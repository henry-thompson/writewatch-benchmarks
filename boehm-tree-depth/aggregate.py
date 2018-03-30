import math
from sys import argv

def mean(data):
    return sum(data) / len(data)

def stdev(data):
  stdev = 0
  mu = mean(data)

  for value in data:
    stdev += (value - mu)**2

  stdev = math.sqrt(stdev/len(data))

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

  stats = {} 
  for line in f.readlines():
    stretchDepth, longDepth, array, minDepth, maxDepth, gcs, heap, time = line.split('\t')

    longDepth = int(longDepth.strip())
    heap = int(heap.strip())
    time = float(time.strip())

    if not stats.has_key(longDepth):
        stats[longDepth] = { "timings": [], "heapsizes": [] }

    stats[longDepth].timings.append(time)
    stats[longDepth].heapsizes.append(heap)

  print "Tree Depth\tMean Heap Size (bytes)\tStdDev Heap Size (bytes)\tMean Time (ms)\tStdDev Time (ms)"
  for depth in sorted(stats.iterkeys()):
    get_stats(depth, stats[depth].heapsizes, stats[depth].timings)