load test_helper

@test "rubocop: valid repo passes" {
	use_code_fixture rubocop pass

	run test/emulate-buildkite script/rubocop

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "rubocop: invalid repo fails" {
	use_code_fixture rubocop fail

	run test/emulate-buildkite script/rubocop

	[ $status -eq 1 ]

	assert_tap "${output}"
}

@test "rubocop: repo with config file" {
	use_code_fixture rubocop with_config
	use_conf_fixture rubocop with_config

	run test/emulate-buildkite script/rubocop

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "rubocop: repo with RUBOCOP_OPTS" {
	use_code_fixture rubocop pass
	use_conf_fixture rubocop opts

	run test/emulate-buildkite script/rubocop

	[ $status -eq 0 ]
	[ -n "${output}" ]

	# Grep for debug output that should be triggred by --debug in RUBOCOP_OPTS
	echo "${output}" | grep -qF 'Inheriting configuration'
}

@test "rubocop: test commit files" {
	use_code_fixture rubocop file_list
	set_test_files example.rb skip.txt

	run test/emulate-buildkite script/rubocop

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "rubocop: file in commit ignored by configuration" {
	use_code_fixture rubocop file_list_ignore
	set_test_files test/foo.rb

	run test/emulate-buildkite script/rubocop

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "rubocop: file list should be skipped" {
	use_code_fixture rubocop file-list-skip
	set_test_files junk.txt

	run test/emulate-buildkite script/rubocop

	[ $status -eq 7 ]
}
