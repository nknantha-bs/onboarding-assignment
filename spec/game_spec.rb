# frozen_string_literal: true

require_relative '../game/game'

RSpec.describe Game do
  let(:game) { Game.new }

  describe '#create_players' do
    it 'creates number of players based on user input' do
      allow(game).to receive(:gets).and_return('2', 'Alpha', 'Beta')
      players = game.create_players
      expect(players.size).to eq(2)
      expect(players[0].name).to eq('Alpha')
      expect(players[1].name).to eq('Beta')
    end
  end

  describe '#calculate_points' do
    context 'when there are scoring values' do
      it 'calculates points for a triplet' do
        expect(game.calculate_points([1, 1, 1, 6, 3])).to eq([1000, 3])
      end

      it 'calculates points with single values' do
        expect(game.calculate_points([6, 5, 1, 2, 4])).to eq([150, 2])
      end
    end

    context 'when there are no scoring values' do
      it 'calculate points with non scoring values' do
        expect(game.calculate_points([2, 6, 4, 2, 3, 6])).to eq([0, 0])
      end

      it 'calculate points with no values' do
        expect(game.calculate_points([])).to eq([0, 0])
      end
    end
  end

  describe '#update_player_points' do
    let(:player) { Player.new('Alpha') }

    context 'when points are less than threshold' do
      it 'does not update the player points' do
        game.update_player_points(player, 100)
        expect(player.points).to eq(0)
      end
    end

    context 'when points are greater than threshold' do
      it 'updates the player points' do
        game.update_player_points(player, 1000)
        expect(player.points).to eq(1000)
      end
    end
  end

  describe '#execute_turn_for' do
    let(:player) { Player.new('Alpha') }

    context 'when player rolls scoring values' do
      it 'accumulate the points and return' do
        allow(game).to receive(:calculate_points).and_return([1000, 3], [150, 2])
        allow(game).to receive(:gets).and_return('y', 'n')
        expect(game.execute_turn_for(player)).to eq(1150)
      end

      it 'should return 0 points if consecutive rolls are not scoring' do
        allow(game).to receive(:calculate_points).and_return([1000, 3], [0, 0])
        allow(game).to receive(:gets).and_return('y')
        expect(game.execute_turn_for(player)).to eq(0)
      end

      it 'should allow player to use all dice if all are scoring' do
        allow(game).to receive(:calculate_points).and_return([1000, 3], [1000, 2], [50, 1])
        allow(game).to receive(:gets).and_return('y', 'y', 'n')
        expect(game.execute_turn_for(player)).to eq(2050)
      end
    end

    context 'when player rolls no scoring values' do
      it 'return 0 points' do
        allow(game).to receive(:calculate_points).and_return([0, 0])
        expect(game.execute_turn_for(player)).to eq(0)
      end
    end
  end

  describe '#run' do
    it 'runs the game until completion' do
      allow(game).to receive(:create_players).and_return([Player.new('Alpha'), Player.new('Beta')])
      allow(game).to receive(:execute_turn_for).and_return(
        GameConfig::INITIAL_ROUND_THRESHOLD,
        GameConfig::INITIAL_ROUND_THRESHOLD,
        GameConfig::FINAL_ROUND_THRESHOLD,
        100
      )
      expect(game.run).not_to be_empty
    end
  end
end
