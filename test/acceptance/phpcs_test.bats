load test_helper

@test "phpcs: valid repo passes" {
	use_code_fixture phpcs pass

	run test/emulate-buildkite script/phpcs

	[ $status -eq 0 ]
	assert_tap "${output}"
}

@test "phpcs: invalid repo fails" {
	use_code_fixture phpcs fail

	run test/emulate-buildkite script/phpcs

	[ $status -eq 1 ]

	assert_tap "${output}"
	assert_annotations "${output}"
}

@test "phpcs: skips when no matching files" {
	use_code_fixture phpcs skip

	run test/emulate-buildkite script/phpcs

	[ $status -eq 7 ]
	[ -n "${output}" ]
}

@test "phpcs: config file exists" {
	use_code_fixture phpcs config_file
	use_conf_fixture phpcs config_file

	run test/emulate-buildkite script/phpcs

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "phpcs: exit code 3" {
	use_code_fixture phpcs pass
	use_conf_fixture phpcs bad_output

	run test/emulate-buildkite script/phpcs

	# The configured options should make the failing fixture pass
	[ $status -eq 1 ]
	[ -n "${output}" ]

	# Catch our error message is printed
	echo "${output}" | grep -qFi 'internal error'
}

@test "phpcs: file list set" {
	use_code_fixture phpcs file-list

	run test/emulate-buildkite script/phpcs

	[ $status -eq 1 ]

	set_test_files pass.php junk.txt

	run test/emulate-buildkite script/phpcs

	[ $status -eq 0 ]
}

@test "phpcs: file list includes an ignored file" {
	use_code_fixture phpcs file-list-ignore
	use_conf_fixture phpcs file-list-ignore

	set_test_files pass.php ignore.php

	run test/emulate-buildkite script/phpcs

	[ $status -eq 0 ]
}

@test "phpcs: file list should be skipped" {
	use_code_fixture phpcs file-list-skip

	set_test_files junk.txt

	run test/emulate-buildkite script/phpcs

	[ $status -eq 7 ]
}
