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
# the cumulative session total. in: is a gauge (tokens currently in context);
# out: is a counter (tokens generated all session) — different clocks, by design.
#   uncached input = fresh + reads + writes           (every token at 1x)
#   cached input   = fresh + reads*0.1 + writes*mult
#   saved%         = (uncached - cached) / uncached
# saved% can go slightly negative on an early write-heavy turn — that's the
# up-front cost of building the cache before reads pay it back.
IFS=$'\t' read -r pct reads writes hit saved model five_h seven_d cwd in_tok transcript <<EOF
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
  | ($c.context_window_size // 0) as $real_max
  | (if $real_max > 0 then $real_max
     elif ((.model.id // "") | test("^claude-(fable-5|opus-[45]|sonnet-[45])")) then 1000000
     else 200000 end) as $max
  | (($c.used_percentage // (($fresh + $reads + $writes) * 100 / $max))) as $pct
  | [ ([$pct, 99] | min | round),
      $reads,
      $writes,
      ($hit | round),
      ($saved | round),
      (.model.display_name // .model.id // "unknown"),
      (($rl.five_hour.used_percentage // -1) | round),
      (($rl.seven_day.used_percentage // -1) | round),
      (.workspace.current_dir // "."),
      ($c.total_input_tokens // 0),
      (.transcript_path // "")
    ] | @tsv
')
EOF

# out_tok: cumulative output tokens for the whole session. NOT from
# context_window.total_output_tokens — that field is only the MOST RECENT
# response's output (docs: "output tokens from the most recent response"), so it
# jumps around mid-turn and never accumulates. The transcript replays each
# response 2-3x, so dedupe by message.id before summing.
# ponytail: 8ms on a 900K transcript; if a session ever gets big enough to feel
# it, cache the running total per session_id instead of rescanning.
out_tok=0
[ -f "$transcript" ] && out_tok=$(jq -s '[.[] | select(.message.usage and .message.id)]
    | group_by(.message.id) | map(.[0].message.usage.output_tokens // 0) | add // 0' \
    "$transcript" 2>/dev/null) && [ -n "$out_tok" ] || out_tok=0

fmt_tokens() {  # ponytail: awk does the float math bash can't; bc truncated at
                # scale=1 (24772 -> "24.7k"), %.1f rounds (-> "24.8k").
    awk -v n="${1:-0}" 'BEGIN{ if (n>=1e6) printf "%.1fM", n/1e6;
                               else if (n>=1000) printf "%.1fk", n/1000;
                               else printf "%d", n }'
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

# ctx: percentage and absolute are two views of ONE number (total_input_tokens
# / window size), so the absolute carries no label of its own — a second
# label would imply it differs from the %. out: is separate: a session-
# cumulative counter, not the other half of an in/out pair.
ctx_seg="${dim}ctx:${rst} $(grade "$pct")${pct}%${rst}${mid}$(fmt_tokens "$in_tok")${mid}${dim}out:${rst} $(fmt_tokens "$out_tok")"
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
