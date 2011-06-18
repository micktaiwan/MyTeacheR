require 'constants'

# A move tree entry
class Entry

  include Constants

  attr_reader   :parent, :children, :move, :analyzed_depth
  attr_accessor :score

  def initialize(p, tree, parent=nil, move=nil, score=-MAX, adepth=0)
    @p        = p # position
    @parent   = parent
    @move     = move
    @score    = score  # alpha
    @analyzed_depth = -1  # all tree nodes analyzed_depth must be must be calculated relatively to itself
    @children = nil # to differenciate not yet generated and no chidlren at all
    @tree     = tree
    @complete = nil
  end

  def add_child(move)
    if !@children
      @children = []
      @complete = false
    end
    e = Entry.new(@p, @tree, self, move, -MAX, -1)
    @children << e
    e
  end

  def print_children
    puts @children.join(", ")
  end

  def sort_children
    @children = @children.sort_by { |c| -c.score}
    #puts "Sorting #{self} children:"
    #print_children
  end

  # recursively update and sort children up to the root
  def update_to_root(depth=1)
    sort_children
    best = children.first
    #puts "  setting #{self} to (#{-best.score} for #{depth})"
    @score = -best.score # negamax
    @analyzed_depth = depth
    @parent.update_to_root(depth+1) if @parent
  end

  def to_s
    return "root" if !@move
    "#{@move} (#{@score} for #{@analyzed_depth})"
  end

  def update(score, depth=nil)
    depth = @tree.pv(self).size if !depth
    @score = score
    @analyzed_depth = depth
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

  # itself included
  def weak_siblings(depth)
    return [] if !@parent
    @parent.children.select { |c| c.analyzed_depth < depth }
  end

  # itself included
  def strong_siblings(depth)
    return [] if !@parent
    @parent.children.select { |c| c.analyzed_depth >= depth }
  end

  def depth(rv=0)
    return rv if not @parent
    @parent.depth(rv+1)
  end

  def generate_nodes
    #raise "no move for entry #{self}" if !@move
    #raise "The position is not ready to generate moves for this node (#{@move})" if @p.history.last and @p.history.last[0].to_s(:xboard) != @move.to_s(:xboard)
    if !@children
      @children = []
      @complete = true
    end
    for m in @p.gen_legal_moves
      add_child(m)
    end
  end

  def get_entry_by_move(m)
    generate_nodes if !children
    for e in children
      return e if e.move == m
    end
    nil
  end

  def clear
    if children
      for c in children
        c.clear
      end
      children.clear # Array#clear
      children = nil
    end
  end

end

########################################################################
# MoveTree stores moves and search algorithm
#
# Algorithm:
#
# iteratively search deeper
# choose_next_node (contains the pruning or deepening and is the real intelligence)
# generate all children and evaluate the position for each of them
#
class MoveTree

  include Constants

  attr_reader   :root, :current_pos_node

  def initialize(p,s)
    @p, @s            = p,s
    @root             = Entry.new(@p, self)
    @current_node     = @root # current analyzed node
    @current_pos_node = @root # current position last played move
    @stack            = Array.new
  end

  def clear
    @root.clear
  end

  def search(max_depth=3, max_time=10)
    @max_depth = max_depth
    @max_time  = max_time
    generate_until_history
    while(@current_node = choose_next_node) do
      prepare_position
      @p.printp
      #raise IllegalMoveException.new("make: illegal move") if @current_node.parent and not @p.gen_legal_moves.include?(@current_node.move)
      puts "** current node = #{@current_node}. @root.analyzed_depth=#{@root.analyzed_depth}"
      get_children_score(@current_node)
      @current_node.update_to_root
      print_tree
    end
    unmake_stack
    puts @p.ply
    @current_pos_node = @current_node = pv(@current_pos_node)[0]
    return [nil,nil] if !@current_pos_node
    [@current_pos_node.move, @current_pos_node.score]
  end

  # the history could be more recent than the last move played by the computer
  # generate tree until getting the last move played
  # first get the move in the history that is the @current_move
  # then generate each history move until the last one
  def generate_until_history
    last = @p.history.last
    if !last # if no history, just stop
      clear
      @current_move = @current_pos_node = @root
      return
    end
    return if @current_pos_node.move == last[0] # no move played since last computer move

    # @current_pos_node is the last move payed by computer
    # find it in history
    size = @p.history.size
    index = size-1
    while(true) do
      break if @p.history[index][0].to_s == @current_pos_node.move.to_s
      index -= 1
      break if index < 0
    end

    if index< 0 # move not found in tree
      clear
      @current_move = @current_pos_node = @root
      return
    end

    n = @current_pos_node
    for i in index..size-1
      n = n.add_child(@p.history[i][0])
    end
    @current_node = @current_pos_node = n
  end

  # unmake and make moves
  def prepare_position
    unmake_stack
    build_stack
    @current_node.generate_nodes if !@current_node.children
  end

  # Algo:
  #   the next node is either
  #   - a sibling of the current node
  #   - a child of the current node
  #   -
  # TODO: if max_deph is set, and still has time, finish all not evaluated nodes
  def choose_next_node
    return @current_pos_node if @current_pos_node.analyzed_depth == -1
    puts "choosing next: current node #{@current_node} adepth: #{@current_node.analyzed_depth}"

    # evaluate next sibling
    #   if the current depth is not deep enough,
    #   if the count of analyzed siblings if not enough
    #@p.print_moves(@current_node.weak_siblings(1))
    next_sibling = @current_node.weak_siblings(1).first
    puts "next_sibling=#{next_sibling}"
    return next_sibling if next_sibling and
      (@current_pos_node.analyzed_depth <= ReductionLimit or
      @current_node.strong_siblings(1).size < FullDepthMoves)

    return nil if @current_pos_node.analyzed_depth > @max_depth

    puts "!!! choosing to deepen"
    #gets
    pv(@current_pos_node)[-1]
  end

  def get_children_score(from_node)
    return -MAX if from_node.children.size == 0
    for node in from_node.children # children are sorted
      @p.make(node.move)
      score = -@s.quiesce(-MAX,+MAX,0) # TODO: not -MAX, +MAX
      @p.unmake
      node.update(score, 0)
      # TODO: beta cutoff is when one score of the children > -from_node.score
    end
  end

  def pv(node, rv=[])
    return rv if not node.children or not node.children[0]
    pv(node.children[0], rv << node.children[0])
  end

  def pv_str
    pv(@current_pos_node).map{|n| "#{n.move.to_s} (#{n.score})"}.join(", ")
  end

  def print_tree
    puts "PV: #{pv_str}"
    puts "=> #{@current_node}"
  end
  def unmake_stack
    @stack.size.times { @p.unmake }
    @stack.clear
  end

  # build a move stack from @current_pos_node to @current_node and make the moves
  def build_stack
    n = @current_node
    while(n.parent and n.to_s != @current_pos_node.to_s) do
      @stack << n
      n = n.parent
    end
    @stack.reverse!
    @stack.each { |n|
      @p.make(n.move)
      }
  end

  def get(depth, index)
    puts "    getting #{depth}, #{index}"
    node = pv(@root)[depth]
    raise "get: no node at depth #{depth}" if !node
    c = node.children
    raise "get: no children for node #{node}" if !c
    rv = c[index]
    raise "get: no child at index #{index}" if !rv
    rv
  end

end
