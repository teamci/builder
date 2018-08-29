#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'json'
require 'yaml'

def annotation_level(level)
  case level
  when 2 then 'failure'
  else 'warning'
  end
end

def end_line(msg)
  msg.key?('endLine') ? msg.fetch('endLine') : msg.fetch('line')
end

# Reject warnings about explicit files matching ignore rules
report = JSON.parse($stdin.read).reject do |entry|
  entry.fetch('messages').any? do |data|
    data.fetch('message').include?('--no-ignore')
  end
end

$stdout.puts('--- TAP')
$stdout.puts("1..#{report.size}")

report.each_with_index do |data, i|
  path = data.fetch('filePath')
  messages = data.fetch('messages')

  if messages.empty?
    $stdout.puts("ok #{i + 1} - #{path}")
  else
    $stdout.puts("not ok #{i + 1} - #{path}")
    annotations = messages.map do |msg|
      {
        'path' => path,
        'start_line' => msg.fetch('line'),
        'end_line' => end_line(msg),
        'annotation_level' => annotation_level(msg.fetch('severity')),
        'message' => msg.fetch('message'),
        'title' => "ESLint #{msg.fetch('ruleId')}"
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
