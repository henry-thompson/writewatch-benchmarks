import math
from sys import argv

def mean(data):
    return sum(data) / len(data)

def stdev(data):
  stdev = 0
  mu = mean(data)

  for value in data:
    stdev += (value - mu)**2

  return math.sqrt(stdev/len(data))

with open(argv[1]) as f:
  timings = []
  nonzero_timings = []
  max = 0
  min = 9999999999

  for line in f.readlines():
    time = float(line.strip())
    timings.append(time)

    if not time == 0:
      nonzero_timings.append(time)

    if time > max:
      max = time

    if time < min:
        min = time

  print "Max: %f" % (max)
  print "Min: %f" % (min)
  print "Mean: %f" % (mean(timings))
  print "StdDev: %f" % (stdev(timings))
  print "Mean (Non-Zero): %f" % (mean(nonzero_timings))
  print "StdDev (Non-Zero): %f" % (stdev(nonzero_timings))
