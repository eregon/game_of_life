# My Solution (eregon) #

This solution is rather big, in size of code and numbers of file.

I did coded up to 9 implementations. Some are very similar.

* Cell:
    This is an object-oriented implementation, trying to be nice to read and to show clearly the logic.
    It is creating a new Cell for each evolution. Thus, it is rather slow.

* Boolean:
    This use `true` and `false` and link them by including the Boolean module.
    Boolean is the natural simple structure to represent the life of a Cell.
    As it is possible to simple monkey-patch these 2 values, we do not need a separate class.

* Integer:
    This is identical to Boolean, except it uses `1` and `0`.
    The idea looks unpleasant, but it match without any conversion the spec of the Challenge.

* State:
    This keep the state of the cell, and the next one in the Cells.
    We then do not need to #dup the Array, but to update the values when all are #evolve.

* Fiber:
    This comes from Daniel Moore's solution to his own "Game of Life" Ruby Quiz.
    The solution (ab)use of Fiber, and is really interesting, so I commented a little and made it match my API.
    It also caused a lot of segfaults on trunk(1.9.3), so I have disabled GC (it is then painfully slow).
    You should use 1.9.2 to run it, as Fiber is a 1.9 feature.

* Fast: This aim to be fast, while still being pure Ruby. It uses a 1-dimensional array and check quicker the neighbors

* C: C extension, sort of translated from Fast. It uses Ruby-level instance variables.

* Cwrap: C extension which use its own struct to keep the data.

* Narray: A interesting implementation between Fast and C, which use NArray.
    It does not have an explicit loop in evolve, as it is is only adding NArray (matrix).
    It is inspired from the official example. The borders are managed by adding extra values around the grid.

## Visualizations

I added a Chingu (derived from their example), and tried to improve the NCurses and Shoes ones.

* Shoes

Shoes is notably slow, and then can not be use for large patterns.

* Chingu

Chingu however, is quite fast because based on Gosu (~60fps).

Chingu accepts an optional pattern\_file and size(w*h) as command-line arguments

`ruby life_chingu.rb patterns/spaceships/glider.txt 50*50`

You can make it faster with `j`, slower with `k` and pause with `l`

* NCurses

NCurses beat them all, because it is text based (~800fps)

NCurses accepts an optional pattern\_file and sleep\_time as command-line arguments

`ruby life_ncurses.rb patterns/Gosper_glider_gun_huge.txt 0.1`

## Installation

The code is made to be run by Ruby 1.9, though most implementations can also run 1.8 with backports.
C extensions are coded only for 1.9. Fiber can also only run with 1.9.
Others should be ok with 1.8, but were not extensively tested.

### Gems
Many gems are used, but only for visualizations, test or compatibility, except NArray.

Test:

  * `rspec --pre` (RSpec 2)
  * cucumber
  * rake

Compatibility (with 1.8.7):

  * backports (currently copied in lib, so you do not need it)

Visualizations:

  * [Shoes 3](http://wiki.github.com/shoes/shoes/recentbuilds)
  * ncurses (See below)
  * chingu

### C extensions

The C extensions can only be used (easily) with MRI 1.9.

You need to do the following to compile it:

* `cd ext` (`ext_wrap` pour Cwrap)
* `ruby extconf.rb`
* `make`

## API

As the implementations internals are very different, only this API is safe to use across them:

GameOfLife

* initialize (2-dim-array of 1 and 0 OR a single Integer for random)
* state= 2-dim-array of 1 and 0
* state returns a 2-dim-array of cell-Objects which can be verified if alive by using == 1 (or == 0)
* [x, y] return a cell-Object
* evolve which returns the same as #state
* to_s

A few others methods are defined in `game_of_life.rb`, to avoid repetition.

Note that to know if the cell-Objects are alive, you have to use == 0 or == 1,
 and this is not transitive (no 1 ==)
  because it would require a lot of monkey patching for a small gain.

## Hierarchy

Visualizations are the life_*.rb scripts, implementations are in lib.

`lib/game_of_life.rb` has to be `#require` and you can choose the implementation by first requiring the implementation.

## About my solution

This is a solution I made for fun, but as I like challenges, I would like to participate :)

I learned C extension, Chingu, Cucumber, NArray, Rakefile while coding this, so it is definitely a very good challenge to learn new stuff.

## Author

Benoit Daloze

---

## Ruby Programming Challenge: Game of Life ##

The idea is to implement the game of life in Ruby.
The game of life is a simplified model of evolution and natural selection invented by a mathematician called James Conway. It is described [here](http://en.wikipedia.org/wiki/Conway's_Game_of_Life).

# Rules #
You have a grid of cells in 2 dimensions.  Each cell has 2 possible states, alive or dead.  Each cell has 8 neighbours: above, below, left, right, and the 4 diagonals.

* any life cell < 2 neighbours dies
* any life cell > 3 neighbours dies
* any live cell with 2 or 3 neighbours lives to next generation
* any dead cell with exactly 3 live neighbours becomes a live cell

edges of game: just pretend that the board is folded onto itself, and the edges touch each other. If that's too complicated, you can work without that assumption.


# Your job #
The idea is that you implement a class that will have the following methods:

* initialize: will randomly initialize the game of life matrix. I leave you to think of parameters to use: size, width, height, number of seeds to initialize ... ([for inspiration](http://people.bridgewater.edu/~rbowman/ISAW/Life.html)  )
* evolve: this implements the evolution according to the game of life rules (see above).  Every time evolve is called, one step of the game of life is executed.
The evolve methods should return:
an array of arrays - which represents an array of rows.  Where there's life (a live cell), there's a 1, where there's no life (a dead cell), there's a 0.

So:

    g = GameOfLife.new # say we have 5x5 default
    => #<GameOfLife:0x1010557d8>
    g.evolve
    => [[0, 1, 0, 0, 0], [1, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]

* state=(array) accessor to set the state from outside. This allows us to test whether your evolve method obeys the rules (can also be useful for your own tests).  Regardless of your internal state representation this method should take the same type of parameter as produced by evolve (an array of rows).

# To test your implementation #
Test-driven development is always a good idea.  I added a Test::Unit class as a *simplified* example, but really, try to do TDD (http://en.wikipedia.org/wiki/Test-driven_development).

# To visualize your implementation #

## life_ncurses

This requires the gem ffi-ncurses.
    gem install ffi ffi-ncurses

If you get a dlopen error, you should install one of the forks:
    git clone http://github.com/stepheneb/ffi-ncurses.git
    cd ffi-ncurses
    gem build ffi-ncurses.gemspec
    gem install ffi-ncurses-0.3.2.gem

NOTE: I've asked the maintainer of ffi-ncurses to pull in the fix, but no answer on this ...

To run: (example script given life_ncurses_script)

    LifeNcurses.new(GameOfLife.new)

This will display the game of life in the terminal.

The visualization follows what is known as the Visitor Pattern (http://en.wikipedia.org/wiki/Visitor_pattern).
You have one class, the visitor class, and another, a visitable class. When you initialize a visitor object, you give it as a parameter an object of the visitable class.  The visitor will call certain pre-defined methods (callback) on the visitable object.  In this case the visitor = the visualization, and the visitable = the game of life.  The callback is the 'evolve' method.  The output is displayed using curses.

NOTE: I have no computer under Windows, and ashbb confirmed that it doesn't work under Windows, ffi_ncurses doesn't seem to play nice with the dll. See next paragraph if you have a Windows computer.

## Shoes visualization ##
To solve the Windows issue, ashbb kindly provided a shoes visualization file - see life_shoes.rb.
Install shoes from [here](http://shoes.heroku.com/downloads).
You need to adapt life_shoes.rb in a couple of points (require your class, and call the initialization of your object in the Shoes.app).  To run, run Shoes, and open life_shoes.rb from the Shoes application.

# Bonus points #
* on readable implementation
* on elegant implementation
pure ruby, no gems.

# Out of contest brownie points #
if you implement another visualization for the game.  The ncurses one is text-based, you could do one in ruby-processing, Shoes, or another toolset of your choice.  As long as it takes the game of life object as a parameter at initialize, and calls 'evolve' on it, you can make many different visualizations - that's one of the advantages of the visitor pattern.

Credits to the Baltimore Ruby User Group for giving me the idea at Bohconf.
