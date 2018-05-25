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
  when "error", 'fatal' then 'failure'
  when 'warning' then 'warning'
  else 'notice'
  end
end

report = JSON.parse($stdin.read)

files = report.fetch('files')

$stdout.puts('--- TAP')
$stdout.puts("1..#{files.size}")

files.each_with_index do |data, i|
  path = data.fetch('path')
  offenses = data.fetch('offenses')

  if offenses.empty?
    $stdout.puts("ok #{i + 1} - #{path}")
  else
    $stdout.puts("not ok #{i + 1} - #{path}")
    annotations = offenses.map do |offense|
      {
        'filename' => path,
        'blob_href' => blob_url(path),
        'start_line' => offense.fetch('location').fetch('line'),
        'end_line' => offense.fetch('location').fetch('line'),
        'warning_level' => warning_level(offense.fetch('severity')),
        'message' => offense.fetch('message'),
        'title' => "Rubocop #{offense.fetch('cop_name')}"
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
