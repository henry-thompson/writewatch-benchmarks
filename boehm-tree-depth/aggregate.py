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

def get_stats(treesize, heapsizes, timings, gcIters):
  print "%d\t%f\t%f\t%f\t%f\t%f\t%f" % (treesize,
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
    stretchDepth, longDepth, array, minDepth, maxDepth, gcs, heap, time = line.split('\t')

    longDepth = int(longDepth.strip())
    heap = int(heap.strip())
    time = float(time.strip()) / 1000
    gcs = int(gcs.strip())

    if not timings.has_key(longDepth):
        timings[longDepth] = []

    if not heapsizes.has_key(longDepth):
        heapsizes[longDepth] = []

    if not gcIters.has_key(longDepth):
        gcIters[longDepth] = []
 
    timings[longDepth].append(time)
    heapsizes[longDepth].append(heap)
    gcIters[longDepth].append(gcs)

  print "Tree Depth\tMean Heap Size (bytes)\tStdDev Heap Size (bytes)\tMean Time (s)\tStdDev Time (s)\tMean GC Iters\tStdDev GC Iters"
  for depth in sorted(timings.iterkeys()):
    get_stats(depth, heapsizes[depth], timings[depth], gcIters[depth])
