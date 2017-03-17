class Stars
  FULL_STAR = '★ '
  HALF_STAR = '✭ '
  EMPTY_STAR = '☆ '

  def self.generate(rating)
    rating = 0 unless rating

    if self.is_float?(rating)
      half_star = 1
      full_star = rating - 0.5
    else
      half_star = 0
      full_star = rating
    end

    empty_star = 5 - full_star - half_star

    "#{FULL_STAR * full_star}#{HALF_STAR * half_star}#{EMPTY_STAR * empty_star}"
  end

  private

  def self.is_float?(rating)
    !((rating - rating.floor) == 0)
  end
end
