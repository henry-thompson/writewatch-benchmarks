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

def get_stats(divisor, heapsizes, timings, gcIters):
  print "%d\t%f\t%f\t%f\t%f\t%f\t%f" % (divisor,
                            mean(heapsizes),
                            stdev(heapsizes),
                            mean(timings),
                            stdev(timings),
                            mean(gcIters),
                            stdev(gcIters))

with open(argv[1]) as f:
  f.readline()

  timings = {}
  heapsizes = {}
  gcIters = {}

  for line in f.readlines():
    gcFreeSpaceDivisor, stretchDepth, longLivedDepth, array, minDepth, maxDepth, gcs, heap, time = line.split('\t')

    gcFreeSpaceDivisor = int(gcFreeSpaceDivisor.strip())
    heap = int(heap.strip())
    time = float(time.strip()) / 1000
    gcs = int(gcs.strip())

    if not timings.has_key(gcFreeSpaceDivisor):
        timings[gcFreeSpaceDivisor] = []

    if not heapsizes.has_key(gcFreeSpaceDivisor):
        heapsizes[gcFreeSpaceDivisor] = []

    if not gcIters.has_key(gcFreeSpaceDivisor):
        gcIters[gcFreeSpaceDivisor] = []
 
    timings[gcFreeSpaceDivisor].append(time)
    heapsizes[gcFreeSpaceDivisor].append(heap)
    gcIters[gcFreeSpaceDivisor].append(gcs)

  print "GC Free Space Divisor\tMean Heap Size (bytes)\tStdDev Heap Size (bytes)\tMean Time (s)\tStdDev Time (s)\tMean GC Iters\tStdDev GC Iters"
  for divisor in sorted(timings.iterkeys()):
    get_stats(divisor, heapsizes[divisor], timings[divisor], gcIters[divisor])
