#!/bin/sh

python3 -m pip install ivpm

cd /project

# Fetch development packages and dependencies
# using non-SSH git
ivpm update --anonymous-git


