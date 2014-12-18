require './board'
require './piece'

class ComputerPlayer
  attr_accessor :board

  PIECE_VALUE = {
    :king => 100,
    :queen => 9,
    :rook => 5,
    :bishop => 3,
    :knight => 3,
    :pawn =>1
  }

  def initialize(board = nil)
    @board = board
  end

  def make_move(color)
    start_pos = nil
    end_pos = nil
    capturing_moves = []
    my_pieces = board.find_pieces(color)

    #Look for capturing moves
    my_pieces.each do |piece|
      capturing_moves += capture_moves(piece, color)
    end

    #Choose best capture move
    unless capturing_moves.empty?
      best_move = []
      best_value = 0
      capturing_moves.each do |start_pos, end_pos|
        captured_piece = board[end_pos]
        captured_value = PIECE_VALUE[captured_piece.symbol]
        if captured_value > best_value
          best_move = [start_pos, end_pos]
          best_value = captured_value
        end
      end
      return best_move
    end

    #If no cap moves, make random move
    while end_pos.nil?
      pieces = board.find_pieces(color)
      start_pos = pieces.sample.pos
      next if start_pos.nil?
      end_pos = board[start_pos].valid_moves.sample
    end
    [start_pos, end_pos]
  end

  def turn(color)
    move = make_move(color)
    board.move(move[0], move[1])
    board.render(move[1])
  end

  def capture_moves(piece, color)
    capturing_moves = []
    other_pieces_pos = other_pieces(color).map { |piece| piece.pos }
    my_moves = piece.valid_moves
    my_moves.each do |move|
      if other_pieces_pos.include?(move)
        capturing_moves << [piece.pos, move]
      end
    end

    capturing_moves
  end

  def other_pieces(color)
    other_color = (color == :black ? :white : :black)
    other_pieces = board.find_pieces(other_color)
  end

end

class HumanPlayer
  attr_accessor :board

  def initialize(board = nil)
    @board = board
  end

  def turn(color)
    message = "It's #{color}'s turn \nWhich piece do you want to move?"
    board.render([0,0], message)
    start_pos = kb_user_input([0,0])

    raise MoveError.new "No piece at start position." if board[start_pos].nil?
    raise MoveError.new "Wrong color" unless board[start_pos].color == color

    message = "Where do you want to move it?"
    board.render(start_pos.dup, message)
    end_pos = kb_user_input(start_pos.dup)
    board.move(start_pos, end_pos)
  rescue MoveError => e
    puts "#{e.message}"
    board.render(start_pos.dup, "#{e.message}\nHit any key to continue")
    retry if STDIN.getch
  end

  def kb_user_input(current_pos = [0,0])
    input = STDIN.getch

    unless input == "\r"
      system('clear')
      case input
      when 'w'
        current_pos[0] -= 1 if current_pos[0].between?(1,7)
      when 'a'
        current_pos[1] -= 1 if current_pos[1].between?(1,7)
      when 's'
        current_pos[0] += 1 if current_pos[0].between?(0,6)
      when 'd'
        current_pos[1] += 1 if current_pos[1].between?(0,6)
      when 'q'
        exit
      end
      # Print board with new cursor position
      board.render(current_pos)
      kb_user_input(current_pos)
    end

    current_pos
  end

end
