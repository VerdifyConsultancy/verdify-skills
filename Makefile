.PHONY: validate test links package verify-package

validate:
	ruby scripts/setup-agent-hosts.rb --check
	ruby scripts/validate-repo.rb

test: validate
	ruby tests/test_schema_validator.rb
	bash tests/test_cli.sh
	bash tests/test_pr_policy.sh
	bash tests/test_release_preflight.sh
	bash tests/test_npm_install.sh

links:
	ruby scripts/setup-agent-hosts.rb

package: test
	bash scripts/package.sh

verify-package:
	bash scripts/verify-package.sh "$${ARCHIVE:?set ARCHIVE=/path/to/package.zip}"
