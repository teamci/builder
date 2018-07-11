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
  when 'error' then 'failure'
  else 'warning'
  end
end

report = JSON.parse($stdin.read)

$stdout.puts('--- TAP')
$stdout.puts("1..#{report.size}")

report.each_with_index do |data, i|
  file_name = data.fetch('source').gsub(%r{^/}, '')
  entries = data.fetch('warnings') + data.fetch('parseErrors')

  if entries.empty?
    $stdout.puts("ok #{i + 1} - #{file_name}")
  else
    $stdout.puts("not ok #{i + 1} - #{file_name}")

    annotations = entries.map do |entry|
      {
        'filename' => file_name,
        'blob_href' => blob_url(file_name),
        'start_line' => entry.fetch('line'),
        'end_line' => entry.fetch('line'),
        'warning_level' => warning_level(entry.fetch('severity')),
        'message' => entry.fetch('text'),
        'title' => "stylelint: #{entry.fetch('rule')}"
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
