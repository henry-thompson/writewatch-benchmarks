#!/usr/local/bin/bash

# This benchmark tests how the GC performs for different sized programs, by
# timing the GC against the Boehm microbenchmark across a range of parameter
# values (e.g. different size trees for the benchmark to manipulate).

# Options:
#
#   -result-prefix           Prefix given to results file
#   -writewatch-only         Only run the benchmark on the writewatch enabled
#                            variant of Boehm.
#   -original-only           Only run the benchmark on the unaltered variant of
#                            Boehm.

benchmark()
{
  export GC_PRINT_STATS=true

  echo ">> Running benchmark"

  for ((i = 0; i < 100; i++));
  do
    rtprio 0 ../boehm/benchmark 16 18 2>&1 | grep 'World-stopped marking took ' | sed 's/World-stopped marking took //g' | sed 's/ msec.*$//g'  >> unaggregated.log
  done
  
  python2 aggregate.py unaggregated.log > "$1"
}

original()
{
  cd ../boehm

  # === OLD GC ===
  # Build and install the original GC
  ./install.sh -original -build-gc
  
  cd ../pause-times
  benchmark "$1.baseline.tsv"
}

writewatch()
{
  cd ../boehm

  # === NEW GC ===
  # Build and install the GC. Specify a 16-address buffer if requested.
  ./install.sh -buffer 16 -build-gc

  cd ../pause-times
  benchmark "$1.writewatch.tsv"
}

prefix="results"

if [ "$1" == "-results-prefix" ]; then
  shift
  prefix="$1"
  shift
fi

cd ../boehm

if [ "$1" == "-writewatch-only" ]; then
  shift
  writewatch $prefix
elif [ "$1" == '-original-only' ]; then
  shift
  original $prefix
else
  original $prefix
  writewatch $prefix
fi
