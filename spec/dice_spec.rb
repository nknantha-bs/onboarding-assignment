# frozen_string_literal: true

require_relative '../game/dice'

RSpec.describe Dice do
  let(:dice) { Dice.new }

  describe '#roll' do
    it 'rolls the dice and returns the values' do
      dice.roll(5)
      expect(dice.values.size).to eq(5)
    end

    it 'rolls the dice and returns the values between 1 and 6' do
      dice.roll(5)
      expect(dice.values).to all(be_between(1, 6))
    end
  end
end
