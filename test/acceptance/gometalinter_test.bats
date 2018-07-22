setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	# Required metadata, but scripts continue if these cannot be cloned
	buildkite-agent meta-data set 'teamci.config.repo' 'gometalinter/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'skip'

	rm -rf "${TEAMCI_CODE_DIR}/"*
}

@test "gometalinter: valid repo passes" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'gometalinter/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	run test/emulate-buildkite script/gometalinter

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.gometalinter.title')" ]
}

@test "gometalinter: invalid repo fails" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'gometalinter/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'fail'

	run test/emulate-buildkite script/gometalinter

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

	[ -n "$(buildkite-agent meta-data get 'teamci.gometalinter.title')" ]
}

@test "gometalinter: skips when no matching files" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'gometalinter/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'skip'

	run test/emulate-buildkite script/gometalinter

	# NOTE: there's no way to determine the skip case without an explicit
	# file list.
	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.gometalinter.title')" ]
}

@test "gometalinter: config file exists" {
	buildkite-agent meta-data set 'teamci.repo.slug' 'gometalinter/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'config-file'
	buildkite-agent meta-data set 'teamci.config.repo' 'gometalinter/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'config-file'

	run test/emulate-buildkite script/gometalinter

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.gometalinter.title')" ]
}
