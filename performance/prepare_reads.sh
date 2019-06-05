#!/bin/bash

forward=$1
reverse=$2

# copy both read sets
zcat $forward >forward.changed.fq
zcat $reverse >reverse.changed.fq

# generate quality information
/tank/projects/benchmark/benchmark/docker/benchmark-baseimage/random_qual.pl forward.changed.fq
/tank/projects/benchmark/benchmark/docker/benchmark-baseimage/random_qual.pl reverse.changed.fq

# prepare beacons
mkdir "read_sets_changed.started"
touch read_sets_changed.done
touch forward.fq
touch reverse.fq
