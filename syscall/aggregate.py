import math

def get_stats(heapsize, bufsize, timings):
  if not len(timings) == 100:
      print "Not 100 items! Found %d instead" % len(timings)
      return

  mean = sum(timings) / 100
  stdev = 0

  for value in timings:
    stdev += (value - mean)**2
  stdev = math.sqrt(stdev/100)

  print "%d\t%d\t%f\t%f" % (heapsize, bufsize, mean, stdev)

with open('syscall-timing-results.tsv') as f:
  stats = {} 
  for line in f.readlines():
    heapsize, bufsize, i, time = line.split('\t')
    heapsize = int(heapsize.strip())
    bufsize = int(bufsize.strip())
    time = float(time.strip())

    if not stats.has_key(heapsize):
        stats[heapsize] = { bufsize: [] }
    
    if not stats[heapsize].has_key(bufsize):
        stats[heapsize][bufsize] = []

    stats[heapsize][bufsize].append(time)

  print "Heapsize\tBuffer Size\tMean\tStdDev"
  for heap in sorted(stats.iterkeys()):
      for buf in sorted(stats[heap].iterkeys()):
        get_stats(heap,buf,stats[heap][buf])