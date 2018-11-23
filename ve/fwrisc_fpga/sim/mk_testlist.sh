
test=""

while read line; do
  is_category=`echo $line | sed -e 's/^.*\.$/true/g'`
  if test "x$is_category" = "xtrue"; then
    test=$line
  else
    echo "${test}${line}"
  fi
done
