require './piece'
require './game'
require './errors'
require 'colorize'
require 'byebug'

class Board
  attr_accessor :grid
  BLACK_POSITIONS = {
    :rook => [[0,0], [0,7]],
    :knight => [[0,1], [0,6]],
    :bishop => [[0,2], [0,5]],
    :queen => [[0,3]],
    :king => [[0,4]],
    :pawn => [[1,0], [1,1], [1,2], [1,3], [1,4], [1,5], [1,6], [1,7]]
  }

  WHITE_POSITIONS = {
    :rook => [[7,0], [7,7]],
    :knight => [[7,1], [7,6]],
    :bishop => [[7,2], [7,5]],
    :queen => [[7,3]],
    :king => [[7,4]],
    :pawn => [[6,0], [6,1], [6,2], [6,3], [6,4], [6,5], [6,6], [6,7]]
  }

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    setup
  end

  def inspect
    display = grid.map do |row|
      row.map do |piece|
        if piece.nil?
          "    "
        elsif piece.color == :black
          case piece.symbol
          when :king
            "KING".blue
          when :queen
            "QUEN".blue
          when :rook
            "ROOK".blue
          when :bishop
            "BISH".blue
          when :knight
            "KNIT".blue
          when :pawn
            "PAWN".blue
          end
        else
          case piece.symbol
          when :king
            "KING".red
          when :queen
            "QUEN".red
          when :rook
            "ROOK".red
          when :bishop
            "BISH".red
          when :knight
            "KNIT".red
          when :pawn
            "PAWN".red
          end
        end
      end.join('|')
    end
    puts display
  end


  def [](pos)
    row, col = pos
    grid[row][col]
  end

  def []=(pos, piece)
    row, col = pos
    grid[row][col] = piece
    piece.pos = pos unless piece.nil?
  end


  def setup
    BLACK_POSITIONS.each do |piece, positions|
      positions.each do |position|
        self[position] = Piece.create(piece, position, :black, self)
      end
    end

    WHITE_POSITIONS.each do |piece, positions|
      positions.each do |position|
        self[position] = Piece.create(piece, position, :white, self)
      end
    end
  end

  def in_check?(color)
    king_position = find_piece(:king, color)[0]
    can_check?(king_position)
  end

  def can_check?(king_position)
    grid.any? do |row|
      row.any? do |piece|
        # byebug if !piece.nil? && piece.color == :black && piece.pos == [7,0]
        piece && piece.moves.include?(king_position)
      end
    end
  end

  def checkmate?(color)
    if in_check?(color)
      color_pieces = self.grid.flatten.select { |piece| piece && piece.color == color }
      color_pieces.all? { |piece| piece.valid_moves.empty? }
    end
  end

  def find_piece(type, color)
    positions = []
    (0..7).each do |row|
      (0..7).each do |col|
        piece = self[[row,col]]
        next unless piece
        positions << [row, col] if piece.symbol == type && piece.color == color
      end
    end
    positions
  end


  def move(start, end_pos)
    raise MoveError.new "No piece at start position." if self[start].nil?
    possible_moves = self[start].moves
    raise MoveError.new "Can't move there." unless possible_moves.include?(end_pos)
    valid_moves = self[start].valid_moves
    raise MoveError.new "You will be in check!" unless valid_moves.include?(end_pos)
    self[end_pos] = nil
    self[end_pos] = self[start]
    self[start] = nil
  end

  def move!(start, end_pos)
    self[end_pos] = nil
    self[end_pos] = self[start]
    self[start] = nil
  end

  def dup
    new_board = Board.new
    grid.each_with_index do |row, row_i|
      row.each_with_index do |piece, col_i|
        piece.nil? ? new_board[[row_i,col_i]] = nil : new_board[[row_i,col_i]] = piece.dup(new_board)
      end
    end
    new_board
  end

end
