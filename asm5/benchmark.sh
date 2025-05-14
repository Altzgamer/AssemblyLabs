# ДЛЯ АСЕМБЛЕРА /usr/bin/time -f "%e секунд при комбинации С+ASM" ./gray input.png output.png
# gcc -std=c99 -Wall -Wextra -Ofast -c main.c -o main.o
# gcc main.o process.o -o gray -lm

#!/usr/bin/env bash
set -eu

# Массив оптимизационных флагов
FLAGS=(0 1 2 3 fast)

# Имена входных файлов
IMAGES=("input.png" "input2.png" "input3.png")

# Файл с результатами
OUTPUT="results.csv"

# Заголовок CSV
echo "flag,image,real_time_s" > "$OUTPUT"

# Проверка папки
if [ ! -d "./images" ]; then
  echo "Папка ./images не найдена!" >&2
  exit 1
fi

for f in "${FLAGS[@]}"; do
  BIN="gray_O${f}"
  echo "=== Компиляция с -O${f} ==="
  gcc -std=c99 -Wall -Wextra -O"${f}" main.c process.s -o "${BIN}" -lm

  for img in "${IMAGES[@]}"; do
    IN="./images/${img}"
    if [ ! -f "$IN" ]; then
      echo "Файл $IN не найден, пропускаем" >&2
      continue
    fi

    # Измеряем время выполнения в секундах (%e)
    t=$(/usr/bin/time -f "%e" "./${BIN}" "$IN" /dev/null 2>&1 >/dev/null)
    echo "O${f},${img},${t}" >> "$OUTPUT"
    echo "  Флаг -O${f}, ${img}: ${t}s"
  done
done

echo "Готово! Результаты в $(pwd)/${OUTPUT}"