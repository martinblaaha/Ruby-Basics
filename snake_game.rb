require 'ruby2d'

# comment exactly one of next two lines to select controls
CONTROLS = "mouse"
# CONTROLS = "arrows"
# --------------------------------------------------------
GRID_SIZE = 20
GRID_WIDTH = 32
GRID_HEIGHT = 24
TILE_SIZE = GRID_SIZE - 1
set title: "Snake Game"
set background: '#000055'
set width: GRID_WIDTH * GRID_SIZE, height: GRID_HEIGHT * GRID_SIZE

class Game
  def initialize
    @snake = Snake.new
    @food = Food.new
    @last_tick = Time.now
    @renderer = GameRenderer.new(@snake, @food)
    @input = InputHandler.new(@snake)
    @tick_rate = 0.15     # in seconds
  end

  def handle_key(key)
    @input.handle_key(key)
  end

  def handle_mouse_move(event)
    @input.handle_mouse(event)
  end

  def update
    if time_for_tick?
      @snake.move
      check_collisions
      @renderer.update_snake
      @last_tick = Time.now
    end
  end

  def time_for_tick?
    Time.now - @last_tick >= @tick_rate
  end

  def check_collisions
    if @snake.get_head_position == @food.position
      @snake.grow
      @food.respawn
      @renderer.update_food
      @renderer.update_grow(@snake.get_head_position)
      @tick_rate *= 0.98
    end

    if @snake.collides_with_wall? or @snake.collides_with_self?
      restart
      @tick_rate = 0.15
    end
  end

  def restart
    @snake.reset
    @renderer.clear_board
    @renderer.reset
  end
end

class InputHandler
  def initialize(snake)
    @snake = snake
  end

  def handle_key(key)
    if CONTROLS == "arrows"
      case key
      when "up"    then @snake.change_direction(:up)
      when "down"  then @snake.change_direction(:down)
      when "left"  then @snake.change_direction(:left)
      when "right" then @snake.change_direction(:right)
      end
    end
  end

  def handle_mouse(event)
    if CONTROLS == "mouse"
      x_diff, y_diff = get_relative_mouse_position event.x, event.y
      if x_diff.abs >= y_diff.abs
        new_direction  = x_diff.positive? ? (:right) : (:left)
      else
        new_direction  = y_diff.positive? ? (:down) : (:up)
      end
      @snake.change_direction(new_direction)
    end
  end

  def get_relative_mouse_position(mouse_x, mouse_y)
    # get the difference of mouse position and a center of snake head
    x_diff = mouse_x - (@snake.get_head_position[0] * GRID_SIZE - GRID_SIZE / 2)
    y_diff = mouse_y - (@snake.get_head_position[1] * GRID_SIZE - GRID_SIZE / 2)
    [x_diff, y_diff]
  end
end

class Snake
  attr_reader :body

  def initialize
    reset
  end

  def reset
    @body = [[7,3], [6,3], [5,3]]
    @direction = :right
    @should_grow = false
  end

  def move
    new_head_position = get_new_head_position
    if @should_grow
      @should_grow = false
    else
      @body.pop
    end
    @body.unshift(new_head_position)
  end

  def grow
    @should_grow = true
  end

  def get_head_position
    @body.first
  end

  def get_new_head_position
    x, y = get_head_position
    case @direction
    when :right then [x + 1, y]
    when :left then [x - 1, y]
    when :up then [x, y - 1]
    when :down then [x, y + 1]
    end
  end

  def change_direction(new_direction)
    return if opposite?(new_direction)
    @direction = new_direction
  end

  def collides_with_self?
    @body[1..].include?(get_head_position)
  end

  def collides_with_wall?
    !(get_head_position[0].between?(0, GRID_WIDTH - 1)) or
      !(get_head_position[1].between?(0, GRID_HEIGHT - 1))
  end

  def opposite?(new_direction)
    {
      up: :down,
      down: :up,
      left: :right,
      right: :left
    }[@direction] == new_direction
  end
end

class Food
  attr_reader :position

  def initialize
    respawn
  end

  def respawn
    # generate new food position
    @position = [rand(0..(GRID_WIDTH - 1)), rand(0..(GRID_HEIGHT - 1))]
  end
end

class GameRenderer
  def initialize(snake, food)
    @snake = snake
    @food = food
    reset
  end

  def reset
    @snake_segments = []
    # draw initial square of food
    @food_square = Square.new(
      x: @food.position[0] * GRID_SIZE,
      y: @food.position[1] * GRID_SIZE,
      size: TILE_SIZE,
      color: 'red')
    # draw initial squares of snake
    @snake.body.each do |position|
      s = Square.new(
        x: position[0] * GRID_SIZE,
        y: position[1] * GRID_SIZE,
        size: TILE_SIZE,
        color: 'white'
      )
      @snake_segments << s
    end
  end

  def update_food
    @food_square.x = @food.position[0] * GRID_SIZE
    @food_square.y = @food.position[1] * GRID_SIZE
  end

  def update_snake
    new_head_position = @snake.get_head_position
    # update the last segment to the new head coordinates
    @snake_segments.last.x = new_head_position[0] * GRID_SIZE
    @snake_segments.last.y = new_head_position[1] * GRID_SIZE
    # rotate the segments array so the last segment is first
    @snake_segments = @snake_segments.rotate(-1)
  end

  def update_grow(new_coords)
    s = Square.new(
      x: new_coords[0] * GRID_SIZE,
      y: new_coords[1] * GRID_SIZE,
      size: TILE_SIZE,
      color: 'white'
    )
    @snake_segments.unshift(s)
  end

  def clear_board
    @food_square.remove
    @food.respawn
    @snake_segments.each do |tile|
      tile.remove
    end
  end
end

game = Game.new

on :mouse_move do |event|
  game.handle_mouse_move(event)
end

on :key_down do |event|
  game.handle_key(event.key)
end

update do
  game.update
end

show