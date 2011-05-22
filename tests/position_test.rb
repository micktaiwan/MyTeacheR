require 'position'
require 'search'
include Constants


describe Position, "just created" do

  INIT_POSITION = 18446462598732906495

  before(:all) do
    @p = Position.new
    @s = Search.new(@p)
  end

  it "should be initialized with starting position" do
    @p.all_pieces.should == INIT_POSITION
  end

  it "should be empty if needed" do
    @p.empty_position!
    @p.is_empty?.should eq(true)
    @p.all_pieces.should eq 0
  end

  it "should move nothing if move is not initialized" do
    @p.reset_to_starting_position
    move = Move.new
    lambda {@p.make(move)}.should raise_error
    @p.all_pieces.should == INIT_POSITION
  end

  it "should move the pieces correctly" do
    @p.piece_at(C3).should eq nil
    move = Move.new(KNIGHT, B1, C3)
    lambda { @p.make(move) }.should_not raise_error
    @p.piece_at(C3).should eq WKNIGHT
    @p.piece_at(B1).should eq nil
  end

  it "should unmake correctly" do
    @p.reset_to_starting_position
    20.times{@s.play}
    20.times{@p.unmake}
    @p.all_pieces.should == INIT_POSITION
    # another unnessassary unmake
    lambda { @p.unmake }.should_not raise_error
  end


end

