require 'constants'

# A move tree entry
class Entry

  include Constants

  attr_reader   :parent, :children, :move, :analyzed_depth, :beta
  attr_accessor :score

  def initialize(p, tree, parent=nil, move=nil, score=-MAX, adepth=0)
    @p        = p # position
    @parent   = parent
    @move     = move
    @score    = score  # alpha
    @beta     = +MAX
    @analyzed_depth = -1  # all tree nodes analyzed_depth must be must be calculated relatively to itself
    @children = nil # to differenciate not yet generated and no chidlren at all
    @tree     = tree
  end

  def add_child(move)
    raise "Entry::add_child: children==nil" if !@children
    @children << Entry.new(@p, @tree, self, move, -MAX, -1)
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
  def update_to_root(depth=0)
    sort_children
    best = children.first
    puts "  setting #{self} to (#{-best.beta},#{-best.score})"
    @score, @beta = -best.beta, -best.score # negamax
    @analyzed_depth = depth
    @parent.update_to_root(depth+1) if @parent
  end

  def to_s
    return "root" if !@move
    "#{@move} (#{@score} for #{@analyzed_depth})"
  end

  def update_parent(score, beta, depth)
    return if !@parent
    puts "    in update_parent for #{self}"
    @parent.score = score
    @parent.score = beta
    @parent.sort_children
    @parent.analyzed_depth = depth
    if @parent.parent # not root move
      @parent.update(-@parent.children.first.score, @analyzed_depth)
      @parent.parent.update_parent(-beta, -score, depth-1)
    end
  end

  def update(score, beta, depth=nil)
    depth = @tree.pv(self).size if !depth
    #puts "   Updating #{self} with score #{score}/#{beta} for depth #{depth}"
    @score = score
    @beta  = beta
    @analyzed_depth = depth
    # TODO: I'm not sure this is right....
    # @parent.update(-beta, -score, @analyzed_depth+1) if @parent
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
    @children.select { |c| c.analyzed_depth < depth }.first
  end

  def depth(rv=0)
    return rv if not @parent
    @parent.depth(rv+1)
  end

  def generate_nodes
    raise "The position is not ready to generate moves for this node (#{@node})" if @p.history.last and @p.history.last[0].to_s(:xboard) != @move.to_s(:xboard)
    @children ||= []
    for m in @p.gen_legal_moves
      add_child(m)
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

  #attr_reader   :depth_pointer, :move_index, :current_search_depth
  #attr_accessor :children_initialized

  def initialize(p,s)
    @p, @s            = p,s
    @root             = Entry.new(@p, self)
    @current_node     = @root
  end

  def search(max_depth=3, max_time=10)
    @max_depth = max_depth
    @max_time  = max_time

    raise "No more node to analyze" if !@current_node

    begin
      # get the node played by opponent in the tree
      @current_node = @current_node.get_child(@p.history.last[0]) if
        @p.history.last and
        @p.history.last[0].to_s(:xboard) != @current_node.move.to_s(:xboard)

      while(@current_node = choose_next_node) do
        raise "make: illegal move" if @current_node.parent and not @p.gen_legal_moves.include?(@current_node.move)
        puts "** next node = #{@current_node}. @root.analyzed_depth=#{@root.analyzed_depth}"
        iterate(@current_node, -MAX, MAX)
        print_tree
        gets
      end
      @current_node = pv(@root)[@p.ply]
      return [nil,nil] if !@current_node
    rescue Exception => e
      puts e
      puts e.backtrace
      @p.printp
    end

    return [@current_node.move, @current_node.score]

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

  # Algo:
  #   the next node is
  #   - either a sibling of the current node
  #   - or a child of the current node pv(@root)[-1]
  def choose_next_node
    return @root if @root.analyzed_depth == -1
    # TODO: if max_deph is set, and still has time, finish all not evaluated nodes
    pv(@root)[-1]
  end

  # start an iteration from current @p
  #   generate all children
  #   evaluate each children
  #   sort them
  #     children.first.sort_parents
  def iterate(from_node, a, b)
    puts "\n *** iterate from #{from_node}, at depth #{from_node.depth}. a=#{a}, b=#{b}\n"
    puts @p.side
    return if !from_node
    @p.make(from_node.move) if from_node.parent # !root
    raise "oops" if (@p.all_whites & @p.all_blacks) > 1
    puts @p.side

    # TODO: there is a bug here as side should be 0 on the 3rd move


    @p.printp
    from_node.generate_nodes if !from_node.children
    return [-MAX, b] if from_node.children.size == 0
    puts "Nodes: #{from_node.children.join(", ")}"
    #return @s.quiesce(a,b,0) if(depth <= 0)

    for node in from_node.children # children are sorted
      #puts "\nnext node is #{node}"

      # real search begins here
      @p.make(node.move)
      #print "   Evaluating #{node}... "
      score = -@s.factor*@p.eval_position #@s.quiesce(a,b,0)
      #puts "=> #{score}"
      @p.unmake
      raise "oops 1" if (@p.all_whites & @p.all_blacks) > 1

      #if(score >= b) # no beta cutoff possible at depth=1
      #  puts "beta cutoff for #{node} at #{score} while beta is #{b}"
      #  a = b
      #  node.update(score, b)
      #  break
      #end
      a = score if(score > a)
      node.update(score, b)
    end
    @p.unmake if from_node.parent
    raise "oops 2" if (@p.all_whites & @p.all_blacks) > 1

    from_node.update_to_root
    best = from_node.children.first
    puts "** best node: #{best}"
    #from_node.update(-best.beta, -best.score)
    #from_node.parent.update(-beta, -score, @analyzed_depth+1) if @parent
  end

  def pv(node, rv=[])
    return rv if not node.children or not node.children[0]
    pv(node.children[0], rv << node.children[0])
  end

  def pv_str
    pv(@root).map{|n| "#{n.move.to_s} (#{n.score})"}.join(", ")
  end

  def print_tree
    puts "=> Current node: #{@current_node}"
    puts "   PV: #{pv_str}"
  end

end
