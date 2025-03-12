local track = {}

function track.load()
    local tracks = {}
    local trackFiles = love.filesystem.getDirectoryItems("assets/tracks")
    
    for i, file in ipairs(trackFiles) do
        -- Initialize the sub-table for this track
        tracks[i] = {
            source = nil,
            soundData = nil,
            name = file,
            image = nil
        }
        
        -- Load the audio source
        local audioPath = "assets/tracks/" .. file .. "/index.mp3"
        if love.filesystem.getInfo(audioPath) then
            local sD = love.sound.newSoundData(audioPath) 
            tracks[i].soundData = sD
            tracks[i].source = love.audio.newSource(sD, "stream")
        else
            print("Warning: Audio file not found for track: " .. file)
        end
        
        -- Load the image
        local imagePath = "assets/tracks/" .. file .. "/index.png"
        if love.filesystem.getInfo(imagePath) then
            tracks[i].image = love.graphics.newImage(imagePath)
        else
            print("Warning: Image file not found for track: " .. file)
        end
    end
    
    return tracks
end

return track