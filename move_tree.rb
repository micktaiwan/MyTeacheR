require 'constants'

# A move tree entry
class Entry

  include Constants

  attr_reader :parent, :children, :move, :score, :analyzed_depth

  def initialize(parent=nil, move=nil, score=-MAX, adepth=0)
    @parent   = parent
    @move     = move
    @score    = score
    @analyzed_depth = adepth # to what depth this move has been analyzed
    @children = nil
  end

  def add_child(move)
    @children ||= []
    @children << Entry.new(self, move, -MAX, -1)
  end

  def print_children
    puts @children.join(", ")
  end

  def sort_children
    @children = @children.sort_by { |c| -c.score}
  end

  def to_s
    "#{@move} (#{@score} for #{@analyzed_depth})"
  end

  # recursively sort children up to the root
  def update_parent
    return if !@parent
    #puts "in update_parent for #{self}"
    @parent.sort_children
    if @parent.parent # not root move
      @parent.update(-@parent.children.first.score, @analyzed_depth)
      @parent.update_parent
    end
  end

  def update(score, depth)
    #puts "Updating #{@move} with score #{score} for depth #{depth}"
    @score = score
    @analyzed_depth = depth # TODO: do not test if depth < @analysed_depth ?
    update_parent # sort all siblings and update score tree
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

end


#################################################################
# All possible (not pruned) moves are stored in a MoveTree object
#################################################################

class MoveTree

  include Constants

  attr_reader :depth_pointer, :move_index, :current_search_depth
  attr_accessor :children_initialized

  def initialize(p,s)
    @p, @s            = p,s
    @depth_index      = 0
    @move_index       = 0
    @current_search_depth  = 0
    @root             = Entry.new
    @next_node        = @root
    @max_depth        = 3
    @ply              = 0 # depth from the begin, that's the depth of the tree
  end

  def search(max_depth=3)
    # TODO: all tree nodes analyzed depth must be decremented
    # or must be calculated taking into account @current_search_depth and @ply
    @max_depth = max_depth
    best = @root
    for depth in (1..@max_depth)
      puts
      puts "===== iterating #@next_node to #{depth}"
      score = iterate(@next_node, -MAX, MAX, depth)
      if(score > best.score )
        best  = @next_node.children.first
        puts
        puts "best so far: #{best.move}, score: #{best.score}" #, nodes: #{@s.stats.current_turn_nodes}, n/s: #{@stats.nodes_per_second}, #{pretty_time(5000.0/@stats.nodes_per_second)} for 5000 nodes" if @s.debug
        puts
      end
      #@next_node = @root.next_sibling(depth)
      #break if !@next_node
    end
    [best.move, best.score]
  end

  # start an iteration from current @p
  def iterate(from_node, a, b, depth)
    return @s.quiesce(a,b,0) if(depth <= 0)
    puts "\n *** iterate from #{from_node}, at depth #{depth}. a=#{a}, b=#{b}\n"

    generate_nodes(from_node) if !from_node.children
    # puts "Nodes: #{@next_node.children.join(", ")}"
    return a if from_node.children.size == 0 # TODO: really return alpha if no move is possible ????

    #best = -MAX
    while(node = from_node.next_sibling(depth)) # children are sorted
      #puts "\nnext node is #{node}"

      # real search begins here
      @p.make(node.move)
      puts "=> making #{node}"
      score = -iterate(node, -b, -a, depth-1)
      @p.unmake
      puts "<= unmaking #{node}"

      if(score >= b)
        puts "beta cutoff for #{node} at #{score} while beta is #{b}"
        #node.update(b, depth)
        return b
      end
      a = score if(score > a)
      node.update(score, depth)

      #best = score if(score > a)
    end
    #best # or from_node.next_sibling(depth+1).score
    a
  end

  def generate_nodes(from_node)
    for m in @p.gen_legal_moves
      from_node.add_child(m)
    end
  end

end
