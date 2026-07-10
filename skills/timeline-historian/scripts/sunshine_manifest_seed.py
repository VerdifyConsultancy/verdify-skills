#!/usr/bin/env python3
"""Create a read-only Timeline Historian seed bundle from the Sunshine manifest."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


TREATMENT_NOT_EVALUATED = "not-evaluated"


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def jsonl_write(path: Path, rows: list[dict[str, Any]]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, sort_keys=True, ensure_ascii=False))
            handle.write("\n")


def read_manifest_rows(
    manifest: Path,
    decade: str | None,
    start_year: int | None,
    end_year: int | None,
    categories: set[str],
    limit: int,
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with manifest.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"manifest JSON parse failed on line {line_number}: {exc}") from exc
            if decade and row.get("target_decade") != decade:
                continue
            if categories and row.get("category") not in categories:
                continue
            selected_year = row.get("selected_year")
            if start_year is not None and (not isinstance(selected_year, int) or selected_year < start_year):
                continue
            if end_year is not None and (not isinstance(selected_year, int) or selected_year > end_year):
                continue
            rows.append(row)
            if len(rows) >= limit:
                break
    return rows


def build_asset_rows(rows: list[dict[str, Any]], generated_at: str, verify_target_paths: bool) -> list[dict[str, Any]]:
    asset_rows = []
    for row in rows:
        content_sha256 = row.get("content_sha256") or ""
        sha12 = content_sha256[:12]
        target_path = row.get("target_path")
        target_exists = None
        if verify_target_paths and target_path:
            target_exists = Path(target_path).exists()
        asset_rows.append(
            {
                "schema": "timeline-historian.asset.v1",
                "generated_at": generated_at,
                "asset_id": f"sha256:{content_sha256}",
                "content_sha256": content_sha256,
                "sha12": sha12,
                "source_uri": row.get("source_object_uri"),
                "object_key": row.get("object_key"),
                "target_path": target_path,
                "target_exists": target_exists,
                "source_paths": row.get("source_paths") or [],
                "collection": "sunshine-vault",
                "category": row.get("category"),
                "date_evidence": row.get("date_evidence") or {},
                "selected_year": row.get("selected_year"),
                "selected_period": row.get("selected_period"),
                "target_decade": row.get("target_decade"),
                "confidence": row.get("confidence"),
                "text_length": row.get("text_length"),
                "page_count": row.get("page_count"),
                "sha256_verified": row.get("sha256_verified"),
                "access": "exported-review-copy" if target_path else "unknown",
                "rights": "unknown",
                "derived_artifacts": [],
            }
        )
    return asset_rows


def build_search_rows(
    rows: list[dict[str, Any]],
    generated_at: str,
    manifest: Path,
    manifest_hash: str,
    args: argparse.Namespace,
) -> list[dict[str, Any]]:
    results = []
    for index, row in enumerate(rows, 1):
        content_sha256 = row.get("content_sha256") or ""
        results.append(
            {
                "rank": index,
                "score": None,
                "asset_id": f"sha256:{content_sha256}",
                "sha12": content_sha256[:12],
                "category": row.get("category"),
                "selected_year": row.get("selected_year"),
                "selected_period": row.get("selected_period"),
                "target_path": row.get("target_path"),
                "snippet": "",
            }
        )
    query = {
        "manifest": str(manifest),
        "decade": args.decade,
        "start_year": args.start_year,
        "end_year": args.end_year,
        "categories": sorted(args.category or []),
        "limit": args.limit,
    }
    return [
        {
            "schema": "timeline-historian.search.v1",
            "generated_at": generated_at,
            "search_id": "search-001-manifest-filter",
            "purpose": "discovery",
            "backend": "sunshine-decade-manifest",
            "query": json.dumps(query, sort_keys=True),
            "filters": query,
            "index_version": f"sha256:{manifest_hash}",
            "searched_at": generated_at,
            "results": results,
        }
    ]


def build_claim_rows(rows: list[dict[str, Any]], generated_at: str) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    claims = []
    treatments = []
    for index, row in enumerate(rows, 1):
        content_sha256 = row.get("content_sha256") or ""
        sha12 = content_sha256[:12]
        claim_id = f"claim-{index:04d}-{sha12}"
        period = row.get("selected_period") or row.get("target_decade") or "unknown period"
        category = row.get("category") or "uncategorized source"
        confidence = row.get("confidence") or "unknown"
        assertion = (
            f"The Sunshine manifest assigns asset {sha12} to {period} as "
            f"{category} with {confidence} confidence."
        )
        claims.append(
            {
                "schema": "timeline-historian.claim.v1",
                "generated_at": generated_at,
                "claim_id": claim_id,
                "window_id": row.get("target_decade") or "sunshine-window",
                "assertion": assertion,
                "time_interval": {
                    "start_year": row.get("selected_year"),
                    "end_year": row.get("selected_year"),
                },
                "claim_type": "manifest-date-category-assignment",
                "source_anchors": [
                    {
                        "asset_id": f"sha256:{content_sha256}",
                        "anchor_type": "manifest-row",
                        "citation": row.get("target_path") or row.get("source_object_uri") or sha12,
                    }
                ],
                "confidence": confidence,
                "status": "draft",
                "created_from": "sunshine_manifest_seed.py",
            }
        )
        treatments.append(
            {
                "schema": "timeline-historian.claim-treatment.v1",
                "generated_at": generated_at,
                "treatment_id": f"treatment-{index:04d}-{sha12}",
                "claim_id": claim_id,
                "treatment": TREATMENT_NOT_EVALUATED,
                "reviewer": "timeline-historian seed",
                "reviewed_at": generated_at,
                "evidence_anchors": [],
                "rationale": "Initial manifest-derived claim before OCR, semantic search, and critical-historian review.",
            }
        )
    return claims, treatments


def write_window_summary(output: Path, rows: list[dict[str, Any]], generated_at: str, args: argparse.Namespace) -> None:
    categories = Counter(row.get("category") or "unknown" for row in rows)
    weak_dates = sum(1 for row in rows if row.get("confidence") == "weak")
    no_text = sum(1 for row in rows if not row.get("text_length"))
    years = [row.get("selected_year") for row in rows if isinstance(row.get("selected_year"), int)]
    label = args.decade or (
        f"{min(years)}-{max(years)}" if years else "sunshine-selection"
    )
    payload = {
        "schema": "timeline-historian.window-summary.v1",
        "generated_at": generated_at,
        "window": {
            "window_id": label,
            "label": label,
            "start_year": min(years) if years else args.start_year,
            "end_year": max(years) if years else args.end_year,
            "parent_window_id": None,
        },
        "source_coverage": {
            "asset_count": len(rows),
            "categories": dict(sorted(categories.items())),
            "weak_date_count": weak_dates,
            "no_text_count": no_text,
        },
        "accepted_claims": [],
        "qualified_claims": [],
        "contradicted_claims": [],
        "narrative": "",
        "open_questions": [
            "Add OCR/page spans for manifest-derived claims.",
            "Run hybrid or semantic search for support and counterevidence.",
            "Review public access rules before publishing source links.",
        ],
        "rollup_ready": False,
    }
    output.joinpath("window-summary.json").write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def write_narrative_review(output: Path, generated_at: str) -> None:
    payload = {
        "schema": "timeline-historian.narrative-review.v1",
        "reviewed_at": generated_at,
        "reviewer": "timeline-historian seed",
        "scope": str(output),
        "verdict": "needs-work",
        "checks": {
            "source_identity": "seeded-from-manifest",
            "source_coverage": "partial",
            "ocr_stability": "not-reviewed",
            "claim_anchors": "manifest-only",
            "claim_treatment": "not-evaluated",
            "public_access": "not-reviewed",
        },
        "findings": [
            "Bundle is a read-only manifest seed, not a finished historical narrative.",
            "Manifest rows need OCR, source-card, and search enrichment before rollup.",
        ],
        "required_actions": [
            "Inspect selected sources and OCR.",
            "Add semantic or hybrid search results.",
            "Update claim-treatment rows before accepting a narrative.",
        ],
    }
    output.joinpath("narrative-review.json").write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--decade", help="Target manifest target_decade, for example 1960s")
    parser.add_argument("--start-year", type=int)
    parser.add_argument("--end-year", type=int)
    parser.add_argument("--category", action="append", default=[])
    parser.add_argument("--limit", type=int, default=25)
    parser.add_argument("--verify-target-paths", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.limit <= 0:
        print("error: --limit must be positive", file=sys.stderr)
        return 2
    if not args.manifest.is_file():
        print(f"error: manifest not found: {args.manifest}", file=sys.stderr)
        return 2

    try:
        rows = read_manifest_rows(
            args.manifest,
            args.decade,
            args.start_year,
            args.end_year,
            set(args.category or []),
            args.limit,
        )
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    if not rows:
        print("error: no manifest rows matched the requested filters", file=sys.stderr)
        return 1

    generated_at = utc_now()
    manifest_hash = sha256_file(args.manifest)
    args.output.mkdir(parents=True, exist_ok=True)

    asset_rows = build_asset_rows(rows, generated_at, args.verify_target_paths)
    search_rows = build_search_rows(rows, generated_at, args.manifest, manifest_hash, args)
    claim_rows, treatment_rows = build_claim_rows(rows, generated_at)

    jsonl_write(args.output / "asset-ledger.jsonl", asset_rows)
    jsonl_write(args.output / "search-ledger.jsonl", search_rows)
    jsonl_write(args.output / "claim-ledger.jsonl", claim_rows)
    jsonl_write(args.output / "claim-treatment-ledger.jsonl", treatment_rows)
    write_window_summary(args.output, rows, generated_at, args)
    write_narrative_review(args.output, generated_at)

    summary = {
        "output": str(args.output),
        "asset_count": len(asset_rows),
        "claim_count": len(claim_rows),
        "manifest_sha256": manifest_hash,
        "next_command": f"python3 skills/timeline-historian/scripts/validate_timeline_bundle.py {args.output}",
    }
    print(json.dumps(summary, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
