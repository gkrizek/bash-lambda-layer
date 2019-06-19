SHELL = /usr/bin/env bash -xe

PWD := $(shell pwd)

build:
	@rm -rf export
	@mkdir export
	@zip -yr export/layer.zip bootstrap bin lib libexec share

publish:
	@$(PWD)/publish.sh

publish-staging:
	@$(PWD)/publish-staging.sh

.PHONY: \
	build
	publish
	publish-staging