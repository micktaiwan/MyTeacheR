require 'search'
include Constants

describe Search, "just created" do

  before(:all) do
    @p = Position.new
    @s = Search.new(@p)
  end

  it "should play as white the first move if asked" do
    @s.played_move.should eq(nil)
    @s.play(:random).should eq(true)
    m = @s.played_move
    m.from.should > 0
    @p.ply.should  eq 1
    @p.hply.should eq 1
    @p.history.size.should eq 1
    @p.history[0][0].should eq m
    @p.side.should eq BLACK
  end

  it "should generate 20 moves at starting position" do
    @p.reset_to_starting_position
    moves = @p.gen_legal_moves
    moves.size.should eq 20
  end

  it "should return the right evaluation for initial position" do
    @p.reset_to_starting_position
    @s.eval_material.should == 0
    #@s.eval_mobility.should == 0.2
    s1, m1 = @s.search_root(-1000, 1000, 3)
    @p.change_side
    s2, m2 = @s.search_root(-1000, 1000, 3)
    puts s1, s2
    s1.should == s2
  end

end

