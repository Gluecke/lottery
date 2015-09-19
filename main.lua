
--require libraries
local widgets = require "widget";
local maths = require "math";
local displays = require "display";
local physics = require "physics";


-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- Created By: Garrett Luecke
--
-- Created On: 9/05/2015
--
-- Notes: to deploy to a device, build project with emulator, drag apk file to device, install
--
-- Purpose: this app generates a random number based on a cieling in a text field
--
--
--
--
-----------------------------------------------------------------------------------------

--variables
--create text field for user to enter a number

--start physics
physics.start();
physics.setPositionIterations(16);
physics.setVelocityIterations(6);
physics.setAverageCollisionPositions(true);

local numericField = native.newTextField(display.contentWidth / 2, display.contentHeight / 4, display.contentWidth/5, 36 );

--set some default values for the number input field
numericField.placeholder = "(#)";
numericField.inputType = "number";

--reset button
local resetButton = widgets.newButton(
                {
                    x = display.contentWidth / 2, 
                    y = display.contentHeight / 8,
                    width = display.contentWidth/5,
                    defaultFile = "Images/reset-default.png",
                    overFile = "Images/reset-over.png"
                });
                
--ground & walls
local ground = display.newRect(display.contentWidth/2, display.contentHeight, display.contentWidth, 0);
                
local leftWall = display.newRect( 0, display.contentHeight / 2, 0, display.contentHeight);

local rightWall = display.newRect(display.contentWidth, display.contentHeight / 2, 0, display.contentHeight);

--add physics bodies to walls and floor
physics.addBody(ground, "static", {friction = 0.2, bounce = 0.75});
physics.addBody(leftWall, "static");
physics.addBody(rightWall, "static");

--spawn variables
local spawnedNumbers = {};
local spawnParams = {
                        xMin = display.contentWidth / 2.1,
                        xMax = display.contentWidth / 1.9,
                        yMin = display.contentHeight / 4.5,
                        yMax = display.contentHeight / 4,
                    };

--Used for delta time
local runTime = 0;

--logo image
local logo = display.newImage("Images/Logo.png", display.contentWidth/2, display.contentHeight - display.contentHeight / 2.5);

--functions
local spawnNumber;
local spawnController;
local getDeltaTime;
local IsPicked;
local getRandomNumber;
local resetNumberList;
-----------------------[[
--functions
-----------------------]]


--spawning function
spawnNumber = function( bounds, oneRandom)
    local item = display.newText(
                {
                    text = "1",
                    font = native.systemFont, 
                    fontSize = 35, 
                    align = "left"
                });
    
    --set fill color
    item:setFillColor(1);
    --set text to winning number
    item.text = oneRandom;
    
    --set random spawn location
    item.x = math.random(bounds.xMin, bounds.xMax);
    item.y = math.random(bounds.yMin, bounds.yMax);
    
    physics.addBody(item);
    --send the numbers out a random direction
    local xVelo = math.random(-200, 200);
    local yVelo =  math.random(-200,200);
    
    item:setLinearVelocity(xVelo,yVelo);
    --set color
    item:setFillColor(math.random(80, 81)/100, math.random(40, 100)/100, math.random(20, 80)/100
    );
    
    for num = 1, #spawnedNumbers do
        spawnedNumbers[num]:setLinearVelocity(xVelo*2, yVelo*2);
    end
    
    --add item to array for tracking
    spawnedNumbers[#spawnedNumbers+1] = item;
end

--spawn controller
spawnController = function (action, params, oneRandom)
    if(action == "start")
        then
        --gather spawning bounds
        local spawnBounds = {};
        spawnBounds.xMin = params.xMin or display.contentWidth / 2.1;
        spawnBounds.xMax = params.xMax or display.contentWidth / 1.9;
        spawnBounds.yMin = params.yMin or display.contentHeight / 4.5;
        spawnBounds.yMax = params.yMax or display.contentHeight / 4;
        
        spawnNumber(spawnBounds, oneRandom);
        
    end
end


--Returns delta time since last shake
getDeltaTime = function()
    local curTime = system.getTimer();
    local dTime = (curTime-runTime) / 1000;
    runTime = curTime;
    return dTime;
end


--check if number is already used
IsPicked = function(wasPicked)
    local isPicked = 0;
        
        for idx = 1, #spawnedNumbers do
            
            if(wasPicked == tonumber(spawnedNumbers[idx].text))
                then
                isPicked = 1;
            end
            
        end
    
    return isPicked;
end



--event handlers
--button
getRandomNumber = function( event )
    
    if event.isShake and getDeltaTime() > 0.5 then
        
        local oneRandom = math.random(1, tonumber(numericField.text) or 42);
        
        local tries = 0;
        while(IsPicked(oneRandom) ~= 0 and tries < 500) do
            
            oneRandom = math.random(1, tonumber(numericField.text) or 42);
            tries = tries + 1;
        end
        
        spawnController("start", spawnParams, oneRandom);
    end
end

resetNumberList = function( event )
    if (event.phase == "began") then
        for num = 1, #spawnedNumbers do
        spawnedNumbers[num]:removeSelf();
        end
        spawnedNumbers = {};
    end
end


--event listeners
resetButton:addEventListener("touch", resetNumberList);
Runtime:addEventListener("accelerometer", getRandomNumber);


--ranButton:addEventListener("touch", getRandomNumber);