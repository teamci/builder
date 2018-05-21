class Report
	def initialize
		@results = [ ]
	end

	def test(name, &block)
		begin
			yield
			@results << [ :ok, name, nil ]
		rescue => ex
			@results << [ :fail, name, ex.message ]
		end
	end

  def skip(name)
    @results << [ :skip, name ]
  end

	def passed?
		!@results.any? do |(outcome, _name, _message)|
			outcome == :fail
		end
	end

  def neutral?
		@results.all? do |(outcome, _name, _message)|
			outcome == :skip
		end
  end

	def to_s
		lines = [ ]
		lines << "1..%d" % [ @results.length ]

		@results.each_with_index do |(outcome, name, message), i|
			if outcome == :ok
				lines << "%s %d - %s" % [ 'ok', i + 1, name ]
      elsif outcome == :skip
        lines << "%s %d - # SKIP %s" % [ 'ok', i + 1, name ]
      elsif outcome == :fail
				lines << "%s %d - %s" % [ 'not ok', i + 1, name ]
				message.lines.each do |line|
					lines << "# %s" % [ line.chomp ]
				end
      else
        fail "Unexpected outcome: #{outcome}"
      end
		end

		lines.join("\n")
	end
end
