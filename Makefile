.PHONY: validate test links package release-candidate verify-package manifest manifest-check

validate:
	ruby scripts/setup-agent-hosts.rb --check
	ruby scripts/validate-repo.rb

test: validate manifest-check
	bash tests/test_package_file_set.sh
	ruby tests/test_schema_validator.rb
	bash tests/test_cli.sh
	ruby tests/test_lane_review_validator.rb
	ruby tests/test_sprint_terminal_receipt.rb
	bash tests/test_pr_policy.sh
	bash tests/test_delivery_gate.sh
	bash tests/test_github_delivery_controls.sh
	bash tests/test_release_preflight.sh
	bash tests/test_release_transaction.sh
	bash tests/test_packed_artifact.sh

# Regenerate the committed integrity manifest (run after changing any tracked file). #109
manifest:
	bash scripts/gen-manifest.sh

# Fail if the committed MANIFEST.sha256 has drifted from a fresh regeneration (CI gate). #109
manifest-check:
	@tmp="$$(mktemp)"; bash scripts/gen-manifest.sh "$(CURDIR)" "$$tmp"; \
	  if ! diff -u MANIFEST.sha256 "$$tmp" >/dev/null 2>&1; then \
	    echo "MANIFEST.sha256 is stale — run 'make manifest' and commit the result (see #109):" >&2; \
	    diff -u MANIFEST.sha256 "$$tmp" | head -40 >&2 || true; \
	    rm -f "$$tmp"; exit 1; \
	  fi; \
	  rm -f "$$tmp"; echo "MANIFEST.sha256 OK ($$(wc -l < MANIFEST.sha256 | tr -d ' ') entries verified against the tree)"

links:
	ruby scripts/setup-agent-hosts.rb

package: test
	bash scripts/package.sh

release-candidate: test
	bash scripts/build-release-candidate.sh

verify-package:
	bash scripts/verify-package.sh "$${ARCHIVE:?set ARCHIVE=/path/to/package.zip}"
