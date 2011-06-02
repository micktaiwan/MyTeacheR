require 'constants'

module MyTeacherUtils

  include Constants

  def symbol_to_piece(sym)
    SYMBOLS.index(sym)
  end

  def case_to_index(c)
    SQUARENAME.index(c)
  end

  def time_it
    t = Time.now
    rv = yield
    puts Time.now-t
    rv
  end

end

