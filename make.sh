#!/bin/sh
set -x
dmd -m64 phyx.d
rm *.o
