
require "lovekit.all"
reloader = require "lovekit.reloader"

g = love.graphics
import timer, keyboard, audio from love

import concat from table

require "lovekit.screen_snap"
-- snapper = ScreenSnap!

p = (str, ...) -> g.print str\lower!, ...

-- prints lines of text over time
class Printer extends Sequence
  rate: 0.1
  line_height: 8

  new: (str) =>
    @line = 1
    @char = 1
    @lines = split str, "\n"

    super ->
      while @line <= #@lines
        wait @rate
        @char += 1
        if @char > #@lines[@line]
          @char = 1
          @line += 1

      -- all done
      @line = #@lines
      @char = #@lines[@line]

  draw: (x, y) =>
    for i=1,@line
      text = @lines[i]
      text = text\sub 1, @char if i == @line

      p text, x, y + i * @line_height

class Player extends Entity
  w: 10, h: 12
  ox: 0, oy: 0

  alive: true

  __tostring: => concat { "<Player: ", tostring(@box), ">" }

  state_names: {
    walk: {"walk_up", "walk_up", "walk_down", "walk_down"}
    stand: {"stand_up", "stand_up", "stand_down", "stand_down"}
  }

  new: (...) =>
    super ...
    @sprite = Spriter imgfy"img/sprite.png", 10, 12, 3

    @anim = StateAnim "stand_down", {
      stand_down: @sprite\seq {5}
      stand_up:   @sprite\seq {8}

      walk_down:  @sprite\seq {3, 4}, 0.25
      walk_up:    @sprite\seq {6, 7}, 0.25
    }

  draw: =>
    @anim\draw @box.x - @ox, @box.y - @oy

  update: (...) =>
    base = if @velocity\is_zero! then
      "stand"
    else
      @last_direction = @velocity\direction_name!
      "walk"

    dir = @last_direction or "down"
    if dir == "down" or dir == "up"
      @anim\set_state base .. "_" .. dir

    @anim\update ...
    super ...
    true -- still alive

class World
  collides: => false


hello = Printer "hello\nworld!\n\nI think you\nwill & this\ngame!"

class Game
  new: =>
    @viewport = Viewport scale: 3

    @entities = DrawList!

    @world = World!
    @player = Player @world, 56, 23

    with @entities
      \add @player

  draw: =>
    @viewport\apply!
    @entities\draw!
    -- p "I & you Lee! Forever Yours, Leafo.", 0,0

    hello\draw 10, 10

  update: (dt) =>
    reloader\update dt

    @player.velocity = movement_vector 30
    @entities\update dt
    hello\update dt

    snapper\tick dt if snapper

  on_key: (key, code) =>
    switch key
      when " "
        print @player

love.load = ->
  g.setBackgroundColor 61, 52, 47

  font_image = imgfy"img/font.png"
  font = g.newImageFont font_image.tex, [[ abcdefghijklmnopqrstuvwxyz-1234567890!.,:;'"?$&]]
  g.setFont font


  dispatch = Dispatcher Game!
  dispatch\bind love

