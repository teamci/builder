# frozen_string_literal: true

class Report
  def initialize
    @results = []
  end

  def test(name)
    yield
    @results << [ :ok, name, nil ]
  rescue StandardError => ex
    @results << [ :fail, name, ex.message ]
  end

  def skip(name)
    @results << [ :skip, name ]
  end

  def passed?
    @results.none? do |(outcome, _name, _message)|
      outcome == :fail
    end
  end

  def neutral?
    @results.all? do |(outcome, _name, _message)|
      outcome == :skip
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def to_s
    lines = []
    lines << '--- TAP'
    lines << format('1..%<total>d', total: @results.length)

    @results.each_with_index do |(outcome, name, message), i|
      if outcome == :ok
        lines << format('%<result>s %<number>d - %<name>s', {
          result: 'ok',
          number: i + + 1,
          name: name
        })
      elsif outcome == :skip
        lines << format('%<result>s %<number>d - # SKIP %<name>s', {
          result: 'ok',
          number: i + + 1,
          name: name
        })
      elsif outcome == :fail
        lines << format('%<result>s %<number>d - %<name>s', {
          result: 'not ok',
          number: i + + 1,
          name: name
        })
        message.lines.each do |line|
          lines << format('# %<text>s', text: line.chomp)
        end
      else
        raise "Unexpected outcome: #{outcome}"
      end
    end

    lines << '--- TAP'

    lines.join("\n")
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
