import math
from sys import argv
# Outliers are due to context switching
def mean(data):
    return sum(data) / len(data)

def stdev(data):
  stdev = 0
  mu = mean(data)

  for value in data:
    stdev += (value - mu)**2

  return math.sqrt(stdev/len(data))

def get_stats(kMaxTreeDepth, timings, heapSizes, gcIters):
  return "%d\t%f\t%f\t%f\t%f\t%f\t%f\n" % (kMaxTreeDepth, mean(timings), stdev(timings), mean(heapSizes), stdev(heapSizes), mean(gcIters), stdev(gcIters))

filename = "results-%s.tsv" % (argv[1])
with open(filename) as f:
  f.readline()

  timings = {}
  gcIters = {}
  heapSizes = {}
  
  for line in f.readlines():
    kStretchTreeDepth, kLongLivedTreeDepth, kArraySize, kMinTreeDepth, kMaxTreeDepth, gcIter, heapSize, time = line.split('\t')

    kLongLivedTreeDepth = int(kLongLivedTreeDepth.strip())
    kMaxTreeDepth = int(kMaxTreeDepth.strip())
    gcIter = int(gcIter.strip())
    heapSize = int(heapSize.strip())
    time = float(time.strip()) / 1000

    if not gcIters.has_key(kLongLivedTreeDepth):
        gcIters[kLongLivedTreeDepth] = {}

    if not gcIters[kLongLivedTreeDepth].has_key(kMaxTreeDepth):
        gcIters[kLongLivedTreeDepth][kMaxTreeDepth] = []
    
    if not heapSizes.has_key(kLongLivedTreeDepth):
        heapSizes[kLongLivedTreeDepth] = {}

    if not heapSizes[kLongLivedTreeDepth].has_key(kMaxTreeDepth):
        heapSizes[kLongLivedTreeDepth][kMaxTreeDepth] = []

    if not timings.has_key(kLongLivedTreeDepth):
        timings[kLongLivedTreeDepth] = {}

    if not timings[kLongLivedTreeDepth].has_key(kMaxTreeDepth):
        timings[kLongLivedTreeDepth][kMaxTreeDepth] = []

    gcIters[kLongLivedTreeDepth][kMaxTreeDepth].append(gcIter)
    heapSizes[kLongLivedTreeDepth][kMaxTreeDepth].append(heapSize)
    timings[kLongLivedTreeDepth][kMaxTreeDepth].append(time)

  for kLongLivedTreeDepth in sorted(timings.iterkeys()):
    filename = "results.%s.kLongLivedTreeDepth=%s.tsv" % (argv[1], kLongLivedTreeDepth)
    with  open(filename, "w+") as f:
      f.write("kMaxTreeDepth\tMean_Timing_(s)\tStDev_Timing_(s)\tMean_Heapsize_(bytes)\tStDev_Heapsize_(bytes)\tMean_GC_Iters\tStDev_GC_Iters\n")

      for kMaxTreeDepth in sorted(timings[kLongLivedTreeDepth].iterkeys()):
        stats = get_stats(kMaxTreeDepth, timings[kLongLivedTreeDepth][kMaxTreeDepth], heapSizes[kLongLivedTreeDepth][kMaxTreeDepth], gcIters[kLongLivedTreeDepth][kMaxTreeDepth])
        f.write(stats)
