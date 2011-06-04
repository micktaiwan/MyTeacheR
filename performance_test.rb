# I found a position that takes a long time to find the next move at detph 3
# 12 min and 17.6 seconds

# 4-June: with quiece max depth = 3: 14m 4.3s


require 'search'
require 'constants'
include Constants
include MyTeacherUtils

p = Position.new
s = Search.new(p)
#p.load_fen("r2qkb1r/2p1pppp/p1n2n2/1p1p1b2/3P4/1BN1PN2/PPP2PPP/R1BQK2R b KQkq - 3 7")
#p.printp
#start = Time.now()
#s.play
#puts pretty_time(Time.now()-start)
#p.printp
# TODO: score last move score


p.load_fen("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1")
p.printp
start = Time.now()
s.play
puts pretty_time(Time.now()-start)
p.printp


# test 1
#p.load_fen("2r3kr/p4ppp/2QBp3/1B1p4/3P4/P3P3/4N1P1/1R4K1 w - - 5 31")
#p.printp
#puts p.moves_string(p.gen_queens_moves(WHITE))
#s.play
#p.printp
#s.play
#p.printp
#puts s.played_move

# test 2
#p.load_fen("2r1Q1kr/p4ppp/3Bp3/1B1p4/3P4/P3P3/4N1P1/1R4K1 b - - 6 1")
#p.printp
#puts p.moves_string(p.gen_rooks_moves(BLACK))
#p.make(Move.new(BROOK, C8, E8))
#p.printp

