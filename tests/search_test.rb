require 'search'
include Constants
include MyTeacherUtils

describe Search, "" do

  before(:all) do
    @p = Position.new
    @s = Search.new(@p)
  end

  it "should play as white the first move if asked" do
    @s.move.should eq(nil)
    @s.play(:random).should eq(true)
    m = @s.move
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
    @p.change_side
    m1, s1 = @s.search_root(-10000, 10000, 1)
    @p.change_side
    m2, s2 = @s.search_root(-10000, 10000, 1)
    s1.should == s2
  end

  #it "should not let the king in check" do
  #  @p.load_fen("r3kb1r/pp2pppp/2B5/q2p1b2/3P2P1/2N2N1P/RPP2P2/3QK2R b Kkq - 0 7")
  #  @s.play
  #  puts @s.played_move
  #end

  it "should do the last move" do
    @p.load_fen("2r2k1r/p4ppp/2QBp3/1B1p4/3P4/P3P3/4N1P1/1R4K1 b - - 4 30")
    @s.play
    @s.move.to_s.should == "f8g8"
    @s.play # FIXME: 5 seconds to find it....
    @s.move.to_s.should == "c6c8"
  end

end

