#!/usr/bin/env ruby

$stdout.sync = true
$stderr.sync = true

require 'json'
require 'yaml'

def blob_url(file_name)
  format('https://github.com/%<slug>s/blob/%<commit>s/%<file>s', {
    slug: ENV.fetch('TEAMCI_REPO_SLUG'),
    commit: ENV.fetch('TEAMCI_COMMIT'),
    file: file_name
  })
end

def warning_level(level)
  case level
  when 'warning' then 'warning'
  when 'error' then 'failure'
  else 'notice'
  end
end

input_files = File.read(ARGV[0]).lines.map(&:chomp)
error_results = Array(JSON.parse($stdin.read))

$stdout.puts('--- TAP')
$stdout.puts("1..#{input_files.size}")

input_files.each_with_index do |file_name, i|
  errors = error_results.select do |result|
    result.fetch('file') == file_name
  end

  if errors.empty?
    $stdout.puts("ok #{i + 1} - #{file_name}")
  else
    $stdout.puts("not ok #{i + 1} - #{file_name}")
    annotations = errors.map do |error|
      {
        'filename' => file_name,
        'blob_href' => blob_url(file_name),
        'start_line' => error.fetch('line'),
        'end_line' => error.fetch('line'),
        'warning_level' => warning_level(error.fetch('level')),
        'message' => error.fetch('message'),
        'title' => "Rule ##{error.fetch('code')}"
      }
    end
    yaml = YAML.dump(annotations).lines.map do |line|
      "  #{line}" # prepend two spaces for tap correctness
    end
    yaml << '  ...'
    $stdout.puts(yaml.join)
  end
end

$stdout.puts('--- TAP')
