import json
import os
import urllib.error
import urllib.request
from pathlib import Path


DEFAULT_MCP_PORT = 9316
DEFAULT_MCP_URL = f"http://127.0.0.1:{DEFAULT_MCP_PORT}/mcp"
PROJECT_ROOT = Path(__file__).resolve().parent.parent
MONOLITH_SENTINEL_PATH = PROJECT_ROOT / "Plugins" / "Monolith" / "Saved" / ".monolith_running"
MONOLITH_CONFIG_PATHS = (
    PROJECT_ROOT / "Saved" / "Config" / "WindowsEditor" / "Monolith.ini",
    PROJECT_ROOT / "Saved" / "Config" / "Windows" / "Monolith.ini",
    PROJECT_ROOT / "Config" / "DefaultMonolith.ini",
)
MCP_URL = os.environ.get("MONOLITH_MCP_URL", DEFAULT_MCP_URL)


class MCPError(RuntimeError):
    pass


def _normalize_port(value: object) -> int | None:
    try:
        port = int(value)
    except (TypeError, ValueError):
        return None

    if 1 <= port <= 65535:
        return port
    return None


def _url_from_port(port: int) -> str:
    return f"http://127.0.0.1:{port}/mcp"


def _parse_monolith_ini_port(path: Path) -> int | None:
    if not path.is_file():
        return None

    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return None

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith(("[", ";", "#")):
            continue
        if not line.startswith("ServerPort="):
            continue
        return _normalize_port(line.partition("=")[2].strip())

    return None


def _read_sentinel_port() -> int | None:
    if not MONOLITH_SENTINEL_PATH.is_file():
        return None

    try:
        payload = json.loads(MONOLITH_SENTINEL_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None

    return _normalize_port(payload.get("port"))


def discover_mcp_urls() -> list[str]:
    candidates: list[str] = []

    def add_url(url: str | None):
        if url and url not in candidates:
            candidates.append(url)

    env_url = os.environ.get("MONOLITH_MCP_URL")
    env_port = _normalize_port(os.environ.get("MONOLITH_MCP_PORT"))
    sentinel_port = _read_sentinel_port()

    add_url(env_url)
    if env_port is not None:
        add_url(_url_from_port(env_port))
    if sentinel_port is not None:
        add_url(_url_from_port(sentinel_port))

    for config_path in MONOLITH_CONFIG_PATHS:
        config_port = _parse_monolith_ini_port(config_path)
        if config_port is not None:
            add_url(_url_from_port(config_port))

    add_url(DEFAULT_MCP_URL)
    return candidates


class MCPClient:
    def __init__(self, url: str | None = None):
        self.url = url or MCP_URL
        self._next_id = 1
        self._candidate_urls = discover_mcp_urls()
        if self.url not in self._candidate_urls:
            self._candidate_urls.insert(0, self.url)

    def call(self, tool_name: str, action: str, params: dict | None = None):
        payload = {
            "jsonrpc": "2.0",
            "id": self._next_id,
            "method": "tools/call",
            "params": {
                "name": tool_name,
                "arguments": {
                    "action": action,
                    "params": params or {},
                },
            },
        }
        self._next_id += 1

        raw = None
        last_error: Exception | None = None
        attempt_urls = [self.url]
        attempt_urls.extend(url for url in self._candidate_urls if url != self.url)

        for candidate_url in attempt_urls:
            request = urllib.request.Request(
                candidate_url,
                data=json.dumps(payload).encode("utf-8"),
                headers={"Content-Type": "application/json"},
                method="POST",
            )

            try:
                with urllib.request.urlopen(request, timeout=120) as response:
                    raw = json.loads(response.read().decode("utf-8"))
                self.url = candidate_url
                if candidate_url in self._candidate_urls:
                    self._candidate_urls.remove(candidate_url)
                self._candidate_urls.insert(0, candidate_url)
                break
            except urllib.error.HTTPError as exc:
                message = exc.read().decode("utf-8", errors="replace")
                raise MCPError(f"HTTP {exc.code}: {message}") from exc
            except urllib.error.URLError as exc:
                last_error = exc
                continue

        if raw is None:
            raise MCPError(
                f"Failed to reach Monolith. Tried: {', '.join(attempt_urls)}; last error: {last_error}"
            ) from last_error

        if "error" in raw:
            raise MCPError(raw["error"].get("message", json.dumps(raw["error"], ensure_ascii=False)))

        result = raw.get("result", {})
        if result.get("isError"):
            content = result.get("content") or []
            message = content[0].get("text") if content else json.dumps(result, ensure_ascii=False)
            raise MCPError(message)

        content = result.get("content") or []
        if not content:
            return {}

        text = content[0].get("text", "")
        if not text:
            return {}

        try:
            return json.loads(text)
        except json.JSONDecodeError:
            return {"raw_text": text}


def ensure_call(client: MCPClient, tool_name: str, action: str, params: dict, ok_errors: tuple[str, ...] = ()):
    try:
        return client.call(tool_name, action, params)
    except MCPError as exc:
        message = str(exc)
        if any(marker in message for marker in ok_errors):
            return {"skipped": True, "message": message}
        raise
