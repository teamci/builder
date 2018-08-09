load test_helper

@test "custom: valid repo passes" {
	use_code_fixture custom pass
	use_conf_fixture custom pass

	run test/emulate-buildkite script/custom

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "custom: no Dockerfile" {
	use_code_fixture custom pass
	use_conf_fixture custom skip

	run test/emulate-buildkite script/custom

	[ $status -eq 7 ]
	[ -n "${output}" ]
}
