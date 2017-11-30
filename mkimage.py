#!/usr/bin/env python3
import pygame
pygame.init()
image = pygame.image.load("jw.png")

def printcolor(a, f):
    for i in range(0, len(r), 32):
        for j in range(0, 32):
            if j != 0 and j != 16:
                print("_", end='', sep='', file=f)
            if j == 16:
                print(" ", end='', sep='', file=f)
            print("%03X" % int(a[i+j]), end='', sep='', file=f)
        print("", file=f)
    print("", file=f)

(r, g, b) = ([], [], [])
pixels = pygame.image.tostring(image, "RGB")
for i in range(0, len(pixels), 3):
    r.append(pixels[i])
    g.append(pixels[i+1])
    b.append(pixels[i+2])
f = open('image.txt', 'w')
printcolor(r, f)
printcolor(g, f)
printcolor(r, f)
f.close()
