#!/usr/bin/env python3
import sys
import pygame
pygame.init()
name = "jw.png"
image = pygame.image.load(name)

def printlgs(a, f):
    for i in range(16, len(a), 32):
        s = '_'.join(a[i:i+16])
        print("wire [0:575] lgs%-2d = {576'h%s};" % ((i-16)/32, '__'.join([s, s, s])), sep='', file=f)

def printrgs(a, f):
    for i in range(0, len(a), 32):
        s = '_'.join(a[i:i+16])
        print("wire [0:575] rgs%-2d = {576'h%s};" % (i/32, '__'.join([s, s, s])), sep='', file=f)

(r, g, b) = ([], [], [])
pixels = [("%03X" % d) for d in pygame.image.tostring(image, "RGB")]
for i in range(0, len(pixels), 3):
    r.append(pixels[i])
    g.append(pixels[i+1])
    b.append(pixels[i+2])
f = open('image.v', 'w')
printlgs(r, f)
printrgs(r, f)
f.close()
