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

@test "precommand: [REGRESSION] file list contains file that doesn't exit" {
	use_code_fixture custom pass
	use_conf_fixture custom pass
	set_test_files -f /null/foo .gitkeep

	run test/emulate-buildkite script/syntax

	! grep -qF '/null/foo' "${TEAMCI_CODE_DIR}/custom/code/.teamci_test_files"
	grep -qF '.gitkeep' "${TEAMCI_CODE_DIR}/custom/code/.teamci_test_files"
}

@test "precommand: [REGRESSION] file list is all non-existent" {
	use_code_fixture custom pass
	use_conf_fixture custom pass
	set_test_files -f /null/foo

	run test/emulate-buildkite script/syntax

	[ ! -f "${TEAMCI_CODE_DIR}/custom/code/.teamci_test_files" ]
}
