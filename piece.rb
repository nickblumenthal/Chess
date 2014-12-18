# encoding: utf-8
require './board'
require './game'

class Piece
  attr_accessor :pos
  attr_reader :color, :board, :symbol

  DIAGONAL = [
    [-1, -1],
    [1, 1],
    [-1, 1],
    [1, -1]
  ]

  ORTHOGONAL = [
    [1, 0],
    [-1, 0],
    [0, 1],
    [0, -1]
  ]

  def initialize(pos, color, board)
    @pos, @color, @board = pos, color, board
  end

  def moves
  end

  def dup(new_board)
    # self.class.new()
    Piece.create(symbol, pos, color, new_board)
  end

  def inspect
    puts "#{self.class}"
  end

  def self.create(type_piece, pos, color, board)
    case type_piece
    when :rook
      Rook.new(pos, color, board)
    when :knight
      Knight.new(pos, color, board)
    when :bishop
      Bishop.new(pos, color, board)
    when :queen
      Queen.new(pos, color, board)
    when :king
      King.new(pos, color, board)
    else
      Pawn.new(pos, color, board)
    end
  end

  def valid_moves
    moves.reject do |move|
      move_into_check?(move)
    end
  end

  def move_into_check?(end_pos)
    new_board = board.dup
    new_board.move!(pos, end_pos)
    new_board.in_check?(self.color)
  end
end

class SlidingPieces < Piece
  # def get_move(offset)
  #   [offset[0] + pos[0], offset[1] + pos[1]]
  # end

  def moves(offsets)
    possible_moves = []
    offsets.each do |offset|
      row, col = pos
      move = [offset[0] + row, offset[1] + col]
      while board.on_board?(move)
        break if board[move] && board[move].color == color
        possible_moves << move
        break if board[move] && board[move].color != color
        move = [move[0] + offset[0], move[1] + offset[1]]
      end
    end

    possible_moves
  end
end

class SteppingPieces < Piece
  def moves(offsets)
    possible_moves = []
    row = pos[0]
    col = pos[1]
    offsets.each do |offset|
      move = [row + offset[0], col + offset[1]]
      if board.on_board?(move) && (board[move].nil? || board[move].color != color)
        possible_moves << move
      end
    end
    
    possible_moves
  end
end

class Queen < SlidingPieces
  def initialize (pos, color, board)
    super(pos, color, board)
    @symbol = :queen
  end

  def moves
    super(DIAGONAL + ORTHOGONAL)
  end
end

class Rook < SlidingPieces
  def initialize (pos, color, board)
    super(pos, color, board)
    @symbol = :rook
  end

  def moves
    super(ORTHOGONAL)
  end
end

class Bishop < SlidingPieces
  def initialize (pos, color, board)
    super(pos, color, board)
    @symbol = :bishop
  end

  def moves
    super(DIAGONAL)
  end
end

class Knight < SteppingPieces
  OFFSETS = [
    [2,   1],
    [1,   2],
    [-2,  1],
    [-1,  2],
    [-2, -1],
    [-1, -2],
    [2,  -1],
    [1,  -2],
  ]

  def initialize (pos, color, board)
    super(pos, color, board)
    @symbol = :knight
  end

  def moves
    super(OFFSETS)
  end

end

class King < SteppingPieces
  def initialize (pos, color, board)
    super(pos, color, board)
    @symbol = :king
  end

  def moves
    super(DIAGONAL + ORTHOGONAL)
  end
end

class Pawn < SteppingPieces
  DIAGONAL = {
    :black => [[1, -1], [1, 1]],
    :white => [[-1, -1], [-1, 1]]
  }

  def initialize (pos, color, board)
    super(pos, color, board)
    @symbol = :pawn
  end

  def moves
    possible_moves = []
    starting_row = (color == :black ? 1 : 6)
    direction = (color == :black ? 1 : -1)
    if pos[0] == starting_row
      possible_moves << [pos[0] + direction, pos[1]]
      possible_moves << [pos[0] + (direction * 2), pos[1]]
    else
      possible_moves << [pos[0] + direction, pos[1]]
    end
    possible_moves.select! { |move| board.on_board?(move) }
    possible_moves.select! { |move| board.empty?(move) }

    DIAGONAL[color].each do |offset|
      row, col = offset
      move = [pos[0] + row, pos[1] + col]
      next unless board.on_board?(move)
      test_pos = board[move]
      if test_pos && test_pos.color != color
        possible_moves << test_pos.pos
      end
    end

    possible_moves
  end
end
