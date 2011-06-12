require 'position'
require 'eval'
require 'stats'

class IllegalMoveException < RuntimeError
end

class Search

  include Constants

  attr_reader :move, :position, :done, :stats, :score
  attr_accessor :debug

  def initialize(position, stats=nil)
    @p          = position
    @stats      = stats
    @stats.s    = self if @stats
    @debug      = nil
    @score      = 0
    @move       = nil
    @null_move  = false
  end

  def play(type=:iterative_search)
    @done = nil
    @stats.start_turn
    # type of play depends of the function used
    # random_move, simple
    @move, @score = case type
      when :iterative_search
        iterative_start
      when :depth_first
        depth_first
      when :random
        random_move
      else
        raise "unknown type of play '#{type.to_s}'"
      end
    @stats.end_turn(@score, @move)
    return false if not @move
    @p.make(@move)
    @done = true
    true
  end

  def random_move
    @nodes = @p.gen_legal_moves
    return nil if @nodes.size == 0
    @nodes[rand(@nodes.size)]
  end

  def depth_first
    search_root(-100000, 100000, 3)
  end

  def iterative_start
    return iterate(-100000, 100000, 3)

    #@moves = [] # store PV
    depth = 1
    while depth <= 3
      puts "d=#{depth}"
      move, score = iterate(-100000, 100000, depth)
      puts "> best so far: #{move}, score: #{score}, nodes: #{@stats.current_turn_nodes}, n/s: #{@stats.nodes_per_second}, #{pretty_time(5000.0/@stats.nodes_per_second)} for 5000 nodes" if @debug
      depth += 1
    end
    return [move, score]
  end

  def iterate(a, b, depth)
    return [0,nil] if(depth == 0)
    best = nil
    moves = @p.gen_legal_moves
    sort_moves!(moves)
    for m in moves
      @stats.inc_turn_nodes
      @p.make(m)
      score = -negamax_with_reductions(-b, -a, depth-1)
      #puts "move: #{m}"
      #puts "score: #{score}"
      #@p.printp
      @p.unmake
      #return [score, m] if( score >= b )
      if( score > a )
        a     = score
        best  = m
        puts "best so far: #{m}, score: #{a}, nodes: #{@stats.current_turn_nodes}, n/s: #{@stats.nodes_per_second}, #{pretty_time(5000.0/@stats.nodes_per_second)} for 5000 nodes" if @debug
      end
    end
    [best, a]
  end

  def search_root(a,b,depth)
    return [0,nil] if(depth == 0)
    best = nil
    moves = @p.gen_legal_moves
    sort_moves!(moves)
    for m in moves
      @stats.inc_turn_nodes
      @p.make(m)
      score = -negamax(-b, -a, depth-1)
      #puts "move: #{m}"
      #puts "score: #{score}"
      #@p.printp
      @p.unmake
      #return [score, m] if( score >= b )
      if( score > a )
        a     = score
        best  = m
        puts "best so far: #{m}, score: #{a}, nodes: #{@stats.current_turn_nodes}, n/s: #{@stats.nodes_per_second}, #{pretty_time(5000.0/@stats.nodes_per_second)} for 5000 nodes" if @debug
      end
    end
    [best, a]
  end

  def factor
    (@p.side==WHITE ? 1 : -1)
  end

  def negamax(a,b,depth)
    return quiesce(a,b,0) if(depth == 0)
    #return factor*evaluate() if(depth == 0)
    moves = @p.gen_legal_moves
    return factor*99999 if moves.size == 0
    for m in moves
      @stats.inc_turn_nodes
      #return factor*99999 if king_captured?(m)
      @p.make(m)
      score = -negamax(-b, -a, depth-1)
      @p.unmake
      return b if( score >= b )
      a = score if( score > a )
    end
    a
  end

  def negamax_with_reductions(a,b,depth)
    return quiesce(a,b,0) if(depth <= 0)
    
    # Null move reduction
    if (null_move_allowed?)
      @null_move = true
      r = depth > 6 ? 4 : 3
      @p.make_null_move
      score = -negamax_with_reductions(-b, 1-b, depth-r-1)
      @p.unmake_null_move
      if (score >= b)
        depth -= 4 # reduce search
        return quiesce(a,b,0) if ( depth <= 0 )
      end
    else
      @null_move = false
    end    
    
    moves = @p.gen_legal_moves
    return factor*99999 if moves.size == 0
    sort_moves!(moves)
    moves_searched = 0
    for m in moves
      @stats.inc_turn_nodes
      @p.make(m)
      if(moves_searched == 0) # First move, use full-window search
        score = -negamax_with_reductions(-b, -a, depth-1)
      else
        if(moves_searched >= FullDepthMoves and depth >= ReductionLimit and ok_to_reduce?(m))
          # Search this move with reduced depth
          score = -negamax_with_reductions(-(a+1), -a, depth-2)
        else
          score = a+1 # Hack to ensure that full-depth search is done.
        end
        if(score > a)
          # If one of the reduced moves surprise us by returning
          # a score above alpha, the move is re-searched with full depth.
          score = -negamax_with_reductions(-(a+1), -a, depth-1)
          if(score > a and score < b)
            score = -negamax_with_reductions(-b, -a, depth-1)
          end
        end
      end
      @p.unmake
      return b if( score >= b )
      a = score if( score > a )
      moves_searched += 1
    end
    a
  end

  def null_move_allowed?
		index = @p.indexes(@p.bitboards[colored_piece(KING, @side)]).first
    !@p.in_check?(index,@side) and !@null_move
  end
  
  # Common Conditions
  # Most programs do not reduce these types of moves:
  # - Tactical moves (captures and promotions)
  # - Moves while in check
  # - Moves which give check
  # - Moves that cause a search extension
  # - Anytime in a PV-Node in a PVS search
  # - Depth<3 (sometimes depth<2)
  def ok_to_reduce?(move)
		index = @p.indexes(@p.bitboards[colored_piece(KING, @side)]).first
    return false if move.capture or move.promotion or @p.in_check?(index,@side)
    #puts "reducing #{move}"
    true
  end

  def quiesce(alpha, beta, depth)
    stand_pat = factor*evaluate()
    return beta if( stand_pat >= beta )

    #BIG_DELTA = piece_value(QUEEN)
    #if ( isPromotingPawn() ) BIG_DELTA += 775;

    return alpha if(stand_pat < alpha - BIG_DELTA) # delta pruning

    alpha = stand_pat if(stand_pat > alpha)
    return alpha if depth >= 3 # FIXME

    moves = @p.gen_legal_captures
    sort_moves!(moves)

    for m in moves
      #return factor*99999 if king_captured?(m)
      @p.make(m)
      score = -quiesce( -beta, -alpha, depth+1 )
      @p.unmake

      return beta if( score >= beta )
      alpha = score if( score > alpha )
    end
    alpha
  end

  # Static Exchange Evaluation from a Move
  def see_root(capture_move)
    @p.make(capture_move)
    value = piece_value(capture_move.piece) - see(capture_move.to)
    @p.unmake
    return value
  end

  # generic Static Exchange Evaluation
  def see(square)
    piece, from_square = @p.get_smallest_attacker(square, @p.side)
    return 0 if not piece
    move = Move.new(piece, from_square, square, @p.piece_at(square))
    @p.make(move)
    value = piece_value(piece) - see(square)
    @p.unmake
    return value
  end

  def sort_moves!(moves)
    moves = moves.sort_by { |m|
      @p.make(m)
      rv = eval_material + eval_position
      @p.unmake
      rv
      }
  end

  def king_captured?(m)
    return true if m.capture == WKING
    return true if m.capture == BKING
    false
  end

end

