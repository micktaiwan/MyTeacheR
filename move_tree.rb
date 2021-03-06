require 'constants'
begin
  require 'rubygems'
  require 'graphviz'
  $graphiz = true
rescue Exception => e
  $graphiz = false
  puts "*** No graphiz library -- For tree vizualisation, install GraphViz and ruby-graphiz gem"
  puts
end

# A move tree entry, could be named "node"
class Entry

  include Constants

  attr_reader   :parent, :children, :move, :analyzed_depth, :depth
  attr_accessor :score

  def initialize(p, tree, parent=nil, move=nil, score=-MAX, depth=0)
    @p        = p # position
    @parent   = parent
    @move     = move
    @score    = score  # alpha
    @analyzed_depth = -1  # all tree nodes analyzed_depth must be must be calculated relatively to itself
    @depth    = depth # this node depth from root node
    @children = nil # nil to differenciate not yet generated and no chidlren at all
    @tree     = tree
    @complete = nil
  end

  def add_child(move)
    if !@children
      @children = []
      @complete = false
    end
    e = Entry.new(@p, @tree, self, move, -MAX, @depth+1)
    @children << e
    e
  end

  def print_children
    puts @children.join(", ")
  end

  def sort_children
    @children = @children.sort_by { |c| [(c.analyzed_depth >= MinFullDepth ? 0 : 1), -c.score]}
    #puts "Sorting #{self} children:"
    #print_children
  end

  # recursively update and sort children up to the root
  def update_to_root(depth=1)
    sort_children
    best = children.first
    #puts "  setting #{self} to (#{-best.score} for #{depth})"
    @score = -best.score if best # negamax
    @analyzed_depth = depth
    @parent.update_to_root(depth+1) if @parent
  end

  def to_s
    return "root (#{@score}/#{@analyzed_depth})" if !@move
    "#{@move} (#{@score}/#{@analyzed_depth})"
  end

  def to_graphviz
    return "{root|{#{@score}/#{@analyzed_depth}}}" if !@move
    "{#{@move}|{#{@score}/#{@analyzed_depth}}}"
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

  # itself included
  def capture_siblings(depth)
    return [] if !@parent
    @parent.children.select { |c| c.analyzed_depth < depth and c.move.capture }
  end

  def calculated_depth(rv=0)
    return rv if not @parent
    @parent.calculated_depth(rv+1)
  end

  def generate_children
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
    if @children
      for c in @children
        c.clear
      end
      @children.clear # Array#clear
      @children = nil
    end
    @analyzed_depth = -1
    @score          = -MAX
    @complete       = nil
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

  attr_reader   :root, :current_pos_node, :best, :current_time

  def initialize(p,s)
    @p, @s            = p,s
    @root             = Entry.new(@p, self)
    @current_node     = @root # current analyzed node
    @current_pos_node = @root # current position last played node
    @stack            = Array.new
    @start_time       = Time.now
    @check_nodes      = Array.new
  end

  def best
    return @current_pos_node.children.first if @current_pos_node and @current_pos_node.children
    nil
  end

  def current_time
    Time.now-@start_time
  end

  def clear
    @root.clear
  end

  def search(max_time=0)
    return [nil,-MAX] if !@current_pos_node # mate
    @start_time = Time.now
    @max_time   = max_time
    #@stack.clear # as we could do a @current_move = @current_pos_node, but still preparing the position with some @p.unmake.... due to the stack being
    generate_until_history # FIXME: generate some bugs with unmake: play, play, unmake, d7d5, play => bug !
    best_depth = 0
    best_score = -MAX
    start_time = Time.now
    while(@current_node = choose_next_node) do
      prepare_position
      #puts "** current node = #{@current_node}. @root.analyzed_depth=#{@root.analyzed_depth}"
      get_children_score(@current_node) # this is the iteration
      @current_node.update_to_root
      depth = @current_pos_node.analyzed_depth
      score = -@current_pos_node.score
      if(depth > best_depth or score != best_score)
        best_depth = depth
        best_score = score
        puts "depth: #{best_depth}, score: #{score}"
        print_pv
      end
      break if max_time != 0 and Time.now-@start_time > max_time
    end
    unmake_stack
    @current_pos_node = @current_node = @current_pos_node.children.first # pv(@current_pos_node)[0]
    if @p.history.last and @current_node and move_str(@current_node.parent) != @p.history.last[0].to_s(:xboard)
      graph("bug_illegal_move")
      raise IllegalMoveException.new("#{move_str(@current_node.parent)} != #{@p.history.last[0].to_s(:xboard)}")
    end
    return [nil,-MAX] if !@current_pos_node
    [@current_pos_node.move, @current_pos_node.score]
  end

  # the history could be more recent than the last move played by the computer
  # generate tree until getting the last move played
  # first get the move in the history that is the @current_move
  # then generate each history move until the last one
  def generate_until_history
    last = @p.history.last
    if !last # if no history, just stop
      #puts "Info: no history, clearing tree"
      clear
      @current_move = @current_pos_node = @root
      return
    end
    return if !@current_pos_node or @current_pos_node.move == last[0] # mate or no move played since last computer move

    # @current_pos_node is the last move payed by computer
    # find it in history
    # FIXME: does not work just after an unmake
    size = @p.history.size
    index = size-1
    while(true) do
      break if @p.history[index][0].to_s == @current_pos_node.move.to_s
      index -= 1
      break if index < 0
    end

    if index< 0 # @current_pos_node is not a history move
      # try brute force

      # FIXME: BUGGY because of lazy find. Start from ply
      #parent = @p.history[-2]
      #parent = parent[0] if parent
      #n = find(last[0], parent)
      #if n
      #  puts "Info: found move #{n} in tree"
      #  @current_move = @current_pos_node = n
      #  return
      #end

      # else clear the tree
      # FIXME: should never happen, find the move, or one of his ancestor !
      #puts "Info: move #{last[0]} not found in tree, clearing tree"
      clear
      n = @root.add_child(last[0])
      @current_move = @current_pos_node = n
      return
    end

    # else @current_pos_node is a move in history, so generate missing move in tree
    n = @current_pos_node
    for i in index..size-1
      n = n.add_child(@p.history[i][0])
    end
    @current_node = @current_pos_node = n
  end

  # assuming @current_node and @current_pos_node are set correctly
  #   to current_node in tree and node that led to the current position
  # algo:
  #   the next node is either
  #   - a sibling of the current node
  #   - a child of the current node
  #   - a parent's sibling in case of beta cutoff
  #   - TODO: another node ?
  # TODO: if still has time, finish all not evaluated nodes
  def choose_next_node
    raise "no @current_pos_node" if !@current_pos_node
    return @current_pos_node if @current_pos_node.analyzed_depth <= 0
    return nil if @current_node.score >= MAX # previous node led to checkmate
    return @current_pos_node.children.first if @current_pos_node == @current_node

    #puts "choosing next: current node #{@current_node} adepth: #{@current_node.analyzed_depth}"

    # TODO: beta cutoff when @current_node.score > parent.score
    # what really does a beta cutoff ?

    # evaluate all captures
    #s = @current_node.capture_siblings(1).first
    #return s if s

    # evaluate next sibling
    #   if the current depth is not deep enough,
    #   if the count of analyzed siblings if not enough
    #   if it remains some nodes that are better evaluated
    s = @current_node.weak_siblings(1).first
    #strongs = @current_node.strong_siblings(1)
    return s if s and
      (@current_pos_node.analyzed_depth <= MinFullDepth or
      @current_node.strong_siblings(1).size < MinDepthMoves or
      @current_node.strong_siblings(1).first.score < s.score  or # to avoid an horizon effect: queen is taken early in the game
      Time.now-@start_time < MinTime
      )

    # ensuring that pv has at least MinDepth moves after deepening some moves
    return pv(@current_pos_node)[-1] if pv(@current_pos_node).size < MinDepth

    # deepen moves giving check
    if !@check_nodes.empty?
      n = @check_nodes.pop
      puts "deepening move giving check #{n} / #{@check_nodes.size}"
      return n
    end

    return nil # that was the last node, will now play pv
  end

  def get_children_score(node)
    node.generate_children if !node.children
    if node.children.size == 0
      if @p.other_side_in_check? # checkmate
        node.update(MAX, 0)
      else                    # stalemate
        node.update(0, 0)
      end
      return
    end
    # graph(node.move.to_s) # FIXME: clear tree, so children too !!
    for child in node.children # children are sorted
      @p.make(child.move)
      #puts "making #{child.move}"
      @check_nodes << child if child.depth-@current_pos_node.depth < MinDepth and @p.side_in_check?
      score = -@s.quiesce(-MAX, (node.parent ?  -node.score : MAX), 0)
      @p.unmake
      child.update(score, 0)
    end
  end

  def pv(node=@current_pos_node, rv=[])
    return rv if not node.children or not node.children[0]
    pv(node.children[0], rv << node.children[0])
  end

  # unmake and make moves
  def prepare_position
    unmake_stack
    build_stack
  end

  def unmake_stack
    @stack.size.times { @p.unmake }
    #@stack.each { |n|
    #  puts "unmaking #{n}"
    #  @p.unmake
    #  }
    @stack.clear
  end

  # build a move stack from @current_pos_node to @current_node and make the moves
  def build_stack
    n = @current_node
    #puts "from #{@current_pos_node} to #{n}"
    while(n.parent and (@current_pos_node==@root or n.move.to_s(:xboard) != @current_pos_node.move.to_s(:xboard))) do
      #puts "  stacking #{n}"
      @stack << n
      n = n.parent
    end
    @stack.reverse!
    @stack.each { |n|
      #puts "making #{n}"
      @p.make(n.move)
      }
  end

  #def get(depth, index)
  #  puts "getting #{depth}, #{index}"
  #  node = pv(@root)[depth]
  #  raise "get: no node at depth #{depth}" if !node
  #  c = node.children
  #  raise "get: no children for node #{node}" if !c
  #  rv = c[index]
  #  raise "get: no child at index #{index}" if !rv
  #  rv
  #end

  def pv_str
    pv(@current_pos_node).map{|n| "#{n.move.to_s} (#{n.score})"}.join(", ")
  end

  def print_pv
    puts "PV: #{pv_str}"
  end

  def move_str(node)
    return "" if !node or !node.move
    node.move.to_s(:xboard)
  end

  def find_child(node, move, parent_move)
    return node if move_str(node) == move.to_s(:xboard) and
      (!parent_move or move_str(node.parent) == parent_move.to_s(:xboard))
    return nil if !node.children
    for c in node.children
      n = find_child(c, move, parent_move)
      return n if n
    end
    return nil
  end

  def find(move, parent_move=nil)
    find_child(@root, move, parent_move)
  end

  def graph_node(n, parent=nil, depth=0)
    #print n, " "
    gn = @g.add_node(n.object_id.to_s, :label=>n.to_graphviz, :shape=>"Mrecord")
    if parent
      e = @g.add_edge(parent, gn)
    end
    if n == @current_pos_node
      gn[:color] = "brown3"
      gn[:style] = "filled"
    elsif @s.tree.pv(@current_pos_node).include?(n)
      gn[:color] = "cadetblue"
      gn[:style] = "filled"
    elsif @s.tree.pv(@root).include?(n)
      gn[:color] = "yellow"
      gn[:style] = "filled"
    end
    return if !n.children # or depth == 2
    i = 0
    for c in n.children
      graph_node(c, gn, depth+1)
      i += 1
      #break if i > 2
    end
  end

  def graph(name="tree", root_node=@current_pos_node)
    @g = GraphViz::new("G")
    #@g['sep'] = "10,100"
    #@g["overlap"] = "compress"
    #@g["rankdir"] = "BT"
    #@g["ratio"] = "0.9"
    @g["size"] = "350,500"
    generate_until_history # FIXME: while doing ptest, it bugs
    graph_node(root_node) #@s.tree.root
    #puts
    @g.output(:svg => "#{name}.svg")
  end

end
