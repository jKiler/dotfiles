#!/bin/bash

MCP_FLAGS=""

if [ -f "$(pwd)/go.mod" ]; then
  MCP_FLAGS="--mcp-config $HOME/.claude/mcp.json"
fi

exec claude $MCP_FLAGS "$@"
