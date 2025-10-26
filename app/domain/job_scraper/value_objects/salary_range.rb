module Domain
  module JobScraper
    module ValueObject
      class SalaryRange
        attr_reader :min, :max

        def initialize(min: nil, max: nil)
          @min = min
          @max = max
        end

        def to_s
          return "#{@min}万円〜" if @min && !@max
          return "#{@max}万円以下" if @max && !@min
          return "#{@min}万円〜#{@max}万円" if @min && @max
          "要相談"
        end

        def includes?(amount)
          return false unless amount
          return amount >= @min if @min && !@max
          return amount <= @max if @max && !@min
          return amount >= @min && amount <= @max if @min && @max
          true
        end

        def valid?
          return true if @min.nil? || @max.nil?
          @min <= @max
        end
      end
    end
  end
end
