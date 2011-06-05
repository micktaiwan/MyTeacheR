#!/usr/bin/env ruby

require 'search'
require 'constants'
include Constants
include MyTeacherUtils

# TODO: read perftsuite.epd

FEN = [
  "r2qkb1r/2p1pppp/p1n2n2/1p1p1b2/3P4/1BN1PN2/PPP2PPP/R1BQK2R b KQkq - 3 7", # 4-June: D3, with quiece max depth = 3: 14m 4.3s
  "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1", # 1h50 min !
  "2r3kr/p4ppp/2QBp3/1B1p4/3P4/P3P3/4N1P1/1R4K1 w - - 5 31",
  "2r1Q1kr/p4ppp/3Bp3/1B1p4/3P4/P3P3/4N1P1/1R4K1 b - - 6 1"
  ]

p = Position.new
s = Search.new(p)
for fen in FEN
  p.load_fen(fen)
  p.printp
  start = Time.now()
  s.play
  puts "move: #{s.played_move}, #{pretty_time(Time.now()-start)}"
  p.printp
  # TODO: print last move score
end

