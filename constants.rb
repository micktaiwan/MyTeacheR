class IllegalMoveException < RuntimeError
end
class IllegalInput < RuntimeError
end

module Constants

# MinFullDepth is the minimum depth to go evaluating all the moves
# moves are sorted first if analyzed_depth > MinFullDepth, and then by score
MinFullDepth  = 1
MinDepth      = 3 # depth to go for at least a nb of moves equals to MinDepthMoves, without extensions
MinDepthMoves = 4 # minimum nb of moves to analyze at least at MinDepth
Check_value   = 50 # how much we value a check
MinTime       = 2 # time below wich we can deepen


WHITE, BLACK = 0, 1
KING, QUEEN, ROOK, KNIGHT, BISHOP, PAWN = 0,1,2,3,4,5
WKING, WQUEEN, WROOK, WKNIGHT, WBISHOP, WPAWN = 0,1,2,3,4,5
BKING, BQUEEN, BROOK, BKNIGHT, BBISHOP, BPAWN = 6,7,8,9,10,11
WHITE_KING,WHITE_QUEENS,WHITE_ROOKS,WHITE_KNIGHTS,WHITE_BISHOPS,WHITE_PAWNS = 0,1,2,3,4,5
BLACK_KING,BLACK_QUEENS,BLACK_ROOKS,BLACK_KNIGHTS,BLACK_BISHOPS,BLACK_PAWNS = 6,7,8,9,10,11
BLACKS_OFFSET = 6
ENPASSANT     = 12
LAST_BOARD_INDEX = CAN_CASTLE = 13
QUEENSIDE, KINGSIDE = 0, 1

INIT_POSITION       = 0xFFFF00000000FFFF
FULL_BB             = 0xFFFFFFFFFFFFFFFF
FILE_OCCUPANCY_MASK = 0x000000000000003F
BYTE                = 0xFF
K1  = 0xaa00aa00aa00aa00
K2  = 0xcccc0000cccc0000
K4  = 0xf0f0f0f00f0f0f0f

MAX = 999999


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

SYMBOLS = [ 'K','Q','R','N','B','P',
            'k','q','r','n','b','p']

# http://chessprogramming.wikispaces.com/Simplified+evaluation+function
Piece_values = [20000, 900, 500, 330, 320, 100, 20000, 900, 500, 330, 320, 100] # WKING, WQUEEN, WROOK, WKNIGHT, WBISHOP, WPAWN, and blacks
BIG_DELTA = 900 # for delta pruning

BPAWN_TABLE = [
 0,  0,  0,  0,  0,  0,  0,  0,
50, 50, 50, 50, 50, 50, 50, 50,
10, 10, 20, 30, 30, 20, 10, 10,
 5,  5, 10, 25, 25, 10,  5,  5,
 0,  0,  0, 20, 20,  0,  0,  0,
 5, -5,-10,  0,  0,-10, -5,  5,
 5, 10, 10,-20,-20, 10, 10,  5,
 0,  0,  0,  0,  0,  0,  0,  0
]

WPAWN_TABLE = [
 0,  0,  0,  0,  0,  0,  0,  0,
 5, 10, 10,-20,-20, 10, 10,  5,
 5, -5,-10,  0,  0,-10, -5,  5,
 0,  0,  0, 20, 20,  0,  0,  0,
 5,  5, 10, 25, 25, 10,  5,  5,
10, 10, 20, 30, 30, 20, 10, 10,
50, 50, 50, 50, 50, 50, 50, 50,
 0,  0,  0,  0,  0,  0,  0,  0
]

BKNIGHT_TABLE = [
-50,-40,-30,-30,-30,-30,-40,-50,
-40,-20,  0,  0,  0,  0,-20,-40,
-30,  0, 10, 15, 15, 10,  0,-30,
-30,  5, 15, 20, 20, 15,  5,-30,
-30,  0, 15, 20, 20, 15,  0,-30,
-30,  5, 10, 15, 15, 10,  5,-30,
-40,-20,  0,  5,  5,  0,-20,-40,
-50,-40,-30,-30,-30,-30,-40,-50
]

WKNIGHT_TABLE = [
-50,-40,-30,-30,-30,-30,-40,-50,
-40,-20,  0,  5,  5,  0,-20,-40,
-30,  5, 10, 15, 15, 10,  5,-30,
-30,  0, 15, 20, 20, 15,  0,-30,
-30,  5, 15, 20, 20, 15,  5,-30,
-30,  0, 10, 15, 15, 10,  0,-30,
-40,-20,  0,  0,  0,  0,-20,-40,
-50,-40,-30,-30,-30,-30,-40,-50
]

BBISHOP_TABLE = [
-20,-10,-10,-10,-10,-10,-10,-20,
-10,  0,  0,  0,  0,  0,  0,-10,
-10,  0,  5, 10, 10,  5,  0,-10,
-10,  5,  5, 10, 10,  5,  5,-10,
-10,  0, 10, 10, 10, 10,  0,-10,
-10, 10, 10, 10, 10, 10, 10,-10,
-10,  5,  0,  0,  0,  0,  5,-10,
-20,-10,-10,-10,-10,-10,-10,-20
]

WBISHOP_TABLE = [
-20,-10,-10,-10,-10,-10,-10,-20,
-10,  5,  0,  0,  0,  0,  5,-10,
-10, 10, 10, 10, 10, 10, 10,-10,
-10,  0, 10, 10, 10, 10,  0,-10,
-10,  5,  5, 10, 10,  5,  5,-10,
-10,  0,  5, 10, 10,  5,  0,-10,
-10,  0,  0,  0,  0,  0,  0,-10,
-20,-10,-10,-10,-10,-10,-10,-20
]

BROOK_TABLE = [
 0,  0,  0,  0,  0,  0,  0,  0,
  5, 10, 10, 10, 10, 10, 10,  5,
 -5,  0,  0,  0,  0,  0,  0, -5,
 -5,  0,  0,  0,  0,  0,  0, -5,
 -5,  0,  0,  0,  0,  0,  0, -5,
 -5,  0,  0,  0,  0,  0,  0, -5,
 -5,  0,  0,  0,  0,  0,  0, -5,
  0,  0,  0,  5,  5,  0,  0,  0
]

WROOK_TABLE = [
  0,  0,  0,  5,  5,  0,  0,  0,
 -5,  0,  0,  0,  0,  0,  0, -5,
 -5,  0,  0,  0,  0,  0,  0, -5,
 -5,  0,  0,  0,  0,  0,  0, -5,
 -5,  0,  0,  0,  0,  0,  0, -5,
 -5,  0,  0,  0,  0,  0,  0, -5,
  5, 10, 10, 10, 10, 10, 10,  5,
 0,  0,  0,  0,  0,  0,  0,  0
]

BQUEEN_TABLE = [
-20,-10,-10, -5, -5,-10,-10,-20,
-10,  0,  0,  0,  0,  0,  0,-10,
-10,  0,  5,  5,  5,  5,  0,-10,
 -5,  0,  5,  5,  5,  5,  0, -5,
  0,  0,  5,  5,  5,  5,  0, -5,
-10,  5,  5,  5,  5,  5,  0,-10,
-10,  0,  5,  0,  0,  0,  0,-10,
-20,-10,-10, -5, -5,-10,-10,-20
]

WQUEEN_TABLE = [
-20,-10,-10, -5, -5,-10,-10,-20,
-10,  0,  5,  0,  0,  0,  0,-10,
-10,  5,  5,  5,  5,  5,  0,-10,
  0,  0,  5,  5,  5,  5,  0, -5,
 -5,  0,  5,  5,  5,  5,  0, -5,
-10,  0,  5,  5,  5,  5,  0,-10,
-10,  0,  0,  0,  0,  0,  0,-10,
-20,-10,-10, -5, -5,-10,-10,-20
]

BKING_MG_TABLE = [
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30,
-20,-30,-30,-40,-40,-30,-30,-20,
-10,-20,-20,-20,-20,-20,-20,-10,
 20, 20,  0,  0,  0,  0, 20, 20,
 20, 30, 10,  0,  0, 10, 30, 20
]

WKING_MG_TABLE = [
 20, 30, 10,  0,  0, 10, 30, 20,
 20, 20,  0,  0,  0,  0, 20, 20,
-10,-20,-20,-20,-20,-20,-20,-10,
-20,-30,-30,-40,-40,-30,-30,-20,
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30
]

BKING_EG_TABLE = [
-50,-40,-30,-20,-20,-30,-40,-50,
-30,-20,-10,  0,  0,-10,-20,-30,
-30,-10, 20, 30, 30, 20,-10,-30,
-30,-10, 30, 40, 40, 30,-10,-30,
-30,-10, 30, 40, 40, 30,-10,-30,
-30,-10, 20, 30, 30, 20,-10,-30,
-30,-30,  0,  0,  0,  0,-30,-30,
-50,-30,-30,-30,-30,-30,-30,-50
]

WKING_EG_TABLE = [
-50,-30,-30,-30,-30,-30,-30,-50,
-30,-30,  0,  0,  0,  0,-30,-30,
-30,-10, 20, 30, 30, 20,-10,-30,
-30,-10, 30, 40, 40, 30,-10,-30,
-30,-10, 30, 40, 40, 30,-10,-30,
-30,-10, 20, 30, 30, 20,-10,-30,
-30,-20,-10,  0,  0,-10,-20,-30,
-50,-40,-30,-20,-20,-30,-40,-50
]

DeBruijn = [
63,  0, 58,  1, 59, 47, 53,  2,
60, 39, 48, 27, 54, 33, 42,  3,
61, 51, 37, 40, 49, 18, 28, 20,
55, 30, 34, 11, 43, 14, 22,  4,
62, 57, 46, 52, 38, 26, 32, 41,
50, 36, 17, 19, 29, 10, 13, 21,
56, 45, 25, 31, 35, 16,  9, 12,
44, 24, 15,  8, 23,  7,  6,  5
]

DeBruijn64 = 0x07EDD5E59A4E28C2

end

