require 'search'
include Constants
include MyTeacherUtils

describe Search, "" do

  before(:all) do
    @stats = Stats.new
    @p = Position.new(@stats)
    @s = Search.new(@p, @stats)
  end

  it "should play as white the first move if asked" do
    @s.move.should eq(nil)
    @s.play
    m = @s.move
    m.from.should > 0
    @p.ply.should  eq 1
    @p.hply.should eq 1
    @p.history.size.should eq 1
    @p.history[0][0].should eq m
    @p.side.should eq BLACK
  end

  it "should return the right evaluation for initial position" do
    @p.reset_to_starting_position
    @p.eval_material.should == 0
    m1, s1 = @s.tree.search(0) # @s.search_root(-10000, 10000, 1)
    @p.change_side
    m2, s2 = @s.tree.search(0) # @s.search_root(-10000, 10000, 1)
    s1.should == s2
  end

  #it "should not let the king in check" do
  #  @p.load_fen("r3kb1r/pp2pppp/2B5/q2p1b2/3P2P1/2N2N1P/RPP2P2/3QK2R b Kkq - 0 7")
  #  @s.play
  #  puts @s.played_move
  #end

  it "should return a checkmate" do
    @p.load_fen("8/8/8/8/8/2K5/1Q6/k7 b - - 30 89")
    @s.play
    @s.move.should == nil
  end

  it "should do the last move" do
    @p.load_fen("2r2k1r/p4ppp/2QBp3/1B1p4/3P4/P3P3/4N1P1/1R4K1 b - - 4 30")
    @s.play
    @s.move.to_s.should == "kf8g8"
    @s.play
    @s.move.to_s.should == "Qc6xc8"
    @s.play
    @s.move.should == nil
  end

end

