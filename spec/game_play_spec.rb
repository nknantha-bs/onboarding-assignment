# frozen_string_literal: true

require_relative '../game/game_play'

RSpec.describe GamePlay do
  let(:game_play) { GamePlay.new }

  describe '#play_round' do
    let(:player) { Player.new('Alpha') }

    context 'when player rolls scoring values' do
      it 'accumulate the points and return' do
        allow_any_instance_of(GameScore).to receive(:calculate_points).and_return([1000, 3], [150, 2])
        allow(game_play).to receive(:gets).and_return('y', 'n')
        game_play.play_round(player)
        expect(player.points).to eq(1150)
      end

      it 'should update 0 points if consecutive rolls are not scoring' do
        allow_any_instance_of(GameScore).to receive(:calculate_points).and_return([1000, 3], [0, 0])
        allow(game_play).to receive(:gets).and_return('y')
        game_play.play_round(player)
        expect(player.points).to eq(0)
      end

      it 'should allow player to use all dice if all are scoring' do
        allow_any_instance_of(GameScore).to receive(:calculate_points).and_return([1000, 3], [1000, 2], [50, 1])
        allow(game_play).to receive(:gets).and_return('y', 'y', 'n')
        game_play.play_round(player)
        expect(player.points).to eq(2050)
      end
    end

    context 'when player rolls no scoring values' do
      it 'should update 0 points' do
        allow_any_instance_of(GameScore).to receive(:calculate_points).and_return([0, 0])
        game_play.play_round(player)
        expect(player.points).to eq(0)
      end
    end
  end

  describe '#run' do
    it 'should run and complete the game' do
      allow_any_instance_of(GamePlayers).to receive(:gets).and_return('2', 'Alpha', 'Beta')
      allow(game_play).to receive(:play_round).with(any_args).and_return(nil)
      allow_any_instance_of(Player).to receive(:points).and_return(
        0, 1000, 1000, GameConfig::FINAL_ROUND_THRESHOLD, 2000
      )
      game_play.run
    end
  end
end
