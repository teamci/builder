load test_helper

@test "stylelint: invalid repo fails" {
	use_code_fixture stylelint fail

	run test/emulate-buildkite script/stylelint

	[ $status -eq 1 ]

	assert_tap "${output}"
	assert_annotations "${output}"
}

@test "stylelint: parse errors" {
	use_code_fixture stylelint parse_error

	run test/emulate-buildkite script/stylelint

	[ $status -eq 1 ]

	assert_tap "${output}"
	assert_annotations "${output}"
}

@test "stylelint: valid repo passes" {
	use_code_fixture stylelint pass

	run test/emulate-buildkite script/stylelint

	[ $status -eq 0 ]

	assert_tap "${output}"
}

@test "stylelint: skips when no matching files" {
	use_code_fixture stylelint skip

	run test/emulate-buildkite script/stylelint

	[ $status -eq 7 ]

	refute_tap "${output}"
}

@test "stylelint: config file exists" {
	use_code_fixture stylelint config_file
	use_conf_fixture stylelint config_file

	run test/emulate-buildkite script/stylelint

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]

	assert_tap "${output}"
}

@test "stylelint: file list set" {
	use_code_fixture stylelint file-list

	run test/emulate-buildkite script/stylelint

	[ $status -eq 1 ]

	# Test that css files pass through selection filter
	set_test_files pass.css junk.txt

	run test/emulate-buildkite script/stylelint

	[ $status -eq 0 ]

	# Test that scss files pass through selection filter
	set_test_files pass.scss

	run test/emulate-buildkite script/stylelint

	[ $status -eq 0 ]

	# Test that less files pass through selection filter
	set_test_files pass.less

	run test/emulate-buildkite script/stylelint

	[ $status -eq 0 ]
}

@test "stylelint: file list includes an ignored file" {
	use_code_fixture stylelint file-list-ignore

	set_test_files pass.css ignore.css

	run test/emulate-buildkite script/stylelint

	[ $status -eq 0 ]
}

@test "stylelint: file list should be skipped" {
	use_code_fixture stylelint file-list
	set_test_files junk.txt

	run test/emulate-buildkite script/stylelint

	[ $status -eq 7 ]
}

@test "stylelint: invalid JSON configuration file" {
	use_code_fixture stylelint pass
	use_conf_fixture stylelint invalid-json

	run test/emulate-buildkite script/stylelint

	[ $status -eq 1 ]
	! echo "${output}" | grep -qiF 'unexpected token'
}
