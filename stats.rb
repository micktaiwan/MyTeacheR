require 'utils'

class Stats

  include MyTeacherUtils

  attr_reader :current_turn_nodes
  attr_accessor :p, :s

  def initialize
    @p = nil
    @s = nil
    @total_nodes = 0
    @current_turn_nodes = 0
    @nb_moves_per_turn = []
    @time_per_turn = []
    @nodes_per_second = []
    @score_per_turn = []
  end

  def start_turn
    @current_turn_nodes = 0
    @start_time = Time.now
  end

  def inc_turn_nodes
    @current_turn_nodes += 1
  end

  def end_turn(score, move)
    @total_nodes += @current_turn_nodes
    @nb_moves_per_turn << @current_turn_nodes
    @time_per_turn << Time.now - @start_time
    @score_per_turn << score
    @nodes_per_second << @current_turn_nodes.to_f/@time_per_turn.last
    puts "## end score: #{score.to_f/100}, best = #{move}, time = #{pretty_time(@time_per_turn.last)}, nodes: #{@current_turn_nodes}, n/s: #{round(@current_turn_nodes.to_f/@time_per_turn.last)}" if @s.debug
  end

  def end_human_turn(move)
    @nb_moves_per_turn << nil
    @time_per_turn << nil
    @score_per_turn << nil
    @nodes_per_second << nil
  end

  def print_end_turn_stats
    puts "#{@p.ply}. #{@s.move} (turn moves: #{@current_turn_nodes}, moy: #{round(@total_nodes/@p.ply)}) hclock=#{@p.hclock}"
  end

  def print_verbose_stats
    puts "n/s per turn:"
    puts pretty_array(@nodes_per_second,  :round)
    puts "score per turn:"
    puts pretty_array(@score_per_turn,    :round)
    puts "nodes per turn:"
    puts pretty_array(@nb_moves_per_turn, :round)
    puts "  #{round(@nb_moves_per_turn.inject(:+) / @nb_moves_per_turn.size)} on average"
    puts "time per turn:"
    puts pretty_array(@time_per_turn,     :pretty_time)
    puts "  #{pretty_time(@time_per_turn.inject(:+) / @time_per_turn.size)} on average for #{@time_per_turn.size} moves"
  end

  def nodes_per_second
    round(@current_turn_nodes.to_f/(Time.now-@start_time))
  end

private

  def pretty_array(a, proc)
    rv = []
    a.each_with_index { |item, index|
      if !item
        rv << "  #{index+1}. Human (#{@p.history[index][0]})"
      else
        rv << "  #{index+1}. #{method(proc).call(item)} (#{@p.history[index][0]})"
      end
      }
    rv.join("\n")
  end

end

