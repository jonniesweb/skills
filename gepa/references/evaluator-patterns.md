# Evaluator Patterns

## Pattern 1: Speed Benchmark (most common)

Full working template for optimizing a Python function for speed.

```python
#!/usr/bin/env python3
import json, os, sys, subprocess, tempfile, time

CANDIDATE_FILE = os.environ.get("GEPA_CANDIDATE_FILE", "")
N = 500_000           # <-- tune this
EXPECTED_COUNT = 41538  # <-- compute offline
MAX_TIME = 3.0        # <-- calibrate so seed scores 0.15-0.35

if not CANDIDATE_FILE:
    print(json.dumps({"score": 0.0, "diagnostics": {"Error": "GEPA_CANDIDATE_FILE not set"}}))
    sys.exit(0)

with open(CANDIDATE_FILE) as f:
    candidate_code = f.read()

test_code = f'''
{candidate_code}

import time, json, sys

# 1. Fast correctness check (small input, runs even on slow implementations)
small = my_function(small_input)
if small != expected_small:
    print(json.dumps({{"score": 0.0, "diagnostics": {{"Error": f"Wrong on small input: {{small}}"}}}}))
    sys.exit(0)

# 2. Full benchmark
t = time.perf_counter()
result = my_function({N})
elapsed = time.perf_counter() - t

# 3. Full correctness check
if len(result) != {EXPECTED_COUNT}:
    print(json.dumps({{"score": 0.0, "diagnostics": {{"Error": f"count={{len(result)}} expected {EXPECTED_COUNT}"}}}}))
    sys.exit(0)

score = max(0.0, min(1.0, ({MAX_TIME} - elapsed) / {MAX_TIME}))
print(json.dumps({{
    "score": score,
    "diagnostics": {{
        "Time":          f"{{elapsed:.4f}}s",
        "SpeedupNeeded": f"{{({MAX_TIME} / max(elapsed,1e-9)):.1f}}x to max score",
        "Verdict":       "🚀 fast" if elapsed < 0.1 else "🐢 slow",
        "Hint":          "Try algorithm X for big gains" if elapsed > 1.0 else "Micro-optimizations remain"
    }}
}}))
'''

with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
    f.write(test_code)
    tmpname = f.name

try:
    r = subprocess.run(['python3', tmpname], capture_output=True, text=True, timeout=25)
    print(r.stdout.strip() if r.stdout.strip() else
          json.dumps({"score": 0.0, "diagnostics": {"Error": r.stderr[:600]}}))
except subprocess.TimeoutExpired:
    print(json.dumps({"score": 0.0, "diagnostics": {"Error": "Timeout (25s)"}}))
finally:
    os.unlink(tmpname)
```

**How to calibrate MAX_TIME:**
1. Benchmark the seed: `time python3 -c "import seed; seed.fn(N)"`
2. Set `MAX_TIME = seed_time * 1.3`
3. Check: seed score = `(MAX_TIME - seed_time) / MAX_TIME` → should be 0.15–0.35

---

## Pattern 2: Accuracy Benchmark (multi-task mode)

For prompt optimization, ML model tuning, or any accuracy-scored task.

```python
#!/usr/bin/env python3
import json, os, sys

CANDIDATE_FILE = os.environ.get("GEPA_CANDIDATE_FILE", "")
EXAMPLE        = json.loads(os.environ.get("GEPA_EXAMPLE", "{}"))

# EXAMPLE structure: {"input": "...", "expected": "..."}

with open(CANDIDATE_FILE) as f:
    prompt_template = f.read().strip()

# Fill prompt with example
prompt = prompt_template.replace("{INPUT}", EXAMPLE.get("input", ""))
expected = EXAMPLE.get("expected", "")

# Call LLM or run function
response = call_my_system(prompt)
score = 1.0 if response.strip() == expected.strip() else 0.0

# Partial credit: Levenshtein or keyword overlap
# score = similarity(response, expected)

print(json.dumps({
    "score": score,
    "diagnostics": {
        "Input":    EXAMPLE.get("input", "")[:100],
        "Expected": expected[:100],
        "Got":      response[:100],
        "Match":    "✓" if score == 1.0 else "✗"
    }
}))
```

Dataset format (`train.json`):
```json
[
  {"id": "q1", "input": "What is 2+2?", "expected": "4"},
  {"id": "q2", "input": "Reverse 'hello'", "expected": "olleh"}
]
```

Run:
```bash
gepa optimize \
  --seed prompt.txt \
  --objective "Improve accuracy on these tasks" \
  --evaluator "python3 evaluator.py" \
  --dataset train.json \
  --valset val.json \
  --max-calls 30
```

---

## Pattern 3: Compression / Quality Ratio

For optimizing compression, code golf, output quality metrics.

```python
import json, os, zlib

CANDIDATE_FILE = os.environ.get("GEPA_CANDIDATE_FILE", "")

# Candidate is a compressor function: compress(data: bytes) -> bytes
with open(CANDIDATE_FILE) as f:
    candidate_code = f.read()

# ... run candidate ...
original_size = len(test_data)
compressed_size = len(run_candidate(test_data))
ratio = original_size / compressed_size  # higher = better

# Baseline: zlib level 1 ratio = ~2.0, level 9 = ~3.5
MAX_RATIO = 5.0
score = min(1.0, ratio / MAX_RATIO)

print(json.dumps({
    "score": score,
    "diagnostics": {
        "OriginalSize":    f"{original_size:,} bytes",
        "CompressedSize":  f"{compressed_size:,} bytes",
        "Ratio":           f"{ratio:.2f}x",
        "Hint": "LZ4, Zstd, or custom dictionary coding may improve ratio"
    }
}))
```

---

## Pattern 4: Seedless Mode

When you don't have a starting artifact — describe what you want, gepa generates the first version.

```bash
gepa optimize \
  --objective "Write a Python function solve(board) that solves a 9x9 Sudoku puzzle. Returns solved board or None." \
  --background "board is a list of 81 ints, 0 = empty. Known approaches: backtracking, constraint propagation, dancing links." \
  --evaluator "python3 evaluator.py" \
  --max-calls 15 \
  --output solver.py
```

---

## Advanced Diagnostics Tips

### Dynamic hints based on score
```python
if elapsed > 2.0:
    hint = "Still in O(n²) territory — try a fundamentally different algorithm"
elif elapsed > 0.5:
    hint = "Good progress — profile for hotspots, consider C-ext or bit tricks"
elif elapsed > 0.1:
    hint = "Nearly there — try bytearray/memoryview instead of list"
else:
    hint = "Excellent — try to reduce constant factors further"
```

### Catch subtle wrong-but-fast implementations
```python
# LLMs sometimes return hardcoded answers or truncated results when they know the expected value
assert result[0] == 2             # first prime is always 2
assert all(result[i] < result[i+1] for i in range(min(10, len(result)-1)))  # strictly ascending
assert result[-1] <= N            # no primes beyond N
# For sorting: verify a few random positions against a reference sort
import random
sample_idxs = random.sample(range(len(result)), min(20, len(result)))
ref = sorted(original_arr)
assert all(result[i] == ref[i] for i in sample_idxs)
```

### Multi-run timing for noisy environments
```python
# Warm up + multiple runs to reduce noise
_ = my_function(small_n)  # warm up JIT / caches
times = []
for _ in range(3):
    t = time.perf_counter()
    my_function(N)
    times.append(time.perf_counter() - t)
elapsed = min(times)  # use best-of-3
```

---

## Evaluator Checklist

Before running gepa, verify your evaluator:

- [ ] Returns valid JSON on stdout
- [ ] Exits 0 in all cases (errors go in `diagnostics.Error`, not stderr)
- [ ] Has a correctness check on small input that runs in <1s even for slow candidates
- [ ] `MAX_TIME` calibrated so seed scores 0.15–0.35
- [ ] `diagnostics` includes a `Hint` field pointing the LLM toward the right algorithm
- [ ] `diagnostics` includes absolute timing (not just score)
- [ ] Handles timeouts (subprocess.run with timeout=)
- [ ] Cleans up temp files

## Common Pitfalls

| Symptom | Cause | Fix |
|---------|-------|-----|
| Seed scores too high (>0.7) | MAX_TIME too generous | Increase N or reduce MAX_TIME |
| Seed scores 0.0 | Timeout or correctness failure | Test seed manually first |
| Score jumps to 1.0 in iteration 1 | Problem too well-known | Use a harder/domain-specific problem |
| Several 0.0 score iterations | LLM trying aggressive optimizations | Normal — Pareto frontier preserves best |
| LLM keeps producing same candidate | Score plateau | Add `Hint` to diagnostics with specific next direction |
| Wrong-but-fast candidate scores high | Missing correctness check | Always correctness-gate before timing |
