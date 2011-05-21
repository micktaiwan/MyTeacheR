require 'constants'

class Move
  include Constants

	attr_accessor :piece, :from, :to, :capture, :promotion

  def initialize(piece=nil, from=nil, to=nil, capture=nil, promotion=nil)
		@piece      = piece
    @from       = from
    @to         = to
		@capture    = capture
		@promotion  = promotion
		#@forward    = (@piece == WPAWN and @to == 8 or @piece == BPAWN and @to == 1)
		# if forward, then @from is the @piece, @promotion is the target on @to
		# if !forward, the move is backward (!) and @piece is the origin
  end

  def set(from, to)
    @from, @to = from, to
  end

  def to_s
    "#{SQUARENAME[@from]}#{SQUARENAME[@to]}" + (@promotion ? SYMBOLS[@promotion] : "")
  end

  def ==(b)
    @from == b.from and @to == b.to and @piece == b.piece and @capture == b.capture and
    @promotion == b.promotion
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

