#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
CTX_INPUT=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
MAX_CONTEXT=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
TOTAL_IN=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
TOTAL_OUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
CACHE_WRITE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

FILLED=$((PCT * 10 / 100))
EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '▓')$(printf "%${EMPTY}s" | tr ' ' '░')

GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; CYAN='\033[36m'; RESET='\033[0m'
if [ "$PCT" -ge 90 ]; then COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then COLOR="$YELLOW"
else COLOR="$GREEN"; fi

# Format large numbers with k suffix
fmt_k() { local n=$1; if [ "$n" -ge 1000 ]; then printf '%dk' "$((n / 1000))"; else printf '%d' "$n"; fi; }

CTX_INPUT_FMT=$(fmt_k "$CTX_INPUT")
MAX_FMT=$(fmt_k "$MAX_CONTEXT")
TOTAL_IN_FMT=$(fmt_k "$TOTAL_IN")
TOTAL_OUT_FMT=$(fmt_k "$TOTAL_OUT")
CACHE_READ_FMT=$(fmt_k "$CACHE_READ")

DIM='\033[2m'
echo -e "${DIM}model${RESET} $MODEL ${DIM}│${RESET} ${DIM}ctx${RESET} ${COLOR}${BAR}${RESET} ${PCT}% ${DIM}(${CTX_INPUT_FMT}/${MAX_FMT})${RESET} ${DIM}│${RESET} ${DIM}in${RESET} ${TOTAL_IN_FMT} ${DIM}|${RESET} ${DIM}out${RESET} ${TOTAL_OUT_FMT} ${DIM}|${RESET} ${DIM}cache${RESET} ${CACHE_READ_FMT}"
