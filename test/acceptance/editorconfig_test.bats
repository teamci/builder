setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	# Required metadata, but scripts continue if these cannot be cloned
	buildkite-agent meta-data set 'teamci.config.repo' 'no-op/no-op'
	buildkite-agent meta-data set 'teamci.config.branch' 'master'

	rm -rf "${TEAMCI_CODE_DIR}/"*
}

@test "editorconfig: valid repo passes" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'editorconfig/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ "$(echo "${output}" | grep -cF -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.editorconfig.title')" ]
}

@test "editorconfig: problematic git files" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'editorconfig/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'ignore_files'

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ "$(echo "${output}" | grep -cF -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.editorconfig.title')" ]
}

@test "editorconfig: invalid repo fails" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'editorconfig/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'fail'

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 1 ]
	[ -n "${output}" ]

	[ "$(echo "${output}" | grep -cF -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.editorconfig.title')" ]
}

@test "editorconfig: no .editorconfig" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'editorconfig/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'skip'

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 7 ]
	[ -n "${output}" ]

	# Test that ls-files found 1 out of 2 files in the fixture repo
	echo "${output}" | grep -iqF 'skip'

	[ -n "$(buildkite-agent meta-data get 'teamci.editorconfig.title')" ]
}
