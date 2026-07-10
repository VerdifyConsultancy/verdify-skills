#!/usr/bin/env python3
"""Generate deterministic timeline historian windows as JSON."""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone


def window_id(label: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", label.lower()).strip("-")
    return slug or "window"


def build_windows(start_year: int, end_year: int, span_years: int, overlap_years: int) -> list[dict]:
    if end_year < start_year:
        raise ValueError("--end-year must be greater than or equal to --start-year")
    if span_years <= 0:
        raise ValueError("--span-years must be positive")
    if overlap_years < 0:
        raise ValueError("--overlap-years cannot be negative")
    if overlap_years >= span_years:
        raise ValueError("--overlap-years must be smaller than --span-years")

    windows = []
    step = span_years - overlap_years
    current = start_year
    while current <= end_year:
        window_end = min(current + span_years - 1, end_year)
        label = str(current) if current == window_end else f"{current}-{window_end}"
        windows.append(
            {
                "window_id": window_id(label),
                "label": label,
                "start_year": current,
                "end_year": window_end,
                "parent_window_id": None,
                "source_count": 0,
                "claim_count": 0,
                "coverage_notes": [],
                "open_questions": [],
                "ready_for_rollup": False,
            }
        )
        current += step
    return windows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--start-year", type=int, required=True)
    parser.add_argument("--end-year", type=int, required=True)
    parser.add_argument("--granularity", choices=["year", "decade", "fixed"], default="decade")
    parser.add_argument("--span-years", type=int, help="Required when --granularity fixed")
    parser.add_argument("--overlap-years", type=int, default=0)
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    span_years = {"year": 1, "decade": 10}.get(args.granularity, args.span_years)
    if span_years is None:
        parser.error("--span-years is required when --granularity fixed")

    try:
        windows = build_windows(args.start_year, args.end_year, span_years, args.overlap_years)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    payload = {
        "schema": "timeline-historian.windows.v1",
        "generated_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        "parameters": {
            "start_year": args.start_year,
            "end_year": args.end_year,
            "granularity": args.granularity,
            "span_years": span_years,
            "overlap_years": args.overlap_years,
        },
        "windows": windows,
    }
    print(json.dumps(payload, indent=2 if args.pretty else None, sort_keys=args.pretty))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
