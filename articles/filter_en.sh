#!/bin/sh
grep -A1 -e '^EN:' curse-of-timezones-merged.md | grep -v -- "^--$" | sed -e 's/^EN: *//g'
