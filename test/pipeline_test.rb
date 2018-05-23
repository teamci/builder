require 'minitest/autorun'
require 'yaml'

class PipelineTest < MiniTest::Test
  PIPELINE_FILE = '.buildkite/pipeline.yml'

  attr_reader :pipeline

  def setup
    @pipeline = YAML.load(File.new(PIPELINE_FILE))
  end

  def test_scripts
    pipeline.fetch('steps').each do |entry|
      command = entry.dig('command')

      assert File.exists?(command), "no such file: #{command}"
      assert File.executable?(command), "#{command} is not executable"
    end
  end
end
