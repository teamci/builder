ENV:=tmp/env

SYNTAX_IMAGE_FILES:=$(shell find syntax -print)

$(ENV): docker-compose.yml $(SYNTAX_IMAGE_FILES) test/fake_api/*
	docker-compose build
	docker-compose up -d api
	@mkdir -p $(@D)
	@touch $@

.PHONY: test-pipeline
test-pipeline:
	docker run --rm -v $(CURDIR):/data -w /data ruby:2.5 ruby test/pipeline_test.rb

.PHONY: test-lint
test-lint:
	@echo '~~~ Linting Tests'
	docker run --rm -v $(CURDIR):/data -w /data koalaman/shellcheck:v0.4.7 $(wildcard script/*) $(wildcard .buildkite/hooks/*)

.PHONY: test-hooks
test-hooks:
	@echo '~~~ Testing hooks'
	env BUILDKITE_LABEL=:pipeline: sh -c '. .buildkite/hooks/pre-command' > /dev/null
	env BUILDKITE_LABEL=:dummy: sh -c '. .buildkite/hooks/pre-command' > /dev/null
	sh -c '. .buildkite/hooks/post-command' > /dev/null

.PHONY: test-acceptance
test-acceptance: $(ENV) | tmp/buildkite-agent
	@echo '~~~ Acceptance Tests'
	@env \
		BUILDKITE_AGENT_METADIR=$(CURDIR)/tmp/buildkite-agent \
		FIXTURE_DIR=$(CURDIR)/test/fixtures \
		PATH=$(CURDIR)/test/stubs/bin:$$PATH \
		TEAMCI_API_URL=http://localhost:9292 \
		TEAMCI_CODE_DIR=$(CURRDIR)/tmp/code \
		bats test/acceptance/*_test.bats

.PHONY: test-ci
test-ci: test-acceptance test-hooks test-pipeline test-lint

tmp/buildkite-agent:
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf $(ENV) tmp/*
	docker-compose down
