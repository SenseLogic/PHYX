#!/bin/sh
set -x
dmd -O -inline -m64 phyx.d
rm *.o
