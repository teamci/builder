setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	# Required metadata, but scripts continue if these cannot be cloned
	buildkite-agent meta-data set 'teamci.config.repo' 'no-op/no-op'
	buildkite-agent meta-data set 'teamci.config.branch' 'master'

	rm -rf "${TEAMCI_CODE_DIR}/"*
}

@test "custom: valid repo passes" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'custom/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'
	buildkite-agent meta-data set 'teamci.config.repo' 'custom/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'pass'

	run test/emulate-buildkite script/custom

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "custom: no Dockerfile" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'custom/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'
	buildkite-agent meta-data set 'teamci.config.repo' 'custom/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'skip'

	run test/emulate-buildkite script/custom

	[ $status -eq 7 ]
	[ -n "${output}" ]

	# Test that ls-files found 1 out of 2 files in the fixture repo
	echo "${output}" | grep -iqF 'skip'
}
