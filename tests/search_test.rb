require 'search'
include Constants

describe Search, "just created" do

  before(:all) do
    @p = Position.new
    @s = Search.new(@p)
  end

  it "should play as white the first move if asked" do
    @s.played_move.should eq(nil)
    @s.play.should eq(true)
    m = @s.played_move
    m.from.should > 0
    #m.to_s.should eq("b1c3")
    @p.ply.should  eq 1
    @p.hply.should eq 1
    @p.history.size.should eq 1
    @p.history[0][0].should eq m
    @p.side.should eq BLACK
  end

  it "should generate 20 moves at starting position" do
    @p.reset_to_starting_position
    moves = @p.gen_legal_moves
    #print @p.print_moves(moves)+ " "
    moves.size.should eq 20
  end

end

