ENV:=tmp/env

DOCKER_IMAGES:=syntax,rubocop,shellcheck,editorconfig,eslint,gometalinter,phpcs,stylelint,credo,kubeval,cfnlint
DOCKER_IMAGE_FILES:=$(shell find {$(DOCKER_IMAGES)} -print)

$(ENV): docker-compose.yml $(DOCKER_IMAGE_FILES) test/fake_api/*
	docker-compose build
	docker-compose up -d api
	@mkdir -p $(@D)
	@touch $@

.PHONY: test-pipeline
test-pipeline:
	docker run --rm -v $(CURDIR):/data -w /data ruby:2.5 ruby test/pipeline_test.rb

.PHONY: test-compose
test-compose:
	docker run --rm -v $(CURDIR):/data -w /data ruby:2.5 ruby test/compose_test.rb

.PHONY: test-lint
test-lint:
	@echo '~~~ Linting Tests'
	docker run --rm -v $(CURDIR):/data -w /data koalaman/shellcheck:v0.4.7 -f gcc \
		$(wildcard script/*) \
		$(wildcard .buildkite/hooks/*) \
		$(wildcard test/stubs/bin/*) \
		$(shell find . -name '*-tap' -print) \
		test/emulate-buildkite

.PHONY: test-acceptance
test-acceptance: FILE=$(wildcard test/acceptance/*_test.bats)
test-acceptance: $(ENV)
	@echo '~~~ Acceptance Tests'
	@env \
		BUILDKITE_AGENT_METADIR=$(shell mktemp -d) \
		FIXTURE_DIR=$(CURDIR)/test/fixtures \
		PATH=$(CURDIR)/test/stubs/bin:$$PATH \
		TEAMCI_API_URL=http://localhost:9292 \
		TEAMCI_CODE_DIR=$(CURDIR)/tmp/code \
		bats $(FILE)

.PHONY: test-ci
test-ci: test-acceptance test-pipeline test-compose test-lint

tmp/buildkite-agent:
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf $(ENV) tmp/*
	docker-compose down
