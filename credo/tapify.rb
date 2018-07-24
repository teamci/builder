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
  case level.downcase
  when 'w' then 'failure'
  else 'warning'
  end
end

report = $stdin.read.lines

if report.empty?
  exit
end

$stdout.puts('--- TAP')
$stdout.puts("1..#{report.size}")

report.each_with_index do |data, i|
  result = data.match(/^(?<file>[^:]+):(?<line>\d+):\d+:\d*\s(?<level>[A-Z]):\s(?<msg>.+)$/)
  file_name = result[:file]

  $stdout.puts("not ok #{i + 1} - #{file_name}")

  annotation = {
    'filename' => file_name,
    'blob_href' => blob_url(file_name),
    'start_line' => result[:line].to_i,
    'end_line' => result[:line].to_i,
    'warning_level' => warning_level(result[:level]),
    'message' => result[:msg],
    'title' => 'Credo check failed'
  }

  yaml = YAML.dump(annotation).lines.map do |line|
    "  #{line}" # prepend two spaces for tap correctness
  end
  yaml << '  ...'
  $stdout.puts(yaml.join)
end

$stdout.puts('--- TAP')
