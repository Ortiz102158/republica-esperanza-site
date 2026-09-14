#!/bin/bash
set -euo pipefail
HINT_FILE="passphrase-hint.txt"
ENCRYPTED_FILE="$HINT_FILE.gpg"
INTEGRITY_FILE="bundle/integrity.sha256"

if [[ ! -f "$HINT_FILE" ]]; then
  echo "❌ Error: $HINT_FILE no encontrado."
  echo "   Usa: nano passphrase-hint.txt para crearlo primero."
  exit 1
fi

echo "🔐 Cifrando $HINT_FILE → $ENCRYPTED_FILE (AES256+SHA512)..."
gpg --symmetric --cipher-algo AES256 --digest-algo SHA512 "$HINT_FILE"

if [[ ! -f "$ENCRYPTED_FILE" ]]; then
  echo "❌ Falló la generación de $ENCRYPTED_FILE"
  exit 2
fi

echo "🧹 Eliminando $HINT_FILE de forma segura..."
shred -u "$HINT_FILE" 2>/dev/null || rm -f "$HINT_FILE"

hash=$(sha256sum "$ENCRYPTED_FILE" | awk '{print $1}')
echo "$hash  $ENCRYPTED_FILE" >> "$INTEGRITY_FILE"
echo "✅ SHA256 registrado en $INTEGRITY_FILE"
echo "📦 Listo: $ENCRYPTED_FILE ($hash)"
