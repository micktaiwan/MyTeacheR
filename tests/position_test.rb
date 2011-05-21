require 'position'
include Constants

describe Position, "just created" do

  before(:all) do
    @p = Position.new
  end

  it "should be initialized with starting position" do
    @p.all_pieces.should == 18446462598732906495
  end

  it "should be empty if needed" do
    @p.empty_position!
    @p.is_empty?.should eq(true)
    @p.all_pieces.should eq 0
    @p.played_move.should eq(nil)
  end

  it "should play as white the first move if asked" do
    @p.play.should eq(true)
    m = @p.played_move
    m.to_s.should eq("b1c3")
    @p.ply.should  eq 1
    @p.hply.should eq 0
    @p.history.size.should eq 1
    @p.history[0].should eq m
    @p.side.should eq WHITE
  end

  it "should generate 20 moves at starting position" do
    @p.reset_to_starting_position
    moves = @p.gen_moves
    print @p.print_moves(moves)+ " "
    moves.size.should eq 20
  end

end

