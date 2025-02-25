# frozen_string_literal: true

# This module contains the Dice class.
# It is responsible for generating random dice values.

class Dice
  attr_reader :values

  def roll(num)
    @values = []
    num.times do
      @values.push(rand(1..6))
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  dice = Dice.new
  dice.roll(5)
  puts "Dice values: #{dice.values}"
end
