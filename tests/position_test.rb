require 'position'
require 'search'
include Constants


describe Position, "(all tests)" do

  INIT_POSITION = 18446462598732906495

  before(:all) do
    @p = Position.new
    @s = Search.new(@p)
  end

  it "should be initialized with starting position" do
    @p.all_pieces.should == INIT_POSITION
    @p.piece_at(0).should == WROOK
    @p.piece_at(1).should == WKNIGHT
    @p.piece_at(2).should == WBISHOP
    @p.piece_at(3).should == WQUEEN
    @p.piece_at(4).should == WKING
    @p.piece_at(5).should == WBISHOP
    @p.piece_at(6).should == WKNIGHT
    @p.piece_at(7).should == WROOK
    @p.piece_at(8).should == WPAWN
    @p.piece_at(9).should == WPAWN
    @p.piece_at(10).should == WPAWN
    @p.piece_at(11).should == WPAWN
    @p.piece_at(12).should == WPAWN
    @p.piece_at(13).should == WPAWN
    @p.piece_at(14).should == WPAWN
    @p.piece_at(15).should == WPAWN
    (16..47).each { |i| @p.piece_at(i).should == nil }
    @p.piece_at(63).should == BROOK
    @p.piece_at(62).should == BKNIGHT
    @p.piece_at(61).should == BBISHOP
    @p.piece_at(60).should == BKING
    @p.piece_at(59).should == BQUEEN
    @p.piece_at(58).should == BBISHOP
    @p.piece_at(57).should == BKNIGHT
    @p.piece_at(56).should == BROOK
    @p.piece_at(55).should == BPAWN
    @p.piece_at(54).should == BPAWN
    @p.piece_at(53).should == BPAWN
    @p.piece_at(52).should == BPAWN
    @p.piece_at(51).should == BPAWN
    @p.piece_at(50).should == BPAWN
    @p.piece_at(49).should == BPAWN
    @p.piece_at(48).should == BPAWN
  end

  it "should be empty if needed" do
    @p.empty!
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
    20.times{@s.play(:random)}
    20.times{@p.unmake}
    @p.all_pieces.should == INIT_POSITION
    @p.hclock.should == 0
    # another unnessassary unmake
    lambda { @p.unmake }.should_not raise_error
  end

  it "should load fen correctly" do
    #@p.load_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    @p.load_fen("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")
    @p.all_pieces.should == 18445336716276461503
    @p.bitboards[CAN_CASTLE].should == 15
    @p.side.should == BLACK
    @p.hclock.should == 1
    @p.ply.should == 2
    @p.hply.should == 3

    @p.load_fen("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b Qkq e3 1 2")
    @p.bitboards[CAN_CASTLE].should == 13
    @p.bitboards[ENPASSANT] = 0x0000000000000000000010000000000000000000000000000000000000000000

    @p.load_fen("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w Q - 1 4")
    @p.bitboards[CAN_CASTLE].should == 1
    @p.hply == 6

    @p.load_fen("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b kq - 1 4")
    @p.bitboards[CAN_CASTLE].should == 12
    @p.hply == 7
  end

  it "should castle correctly" do
    @p.load_fen("r3k2r/p6p/8/8/8/8/P6P/R3K2R w KQkq - 1 2")
    m = @p.gen_legal_moves
    m.size.should == 16
    @p.load_fen("r3k2r/p6p/8/8/8/8/P6P/R3K2R w kq - 1 2")
    m = @p.gen_legal_moves
    m.size.should == 14
    @p.load_fen("r3k2r/p6p/8/8/8/8/P6P/R3K2R b KQkq - 1 2")
    m = @p.gen_legal_moves
    m.size.should == 16
    @p.load_fen("r3k2r/p6p/8/8/8/8/P6P/R3K2R b KQ - 1 2")
    m = @p.gen_legal_moves
    m.size.should == 14
    @p.load_fen("r3k2r/p6p/8/8/8/8/P6P/R3K2R b q - 1 2")
    m = @p.gen_legal_moves
    m.size.should == 15
  end

  it "should dump correctly" do
    init  = Position.new
    l     =  Position.new
    l.load(init.dump)
    l.all_pieces.should == INIT_POSITION
    l.should == init
  end

  it "should do en passant correctly" do
    @p.load_fen("1r3rk1/2pn3p/p2qp3/3p1pPQ/3P4/2P1P3/P1B3P1/R1B2K2 w - f6 0 25")
    @p.make(Move.new(WPAWN, G5, F6))
    @p.piece_at(F5).should == nil
    @p.history.last[0].capture.should == BPAWN
    # TODO: more tests !!!! specially with unmake
  end

  it "should uncastle correctly" do
    @p.load_fen("4k2r/pppppppp/8/8/8/8/8/4K3 b k - 0 1")
    d = @p.dump
    new_pos = Position.new.load(d)
    @p.make(Move.new(BKING, E8, G8))
    @p.unmake
    @p.should == new_pos
  end

  it "should detect legal moves" do
    @p.load_fen("r3kb1r/pp2pppp/2B5/q2p1b2/3P2P1/2N2N1P/RPP2P2/3QK2R b Kkq - 0 7")
    @p.gen_moves.size.should > @p.gen_legal_moves.size
  end

end

