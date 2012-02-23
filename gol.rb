require_relative 'game_of_life'

god = God.blinker

God.glider.cells.each do |cell|
  god.add cell
end

world = World.new

Simulation.tick(50) do |turn|
  sleep(0.2)
  world.draw god.cells.map(&:position)
  god.evolve
  puts
  puts "Turn: #{turn}"
end