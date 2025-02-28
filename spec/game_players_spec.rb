# frozen_string_literal: true

require_relative '../game/game_players'

RSpec.describe GamePlayers do
  let(:players) { GamePlayers.new }

  describe '#create_players' do
    it 'creates number of players based on user input' do
      allow(players).to receive(:gets).and_return('2', 'Alpha', 'Beta')
      players.create_players
      expect(players.length).to eq(2)
      expect(players[0].name).to eq('Alpha')
      expect(players[1].name).to eq('Beta')
    end
  end

  describe '#update_points_for' do
    let(:player) do
      allow(players).to receive(:gets).and_return('1', 'Alpha')
      players.create_players
      players[0]
    end

    context 'when points are less than threshold' do
      it 'does not update the player points' do
        players.update_points_for(player, 100)
        expect(player.points).to eq(0)
      end
    end

    context 'when points are greater than threshold' do
      it 'updates the player points' do
        players.update_points_for(player, 1000)
        expect(player.points).to eq(1000)
      end
    end
  end
end
