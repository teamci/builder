setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	buildkite-agent meta-data set 'teamci.config.repo' 'eslint/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'pass'

	rm -rf "${TEAMCI_CODE_DIR}/"*
}

@test "eslint: valid repo passes" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'eslint/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	run test/emulate-buildkite script/eslint

	echo "${output}"

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ "$(echo "${output}" | grep -cF -- '--- TAP')" -eq 2 ]
}

@test "eslint: invalid repo fails" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'eslint/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'fail'

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]
	[ -n "${output}" ]

	[ "$(echo "${output}" | grep -cF -- '--- TAP')" -eq 2 ]

	# Test for annotation keys
	echo "${output}" | grep -qF 'filename:'
	echo "${output}" | grep -qF 'blob_href:'
	echo "${output}" | grep -qF 'start_line:'
	echo "${output}" | grep -qF 'end_line:'
	echo "${output}" | grep -qF 'warning_level:'
	echo "${output}" | grep -qF 'message:'
	echo "${output}" | grep -qF 'title:'
}

@test "eslint: no configuration file" {
	buildkite-agent meta-data set 'teamci.config.repo' 'no-op/no-op'
	buildkite-agent meta-data set 'teamci.config.branch' 'no-op'

	buildkite-agent meta-data set 'teamci.repo.slug' 'eslint/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	run test/emulate-buildkite script/eslint

	[ $status -eq 7 ]
	[ -n "${output}" ]
}

@test "eslint: ignore file" {
	buildkite-agent meta-data set 'teamci.config.repo' 'eslint/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'ignore_file'

	buildkite-agent meta-data set 'teamci.repo.slug' 'eslint/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'ignore_file'

	run test/emulate-buildkite script/eslint

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "eslint: no files" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'eslint/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'skip'

	run test/emulate-buildkite script/eslint

	[ $status -eq 7 ]
	[ -n "${output}" ]
}
