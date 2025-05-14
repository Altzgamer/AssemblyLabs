Mephi assembly labs

make
make clean

lab2:
-DSORT_ORDER=(0|1)

lab5: Для замера времени с своей ASM функцией
/usr/bin/time -f "%e секунд при комбинации С+ASM" ./gray input.png output.png 
Скомпилировать только С часть
gcc -std=c99 -Wall -Wextra -Ofast -c main.c -o main.o 
Скомпилировать ASM
~/nasm-2.16.01/nasm -f elf64 -g process.s -o process.o
Скомпилировать все
gcc main.o process.o -o gray -lm

В main заменить grayscale_asm на grayscale_c если нужен только си
Замерить можно с помощью bash bencmark.sh (в папку images положить image.png, image2.png, image3.png)

Вызов программы как ./gray input.png output.png
