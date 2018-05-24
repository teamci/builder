setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	# Required metadata, but scripts continue if these cannot be cloned
	buildkite-agent meta-data set 'teamci.config.repo' 'no-op/no-op'
	buildkite-agent meta-data set 'teamci.config.branch' 'master'

	rm -rf "${TEAMCI_CODE_DIR}/"*
}

@test "shellcheck: valid repo passes" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'shellcheck/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.shellcheck.title')" ]
}

@test "shellcheck: invalid repo fails" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'shellcheck/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'fail'

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 1 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.shellcheck.title')" ]
}

@test "shellcheck: finds files with shell shebang" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'shellcheck/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'shebang'

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 0 ]
	[ -n "${output}" ]

	# Test all fixture files were found
	echo "${output}" | grep -iqF 'found 8 file(s)'

	[ -n "$(buildkite-agent meta-data get 'teamci.shellcheck.title')" ]
}

@test "shellcheck: skips when no matching files" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'shellcheck/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'skip'

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 7 ]
	[ -n "${output}" ]

	# Test all fixture files were found
	echo "${output}" | grep -iqF 'found 0 file(s)'

	[ -n "$(buildkite-agent meta-data get 'teamci.shellcheck.title')" ]
}

@test "shellcheck: SHELLCHECK_OPTS exists" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'shellcheck/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'fail'
	buildkite-agent meta-data set 'teamci.config.repo' 'shellcheck/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'opts'

	run test/emulate-buildkite script/shellcheck

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.shellcheck.title')" ]
}

@test "shellcheck: ls-files exists" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'shellcheck/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'ls-files'
	buildkite-agent meta-data set 'teamci.config.repo' 'shellcheck/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'ls-files'

	run test/emulate-buildkite script/shellcheck

	echo "${output}"

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]

	# Test that ls-files found 1 out of 2 files in the fixture repo
	echo "${output}" | grep -iqF 'found 1 file(s)'

	[ -n "$(buildkite-agent meta-data get 'teamci.shellcheck.title')" ]
}
