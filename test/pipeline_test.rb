# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

class PipelineTest < MiniTest::Test
  PIPELINE_FILE = '.buildkite/pipeline.yml'.freeze

  attr_reader :pipeline

  def setup
    @pipeline = YAML.safe_load(File.new(PIPELINE_FILE))
  end

  def test_scripts
    pipeline.fetch('steps').each do |entry|
      command = entry.dig('command')

      assert File.exist?(command), "no such file: #{command}"
      assert File.executable?(command), "#{command} is not executable"
    end
  end

  def test_pipline_calls_all_check_scripts
    Dir['script/*'].each do |script|
      step = pipeline.fetch('steps').find do |entry|
        entry.dig('command') == script
      end

      assert step, "No step for: #{script}"
    end
  end
end
