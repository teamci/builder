load test_helper

@test "cfnlint: invalid repo fails" {
	use_code_fixture cfnlint fail

	run test/emulate-buildkite script/cfnlint

	[ $status -eq 1 ]

	assert_tap "${output}"
	assert_annotations "${output}"
}

@test "cfnlint: valid repo passes" {
	use_code_fixture cfnlint pass

	run test/emulate-buildkite script/cfnlint

	[ $status -eq 0 ]

	refute_tap "${output}"
}

@test "cfnlint: skips when no matching files" {
	use_code_fixture cfnlint skip

	run test/emulate-buildkite script/cfnlint

	[ $status -eq 7 ]

	refute_tap "${output}"
}

@test "cfnlint: file list set" {
	use_code_fixture cfnlint file-list

	run test/emulate-buildkite script/cfnlint

	[ $status -eq 1 ]

	# Test that non-manifests pass through selection filter
	set_test_files valid.yml junk.yml

	run test/emulate-buildkite script/cfnlint

	[ $status -eq 0 ]
}

@test "cfnlint: file list should be skipped" {
	use_code_fixture cfnlint file-list
	set_test_files junk.txt

	run test/emulate-buildkite script/cfnlint

	[ $status -eq 7 ]
}

@test "cfnlint: ls-files script configured" {
	use_code_fixture cfnlint ls-files
	use_conf_fixture cfnlint ls-files

	run test/emulate-buildkite script/cfnlint

	[ $status -eq 0 ]

	refute_tap "${output}"
}
