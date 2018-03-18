#!/bin/sh

# tests for the POSIX compliant shell functions
# we need.

if which sh > /dev/null 2>&1; then
    echo "sh found (expected)"
else
    echo sh not found
fi

if which nonesuch > /dev/null 2>&1
then
    echo nonesuch found
else
    echo "nonesuch not found (expected)"
fi

badfun () {
    return 1
}

goodfun () {
    return 0
}

if goodfun; then
    echo "Good fun good (expected)"
else
    echo "Good fun bad"
fi

if badfun; then
    echo "Bad fun good"
else
    echo "Bad fun bad (expected)"
fi

if [ 1 -eq 1 ]; then
    echo "equality good (expected)"
else
    echo "equality bad"
fi

if [ 1 -eq 2 ]; then
    echo "inequality good"
else
    echo "inequality bad (expected)"
fi

if [ "1" = "1" ]; then
    echo "string equality good (expected)"
else
    echo "string equality bad"
fi

if [ "1" = "2" ]; then
    echo "string inequality good"
else
    echo "string inequality bad (expected)"
fi

for option; do
    echo $option
done