require './player.rb'

class SmarterPlayer < ComputerPlayer

  def initialize
    super
  end

  def will_be_captured(color)
    escape_moves = []
    opponent = other_pieces(color)
    opponent.each do |piece|
      piece.valid_moves.each do |move|
        if board[move] && board[move].color == color
          start_pos = move
          end_pos = board[move].valid_moves.sample
          escape_moves << [start_pos, end_pos] unless end_pos.nil?
        end
      end
    end
    best_escape_piece = nil
    best_escape_value = 0
    escape_moves.each do |escape_move|
      escape_piece = board[escape_move[0]]
      escape_value = PIECE_VALUE[escape_piece.symbol]
      if escape_value > best_escape_value
        best_escape_value = escape_value
        best_escape_piece = escape_piece
      end
    end

    best_escape_piece
  end

  def make_move(color)
    escape_piece = will_be_captured(color)
    if escape_piece.nil?
      super
    else
      start_pos = escape_piece.pos
      end_pos = escape_piece.valid_moves.sample
      return [start_pos, end_pos]
    end
  end
end
