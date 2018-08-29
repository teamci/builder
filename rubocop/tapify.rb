#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'json'
require 'yaml'

def annotation_level(level)
  case level
  when 'error', 'fatal' then 'failure'
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
        'path' => path,
        'start_line' => offense.fetch('location').fetch('line'),
        'end_line' => offense.fetch('location').fetch('line'),
        'annotation_level' => annotation_level(offense.fetch('severity')),
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
