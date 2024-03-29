class Game
  attr_accessor :codemaker, :codebreaker, :board

  def initialize(codemaker, codebreaker, board)
    @codemaker = codemaker
    @codebreaker = codebreaker
    @board = board
  end

  def self.code_retriever
    while true
      code = gets.chomp.split('')
      if code.length == 4 && (code.all? { |element| element.to_i >= 1 && element.to_i <= 6 })
        break
      else
        puts 'Enter valid code.'
      end
    end
    code.map(&:to_i)
  end

  def give_hints(code, guess)
    hints = []
    code2 = code.dup
    guess2 = guess.dup
    for i in 0..3
      if code2[i] == guess[i]
        code2[i] = 'A'
        guess2[i] = 'A'
        hints.append('p')
      end
    end

    code2 = code2.partition { |a| a != 'A' }[0]
    guess2 = guess2.partition { |a| a != 'A' }[0]
    code_e = code2.uniq
    guess_e = guess2.uniq

    for i in code_e
      if guess_e.include?(i)
        if code2.count(i) >= guess2.count(i)
          hints.concat(Array.new(guess2.count(i), 'e'))
        else
          hints.concat(Array.new(code2.count(i), 'e'))
        end
      end
    end
    hints.concat(Array.new(4 - hints.length, '○'))

    hints.shuffle
  end

  def self.instructions
    puts "Hello and welcome to Mastermind on the command line against the computer!
- Please enter your guess in the form '1234' where each digit of the guess is a number 1-6
- There can be any duplicate digits in the code
- For the hints, 'p' will be shown for a perfect guess, 'e' will be shown for a guess which exists in the code
- There are 12 maximum turns to guess the code
- Guesses will be on the left and hints will be on the right of the game board
- The computer does not use any algorithm for guessing your code, so there is a fair chance of you winning.

What would you like to be? Enter 0 for codemaker and 1 for codebreaker."
  end

  def play
    if codemaker.name == 'computer'
      turns = 1
      code = codemaker.code
      while turns <= 12
        puts "Turn #{turns}:"
        board.print
        puts 'Enter your guess: '
        guess = Game.code_retriever
        guesses = board.guesses
        guesses[turns - 1] = guess
        board.guesses = guesses
        hints = board.hints
        hints[turns - 1] = give_hints(code, guess)
        board.hints = hints
        turns += 1
        if code.join == guess.join
          puts "Turn #{turns}"
          board.print
          puts 'You win! Congrats.'
          exit
        end
      end
      puts "Oof, you lose. Better luck next time. The code was #{code.join}"
      exit
    else
      turns = 1
      code = codemaker.code
      while turns <= 12
        puts "Turn #{turns}:"
        board.print
        prev_guesses = board.guesses
        guess = turns != 1 ? codebreaker.next_guess(code, prev_guesses[turns - 2]) : [1, 1, 2, 2]
        guesses = board.guesses
        guesses[turns - 1] = guess
        board.guesses = guesses
        hints = board.hints
        hints[turns - 1] = give_hints(code, guess)
        board.hints = hints
        turns += 1
        if code.join == guess.join
          puts "Turn #{turns}"
          board.print
          puts 'The computer guessed the code successfully.'
          exit
        end
      end
      puts 'The computer lost. Congratulations!'
    end
  end
end

class Board
  attr_accessor :guesses, :hints

  def initialize
    @guesses = Array.new(12, ['⬤', '⬤', '⬤', '⬤'])
    @hints = Array.new(12, ['○', '○', '○', '○'])
  end

  def print
    puts '╔═════════════╦═════════╗'
    for i in 0..11 do
      puts "║ #{@guesses[i][0]}  #{@guesses[i][1]}  #{@guesses[i][2]}  #{@guesses[i][3]}  ║ #{@hints[i][0]} #{@hints[i][1]} #{@hints[i][2]} #{@hints[i][3]} ║"
      puts '╠═════════════╬═════════╣' unless i == 11
    end
    puts '╚═════════════╩═════════╝'
  end
end

class Codemaker
  attr_reader :name, :code

  def initialize(name, code = [Random.rand(1..6), Random.rand(1..6), Random.rand(1..6), Random.rand(1..6)])
    @name = name
    @code = code
  end
end

class Codebreaker
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def next_guess(code, prev_guess)
    # my own strategy (includes cheating lmao)
    next_guess = []
    code2 = code.dup
    guess2 = prev_guess.dup
    perfect_guesses = Hash.new([])

    for i in 0..3
      if code2[i] == prev_guess[i]
        # saves perfect guess as it is
        # fix this, put array in hash as value
        perfect_guesses[code2[i]] = perfect_guesses[code2[i]].append(i)
        code2[i] = 'A'
        guess2[i] = 'A'
      end
    end
    p perfect_guesses

    code2 = code2.partition { |a| a != 'A' }[0]
    guess2 = guess2.partition { |a| a != 'A' }[0]
    code_e = code2.uniq
    guess_e = guess2.uniq

    for i in code_e
      if guess_e.include?(i)
        if code2.count(i) >= guess2.count(i)
          next_guess.concat(Array.new(guess2.count(i), i))
        else
          next_guess.concat(Array.new(code2.count(i), i))
        end
      end
    end
    e = perfect_guesses.values.flatten.length
    (4 - (next_guess.length + e)).times { next_guess.append(Random.rand(1..6)) }
    next_guess = next_guess.shuffle

    # puts perfect guesses at their right places
    perfect_guesses.each do |k, v|
      for i in v
        next_guess.insert(i, k)
      end
    end

    next_guess
  end
end

def start
  Game.instructions
  # know whether user will be codemaker or codebreaker
  while true
    choice = gets.chomp
    if %w[0 1].include?(choice)
      break
    else
      puts 'Enter valid choice.'
    end
  end

  # get name, initialise class instances
  choice = choice.to_i
  puts 'Please enter your name: '
  name_of_user = gets.chomp
  case choice
  when 0
    puts 'Enter your secret code.'
    code = Game.code_retriever
    codebreaker = Codebreaker.new('computer')
    codemaker = Codemaker.new(name_of_user, code)
  when 1
    codemaker = Codemaker.new('computer')
    codebreaker = Codebreaker.new(name_of_user)
  end

  # initialise new game
  game = Game.new(codemaker, codebreaker, Board.new)
  game.play
end

start
