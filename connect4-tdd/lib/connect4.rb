class Player
    attr_reader :name, :symbol
  
    def initialize(name, symbol)
      @name = name ? name : get_name
      @symbol = symbol ? symbol : get_symbol
    end
  
    def get_name
      puts "Enter player name: "
      name = gets.chomp
    end
  

    def get_symbol
      while true
        puts "Enter your symbol: "
        symbol = gets.chomp
        break if symbol.size == 1
      end
      symbol
    end
  end

class Game
  attr_accessor :grid, :player1, :player2, :turn

  def initialize(player_1, player_2)
      @player1 = player_1
      @player2 = player_2
      @grid = Array.new(7) { Array.new(6, '○') } 
      @turn = @player1
  end

  def get_column
    while true
      puts "Where would you like to drop your marker, #{turn.name}?"
      column = gets.chomp.to_i
      tmp = grid
      break if column.positive? && column <= 7 && tmp[column][-1] == '○'
    end
    column
  end

  def print_grid
    tmp = grid
    for i in 1..6
      for j in 0..6
        print tmp[j][-(i)]
        print ' '
      end
      print "\n"
    end
    for k in 1..7
      print k
      print ' '
    end
  end

  def place_marker(column)
    # full column case?
    col = column ? column - 1 : get_column
    tmp = grid
    for i in 0..5
      if tmp[col][i] == '○'
        tmp[col][i] = turn.symbol
        self.grid = tmp
        check_win(col, i, turn.symbol)
        break
      end
    end
  end

  def check_win(col, row, symbol)
    # to do
    tmp = grid
    # vertical check
    if (grid[col].count(symbol) == 4) ||
      (tmp.collect_concat { |col| col[row] }.count(symbol) >= 4) ||
      diagonal_check(col, row, symbol) == true
      puts "#{turn.name} won. Congrats!"
      return true
    end
  end

  def switch_turn
    self.turn = turn == player1 ? player2 : player1
  end

  def diagonal_check(col, row, symbol)
    # diagonal
    tmp = grid
    diagonal = [tmp[col][row]]
    c = col - 1
    r = row - 1
    unless col == 0 || row == 0
      until c == 0 || r == 0 do 
        diagonal.prepend(tmp[c][r])
        c -= 1
        r -= 1
      end
    end
    c = col + 1
    r = row + 1
    unless col == 6 || row == 5
      until c == 6 || r == 5 do
        diagonal.append(tmp[c][r])
        c += 1 
        r += 1
      end
    end
    if diagonal.count(symbol) >= 4
      return true
    end
  
    # antidiagonal
    anti = [tmp[col][row]]
    c = col + 1
    r = row - 1
    unless col == 6 || row == 0
      until c == 6 || r == 0 do 
        anti.prepend(tmp[c][r])
        c += 1
        r -= 1
      end
    end
    c = col - 1
    r = row + 1
    unless col == 0 || row == 5
      until c == 0 || r == 5 do
        anti.append(tmp[c][r])
        c -= 1
        r += 1
      end
    end
    if anti.count(symbol) >= 4
      return true
    end
  
    return false
  end
  
end

p1 = Player.new('sa', 'X')
p2 = Player.new('da', 'O')
game = Game.new(p1, p2)
game.place_marker(1)