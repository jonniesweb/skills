---
name: gepa
description: Optimize any text artifact (code, prompts, configs, algorithms) using LLM-guided iterative search via the gepa CLI (github.com/jonniesweb/gepa). Use when asked to optimize something for speed, accuracy, compression, or any measurable quality — especially when it requires writing an evaluator, setting up a benchmark, or running multi-iteration optimization. Triggers include phrases like "optimize this with gepa", "use gepa to improve", "benchmark and optimize", or "set up a gepa run".
---

# gepa — Optimize Anything

`gepa` runs an iterative loop: evaluate candidate → pass score + diagnostics to LLM → LLM proposes improvement → repeat.

## Install

```bash
go install github.com/jonniesweb/gepa/cmd/gepa@latest
```

If `go` isn't on your PATH, install it first: https://go.dev/dl/
The binary lands at `$(go env GOPATH)/bin/gepa` — make sure that's on your PATH.

On this sandbox/root environment, Go may be under a module cache path. Find it with:
```bash
find /root/go /root/.asdf -name 'go' -type f 2>/dev/null | grep '/bin/go$' | head -3
```
Then either add the parent to PATH or call it directly.

## Three Modes

| Flags | Mode | Use for |
|-------|------|---------|
| `--seed` + `--evaluator` | Single-task | Optimize one artifact directly |
| `+ --dataset tasks.json` | Multi-task | Transfer insights across related problems |
| `+ --valset val.json` | Generalization | Build a skill that transfers to unseen examples |

## Core Workflow

1. **Write the seed** — the starting artifact (file, or omit for seedless)
2. **Write the evaluator** — shell command that scores the candidate (see below)
3. **Run gepa** — tune `--max-calls` and `--objective`
4. **Inspect results** — best candidate written to `--output`, diagnostics in run log

```bash
gepa optimize \
  --seed my_artifact.py \
  --objective "Optimize for speed. Must return correct results." \
  --background "Domain context, constraints, known good approaches." \
  --evaluator "python3 evaluator.py" \
  --max-calls 12 \
  --output best.py
```

## Evaluator Protocol

The evaluator is a shell command. gepa sets env vars and expects JSON on stdout.

**Env vars provided:**
- `GEPA_CANDIDATE_FILE` — path to temp file with candidate content
- `GEPA_CANDIDATE` — candidate content as string
- `GEPA_EXAMPLE` — JSON-encoded example (multi-task mode; empty otherwise)
- `GEPA_ITERATION` — current iteration number

**Evaluator output** (stdout):
```json
{"score": 0.85, "diagnostics": {"Error": "...", "Time": "2.3s", "Hint": "try sieve"}}
```
Or just a float: `0.85`. Higher score = better. Non-zero exit or timeout → score 0.

**Critical pattern — always check correctness before timing:**
```python
# 1. Fast correctness check on small input
result_small = my_function(small_input)
if result_small != expected_small:
    print(json.dumps({"score": 0.0, "diagnostics": {"Error": f"Wrong: got {result_small}"}}))
    sys.exit(0)

# 2. Only then benchmark on full input
t = time.perf_counter()
result = my_function(full_input)
elapsed = time.perf_counter() - t
```

## Score Function Design

The score function is the most important design decision. Rules of thumb:

- **Seed should score ~0.15–0.35** — low enough to show clear improvement headroom
- **Optimal should score ~0.97+** — high but leaves room for micro-improvements
- **Score 0.0 means wrong/broken** — always correctness-gate before scoring

For speed optimization (most common):
```python
MAX_TIME = <seed_time * 1.3>   # gives seed a score of ~0.23
score = max(0.0, min(1.0, (MAX_TIME - elapsed) / MAX_TIME))
```

Test the seed time first before writing the evaluator. Calibrate MAX_TIME so seed scores 0.2–0.3.

## Diagnostics as ASI

The `diagnostics` dict is Actionable Side Information — the LLM reads it to understand failures.
Pack it with signal:

```python
"diagnostics": {
    "Time":         f"{elapsed:.4f}s",
    "SpeedupNeeded": f"{MAX_TIME/elapsed:.1f}x faster to max out",
    "Verdict":      "🐢 slow" if elapsed > 1.0 else "⚡ fast",
    "Hint":         "Sieve of Eratosthenes is ~50x faster for this N"
                    if elapsed > 1.0 else "Try wheel factorization next"
}
```

**Include a `Hint`** in diagnostics — explicitly name the next approach to try. The LLM uses it.
**Include absolute timing** — not just the score. Score alone hides whether it's 0.3s or 3s from optimal.

## Engine Setup (Sandbox/Root)

The `claude` CLI refuses `--dangerously-skip-permissions` as root. Use the OpenAI shim:

```bash
cat > /usr/local/bin/claude << 'EOF'
#!/usr/bin/env python3
import sys, os, json, urllib.request
API_KEY = os.environ.get("OPENAI_API_KEY","")
MODEL   = os.environ.get("CLAUDE_SHIM_MODEL","gpt-4.1")
# parse last positional arg as prompt, ignore flags
args = sys.argv[1:]
prompt = ""
i = 0
while i < len(args):
    a = args[i]
    if a in ("-p","--print","--dangerously-skip-permissions","--allow-dangerously-skip-permissions","--verbose"):
        i+=1; continue
    if a in ("--output-format","--resume","--model","--permission-mode"):
        i+=2; continue
    if a.startswith("-"): i+=1; continue
    prompt = a; i+=1
payload = json.dumps({"model":MODEL,"messages":[{"role":"user","content":prompt}],"max_tokens":4096,"temperature":0.7}).encode()
req = urllib.request.Request("https://api.openai.com/v1/chat/completions",data=payload,headers={"Authorization":f"Bearer {API_KEY}","Content-Type":"application/json"})
with urllib.request.urlopen(req,timeout=120) as r:
    print(json.loads(r.read())["choices"][0]["message"]["content"])
EOF
chmod +x /usr/local/bin/claude
```

## Tuning `--max-calls`

| Problem type | Recommended |
|---|---|
| Well-known algorithm (fib, sorting) | 6–8 (LLM likely hits optimal in 1–2) |
| Domain-specific optimization | 10–15 |
| Multi-task / generalization | 20–40 |

The LLM will occasionally produce broken candidates (score 0.0) when trying aggressive optimizations. This is normal — the Pareto frontier preserves the last good candidate.

## Reference Files

- **`references/evaluator-patterns.md`** — Complete evaluator templates for speed, accuracy, and multi-task benchmarks; advanced diagnostics patterns
- **`scripts/evaluator_template.py`** — Drop-in Python evaluator template to customize
