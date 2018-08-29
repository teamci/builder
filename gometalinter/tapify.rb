#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'json'
require 'yaml'

def annotation_level(level)
  case level
  when 'error' then 'failure'
  else 'warning'
  end
end

report = JSON.parse($stdin.read)

$stdout.puts('--- TAP')
$stdout.puts("1..#{report.size}")

report.each_with_index do |data, i|
  path = data.fetch('path')
  message = data.fetch('message')

  $stdout.puts("not ok #{i + 1} - #{path}")
  annotation = {
    'path' => path,
    'start_line' => data.fetch('line'),
    'end_line' => data.fetch('line'),
    'annotation_level' => annotation_level(data.fetch('severity')),
    'message' => message,
    'title' => "gometalinter: #{data.fetch('linter')}"
  }
  yaml = YAML.dump(annotation).lines.map do |line|
    "  #{line}" # prepend two spaces for tap correctness
  end
  yaml << '  ...'
  $stdout.puts(yaml.join)
end

$stdout.puts('--- TAP')
