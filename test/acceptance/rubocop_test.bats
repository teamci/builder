setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	# Required metadata, but scripts continue if these cannot be cloned
	buildkite-agent meta-data set 'teamci.config.repo' 'no-op/no-op'
	buildkite-agent meta-data set 'teamci.config.branch' 'master'

	rm -rf "${TEAMCI_CODE_DIR}/"*
}

@test "rubocop: valid repo passes" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'rubocop/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	run test/emulate-buildkite script/rubocop

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "rubocop: invalid repo fails" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'rubocop/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'fail'

	run test/emulate-buildkite script/rubocop

	echo "${output}"

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

@test "rubocop: repo with config file" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'rubocop/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'with_config'
	buildkite-agent meta-data set 'teamci.config.repo' 'rubocop/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'with_config'

	run test/emulate-buildkite script/rubocop

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "rubocop: repo with RUBOCOP_OPTS" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'rubocop/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'
	buildkite-agent meta-data set 'teamci.config.repo' 'rubocop/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'opts'

	run test/emulate-buildkite script/rubocop

	[ $status -eq 0 ]
	[ -n "${output}" ]

	# Grep for debug output that should be triggred by --debug in RUBOCOP_OPTS
	echo "${output}" | grep -qF 'Inheriting configuration'
}
