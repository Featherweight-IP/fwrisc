#!/bin/sh

etc_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd)"
FWRISC=`cd $etc_dir/.. ; pwd`
export FWRISC

# Add a path to the simscripts directory
export PATH=$FWRISC/packages/simscripts/bin:$PATH

# Force the PACKAGES_DIR
export PACKAGES_DIR=$FWRISC/packages

