load test_helper

@test "gometalinter: valid repo passes" {
	use_code_fixture gometalinter pass

	run test/emulate-buildkite script/gometalinter

	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "gometalinter: deps script provided" {
	use_code_fixture gometalinter deps

	run test/emulate-buildkite script/gometalinter

	[ $status -eq 0 ]

	echo "${output}" | grep -qF 'hello from deps script'
}

@test "gometalinter: invalid repo fails" {
	use_code_fixture gometalinter fail

	run test/emulate-buildkite script/gometalinter

	[ $status -eq 1 ]

	assert_tap "${output}"
	assert_annotations "${output}"
}

@test "gometalinter: skips when no matching files" {
	use_code_fixture gometalinter skip

	run test/emulate-buildkite script/gometalinter

	# NOTE: there's no way to determine the skip case without an explicit
	# file list.
	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "gometalinter: config file exists" {
	use_code_fixture gometalinter config-file
	use_conf_fixture gometalinter config-file

	run test/emulate-buildkite script/gometalinter

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "gometalinter: test specific file ignored by config" {
	use_code_fixture gometalinter file-list-exclude
	use_conf_fixture gometalinter file-list-exclude

	set_test_files ignore.go valid.go

	run test/emulate-buildkite script/gometalinter

	# The configured options should make the failing fixture pass
	[ $status -eq 0 ]
	[ -n "${output}" ]
}

@test "gometalinter: file list should be skipped" {
	use_code_fixture gometalinter file-list-skip

	set_test_files junk.txt

	run test/emulate-buildkite script/gometalinter

	[ $status -eq 7 ]
}

@test "gometalinter: test commit files package" {
	use_code_fixture gometalinter pass

	set_test_files mypkg/mypkg.go

	run test/emulate-buildkite script/gometalinter

	[ $status -eq 0 ]
	[ -n "${output}" ]
}
