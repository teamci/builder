use_code_fixture() {
	if [ -d "${FIXTURE_DIR}/${1}/code/${2}" ]; then
		buildkite-agent meta-data set 'teamci.repo.slug' "${1}/code"
		buildkite-agent meta-data set 'teamci.head_branch' "${2}"
	else
		echo "No fixture for ${1}/code/${2}" 1>&2
		return 1
	fi
}

use_conf_fixture() {
	if [ -d "${FIXTURE_DIR}/${1}/config/${2}" ]; then
		buildkite-agent meta-data set 'teamci.config.repo' "${1}/config"
		buildkite-agent meta-data set 'teamci.config.branch' "${2}"
	else
		echo "No fixture for ${1}/config/${2}" 1>&2
		return 1
	fi
}

use_empty_config() {
	buildkite-agent meta-data set 'teamci.config.repo' 'no-op/no-op'
	buildkite-agent meta-data set 'teamci.config.branch' 'no-op'
}

set_test_files() {
	local OPTIND
	local slug branch temp force

	while getopts ':f' opt; do
		case "${opt}" in
			f)
				force="true"
				;;
			\?)
				echo "Unknown option -${OPTARG}" 1>&2
				return 1
				;;
		esac
	done

	shift $((OPTIND-1))

	if ! buildkite-agent meta-data get 'teamci.repo.slug' > /dev/null; then
		echo "no repo set"
		return 1
	fi

	if ! buildkite-agent meta-data get 'teamci.head_branch' > /dev/null; then
		echo "no branch set"
		return 1
	fi

	slug="$(buildkite-agent meta-data get 'teamci.repo.slug')"
	branch="$(buildkite-agent meta-data get 'teamci.head_branch')"
	temp="$(mktemp)"

	if [ -z "${force:-}" ]; then
		for file in "$@"; do
			if [ ! -f "${FIXTURE_DIR}/${slug}/${branch}/${file}" ]; then
				echo "${file} is not declared in the fixture"
				return 1
			fi
		done
	fi

	for file in "$@"; do
		echo "[ \"${file}\" ]" >> "${temp}"
	done

	buildkite-agent \
		meta-data set \
		'teamci.check_suite.files' \
		"$(jq --slurp -r '. | flatten' "${temp}")"
}

assert_tap() {
	[ -n "${1}" ]
	[ "$(echo "${1}" | grep -cF -- '--- TAP')" -eq 2 ]
}

assert_annotations() {
	# Test for annotation keys
	echo "${1}" | grep -qE 'path: [^\.+\/]'
	echo "${1}" | grep -qF 'start_line:'
	echo "${1}" | grep -qF 'end_line:'
	echo "${1}" | grep -qF 'annotation_level:'
	echo "${1}" | grep -qF 'message:'
	echo "${1}" | grep -qF 'title:'
}

refute_tap() {
	[ -n "${1}" ]
	[ "$(echo "${1}" | grep -cF -- '--- TAP')" -eq 0 ]
}

setup() {
	# Wipe metadata
	buildkite-agent reset

	# Set common metadata
	buildkite-agent meta-data set 'teamci.access_token_url' "${TEAMCI_API_URL}"
	buildkite-agent meta-data set 'teamci.head_sha' 'HEAD'

	# Required metadata, but scripts continue if these cannot be cloned
	use_empty_config

	rm -rf "${TEAMCI_CODE_DIR}/"*
}
