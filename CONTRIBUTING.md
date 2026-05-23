# Contributing

Thanks for taking the time to improve T-Sense.

This repository is intentionally scoped as a community open core. Please keep
contributions inside the public local-scanner boundary.

## Public Scope

Good fits for this repository:

- Local scanner reliability and rate-limit handling.
- JSONL metadata, report generation, and profile parsing.
- Privacy, redaction, and local-first safety improvements.
- Public examples that do not expose private source lists or personal data.
- Tests, CI, documentation, and cross-platform script fixes.

Out of scope for this public repository:

- Private dashboards or commercial product UX.
- Telegram source discovery/recommendation systems, auto-join, invites, folders,
  or curated private datasets.
- Hosted services, paid access checks, bundled service credentials, or managed relays.
- Private product strategy, market research, user research, or branded
  experiences.
- Secrets, sessions, generated reports, private profiles, or private channel
  lists.

If a useful change crosses that boundary, keep the public piece small and move
the product-specific part to a private Sapientropic repository.

## License Confirmation

The community version is licensed under `AGPL-3.0-only`, with commercial
licensing available separately from Sapientropic.

By submitting a contribution, you confirm that:

- You have the right to submit it.
- You license it to the project under `AGPL-3.0-only`.
- You also grant Sapientropic the right to use, sublicense, and relicense the
  contribution under separate commercial licenses.
- You did not copy incompatible third-party code, prompts, data, generated
  assets, or documentation into the project.

For larger contributions, maintainers may ask you to include this confirmation
in the pull request:

> I confirm that I have the right to submit this contribution and that I license
> it to T-Sense under AGPL-3.0-only and to Sapientropic for separate
> commercial licensing as described in docs/licensing.md.

## Development Checks

```bash
python -m pip install -r requirements.txt -r requirements-llm.txt -r requirements-dev.txt
python -m ruff check .
python -m pytest -q
```

Keep changes focused. Prefer small, well-tested improvements to broad product
expansion in this public core.
