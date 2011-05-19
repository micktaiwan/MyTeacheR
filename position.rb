class Position

  LIGHT = 0
  DARK  = 1
  CK    = 1 # castle white king side
  CQ    = 2 # castle white queen side
  Ck    = 4 # castle black king side
  Cq    = 8 # castle black queen side

  A8 = 56; B8 = 57; C8 = 58; D8 = 59; E8 = 60; F8 = 61; G8 = 62; H8 = 63;
  A7 = 48; B7 = 49; C7 = 50; D7 = 51; E7 = 52; F7 = 53; G7 = 54; H7 = 55;
  A6 = 40; B6 = 41; C6 = 42; D6 = 43; E6 = 44; F6 = 45; G6 = 46; H6 = 47;
  A5 = 32; B5 = 33; C5 = 34; D5 = 35; E5 = 36; F5 = 37; G5 = 38; H5 = 39;
  A4 = 24; B4 = 25; C4 = 26; D4 = 27; E4 = 28; F4 = 29; G4 = 30; H4 = 31;
  A3 = 16; B3 = 17; C3 = 18; D3 = 19; E3 = 20; F3 = 21; G3 = 22; H3 = 23;
  A2 =  8; B2 =  9; C2 = 10; D2 = 11; E2 = 12; F2 = 13; G2 = 14; H2 = 15;
  A1 =  0; B1 =  1; C1 =  2; D1 =  3; E1 =  4; F1 =  5; G1 =  6; H1 =  7;


  SQUARENAME =
   ["a1","b1","c1","d1","e1","f1","g1","h1",
    "a2","b2","c2","d2","e2","f2","g2","h2",
    "a3","b3","c3","d3","e3","f3","g3","h3",
    "a4","b4","c4","d4","e4","f4","g4","h4",
    "a5","b5","c5","d5","e5","f5","g5","h5",
    "a6","b6","c6","d6","e6","f6","g6","h6",
    "a7","b7","c7","d7","e7","f7","g7","h7",
    "a8","b8","c8","d8","e8","f8","g8","h8"]

  attr_accessor :white_king, :white_queens,:white_rooks,:white_bishops,:white_knights,:white_pawns,:black_king,:black_queens,:black_rooks,:black_bishops,:black_knights,:black_pawns,:all_pieces


  def initialize
    @white_king     = 0b0
    @white_queens   = 0b0
    @white_rooks    = 0b0
    @white_bishops  = 0b0
    @white_knights  = 0b0
    @white_pawns    = 0b0
    @black_king     = 0b0
    @black_queens   = 0b0
    @black_rooks    = 0b0
    @black_bishops  = 0b0
    @black_knights  = 0b0
    @black_pawns    = 0b0
    @all_pieces     = @white_king|@white_queens|@white_rooks|@white_bishops|@white_knights|@white_pawns|@black_king|@black_queens|@black_rooks|@black_bishops|@black_knights|@black_pawns
  end

  def is_empty?
    @all_pieces == 0b0
  end

  def reset_to_starting_position
    @side   = LIGHT
    @castle = CK|CQ|Ck|Cq
    @ep     = -1
    @fifty  = 0
    @ply    = 0
    @hply   = 0
    @white_pawns    = 0b0000000000000000000000000000000000000000000000001111111100000000
    @white_rooks    = 0b0000000000000000000000000000000000000000000000000000000010000001
    @white_knights  = 0b0000000000000000000000000000000000000000000000000000000001000010
    @white_bishops  = 0b0000000000000000000000000000000000000000000000000000000000100100
    @white_queens   = 0b0000000000000000000000000000000000000000000000000000000000001000
    @white_king     = 0b0000000000000000000000000000000000000000000000000000000000010000
    @black_pawns    = 0b0000000011111111000000000000000000000000000000000000000000000000
    @black_rooks    = 0b1000000100000000000000000000000000000000000000000000000000000000
    @black_knights  = 0b0100001000000000000000000000000000000000000000000000000000000000
    @black_bishops  = 0b0010010000000000000000000000000000000000000000000000000000000000
    @black_queens   = 0b0000100000000000000000000000000000000000000000000000000000000000
    @black_king     = 0b0001000000000000000000000000000000000000000000000000000000000000
    @all_pieces     = @white_king|@white_queens|@white_rooks|@white_bishops|@white_knights|@white_pawns|@black_king|@black_queens|@black_rooks|@black_bishops|@black_knights|@black_pawns
  end

end


