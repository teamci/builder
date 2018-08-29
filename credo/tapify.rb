#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'json'
require 'yaml'

FORMAT = /^(?<file>[^:]+):(?<line>\d+):\d+:\d*\s(?<level>[A-Z]):\s(?<msg>.+)$/

def annotation_level(level)
  case level.downcase
  when 'w' then 'failure'
  else 'warning'
  end
end

report = $stdin.read.lines.select do |output|
  output =~ FORMAT
end

exit if report.empty?

$stdout.puts('--- TAP')
$stdout.puts("1..#{report.size}")

report.each_with_index do |data, i|
  result = data.match(FORMAT)
  file_name = result[:file]

  $stdout.puts("not ok #{i + 1} - #{file_name}")

  annotation = {
    'path' => file_name,
    'start_line' => result[:line].to_i,
    'end_line' => result[:line].to_i,
    'annotation_level' => annotation_level(result[:level]),
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
