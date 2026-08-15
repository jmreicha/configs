#!/usr/bin/env bash
# ponytail: statusline — context %, tokens, cache read/write split + savings, cost

# Cache-write cost multiplier vs base input price. 1.25 = 5-minute TTL (Claude
# Code default); set 2.0 if you run a 1-hour cache TTL. Reads are always 0.1x.
# ponytail: the only pricing assumption in the savings math — one knob.
write_mult=1.25

data=$(cat)

# One jq pass emits every scalar, tab-separated. Cache savings are computed in
# input-token-equivalents, so the % is rate-independent (no per-model price
# table needed). All cache/token figures are the LAST turn's snapshot; cost is
# the cumulative session total (they are not on the same clock — by design).
#   uncached input = fresh + reads + writes           (every token at 1x)
#   cached input   = fresh + reads*0.1 + writes*mult
#   saved%         = (uncached - cached) / uncached
# saved% can go slightly negative on an early write-heavy turn — that's the
# up-front cost of building the cache before reads pay it back.
IFS=$'\t' read -r pct reads writes hit saved model five_h seven_d cwd <<EOF
$(echo "$data" | jq -r --argjson wm "$write_mult" '
  (.context_window // {}) as $c
  | ($c.current_usage // {}) as $u
  | (.rate_limits // {}) as $rl
  | ($u.input_tokens // 0) as $fresh
  | ($u.cache_read_input_tokens // 0) as $reads
  | ($u.cache_creation_input_tokens // 0) as $writes
  | ($fresh + $reads + $writes) as $tot
  | (if $tot > 0 then $reads * 100 / $tot else 0 end) as $hit
  | (if $tot > 0
       then ($tot - ($fresh + $reads * 0.1 + $writes * $wm)) * 100 / $tot
       else 0 end) as $saved
  | [ (($c.used_percentage // 0) | round),
      $reads,
      $writes,
      ($hit | round),
      ($saved | round),
      (.model.display_name // .model.id // "unknown"),
      (($rl.five_hour.used_percentage // -1) | round),
      (($rl.seven_day.used_percentage // -1) | round),
      (.workspace.current_dir // ".")
    ] | @tsv
')
EOF

fmt_tokens() {
    local n=$1
    if [ "$n" -ge 1000000 ] 2>/dev/null; then
        printf "%.1fM" "$(echo "scale=1; $n / 1000000" | bc)"
    elif [ "$n" -ge 1000 ] 2>/dev/null; then
        printf "%.1fk" "$(echo "scale=1; $n / 1000" | bc)"
    else
        echo "$n"
    fi
}

# ANSI styling — Claude Code renders these. Only the column identifiers
# (model:/ctx:/cache:/cost:/rtk:) are dimmed; sub-words and separators stay at
# normal brightness. Limit numbers (context %, cost budget) are graded
# green/yellow/red so a ceiling being approached stands out at a glance.
dim=$'\033[2m'; rst=$'\033[0m'
grn=$'\033[32m'; ylw=$'\033[33m'; red=$'\033[31m'
sep=" | "
mid=" · "

grade() {  # print the color code for a limit percentage
    if   [ "$1" -ge 90 ] 2>/dev/null; then printf '%s' "$red"
    elif [ "$1" -ge 70 ] 2>/dev/null; then printf '%s' "$ylw"
    else                                    printf '%s' "$grn"; fi
}

ctx_seg="${dim}ctx:${rst} $(grade "$pct")${pct}%${rst}"
cache_seg="${dim}cache:${rst} $(fmt_tokens "$reads")↓ $(fmt_tokens "$writes")↑${mid}${hit}% hit"

# cost = rate-limit budget consumed on a Pro/Max subscription (the real
# constraint). Absent (-1) for pay-per-token API keys and before the first API
# response; the segment is omitted when neither window is set.
cost_seg=""
[ "$five_h" != "-1" ] && cost_seg+="5h $(grade "$five_h")${five_h}%${rst}"
[ "$seven_d" != "-1" ] && cost_seg+="${cost_seg:+$mid}7d $(grade "$seven_d")${seven_d}%${rst}"
[ -n "$cost_seg" ] && cost_seg="${dim}cost:${rst} ${cost_seg}"

# RTK savings — tokens rtk kept OUT of context (not prompt-cache; a separate,
# upstream win). All-time, scoped to this project via the session cwd (rtk
# --project keys off process cwd, so scope it explicitly). Segment drops if rtk
# is absent or has no data. Runs <10ms; skip if that ever changes.
rtk_seg=""
if command -v rtk >/dev/null 2>&1; then
    read -r rtk_saved rtk_pct rtk_sent <<<"$( (cd "${cwd:-.}" 2>/dev/null && rtk gain --project --format json 2>/dev/null) \
        | jq -r '.summary | "\(.total_saved // 0) \((.avg_savings_pct // 0) | round) \(.total_output // 0)"' 2>/dev/null)"
    if [ -n "$rtk_saved" ] && [ "$rtk_saved" -gt 0 ] 2>/dev/null; then
        # saved = tokens rtk stripped; sent = tokens that actually reached context.
        rtk_seg="${dim}rtk:${rst} $(fmt_tokens "$rtk_saved") saved${mid}${rtk_pct}% compressed${mid}$(fmt_tokens "$rtk_sent") sent"
    fi
fi

echo "${dim}model:${rst} ${model}${sep}${ctx_seg}${sep}${cache_seg}${cost_seg:+${sep}${cost_seg}}${rtk_seg:+${sep}${rtk_seg}}"
