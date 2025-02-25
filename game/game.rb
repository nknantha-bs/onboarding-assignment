# frozen_string_literal: true

# This module contains the game logic and game config.
# It depends on the Dice and Player classes. It creates players and executes the game with the
# given user input.
#
# It contains the following classes:
# - GameConfig: It contains the game configuration constants.
# - Game: It contains the game logic.

require_relative 'dice'
require_relative 'player'

class GameConfig
  FINAL_ROUND_THRESHOLD = 3000
  INITIAL_ROUND_THRESHOLD = 300
  TOTAL_DICE_COUNT = 5
end

class Game
  SCORE_TABLE_TRIPLET = {
    1 => 1000,
    2 => 200,
    3 => 300,
    4 => 400,
    5 => 500,
    6 => 600
  }.freeze
  SCORE_TABLE_SINGLE = {
    1 => 100,
    5 => 50
  }.freeze

  def initialize
    @dice = Dice.new
  end

  # It creates number of players based on user input.
  #
  # @return [Array<Player>] Array of players.
  def create_players
    players = []
    print 'Enter number of players: '
    num_players = gets.chomp.to_i
    num_players.times do |i|
      print "Enter player #{i + 1} name: "
      name = gets.chomp
      players.push(Player.new(name))
    end

    players
  end

  # It uses SCORE_TABLE_TRIPLET and SCORE_TABLE_SINGLE to calculate points for a given set of
  # dice values.
  #
  # @param dice_values [Array<Integer>] Array of dice values.
  # @return [Array<Integer>] Points and used dice count for calculating points.
  def calculate_points(dice_values)
    points = 0
    used_dice_count = 0

    counter = Hash.new(0)
    dice_values.each do |dice_value|
      counter[dice_value] += 1
    end

    counter.each do |dice_value, count|
      if count >= 3
        points += Game::SCORE_TABLE_TRIPLET[dice_value]
        count -= 3
        used_dice_count += 3
      end

      if Game::SCORE_TABLE_SINGLE.key?(dice_value)
        points += Game::SCORE_TABLE_SINGLE[dice_value] * count
        used_dice_count += count
      end
    end

    [points, used_dice_count]
  end

  # It executes a turn for a given player.
  #
  # @param player [Player] Player object.
  # @return [Integer] Points scored in the turn.
  def execute_turn_for(player)
    dice_count = GameConfig::TOTAL_DICE_COUNT
    current_round_points = 0

    puts
    loop do
      @dice.roll(dice_count)
      current_roll_points, used_dice_count = calculate_points(@dice.values)
      current_round_points += current_roll_points

      puts "\"#{player.name}\" rolls: #{@dice.values}"
      puts "Roll points: #{current_roll_points}"
      puts "Current round points: #{current_round_points}"
      puts "Total points: #{player.points}"

      if current_roll_points.zero?
        puts 'Oops! No points this round.'
        current_round_points = 0
        break
      end

      if used_dice_count == dice_count
        dice_count = GameConfig::TOTAL_DICE_COUNT
      else
        dice_count -= used_dice_count
      end

      if dice_count.zero?
        puts 'All dice used. No more rolls.'
        break
      end

      print "Roll again with non-scored #{dice_count} dice? (y/n): "
      response = gets.chomp
      break if response == 'n'
    end
    current_round_points
  end

  # It displays the final result of the game.
  #
  # @param players [Array<Player>] Array of players.
  def complete_game(players)
    puts "\nGame over!\n#{'-' * 15}"
    players.sort_by! { |player| -player.points }
    players.each_with_index do |player, index|
      puts "#{index + 1}. #{player.name}: #{player.points} points"
    end
  end

  # It check for the initial round threshold to let the player to get into the game.
  #
  # @param player [Player] Player object.
  # @param current_round_points [Integer] Points scored in the current round.
  def update_player_points(player, current_round_points)
    if player.points >= GameConfig::INITIAL_ROUND_THRESHOLD ||
       current_round_points >= GameConfig::INITIAL_ROUND_THRESHOLD

      player.points += current_round_points
    else
      puts 'Not enough points to get into the game.'
    end
  end

  # It is the entry point of the game.
  def run
    players = create_players

    current_round = 1
    player_index = 0
    final_round_player_index = -1
    loop do
      if final_round_player_index != -1
        puts "\nFinal round!\n#{'-' * 15}"
      elsif player_index.zero?
        puts "\nRound #{current_round}:\n#{'-' * 15}"
        current_round += 1
      end

      current_player = players[player_index]
      current_round_points = execute_turn_for(current_player)

      update_player_points(current_player, current_round_points)

      if final_round_player_index == -1 &&
         current_player.points >= GameConfig::FINAL_ROUND_THRESHOLD
        final_round_player_index = player_index
      end

      player_index = (player_index + 1) % players.length
      break if final_round_player_index == player_index
    end

    complete_game(players)
  end
end
