#!/usr/bin/env python3
import sys
import pygame

class MkImage:

    def print_gs(pixels, prefix, offset, has_alpha, f):
        skip = 4 if has_alpha else 3
        b = (pixels[0::skip])[::-1]
        g = (pixels[1::skip])[::-1]
        r = (pixels[2::skip])[::-1]
        for i in range(offset, len(r), 32):
            sr = '_'.join(r[i:i+16])
            sg = '_'.join(g[i:i+16])
            sb = '_'.join(b[i:i+16])
            print("wire [0:575] %sgs%-2d = {576'h%s};" % (prefix, 35-((i-offset)/32), '__'.join([sr, sg, sb])), sep='', file=f)

    def process():
        pygame.init()

        name = "jw.png" if len(sys.argv) == 1 else sys.argv[1]
        image = pygame.image.load(name)

        try:
            pixels = [("%03X" % d) for d in pygame.image.tostring(image, "RGBA_PREMULT")]
            has_alpha = True
        except:
            pixels = [("%03X" % d) for d in pygame.image.tostring(image, "RGB")]
            has_alpha = False

        f = open('image.v', 'w')
        MkImage.print_gs(pixels, "l", 16, has_alpha, f)
        MkImage.print_gs(pixels, "r",  0, has_alpha, f)
        f.close()

MkImage.process()
