local track = require("tracks")
local tracks = track.load()
currentQueue = 1
soundData = tracks[currentQueue].soundData -- Replace with your sound file

function playTrack()
    soundData = tracks[currentQueue].soundData -- Replace with your sound file

    for i = 1, sampleCount do
        samples[i] = soundData:getSample(i)
    end

    tracks[currentQueue].source:play()
end

function nextTrack()
    stopPlayback()
    if currentQueue < #tracks then
        currentQueue = currentQueue + 1
    else
        currentQueue = 1
    end
end

function previousTrack()
    stopPlayback()
    if currentQueue > 1 then
        currentQueue = currentQueue - 1
    else
        currentQueue = #tracks
    end
end

function stopPlayback()
    tracks[currentQueue].source:stop()
end
function pausePlayback()
    tracks[currentQueue].source:pause()
end

function playbackSetVolume(volume)
    tracks[currentQueue].source:setVolume(volume)
end

function playbackCurrentSoundData()
    return soundData
end

function playbackCurrentSource()
    return tracks[currentQueue].source
end

function getTrackImage()
    return tracks[currentQueue].image
end
function playbackName()
    return tracks[currentQueue].name
end