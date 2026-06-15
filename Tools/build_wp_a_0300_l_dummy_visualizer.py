import html
import json
import os
import re
import subprocess


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OBJ_PATH = os.path.join(
    PROJECT_ROOT,
    "ImportSource",
    "Sekiro",
    "Weapons",
    "WP_A_0300",
    "Obj",
    "WP_A_0300_L_CompleteSheathed.obj",
)
OUTPUT_HTML = os.path.join(
    PROJECT_ROOT,
    "Saved",
    "SekiroImportReports",
    "wp_a_0300_l_dummy_visualizer.html",
)
FLVER_EXPORTER = os.path.join(
    PROJECT_ROOT,
    "Tools",
    "SekiroFlverObjExporter",
    "bin",
    "Release",
    "net8.0",
    "SekiroFlverObjExporter.exe",
)
SOURCE_FLVER = (
    r"E:\Sekiro\Sekiro Shadows Die Twice GE\Sekiro Shadows Die Twice GE"
    r"\parts\wp_a_0300_l-partsbnd-dcx\parts\Weapon\WP_A_0300\WP_A_0300_L.flver"
)

DUMMY_LINE_RE = re.compile(
    r"^dummy ref=(?P<ref>-?\d+) parent=(?P<parent>-?\d+):(?P<parent_name>.*?) "
    r"attach=(?P<attach>-?\d+):(?P<attach_name>.*?) "
    r"pos=<(?P<pos>[^>]*)> fwd=<(?P<fwd>[^>]*)> up=<(?P<up>[^>]*)>"
)


def parse_vec(text):
    parts = [float(part.strip()) for part in text.split(",")]
    if len(parts) != 3:
        raise RuntimeError(f"Bad vector: {text}")
    return parts


def to_obj_space(vec):
    return [vec[0], vec[1], -vec[2]]


def sanitize(value):
    token = re.sub(r"[^A-Za-z0-9_]+", "_", value.strip()).strip("_")
    return token or "none"


def parse_obj():
    vertices = []
    edges = set()
    current_object = "global"
    object_ranges = {}

    def touch_object(name):
        if name not in object_ranges:
            object_ranges[name] = {"start": len(vertices), "end": len(vertices)}

    touch_object(current_object)
    with open(OBJ_PATH, "r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line.startswith("o "):
                current_object = line[2:].strip()
                touch_object(current_object)
                continue
            if line.startswith("v "):
                values = [float(part) for part in line.split()[1:4]]
                vertices.append(values)
                object_ranges[current_object]["end"] = len(vertices)
                continue
            if line.startswith("f "):
                face_indices = []
                for token in line.split()[1:]:
                    raw_index = token.split("/")[0]
                    if not raw_index:
                        continue
                    index = int(raw_index)
                    if index < 0:
                        index = len(vertices) + index + 1
                    face_indices.append(index - 1)
                for a, b in zip(face_indices, face_indices[1:] + face_indices[:1]):
                    edges.add(tuple(sorted((a, b))))

    mins = [min(vertex[i] for vertex in vertices) for i in range(3)]
    maxs = [max(vertex[i] for vertex in vertices) for i in range(3)]
    center = [(mins[i] + maxs[i]) * 0.5 for i in range(3)]
    return {
        "vertices": vertices,
        "edges": [list(edge) for edge in sorted(edges)],
        "bounds": {"mins": mins, "maxs": maxs, "center": center},
        "objects": object_ranges,
    }


def parse_dummies():
    result = subprocess.run(
        [FLVER_EXPORTER, "--inspect", SOURCE_FLVER],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr or result.stdout)

    dummies = []
    for line in result.stdout.splitlines():
        match = DUMMY_LINE_RE.match(line.strip())
        if not match:
            continue
        index = len(dummies)
        ref = int(match.group("ref"))
        parent = match.group("parent_name")
        attach = match.group("attach_name")
        pos = parse_vec(match.group("pos"))
        fwd = parse_vec(match.group("fwd"))
        up = parse_vec(match.group("up"))
        dummies.append(
            {
                "index": index,
                "referenceId": ref,
                "name": f"FLVERDummy_{ref:03d}_{index:02d}_P_{sanitize(parent)}_A_{sanitize(attach)}",
                "parentBone": parent,
                "attachBone": attach,
                "position": to_obj_space(pos),
                "forward": to_obj_space(fwd),
                "upward": to_obj_space(up),
            }
        )
    return dummies


def build_html(payload):
    payload_json = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
    title = "WP_A_0300_L FLVER Dummy Visualizer"
    return f"""<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<style>
html, body {{ margin: 0; height: 100%; overflow: hidden; background: #111418; color: #e7eaf0; font-family: Segoe UI, sans-serif; }}
#wrap {{ display: grid; grid-template-columns: minmax(0, 1fr) 360px; height: 100%; }}
canvas {{ width: 100%; height: 100%; display: block; background: #0b0e11; }}
aside {{ border-left: 1px solid #303640; background: #171b20; overflow: auto; }}
h1 {{ font-size: 15px; margin: 14px 14px 8px; font-weight: 650; }}
.meta {{ margin: 0 14px 12px; color: #aeb6c2; font-size: 12px; line-height: 1.55; }}
.controls {{ display: flex; gap: 8px; padding: 0 14px 12px; }}
button {{ background: #2a313b; color: #e7eaf0; border: 1px solid #3b4654; padding: 6px 10px; border-radius: 4px; cursor: pointer; }}
button:hover {{ background: #36404c; }}
.row {{ padding: 8px 14px; border-top: 1px solid #252b33; cursor: pointer; font-size: 12px; }}
.row:hover, .row.active {{ background: #26303a; }}
.name {{ color: #ff6b5f; font-weight: 650; }}
.small {{ color: #aeb6c2; margin-top: 3px; line-height: 1.35; }}
.legend {{ position: fixed; left: 14px; top: 12px; background: rgba(17,20,24,.78); border: 1px solid #303640; padding: 8px 10px; font-size: 12px; color: #cad1da; }}
</style>
</head>
<body>
<div id="wrap">
  <main><canvas id="view"></canvas><div class="legend">左键拖拽旋转，滚轮缩放。红点是 FLVER dummy，灰线是导出的收刀组合模型。</div></main>
  <aside>
    <h1>WP_A_0300_L 原始 Dummy</h1>
    <div class="meta" id="meta"></div>
    <div class="controls">
      <button id="reset">重置视角</button>
      <button id="labels">标签开/关</button>
    </div>
    <div id="list"></div>
  </aside>
</div>
<script>
const DATA = {payload_json};
const canvas = document.getElementById('view');
const ctx = canvas.getContext('2d');
const state = {{ yaw: -0.7, pitch: 0.25, zoom: 8.5, panX: 0, panY: 0, dragging: false, lastX: 0, lastY: 0, selected: 0, labels: true }};
const center = DATA.mesh.bounds.center;

document.getElementById('meta').innerHTML =
  `vertices: ${{DATA.mesh.vertices.length}}<br>edges: ${{DATA.mesh.edges.length}}<br>dummies: ${{DATA.dummies.length}}<br>source: WP_A_0300_L.flver`;

const list = document.getElementById('list');
DATA.dummies.forEach((d, i) => {{
  const div = document.createElement('div');
  div.className = 'row';
  div.innerHTML = `<div class="name">${{d.name}}</div><div class="small">ref=${{d.referenceId}} parent=${{d.parentBone}} attach=${{d.attachBone}}<br>pos=(${{d.position.map(v=>v.toFixed(4)).join(', ')}})</div>`;
  div.onclick = () => {{ state.selected = i; updateList(); draw(); }};
  list.appendChild(div);
}});
function updateList() {{
  [...list.children].forEach((el, i) => el.classList.toggle('active', i === state.selected));
}}
updateList();

document.getElementById('reset').onclick = () => {{ state.yaw = -0.7; state.pitch = 0.25; state.zoom = 8.5; state.panX = 0; state.panY = 0; draw(); }};
document.getElementById('labels').onclick = () => {{ state.labels = !state.labels; draw(); }};

canvas.addEventListener('mousedown', e => {{ state.dragging = true; state.lastX = e.clientX; state.lastY = e.clientY; }});
window.addEventListener('mouseup', () => state.dragging = false);
window.addEventListener('mousemove', e => {{
  if (!state.dragging) return;
  const dx = e.clientX - state.lastX, dy = e.clientY - state.lastY;
  state.lastX = e.clientX; state.lastY = e.clientY;
  state.yaw += dx * 0.008;
  state.pitch = Math.max(-1.45, Math.min(1.45, state.pitch + dy * 0.008));
  draw();
}});
canvas.addEventListener('wheel', e => {{ e.preventDefault(); state.zoom *= Math.exp(-e.deltaY * 0.001); draw(); }}, {{ passive: false }});

function resize() {{
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = Math.floor(rect.width * dpr);
  canvas.height = Math.floor(rect.height * dpr);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  draw();
}}
window.addEventListener('resize', resize);

function rotate(p) {{
  let x = p[0] - center[0], y = p[1] - center[1], z = p[2] - center[2];
  const cy = Math.cos(state.yaw), sy = Math.sin(state.yaw);
  const cp = Math.cos(state.pitch), sp = Math.sin(state.pitch);
  const x1 = x * cy - y * sy;
  const y1 = x * sy + y * cy;
  const z1 = z;
  const y2 = y1 * cp - z1 * sp;
  const z2 = y1 * sp + z1 * cp;
  return [x1, y2, z2];
}}
function project(p) {{
  const r = rotate(p);
  const scale = Math.min(canvas.clientWidth, canvas.clientHeight) * state.zoom / 120;
  return [canvas.clientWidth * .5 + r[0] * scale + state.panX, canvas.clientHeight * .5 - r[1] * scale + state.panY, r[2]];
}}
function draw() {{
  ctx.clearRect(0, 0, canvas.clientWidth, canvas.clientHeight);
  ctx.lineWidth = 0.75;
  ctx.strokeStyle = 'rgba(160,170,180,.35)';
  ctx.beginPath();
  for (const [a, b] of DATA.mesh.edges) {{
    const pa = project(DATA.mesh.vertices[a]);
    const pb = project(DATA.mesh.vertices[b]);
    ctx.moveTo(pa[0], pa[1]);
    ctx.lineTo(pb[0], pb[1]);
  }}
  ctx.stroke();

  DATA.dummies.forEach((d, i) => {{
    const p = project(d.position);
    const selected = i === state.selected;
    ctx.fillStyle = selected ? '#ffd166' : '#ff4d4d';
    ctx.strokeStyle = '#111418';
    ctx.lineWidth = selected ? 3 : 2;
    ctx.beginPath();
    ctx.arc(p[0], p[1], selected ? 6 : 4, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
    if (state.labels || selected) {{
      ctx.font = selected ? '13px Segoe UI' : '11px Segoe UI';
      ctx.fillStyle = selected ? '#ffd166' : '#ff9a94';
      ctx.fillText(`${{d.referenceId}}:${{d.index}}`, p[0] + 8, p[1] - 8);
    }}
  }});
}}
resize();
</script>
</body>
</html>"""


def main():
    payload = {
        "mesh": parse_obj(),
        "dummies": parse_dummies(),
        "sourceFlver": SOURCE_FLVER,
        "sourceObj": OBJ_PATH,
    }
    os.makedirs(os.path.dirname(OUTPUT_HTML), exist_ok=True)
    with open(OUTPUT_HTML, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(build_html(payload))
    print(OUTPUT_HTML)


if __name__ == "__main__":
    main()
