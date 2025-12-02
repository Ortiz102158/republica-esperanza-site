#!/bin/bash
# backup.sh — respaldo seguro con SHA256 + GPG (como tú usas)
set -euo pipefail

GPG_KEY="${GPG_KEY:-pablo102158@gmail.com}"
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
BACKUP_DIR="backup_$TIMESTAMP"

echo "🔐 Iniciando backup — $TIMESTAMP"
mkdir -p "$BACKUP_DIR"

# SHA256 de los HTML
sha256sum es/index.html ht/index.html en/index.html > "$BACKUP_DIR/checksums.sha256"

# Empaqueta
tar -czf "$BACKUP_DIR/site.tar.gz" es/ ht/ en/ vercel.json

# Cifra
gpg --encrypt --recipient "$GPG_KEY" "$BACKUP_DIR/site.tar.gz"

echo "✅ Backup listo: $BACKUP_DIR/site.tar.gz.gpg"
