@test "valid repo passes" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/syntax'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 0 ]
	[ -n "${output}" ]
	[ "$(echo "${output}" | grep -c -F -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}

@test "invalid json fails" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/syntax'
	buildkite-agent meta-data set 'teamci.head_branch' 'invalid_json'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 1 ]
	[ -n "${output}" ]
	[ "$(echo "${output}" | grep -c -F -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}

@test "invalid yml fails" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/syntax'
	buildkite-agent meta-data set 'teamci.head_branch' 'invalid_yml'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 1 ]
	[ -n "${output}" ]
	[ "$(echo "${output}" | grep -c -F -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}

@test "no files to syntax" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/syntax'
	buildkite-agent meta-data set 'teamci.head_branch' 'skip'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 7 ]
	[ -n "${output}" ]
	[ "$(echo "${output}" | grep -c -F -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}

@test "ls-files script present" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.repo.slug' 'test/syntax'
	buildkite-agent meta-data set 'teamci.head_branch' 'config_script'
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}
