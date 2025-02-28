# frozen_string_literal: true

require_relative 'game/game_play'

if __FILE__ == $PROGRAM_NAME
  game = GamePlay.new
  game.run
end
