# encoding: utf-8
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

  SYMBOL_HASH = {
    :white => {:king =>'♔',
      :queen => "♕", :rook => "♖",
      :bishop => "♗", :knight => "♘", :pawn => "♙"},
    :black => {:king => "♚",
        :queen => "♛", :rook => "♜",
        :bishop => "♝", :knight => "♞", :pawn => "♟"}
      }

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    setup
  end

  def inspect
    puts "BOARD!"
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

  def in_check?(color)
    king_position = find_pieces(color).select{ |piece| piece.symbol == :king}[0].pos
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
      color_pieces = self.grid.flatten.compact.select { |piece| piece.color == color }
      color_pieces.all? { |piece| piece.valid_moves.empty? }
    end
  end

  def find_pieces(color)
    grid.flatten.compact.select { |piece| piece.color == color}
  end

  def on_board?(pos)
    pos.all? do |p|
      p.between?(0, 7)
    end
  end

  def empty?(pos)
    return self[pos].nil? unless pos == nil
    return false
  end

  def move(start, end_pos)
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

  def render(cursor_position = [0,0], message = "")
    system('clear')
    display = grid.map.with_index do |row, row_i|
      row.map.with_index do |piece, col_i|
        if [row_i, col_i] == cursor_position
          if piece.nil?
            "*".blue
          else
            SYMBOL_HASH[piece.color][piece.symbol].blue
          end
        else
          if piece.nil?
            " "
          else
            SYMBOL_HASH[piece.color][piece.symbol]
          end
        end
      end.join(' | ')
    end
    j = 8
    display.each_with_index do |row, i|
      display[i] = "#{j} |" + row
      j -= 1
    end

    puts "   a   b   c   d   e   f   g   h"
    puts display
    puts message
  end

  private

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

end
