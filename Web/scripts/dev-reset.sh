#!/usr/bin/env bash
# Eski Next.js süreçlerini durdurur, .next'i temizler, tek sunucu başlatır.
set -euo pipefail
cd "$(dirname "$0")/.."

for port in 3000 3001; do
  pids=$(lsof -ti "tcp:${port}" 2>/dev/null || true)
  if [ -n "${pids}" ]; then
    echo "→ Port ${port} kullanımda, durduruluyor..."
    kill -9 ${pids} 2>/dev/null || true
    sleep 1
  fi
done

echo "→ .next temizleniyor..."
rm -rf .next

echo "→ Dev sunucusu: http://localhost:3000"
exec npx next dev -p 3000
