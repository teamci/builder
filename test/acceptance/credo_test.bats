load test_helper

@test "credo: invalid repo fails" {
	use_code_fixture credo fail

	run test/emulate-buildkite script/credo

	[ $status -eq 1 ]

	assert_tap "${output}"
}

@test "credo: valid repo passes" {
	use_code_fixture credo pass

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]

	refute_tap "${output}"
}

@test "credo: no matching files" {
	use_code_fixture credo skip

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "credo: config file exists" {
	use_code_fixture credo config_file
	use_conf_fixture credo config_file

	run test/emulate-buildkite script/credo

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "credo: config parse errors" {
	use_code_fixture credo pass
	use_conf_fixture credo parse_error

	run test/emulate-buildkite script/credo

	[ $status -eq 1 ]

	refute_tap "${output}"
}

@test "credo: file list set" {
	# Run against all files should fail
	use_code_fixture credo file-list

	run test/emulate-buildkite script/credo

	[ $status -eq 1 ]
	[ -n "${output}" ]

	assert_tap "${output}"

	# Run without the failing file should pass
	set_test_files lib/pass.ex lib/junk.txt

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]

	refute_tap "${output}"
}

@test "credo: file list ignored by config" {
	# Run with a invalid file excluded from config passes
	use_code_fixture credo file-list-ignore
	use_conf_fixture credo file-list-ignore

	# fail/sample.ex is ignored by config, so run should pass
	set_test_files lib/pass.ex fail/sample.ex lib/junk.txt

	run test/emulate-buildkite script/credo

	[ $status -eq 0 ]

	refute_tap "${output}"
}

@test "credo: file list should be skipped" {
	use_code_fixture credo file-list-skip

	set_test_files junk.txt

	run test/emulate-buildkite script/credo

	[ $status -eq 7 ]
}
