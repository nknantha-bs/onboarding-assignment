# frozen_string_literal: true

require_relative 'game/game'

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.run
end
