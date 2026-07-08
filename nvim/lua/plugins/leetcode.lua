-- ============================================================================
-- LeetCode — problem browser + Obsidian vault integration
--
-- On an accepted submission the plugin automatically:
--   • Creates a rich Markdown note in the Obsidian vault
--   • Infers (or reads from comments) time/space complexity
--   • Spawns a background Gemini AI analysis (requires lc_ai_analyze.py)
--   • For repeat submissions: appends a new solution block instead
-- ============================================================================
return {
  {
    'kawre/leetcode.nvim',
    build = ':TSUpdate html',
    cmd   = 'Leet',   -- only load when you run :Leet (e.g. :Leet menu)
    keys  = {
      { '<leader>lc', '<cmd>Leet menu<cr>', desc = 'LeetCode menu' },
    },
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      -- ── Obsidian vault paths ──────────────────────────────────────────────
      local VAULT_ROOT      = '/Users/aisen/interview-prep_AI-prep_vault/Interview-Prep'
      local PYTHON_VAULT    = VAULT_ROOT .. '/LeetCode'
      local JAVA_VAULT      = VAULT_ROOT .. '/LeetCodeJava'

      local function vault_for_lang(lang)
        return (lang or ''):lower():match('java') and JAVA_VAULT or PYTHON_VAULT
      end

      -- ── String helpers ────────────────────────────────────────────────────
      local function sanitize(title)
        return title:gsub('[\\/:*?"<>|#%%]', ''):gsub('%s+', '-'):lower()
      end

      local function trim(s)
        return (s:gsub('^%s+', ''):gsub('%s+$', ''))
      end

      -- ── Complexity helpers ────────────────────────────────────────────────
      local function normalize_big_o(raw)
        if not raw then return nil end
        local v = trim(raw):gsub('%s+', '')
        if v == '' then return nil end
        if v:match('^[oO]%b()$') then return 'O' .. v:sub(2) end
        if v:match('^[%w%^%+%-%*/]+$') then return ('O(%s)'):format(v) end
        return nil
      end

      local function extract_complexity_from_comments(code)
        local time, space
        for line in code:gmatch('[^\n]+') do
          if not time  then time  = line:match('[Tt]ime.-([oO]%b())') or line:match('T%s*[:=]%s*([oO]%b())') end
          if not space then space = line:match('[Ss]pace.-([oO]%b())') or line:match('S%s*[:=]%s*([oO]%b())') end
          if time and space then break end
        end
        return normalize_big_o(time), normalize_big_o(space)
      end

      local function estimate_python_loop_depth(code)
        local stack, max_depth = {}, 0
        for line in code:gmatch('[^\n]+') do
          local indent  = #(line:match('^%s*') or '')
          local stripped = trim(line)
          if stripped ~= '' and not stripped:match('^#') then
            while #stack > 0 and indent <= stack[#stack] do table.remove(stack) end
            if stripped:match('^for%s+') or stripped:match('^while%s+') then
              table.insert(stack, indent)
              if #stack > max_depth then max_depth = #stack end
            end
          end
        end
        return max_depth
      end

      local function estimate_general_loop_depth(code)
        local max_depth, current_depth = 0, 0
        for line in code:gmatch('[^\n]+') do
          local clean  = line:gsub('//.*$', '')
          local closes = select(2, clean:gsub('}', ''))
          if clean:match('%f[%a]for%f[^%a]') or clean:match('%f[%a]while%f[^%a]') then
            current_depth = current_depth + 1
            if current_depth > max_depth then max_depth = current_depth end
          end
          if closes > 0 then current_depth = math.max(0, current_depth - closes) end
        end
        return max_depth
      end

      local function infer_complexity(lang, code)
        local explicit_time, explicit_space = extract_complexity_from_comments(code)
        if explicit_time and explicit_space then return explicit_time, explicit_space end

        local lc   = code:lower()
        local ll   = (lang or ''):lower()

        local has_sort = lc:match('%.sort%(') or lc:match('sorted%(')
          or lc:match('arrays%.sort%(') or lc:match('collections%.sort%(')

        local looks_like_binary_search =
          lc:match('while%s+[%w_]+%s*[<>=]+%s*[%w_]+') and lc:match('mid')

        local loop_depth = ll:match('py')
          and estimate_python_loop_depth(code)
          or  estimate_general_loop_depth(code)

        local time
        if explicit_time then
          time = explicit_time
        elseif looks_like_binary_search and loop_depth <= 1 then
          time = 'O(log n)'
        elseif loop_depth <= 0 then
          time = has_sort and 'O(n log n)' or 'O(1)'
        elseif loop_depth == 1 then
          time = has_sort and 'O(n log n)' or 'O(n)'
        else
          time = ('O(n^%d)'):format(loop_depth)
        end

        local has_linear_memory = lc:match('hashmap') or lc:match('hashset')
          or lc:match('dict%[') or lc:match('set%(') or lc:match('%f[%a]map%f[^%a]')
          or lc:match('new%s+int%s*%[') or lc:match('new%s+long%s*%[')
          or lc:match('append%(') or lc:match('push%(')
          or lc:match('queue') or lc:match('stack')

        return time, explicit_space or (has_linear_memory and 'O(n)' or 'O(1)')
      end

      -- ── Obsidian note builder ─────────────────────────────────────────────
      local DRAWING_TEMPLATE = '/Users/aisen/interview-prep_AI-prep_vault/templates/Drawing Template.md'
      local FALLBACK_JSON    = 'N4IgLgngDgpiBcIYA8DGBDANgSwCYCd0B3EAGhADcZ8BnbAewDsEAmcm+gV31TkQAswYKDXgB6MQHNsYfpwBGAOlT0AtmIBeNCtlQbs6RmPry6uA4wC0KDDgLFLUTJ2lH8MTDHQ0YNMWHRJMRZFFhCABjIkT1UYRjAaBABtAF1ydCgoAGUAsD5QSXw8LOwNPkZOTExyHRgiACF0VABrQq5GXABhekx6fAQQAGIAM1GxkABfCaA=='

      local function get_drawing_json()
        local tf = io.open(DRAWING_TEMPLATE, 'r')
        if not tf then return FALLBACK_JSON end
        local content = tf:read('*a'); tf:close()
        return content:match('```compressed%-json\n(.-)\n```') or FALLBACK_JSON
      end

      local function build_note(q, lang, code, filename_no_ext)
        local title      = q.title or 'Unknown'
        local difficulty = q.difficulty or 'Unknown'
        local slug       = q.title_slug or ''
        local date       = os.date('%Y-%m-%d')
        local url        = ('https://leetcode.com/problems/%s/'):format(slug)
        local time_c, space_c = infer_complexity(lang, code)

        return table.concat({
          '---',
          'excalidraw-plugin: parsed',
          'tags:',
          '  - excalidraw',
          '  - leetcode',
          'excalidraw-open-md: "true"',
          ('title: "%s"'):format(title:gsub('"', '\\"')),
          ('difficulty: %s'):format(difficulty),
          ('date: %s'):format(date),
          ('link: %s'):format(url),
          ('neetcode: https://neetcode.io/solutions/%s'):format(slug),
          '---',
          ('![[%s]]'):format(filename_no_ext),
          '',
          '## My Solution',
          '',
          ('```%s'):format(lang),
          code,
          '```',
          '',
          '## Complexity',
          '',
          '- **Time**: _AI my time..._',
          '  - **Why**: _AI my time why..._',
          '- **Space**: _AI my space..._',
          '  - **Why**: _AI my space why..._',
          '',
          '## Walkthrough',
          '',
          '_AI generating walkthrough..._',
          '',
          '## Trade-offs & Improvements',
          '',
          '_AI generating analysis..._',
          '',
          '%%',
          '## Drawing',
          '```compressed-json',
          get_drawing_json(),
          '```',
          '%%',
          '',
        }, '\n')
      end

      -- ── Skeleton note (created on question open) ──────────────────────────
      local TEMPLATE_MARKER = '<!-- awaiting-solution -->'

      local function build_template(q, lang, name_no_ext)
        local title      = q.title or 'Unknown'
        local difficulty = q.difficulty or 'Unknown'
        local slug       = q.title_slug or ''
        local date       = os.date('%Y-%m-%d')
        local url        = ('https://leetcode.com/problems/%s/'):format(slug)

        return table.concat({
          '---',
          'excalidraw-plugin: parsed',
          'tags:',
          '  - excalidraw',
          '  - leetcode',
          'excalidraw-open-md: "true"',
          ('title: "%s"'):format(title:gsub('"', '\\"')),
          ('difficulty: %s'):format(difficulty),
          ('date: %s'):format(date),
          ('link: %s'):format(url),
          ('neetcode: https://neetcode.io/solutions/%s'):format(slug),
          '---',
          ('![[%s]]'):format(name_no_ext),
          '',
          TEMPLATE_MARKER,
          '',
          '## My Solution',
          '',
          '_Not yet solved._',
          '',
          '## Complexity',
          '',
          '- **Time**: _TBD_',
          '- **Space**: _TBD_',
          '',
          '## Walkthrough',
          '',
          '_TBD_',
          '',
          '## Trade-offs & Improvements',
          '',
          '_TBD_',
          '',
          '%%',
          '## Drawing',
          '```compressed-json',
          get_drawing_json(),
          '```',
          '%%',
          '',
        }, '\n')
      end

      local function create_skeleton_note(question)
        local q           = question.q
        local lang        = question.lang or 'java'
        local vault       = vault_for_lang(lang)
        local frontend_id = q.frontend_id or q.id or 0
        local name_no_ext = ('%d.%s'):format(frontend_id, sanitize(q.title or 'unknown'))
        local filepath    = vault .. '/' .. name_no_ext .. '.md'

        local existing = io.open(filepath, 'r')
        if existing then existing:close(); return end

        vim.fn.mkdir(vault, 'p')
        local f = io.open(filepath, 'w')
        if f then
          f:write(build_template(q, lang, name_no_ext)); f:close()
          vim.notify(('Skeleton created: %s'):format(name_no_ext .. '.md'),
            vim.log.levels.INFO, { title = 'LeetCode' })
        end
      end

      -- ── Background Claude AI analysis (disabled) ──────────────────────────
      -- local AI_SCRIPT = vim.fn.expand('~/.config/nvim/scripts/lc_ai_analyze.py')
      --
      -- local function spawn_ai_analysis(q, lang, code, filepath, time_c, space_c, mode)
      --   if vim.fn.filereadable(AI_SCRIPT) == 0 then return end
      --   local payload = vim.fn.json_encode({
      --     title             = q.title or 'Unknown',
      --     difficulty        = q.difficulty or 'Unknown',
      --     lang              = lang,
      --     code              = code,
      --     time_complexity   = time_c,
      --     space_complexity  = space_c,
      --     problem_statement = q.content or '',
      --     filepath          = filepath,
      --     mode              = mode or 'full',
      --   })
      --   local job_id = vim.fn.jobstart({ 'python3', AI_SCRIPT }, {
      --     stdin           = 'pipe',
      --     stdout_buffered = true,
      --     stderr_buffered = true,
      --     on_exit = function(_, exit_code)
      --       vim.schedule(function()
      --         if exit_code == 0 then
      --           vim.notify('Claude analysis added to note', vim.log.levels.INFO,  { title = 'LeetCode' })
      --         elseif exit_code == 2 then
      --           vim.notify('Claude quota exceeded — note left with placeholders', vim.log.levels.WARN, { title = 'LeetCode' })
      --         else
      --           vim.notify('Claude analysis failed (see /tmp/lc_ai_analyze.log)', vim.log.levels.WARN, { title = 'LeetCode' })
      --         end
      --       end)
      --     end,
      --   })
      --   vim.fn.chansend(job_id, payload)
      --   vim.fn.chanclose(job_id, 'stdin')
      -- end

      -- ── Patch ResultPopup to save on accepted submission (disabled) ───────
      -- local function patch_result_popup()
      --   local ok, ResultPopup = pcall(require, 'leetcode-ui.popup.console.result')
      --   if not ok or ResultPopup._obsidian_patched then return end
      --   ResultPopup._obsidian_patched = true
      --
      --   local orig_handle = ResultPopup.handle
      --   ResultPopup.handle = function(self, item)
      --     orig_handle(self, item)
      --
      --     if not (item._ and item._.submission and item.status_code == 10) then return end
      --
      --     local question     = self.console.question
      --     local q            = question.q
      --     local lang         = question.lang or 'java'
      --     local code_lines   = vim.api.nvim_buf_get_lines(question.bufnr, 0, -1, false)
      --     local code         = table.concat(code_lines, '\n')
      --
      --     local vault        = vault_for_lang(lang)
      --     local frontend_id  = q.frontend_id or q.id or 0
      --     local name_no_ext  = ('%d.%s'):format(frontend_id, sanitize(q.title or 'unknown'))
      --     local filepath     = vault .. '/' .. name_no_ext .. '.md'
      --
      --     vim.fn.mkdir(vault, 'p')
      --
      --     local existing = io.open(filepath, 'r')
      --     if existing then
      --       local prev_content = existing:read('*a') or ''
      --       existing:close()
      --       if code ~= '' and prev_content:find(code, 1, true) then
      --         vim.notify('Identical to a prior submission — skipping write',
      --           vim.log.levels.INFO, { title = 'LeetCode' })
      --         return
      --       end
      --       local time_c, space_c = infer_complexity(lang, code)
      --       if prev_content:find(TEMPLATE_MARKER, 1, true) then
      --         local f = io.open(filepath, 'w')
      --         if f then
      --           f:write(build_note(q, lang, code, name_no_ext)); f:close()
      --           vim.notify(('Saved to Obsidian: %s'):format(name_no_ext .. '.md'),
      --             vim.log.levels.INFO, { title = 'LeetCode' })
      --           spawn_ai_analysis(q, lang, code, filepath, time_c, space_c, 'full')
      --         end
      --       else
      --         local f = io.open(filepath, 'a')
      --         if f then
      --           local ts = os.date('%Y-%m-%d %H:%M')
      --           f:write(('\n---\n\n## My Solution (%s)\n\n```%s\n%s\n```\n\n## Complexity\n\n- **Time**: _AI my time..._\n  - **Why**: _AI my time why..._\n- **Space**: _AI my space..._\n  - **Why**: _AI my space why..._\n\n## Trade-offs & Improvements\n\n_AI generating analysis..._\n')
      --             :format(ts, lang, code))
      --           f:close()
      --           vim.notify(('Appended solution to: %s'):format(name_no_ext .. '.md'),
      --             vim.log.levels.INFO, { title = 'LeetCode' })
      --           spawn_ai_analysis(q, lang, code, filepath, time_c, space_c, 'append')
      --         end
      --       end
      --     else
      --       local time_c, space_c = infer_complexity(lang, code)
      --       local f = io.open(filepath, 'w')
      --       if f then
      --         f:write(build_note(q, lang, code, name_no_ext)); f:close()
      --         vim.notify(('Saved to Obsidian: %s'):format(name_no_ext .. '.md'),
      --           vim.log.levels.INFO, { title = 'LeetCode' })
      --         spawn_ai_analysis(q, lang, code, filepath, time_c, space_c, 'full')
      --       else
      --         vim.notify(('Failed to write: %s'):format(filepath),
      --           vim.log.levels.ERROR, { title = 'LeetCode' })
      --       end
      --     end
      --   end
      -- end

      -- ── Plugin setup ──────────────────────────────────────────────────────
      require('leetcode').setup({
        lang = 'java',
        cn   = { enabled = false },
        hooks = {
          question_enter = { create_skeleton_note },
        },
      })
    end,
  },
}
