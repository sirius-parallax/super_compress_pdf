#!/bin/bash

set -e

# Проверка аргументов
if [ $# -ne 2 ]; then
  echo "Использование: $0 input.pdf output.pdf"
  exit 1
fi

INPUT="$1"
OUTPUT="$2"
WORKDIR=$(mktemp -d)
QUALITY=50   # Уровень сжатия JPEG (можешь изменить на 10–40)

echo "[+] Временная папка: $WORKDIR"

# Проверка наличия утилит
for cmd in pdftoppm convert img2pdf; do
  if ! command -v $cmd >/dev/null; then
    echo "[-] Утилита '$cmd' не установлена. Установи её и повтори."
    exit 1
  fi
done

cd "$WORKDIR"

echo "[+] Конвертация PDF в изображения..."
pdftoppm "$OLDPWD/$INPUT" page -jpeg -r 100  # Можно поиграть с -r (dpi)

echo "[+] Сжатие изображений..."
mkdir compressed
for img in page-*.jpg; do
  convert "$img" -quality $QUALITY "compressed/$img"
done

echo "[+] Сборка обратно в PDF..."
img2pdf compressed/*.jpg -o "$OLDPWD/$OUTPUT"

echo "[✓] Готово! Сжатый файл: $OUTPUT"
echo "[i] Размер: $(du -h "$OLDPWD/$OUTPUT" | cut -f1)"

# Очистка
rm -rf "$WORKDIR"
