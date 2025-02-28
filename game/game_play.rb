# frozen_string_literal: true

# This module contains the game play logic.
# It depends on the DiceSet, Player, GamePlayers, GameScore, and GameConfig modules.

require_relative 'dice_set'
require_relative 'player'
require_relative 'game_players'
require_relative 'game_score'
require_relative 'game_config'

class GamePlay
  def initialize
    @dice = DiceSet.new
    @players = GamePlayers.new
    @score = GameScore.new
  end

  # It executes a turn for a given player.
  # And update the player points.
  #
  # @param player [Player] Player object.
  def play_round(player)
    dice_count = GameConfig::TOTAL_DICE_COUNT
    round_points = 0

    puts
    loop do
      dice_values = @dice.roll(dice_count)
      roll_points, used_dice_count = @score.calculate_points(dice_values)
      round_points += roll_points

      puts "\"#{player.name}\" rolls: #{dice_values}"
      puts "Roll points: #{roll_points}"
      puts "Current round points: #{round_points}"
      puts "Total points: #{player.points}"

      if roll_points.zero?
        puts 'Oops! No points this round.'
        round_points = 0
        break
      end

      dice_count -= used_dice_count
      dice_count = GameConfig::TOTAL_DICE_COUNT if dice_count.zero?

      print "Roll again with non-scored #{dice_count} dice? (y/n): "
      response = gets.chomp
      break if response == 'n'
    end

    @players.update_points_for(player, round_points)
  end

  # It is the entry point of the game.
  def run
    @players.create_players

    current_round = 0
    player_index = 0
    final_round_index = -1

    # Loop until all players have reached the final round threshold
    while final_round_index == -1
      puts "\nRound #{current_round += 1}:\n#{'-' * 15}" if player_index.zero?

      current_player = @players[player_index]
      play_round(current_player)

      final_round_index = player_index if current_player.points >= GameConfig::FINAL_ROUND_THRESHOLD

      player_index = (player_index + 1) % @players.length
    end

    # Final round loop
    puts "\nFinal round:\n#{'-' * 15}"
    while player_index != final_round_index
      play_round(@players[player_index])
      player_index = (player_index + 1) % @players.length
    end

    puts "\nFinal score:\n#{'-' * 15}"
    @players.display_score
  end
end
