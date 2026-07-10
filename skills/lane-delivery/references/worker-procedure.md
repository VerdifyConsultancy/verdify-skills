# Worker procedure

1. Orient to contract and baseline. Verify the first post-baseline commit is the
   approved dispatch-only commit and that its plan, wave, and contract bytes
   have not changed.
2. Identify the smallest implementation sequence that keeps tests runnable.
3. Add or update contract-facing tests before or with behavior changes.
4. Implement without changing unrelated formatting or dependencies.
5. Keep worker credentials isolated to the approved allowlisted environment; do
   not inherit or request production credentials.
6. Run targeted validation, then the required lane suite.
7. Review the full diff for scope, security, error handling, migrations, and generated files.
8. Push, update the PR, and complete closeout.

Never combine the dispatch transaction with implementation. If the approved
SprintPlan, wave release plan, or lane contract is wrong, stop and replan; a
worker may not repair its own authority inputs.

Do not claim evidence you did not observe. Record skipped tests and why; skipped required tests normally block closeout.
