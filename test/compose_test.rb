# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

class PipelineTest < MiniTest::Test
  COMPOSE_FILE = 'docker-compose.yml'.freeze

  attr_reader :services

  def setup
    data = YAML.safe_load(File.new(COMPOSE_FILE))
    @services = data.fetch('services').reject do |name, _config|
      name == 'api'
    end
  end

  def test_check_images
    services.each_pair do |name, data|
      assert data.dig('image'), "#{name} missing image"

      assert_match %r{^teamci/\w+:v\d\.\d.\d$}, data.dig('image'), "#{name} image incorrect"
    end
  end

  def test_check_environment
    services.each_pair do |name, data|
      environment = data.fetch('environment')

      assert_nil environment.fetch('TEAMCI_REPO_SLUG'), 'TEAMCI_REPO_SLUG not set'
      assert_nil environment.fetch('TEAMCI_COMMIT'), 'TEAMCI_COMMIT not set'
    end
  end
end
