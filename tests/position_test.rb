require 'position'
require 'search'
include Constants


describe Position, "(all tests)" do

  before(:all) do
    @stats = Stats.new
    @p = Position.new(@stats)
    @s = Search.new(@p, @stats)
  end

  it "should be initialized with starting position" do
    @p.all_pieces.should  == INIT_POSITION
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
    lambda { @p.unmake }.should raise_error
  end

  it "should unmake correctly 2" do
    @p.reset_to_starting_position
    @p.gen_legal_moves.each { |m|
      @p.make(m)
      @p.unmake
      @p.all_pieces.should == INIT_POSITION
      }
  end

  it "should load fen correctly" do
    #@p.load_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    @p.load_fen("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")
    @p.all_pieces.should == 18445336716276461503
    @p.bitboards[CAN_CASTLE].should == 15
    @p.side.should == BLACK
    @p.hclock.should == 1
    @p.hply.should == 2
    @p.ply.should == 3

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
    l     = Position.new
    l.load(init.dump)
    l.all_pieces.should == INIT_POSITION
    l.should == init
  end

  it "should compare correctly" do
    p1  = Position.new
    p2  = Position.new
    p1.should == p2
    p1.make(Move.new(WPAWN, D2, D3))
    p1.should_not == p2
  end

  it "should do en passant correctly" do
    fen = "1r3rk1/2pn3p/p2qp3/3p1pPQ/3P4/2P1P3/P1B3P1/R1B2K2 w - f6 0 25"
    @p.load_fen(fen)
    @p.piece_at(F5).should == BPAWN
    @p.make(Move.new(WPAWN, G5, F6))
    @p.piece_at(F5).should == nil
    @p.history.last[0].capture.should == BPAWN
    @p.unmake
    @p.piece_at(F5).should == BPAWN
    @p.==(Position.new.load_fen(fen)).should eq true
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

  it "should read a algebraic position correctly" do
    @p.load_fen("r1bq2rk/pp3pbp/2p1p1pQ/7P/3P4/2PB1N2/PP3PPR/2KR4 w - -")
    m = @p.algebraic_read("Qxh7+")
    m.to_s.should == "Qh6xh7"
    @p.load_fen("rb3qk1/pQ3ppp/4p3/3P4/8/1P3N2/1P3PPP/3R2K1 w - -")
    m = @p.algebraic_read("Qxa8")
    m.to_s.should == "Qb7xa8"
    m = @p.algebraic_read("d6")
    m.to_s.should == "Pd5d6"
    m = @p.algebraic_read("dxe6")
    m.to_s.should == "Pd5xe6"
    m = @p.algebraic_read("g3")
    m.to_s.should == "Pg2g3"
  end
  
  it "get smallest attacker" do
    @p.load_fen("8/1b6/8/3n4/3pk3/q3K2r/6n1/2b5 w - - 0 1")
    a = @p.rook_attackers(20, WHITE)
    a.should == [[BROOK, 23], [BQUEEN, 16]]
    a = @p.knight_attackers(20, WHITE)
    a.should == [[BKNIGHT, 14], [BKNIGHT, 35]]
    a = @p.bishop_attackers(20, WHITE)
    a.should == [[BBISHOP, 2]]
    a = @p.pawn_attackers(20, WHITE)
    a.should == [[BPAWN, 27]]
    a = @p.king_attackers(20, WHITE)
    a.should == [[BKING, 28]]
    a = @p.get_smallest_attacker(20, WHITE)
    a.should == [BPAWN, 27]
  end

end

