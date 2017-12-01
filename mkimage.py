#!/usr/bin/env python3
import sys
import pygame
pygame.init()
name = "pacman.png"
image = pygame.image.load(name)

def printxgs(r, g, b, x, o, f):
    for i in range(o, len(r), 32):
        sr = '_'.join(r[i:i+16])
        sg = '_'.join(g[i:i+16])
        sb = '_'.join(b[i:i+16])
        print("wire [0:575] %sgs%-2d = {576'h%s};" % (x, (i-o)/32, '__'.join([sr, sg, sb])), sep='', file=f)

(r, g, b) = ([], [], [])
pixels = [("%03X" % d) for d in pygame.image.tostring(image, "RGB")]
for i in range(0, len(pixels), 3):
    b.append(pixels[i])
    g.append(pixels[i+1])
    r.append(pixels[i+2])
f = open('image.v', 'w')
printxgs(r, g, b, "l", 16, f)
printxgs(r, g, b, "r",  0, f)
f.close()
