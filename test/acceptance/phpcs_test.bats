setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	# Required metadata, but scripts continue if these cannot be cloned
	buildkite-agent meta-data set 'teamci.config.repo' 'phpcs/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'skip'

	rm -rf "${TEAMCI_CODE_DIR}/"*
}

@test "phpcs: valid repo passes" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'phpcs/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	run test/emulate-buildkite script/phpcs

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ "$(echo "${output}" | grep -cF -- '--- TAP')" -eq 2 ]

	[ -n "$(buildkite-agent meta-data get 'teamci.phpcs.title')" ]
}

@test "phpcs: invalid repo fails" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'phpcs/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'fail'

	run test/emulate-buildkite script/phpcs

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

	[ -n "$(buildkite-agent meta-data get 'teamci.phpcs.title')" ]
}

@test "phpcs: skips when no matching files" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'phpcs/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'skip'

	run test/emulate-buildkite script/phpcs

	[ $status -eq 7 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.phpcs.title')" ]
}

@test "phpcs: config file exists" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'phpcs/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'config_file'
	buildkite-agent meta-data set 'teamci.config.repo' 'phpcs/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'config_file'

	run test/emulate-buildkite script/phpcs

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.phpcs.title')" ]
}

@test "phpcs: exit code 3" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'phpcs/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'
	buildkite-agent meta-data set 'teamci.config.repo' 'phpcs/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'bad_output'

	run test/emulate-buildkite script/phpcs

	# The configured options should make the failing fixture pass
	[ $status -eq 1 ]
	[ -n "${output}" ]

	# Catch our error message is printed
	echo "${output}" | grep -qFi 'internal error'

	[ -n "$(buildkite-agent meta-data get 'teamci.phpcs.title')" ]
}
