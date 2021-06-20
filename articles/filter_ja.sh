#!/bin/sh
grep -A1 -e '^JA:' curse-of-timezones-merged.md | grep -v -- "^--$" | sed -e 's/^JA: *//g'
