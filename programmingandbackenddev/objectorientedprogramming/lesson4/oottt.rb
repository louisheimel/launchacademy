require 'pry'
class Board
  WINNING_LINES = [[1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 2, 3],
                   [4, 5, 6], [7, 8, 9], [1, 5, 9], [3, 5, 7]]
  attr_reader :marker, :squares
  def initialize
    @squares = {}
    reset
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts '     |     |'
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts '     |     |'
  end
  # rubocop:enable Metrics/AbcSize

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)      # => we wish this method existed
        return squares.first.marker             # => return the marker, whatever it is
      end
    end
    nil
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def to_s
    @marker
  end
end

class Player
  attr_reader :marker
  attr_accessor :score, :name

  def initialize(marker)
    @marker = marker
    @score = 0
    @name == ''
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  GOES_FIRST = COMPUTER_MARKER

  attr_accessor :board, :human, :computer

  def play
    display_welcome_message

    loop do
      clear_screen_and_display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end
      update_scores
      display_result
      display_scores
      break if game_won?
      break unless play_again? 
      reset
      display_play_again_message
    end
    display_winner
    display_goodbye_message
  end

  private

  def pick_marker
    puts "What's your marker?"
    gets.chomp
  end

  def initialize
    @board = Board.new
    @human = Player.new(pick_marker)
    @computer = Player.new(COMPUTER_MARKER)
    puts "What is the human's name?"
    @human.name = gets.chomp
    puts "What is the computer's name?"
    @computer.name = gets.chomp

    @first_to_move = ''
    if GOES_FIRST == 'choose'
      puts "Would you like to go first? (y n)"
      choice = gets.chomp
      if choice.downcase.include?('y')
        @first_to_move = HUMAN_MARKER
      else
        @first_to_move = COMPUTER_MARKER
      end
    elsif GOES_FIRST == COMPUTER_MARKER
      @first_to_move = COMPUTER_MARKER
    else
      @first_to_move = HUMAN_MARKER
    end
    @current_marker = @first_to_move
  end

  def update_scores
    case board.winning_marker
    when human.marker
      human.score += 1
    when computer.marker
      computer.score += 1
    end
  end

  def game_won?
    human.score >= 5 || computer.score >= 5
  end

  def display_winner
    if human.score >= 5
      puts "You won the game!"
    elsif computer.score >= 5
      puts "Computer won the game."
    end
  end

  def joinor(arr, delimiter = ', ', conjunction = 'or')
    result = ''
    arr[0...-1].each { |num| result += num.to_s + delimiter }
    if arr.size > 1
      result += conjunction + ' ' + arr[-1].to_s
    else
      result += arr[-1].to_s
    end
    result
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def attack_here
    Board::WINNING_LINES.each do |line|
      count = 0
      line.each do |index|
        if board.squares[index].marker == COMPUTER_MARKER
          count += 1
        end
      end
      if count == 2
        line.each do |index|
          if board.squares[index].marker == ' '
            return index
          end
        end
      end
    end
    nil
  end

  def defend_here
    Board::WINNING_LINES.each do |line|
      count = 0
      line.each do |index|
        if board.squares[index].marker == HUMAN_MARKER
          count += 1
        end
      end
      if count == 2
        line.each do |index|
          if board.squares[index].marker == ' '
            return index
          end
        end
      end
    end
    nil
  end

  def computer_moves
    if board.unmarked_keys.include?(5)
      square = 5
    elsif attack_here
      square = attack_here
    elsif defend_here
      square = defend_here
    else
      square = board.unmarked_keys.sample
    end
    board[square] = COMPUTER_MARKER
  end

  def display_welcome_message
    puts 'Welcome to Tic Tac Toe!'
    puts ''
    puts 'Pick your marker!'
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe! Goodbye!'
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts ''
    board.draw
    puts ''
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_scores
    puts "#{human.name} has: #{human.score} points"
    puts "#{computer.name} has: #{computer.score} points"
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "#{human.name} won!"
    when computer.marker
      puts "#{computer.name} won."
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts 'Sorry, must be y or n'
    end

    answer == 'y'
  end

  def clear
    system 'clear'
  end

  def reset
    board.reset
    @current_marker = @first_to_move
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end

  def current_player_moves
    if @current_marker == HUMAN_MARKER
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end
end

game = TTTGame.new
game.play
