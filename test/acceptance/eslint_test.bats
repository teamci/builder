load test_helper

@test "eslint: valid repo passes" {
	use_code_fixture eslint pass
	use_conf_fixture eslint pass

	run test/emulate-buildkite script/eslint

	[ $status -eq 0 ]

	assert_tap "${output}"
}

@test "eslint: invalid repo fails" {
	use_code_fixture eslint fail
	use_conf_fixture eslint pass

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]

	assert_tap "${output}"
	assert_annotations "${output}"
}

@test "eslint: no configuration file" {
	use_code_fixture eslint pass
	use_empty_config

	run test/emulate-buildkite script/eslint

	[ $status -eq 7 ]
	[ -n "${output}" ]
}

@test "eslint: ignore file" {
	use_code_fixture eslint ignore_file
	use_conf_fixture eslint ignore_file

	run test/emulate-buildkite script/eslint

	[ $status -eq 0 ]

	assert_tap "${output}"
}

@test "eslint: no files" {
	use_code_fixture eslint skip
	use_conf_fixture eslint pass

	run test/emulate-buildkite script/eslint

	[ $status -eq 7 ]
	[ -n "${output}" ]
}

@test "eslint: file list set" {
	use_code_fixture eslint file-list
	use_conf_fixture eslint pass

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]

	set_test_files pass.js junk.txt

	run test/emulate-buildkite script/eslint

	[ $status -eq 0 ]
}

@test "eslint: file list includes an ignored file" {
	use_code_fixture eslint file-list-ignore
	use_conf_fixture eslint file-list-ignore

	# fail.js should be ignored
	set_test_files pass.js fail.js

	run test/emulate-buildkite script/eslint

	[ $status -eq 0 ]
}

@test "eslint: file list should be skipped" {
	use_code_fixture eslint file-list-skip
	use_conf_fixture eslint pass

	set_test_files junk.txt

	run test/emulate-buildkite script/eslint

	[ $status -eq 7 ]
}

@test "eslint: invalid JSON configuration file" {
	use_code_fixture eslint pass
	use_conf_fixture eslint invalid-json

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]
	! echo "${output}" | grep -qiF 'unexpected token'
}

@test "eslint: vue plugin enabled" {
	use_code_fixture eslint vue
	use_conf_fixture eslint vue

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]

	set_test_files valid.vue

	run test/emulate-buildkite script/eslint

	[ $status -eq 0 ]

	set_test_files invalid.vue

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]
}

@test "eslint: react plugin enabled" {
	use_code_fixture eslint react
	use_conf_fixture eslint react

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]

	set_test_files valid.js

	run test/emulate-buildkite script/eslint

	[ $status -eq 0 ]

	set_test_files invalid.js

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]
}

@test "eslint: ember plugin enabled" {
	use_code_fixture eslint ember
	use_conf_fixture eslint ember

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]

	set_test_files valid.js

	run test/emulate-buildkite script/eslint

	[ $status -eq 0 ]

	set_test_files invalid.js

	run test/emulate-buildkite script/eslint

	[ $status -eq 1 ]
}
