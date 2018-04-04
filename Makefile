all: build

build:
	docker build \
		--build-arg EUPS_TAG=w_2018_13 \
		-t lsstsqre/centos:7-stack-lsst_distrib .
