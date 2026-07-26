#!/usr/bin/env sh
set -eu

SELF_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
export REPO_MAINTENANCE_COMMON_DIR="$SELF_DIR/../lib"
. "$SELF_DIR/../lib/common.sh"

allowlist="$REPO_MAINTENANCE_ROOT/config/public-identities.allowlist"
[ -f "$allowlist" ] || die "Expected $allowlist to declare intentionally public email addresses."

failed="false"

for tracked_path in $(git -C "$REPO_ROOT" ls-files); do
  case "$tracked_path" in
    .env|.env.*|*.pem|*.key|*/id_rsa|*/id_ed25519)
      case "$tracked_path" in
        .env.example)
          ;;
        *)
          warn "PII/secrets check found a tracked secret-bearing filename: $tracked_path"
          failed="true"
          ;;
      esac
      ;;
  esac
done

secret_matches="$(git -C "$REPO_ROOT" grep -I -n -E 'AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|sk_(live|test)_[A-Za-z0-9]+|-----BEGIN [A-Z ]*PRIVATE KEY-----' || true)"
if [ -n "$secret_matches" ]; then
  warn "PII/secrets check found credential-like content in tracked text:"
  printf '%s\n' "$secret_matches" >&2
  failed="true"
fi

email_matches="$(git -C "$REPO_ROOT" grep -I -h -o -E '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' || true)"
for email_address in $(printf '%s\n' "$email_matches" | sed '/^$/d' | sort -u); do
  case "$email_address" in
    *@example.com)
      # RFC 2606's example.com is reserved for fixtures and documentation.
      continue
      ;;
  esac
  if ! grep -Fqx "$email_address" "$allowlist"; then
    warn "PII/secrets check found an unapproved email address in tracked text: $email_address"
    failed="true"
  fi
done

[ "$failed" = "false" ] || die "PII/secrets check failed. Remove the sensitive content or explicitly approve an intentional public email in $allowlist."
log "PII/secrets check passed: no tracked credential patterns or unapproved email addresses found."
