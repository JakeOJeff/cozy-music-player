local imgbutt = require "imgbutt"
local ffi = require "ffi"
require "playback"

-- UI Elements
local playButton, forwardButton, backButton, heartsButton, menuButton
local playing = false
local wW, wH, cW, cH
local soundData
wW, wH = love.graphics.getDimensions()
cW, cH = wW / 2, wH / 2
soundData = playbackCurrentSoundData() -- Replace with your sound file

samples = {}
sampleCount = 3000 -- Number of samples to visualize
zoom = .2 -- Zoom level for visualization
local lineWidth = 2 -- Waveform line thickness

local beachDay = love.graphics.newFont("fonts/beachday.ttf", 17)
-- Slider variables
local sliderX = 0 -- Current x position of the slider
local sliderY = cH - 14 -- Fixed y position of the slider
local sliderWidth = 25 -- Width of the slider (heart image)
local sliderHeight = 25 -- Height of the slider (heart image)
local isDragging = false -- Whether the slider is being dragged
local stoppedDragging = false

-- UI Setup
function loadImage(name)
    return love.graphics.newImage("assets/" .. name .. ".png")
end

volume = 0.3



function love.load()

    startX = (wW - 20) / 2 - (wW - 60) / 2 + 10
    endX = (wW - 20) / 2 - (wW - 60) / 2 + 10 + (wW - 60) -- Ending x position of the waveform

    -- Load UI elements
    images = {
        frame = loadImage("frame1"),
        imgframe = loadImage("frame2"),
        nameDisplay = loadImage("name"),
        seperationBar = loadImage("seperation_bar"),
        play = loadImage("play"),
        pause = loadImage("pause"),
        forward = loadImage("forward"),
        back = loadImage("back"),
        menu = loadImage("menu"),
        hearts = {loadImage("heart1"), loadImage("heart2"), loadImage("heart3")}
    }

    -- Create buttons
    playButton = imgbutt.new(images.play, cW - 50, wH - 140, 100, 100,
                             function()
        playing = not playing
        if playing then
            playTrack()
        else
            print("Pause")
            pausePlayback()
        end
    end, images.pause)

    forwardButton = imgbutt.new(images.forward, playButton.x + 120, wH - 133,
                                40, 40, nextTrack)
    backButton = imgbutt.new(images.back, playButton.x - 60, wH - 133, 40, 40,
                             previousTrack)

    heartsButton = {}
    for i = 1, 3 do
        heartsButton[i] = imgbutt.new(images.hearts[i],
                                      playButton.x + 70 + (25 * i), wH - 77, 25,
                                      25, function()
            volume = 0.3 * i
            playbackSetVolume(volume)
        end)
    end

    menuButton = imgbutt.new(images.menu, playButton.x - 70, wH - 77, 72, 25,
                             function()
        -- Menu logic
    end)

    -- Define WinAPI functions and constants
    ffi.cdef [[
        typedef void* HWND;
        typedef unsigned long DWORD;
        typedef int BOOL;
        typedef unsigned int UINT;
    
        HWND GetActiveWindow(void);
        BOOL SetWindowRgn(HWND hWnd, void* hRgn, BOOL bRedraw);
        void* CreateRoundRectRgn(int x1, int y1, int x2, int y2, int w, int h);
        int ReleaseCapture();
    ]]

    -- Get the Love2D window handle
    local hwnd = ffi.C.GetActiveWindow()

    -- Create a rounded region
    local width, height = love.window.getMode()
    local cornerRadius = 20
    local hRgn = ffi.C.CreateRoundRectRgn(0, 0, width, height, cornerRadius,
                                          cornerRadius)

    -- Apply the rounded region to the window
    ffi.C.SetWindowRgn(hwnd, hRgn, 1)

    -- Preload all audio samples
    for i = 1, soundData:getSampleCount() do
        samples[i] = soundData:getSample(i)
    end

    -- Initialize slider position
    local src = playbackCurrentSource()
    if src then
        sliderX = startX + (endX - startX) * (src:tell("seconds") / src:getDuration())
    end
end


function love.update(dt)
    -- Update buttons
    playButton:update(dt)
    forwardButton:update(dt)
    backButton:update(dt)
    for _, btn in pairs(heartsButton) do btn:update(dt) end
    menuButton:update(dt)
    local src = playbackCurrentSource()

    -- Update slider position if dragging
    if isDragging then
        local mouseX = love.mouse.getX()
        sliderX = math.max(startX, math.min(endX - sliderWidth, mouseX))

        -- Update playback position based on slider position
        if src then
            src:pause()
            local newTime = (sliderX - startX) / (endX - startX) * src:getDuration()
            src:seek(newTime)
        end
    elseif src then
        -- Update slider position based on current playback time
        if not isDragging then
            local currentTime = src:tell("seconds")
            sliderX = startX + (endX - startX) * (currentTime / src:getDuration())
        end
    end

    if stoppedDragging ~= false and playing then
        stoppedDragging = false
        if src then
            src:play()
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(181 / 255, 130 / 255, 140 / 255)
    love.graphics.setColor(1, 1, 1)

    -- Draw UI elements
    love.graphics.draw(images.frame, 10, playButton.y - 25, 0,
                       (wW - 20) / images.frame:getWidth(),
                       wH / 3.1 / images.frame:getHeight())
    love.graphics.draw(images.imgframe, 10, playButton.y - 302, 0,
                       (wW - 20) / images.imgframe:getWidth(),
                       (wW - 20) / images.imgframe:getHeight())
    love.graphics.draw(images.nameDisplay, (wW - 20)/4 - 3, playButton.y - 335, 0,
                       (wW - 130) / images.imgframe:getWidth(),
                       (wW - 140) / images.imgframe:getHeight())
                       love.graphics.setFont(beachDay)
                       local name = playbackName()
                       love.graphics.print(name, (wW - 20)/2 - beachDay:getWidth(name)/2 + 5, playButton.y - 326)
    love.graphics.draw(images.seperationBar, playButton.x - 70, wH - 90, 0,
                       72 / images.seperationBar:getWidth(),
                       4 / images.seperationBar:getHeight())
    love.graphics.draw(images.seperationBar, playButton.x + 98, wH - 90, 0,
                       72 / images.seperationBar:getWidth(),
                       4 / images.seperationBar:getHeight())
-- Define the rounded rectangle area
local x = (wW - 20) / 2 - (wW - 60) / 2 + 10
local y = (playButton.y - 320 + (wW - 20)) / 2 - (wW - 60) / 2 + 26
local width = (wW - 60)
local height = width * (getTrackImage():getHeight() / getTrackImage():getWidth())
local radius = 10 -- Adjust the radius for desired curvature

-- Set the stencil
roundedRectangle(x, y, width, height, radius)

-- Draw the image
love.graphics.draw(getTrackImage(), x, y, 0, (wW - 60) / getTrackImage():getWidth(), (wW - 60) / getTrackImage():getHeight())

-- Reset the stencil
love.graphics.setStencilTest()

    playButton:draw()
    forwardButton:draw()
    backButton:draw()
    for _, btn in pairs(heartsButton) do btn:draw() end
    menuButton:draw()

    -- Waveform visualization
    local src = playbackCurrentSource()
    if src then
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()
        local midY = h / 2

        -- Get the current playback position in seconds
        local timePos = src:tell("seconds")
        -- Convert time to sample index
        local sampleIndex = math.floor(timePos * soundData:getSampleRate()) + 1

        -- Freeze the waveform if not playing
        if not src:isPlaying() then
            sampleIndex = frozenSampleIndex or sampleIndex
        else
            frozenSampleIndex = sampleIndex -- Update frozen index while playing
        end

        love.graphics.setColor(setRgb(255, 205, 178))
        love.graphics.setLineWidth(lineWidth)

        -- Smooth waveform drawing with Catmull-Rom interpolation
        for i = 0, sampleCount - 2 do
            -- Calculate positions with wrapping
            local s1 = (sampleIndex + i - 1) % #samples + 1
            local s2 = (sampleIndex + i) % #samples + 1
            local s3 = (sampleIndex + i + 1) % #samples + 1
            local s4 = (sampleIndex + i + 2) % #samples + 1

            -- Get sample values
            local y0 = midY - samples[s1] * h / 2 * zoom
            local y1 = midY - samples[s2] * h / 2 * zoom
            local y2 = midY - samples[s3] * h / 2 * zoom
            local y3 = midY - samples[s4] * h / 2 * zoom

            -- Map the x position to the custom range [startX, endX]
            local x0 = startX + (i - 1) / sampleCount * (endX - startX)
            local x1 = startX + i / sampleCount * (endX - startX)
            local x2 = startX + (i + 1) / sampleCount * (endX - startX)
            local x3 = startX + (i + 2) / sampleCount * (endX - startX)

            -- Catmull-Rom interpolation between points
            for t = 0, 1, 0.1 do
                local x = x1 + (x2 - x1) * t
                local y = catmullRom(y0, y1, y2, y3, t)

                if t == 0 then
                    love.graphics.points(x, y)
                else
                    love.graphics.line(prevX, prevY, x, y)
                end
                prevX, prevY = x, y
            end
        end
    end

    -- Draw the draggable slider
    love.graphics.draw(images.hearts[1], sliderX, sliderY, 0, sliderWidth / images.hearts[1]:getWidth(), sliderHeight / images.hearts[1]:getHeight())
end

function roundedRectangle(x, y, width, height, radius)
    love.graphics.stencil(function()
        love.graphics.rectangle("fill", x + radius, y, width - 2 * radius, height)
        love.graphics.rectangle("fill", x, y + radius, width, height - 2 * radius)
        love.graphics.circle("fill", x + radius, y + radius, radius)
        love.graphics.circle("fill", x + width - radius, y + radius, radius)
        love.graphics.circle("fill", x + radius, y + height - radius, radius)
        love.graphics.circle("fill", x + width - radius, y + height - radius, radius)
    end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
end

-- Catmull-Rom interpolation function
function catmullRom(y0, y1, y2, y3, t)
    local t2 = t * t
    local t3 = t2 * t
    return 0.5 * (
        (2 * y1) +
        (-y0 + y2) * t +
        (2 * y0 - 5 * y1 + 4 * y2 - y3) * t2 +
        (-y0 + 3 * y1 - 3 * y2 + y3) * t3
    )
end

function setRgb(r, g, b)
    return r / 255, g / 255, b / 255
end

-- Mouse input handling
function love.mousepressed(x, y, button)
    if button == 1 then
        -- Check if the slider is clicked
        if x >= sliderX and x <= sliderX + sliderWidth and y >= sliderY and y <= sliderY + sliderHeight then
            isDragging = true
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        isDragging = false
        stoppedDragging = true
    end
end