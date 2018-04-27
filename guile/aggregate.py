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

def get_stats(benchmark, time):
  benchmark = benchmark.split(':', 1)[0]
  print "%s\t%f\t%f" % (benchmark, mean(time), stdev(time))

with open(argv[1]) as f:
  timings = {}
  f.readline()

  for line in f.readlines():
    runtime, benchmark, time = line.split(',')

    runtime = runtime.strip()
    benchmark = benchmark.strip()
    time = time.strip()

    if time == "ULIMITKILLED" or time == "CRASHED":
        continue

    time = float(time)

    if not timings.has_key(benchmark):
        timings[benchmark] = []

    timings[benchmark].append(time)

  print "Benchmark\tMean_Total_(s)\tStdDev_Total_(s)"
  for benchmark in sorted(timings.iterkeys()):
    get_stats(benchmark, timings[benchmark])
