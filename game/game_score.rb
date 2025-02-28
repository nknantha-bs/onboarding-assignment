# frozen_string_literal: true

class GameScore
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
        points += SCORE_TABLE_TRIPLET[dice_value]
        count -= 3
        used_dice_count += 3
      end

      single_score = SCORE_TABLE_SINGLE[dice_value]
      if single_score
        points += single_score * count
        used_dice_count += count
      end
    end

    [points, used_dice_count]
  end
end
