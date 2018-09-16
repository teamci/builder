# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'
require 'json'

class PipelineTest < MiniTest::Test
  PIPELINE_FILE = '.buildkite/pipeline.yml'
  TITLES_FILE = 'titles.json'

  attr_reader :pipeline, :titles

  def setup
    @pipeline = YAML.safe_load(File.new(PIPELINE_FILE))
    @titles = JSON.parse(File.read(TITLES_FILE))
  end

  def test_timeout
    assert pipeline.dig('env', 'BUILDKITE_TIMEOUT'), 'timeout missing'
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

  def test_title_for_pipeline_steps
    pipeline.fetch('steps').each do |entry|
      name = entry.fetch('label')
      assert titles.dig(name), "#{name} missing title entry"
    end
  end
end
