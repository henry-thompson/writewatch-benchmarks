#!/usr/local/bin/bash

# This benchmark times how long the benchmark takes to scan an entire heap area
# across a range of heap sizes and output buffer sizes.

# Build the caller again if requested
if [ "$1" == '-build' ]; then
  shift
  echo "Rebuilding caller"
  cc caller.c -o caller
  chmod +x caller
fi

selftime=false

# Build the caller again if requested
if [ "$1" == '-selftime' ]; then
  shift
  selftime=true
  echo "Self-timing enabled"
fi

results=./results.tsv
timingTemp=./timing.temp 
unaggregatedTemp=./syscall-timing-results.tsv

minheap=1024*1024
maxheap=512*1024*1024
maxbufsize=512*1024

rm "$results"
rm "$timingTemp"
rm "$unaggregatedTemp"

# Run 100 times
for ((i=1;i<=100;i++));
do
  for ((heapsize = minheap; heapsize <= maxheap; heapsize *= 2));
  do
    for ((bufsize = 1; bufsize <= maxbufsize; bufsize *= 2));
    do
      echo "Testing heap $heapsize with buffer $bufsize"
      if [ "$selftime" = false ]; then
        # No need to give high priority---syscalls are never preempted, and since
        # that is all that is being measured no need to worry.
        truss -c -o "$timingTemp" ./caller "$heapsize" "$bufsize"
        timing="$(grep "#561" $timingTemp | grep -Eo "[0-9]\.[0-9]+")"
      else
        timing="$(./caller "$heapsize" "$bufsize" -selftime)"
      fi
      echo "$heapsize	$bufsize	$i	$timing" >> "$unaggregatedTemp"
    done
    # Without this CPU heats a lot---does this distort results? Best be safe.
    sleep 0.2
  done
done

# Aggregate results
python2 aggregate.py > "$results"