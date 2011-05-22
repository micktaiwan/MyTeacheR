require 'constants'

class Move
  include Constants

	attr_accessor :piece, :from, :to, :capture, :promotion, :can_castle

  def initialize(piece=nil, from=nil, to=nil, capture=nil, promotion=nil, can_castle=nil)
		@piece      = piece # WKING to BPAWN
    @from       = from
    @to         = to
		@capture    = capture # WKING to BPAWN
		@promotion  = promotion # WQUEEN..WBISHOP AND BQUEEN..BBISHOP
		@can_castle = can_castle
  end

  def set(from, to)
    @from, @to = from, to
  end

  def to_s
    "#{SQUARENAME[@from]}#{SQUARENAME[@to]}" + (@promotion ? SYMBOLS[@promotion] : "")
  end

  def ==(b)
    @from == b.from and @to == b.to and @piece == b.piece and @capture == b.capture and
    @promotion == b.promotion and @can_castle == b.can_castle
  end

  #def inverse
  #  m             = Move.new
	#	m.piece       = @piece
  #  m.from        = @to
  #  m.to          = @from
	#	m.capture     = @capture
	#	m.promotion   = @promotion
	#	m
  #end

end

