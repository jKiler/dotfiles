#!/bin/bash
#
# Claude Code Status Line Script
# Displays: directory path, git branch, model, output style, and token usage
#

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size')

# Get current directory with ~ for home directory
dir_path="${current_dir/#$HOME/~}"

# Get git branch if in a git repo
git_branch=""
if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$current_dir" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        # Check for uncommitted changes
        if ! git -C "$current_dir" --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null; then
            git_branch=" ${branch}*"
        else
            git_branch=" ${branch}"
        fi
    fi
fi

# Calculate total tokens used (conversation only)
total_tokens=$((total_input + total_output))

# Calculate output/input ratio (e.g., 3.2x means Claude generated 3.2x more tokens than user input)
if [ "$total_input" -gt 0 ]; then
    ratio=$(awk "BEGIN {printf \"%.1f\", $total_output / $total_input}")
else
    ratio="0.0"
fi

# Calculate percentage of context window used
# Note: This is based on conversation tokens only (total_input + total_output)
# The actual context usage includes system prompts, tools, and memory files,
# so the real percentage may be higher than shown here
if [ "$context_size" -gt 0 ]; then
    percent=$((total_tokens * 100 / context_size))
else
    percent=0
fi

# Format usage info: "X.Xx / XX% used"
usage_info="${ratio}x / ${percent}% used"

# Build the status line with colors matching user's console prompt
# Using printf with ANSI color codes
# \033[94m = bright blue (directory path)
# \033[32m = standard green (git branch and usage info)
# \033[95m = bright magenta (model)
# \033[93m = bright yellow (output style)
printf "\033[94m%s\033[0m\033[32m%s\033[0m | \033[95m%s\033[0m | \033[93m%s\033[0m | \033[32m%s\033[0m" \
    "$dir_path" \
    "$git_branch" \
    "$model" \
    "$output_style" \
    "$usage_info"
