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

