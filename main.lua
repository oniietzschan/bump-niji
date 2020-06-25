local bump = require 'bump-niji'

local bumpDebug
do
  local function getCellRect(world, cx,cy)
    local cellSize = world.cellSize
    local l,t = world:toWorld(cx,cy)
    return l,t,cellSize,cellSize
  end

  bumpDebug = function(world)
    local cellSize = world.cellSize
    local font = love.graphics.getFont()
    local fontHeight = font:getHeight()
    local topOffset = (cellSize - fontHeight) / 2
    for cy, row in pairs(world.rows) do
      for cx, cell in pairs(row) do
        local l,t,w,h = getCellRect(world, cx,cy)
        local intensity = cell.itemCount * 0.05 + 0.1
        love.graphics.setColor(1, 1, 1, intensity)
        love.graphics.rectangle('fill', l,t,w,h)
        love.graphics.setColor(1, 1, 1, 0.25)
        love.graphics.printf(cell.itemCount, l, t+topOffset, cellSize, 'center')
        love.graphics.setColor(1, 1, 1, 0.05)
        love.graphics.rectangle('line', l,t,w,h)
      end
    end
  end
end

local instructions = [[
  bump.lua simple demo

    arrows: move
    tab: toggle debug info
    delete: run garbage collector
]]

local function drawMessage()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(instructions, 550, 10)
end


-- World creation
local world = bump.newWorld()

local cols_len = 0 -- how many collisions are happening

local function drawDebug()
  bumpDebug(world)

  local statistics = ("fps: %d, mem: %dKB, collisions: %d, items: %d"):format(love.timer.getFPS(), collectgarbage("count"), cols_len, world:countItems())
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(statistics, 0, 580, 790, 'right')
end

local consoleBuffer = {}
local consoleBufferSize = 15
for i = 1, consoleBufferSize do consoleBuffer[i] = "" end
local function consolePrint(msg)
  table.remove(consoleBuffer,1)
  consoleBuffer[consoleBufferSize] = msg
end

local function drawConsole()
  for i, line in ipairs(consoleBuffer) do
    love.graphics.setColor(1,1,1, i / consoleBufferSize)
    love.graphics.printf(line, 10, 580-(consoleBufferSize - i)*12, 790, "left")
  end
end

local function drawBox(box, r, g, b)
  love.graphics.setColor(r, g, b, 0.25)
  love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
end



local player = {
  x = 50,
  y = 50,
  w = 20,
  h = 20,
  speed = 80,
}

local isDown = love.keyboard.isDown

function player:update(dt)
  local dx, dy = 0, 0
  if isDown('d') or isDown('right') then
    dx = self.speed * dt
  end
  if isDown('a') or isDown('left') then
    dx = self.speed * dt * -1
  end
  if isDown('s') or isDown('down') then
    dy = self.speed * dt
  end
  if isDown('w') or isDown('up') then
    dy = self.speed * dt * -1
  end

  if dx == 0 and dy == 0 then
    cols_len = 0
    return
  end

  local cols
  self.x, self.y, cols, cols_len = world:move(self, self.x + dx, self.y + dy)
  for _, col in ipairs(cols) do
    consolePrint(("col.other = %s, col.type = %s, col.normal = %d,%d"):format(col.other, col.type, col.normalX, col.normalY))
  end
end

function player:draw()
  drawBox(self, 0, 1, 0)
end



local blocks = {}

local function addBlock(x,y,w,h)
  local block = {x=x,y=y,w=w,h=h}
  blocks[#blocks+1] = block
  world:add(block, x,y,w,h)
end

local function drawBlocks()
  for _,block in ipairs(blocks) do
    drawBox(block, 1, 0, 0)
  end
end



function love.load()
  world:add(player, player.x, player.y, player.w, player.h)

  addBlock(32,       0,     800 - 32, 32)
  addBlock(0,        600 - 32, 800 - 32, 32)
  addBlock(0,        0,      32, 600 - 32)
  addBlock(800 - 32, 32,      32, 600 - 32)

  for _ = 1, 30 do
    addBlock(
      math.random(100, 600),
      math.random(100, 400),
      math.random(10, 100),
      math.random(10, 100)
    )
  end
end

function love.update(dt)
  player:update(dt)
end

local shouldDrawDebug = false

function love.draw()
  drawBlocks()
  player:draw()
  if shouldDrawDebug then
    drawDebug()
    drawConsole()
  end
  drawMessage()
end

function love.keypressed(k)
  if     k == "escape" then
    love.event.quit()
  elseif k == "tab" then
    shouldDrawDebug = not shouldDrawDebug
  elseif k == "delete" then
    collectgarbage("collect")
  end
end
