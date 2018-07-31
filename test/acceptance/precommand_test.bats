setup() {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	# Use a passing fixture
	buildkite-agent meta-data set 'teamci.repo.slug' 'credo/code'
	buildkite-agent meta-data set 'teamci.head_branch' 'pass'

	# Required metadata, but scripts continue if these cannot be cloned
	buildkite-agent meta-data set 'teamci.config.repo' 'credo/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'skip'

	rm -rf "${TEAMCI_CODE_DIR}/"*
}

@test "precommand: token request failure" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}?fail=true"

	run test/emulate-buildkite script/credo

	[ $status -eq 7 ]
	[ -n "${output}" ]

	echo "${output}" | grep -qF 'FATAL'
}

@test "precommand: blacklisted" {
	buildkite-agent meta-data set 'teamci.config.repo' 'credo/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'blacklist'

	run test/emulate-buildkite script/credo

	[ $status -eq 7 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.credo.title')" ]
}

@test "precommand: whitelisted" {
	buildkite-agent meta-data set 'teamci.config.repo' 'credo/config'
	buildkite-agent meta-data set 'teamci.config.branch' 'whitelist'

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.credo.title')" ]
}
