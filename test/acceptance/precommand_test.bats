load test_helper

@test "precommand: token request failure" {
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}?fail=true"

	run test/emulate-buildkite script/credo

	[ $status -eq 7 ]
	[ -n "${output}" ]

	echo "${output}" | grep -qF 'FATAL'
}

@test "precommand: upstream branch non-existent" {
	use_code_fixture credo pass
	buildkite-agent meta-data set 'teamci.head_branch' 'deleted-upstream'

	run test/emulate-buildkite script/credo

	[ $status -eq 7 ]
	[ -n "${output}" ]

	echo "${output}" | grep -qF 'WARN'
	echo "${output}" | grep -qF 'deleted-upstream'
}

@test "precommand: blacklisted" {
	use_code_fixture credo pass
	use_conf_fixture credo blacklist

	run test/emulate-buildkite script/credo

	[ $status -eq 7 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.credo.title')" ]
}

@test "precommand: whitelisted" {
	use_code_fixture credo pass
	use_conf_fixture credo whitelist

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]
	[ -n "${output}" ]

	[ -n "$(buildkite-agent meta-data get 'teamci.credo.title')" ]
}

@test "precommand: second test run after cloning code" {
	use_code_fixture credo pass

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]
}

@test "precommand: second test run with config repo" {
	use_code_fixture credo config_file
	use_conf_fixture credo config_file

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]
}

@test "precommand: [REGRESSION] custom image pull on CI" {
	use_code_fixture custom pass
	use_conf_fixture custom pass

	export CI=true
	run test/emulate-buildkite script/custom
	unset CI

	[ $status -eq 0 ]
}
