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

def get_stats(benchmark, total, user, system):
  print "%s\t%f\t%f\t%f\t%f\t%f\t%f" % (benchmark,
                            mean(total),
                            stdev(total),
                            mean(user),
                            stdev(user),
                            mean(system),
                            stdev(system))

with open(argv[1]) as f:
  timings = {}
  for line in f.readlines():
    benchmark, total, user, system = line.split('\t')

    benchmark = benchmark.strip()
    total = float(total.strip())
    user = float(user.strip())
    system = float(system.strip())

    if not timings.has_key(benchmark):
        timings[benchmark] = {
            'total': [],
            'user': [],
            'system': []
        }

    timings[benchmark]['total'].append(total)
    timings[benchmark]['user'].append(user)
    timings[benchmark]['system'].append(system)

  print "Benchmark\tMean Total (s)\tStdDev Total (s)\tMean User (ms)\tStdDev User (ms)\tMean System (ms)\tStdDev System (ms)"
  for benchmark in sorted(timings.iterkeys()):
    get_stats(benchmark,
              timings[benchmark]['total'],
              timings[benchmark]['user'],
              timings[benchmark]['system'])
