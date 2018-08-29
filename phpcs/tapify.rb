#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'json'
require 'yaml'

def annotation_level(level)
  case level.downcase
  when 'error' then 'failure'
  else 'warning'
  end
end

report = JSON.parse($stdin.read)
files = report.fetch('files')

$stdout.puts('--- TAP')
$stdout.puts("1..#{files.keys.size}")

files.each_with_index do |(path, data), i|
  # Don't ask me why, but it seems / is escaped in the output. PHP?
  file_name = path.gsub('\/', '/').gsub(%r{^/}, '')

  if data.fetch('errors').zero?
    $stdout.puts("ok #{i + 1} - #{file_name}")
  else
    $stdout.puts("not ok #{i + 1} - #{file_name}")

    annotations = data.fetch('messages').map do |entry|
      {
        'path' => file_name,
        'start_line' => entry.fetch('line'),
        'end_line' => entry.fetch('line'),
        'annotation_level' => annotation_level(entry.fetch('type')),
        'message' => entry.fetch('message'),
        'title' => "phpcs: #{entry.fetch('source')}"
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
