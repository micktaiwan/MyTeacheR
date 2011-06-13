# A move tree entry
class Entry

  attr_reader :children, :move, :score

  def initialize(move, score, depth)
    @move     = move
    @score    = score
    @analysed_depth = -1 # to what depth this move has been analyzed
    @children = nil
  end

  def add_child(move)
    @children << Entry.new(move, nil, 0)
  end

  def update(score, depth)
    c.score = score
    c.depth = depth
    # TODO: sort_children
    @analysed_depth = depth # TODO: do not test if depth < @analysed_depth ?
    # TODO: update parents score and sort them
  end

  # update (or add) a child and sort it relative to its score
  def update_child(move, score, depth)
    c = search_child(move)
    raise "didn't find this child #{move} for #{@move}" if !entry
    c.update(score, depth)
  end

  def search_child(move)
    for c in @children
      return c if c.to_s == move.to_s
    end
    nil
  end

  # return the next sibling with highest score for the given depth
  def next_sibling(depth)
    @children.select { |c| c.depth <= depth }.sort_by { |c| -c.score}.first
    # TODO: resorting every time ?
  end

end

# All possible (not pruned) moves are stored in a MoveTree object
class MoveTree

  attr_reader :depth_pointer, :move_index, :current_search_depth
  attr_accessor :children_initialized

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
      iterate(@next_node, -MAX, MAX, depth)
    end
  end

  # start an iteration from current @p
  def iterate(from_node, a, b, depth)
    init_nodes(from_nodes, depth) if !from_node.children
    child = from_node.next_sibling(depth) # children are sorted
    return if !child # once all the moves has been searched, simply return

    # real search begins here
    @p.make(child.move)
    score = -iterate(child, -b, -a, depth)
    @p.unmake
    child.update(m, score, depth)
  end

  def init_nodes(from_node, depth)
    raise "is it normal that for initialisation depth is = 0 ?" if depth != 0
    # TODO: remove depth parameters if previous raise is true
    # TODO: what if no moves are possibles ? then it is normal that this node has no children....
    for m in @p.gen_legal_moves
      from_node.add_child(m)
    end
  end

end
