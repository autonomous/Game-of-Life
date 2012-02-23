require 'rspec'
require_relative 'game_of_life'

describe 'The game of life' do
  describe Simulation do
    it 'ticks over for a turn' do
      arr = [1, 2, 3]
      Simulation.tick(1) do
        arr.map!{|i| i**2}
      end
      arr.should ==[1, 4, 9]
    end

    it 'ticks over for multiple turns' do
      arr = [1, 2, 3]
      Simulation.tick(2) do
        arr.map!{|i| i+1}
      end
      arr.should ==[3, 4, 5]   
    end
  end

  describe God do
    let(:empty_god){
      God.new
     }

    let(:cell){
      Cell.new
    }

    context '.initialize' do
      it 'should have no cells' do
        empty_god.cells.should be_empty        
      end
    end
    
    context '#add' do
      subject do
        God.new
      end

      it 'should add cells' do
        subject.add( cell )
        subject.cells.should_not be_empty
      end

      it 'should not add the same cell more than once' do
        subject.add( cell )
        subject.add( cell )
        subject.cells.size.should eql(1)
      end
    end

    context '#cells' do
      it 'should return a copy of cells' do
        subject.cells.object_id.should_not eql(subject.instance_eval('cells').object_id)
      end
    end

    context '#neighbours' do
      let(:home_cell) do
        Cell.new(x: 0, y: 0)
      end

      before do
        subject.add(home_cell)
      end

      it 'should find neighbours to the N' do
        north = Cell.new(y: 1)
        subject.add(north)
        subject.neighbours(home_cell).should eql( [north] )
      end

      it 'should find neighbours to the E' do
        east = Cell.new(x: 1)
        subject.add(east)
        subject.neighbours(home_cell).should eql( [east] )
      end

      it 'should find neighbours to the S' do
        south = Cell.new(y: -1)
        subject.add(south)
        subject.neighbours(home_cell).should eql( [south] )
      end

      it 'should find neighbours to the W' do
        west = Cell.new(x: -1)
        subject.add(west)
        subject.neighbours(home_cell).should eql( [west] )
      end

      it 'should find neighbours to the NE' do
        ne = Cell.new(x: 1, y: 1)
        subject.add(ne)
        subject.neighbours(home_cell).should eql( [ne] )
      end

      it 'should find neighbours to the NW' do
        nw = Cell.new(x: -1, y: 1)
        subject.add(nw)
        subject.neighbours(home_cell).should eql( [nw] )
      end

      it 'should find neighbours to the SE' do
        se = Cell.new(x: 1, y: -1)
        subject.add(se)
        subject.neighbours(home_cell).should eql( [se] )
      end

      it 'should find neighbours to the SW' do
        sw = Cell.new(x: -1, y: -1)
        subject.add(sw)
        subject.neighbours(home_cell).should eql( [sw] )
      end
    end

    context 'Any live cell with fewer than two live neighbours dies' do
      let(:cell) do
        Cell.new
      end

      before do
        subject.add(cell)
      end

      it 'should kill the cell' do
        subject.evolve
        subject.cells.should be_empty
      end
    end

    context 'Any live cell with two or three live neighbours lives on' do
      let(:home_cell){ Cell.new }

      before{ subject.add(home_cell) }
      
      context 'two neighbours' do
        it 'should include the home cell' do
          subject.add Cell.new(x: 1, y: 1)
          subject.add Cell.new(x: 1, y: 0)
          subject.evolve()

          subject.should include(home_cell)
        end
      end

      context 'three neighbours' do
        it 'should include the home cell' do
          subject.add Cell.new(x: 1, y: 1)
          subject.add Cell.new(x: 1, y: 0)
          subject.add Cell.new(x: 0, y: 1)
          subject.evolve()

          subject.should include(home_cell)
        end
      end
    end

    context 'Any live cell with more than three live neighbours dies' do
      let(:home_cell){ Cell.new }

      before{ subject.add(home_cell) }

      it 'should not include the home cell' do
        subject.add Cell.new(x: 1, y: 1)
        subject.add Cell.new(x: 1, y: 0)
        subject.add Cell.new(x: 0, y: 1)
        subject.add Cell.new(x: -1, y: 0)
        subject.evolve()

        subject.should_not include(home_cell)
      end
    end

    context 'Any dead cell with exactly three live neighbours becomes a live cell' do
      it 'spawns a new cell' do
        subject.add Cell.new(x: 1, y: 1)
        subject.add Cell.new(x: 1, y: 0)
        subject.add Cell.new(x: 0, y: 1)
        subject.evolve

        subject.should include(Cell.new)
      end
    end

    context 'All rules' do
      it 'should be a blinker' do
        subject.add Cell.new(x: 0, y: 1)
        subject.add Cell.new(x: 0, y: 0)
        subject.add Cell.new(x: 0, y: -1)

        subject.evolve
        subject.cells.size.should eql(3)
        subject.should include(Cell.new(x: 1, y: 0))
        subject.should include(Cell.new(x: 0, y: 0))
        subject.should include(Cell.new(x: -1, y: 0))
        
        subject.should_not include(Cell.new(x: 0, y: 1))
        subject.should_not include(Cell.new(x: 0, y: -1))

        subject.evolve
        subject.cells.size.should eql(3)
        subject.should_not include(Cell.new(x: 1, y: 0))
        subject.should_not include(Cell.new(x: -1, y: 0))
        
        subject.should include(Cell.new(x: 0, y: 1))
        subject.should include(Cell.new(x: 0, y: 0))
        subject.should include(Cell.new(x: 0, y: -1))
      end

      it 'should be a block' do
        subject.add Cell.new(x: 0, y: 1)
        subject.add Cell.new(x: 1, y: 0)
        subject.add Cell.new(x: 0, y: 0)
        subject.add Cell.new(x: 1, y: 1)

        4.times{subject.evolve}
        subject.should include(Cell.new(x: 0, y: 1))
        subject.should include(Cell.new(x: 1, y: 0))
        subject.should include(Cell.new(x: 0, y: 0))
        subject.should include(Cell.new(x: 1, y: 1))
        subject.cells.size.should eql(4)
      end
    end
  end

  describe Cell do
    context '.initialize' do
      it 'defaults to (0,0)' do
        position = {x: 0, y: 0}
        subject.position.should eql( position ) 
      end

      it 'should take a coordinate' do
        position = {x: 1, y: 2}
        cell = Cell.new(position)
        cell.position.should eql( position )
      end

      it 'should default x' do
        position = {x: 0, y: 1}
        cell = Cell.new(y: 1)
        cell.position.should eql( position )
      end

      it 'should default y' do
        position = {x: 1, y: 0}
        cell = Cell.new(x: 1)
        cell.position.should eql( position )
      end
    end

    context '#adjacent?' do
      it 'should know that a cell with the same position is not adjacent' do
        cell = Cell.new(subject.position)
        cell.adjacent?(subject).should be_false
      end
      
      it 'should know if it is adjacent to another cell' do
        x_range = [-1, 0, 1]
        y_range = [-1, 0, 1]
        
        x_range.each do |i|
          y_range.each do |j|
            cell = Cell.new(x: i, y: j)
            next if cell.position == subject.position
            subject.adjacent?(cell).should be_true
          end
        end
      end
    end
  end
end
