class World

  def initialize(x=40, y=40)
    @x, @y = x, y
  end

  def draw(positions)
    system('clear')
    grid = Array.new(@x)

    positions.each do |position|
      x = position[:x] % @x 
      y = position[:y] % @y

      grid[x] ||= Array.new(@y, '|___')
      grid[x][y] = '|_0_'
    end

    puts ' ' + Array.new(@x, '___').join(' ')
    grid.each do |row|
      row ||= Array.new(@y, '|___')
      puts row.join + '|'
    end
  end
end

class Simulation
  def self.tick(turns)
    turns.times do |i|
      yield i
    end
  end
end

class God
  def self.blinker
    new.tap do |god|
      god.add Cell.new(x: 11, y: 12)
      god.add Cell.new(x: 11, y: 11)
      god.add Cell.new(x: 11, y: 10)
    end
  end

  def self.block
    new.tap do |god|
      god.add Cell.new(x: 23, y: 24)
      god.add Cell.new(x: 24, y: 23)
      god.add Cell.new(x: 23, y: 23)
      god.add Cell.new(x: 24, y: 24)
    end
  end

  def self.glider
    new.tap do |god|
      god.add Cell.new(x: 21, y: 20)
      god.add Cell.new(x: 22, y: 20)
      god.add Cell.new(x: 20, y: 21)
      god.add Cell.new(x: 21, y: 21)
      god.add Cell.new(x: 22, y: 22)
    end
  end

  def initialize
    @cells      = []
    @new_cells  = []
    @dead_cells = []
  end

  def add(cell)
    @cells << cell unless include?(cell)
  end

  def include?(cell)
    @cells.any? { |c| c.position == cell.position }
  end

  def cells
    @cells.dup
  end

  def neighbours( cell )
    cells.select do |c|
      c.adjacent?(cell)
    end
  end

  def evolve
    @dead_cells = determine_dead_cells
    @new_cells  = determine_new_cells

    evolved_cells = @cells - @dead_cells + @new_cells
    [@cells, @dead_cells, @new_cells].each{ |collection| collection.clear}
    evolved_cells.each{ |cell| add(cell) }
  end

  private
    def determine_dead_cells
      @cells.select do |cell|
        n = self.neighbours(cell)
        if n.size < 2 || n.size > 3
          cell
        end  
      end
    end
    
    def determine_new_cells
      new_cells = []

      @cells.each do |cell|
        position = cell.position.dup
        range = [-1, 0, 1]

        range.each do |dx|
          x = position[:x] + dx
          range.each do |dy|  
            y = position[:y] + dy
            new_cell = Cell.new(x: x, y: y)
            if(!self.include?(new_cell) && self.neighbours(new_cell).size == 3)
              new_cells << new_cell
            end
          end
        end
      end

      new_cells
    end
end

class Cell
  attr_reader :position

  def initialize(position={})
    @position = {x: 0, y: 0}.merge( position )
  end

  def adjacent?(other_cell)
    return false if position == other_cell.position
    [].tap do |arr|
      other_cell.position.each_pair do |k, v|
        in_range = ((@position[k] - other_cell.position[k])**2 <= 1)
        arr << in_range
      end    
    end.all?
  end
end
