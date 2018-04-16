#!/usr/local/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

git clone https://github.com/henry-thompson/see-mirror.git
cd see-mirror
git checkout enable-incremental
git pull
git fetch

./configure --with-boehm-gc
make
make install

