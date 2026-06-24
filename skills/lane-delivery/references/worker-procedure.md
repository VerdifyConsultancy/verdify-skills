# Worker procedure

1. Orient to contract and baseline.
2. Identify the smallest implementation sequence that keeps tests runnable.
3. Add or update contract-facing tests before or with behavior changes.
4. Implement without changing unrelated formatting or dependencies.
5. Keep worker credentials isolated to the approved allowlisted environment; do
   not inherit or request production credentials.
6. Run targeted validation, then the required lane suite.
7. Review the full diff for scope, security, error handling, migrations, and generated files.
8. Push, update the PR, and complete closeout.

Do not claim evidence you did not observe. Record skipped tests and why; skipped required tests normally block closeout.
