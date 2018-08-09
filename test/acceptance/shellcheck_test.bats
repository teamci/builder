load test_helper

@test "shellcheck: valid repo passes" {
	use_code_fixture shellcheck pass

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 0 ]

	assert_tap "${output}"
}

@test "shellcheck: invalid repo fails" {
	use_code_fixture shellcheck fail

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 1 ]

	assert_tap "${output}"
	assert_annotations "${output}"
}

@test "shellcheck: finds files with shell shebang" {
	use_code_fixture shellcheck shebang

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 0 ]
	[ -n "${output}" ]

	# Test all fixture files were found
	echo "${output}" | grep -iqF 'found 8 file(s)'
}

@test "shellcheck: skips when no matching files" {
	use_code_fixture shellcheck skip

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 7 ]
	[ -n "${output}" ]

	# Test all fixture files were found
	echo "${output}" | grep -iqF 'found 0 file(s)'
}

@test "shellcheck: SHELLCHECK_OPTS exists" {
	use_code_fixture shellcheck fail
	use_conf_fixture shellcheck opts

	run test/emulate-buildkite script/shellcheck

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "shellcheck: ls-files exists" {
	use_code_fixture shellcheck ls-files
	use_conf_fixture shellcheck ls-files

	run test/emulate-buildkite script/shellcheck

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]

	# Test that ls-files found 1 out of 2 files in the fixture repo
	echo "${output}" | grep -iqF 'found 1 file(s)'
}

@test "shellcheck: file list set" {
	use_code_fixture shellcheck file-list

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 1 ]

	set_test_files pass.sh junk.txt

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 0 ]
}

@test "shellcheck: file list should be skipped" {
	use_code_fixture shellcheck file-list
	set_test_files junk.txt

	run test/emulate-buildkite script/shellcheck

	[ $status -eq 7 ]
}
