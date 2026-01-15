#! /bin/python3
# Author: Aline Normoyle, 2023

import sys
import numpy as np

if len(sys.argv) != 2:
   print("usage: %s <npz>"%sys.argv[0])
   sys.exit(0)

data = np.load(sys.argv[1])
numFrames = len(data)
numJoints = len(data[0])
for f in range(len(data)):
   for p in range(len(data[f])):
      pos = data[f][p]
      x = pos[0]
      y = pos[1]
      z = pos[2]
      data[f][p][0] = x
      data[f][p][1] = z
      data[f][p][2] = -y
      
frames = np.reshape(data, (numFrames, numJoints * 3))

tokens = sys.argv[1].split(".")
print(f"Writing file: {tokens[0]}.csv")
np.savetxt('%s.csv'%tokens[0], frames, delimiter=",")
