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

  def moves(offsets)
    possible_moves = []
    offsets.each do |offset|
      row = pos[0]
      col = pos[1]
      while (offset[0] + row).between?(0,7) &&
            (offset[1] + col).between?(0,7)

        break if board[[offset[0] + row, offset[1] + col]] &&
                 board[[offset[0] + row, offset[1] + col]].color == color

        possible_moves << [offset[0] + row, offset[1] + col]

        break if board[[offset[0] + row, offset[1] + col]] &&
                 board[[offset[0] + row, offset[1] + col]].color != color
        row, col = offset[0] + row, offset[1] + col
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
      # if empty? or has_enemy?
      if (offset[0] + row).between?(0,7) &&
          (offset[1] + col).between?(0,7) &&
          (board[[offset[0] + row, offset[1] + col]].nil? ||
          board[[offset[0] + row, offset[1] + col]].color != color)

        possible_moves << [offset[0] + row, offset[1] + col]
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
    if color == :black && pos[0] == 1
      possible_moves << [2, pos[1]]
      possible_moves << [3, pos[1]]
    elsif color == :white && pos[0] == 6
      possible_moves << [5, pos[1]]
      possible_moves << [4, pos[1]]
    elsif color == :black
      possible_moves << [pos[0] + 1, pos[1]]
    else
      possible_moves << [pos[0] - 1, pos[1]]
    end
    possible_moves.reject! { |move| move.any? { |idx| !idx.between?(0,7) } }
    possible_moves.select!{ |move| board[move].nil? } unless possible_moves.empty?

    DIAGONAL[color].each do |offset|
      row, col = offset
      next if !(pos[0] + row).between?(0,7) || !(pos[1] + col).between?(0,7)
      test_pos = board[[pos[0] + row, pos[1] + col]]
      if test_pos && test_pos.color != color
        possible_moves << test_pos.pos
      end
    end

    possible_moves
  end

end
