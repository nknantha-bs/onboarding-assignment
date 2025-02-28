# frozen_string_literal: true

require_relative '../game/game_score'

RSpec.describe GameScore do
  let(:score) { GameScore.new }

  describe '#calculate_points' do
    context 'when there are scoring values' do
      it 'calculates points for a triplet' do
        expect(score.calculate_points([1, 1, 1, 6, 3])).to eq([1000, 3])
      end

      it 'calculates points with single values' do
        expect(score.calculate_points([6, 5, 1, 2, 4])).to eq([150, 2])
      end
    end

    context 'when there are no scoring values' do
      it 'calculate points with non scoring values' do
        expect(score.calculate_points([2, 6, 4, 2, 3, 6])).to eq([0, 0])
      end

      it 'calculate points with no values' do
        expect(score.calculate_points([])).to eq([0, 0])
      end
    end
  end
end
