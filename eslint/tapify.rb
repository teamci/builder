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
  when 2 then 'failure'
  else 'warning'
  end
end

report = JSON.parse($stdin.read)

$stdout.puts('--- TAP')
$stdout.puts("1..#{report.size}")

report.each_with_index do |data, i|
  path = data.fetch('filePath')
  messages = data.fetch('messages')

  if messages.empty?
    $stdout.puts("ok #{i + 1} - #{path}")
  else
    $stdout.puts("not ok #{i + 1} - #{path}")
    annotations = messages.map do |message|
      {
        'filename' => path,
        'blob_href' => blob_url(path),
        'start_line' => message.fetch('line'),
        'end_line' => message.key?('endLine') ? message.fetch('endLine') : message.fetch('line'),
        'warning_level' => warning_level(message.fetch('severity')),
        'message' => message.fetch('message'),
        'title' => "ESLint #{message.fetch('ruleId')}"
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
