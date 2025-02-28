# frozen_string_literal: true

require_relative 'player'
require_relative 'game_config'

# This class responsible for player management.
class GamePlayers
  def initialize
    @players = []
  end

  def [](index)
    @players[index]
  end

  def length
    @players.length
  end

  # It creates number of players based on user input.
  def create_players
    @players = []
    print 'Enter number of players: '
    num_players = gets.chomp.to_i
    num_players.times do |i|
      print "Enter player #{i + 1} name: "
      name = gets.chomp
      @players.push(Player.new(name))
    end
  end

  # It check for the initial round threshold to let the player to get into the game.
  #
  # @param player [Player] Player object.
  # @param points [Integer] Points to be updated.
  def update_points_for(player, points)
    if player.points >= GameConfig::INITIAL_ROUND_THRESHOLD ||
       points >= GameConfig::INITIAL_ROUND_THRESHOLD

      player.points += points
    else
      puts 'Not enough points to get into the game.'
    end
  end

  def display_score
    sorted_players = @players.sort_by { |player| -player.points }
    sorted_players.each_with_index do |player, index|
      puts "#{index + 1}. #{player.name}: #{player.points} points"
    end
  end
end
