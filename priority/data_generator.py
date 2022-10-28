def nearest_power2(num):
  power = 0;
  out = 0;
  while (2**power <= num):
    out = 2**power
    power += 1
  return out

for i in range(0, 256):
  print("{0:08b}".format(i) + "_" + "{0:08b}".format(nearest_power2(i)))
