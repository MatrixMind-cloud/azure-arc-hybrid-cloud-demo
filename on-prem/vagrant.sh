#!/usr/bin/env bash

source "$(dirname "$0")/credentials.env"

for _v in $(set -o posix; set | grep 'arc_');
do
  export "${_v}"
done

vagrant $@