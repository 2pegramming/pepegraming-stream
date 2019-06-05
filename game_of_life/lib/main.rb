
class Cell
  def initialize(alive = false)
    @alive = !!alive
    @will_change = true
  end

  def alive?
    @alive
  end

  def live!
    @alive = true
  end

  def die!
    @alive = false
  end

  def to_s
    alive? ? 'x' : '.'
  end

  def will_change?
    @will_change
  end

  def change!
    @alive = !@alive if @will_change
  end

  def check(life_neighbours)
    if alive?
      @will_change = !(2..3).include?(life_neighbours)
    else
      @will_change = life_neighbours == 3
    end
  end

  def inspect
    "#{self.class}: #{alive? ? 'alive' : 'dead'}"
  end
end

class Grid
  RELATIVE_NEIGHBOUR_COORDINATES = {
    north: [-1, 0].freeze, north_east: [-1, 1].freeze,
    east:  [0, 1].freeze,  south_east: [1, 1].freeze,
    south: [1, 0].freeze,  south_west: [1, -1].freeze,
    west:  [0, -1].freeze, north_west: [-1, -1].freeze,
  }.freeze

  def initialize(width, height, cells = [])
    @cells = Array.new(width * height).map! { Cell.new }
    @grid = @cells.each_slice(width).to_a

    cells.each { |coordinate| @grid.dig(*coordinate).live! }
  end

  def evolve
    @grid.each_with_index do |line, y|
      line.each_with_index do |cell, x|
        cell.check(life_neighbours_count(x, y))
      end
    end

    @cells.each(&:change!)
  end

  def lifeness?
    return true if @cells.none?(&:alive?)
    return true if @cells.map(&:will_change?).all?(false)

    false
  end

  def life_neighbours_count(x, y)
    neighbours(x, y).count(&:alive?)
  end

  def neighbours(x, y)
    RELATIVE_NEIGHBOUR_COORDINATES.map do |position_name, (relative_y, relative_x)|
      next if y + relative_y < 0 || x + relative_x < 0
      @grid.dig(y + relative_y, x + relative_x)
    end.compact
  end

  def to_s
    @grid.map { |line| line.map(&:to_s).join }.join("\n")
  end
end

class Game
  def call(width, height, cells = [])
    system('clear')
    grid = Grid.new(width, height, cells)

    puts grid

    until grid.lifeness?
      grid.evolve

      sleep 0.3
      system('clear')
      puts grid
      puts
    end
  end
end

# g = Grid.new(10, 10, [[0,2], [1,0], [1,2], [2,1], [2,2]])
# p g.life_neighbours_count(1, 1) # => ListOfCells
#
# puts '*'*80
#
# p g.life_neighbours_count(1, 2)
#
# puts '*'*80
#
# p g.life_neighbours_count(0, 0)
#
# puts '*'*80
#
# p g.neighbours(9, 9)
# p g.life_neighbours_count(9, 9)

# Game.new.call(10, 10, [[0,2], [1,0], [1,2], [2,1], [2,2]])
Game.new.call(10, 10, [
  [9, 9], [9, 8], [8, 9], [8, 8], # block
  [0,2], [1,0], [1,2], [2,1], [2,2] # glider
])

