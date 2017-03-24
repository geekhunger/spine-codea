-- Spine2D Runtime Library v1.1

function setup()
    actors = {}
    
    local raptor = spine.Actor(lfs.DROPBOX.."/spine-data", "raptor.json", "raptor.atlas")
    raptor:setPosition(-200, 0)
    raptor:setScale(.25)
    raptor:setAnimation("walk") -- play a sequence of chained animations
    raptor:queueAnimation("walk") -- build animation sequence
    raptor:queueAnimation("walk")
    raptor:queueAnimation("Jump")
    raptor:queueAnimation("walk", true)
    
    local goblin = spine.Actor(lfs.DROPBOX.."/spine-data", "goblins.json", "goblins.atlas", "goblingirl")
    goblin:setScale(1.5)
    goblin:setSkin("goblin")
    goblin:setAnimation("walk", true) -- loop one animation
    
    local spineboy = spine.Actor(lfs.DROPBOX.."/spine-data", "spineboy.json", "spineboy.atlas")
    spineboy:setScale(.5)
    spineboy:queueAnimation("walk")
    spineboy:queueAnimation("walk")
    spineboy:queueAnimation("shoot")
    spineboy:queueAnimation("shoot")
    spineboy:queueAnimation("walk", true)
    
    table.insert(actors, raptor)
    table.insert(actors, goblin)
    table.insert(actors, spineboy)
    table.insert(actors, spine.Actor(lfs.DROPBOX.."/spine-data", "alien.json", "alien.atlas"))
    table.insert(actors, spine.Actor(lfs.DROPBOX.."/spine-data", "tank.json", "tank.atlas"))
    
    parameter.integer("current_actor", 1, #actors, 1)
    parameter.number("s", .001, 2, 1)
    parameter.number("x", 0, WIDTH, WIDTH/2)
    parameter.number("y", 0, HEIGHT, HEIGHT/3)
end


function draw()
    background(40, 40, 50)
    
    translate(x, y)
    scale(s, s)
    actors[current_actor]:draw()
    
    resetMatrix()
    fontSize(16)
    fill(255)
    text(string.format("framerate: %.3fms \nfrequency: %ifps \nmemory: %.0fkb", 1000 * DeltaTime, math.floor(1/DeltaTime), collectgarbage("count")), WIDTH/2, 100)
    collectgarbage()
end
