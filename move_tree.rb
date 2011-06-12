class Entry

  def initialize(move, score, depth)
    @move     = move
    @score    = score
    @searched = false # has this move been evaluated ?
    @analysed_depth = 0 # to what depth this move has been analyzed
    @children = Array.new
  end

end

class MoveTree

  attr_reader :depth_pointer, :move_index, :current_search_depth

  def initialize(p)
    @p                = p
    @depth_index      = 0
    @move_index       = 0
    @current_search_depth  = 0
    @root             = Array.new
    @max_depth        = 3
    @depth_from_start = 0 # depth from the begin, that's the depth of the tree
  end

  def search(max_depth=3)
    @max_depth      = max_depth

    for m in all_moves
      search m at depth
    sort all_moves
  end

end
