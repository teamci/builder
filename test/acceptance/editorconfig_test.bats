load test_helper

@test "editorconfig: valid repo passes" {
	use_code_fixture editorconfig pass

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 0 ]

	assert_tap "${output}"
}

@test "editorconfig: problematic git files" {
	use_code_fixture editorconfig ignore_files

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 0 ]

	assert_tap "${output}"
}

@test "editorconfig: invalid repo fails" {
	use_code_fixture editorconfig fail

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 1 ]

	assert_tap "${output}"
}

@test "editorconfig: no .editorconfig" {
	use_code_fixture editorconfig skip

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 7 ]
	[ -n "${output}" ]

	# Test that ls-files found 1 out of 2 files in the fixture repo
	echo "${output}" | grep -iqF 'skip'
}

@test "editorconfig: file list set" {
	use_code_fixture editorconfig file-list

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 1 ];

	assert_tap "${output}"

	set_test_files pass.rb

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 0 ];

	assert_tap "${output}"
}

@test "editorconfig: file list includes an ignored file" {
	use_code_fixture editorconfig file-list-ignore

	set_test_files pass.rb skip.rb

	run test/emulate-buildkite script/editorconfig

	[ $status -eq 0 ];
}
