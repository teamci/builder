# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'

class PipelineTest < MiniTest::Test
  COMPOSE_FILE = 'docker-compose.yml'
  TAGGED_IMAGE = %r{^teamci/\w+:v\d\.\d.\d$}

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

      assert_match TAGGED_IMAGE, data.dig('image'), "#{name} image incorrect"
    end
  end

  def test_check_environment
    services.each_pair do |name, data|
      env = data.fetch('environment')

      assert_env 'TEAMCI_REPO_SLUG', env, name
      assert_env 'TEAMCI_COMMIT', env, name
    end
  end

  def assert_env(key, data, name)
    assert_nil data.fetch(key), "#{name} missing #{key}"
  end
end
