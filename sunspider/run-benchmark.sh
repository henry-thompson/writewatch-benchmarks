#!/usr/local/bin/bash

chmod +x ./install-see.sh
. /install-see.sh

cd ../boehm
./install.sh -original -build-gc

cd ../sunspider
chmod +x ./runone.sh

rm *.tsv

#  Number of iterations is held in $1

if [[ $# -eq 0 ]] ; then
   iters=30
else
   shift
   iters="$1"
fi

for ((i = 1; i <= "$iters"; i++));
do
   echo "Mode: Baseline | Iteration: $i of $iters"
   find ./sunspider-0.9 -name "*.js" -exec ./runone.sh baseline {} \;
done

cd ../boehm
./install.sh -build-gc
cd ../sunspider

for ((i = 1; i <= "$iters"; i++));
do
   echo "Mode: WriteWatch | Iteration: $i of $iters"
   find ./sunspider-0.9 -name "*.js" -exec ./runone.sh writewatch {} \;
done

python2 aggregate.py results-baseline.unaggregated.tsv   > results-baseline.tsv
python2 aggregate.py results-writewatch.unaggregated.tsv > results-writewatch.tsv