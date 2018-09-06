#!/usr/bin/env bash
for i in $(seq 1 1000); do
  printf "%04d" $i
  dd if=/dev/urandom of=img$(printf "%04d" $i).png bs=1M count=1
done
