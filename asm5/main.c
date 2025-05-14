#include <stdio.h>
#include <stdlib.h>
#define STB_IMAGE_IMPLEMENTATION
#include "Libraries/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "Libraries/stb_image_write.h"

// Прототип ассемблерной функции
void grayscale_asm(unsigned char *img, int width, int height, int channels);

void grayscale_c(unsigned char *img, int width, int height, int channels) {
    int pixels = width * height;
    for (int i = 0; i < pixels; i++) {
        unsigned char *p = img + i * channels;
        unsigned char r = p[0];
        unsigned char g = p[1];
        unsigned char b = p[2];
        int grey = (int)(0.3 * r + 0.59 * g + 0.11 * b);
        if (grey > 255) grey = 255;
        p[0] = p[1] = p[2] = (unsigned char)grey;
    }
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <input.png> <output.png>\n", argv[0]);
        return EXIT_FAILURE;
    }
    const char *infile = argv[1];
    const char *outfile = argv[2];

    int width, height, channels;
    unsigned char *img = stbi_load(infile, &width, &height, &channels, 0);
    if (!img) {
        fprintf(stderr, "Error: cannot load image '%s'\n", infile);
        return EXIT_FAILURE;
    }
    if (channels < 3) {
        fprintf(stderr, "Error: image must have at least 3 channels (RGB)\n");
        stbi_image_free(img);
        return EXIT_FAILURE;
    }

    grayscale_asm(img, width, height, channels);

    if (!stbi_write_png(outfile, width, height, channels, img, width * channels)) {
        fprintf(stderr, "Error: cannot write image '%s'\n", outfile);
        stbi_image_free(img);
        return EXIT_FAILURE;
    }

    stbi_image_free(img);
    return EXIT_SUCCESS;
}

