class Entry

  def initialize(move, score, depth)
    @move     = move
    @score    = score
    @analysed_depth = -1 # to what depth this move has been analyzed
    @children = Array.new
  end

  # update (or add) a child and sort it relative to its score
  def update_child(move, score, depth)
    c = search_child(move)
    if !entry
      @children << Entry.new(move, score, depth) # TODO: insert sorted ?
    else
      c.score = score
      c.depth = depth
      # TODO: sort_children
    end
    @analysed_depth = depth
  end

  def search_child(move)
    for c in @children
      return c if c.to_s == move.to_s
    end
    nil
  end

end

class MoveTree

  attr_reader :depth_pointer, :move_index, :current_search_depth

  def initialize(p, s)
    @p, @s            = p, s
    @depth_index      = 0
    @move_index       = 0
    @current_search_depth  = 0
    @root_node        = Entry.new(nil,nil,0)
    @next_node        = @root_node
    @max_depth        = 3
    @depth_from_start = 0 # depth from the begin, that's the depth of the tree
  end

  def search(max_depth=3)
    @max_depth      = max_depth
    for depth in (0..max_depth)
      iterate(@next_node, depth)
    end
  end

  # start an iteration from current @p
  def iterate(from_node, depth)
    if from_node.children.size == 0 # or if depth == 0 ?
      init_nodes(from_nodes, depth)
    end
    m = from_node.get_next(depth) # children are sorted
    @p.make(m)
    score = -@s.negamax_with_reductions(-b, -a, depth)
    @p.unmake
    from_node.update_child(m, score, depth)
  end

  def init_nodes(from_node, depth)
    raise "is it normal that for initialisation depth is = 0 ?" if depth != 0
    for m in @p.gen_legal_moves
      @p.make(m)
      score = -@s.negamax_with_reductions(-b, -a, depth)
      @p.unmake
      from_node.update_child(m, score, depth)
    end
  end

end
