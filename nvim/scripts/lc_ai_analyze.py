#!/usr/bin/env python3
"""
LeetCode AI Note Analyzer
Receives problem data via stdin as JSON, calls Claude Sonnet (headless),
then updates the Obsidian note with complexity analysis + Excalidraw trace.
"""

import sys
import json
import re
import random
import time
import subprocess

# ─── ID / seed helpers ────────────────────────────────────────────────────────

def make_id(seed=None):
    r = random.Random(seed)
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return "".join(r.choice(chars) for _ in range(8))

def make_seed():
    return random.randint(10000, 99999)

TS = int(time.time() * 1000)

# ─── Excalidraw primitive builders ────────────────────────────────────────────

POINTER_COLORS = {
    "i":      ("#e67700", "#fff3bf"),   # amber
    "l":      ("#1971c2", "#d0ebff"),   # blue
    "r":      ("#2f9e44", "#d3f9d8"),   # green
    "left":   ("#1971c2", "#d0ebff"),
    "right":  ("#2f9e44", "#d3f9d8"),
    "mid":    ("#ae3ec9", "#f3d9fa"),   # purple
    "slow":   ("#1971c2", "#d0ebff"),
    "fast":   ("#c92a2a", "#ffe3e3"),
    "prev":   ("#5c7cfa", "#edf2ff"),
    "cur":    ("#f76707", "#fff4e6"),
    "found":  ("#f76707", "#fff4e6"),
}
DEFAULT_CELL  = ("#495057", "#f1f3f5")
TITLE_COLOR   = ("#1e1e2e", "#e9ecef")
NOTE_COLOR    = ("#5c7cfa", "transparent")

def base_el(eid, etype, x, y, w, h, stroke, bg):
    return {
        "id": eid, "type": etype,
        "x": x, "y": y, "width": w, "height": h,
        "angle": 0,
        "strokeColor": stroke, "backgroundColor": bg,
        "fillStyle": "solid", "strokeWidth": 2, "strokeStyle": "solid",
        "roughness": 1, "opacity": 100,
        "groupIds": [], "frameId": None,
        "roundness": {"type": 3},
        "seed": make_seed(), "version": 1, "versionNonce": make_seed(),
        "isDeleted": False, "boundElements": [],
        "updated": TS, "link": None, "locked": False,
    }

def text_el(eid, x, y, w, h, txt, stroke, font_size=13, container=None, bold=False):
    family = 1
    el = {
        "id": eid, "type": "text",
        "x": x, "y": y, "width": w, "height": h,
        "angle": 0,
        "strokeColor": stroke, "backgroundColor": "transparent",
        "fillStyle": "solid", "strokeWidth": 1, "strokeStyle": "solid",
        "roughness": 1, "opacity": 100,
        "groupIds": [], "frameId": None, "roundness": None,
        "seed": make_seed(), "version": 1, "versionNonce": make_seed(),
        "isDeleted": False, "boundElements": [],
        "updated": TS, "link": None, "locked": False,
        "text": str(txt)[:60],
        "fontSize": font_size,
        "fontFamily": family,
        "textAlign": "center",
        "verticalAlign": "middle",
        "baseline": font_size - 2,
        "containerId": container,
        "originalText": str(txt)[:60],
    }
    return el

def arrow_el(eid, x1, y1, x2, y2, src_id=None, dst_id=None):
    dx, dy = x2 - x1, y2 - y1
    el = {
        "id": eid, "type": "arrow",
        "x": x1, "y": y1, "width": abs(dx), "height": abs(dy),
        "angle": 0,
        "strokeColor": "#868e96", "backgroundColor": "transparent",
        "fillStyle": "solid", "strokeWidth": 1, "strokeStyle": "solid",
        "roughness": 1, "opacity": 80,
        "groupIds": [], "frameId": None,
        "roundness": {"type": 2},
        "seed": make_seed(), "version": 1, "versionNonce": make_seed(),
        "isDeleted": False, "boundElements": [],
        "updated": TS, "link": None, "locked": False,
        "points": [[0, 0], [dx, dy]],
        "lastCommittedPoint": None,
        "startBinding": {"elementId": src_id, "focus": 0, "gap": 2} if src_id else None,
        "endBinding":   {"elementId": dst_id, "focus": 0, "gap": 2} if dst_id else None,
        "startArrowhead": None, "endArrowhead": "arrow",
    }
    return el

# ─── Trace diagram builder ─────────────────────────────────────────────────────

CELL_W  = 46   # width of each array cell
CELL_H  = 38   # height of each array cell
PTR_H   = 18   # pointer label height above cell
NOTE_H  = 22   # note text height
TITLE_H = 26   # step title height
GAP_Y   = 28   # vertical gap between steps
START_X = 60
START_Y = 50

def build_trace_diagram(example):
    """
    example = {
      "input_label": "nums = [-1, 0, 1, 2, -1, -4]",
      "steps": [
        {
          "title": "After sorting",
          "array": [-4, -1, -1, 0, 1, 2],
          "pointers": {"i": 0, "l": 1, "r": 5},
          "note": "sum = -4+-1+2 = -3 < 0, move l right"
        },
        ...
      ]
    }
    """
    elements = []
    steps = example.get("steps", [])
    if not steps:
        return None

    # Determine max array length for consistent width
    max_len = max((len(s.get("array", [])) for s in steps), default=1)
    row_w = max_len * CELL_W

    # Header: input label
    hid = make_id(9000)
    htid = make_id(9001)
    header = base_el(hid, "rectangle", START_X, START_Y, row_w + 20, TITLE_H + 4,
                     "#5c7cfa", "#edf2ff")
    header["roundness"] = {"type": 3}
    header["boundElements"] = [{"type": "text", "id": htid}]
    elements.append(header)
    elements.append(text_el(htid, START_X + 5, START_Y + 2, row_w + 10, TITLE_H,
                            example.get("input_label", "Example"), "#1e1e2e",
                            font_size=13, container=hid))

    cur_y = START_Y + TITLE_H + 4 + GAP_Y
    prev_step_arrow_src = None  # id of last cell row box for step arrows

    for si, step in enumerate(steps):
        arr   = step.get("array", [])
        ptrs  = step.get("pointers", {})   # e.g. {"i": 0, "l": 1, "r": 5}
        title = step.get("title", f"Step {si+1}")
        note  = step.get("note", "")

        # Build reverse map: index → list of pointer names at that index
        idx_to_ptrs = {}
        for pname, pidx in ptrs.items():
            if isinstance(pidx, int) and 0 <= pidx < len(arr):
                idx_to_ptrs.setdefault(pidx, []).append(pname)

        # ── Step title ──
        ttid = make_id(si * 1000 + 100)
        tttid = make_id(si * 1000 + 101)
        title_box = base_el(ttid, "rectangle", START_X, cur_y, row_w + 20, TITLE_H,
                            "#343a40", "#343a40")
        title_box["roundness"] = {"type": 3}
        title_box["boundElements"] = [{"type": "text", "id": tttid}]
        elements.append(title_box)
        elements.append(text_el(tttid, START_X + 4, cur_y + 2, row_w + 12, TITLE_H - 4,
                                title[:55], "#ffffff", font_size=12, container=ttid))

        cur_y += TITLE_H + 6

        # ── Pointer labels row (above cells) ──
        cur_y += PTR_H  # reserve space; labels placed at cur_y - PTR_H

        # ── Array cells ──
        cell_top = cur_y
        cell_ids = []
        for ci, val in enumerate(arr):
            cx = START_X + ci * CELL_W
            cid = make_id(si * 1000 + 200 + ci)
            ctid = make_id(si * 1000 + 300 + ci)

            # Pick color: first pointer at this index wins
            ptr_names = idx_to_ptrs.get(ci, [])
            if ptr_names:
                pname = ptr_names[0].lower()
                stroke, bg = POINTER_COLORS.get(pname, ("#f76707", "#fff4e6"))
            else:
                stroke, bg = DEFAULT_CELL

            cell = base_el(cid, "rectangle", cx, cell_top, CELL_W - 2, CELL_H,
                           stroke, bg)
            cell["roundness"] = {"type": 2}
            cell["boundElements"] = [{"type": "text", "id": ctid}]
            elements.append(cell)
            elements.append(text_el(ctid, cx + 2, cell_top + 2, CELL_W - 6, CELL_H - 4,
                                    str(val), stroke, font_size=13, container=cid))
            cell_ids.append(cid)

            # Pointer label(s) above this cell
            for pi, pname in enumerate(ptr_names):
                plid = make_id(si * 1000 + 400 + ci * 10 + pi)
                ptr_stroke, _ = POINTER_COLORS.get(pname.lower(), ("#f76707", "#fff4e6"))
                lbl = text_el(plid,
                              cx, cell_top - PTR_H + 2,
                              CELL_W - 2, PTR_H - 4,
                              pname, ptr_stroke, font_size=11)
                lbl["textAlign"] = "center"
                elements.append(lbl)

        cur_y += CELL_H + 6

        # ── Note below cells ──
        if note:
            nid  = make_id(si * 1000 + 500)
            ntid = make_id(si * 1000 + 501)
            note_box = base_el(nid, "rectangle", START_X, cur_y, row_w + 20, NOTE_H + 4,
                               "#5c7cfa", "transparent")
            note_box["strokeStyle"] = "dashed"
            note_box["strokeWidth"] = 1
            note_box["roughness"] = 0
            note_box["roundness"] = {"type": 3}
            note_box["boundElements"] = [{"type": "text", "id": ntid}]
            elements.append(note_box)
            elements.append(text_el(ntid, START_X + 4, cur_y + 2, row_w + 12, NOTE_H,
                                    note[:65], "#364fc7", font_size=12, container=nid))
            cur_y += NOTE_H + 4

        cur_y += GAP_Y

    return {
        "type": "excalidraw",
        "version": 2,
        "source": "https://excalidraw.com",
        "elements": elements,
        "appState": {"gridSize": None, "viewBackgroundColor": "#ffffff"},
        "files": {},
    }


# ─── Compression ──────────────────────────────────────────────────────────────

def compress_to_excalidraw(scene_dict):
    try:
        import lzstring
        lz = lzstring.LZString()
        return lz.compressToBase64(json.dumps(scene_dict, separators=(',', ':')))
    except Exception as e:
        log(f"[lc_ai] lzstring compress failed: {e}")
        return None


# ─── Claude call infrastructure ───────────────────────────────────────────────

SONNET_MODEL = "claude-sonnet-4-6"

class QuotaExceeded(Exception):
    pass

def _is_quota_error(text):
    if not text:
        return False
    t = text.lower()
    return any(s in t for s in (
        "rate limit", "quota", "usage limit", "exceeded", "5-hour", "5 hour",
        "too many requests", "throttled",
    ))

def run_claude(prompt, timeout=180):
    """Run claude CLI headless. Raises QuotaExceeded or RuntimeError."""
    result = subprocess.run(
        ["claude", "-p", prompt, "--model", SONNET_MODEL, "--output-format", "text"],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=timeout,
        cwd="/tmp",  # avoid loading project CLAUDE.md from nvim's cwd
        preexec_fn=__import__('os').setsid,
    )
    if result.returncode != 0:
        err = (result.stderr or "").strip() or (result.stdout or "").strip()
        if _is_quota_error(err):
            raise QuotaExceeded(f"claude quota: {err[:200]}")
        raise RuntimeError(f"claude exited {result.returncode}: {err[:300]}")
    text = result.stdout.strip()
    if _is_quota_error(text):
        raise QuotaExceeded(f"claude quota in stdout: {text[:200]}")
    return text

def parse_json_response(text):
    text = re.sub(r'^```[a-zA-Z0-9]*\n?', '', text, flags=re.MULTILINE)
    text = re.sub(r'\n?```$',              '', text, flags=re.MULTILINE)
    match = re.search(r'\{.*\}', text, re.DOTALL)
    if not match:
        raise ValueError(f"No JSON in response: {text[:300]}")
    return json.loads(match.group())

def strip_html(s):
    """Coarse HTML → plain text for problem statement."""
    if not s:
        return ""
    s = re.sub(r'<sup>(.*?)</sup>', r'^\1', s, flags=re.DOTALL)
    s = re.sub(r'<sub>(.*?)</sub>', r'_\1', s, flags=re.DOTALL)
    s = re.sub(r'<code>(.*?)</code>', r'`\1`', s, flags=re.DOTALL)
    s = re.sub(r'<br\s*/?>', '\n', s, flags=re.IGNORECASE)
    s = re.sub(r'</p>', '\n\n', s, flags=re.IGNORECASE)
    s = re.sub(r'</li>', '\n', s, flags=re.IGNORECASE)
    s = re.sub(r'<[^>]+>', '', s)
    s = (s.replace('&nbsp;', ' ').replace('&lt;', '<').replace('&gt;', '>')
           .replace('&amp;', '&').replace('&quot;', '"').replace('&#39;', "'"))
    s = re.sub(r'\n{3,}', '\n\n', s)
    return s.strip()

# ─── Sonnet: full analysis of user's submission ───────────────────────────────

COMPLEXITY_INSTRUCTIONS = """Complexity analysis rules — apply ALL:
- Determine Big-O from the ACTUAL code structure, not the problem category
- Count loop nesting carefully; amortized ops (HashMap, monotonic stack/deque, union-find path compression) are O(1) amortized per operation — do NOT treat them as O(n) per call
- Recursion: space complexity MUST include the call stack depth (e.g. O(h) for tree DFS where h is tree height, O(n) for linear recursion)
- Amortized total: if an element is pushed/popped from a structure at most once across all iterations, the total work is O(n) even inside nested loops
- If you are uncertain about an amortized or non-obvious bound, write the complexity followed by "[verify]" — do NOT guess"""

def call_sonnet_full(title, difficulty, lang, problem_statement, user_code, heuristic_time, heuristic_space):
    prompt = f"""Analyze this LeetCode submission. Return ONLY JSON, no markdown fences.

Problem: {title} ({difficulty})

Problem statement:
{problem_statement or '(not provided)'}

Submitter's code:
```{lang}
{user_code}
```

Heuristic guess (often wrong — verify from code): Time≈{heuristic_time}, Space≈{heuristic_space}.

{COMPLEXITY_INSTRUCTIONS}

JSON shape:
{{
  "my_time": "Big-O time. Exact. Include log/amortized factors.",
  "my_time_why": "1-2 sentences. Reference specific loops, recursion, or amortized ops in the code.",
  "my_space": "Big-O space. Include recursion call stack if applicable.",
  "my_space_why": "1-2 sentences. Reference what data structures or call stack frames are allocated.",
  "tradeoffs": "1-2 sentences: trade-offs of this approach vs common alternatives (time/space, simplicity, edge cases).",
  "improvements": "1-2 sentences: concrete suggestions to improve time, space, or code quality.",
  "is_complex": true_or_false,
  "walkthrough_md": "ONLY when is_complex=false. Concise markdown: small worked example ≤8 lines, use a table or bulleted iteration list. Empty string when is_complex=true.",
  "example": {{
    "input_label": "ONLY when is_complex=true. Short input, e.g. nums = [0,3,7,2,5,8,4,6,0,1]. Empty object when is_complex=false.",
    "steps": [
      {{
        "title": "Short step title",
        "array": [list of ≤8 values representing state],
        "pointers": {{"pointer_name": index_integer}},
        "note": "≤65 chars: what happened and why"
      }}
    ]
  }}
}}

Decide is_complex:
- false → hashmap lookups, single-pass counting, simple two-pointer, basic stack/queue, set membership
- true  → backtracking, DP with non-trivial state, graph traversal, sliding window with multiple invariants, tree DP, monotonic stack/deque, union-find

Rules for example.steps when is_complex=true:
- 4–6 steps showing KEY state changes only
- pointers: i, l, r, left, right, mid, slow, fast, prev, cur
- For non-array problems (trees/graphs/strings), array holds relevant state (node values, stack contents, chars)"""
    text = run_claude(prompt, timeout=180)
    return parse_json_response(text)

# ─── Sonnet: slim resubmit analysis ──────────────────────────────────────────

def call_sonnet_append(title, difficulty, lang, problem_statement, code,
                       heuristic_time, heuristic_space):
    prompt = f"""Analyze this LeetCode submission. Return ONLY JSON, no markdown fences.

Problem: {title} ({difficulty})

Problem statement:
{problem_statement or '(not provided)'}

Submitter's code:
```{lang}
{code}
```

Heuristic guess (often wrong — verify from code): Time≈{heuristic_time}, Space≈{heuristic_space}.

{COMPLEXITY_INSTRUCTIONS}

JSON shape:
{{
  "my_time": "Big-O time. Exact.",
  "my_time_why": "1-2 sentences. Reference specific loops/ops/recursion in the code.",
  "my_space": "Big-O space. Include recursion stack if relevant.",
  "my_space_why": "1-2 sentences. Reference what is stored.",
  "tradeoffs": "1-2 sentences: trade-offs vs common alternatives.",
  "improvements": "1-2 sentences: concrete suggestions."
}}"""
    text = run_claude(prompt, timeout=90)
    return parse_json_response(text)

# ─── Note updater ─────────────────────────────────────────────────────────────

def update_note(filepath, analysis, compressed_json, is_complex, walkthrough_md):
    with open(filepath, 'r') as f:
        content = f.read()

    replacements = {
        "_AI my time..._":     analysis.get("my_time", ""),
        "_AI my time why..._": analysis.get("my_time_why", ""),
        "_AI my space..._":    analysis.get("my_space", ""),
        "_AI my space why..._": analysis.get("my_space_why", ""),
        "_AI generating analysis..._": (
            (analysis.get("tradeoffs", "") + "\n\n" + analysis.get("improvements", "")).strip()
        ),
    }
    for placeholder, value in replacements.items():
        if value:
            content = content.replace(placeholder, value)

    if is_complex:
        walkthrough_text = "See the attached Excalidraw drawing for a step-by-step trace."
    else:
        walkthrough_text = walkthrough_md.strip() or "See the attached drawing."
    content = content.replace("_AI generating walkthrough..._", walkthrough_text)

    if is_complex and compressed_json:
        content = re.sub(
            r'(```compressed-json\n).*?(\n```)',
            lambda m: m.group(1) + compressed_json + m.group(2),
            content,
            flags=re.DOTALL,
        )

    with open(filepath, 'w') as f:
        f.write(content)


# ─── Logging ──────────────────────────────────────────────────────────────────

LOG_FILE = "/tmp/lc_ai_analyze.log"

def log(msg):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"[{ts}] {msg}\n")
    print(msg, file=sys.stderr)


# ─── Entry point ──────────────────────────────────────────────────────────────

def strip_leet_boilerplate(code):
    """Remove @leet imports block and markers injected by leetcode.nvim (py + java)."""
    # Python-style
    code = re.sub(r'#\s*@leet imports start.*?#\s*@leet imports end\n?', '', code, flags=re.DOTALL)
    code = re.sub(r'#\s*@leet (start|end)\n?', '', code)
    # Java/JS-style
    code = re.sub(r'//\s*@leet imports start.*?//\s*@leet imports end\n?', '', code, flags=re.DOTALL)
    code = re.sub(r'//\s*@leet (start|end)\n?', '', code)
    return code.strip()


def call_sonnet_append(title, difficulty, lang, problem_statement, code,
                       heuristic_time, heuristic_space):
    """Slim prompt for repeat submissions — fills my_time/my_space + Whys."""
    prompt = f"""Return ONLY JSON, no markdown fences.

Problem: {title} ({difficulty})

Problem statement:
{problem_statement or '(not provided)'}

Submitter's code:
```{lang}
{code}
```

Heuristic guess (often wrong, verify yourself): Time≈{heuristic_time}, Space≈{heuristic_space}.

JSON shape:
{{
  "my_time": "Big-O time of submitter's code. Determine from the actual code, not the heuristic.",
  "my_time_why": "1-2 sentences justifying my_time. Reference specific loops/ops/recursion.",
  "my_space": "Big-O space of submitter's code. Include recursion stack if relevant.",
  "my_space_why": "1-2 sentences justifying my_space. Reference what is stored."
}}"""
    text = run_claude(prompt, SONNET_MODEL, timeout=90)
    return parse_json_response(text)


def update_note_append(filepath, analysis):
    with open(filepath, 'r') as f:
        content = f.read()
    for placeholder, value in {
        "_AI my time..._":              analysis.get("my_time", ""),
        "_AI my time why..._":          analysis.get("my_time_why", ""),
        "_AI my space..._":             analysis.get("my_space", ""),
        "_AI my space why..._":         analysis.get("my_space_why", ""),
        "_AI generating analysis..._":  (
            (analysis.get("tradeoffs", "") + "\n\n" + analysis.get("improvements", "")).strip()
        ),
    }.items():
        if value:
            content = content.replace(placeholder, value)
    with open(filepath, 'w') as f:
        f.write(content)


def main():
    data              = json.loads(sys.stdin.read())
    title             = data.get("title", "Unknown")
    difficulty        = data.get("difficulty", "Unknown")
    lang              = data.get("lang", "java")
    code              = strip_leet_boilerplate(data.get("code", ""))
    time_c            = data.get("time_complexity", "O(?)")
    space_c           = data.get("space_complexity", "O(?)")
    filepath          = data.get("filepath", "")
    mode              = data.get("mode", "full")
    problem_statement = strip_html(data.get("problem_statement", ""))

    if not filepath:
        log("[lc_ai] No filepath provided")
        sys.exit(1)

    if mode == "append":
        log(f"[lc_ai] Append (Sonnet) for {title}...")
        try:
            analysis = call_sonnet_append(title, difficulty, lang, problem_statement,
                                          code, time_c, space_c)
        except QuotaExceeded as e:
            log(f"[lc_ai] Quota (append): {e}")
            sys.exit(2)
        except Exception as e:
            log(f"[lc_ai] Error (append): {e}")
            sys.exit(1)
        update_note_append(filepath, analysis)
        log(f"[lc_ai] Append note updated: {filepath}")
        return

    log(f"[lc_ai] Full analysis (Sonnet) for {title} [{difficulty}]...")
    try:
        analysis = call_sonnet_full(title, difficulty, lang, problem_statement,
                                    code, time_c, space_c)
    except QuotaExceeded as e:
        log(f"[lc_ai] Quota: {e}")
        sys.exit(2)
    except Exception as e:
        log(f"[lc_ai] Error: {e}")
        sys.exit(1)

    is_complex     = bool(analysis.get("is_complex", False))
    walkthrough_md = analysis.get("walkthrough_md", "") or ""
    example        = analysis.get("example") or {}

    scene = None
    if is_complex and example.get("steps"):
        scene = build_trace_diagram(example)
        log(f"[lc_ai] Diagram: {len(example['steps'])} steps, {len(scene['elements'])} elements")
    elif is_complex:
        log("[lc_ai] is_complex=true but no steps — skipping diagram")
    else:
        log("[lc_ai] Simple → markdown walkthrough")

    compressed = compress_to_excalidraw(scene) if scene else None
    update_note(filepath, analysis, compressed, is_complex, walkthrough_md)
    log(f"[lc_ai] Note updated: {filepath}")


if __name__ == "__main__":
    main()
