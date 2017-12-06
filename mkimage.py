#!/usr/bin/env python3
import sys
import pygame

class MkImage:

    def print_hex(pixels, has_alpha, f):
        for i in range(0, len(pixels), 4 if has_alpha else 3):
            # print(pixels[i], file=f)
            # print(pixels[i+1], file=f)
            # print(pixels[i+2], file=f)
            print(0, file=f)
            print(0, file=f)
            print(0, file=f)

    def print_rom(pixels, has_alpha, f):
        # pixels = [("%03X" % 0) for d in range(0, 3456)]
        # pixels[0]    = "0FF"    # b@[0,0]
        # pixels[3+1]  = "0FF"    # g@[1,0]
        # pixels[6+2]  = "0FF"    # r@[2,0]
        # pixels[18]    = "0FF"
        # pixels[36+1]    = "0FF"
        # pixels[21+1]    = "0FF"
        # pixels[45]   = "0FF"    # b@[15,0]
        # pixels[47]   = "0FF"    # r@[15,0]
        # pixels[0+48] = "0FF"    # b@[16,0]
        # pixels[0+96*1+3] = "0FF"    # b@[0,1]
        # pixels[0+48+1] = "0FF"  # g@[16,0]
        # pixels[0+96*6] = "0FF"  # b@[0,1]
        # has_alpha = False
        skip = 4 if has_alpha else 3
        b = (pixels[0::skip])
        g = (pixels[1::skip])
        r = (pixels[2::skip])
        mb = [[0 for x in range(36)] for y in range(32)]
        mg = [[0 for x in range(36)] for y in range(32)]
        mr = [[0 for x in range(36)] for y in range(32)]
        for y in range(0, 36):
            for x in range(0, 32):
                mb[x][y] = b[y * 32 + x]
        for y in range(0, 36):
            for x in range(0, 32):
                mg[x][y] = g[y * 32 + x]
        for y in range(0, 36):
            for x in range(0, 32):
                mr[x][y] = r[y * 32 + x]
        # print("BLUE")
        # for y in range(0, 36):
        #     print("%2d: " % (y), end='')
        #     for x in range(0, 32):
        #         print("%s " % mb[x][y], end='')
        #     print()
        # print("GREEN")
        # for y in range(0, 36):
        #     print("%2d: " % (y), end='')
        #     for x in range(0, 32):
        #         print("%s " % mg[x][y], end='')
        #     print()
        # print("RED")
        # for y in range(0, 36):
        #     print("%2d: " % (y), end='')
        #     for x in range(0, 32):
        #         print("%s " % mr[x][y], end='')
        #     print()
        # print("%d, %d = %s" % (x, y, mb[x][y]))
        # TODO: every 16 pixels switch to another color
        for r in range(0, 6):
            for c in range(0, 3):
                for p in range(0, 16):
                    for g in range(0, 12):
                        q = 0
                        for lr in range(0, 2):
                            for s in range(0, 6):
                                y = r + s * 6
                                x = (15 - p) + lr * 16
                                if (c == 0):
                                    d = ((int(mr[x][y],16) << g) & 0x800) >> 11
                                if (c == 1):
                                    d = ((int(mg[x][y],16) << g) & 0x800) >> 11
                                if (c == 2):
                                    d = ((int(mb[x][y],16) << g) & 0x800) >> 11
                                v = d << (s + lr * 6)
                                o = c * 192 + r * 576 + x * 12 + g
                                # if (v):
                                #     print("x=%2d, y=%2d, s=%d r=%d g=%2d, m=%s, d=%d v=%s lr=%d c=%d o=%d" % (x,y,s,r,g,mb[x][y],d,bin(v),lr, c, o))
                                q = q | v
                        # if (q):
                        #     print("q=%s" % (bin(q)))
                        print("%03X" % q, file=f)
        for i in range(0, 1152):
            print("%03X" % 0, file=f)

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

        f = open('image.hex', 'w')
        MkImage.print_rom(pixels, has_alpha, f)
        f.close()

MkImage.process()
