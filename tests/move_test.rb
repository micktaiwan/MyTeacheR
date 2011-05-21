require 'position'
include Constants

describe Move, "basics" do

  before(:all) do
    @m = Move.new
  end

  it "should be initialized with all nil" do
		@m.piece.should      eq nil
    @m.from.should       eq nil
    @m.to.should         eq nil
		@m.capture.should    eq nil
		@m.promotion.should  eq nil
  end

  it "should be equal with self" do
    @m.should eq @m
  end

  #it "should be equal with inverse of inverse move" do
  #  @m.should eq @m.inverse.inverse
  #end

end

