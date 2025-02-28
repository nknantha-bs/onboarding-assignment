# frozen_string_literal: true

require_relative '../game/dice_set'

RSpec.describe DiceSet do
  let(:dice_set) { DiceSet.new }

  describe '#roll' do
    it 'rolls the dice set and returns the values' do
      expect(dice_set.roll(5).length).to eq(5)
    end

    it 'rolls the dice set and returns the values between 1 and 6' do
      expect(dice_set.roll(5)).to all(be_between(1, 6))
    end
  end
end
