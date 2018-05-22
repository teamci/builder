@test "valid repo passes" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/linting'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=lint script/lint

	echo "${output}"

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -z "$(buildkite-agent metadata get 'teamci.lint.title')" ]
}

@test "invalid json fails" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/linting'
	buildkite-agent meta-data set 'teamci.head_branch' 'invalid_json'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=lint script/lint

	[ $status -eq 1 ]
	[ -n "${output}" ]

	[ -z "$(buildkite-agent metadata get 'teamci.lint.title')" ]
}

@test "invalid yml fails" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/linting'
	buildkite-agent meta-data set 'teamci.head_branch' 'invalid_yml'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=lint script/lint

	[ $status -eq 1 ]
	[ -n "${output}" ]

	[ -z "$(buildkite-agent metadata get 'teamci.lint.title')" ]
}

@test "no files to lint" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/linting'
	buildkite-agent meta-data set 'teamci.head_branch' 'skip'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=lint script/lint

	[ $status -eq 7 ]
	[ -n "${output}" ]

	[ -z "$(buildkite-agent metadata get 'teamci.lint.title')" ]
}

@test "ls-files script present" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/linting'
	buildkite-agent meta-data set 'teamci.head_branch' 'config_script'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=lint script/lint

	echo "${output}"

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -z "$(buildkite-agent metadata get 'teamci.lint.title')" ]
}
