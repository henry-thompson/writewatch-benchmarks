#!/usr/local/bin/bash

git clone https://github.com/henry-thompson/see-mirror.git
cd see-mirror
git checkout enable-incremental
git pull
git fetch

./configure --with-boehm-gc
make
make install

