#!/usr/bin/env python3
"""Validate a Timeline Historian JSON/JSONL evidence bundle."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


REQUIRED_FILES = {
    "asset-ledger.jsonl",
    "search-ledger.jsonl",
    "claim-ledger.jsonl",
    "claim-treatment-ledger.jsonl",
    "window-summary.json",
    "narrative-review.json",
}
TREATMENTS = {
    "supports",
    "qualifies",
    "contradicts",
    "supersedes",
    "distinguishes",
    "duplicates",
    "needs-review",
    "not-evaluated",
}


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows = []
    with path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            try:
                value = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"{path.name}:{line_number}: invalid JSON: {exc}") from exc
            if not isinstance(value, dict):
                raise ValueError(f"{path.name}:{line_number}: row must be an object")
            rows.append(value)
    return rows


def require(row: dict[str, Any], field: str, errors: list[str], label: str) -> None:
    if row.get(field) in (None, "", []):
        errors.append(f"{label}: missing {field}")


def validate_assets(rows: list[dict[str, Any]], errors: list[str]) -> set[str]:
    ids = set()
    for index, row in enumerate(rows, 1):
        label = f"asset row {index}"
        require(row, "asset_id", errors, label)
        require(row, "content_sha256", errors, label)
        if row.get("asset_id"):
            ids.add(str(row["asset_id"]))
        if row.get("content_sha256") and len(str(row["content_sha256"])) != 64:
            errors.append(f"{label}: content_sha256 must be 64 hex characters")
        if not row.get("source_uri") and not row.get("source_paths") and not row.get("target_path"):
            errors.append(f"{label}: needs source_uri, source_paths, or target_path")
    return ids


def validate_searches(rows: list[dict[str, Any]], asset_ids: set[str], errors: list[str]) -> None:
    for index, row in enumerate(rows, 1):
        label = f"search row {index}"
        require(row, "search_id", errors, label)
        require(row, "backend", errors, label)
        require(row, "query", errors, label)
        results = row.get("results")
        if not isinstance(results, list):
            errors.append(f"{label}: results must be an array")
            continue
        for result_index, result in enumerate(results, 1):
            asset_id = result.get("asset_id") if isinstance(result, dict) else None
            if asset_id and asset_id not in asset_ids:
                errors.append(f"{label} result {result_index}: unknown asset_id {asset_id}")


def validate_claims(rows: list[dict[str, Any]], asset_ids: set[str], errors: list[str]) -> set[str]:
    claim_ids = set()
    for index, row in enumerate(rows, 1):
        label = f"claim row {index}"
        require(row, "claim_id", errors, label)
        require(row, "assertion", errors, label)
        require(row, "status", errors, label)
        if row.get("claim_id"):
            claim_ids.add(str(row["claim_id"]))
        anchors = row.get("source_anchors")
        if not isinstance(anchors, list) or not anchors:
            errors.append(f"{label}: source_anchors must be a non-empty array")
            continue
        for anchor_index, anchor in enumerate(anchors, 1):
            asset_id = anchor.get("asset_id") if isinstance(anchor, dict) else None
            if not asset_id:
                errors.append(f"{label} anchor {anchor_index}: missing asset_id")
            elif asset_id not in asset_ids:
                errors.append(f"{label} anchor {anchor_index}: unknown asset_id {asset_id}")
    return claim_ids


def validate_treatments(rows: list[dict[str, Any]], claim_ids: set[str], errors: list[str]) -> None:
    for index, row in enumerate(rows, 1):
        label = f"treatment row {index}"
        require(row, "treatment_id", errors, label)
        require(row, "claim_id", errors, label)
        require(row, "treatment", errors, label)
        if row.get("claim_id") and row["claim_id"] not in claim_ids:
            errors.append(f"{label}: unknown claim_id {row['claim_id']}")
        if row.get("treatment") and row["treatment"] not in TREATMENTS:
            errors.append(f"{label}: unsupported treatment {row['treatment']}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", type=Path)
    args = parser.parse_args()

    errors: list[str] = []
    if not args.bundle.is_dir():
        print(f"error: bundle directory not found: {args.bundle}", file=sys.stderr)
        return 2

    present = {path.name for path in args.bundle.iterdir() if path.is_file()}
    missing = sorted(REQUIRED_FILES - present)
    for name in missing:
        errors.append(f"missing required file: {name}")

    try:
        assets = read_jsonl(args.bundle / "asset-ledger.jsonl") if "asset-ledger.jsonl" in present else []
        searches = read_jsonl(args.bundle / "search-ledger.jsonl") if "search-ledger.jsonl" in present else []
        claims = read_jsonl(args.bundle / "claim-ledger.jsonl") if "claim-ledger.jsonl" in present else []
        treatments = (
            read_jsonl(args.bundle / "claim-treatment-ledger.jsonl")
            if "claim-treatment-ledger.jsonl" in present
            else []
        )
        window = json.loads((args.bundle / "window-summary.json").read_text(encoding="utf-8")) if "window-summary.json" in present else {}
        review = json.loads((args.bundle / "narrative-review.json").read_text(encoding="utf-8")) if "narrative-review.json" in present else {}
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    asset_ids = validate_assets(assets, errors)
    validate_searches(searches, asset_ids, errors)
    claim_ids = validate_claims(claims, asset_ids, errors)
    validate_treatments(treatments, claim_ids, errors)

    if not isinstance(window, dict) or not window.get("window"):
        errors.append("window-summary.json: missing window object")
    if not isinstance(review, dict) or not review.get("verdict"):
        errors.append("narrative-review.json: missing verdict")

    payload = {
        "bundle": str(args.bundle),
        "valid": not errors,
        "asset_count": len(assets),
        "search_count": len(searches),
        "claim_count": len(claims),
        "treatment_count": len(treatments),
        "errors": errors,
    }
    print(json.dumps(payload, indent=2, sort_keys=True))
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
