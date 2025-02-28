# frozen_string_literal: true

# This module contains the Dice class.
# It is responsible for generating random dice values.

class DiceSet
  # It generates random dice values based on the number of dice and returns it.
  #
  # @param num [Integer] Number of dice to roll.
  # @return [Array<Integer>] Array of dice values.
  def roll(num)
    values = []
    num.times do
      values.push(rand(1..6))
    end
    values
  end
end
