#!/bin/sh
#****************************************************************************
#* status.sh
#****************************************************************************


testname=$1
seed=$2

if test ! -f simx.log; then
  echo "FAIL: $testname - no simx.log"
else
  n_passed=`grep "PASSED: $testname" simx.log | wc -l`
  n_failed=`grep "FAILED: $testname" simx.log | wc -l`

  if test $n_passed -eq 1 && test $n_failed -eq 0; then
    echo "PASSED: $testname"
  elif test $n_failed -ne 0; then
    echo "FAILED: $testname ($n_failed)"
  else
    echo "FAILED: $testname ($n_passed $n_failed)"
  fi
fi