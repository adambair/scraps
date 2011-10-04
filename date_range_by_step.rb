module DateDefaults
  def self.defaults
    defaults = OpenStruct.new
    defaults.from_date = default_from_date
    defaults.to_date = default_to_date
    defaults
  end

  def self.default_from_date
    default_date - 1.year
  end

  def self.default_to_date
    default_date - 1.day
  end

  # Billing starts on the 1st, 5th, 10th, 15th, 20th, and 25th of each month
  # Round today's date into one of those dates.
  def self.default_date(date=Date.today)
    #possible_starts = [1..4] + (5..20).step(5).collect {|x| (x..x+4)} + [25..31]
    possible_starts = [1..4, 5..9, 10..14, 15..19, 20..24, 25..31]
    start_range = possible_starts.select {|x| x.include? date.day}.first
    Date.parse [date.month, start_range, date.year].join('/')
  end
end
