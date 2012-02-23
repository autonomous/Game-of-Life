require_relative 'game_of_life'

god = God.blinker

God.glider.cells.each do |cell|
  god.add cell
end

world = World.new

Simulation.tick(60) do
  sleep(0.1)
  world.draw god.cells.map(&:position)
  god.evolve
end