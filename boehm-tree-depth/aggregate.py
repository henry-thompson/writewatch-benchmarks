import math
import numpy

def get_stats(treesize, heapsizes, timings):
  if not (len(heapsizes) == len(timings)):
    print "Heap and timing sample sizes differ!"
    return

  print "%d\t%f\t%f\t%f\t%f" % (treesize,
                            numpy.mean(heapsizes),
                            numpy.std(heapsizes),
                            numpy.mean(timings),
                            numpy.std(timings))

with open('unaggregated.temp') as f:
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