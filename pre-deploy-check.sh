#!/bin/bash
# pre-deploy-check.sh — Verificación final antes del git push
# © República de Esperanza — Soberanía digital con disciplina
set -euo pipefail

BUNDLE="bundle"
REQUIRED_FILES=(
  "es/index.html"
  "ht/index.html"
  "en/index.html"
  "vercel.json"
  "backup.sh"
  "passphrase-hint.txt.gpg"
  "integrity.sha256"
)

echo "🔍 Pre-deploy checklist — República de Esperanza"
echo "   Directorio: $(pwd)"
echo

# 1. Verifica estructura
if [[ ! -d "$BUNDLE" ]]; then
  echo "❌ ERROR: $BUNDLE/ no existe"
  exit 1
fi

missing=()
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$BUNDLE/$f" ]]; then
    missing+=("$f")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "❌ FALTAN archivos en $BUNDLE/:"
  for f in "${missing[@]}"; do echo "   - $f"; done
  exit 2
fi

# 2. Verifica integridad
echo "✅ Estructura correcta: 7/7 archivos presentes"
cd "$BUNDLE"
if sha256sum -c integrity.sha256 >/dev/null 2>&1; then
  echo "✅ SHA256: todos los hashes coinciden"
else
  echo "❌ ERROR: falló verificación de integridad"
  sha256sum -c integrity.sha256
  exit 3
fi
cd ..

# 3. Verifica vercel.json (redirección raíz → /es/)
if grep -q '"source": *"/"' "$BUNDLE/vercel.json" && \
   grep -q '"destination": *"/es/index.html"' "$BUNDLE/vercel.json"; then
  echo "✅ Vercel: / → /es/index.html (configuración correcta)"
else
  echo "⚠️  ADVERTENCIA: vercel.json no redirige / a /es/"
  echo "   Revisa: $(realpath "$BUNDLE/vercel.json")"
  exit 4
fi

# 4. Verifica que backup.sh sea ejecutable y contenga tu correo
if [[ ! -x "$BUNDLE/backup.sh" ]]; then
  echo "⚠️  ADVERTENCIA: $BUNDLE/backup.sh no es ejecutable"
  echo "   Ejecuta: chmod +x $BUNDLE/backup.sh"
  exit 5
fi

if grep -q "pablo102158@gmail.com" "$BUNDLE/backup.sh"; then
  echo "✅ backup.sh: configurado para pablo102158@gmail.com"
else
  echo "⚠️  ADVERTENCIA: no se encontró pablo102158@gmail.com en backup.sh"
  exit 6
fi

echo
echo "🎉 ✅ LISTO PARA DEPLOY"
echo "   Siguiente paso:"
echo "     git add bundle/"
echo "     git commit -m \"feat: trilingual site — integrity verified\""
echo "     git push && vercel --prod"
