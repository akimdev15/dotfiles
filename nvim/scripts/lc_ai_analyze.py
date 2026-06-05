#!/usr/bin/env python3
"""
LeetCode AI Note Analyzer
Receives problem data via stdin as JSON, calls Gemini CLI (headless),
then updates the Obsidian note with analysis + Excalidraw trace diagram.
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


# ─── Gemini call ──────────────────────────────────────────────────────────────

def call_gemini(title, difficulty, lang, code, time_c, space_c):
    prompt = f"""Analyze this LeetCode solution and return ONLY valid JSON with no markdown fences.

Problem: {title} ({difficulty})
Language: {lang}
Time Complexity: {time_c}  |  Space Complexity: {space_c}

```{lang}
{code}
```

Return exactly this JSON shape:
{{
  "complexity_why": "2-3 sentences WHY the time complexity is {time_c}. Reference specific loops/ops in the code.",
  "tradeoffs": "2-3 sentences on trade-offs of this approach vs alternatives.",
  "improvements": "2-3 sentences on concrete optimizations or alternative approaches.",
  "example": {{
    "input_label": "Short example input string, e.g. nums = [-1,0,1,2,-1,-4]",
    "steps": [
      {{
        "title": "Short step title (e.g. After sorting / i=0 outer loop / Found triplet)",
        "array": [list of numbers or strings representing state — keep to ≤8 elements],
        "pointers": {{"pointer_name": index_integer}},
        "note": "One line: what happened this step and why (≤65 chars)"
      }}
    ]
  }}
}}

Rules for example.steps:
- 4–6 steps maximum showing the KEY state changes (not every iteration)
- array must be actual values at that point (sorted if algorithm sorts, etc.)
- pointers keys: use short names like i, l, r, left, right, mid, slow, fast, prev, cur
- pointer values are 0-based array indices
- note explains the action taken and result
- If the algorithm doesn't use arrays (e.g. trees, strings), use array to show relevant state (chars, node values, stack contents, etc.)"""

    result = subprocess.run(
        ["gemini", "-p", prompt, "-o", "text"],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=120,
        preexec_fn=__import__('os').setsid,
    )

    if result.returncode != 0:
        raise RuntimeError(f"gemini exited {result.returncode}: {result.stderr.strip()}")

    text = result.stdout.strip()
    text = re.sub(r'^```[a-z]*\n?', '', text, flags=re.MULTILINE)
    text = re.sub(r'\n?```$',       '', text, flags=re.MULTILINE)
    match = re.search(r'\{.*\}', text, re.DOTALL)
    if not match:
        raise ValueError(f"No JSON in gemini response: {text[:300]}")
    return json.loads(match.group())


# ─── Note updater ─────────────────────────────────────────────────────────────

def update_note(filepath, analysis, compressed_json):
    with open(filepath, 'r') as f:
        content = f.read()

    replacements = {
        "_AI generating complexity explanation..._": analysis.get("complexity_why", ""),
        "_AI generating trade-off analysis..._":     analysis.get("tradeoffs", ""),
        "_AI generating improvement suggestions..._": analysis.get("improvements", ""),
    }
    for placeholder, value in replacements.items():
        if value:
            content = content.replace(placeholder, value)

    if compressed_json:
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
    """Remove # @leet imports block and markers injected by leetcode.nvim."""
    # Drop everything between @leet imports start / end (inclusive)
    code = re.sub(r'# @leet imports start.*?# @leet imports end\n?', '', code, flags=re.DOTALL)
    # Drop @leet start / @leet end markers
    code = re.sub(r'# @leet (start|end)\n?', '', code)
    return code.strip()


def main():
    data       = json.loads(sys.stdin.read())
    title      = data.get("title", "Unknown")
    difficulty = data.get("difficulty", "Unknown")
    lang       = data.get("lang", "python3")
    code       = strip_leet_boilerplate(data.get("code", ""))
    time_c     = data.get("time_complexity", "O(?)")
    space_c    = data.get("space_complexity", "O(?)")
    filepath   = data.get("filepath", "")

    if not filepath:
        log("[lc_ai] No filepath provided")
        sys.exit(1)

    log(f"[lc_ai] Analyzing {title} via Gemini...")

    try:
        analysis = call_gemini(title, difficulty, lang, code, time_c, space_c)
    except Exception as e:
        log(f"[lc_ai] Gemini error: {e}")
        sys.exit(1)

    example = analysis.get("example")
    if example and example.get("steps"):
        scene = build_trace_diagram(example)
        log(f"[lc_ai] Diagram: {len(example['steps'])} trace steps, "
            f"{len(scene['elements'])} elements")
    else:
        log("[lc_ai] No example trace in response, skipping diagram")
        scene = None

    compressed = compress_to_excalidraw(scene) if scene else None
    update_note(filepath, analysis, compressed)
    log(f"[lc_ai] Note updated: {filepath}")


if __name__ == "__main__":
    main()
