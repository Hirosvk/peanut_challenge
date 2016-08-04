require 'colorize'
require 'io/console'
require 'byebug'

class ComputerTerminal

  COMMANDS = {
    "^c" => :clear,
    "^h" => :reset_cursor,
    "^b" => :cursor_to_line_start,
    "^d" => :cursor_down,
    "^u" => :cursor_up,
    "^l" => :cursor_left,
    "^r" => :cursor_right,
    "^e" => :erase_char,
    "^i" => :set_insert_mode,
    "^o" => :set_overwrite_mode,
    "^^" => :input_circumflex,
    "^k" => :exit
  }

  def initialize(filename = nil)
    @filename = filename unless filename.nil?
    @cursor_pos = [0,0]
    @input = ""
    @input_mode = :overwrite
    @grid = Array.new(10){Array.new(10)}
  end

  def start
    puts "Welcome to My Terminal!"
    sleep(1)
    system('clear')
    input_from_file(@filename) if @filename
    while true
      render
      exiting = get_input
      break if exiting
      system('clear')
    end
  end

  def render
    print "\s\s0123456789\n------------\n"
    @grid.each_with_index do |row, idx_r|
      print idx_r.to_s + "|"
      row.each_with_index do |cell, idx_c|
        if cell.nil?
          new_cell = " "
        else
          new_cell = cell
        end
        if idx_r == @cursor_pos[0] && idx_c == @cursor_pos[1]
          print new_cell.colorize(:background => :red)
        else
          print new_cell
        end
      end
      print "\n"
    end
    puts "<input_mode: #{@input_mode}>"
    puts "enter '^k' to exit"
    print "input: #{@input}"
  end

  def input_from_file(filename)
    if File.exist?(filename)
      content = File.read(filename).gsub("\n", "")
      content.each_char do |char|
        process_input(char)
      end
    else
      puts "#{filename} was not found!"
      sleep(2)
    end
  end


  def get_input
    new_input = STDIN.getch
    return true if process_input(new_input) == :exit
    false
  end

  def process_input(new_input)
    if @input.length == 0
      if new_input == "^"
        @input += new_input
      elsif valid_char?(new_input)
        add_to_grid(new_input)
        reset_input
      end
    else
      @input += new_input
      if @input =~ /\^\d\d/
        self.move_cursor([@input[1].to_i, @input[2].to_i])
        reset_input
      elsif @input =~ /\^\d/
        # wait for another character input
        return
      else
        command = COMMANDS[@input]
        if command == :exit
          puts "exiting the program..."
          sleep(1)
          return command
        elsif command.nil?
          reset_input
        else
          self.send(command)
          reset_input
        end
      end
    end
  end


  def shift_one_letter_down(pos)
    got_nil = false
    new_grid = Array.new(10){Array.new(10)}

    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |col, col_idx|
        current_letter = @grid[row_idx][col_idx]
        if got_nil || row_idx < pos[0] || (row_idx == pos[0] && col_idx < pos[1])
          new_grid[row_idx][col_idx] = current_letter
        elsif !got_nil
          if is_space?(current_letter)
            got_nil = true
          elsif col_idx < 9
            new_grid[row_idx][col_idx+1] = current_letter
          elsif col_idx == 9 && row_idx < 9
            new_grid[row_idx+1][0] = current_letter
          end
        end
      end
    end
    @grid = new_grid
  end

  def shift_one_letter_up(pos)
    new_grid = Array.new(10){Array.new(10)}

    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |col, col_idx|
        current_letter = @grid[row_idx][col_idx]
        if row_idx < pos[0] || (row_idx == pos[0] && col_idx < pos[1])
          new_grid[row_idx][col_idx] = current_letter
        elsif col_idx > 0
          new_grid[row_idx][col_idx-1] = current_letter
        elsif col_idx == 0 && row_idx > 0
          new_grid[row_idx-1][9] = current_letter
        end
      end
    end
    @grid[9][9] = nil
    @grid = new_grid
  end

## COMMANDS methods
  def move_cursor(new_pos)
    @cursor_pos = new_pos
  end

  def add_to_grid(input)
    if @input_mode == :insert
      shift_one_letter_down(@cursor_pos)
    end
    @grid[@cursor_pos[0]][@cursor_pos[1]] = input
    advance_cursor
  end

  def advance_cursor
    if @cursor_pos[1] < 9
      @cursor_pos[1] += 1
    elsif @cursor_pos[1] == 9 && @cursor_pos[0] < 9
      @cursor_pos[0] += 1
      @cursor_pos[1] = 0
    end
  end

  def back_cursor
    if @cursor_pos[1] > 0
      @cursor_pos[1] -= 1
    elsif @cursor_pos[1] == 0 && @cursor_pos[0] > 0
      @cursor_pos[0] -= 1
      @cursor_pos[1] = 0
    end
   end

  def clear
    puts "clear"
    @grid = Array.new(10){Array.new(10)}
  end

  def reset_cursor
    @cursor_pos = [0,0]
  end

  def cursor_to_line_start
    @cursor_pos[1] = 0
  end

  def cursor_down
    @cursor_pos[0] += 1 unless @cursor_pos[0] == 9
  end

  def cursor_up
    @cursor_pos[0] -= 1 unless @cursor_pos[0] == 0
  end

  def cursor_right
    @cursor_pos[1] += 1 unless @cursor_pos[1] == 9
  end

  def cursor_left
    @cursor_pos[1] -= 1 unless @cursor_pos[1] == 0
  end

  def erase_char
    @grid[@cursor_pos[0]][@cursor_pos[1]] = nil
    if @input_mode == :insert
      shift_one_letter_up(@cursor_pos)
    end
  end

  def set_insert_mode
    @input_mode = :insert
  end

  def set_overwrite_mode
    @input_mode = :overwrite
  end

  def input_circumflex
    add_to_grid("^")
  end

  ## other helper methods
  def valid_char?(char)
    !(char =~ /[\r\n\t\e]/)
  end

  def is_space?(letter)
    letter.nil? || letter == " "
  end

  def reset_input
    @input = ""
  end

end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length == 0
    terminal = ComputerTerminal.new
  else
    terminal = ComputerTerminal.new(ARGV[0])
  end
  terminal.start
end
