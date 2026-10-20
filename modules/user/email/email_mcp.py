#!/usr/bin/env python3
"""Minimal MCP stdio server exposing send_email over SMTP."""

import json
import os
import smtplib
import sys
from email.message import EmailMessage
from email.utils import parseaddr

CONFIG_PATH = os.environ.get(
    "EMAIL_MCP_CONFIG", os.path.expanduser("~/.config/email-mcp/config.json")
)
SERVER_VERSION = "0.1.0"
SUPPORTED_VERSIONS = {"2024-11-05", "2025-03-26", "2025-06-18"}

TOOLS = [
    {
        "name": "send_email",
        "description": (
            "Send a plain-text email through the configured SMTP account. "
            "Use only when the user asked to send, reply, or notify someone by email."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "to": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Recipient email addresses.",
                },
                "subject": {"type": "string"},
                "body": {"type": "string", "description": "Plain-text body."},
                "cc": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Optional CC recipients.",
                },
                "bcc": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Optional BCC recipients.",
                },
            },
            "required": ["to", "subject", "body"],
            "additionalProperties": False,
        },
    }
]


def _clean_address(value):
    if not isinstance(value, str) or "\r" in value or "\n" in value:
        raise ValueError(f"invalid email address: {value!r}")
    _, addr = parseaddr(value.strip())
    if "@" not in addr or addr.startswith("@") or addr.endswith("@"):
        raise ValueError(f"invalid email address: {value!r}")
    return value.strip()


def _addresses(value, field):
    if isinstance(value, str):
        value = [value]
    if not isinstance(value, list) or not value:
        raise ValueError(f"{field} must be a non-empty list of addresses")
    return [_clean_address(item) for item in value]


def _header(value, field):
    if not isinstance(value, str) or "\r" in value or "\n" in value:
        raise ValueError(f"{field} must be a single line")
    return value


def _load_config():
    with open(CONFIG_PATH, encoding="utf-8") as handle:
        config = json.load(handle)
    with open(config["password_file"], encoding="utf-8") as handle:
        config["password"] = handle.read().rstrip("\r\n")
    return config


def _send(args, config):
    to = _addresses(args.get("to"), "to")
    cc = _addresses(args.get("cc"), "cc") if args.get("cc") else []
    bcc = _addresses(args.get("bcc"), "bcc") if args.get("bcc") else []
    subject = _header(args.get("subject"), "subject")
    body = args.get("body")
    if not isinstance(body, str):
        raise ValueError("body must be a string")

    message = EmailMessage()
    message["From"] = _header(config["from"], "from")
    message["To"] = ", ".join(to)
    if cc:
        message["Cc"] = ", ".join(cc)
    if bcc:
        message["Bcc"] = ", ".join(bcc)
    message["Subject"] = subject
    message.set_content(body)

    security = config.get("security", "ssl")
    client = smtplib.SMTP_SSL if security == "ssl" else smtplib.SMTP
    with client(config["host"], config["port"], timeout=30) as smtp:
        if security == "starttls":
            smtp.starttls()
        smtp.login(config["username"], config["password"])
        smtp.send_message(message)

    recipients = to + cc + bcc
    return f"Email sent to {', '.join(recipients)}"


def _tool_call(params):
    if params.get("name") != "send_email":
        raise ValueError(f"unknown tool: {params.get('name')!r}")
    arguments = params.get("arguments") or {}
    try:
        text = _send(arguments, _load_config())
    except Exception as error:
        return {"content": [{"type": "text", "text": f"{type(error).__name__}: {error}"}], "isError": True}
    return {"content": [{"type": "text", "text": text}]}


def _handle(request):
    method = request.get("method")
    params = request.get("params") or {}
    if method == "initialize":
        requested = params.get("protocolVersion")
        version = requested if requested in SUPPORTED_VERSIONS else "2025-06-18"
        return {
            "protocolVersion": version,
            "capabilities": {"tools": {}},
            "serverInfo": {"name": "email-mcp", "version": SERVER_VERSION},
        }
    if method == "ping":
        return {}
    if method == "tools/list":
        return {"tools": TOOLS}
    if method == "tools/call":
        return _tool_call(params)
    raise LookupError(f"method not found: {method}")


def _write(payload):
    sys.stdout.write(json.dumps(payload, separators=(",", ":")) + "\n")
    sys.stdout.flush()


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            request = json.loads(line)
        except json.JSONDecodeError as error:
            _write({"jsonrpc": "2.0", "id": None, "error": {"code": -32700, "message": str(error)}})
            continue
        if "id" not in request:
            continue
        try:
            result = _handle(request)
        except LookupError as error:
            _write({"jsonrpc": "2.0", "id": request["id"], "error": {"code": -32601, "message": str(error)}})
        except Exception as error:
            _write({"jsonrpc": "2.0", "id": request["id"], "error": {"code": -32603, "message": str(error)}})
        else:
            _write({"jsonrpc": "2.0", "id": request["id"], "result": result})


def _self_test():
    assert _addresses("a@b.c", "to") == ["a@b.c"]
    for bad in ["", "nope", "a@b.c\nBcc: x@y.z", "a@b.c, d@e.f"]:
        try:
            _clean_address(bad)
        except ValueError:
            pass
        else:
            raise AssertionError(f"accepted invalid address: {bad!r}")
    assert any(tool["name"] == "send_email" for tool in TOOLS)
    assert _handle({"method": "tools/list"})["tools"] == TOOLS
    assert _handle({"method": "initialize", "params": {}})["protocolVersion"] == "2025-06-18"
    print("self-test ok")


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        _self_test()
    else:
        main()
