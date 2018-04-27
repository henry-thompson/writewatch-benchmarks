import math
from sys import argv

def median(lst):
    sortedLst = sorted(lst)
    lstLen = len(lst)
    index = (lstLen - 1) // 2

    if (lstLen % 2):
        return sortedLst[index]
    else:
        return (sortedLst[index] + sortedLst[index + 1])/2.0

# Outliers are due to context switching
def remove_context_switches(data):
    data = sorted(data)
    med = median(data)

    for value in data:
        if value > med * 100:
            data.remove(value)

    return data

def mean(data):
    return sum(data) / len(data)

def variance(data):
  stdev = 0
  mu = mean(data)

  for value in data:
    stdev += (value - mu)**2

  return stdev/len(data)

def get_stats(heapsizes, writes, mprot, mwrit, none):
  mprot = remove_context_switches(mprot)
  mwrit = remove_context_switches(mwrit)
  none = remove_context_switches(none)

  # We are only interested in the overhead from each method. Remove the 'none' baseline.
  mean_none = mean(none)

  mprot_overhead = []
  for value in mprot:
    mprot_overhead.append(value - mean_none)

  mwrit_overhead = []
  for value in mwrit:
    mwrit_overhead.append(value - mean_none)

  # Have to combine standard devs
  mprot_stdev = math.sqrt(variance(mprot_overhead) + variance(none))
  mwrit_stdev = math.sqrt(variance(mwrit_overhead) + variance(none))

  mprot_mean = mean(mprot_overhead)
  mwrit_mean = mean(mwrit_overhead)

  return "%d\t%d\t%f\t%f\t%f\t%f\n" % (heapsize, writes, mprot_mean, mprot_stdev, mwrit_mean, mwrit_stdev)

with open(argv[1]) as f:
  f.readline()

  timings = {}
  fragments_list = {}
  
  for line in f.readlines():
    if len(line.split(',')) != 5:
        continue

    heapsize, writes, fragments, mode, results = line.split(',')

    heapsize = int(heapsize.strip())
    writes = int(writes.strip())
    fragments = int(fragments.strip())
    mode = mode.strip()

    results = results.split('\t')
    results = filter(lambda x: not x == '\n' and x, results)
    results = map(int, results)

    if not timings.has_key(writes):
        timings[writes] = {}

    if not timings[writes].has_key(heapsize):
        timings[writes][heapsize] = {}

    if not timings[writes][heapsize].has_key(fragments):
        timings[writes][heapsize][fragments] = {}

    if not timings[writes][heapsize][fragments].has_key(mode):
        timings[writes][heapsize][fragments][mode] = results

    if not fragments_list.has_key(fragments):
        fragments_list[fragments] = True

  # Ignore fragments for now
  for writes in sorted(timings.iterkeys()):
    filename = "results-%s-writes.tsv" % (writes)
    with  open(filename, "w+") as f:
      f.write("Heap Size (bytes)\tWrites (pages)\tMean mprotect (us)\tStDev mprotect (us)\tMean mwritten (us)\tStDev mwritten (us)\n")

      for heapsize in sorted(timings[writes].iterkeys()):
        stats = get_stats(heapsize, writes,
          timings[writes][heapsize][1]["mprotect"],
          timings[writes][heapsize][1]["mwritten"],
          timings[writes][heapsize][1]["none"]
        )
        f.write(stats)
