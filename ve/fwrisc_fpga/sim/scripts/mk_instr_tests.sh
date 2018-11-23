#!/bin/sh

suite=""
echo "" > tests.tl
while read line; do
  line=`echo $line | sed -e 's/[ \t]*//g'`
  is_suite=`echo $line | sed -e 's/.*\.$/true/g'`
  if test "x$is_suite" = "xtrue"; then
    suite=$line
  elif test $suite != "riscv_compliance_tests." && test "x$line" != "x"; then
    testfile=`echo ${suite}${line} | sed -e 's/\./_/g'`
    echo "--gtest_filter=${suite}${line}" > tests/${testfile}.f
    echo "tests/${testfile}.f" >> tests.tl
    echo "test: ${suite}${line}"
  fi

done

