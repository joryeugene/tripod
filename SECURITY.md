# Security policy

## Supported versions

Tripod supports the current `main` branch.

## Report a vulnerability

Please use [GitHub's private vulnerability reporting](https://github.com/joryeugene/tripod/security/advisories/new) so the report stays private while it is investigated. Do not open a public issue for a suspected vulnerability.

Include the affected version or commit, reproduction steps, expected impact, and any mitigation you have already tested. Please omit real credentials and sensitive personal data.

## Local checks

The native staged secret scan is opt-in:

```text
mise install
git config core.hooksPath .githooks
```
