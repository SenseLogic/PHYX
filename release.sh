#!/bin/sh
set -x
dmd -O -m64 phyx.d
rm *.o
