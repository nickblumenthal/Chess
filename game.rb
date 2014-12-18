# encoding: utf-8
require './board'
require './piece'
require './player'
require './smarter_player'
require 'io/console'

class Game
  attr_reader :board, :player1, :player2

  def initialize(player1, player2)
    @board, @player1, @player2 = Board.new, player1, player2
    @player1.board, @player2.board = @board, @board
  end

  def run
    until board.checkmate?(:black) || board.checkmate?(:white)
      player1.turn(:black)
      sleep(0.25)if player1.is_a?(ComputerPlayer)
      player2.turn(:white) unless board.checkmate?(:white)
      sleep(0.25) if player2.is_a?(ComputerPlayer)
    end

    if board.checkmate?(:black)
      board.render([0,0],"White won!")
    else
      board.render([0,0],"Black won!")
    end
  end


  # def kb_user_input(current_pos = [0,0])
  #   #system('clear')
  #   board.render(current_pos)
  #   chr = ''
  #   input = ''
  #   until chr == '[C'
  #     chr = STDIN.getch
  #     input += chr
  #   end
  #
  #   case input
  #   when '\e[A'
  #     current_pos[0] -= 1 if current_pos[0].between?(0,7)
  #   when '\e[D'
  #     current_pos[1] -= 1 if current_pos[1].between?(0,7)
  #   when '\e[B'
  #     current_pos[0] += 1 if current_pos[0].between?(0,7)
  #   when '\e[C'
  #     current_pos[1] += 1 if current_pos[1].between?(0,7)
  #     kb_user_input(current_pos)
  #   end
  #
  #   #system('clear')
  #   current_pos
  # end

end

if __FILE__ == $PROGRAM_NAME
  hp = HumanPlayer.new
  cp = SmarterPlayer.new
  cp2 = ComputerPlayer.new
  g = Game.new(cp2, cp)
  g.run
end
