require 'position'

describe Position, "just created" do

  before(:all) do
    @b = Position.new
  end

  it "should be empty at start" do
    @b.is_empty?
  end

  it "should be initialized with starting position" do
    @b.reset_to_starting_position
    @b.all_pieces.should == 18446462598732906495
  end

end

