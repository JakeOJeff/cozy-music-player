local ImageButton = {}
ImageButton.__index = ImageButton

-- Constructor
function ImageButton.new(image, x, y, width, height, onClick, image_clicked)
    local self = setmetatable({}, ImageButton)
    self.image = image
    self.image_clicked = image_clicked
    self.x = x
    self.y = y
    self.width = width or image:getWidth() -- Use provided width or default to image width
    self.height = height or image:getHeight() -- Use provided height or default to image height
    self.onClick = onClick
    self.isHovered = false
    self.isClicked = false
    self.scale = 1 -- Initial scale
    self.targetScale = 1 -- Target scale for smooth interpolation
    self.scaleSpeed = 5 -- Speed of scaling (adjust as needed)
    self.currentImg = self.image
    self.clickCooldown = 0 -- Cooldown timer
    self.clickCooldownDuration = 0.5 -- Cooldown duration in seconds (adjust as needed)
    return self
end

-- Check if the mouse is over the button
function ImageButton:isMouseOver(mx, my)
    return mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

-- Update the button state
function ImageButton:update(dt)
    local mx, my = love.mouse.getPosition()
    self.isHovered = self:isMouseOver(mx, my)

    -- Set target scale based on hover state
    if self.isHovered then
        self.targetScale = 1.1 -- Slightly enlarge on hover
    else
        self.targetScale = 1.0 -- Normal size when not hovered
    end

    -- Smoothly interpolate the scale
    self.scale = self.scale + (self.targetScale - self.scale) * self.scaleSpeed * dt

    -- Update the cooldown timer
    if self.clickCooldown > 0 then
        self.clickCooldown = self.clickCooldown - dt
    end

    -- Handle click logic
    if self:isMouseOver(mx, my) and love.mouse.isDown(1) and self.clickCooldown <= 0 then
        self.isClicked = true
        -- Toggle between the normal and clicked image
        if self.image_clicked then
            if self.currentImg == self.image then
                self.currentImg = self.image_clicked
            else
                self.currentImg = self.image
            end
        end
        -- Trigger the onClick function and reset the cooldown timer
        if self.onClick then
            self.onClick()
        end
        self.clickCooldown = self.clickCooldownDuration
    end
    if self.isClicked and not love.mouse.isDown(1) then
        self.isClicked = false
    end
end

-- Draw the button
function ImageButton:draw()
    -- Calculate the new width and height based on the current scale
    local scaledWidth = self.width * self.scale
    local scaledHeight = self.height * self.scale

    -- Calculate the offset to keep the button centered while scaling
    local offsetX = (scaledWidth - self.width) / 2
    local offsetY = (scaledHeight - self.height) / 2

    -- Set the color based on hover state
    local buttColor = {1, 1, 1}
    if self.isHovered then
        buttColor = {.93, .93, .93}
    else
        buttColor = {1, 1, 1}
    end

    -- Draw the image with the scaled width and height
    love.graphics.setColor(buttColor)
    love.graphics.draw(self.currentImg, self.x - offsetX, self.y - offsetY, 0,
                       scaledWidth / self.image:getWidth(),
                       scaledHeight / self.image:getHeight())
end

return ImageButton