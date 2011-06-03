# I found a position that takes a long time to find the next move at detph 3
# 12 min and 17.6 seconds

require 'position'

p = Position.new
s = Search(p)
p.load_fen("r2qkb1r/2p1pppp/p1n2n2/1p1p1b2/3P4/1BN1PN2/PPP2PPP/R1BQK2R b KQkq - 3 7")
start = Time.now()
s.play
puts Time.now()-start

