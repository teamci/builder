load test_helper

@test "syntax: valid repo passes" {
	use_code_fixture syntax pass

	run test/emulate-buildkite script/syntax

	[ $status -eq 0 ]

	assert_tap "${output}"
}

@test "syntax: invalid json fails" {
	use_code_fixture syntax invalid_json

	run test/emulate-buildkite script/syntax

	[ $status -eq 1 ]

	assert_tap "${output}"
}

@test "syntax: invalid yml fails" {
	use_code_fixture syntax invalid_yml

	run test/emulate-buildkite script/syntax

	[ $status -eq 1 ]

	assert_tap "${output}"
}

@test "syntax: no files to syntax" {
	use_code_fixture syntax skip

	run test/emulate-buildkite script/syntax

	[ $status -eq 7 ]

	assert_tap "${output}"
}

@test "syntax: ls-files script present" {
	use_code_fixture syntax config_script

	run test/emulate-buildkite script/syntax

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "syntax: file list set" {
	use_code_fixture syntax file-list

	run test/emulate-buildkite script/syntax

	[ $status -eq 1 ]

	set_test_files valid.json

	run test/emulate-buildkite script/syntax

	[ $status -eq 0 ]
}

@test "syntax: file list should be skipped" {
	use_code_fixture syntax file-list

	set_test_files junk.txt

	run test/emulate-buildkite script/syntax

	[ $status -eq 7 ]
}
