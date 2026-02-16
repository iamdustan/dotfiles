#!/usr/bin/env python3
"""
Read preset TOML(s), emit Codex TOML fragment and Gemini JSON fragment.
Usage: preset-to-agent-configs.py <preset1.toml> [preset2.toml ...]
Stdout: JSON with keys "codex_toml", "gemini_mcp_servers", "env_vars", "plan_path"
"""
import json
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # py < 3.11

def load_toml(path):
    with open(path, "rb") as f:
        return tomllib.load(f)

def preset_meta(data):
    return {
        "id": data.get("id", ""),
        "name": data.get("name", ""),
        "description": data.get("description", ""),
    }

def server_to_codex_toml(server_id, s):
    lines = [f"\n[mcp_servers.{server_id}]"]
    if "command" in s:
        lines.append(f'command = "{s["command"]}"')
    if "args" in s:
        args = s["args"]
        if isinstance(args, list):
            args_str = ", ".join(f'"{a}"' for a in args)
        else:
            args_str = f'"{args}"'
        lines.append(f"args = [{args_str}]")
    if "url" in s:
        lines.append(f'url = "{s["url"]}"')
    if "bearer_token_env_var" in s:
        lines.append(f'bearer_token_env_var = "{s["bearer_token_env_var"]}"')
    if "env_var" in s and s["env_var"]:
        lines.append(f'env = {{ "{s["env_var"]}" = "${{{s["env_var"]}}}" }}')
    else:
        lines.append("env = {}")
    lines.append("cwd = \"\"")
    lines.append("startup_timeout_sec = 30")
    lines.append("tool_timeout_sec = 60")
    lines.append("enabled = true")
    return "\n".join(lines)

def server_to_gemini(s):
    out = {}
    if "command" in s:
        out["command"] = s["command"]
    if "args" in s:
        out["args"] = s["args"]
    if "url" in s:
        out["url"] = s["url"]
    if "headers" in s:
        out["headers"] = s["headers"]
    elif "bearer_token_env_var" in s:
        out["headers"] = {"Authorization": f"Bearer ${{{s['bearer_token_env_var']}}}"}
    if "env_var" in s and s["env_var"]:
        out["env"] = {s["env_var"]: f"${{{s['env_var']}}}"}
    return out

def main():
    if len(sys.argv) >= 2 and sys.argv[1] == "--list":
        # Output one JSON object per preset: {id, name, description}
        out = []
        for path in sys.argv[2:]:
            p = Path(path)
            if p.exists():
                data = load_toml(p)
                out.append(preset_meta(data))
        print(json.dumps(out, indent=2))
        return

    codex_parts = []
    gemini_servers = {}
    env_vars = set()
    plan_path = None

    for path in sys.argv[1:]:
        p = Path(path)
        if not p.exists():
            continue
        data = load_toml(p)
        mcp = data.get("mcp_servers") or {}
        for server_id, s in mcp.items():
            if not isinstance(s, dict):
                continue
            codex_parts.append(server_to_codex_toml(server_id, s))
            gemini_servers[server_id] = server_to_gemini(s)
            for key in ("bearer_token_env_var", "env_var"):
                if s.get(key):
                    env_vars.add(s[key])
        if "plan_path" in data:
            plan_path = data["plan_path"]
        if "plan_filename" in data and plan_path:
            plan_path = f"{plan_path.rstrip('/')}/{data['plan_filename']}"

    # Claude: emit "claude mcp add <name> -- <command> [args...]" for stdio servers
    claude_commands = []
    for server_id, s in gemini_servers.items():
        if "command" in s:
            cmd = s["command"]
            args = s.get("args") or []
            args_str = " ".join(str(a) for a in args)
            claude_commands.append(f"claude mcp add {server_id} -- {cmd} {args_str}".strip())
        # HTTP/SSE servers: user adds via Claude UI or we could add URL form

    result = {
        "codex_toml": "\n".join(codex_parts),
        "gemini_mcp_servers": gemini_servers,
        "env_vars": sorted(env_vars),
        "plan_path": plan_path,
        "claude_commands": claude_commands,
    }
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
