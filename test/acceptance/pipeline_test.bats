load test_helper

generate_pipeline() {
	run .buildkite/pipeline

	[ $status -eq 0 ]

	buildkite-agent meta-data get pipeline > /dev/null

	run test/support/yml2json <(buildkite-agent meta-data get pipeline)

	[ $status -eq 0 ]

	assert_pipeline "${output}"
}

assert_pipeline() {
	local data="${1}"

	while read -r label; do
		jq -re ".${label}" titles.json > /dev/null
	done < <(echo "${data}" | jq -re '.steps | map(.label)[]')

	while read -r script; do
		[ -f "${script}" ]
		[ -x "${script}" ]
	done < <(echo "${data}" | jq -re '.steps | map(.command)[]')

	echo "${data}" | jq -re '.env.BUILDKITE_TIMEOUT' > /dev/null
}

@test "pipeline: no whitelist" {
	use_code_fixture pipeline noop
	use_conf_fixture pipeline no-whitelist

	generate_pipeline

	local all_checks="$(jq -re '. | length' 'titles.json')"
	local steps="$(echo "${output}" | jq -re '.steps | length')"

	[ "${all_checks}" -eq "${steps}" ]

	assert_pipeline "${output}"
}

@test "pipeline: whitelist" {
	use_code_fixture pipeline noop
	use_conf_fixture pipeline whitelist

	generate_pipeline

	local steps="$(echo "${output}" | jq -re '.steps | length')"

	[ "${steps}" -eq 2 ]

	# Test the includes steps are in the whitelist
	while read -r label; do
		grep -qF "${label}" "${TEAMCI_CODE_DIR}/pipeline/config/whitelist"
	done < <(echo "${output}" | jq -re '.steps | map(.label)[]')
}

@test "pipeline: invalid check" {
	use_code_fixture pipeline noop
	use_conf_fixture pipeline invalid-check

	generate_pipeline

	local steps="$(echo "${output}" | jq -re '.steps | length')"

	[ "${steps}" -eq 1 ]

	# Test the includes steps are in the whitelist
	while read -r label; do
		grep -qF "${label}" "${TEAMCI_CODE_DIR}/pipeline/config/whitelist"
	done < <(echo "${output}" | jq -re '.steps | map(.label)[]')
}

@test "pipeline: all invalid" {
	use_code_fixture pipeline noop
	use_conf_fixture pipeline all-invalid

	generate_pipeline

	local all_checks="$(jq -re '. | length' 'titles.json')"
	local steps="$(echo "${output}" | jq -re '.steps | length')"

	[ "${all_checks}" -eq "${steps}" ]
}
