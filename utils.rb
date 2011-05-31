require 'constants'

module MyTeacherUtils

  include Constants

  def symbol_to_piece(sym)
    SYMBOLS.index(sym)
  end

  def case_to_index(c)
    SQUARENAME.index(c)
  end

end

