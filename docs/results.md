# Reported Results

The following values were copied from the archived AICAS submission summary. They were **not rerun or independently verified** during this repository cleanup.

| Metric | Reported value |
| --- | ---: |
| Accuracy | 13/30 = 0.433333 |
| Prefill throughput | 30.555190 tokens/s |
| Decode throughput | 12.446915 tokens/s |
| Energy efficiency | 2.279619 tokens/J |
| Total measured energy | 449.198 J |
| TTFT linear-fit slope | 2.195 ms/character |
| TTFT linear-fit intercept | 10638.027 ms |
| Local provisional weighted score | 446.240 |

The submission also described a system-level comparison for a 501-token prompt and 1024-token generation: end-to-end latency reduced from 350.7 s to 97.1 s, TTFT improved by 6.06x, and wall energy improved by 3.68x. A separate 120-question OCRBench result was reported as 50/120 versus 55/120 for an FP16 CPU baseline.

These result groups came from different archived evaluation contexts and must not be combined as if they were one controlled experiment. Raw JSON, logs, power traces, competition videos, models, and the evaluation environment are intentionally not included in this source repository. Consequently, the numbers are historical claims rather than a reproducibility guarantee.
