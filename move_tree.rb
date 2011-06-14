require 'constants'

# A move tree entry
class Entry

  include Constants

  attr_reader   :parent, :children, :move, :analyzed_depth, :beta
  attr_accessor :score

  def initialize(tree, parent=nil, move=nil, score=-MAX, adepth=0)
    @parent   = parent
    @move     = move
    @score    = score  # alpha
    @beta     = +MAX
    @analyzed_depth = -1  # all tree nodes analyzed_depth must be must be calculated relatively to itself
    @children = nil
    @tree     = tree
  end

  def add_child(move)
    @children ||= []
    @children << Entry.new(@tree, self, move, -MAX, -1)
  end

  def print_children
    puts @children.join(", ")
  end

  def sort_children
    @children = @children.sort_by { |c| -c.score}
    puts "Sorting #{self} children:"
    print_children
  end

  def to_s
    return "root" if !@move
    "#{@move} (#{@score} for #{@analyzed_depth})"
  end

  # recursively sort children up to the root
  def update_parent(score, beta, depth)
    return if !@parent
    puts "in update_parent for #{self}"
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
    puts "Updating #{self} with score #{score}/#{beta} for depth #{depth}"
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

end

########################################################################
# MoveTree stores moves and search algorythm
class MoveTree

  include Constants

  #attr_reader   :depth_pointer, :move_index, :current_search_depth
  #attr_accessor :children_initialized

  def initialize(p,s)
    @p, @s            = p,s
    @root             = Entry.new(self)
  end

  def search(max_depth=3, max_time=10)
    @max_depth = max_depth
    @max_time  = max_time

    while(node = choose_next_node) do
      puts "next node = #{node}. @root.analyzed_depth=#{@root.analyzed_depth}"
      iterate(node, -MAX, MAX)
    end
    best = pv(@root)[@p.ply] # TODO: keep track of best node....
    return [nil,nil] if !best
    [best.move, best.score]
  end

  def get(depth, index)
    puts "getting #{depth}, #{index}"
    node = pv(@root)[depth]
    raise "get: no node at depth #{depth}" if !node
    c = node.children
    raise "get: no children for node #{node}" if !c
    rv = c[index]
    raise "get: no child at index #{index}" if !rv
    rv
  end

  def choose_next_node
    return @root if @root.analyzed_depth == -1
    # TODO: resort children
    # maybe in update_parent, not simply from_node.parent.update
    # see if node score has been decreased, see if we go deeper or choose a sibling
    #@p.make(from_node.children.first.move)
    #@p.printp
    #gets
    #iterate(from_node.children.first, -b, -a)
    #@p.unmake
    nil
  end

  # start an iteration from current @p
  def iterate(from_node, a, b)
    puts "\n *** iterate from #{from_node}, at depth #{from_node.depth}. a=#{a}, b=#{b}\n"
    return if !from_node
    generate_nodes(from_node) if !from_node.children
    # puts "Nodes: #{@next_node.children.join(", ")}"
    return [-MAX, b] if from_node.children.size == 0
    #return @s.quiesce(a,b,0) if(depth <= 0)

    for node in from_node.children # children are sorted
      #puts "\nnext node is #{node}"

      # real search begins here
      @p.make(node.move)
      print "Evaluating #{node}... "
      score = @p.eval_position #@s.quiesce(a,b,0)
      puts "=> #{score}"
      @p.unmake

      #if(score >= b) # no beta cutoff possible at depth=1
      #  puts "beta cutoff for #{node} at #{score} while beta is #{b}"
      #  a = b
      #  node.update(score, b)
      #  break
      #end
      a = score if(score > a)
      node.update(score, b)
    end
    from_node.sort_children
    best = from_node.children.first
    puts "best node: #{best}"
    from_node.update(-best.beta, -best.score)
    #from_node.parent.update(-beta, -score, @analyzed_depth+1) if @parent
  end

  def generate_nodes(from_node)
    puts "Generating nodes for #{from_node}"
    for m in @p.gen_legal_moves
      from_node.add_child(m)
    end
  end

  def pv(node, rv=[])
    return rv if not node.children or not node.children[0]
    rv+pv(node.children[0], [node.children[0]])
  end

end
