#!/usr/bin/env python3
"""
gepa speed-benchmark evaluator template.

Steps to customize:
  1. Replace FUNCTION_NAME with your function (must be defined in candidate code)
  2. Set SMALL_INPUT / EXPECTED_SMALL for the fast correctness check
  3. Set FULL_N / EXPECTED_COUNT for the benchmark
  4. Set MAX_TIME = seed_time * 1.3  (run seed manually first to calibrate)
  5. Update the Hint messages with algorithm-specific advice

Usage:
  gepa optimize --seed seed.py --evaluator "python3 evaluator_template.py" ...
"""

import json, os, sys, subprocess, tempfile

CANDIDATE_FILE = os.environ.get("GEPA_CANDIDATE_FILE", "")

# ── CONFIGURE THESE ─────────────────────────────────────
FUNCTION_NAME   = "my_function"    # function name in candidate
SMALL_INPUT     = 10               # fast correctness check input
EXPECTED_SMALL  = 42               # expected result for small input
FULL_N          = 100_000          # benchmark input
EXPECTED_RESULT = None             # set to expected result, or None to skip exact check
EXPECTED_COUNT  = None             # alternative: check len() of result
MAX_TIME        = 3.0              # calibrate so seed scores 0.15–0.35
TIMEOUT         = 25               # evaluator timeout (seconds)
# ─────────────────────────────────────────────────────────

if not CANDIDATE_FILE:
    print(json.dumps({"score": 0.0, "diagnostics": {"Error": "GEPA_CANDIDATE_FILE not set"}}))
    sys.exit(0)

with open(CANDIDATE_FILE) as f:
    candidate_code = f.read()

test_code = f'''
{candidate_code}

import time, json, sys

# ── Correctness check (small, fast) ───────────────────────────────────────────
try:
    got_small = {FUNCTION_NAME}({repr(SMALL_INPUT)})
    if got_small != {repr(EXPECTED_SMALL)}:
        print(json.dumps({{"score": 0.0, "diagnostics": {{"Error": f"Wrong on small input {{repr({SMALL_INPUT})!r}}}: got {{repr(got_small)[:80]}}, expected {{repr({repr(EXPECTED_SMALL)})[:80]}}"}}}}))
        sys.exit(0)
except Exception as e:
    print(json.dumps({{"score": 0.0, "diagnostics": {{"Error": f"small-input raised {{type(e).__name__}}: {{e}}"}}}}))
    sys.exit(0)

# ── Full benchmark ─────────────────────────────────────────────────────────────
try:
    t = time.perf_counter()
    result = {FUNCTION_NAME}({FULL_N})
    elapsed = time.perf_counter() - t
except Exception as e:
    print(json.dumps({{"score": 0.0, "diagnostics": {{"Error": f"full-input raised {{type(e).__name__}}: {{e}}"}}}}))
    sys.exit(0)

# ── Correctness check (full result) ──────────────────────────────────────────
expected_result = {repr(EXPECTED_RESULT)}
expected_count  = {repr(EXPECTED_COUNT)}

if expected_count is not None and len(result) != expected_count:
    print(json.dumps({{"score": 0.0, "diagnostics": {{"Error": f"count={{len(result)}} expected {{expected_count}}"}}}}))
    sys.exit(0)

if expected_result is not None and result != expected_result:
    print(json.dumps({{"score": 0.0, "diagnostics": {{"Error": f"result mismatch"}}}}))
    sys.exit(0)

# ── Score + diagnostics ───────────────────────────────────────────────────────
MAX_TIME = {MAX_TIME}
score = max(0.0, min(1.0, (MAX_TIME - elapsed) / MAX_TIME))
speedup_needed = MAX_TIME / max(elapsed, 1e-9)

hint = (
    "Try a fundamentally different algorithm (e.g., O(n log n) or better)"
    if elapsed > 1.5 else
    "Try constant-factor optimizations: bytearray, local vars, fewer allocations"
    if elapsed > 0.3 else
    "Near-optimal — try bit manipulation or profiling for hot paths"
)

verdict = (
    "🚀 blazing fast!" if elapsed < 0.05 else
    "⚡ fast"          if elapsed < 0.3  else
    "😐 decent"        if elapsed < 1.0  else
    "🐢 slow"
)

print(json.dumps({{
    "score": round(score, 6),
    "diagnostics": {{
        "Time":          f"{{elapsed:.4f}}s for {FUNCTION_NAME}({FULL_N})",
        "SpeedupNeeded": f"{{speedup_needed:.1f}}x faster to max out score",
        "Verdict":       verdict,
        "Hint":          hint,
    }}
}}))
'''

with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
    f.write(test_code)
    tmpname = f.name

try:
    proc = subprocess.run(['python3', tmpname], capture_output=True, text=True, timeout=TIMEOUT)
    out = proc.stdout.strip()
    err = proc.stderr.strip()
    if out:
        print(out)
    elif err:
        print(json.dumps({"score": 0.0, "diagnostics": {"Error": err[:600]}}))
    else:
        print(json.dumps({"score": 0.0, "diagnostics": {"Error": "No output from candidate"}}))
except subprocess.TimeoutExpired:
    print(json.dumps({"score": 0.0, "diagnostics": {"Error": f"Timeout after {TIMEOUT}s — too slow"}}))
except Exception as e:
    print(json.dumps({"score": 0.0, "diagnostics": {"Error": str(e)}}))
finally:
    try:
        os.unlink(tmpname)
    except Exception:
        pass
