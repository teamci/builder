load test_helper

@test "kubeval: invalid repo fails" {
	use_code_fixture kubeval fail

	run test/emulate-buildkite script/kubeval

	[ $status -eq 1 ]

	refute_tap "${output}"
}

@test "kubeval: valid repo passes" {
	use_code_fixture kubeval pass

	run test/emulate-buildkite script/kubeval

	[ $status -eq 0 ]

	refute_tap "${output}"
}

@test "kubeval: multi-manifest" {
	use_code_fixture kubeval multi

	run test/emulate-buildkite script/kubeval

	[ $status -ne 0 ]

	refute_tap "${output}"

	echo "${output}" | grep -qF 'invalid Deployment'
	echo "${output}" | grep -qF 'valid Service'
}

@test "kubeval: skips when no matching files" {
	use_code_fixture kubeval skip

	run test/emulate-buildkite script/kubeval

	[ $status -eq 7 ]

	refute_tap "${output}"
}

@test "kubeval: file list set" {
	use_code_fixture kubeval file-list

	run test/emulate-buildkite script/kubeval

	[ $status -eq 1 ]

	# Test that non-manifests pass through selection filter
	set_test_files valid.yml junk.yml

	run test/emulate-buildkite script/kubeval

	[ $status -eq 0 ]
}

@test "kubeval: file list should be skipped" {
	use_code_fixture kubeval file-list
	set_test_files junk.txt

	run test/emulate-buildkite script/kubeval

	[ $status -eq 7 ]
}

@test "kubeval: ls-files" {
	use_code_fixture kubeval fail
	use_conf_fixture kubeval ls-files

	run test/emulate-buildkite script/kubeval

	[ $status -eq 0 ]

	refute_tap "${output}"
}
