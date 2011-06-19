require 'constants'

class Move
  include Constants
  include MyTeacherUtils

        attr_accessor :piece, :from, :to, :capture, :promotion, :can_castle, :enpassant

  def initialize(piece=nil, from=nil, to=nil, capture=nil, promotion=nil, can_castle=nil, enpassant=nil)
                @piece      = piece # WKING to BPAWN
    @from       = from
    @to         = to
                @capture    = capture # WKING to BPAWN
                @promotion  = promotion # WQUEEN..WBISHOP AND BQUEEN..BBISHOP
                @can_castle = can_castle
                @enpassant  = enpassant
  end

  def set(from, to)
    @from, @to = from, to
  end

  def to_s(notation=:legible) # FIXME: promotion can be upcase or downcase, is it a good notation principle ?
    case notation
    when :legible
      "#{piece_to_symbol(@piece)}#{SQUARENAME[@from]}#{@capture == nil ? "":"x"}#{SQUARENAME[@to]}#{@promotion ? SYMBOLS[@promotion].upcase : ""}"
    when :xboard
      "#{SQUARENAME[@from]}#{SQUARENAME[@to]}#{@promotion ? SYMBOLS[@promotion].upcase : ""}"
    end
  end

  #"#{m.to_s}: capture=#{m.capture.to_s}, promotion=#{m.promotion.to_s}"

  def ==(b)
    @from == b.from and @to == b.to and @piece == b.piece and @capture == b.capture and
    @promotion == b.promotion and @can_castle == b.can_castle
  end

  def score
    return 0 if promotion != nil
    return 1 if capture != nil
    return 2
  end

  #def inverse
  #  m             = Move.new
        #       m.piece       = @piece
  #  m.from        = @to
  #  m.to          = @from
        #       m.capture     = @capture
        #       m.promotion   = @promotion
        #       m
  #end

end

