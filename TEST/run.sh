#!/bin/sh
set -x
cp ORIGINAL/CODE/STYLE/* FIXED/CODE/STYLE/
cp ORIGINAL/CODE/VIEW/* FIXED/CODE/VIEW/
../phyx "FIXED//*.pht" "FIXED//*.phx" "FIXED//*.styl"

