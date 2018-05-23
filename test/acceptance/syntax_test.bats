setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'
}

@test "syntax: valid repo passes" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'syntax/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 0 ]
	[ -n "${output}" ]
	[ "$(echo "${output}" | grep -c -F -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}

@test "syntax: invalid json fails" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'syntax/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'invalid_json'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 1 ]
	[ -n "${output}" ]
	[ "$(echo "${output}" | grep -c -F -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}

@test "syntax: invalid yml fails" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'syntax/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'invalid_yml'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 1 ]
	[ -n "${output}" ]
	[ "$(echo "${output}" | grep -c -F -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}

@test "syntax: no files to syntax" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'syntax/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'skip'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 7 ]
	[ -n "${output}" ]
	[ "$(echo "${output}" | grep -c -F -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}

@test "syntax: ls-files script present" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'syntax/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'config_script'

	run env BUILDKITE_LABEL=syntax script/syntax

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.syntax.title')" ]
}
