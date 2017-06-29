#!/bin/bash

for t in w_2017_18 w_2017_20 w_2017_21 w_2017_23 w_2017_24 w_2017_25; do
    slug="lsstsqre/stacktest:7-stack-lsst_distrib-${t}"
    docker build --build-arg TAG=$t -t "$slug" .
    docker push "$slug"
done
