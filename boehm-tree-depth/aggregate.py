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

def get_stats(treesize, heapsizes, timings):
  if not (len(heapsizes) == len(timings)):
    print "Heap and timing sample sizes differ!"
    return
  
  print "%d\t%f\t%f\t%f\t%f" % (treesize,
                            mean(heapsizes),
                            stdev(heapsizes),
                            mean(timings),
                            stdev(timings))

with open(argv[1]) as f:
  f.readline()

  timings = {}
  heapsizes = {}
  for line in f.readlines():
    stretchDepth, longDepth, array, minDepth, maxDepth, gcs, heap, time = line.split('\t')

    longDepth = int(longDepth.strip())
    heap = int(heap.strip())
    time = float(time.strip())

    if not timings.has_key(longDepth):
        timings[longDepth] = []

    if not heapsizes.has_key(longDepth):
        heapsizes[longDepth] = []

    timings[longDepth].append(time)
    heapsizes[longDepth].append(heap)

  print "Tree Depth\tMean Heap Size (bytes)\tStdDev Heap Size (bytes)\tMean Time (ms)\tStdDev Time (ms)"
  for depth in sorted(timings.iterkeys()):
    get_stats(depth, heapsizes[depth], timings[depth])