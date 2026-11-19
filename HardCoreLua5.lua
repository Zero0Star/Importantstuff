if workspace:FindFirstChild("HardcoreOne") then
    return
end
local marker = Instance.new("BoolValue")
marker.Name = "HardcoreOne"
marker.Value = true
marker.Parent = workspace
local function GitAud(soundgit, filename)
    local url = soundgit
    local FileName = filename
    writefile(FileName .. ".mp3", game:HttpGet(url))
    return (getcustomasset or getsynasset)(FileName .. ".mp3")
end
local function CustomGitSound(soundlink, vol, filename)
    local sound = Instance.new("Sound")
    sound.SoundId = GitAud(soundlink, filename)
    sound.Parent = workspace
    sound.Name = filename or "Music"
    sound.Volume = vol
    sound:Play()
    return sound
end
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()
local DG_MUSIC_URL = "https://github.com/Zero0Star/RipperNewSound/blob/master/NoRunning.mp3?raw=true"
local LOCAL_FILE_NAME = "DeerGodMusic"
local function GetCachedAudio(url, filename)
    local filePath = filename .. ".mp3"
    if isfile and isfile(filePath) then
        return getcustomasset(filePath)
    end
    writefile(filePath, game:HttpGet(url))
    return getcustomasset(filePath)
end

local cachedAudioAsset = GetCachedAudio(DG_MUSIC_URL, LOCAL_FILE_NAME)
local entityBehaviors = {}

function entityBehaviors.FigureXF()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local function findHeadPart()
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        local figureRig = room:FindFirstChild("FigureRig")
        if figureRig and figureRig:IsA("Model") then
            local head = figureRig:FindFirstChild("Head")
            if head and head:IsA("MeshPart") then
                return head
            end
        end
    end
    return nil
end

local function attractToHead()
    local headPart = findHeadPart()
    if not headPart then return end

    local nearestPlayer
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local distance = (hrp.Position - headPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end
    
    if not nearestPlayer then

        return
    end
    local hrp = nearestPlayer.Character.HumanoidRootPart
    local moveSpeed = 0.5
    local stopDistance = 1
    while (hrp.Position - headPart.Position).Magnitude > stopDistance do
        local direction = (headPart.Position - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position + direction * moveSpeed)
        
        RunService.Heartbeat:Wait()
    end

end

attractToHead()
end

function entityBehaviors.FigureSpawn()
 local RunService = game:GetService("RunService")
local figure1 = nil
local isSetup = false
local currentAnimation = nil
local currentTrack = nil
local currentServerTrack = nil
local walkSoundLoop = nil
local lastWalkTime = 0
local isSoundPlaying = false
local currentSound = nil
local lastMoveCheck = 0
local moveCheckInterval = 0.5
local lastPosition = nil
local movementThreshold = 1.0
local lastSpeedCheck = 0
local speedCheckInterval = 0.1
local figureRigConnections = {}
local ANIMATIONS = {
    idle = "18540813605",
    walk = "18570699250", 
    run = "18570706208",
    crucifix = "18583455040",
    new_anim = "18542418459"
}
local objects = game:GetObjects("rbxassetid://96598945864381")
if #objects > 0 then
    figure1 = objects[1]:Clone()
    figure1.Name = "Figure1"
    figure1.Parent = workspace
end

if not figure1 then
    return
end
local function setupFigureRigListener(room, figureRig)
    if not room or not figureRig then return end
    
    local connection = room.ChildRemoved:Connect(function(child)
        if child == figureRig then
            if figure1 then
                figure1:Destroy()
                figure1 = nil
            end
        end
    end)
    
    table.insert(figureRigConnections, connection)
    return connection
end

local function getAnimator(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = Instance.new("Humanoid")
        humanoid.Parent = model
    end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    
    return animator
end

local function playAnimation(animId, animName, serverTrack)
    if not figure1 or not animId then return end
    
    local figure1Animator = getAnimator(figure1)
    if not figure1Animator then return end

    if currentTrack and currentTrack.IsPlaying then
        currentTrack:Stop()
        currentTrack = nil
    end

    if walkSoundLoop and animName ~= "walk" then
        walkSoundLoop:Disconnect()
        walkSoundLoop = nil
        isSoundPlaying = false
        if currentSound then
            currentSound:Stop()
            currentSound = nil
        end
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId
    anim.Name = animName
    
    local track = figure1Animator:LoadAnimation(anim)
    track:Play()

    if serverTrack then
        track.TimePosition = serverTrack.TimePosition

        if serverTrack.Speed then
            track:AdjustSpeed(serverTrack.Speed)
        end

        track.Looped = serverTrack.Looped
    end
    
    currentTrack = track
    currentAnimation = animId
    currentServerTrack = serverTrack
    return track
end
local function playRandomWalkSound()
    if isSoundPlaying then return end
    local head = figure1:FindFirstChild("Head")
    if not head then return end
    local click = head:FindFirstChild("Click")
    local clickLow = head:FindFirstChild("ClickLow")
    if not click or not clickLow then return end
    local sound = math.random(1, 2) == 1 and click or clickLow
    if sound and sound:IsA("Sound") then
        isSoundPlaying = true
        currentSound = sound
        sound:Play()
        
        sound.Ended:Connect(function()
            isSoundPlaying = false
            currentSound = nil
        end)
    end
end
local function checkMovement(figureRig)
    local now = tick()
    if now - lastMoveCheck < moveCheckInterval then
        return false
    end
    lastMoveCheck = now
    local currentPos = figureRig:GetPivot().Position
    local currentX = math.floor(currentPos.X + 0.5)
    local currentZ = math.floor(currentPos.Z + 0.5)
    if lastPosition then
        local lastX = math.floor(lastPosition.X + 0.5)
        local lastZ = math.floor(lastPosition.Z + 0.5)
        
        local xChanged = math.abs(currentX - lastX) > movementThreshold
        local zChanged = math.abs(currentZ - lastZ) > movementThreshold
        
        lastPosition = currentPos
        
        if not xChanged and not zChanged then
            return false
        end
    end
    lastPosition = currentPos
    return true
end

local function setupSystem()
    if isSetup then return end
    
    local currentRooms = workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then
        return
    end
    
    for _, room in ipairs(currentRooms:GetChildren()) do
        if room:IsA("Model") or room:IsA("Folder") then
            local figureRig = room:FindFirstChild("FigureRig")
            if figureRig then

                setupFigureRigListener(room, figureRig)

                for _, part in ipairs(figureRig:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        part.Transparency = 1
                    end
                end

                local rigHead = figureRig:FindFirstChild("Head")
                if rigHead then
                    for _, sound in ipairs(rigHead:GetDescendants()) do
                        if sound:IsA("Sound") then
                            sound.Volume = 0
                        end
                    end
                end
                local rigHumanoid = figureRig:FindFirstChild("Figurenoid") or figureRig:FindFirstChildOfClass("Humanoid")
                if not rigHumanoid then break end
                
                local rigAnimator = rigHumanoid:FindFirstChildOfClass("Animator")
                if not rigAnimator then
                    rigAnimator = Instance.new("Animator")
                    rigAnimator.Parent = rigHumanoid
                end
                rigAnimator.AnimationPlayed:Connect(function(serverTrack)
                    local animId = serverTrack.Animation.AnimationId
                    local idNumber = animId:match("%d+")
                    
                    if not idNumber then return end

                    if currentAnimation == idNumber and currentTrack and currentTrack.IsPlaying then
                        currentServerTrack = serverTrack
                        return
                    end

                    local animName
                    for name, id in pairs(ANIMATIONS) do
                        if id == idNumber then
                            animName = name
                            break
                        end
                    end
                    
                    if not animName then return end

                    playAnimation(idNumber, animName, serverTrack)

                    if animName == "walk" then
                        if walkSoundLoop then
                            walkSoundLoop:Disconnect()
                        end
                        
                        walkSoundLoop = RunService.Heartbeat:Connect(function()
                            local now = tick()
                            if now - lastWalkTime >= math.random(5, 10) then
                                lastWalkTime = now
                                playRandomWalkSound()
                            end
                        end)
                    elseif animName == "run" then
                        local head = figure1:FindFirstChild("Head")
                        if head then
                            local growl = head:FindFirstChild("Growl")
                            if growl and growl:IsA("Sound") then
                                growl.PlaybackSpeed = 1
                                growl.Volume = 1
                                growl:Play()
                            end
                        end
                    end
                end)
                
                isSetup = true
            end
        end
    end
end
task.wait(2)
setupSystem()
local lastIdleCheck = 0
local idleCheckInterval = 1.0
RunService.RenderStepped:Connect(function()
    if not figure1 then return end
    local currentRooms = workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    
    for _, room in ipairs(currentRooms:GetChildren()) do
        if room:IsA("Model") or room:IsA("Folder") then
            local figureRig = room:FindFirstChild("FigureRig")
            if figureRig then
                figure1:PivotTo(figureRig:GetPivot())
                if currentTrack and currentTrack.IsPlaying and currentServerTrack then
                    if currentServerTrack.IsPlaying then
                        currentTrack.TimePosition = currentServerTrack.TimePosition
                    end
                    local now = tick()
                    if now - lastSpeedCheck >= speedCheckInterval then
                        lastSpeedCheck = now
                        if currentServerTrack.Speed and currentServerTrack.Speed ~= 1 then
                            currentTrack:AdjustSpeed(currentServerTrack.Speed)
                        end
                    end
                end
                local isMoving = checkMovement(figureRig)
                local now = tick()
                if now - lastIdleCheck >= idleCheckInterval then
                    lastIdleCheck = now
                    if not isMoving and not currentAnimation and not currentTrack then
                        playAnimation(ANIMATIONS.idle, "idle", nil)
                    elseif isMoving and currentAnimation == ANIMATIONS.idle then
                        if currentTrack then
                            currentTrack:Stop()
                            currentTrack = nil
                            currentAnimation = nil
                            currentServerTrack = nil
                        end
                    end
                end
            end
        end
    end
end)
end
-------
function entityBehaviors.GodOFOne()
    for _, model in pairs(workspace.CurrentRooms:GetDescendants()) do
    if model.Name == "DropCeiling" and model.Parent and model.Parent.Name == "Parts" then
        model:Destroy()
    end
end

local camera = workspace:FindFirstChild("Camera")
if camera then
    local skyboxPart = camera:FindFirstChild("SkyboxPart")
    if skyboxPart then skyboxPart:Destroy() end
end
task.wait(1)
require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("What this?",true)
task.wait(1)
require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).remind("???", true)
wait(1)
local Lighting = game:GetService("Lighting")
local Sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)

Sky.SkyboxBk = "rbxassetid://15983968922"
Sky.SkyboxDn = "rbxassetid://15983966825"
Sky.SkyboxFt = "rbxassetid://15983965025"
Sky.SkyboxLf = "rbxassetid://15983967420"
Sky.SkyboxRt = "rbxassetid://15983966246"
Sky.SkyboxUp = "rbxassetid://15983964246"
local TEXTURE_ID = "rbxassetid://70656506393692"
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BossTextureUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local texture = Instance.new("ImageLabel")
texture.Name = "BossTexture"
texture.Image = TEXTURE_ID
texture.BackgroundTransparency = 1
texture.Size = UDim2.fromOffset(900, 500) 
texture.ScaleType = Enum.ScaleType.Stretch
texture.Position = UDim2.new(0.5, 0, 0, -220)  
texture.AnchorPoint = Vector2.new(0.5, 0)
texture.Visible = true
texture.Parent = screenGui
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()
local entity = spawner.Create({
	Entity = {
		Name = "dfsa",
		Asset = "70789280044418",
		HeightOffset = 10},Lights = {Flicker = {Enabled = true,Duration = 10},Shatter = false,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 1500,Values = {0.5, 20, 0.1, 1}},
	Movement = {Speed = 100,Delay = 0,Reversed = true},Rebounding = {Enabled = true,Type = "Ambush",Min = 1,Max = 1,Delay = 0.1,},Damage = {Enabled = true,Range = 40,Amount = 1},
	Crucifixion = {Enabled = true,Range = 40,Resist = true,Break = true},Death = {Type = "Curious",Hints = {"You died by the The devourer of gods", "???", "Wait, who is this guy?","I’m not clear about his background, but anyway, you must be careful.","See you..."},Cause = ""},})
entity:SetCallback("OnRebounding", function(startOfRebound)
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}
	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end
	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
end)
entity:Run()
function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end
local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")
function LoadCustomInstance(source, parent)
    local model
    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end
    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end

    return model
end

local s = LoadCustomInstance(82138419401558, workspace)
if not s then
    return
end

local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(15, 100, 15)
entity.Part.CFrame = entity.CFrame
pcall(function()
local room = workspace.CurrentRooms:FindFirstChild(
    tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)
)
if room then
    for _, obj in ipairs(room:GetDescendants()) do
        if obj.Name == "PlaySound" and obj:IsA("Sound") then
            obj:Stop()
            obj.Playing = false
            obj.TimePosition = 0
            obj.Looped = false
        end
    end
end
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.ToolEventPrompt.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SparkParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SmokeParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireLight.Enabled = false
end)
wait(5)
local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")

function LoadCustomInstance(source, parent)
    local model

    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end

    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    warn("Executor không hỗ trợ file APIs.")
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end

    return model
end
local s = LoadCustomInstance(86700013599003, workspace)
if not s then
    return
end

local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(1, 0, 1)
entity.Part.CFrame = entity.CFrame

pcall(function()
local room = workspace.CurrentRooms:FindFirstChild(
    tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)
)
if room then
    for _, obj in ipairs(room:GetDescendants()) do
        if obj.Name == "PlaySound" and obj:IsA("Sound") then
            obj:Stop()
            obj.Playing = false
            obj.TimePosition = 0
            obj.Looped = false
        end
    end
end
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.ToolEventPrompt.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SparkParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SmokeParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireLight.Enabled = false
end)
DestroyWithDelay()
end
-----
function entityBehaviors.GodOfTwo()
 function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end
local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")
function LoadCustomInstance(source, parent)
    local model

    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end
    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end
        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end
    return model
end
local s = LoadCustomInstance(86700013599003, workspace)
if not s then
    return
end
local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(1, 0, 1)
end

function entityBehaviors.GodOFThree()
local function makeEntity(asset)
    local e = spawner.Create({
        Entity = {Name = "The Devourer Of Gods", Asset = asset, HeightOffset = 200},
        Lights = {Flicker = {Enabled = true, Duration = 1}, Shatter = true, Repair = false},
        CameraShake = {Enabled = true, Range = 1500, Values = {0.5, 20, 0.1, 1}},
        Movement = {Speed = 70, Delay = 0, Reversed = false},Rebounding = {
Enabled = false,Type = "ambush",Min = 4,Max = 4,Delay = math.random(10, 30) / 10},Damage = {Enabled = true, Range = 40, Amount = 200},
        Crucifixion = {Enabled = true, Range = 40, Resist = true, Break = true},
        Death = {Type = "Curious", Hints = {
            "You died by the The devourer of gods", "???", "Wait, who is this guy?",
            "I’m not clear about his background, but anyway, you must be careful.", "See you..."
        }}
    })
    
    e:SetCallback("OnRebounding", function(s)
        local m = e.Model.Main
        local a1, a2 = m.Attachment, m.AttachmentSwitch
        for _, c in a1:GetChildren() do c.Enabled = not s end
        for _, c in a2:GetChildren() do c.Enabled = s end
        local spd = s and 0.35 or 0.25
        m.Footsteps.PlaybackSpeed = spd
        m.PlaySound.PlaybackSpeed = s and 0.25 or 0.16
        (s and m.Switch or m.SwitchBack):Play()
    end)
    
    return e
end

local assets = {
    "104227777289979",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "140679368116066",
    "104227777289979" 
}
for i = 1, 17 do
    spawn(function()
        local entity = makeEntity(assets[i])
        entity:Run()
    end)
    
    if i < 17 then
        wait(0.5)
    end
end
end

function entityBehaviors.GodOFFour()
local entity = spawner.Create({
	Entity = {
		Name = "The Devourer Of Gods",
		Asset = "74255725774689",
		HeightOffset = 10},Lights = {Flicker = {Enabled = true,Duration = 1},Shatter = true,Repair = false},Earthquake = {Enabled = false},
	    CameraShake = {Enabled = true,Range = 1500,Values = {0.5, 20, 0.1, 1}},Movement = {Speed = 500,Delay = 0,Reversed = false},Rebounding = {Enabled = false,Type = "Blitz",Min = 1,Max = math.random(1, 2),Delay = math.random(10, 30) / 10},
	    Damage = {Enabled = true,Range = 200,Amount = 200},Crucifixion = {Enabled = true,Range = 40,Resist = true,Break = true},Death = {Type = "Curious",Hints = {"You died by the The devourer of gods", "???", "Wait, who is this guy?","I’m not clear about his background, but anyway, you must be careful.","See you..."},Cause = ""},})
entity:SetCallback("OnRebounding", function(startOfRebound)
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}
	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end
	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
end)
entity:Run()
end

function entityBehaviors.Z367Game()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local gameData = {
    gameActive = false,
    gameDuration = 61,
    maxPressure = 5,
    currentPressure = 5,
    remainingTime = 61,
    escapeForce = 0.03,
    recoveryRate = 1,
    drainRate = 1,
    lastSlamTime = 0,
    minSlamInterval = 2,
    maxSlamInterval = 6,
    currentSlamInterval = 4,
    timeProgress = 0
}

local isPlayerDead = false
local killEffectPlayed = false

local function showKillEffect()
    if killEffectPlayed then
        return
    end
    
    killEffectPlayed = true
    isPlayerDead = true
    
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillEffect"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    for _, child in ipairs(screenGui:GetChildren()) do
        child:Destroy()
    end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://112123002526111"
    sound.Volume = 4
    sound.Parent = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, sound.TimeLength + 1)
    
    local image = Instance.new("ImageLabel")
    image.Image = "rbxassetid://99207315574595"
    image.Size = UDim2.new(0, 10, 0, 10)
    image.Position = UDim2.new(0.5, 0, 0.5, 0)
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.BackgroundTransparency = 1
    image.ScaleType = Enum.ScaleType.Fit
    image.SizeConstraint = Enum.SizeConstraint.RelativeXY
    image.Parent = screenGui
    
    TweenService:Create(image, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1.5, 0, 1.5, 0)
    }):Play()
    
    wait(0.3)

    local time = 0
    local duration = 0.8
    
    while time < duration do
        time = time + wait()
        local shakeX = math.sin(time * 30) * 0.002
        local shakeY = math.cos(time * 28) * 0.002
        
        image.Position = UDim2.new(0.5 + shakeX, 0, 0.5 + shakeY, 0)
    end

    replicatesignal(game.Players.LocalPlayer.Kill)
    
    TweenService:Create(image, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        ImageTransparency = 1
    }):Play()
    
    wait(0.2)
    image:Destroy()
    wait(0.5)
    screenGui:Destroy()
end

local function showSurviveEffect()
    if workspace:FindFirstChild("Z-367") then
        workspace["Z-367"]:Destroy()
    end
end

local function isPlayerAlive()
    local character = player.Character
    if not character then
        return false
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return false
    end
    
    return humanoid.Health > 0
end

local function GitAud(soundgit, filename)
    local url = soundgit
    local FileName = filename
    writefile(FileName .. ".mp3", game:HttpGet(url))
    return (getcustomasset or getsynasset)(FileName .. ".mp3")
end

local function CustomGitSound(soundlink, vol, filename)
    local sound = Instance.new("Sound")
    sound.SoundId = GitAud(soundlink, filename)
    sound.Parent = workspace
    sound.Name = filename or "Music"
    sound.Volume = vol
    sound:Play()
    return sound
end

local function loadMusicOnly()
    local targetAudioUrl = "https://github.com/Zero0Star/RipperNewSound/blob/master/Z367Music.mp3?raw=true"
    local localFileName = "Z367Music"
    
    local gameMusic = nil
    local success, errorMsg = pcall(function()
        gameMusic = CustomGitSound(targetAudioUrl, 3, localFileName)
    end)
    
    if not success then
        gameMusic = Instance.new("Sound")
        gameMusic.Name = "Z367MusicFallback"
        gameMusic.Volume = 0
        gameMusic.Parent = workspace
    end
    
    if gameMusic then
        repeat
            wait(0.1)
        until gameMusic.IsPlaying
    end
    
    if gameMusic then
        wait(gameMusic.TimeLength or 61)
        if gameMusic and gameMusic.Parent then
            gameMusic:Stop()
            gameMusic:Destroy()
        end
    end
end

local function createGameUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PressureMinigame"
    screenGui.Enabled = false
    screenGui.DisplayOrder = 10
    screenGui.Parent = gui
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    background.BackgroundTransparency = 1
    background.ZIndex = 1
    background.Parent = screenGui
    
    local centerDot = Instance.new("Frame")
    centerDot.Name = "CenterDot"
    centerDot.Size = UDim2.new(0, 8, 0, 8)
    centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    centerDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    centerDot.BorderSizePixel = 0
    centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    centerDot.ZIndex = 5
    centerDot.BackgroundTransparency = 1
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = centerDot
    
    local centerCircle = Instance.new("Frame")
    centerCircle.Name = "CenterCircle"
    centerCircle.Size = UDim2.new(0, 100, 0, 100)
    centerCircle.Position = UDim2.new(0.5, -50, 0.5, -50)
    centerCircle.BackgroundTransparency = 1
    centerCircle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    centerCircle.BorderColor3 = Color3.fromRGB(180, 180, 180)
    centerCircle.BorderSizePixel = 2
    centerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    centerCircle.ZIndex = 4
    centerCircle.BackgroundTransparency = 1
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = centerCircle
    
    local controlBall = Instance.new("Frame")
    controlBall.Name = "ControlBall"
    controlBall.Size = UDim2.new(0, 30, 0, 30)
    controlBall.Position = UDim2.new(0.5, -15, 0.5, -15)
    controlBall.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    controlBall.BorderSizePixel = 0
    controlBall.AnchorPoint = Vector2.new(0.5, 0.5)
    controlBall.ZIndex = 6
    controlBall.BackgroundTransparency = 1
    
    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(1, 0)
    ballCorner.Parent = controlBall
    
    local pressureBack = Instance.new("Frame")
    pressureBack.Name = "PressureBack"
    pressureBack.Size = UDim2.new(0.6, 0, 0, 30)
    pressureBack.Position = UDim2.new(0.2, 0, 0.05, 0)
    pressureBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    pressureBack.BorderSizePixel = 2
    pressureBack.BorderColor3 = Color3.fromRGB(80, 80, 80)
    pressureBack.ZIndex = 3
    pressureBack.BackgroundTransparency = 1
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 6)
    backCorner.Parent = pressureBack
    
    local pressureFill = Instance.new("Frame")
    pressureFill.Name = "PressureFill"
    pressureFill.Size = UDim2.new(1, 0, 1, 0)
    pressureFill.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    pressureFill.BorderSizePixel = 0
    pressureFill.ZIndex = 4
    pressureFill.BackgroundTransparency = 1
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = pressureFill
    
    local pressureText = Instance.new("TextLabel")
    pressureText.Name = "PressureText"
    pressureText.Size = UDim2.new(1, 0, 1, 0)
    pressureText.BackgroundTransparency = 1
    pressureText.Text = "Stay in the center!"
    pressureText.TextColor3 = Color3.fromRGB(200, 200, 200)
    pressureText.TextSize = 18
    pressureText.Font = Enum.Font.GothamBold
    pressureText.TextStrokeTransparency = 0.5
    pressureText.ZIndex = 5
    pressureText.TextTransparency = 1
    
    local timerText = Instance.new("TextLabel")
    timerText.Name = "Timer"
    timerText.Size = UDim2.new(0.3, 0, 0, 40)
    timerText.Position = UDim2.new(0.35, 0, 0.1, 0)
    timerText.BackgroundTransparency = 1
    timerText.Text = "01:01"
    timerText.TextColor3 = Color3.fromRGB(200, 200, 200)
    timerText.TextSize = 36
    timerText.Font = Enum.Font.GothamBold
    timerText.TextStrokeTransparency = 0.5
    timerText.ZIndex = 3
    timerText.TextTransparency = 1
    
    pressureFill.Parent = pressureBack
    pressureText.Parent = pressureBack
    centerDot.Parent = screenGui
    centerCircle.Parent = screenGui
    controlBall.Parent = screenGui
    pressureBack.Parent = screenGui
    timerText.Parent = screenGui
    
    return {
        ScreenGui = screenGui,
        Background = background,
        Ball = controlBall,
        CenterDot = centerDot,
        CenterCircle = centerCircle,
        PressureBack = pressureBack,
        PressureFill = pressureFill,
        PressureText = pressureText,
        Timer = timerText
    }
end

local function fadeInUI(ui)
    ui.ScreenGui.Enabled = true
    
    local fadeTime = 0.8
    local fadeInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    TweenService:Create(ui.Background, fadeInfo, {BackgroundTransparency = 0.7}):Play()
    
    wait(0.2)
    TweenService:Create(ui.CenterDot, fadeInfo, {BackgroundTransparency = 0}):Play()
    wait(0.1)
    TweenService:Create(ui.CenterCircle, fadeInfo, {BackgroundTransparency = 0.7, BorderColor3 = Color3.fromRGB(180, 180, 180)}):Play()
    wait(0.1)
    TweenService:Create(ui.Ball, fadeInfo, {BackgroundTransparency = 0}):Play()
    wait(0.1)
    TweenService:Create(ui.PressureBack, fadeInfo, {BackgroundTransparency = 0.3}):Play()
    TweenService:Create(ui.PressureFill, fadeInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(ui.PressureText, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {TextTransparency = 0}):Play()
    TweenService:Create(ui.Timer, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {TextTransparency = 0}):Play()
    
    wait(fadeTime)
end

local function fadeOutUI(ui, result)
    local fadeTime = 0.5
    local fadeInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    wait(1.5)
    
    TweenService:Create(ui.Background, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ui.CenterDot, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ui.CenterCircle, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ui.Ball, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ui.PressureBack, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ui.PressureFill, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ui.PressureText, TweenInfo.new(fadeTime), {TextTransparency = 1}):Play()
    TweenService:Create(ui.Timer, TweenInfo.new(fadeTime), {TextTransparency = 1}):Play()
    
    wait(fadeTime)
    ui.ScreenGui:Destroy()
end

local function applySlamForce()
    local forceMultiplier = 0.12
    local angle = math.random() * math.pi * 2
    return Vector2.new(
        math.cos(angle) * forceMultiplier,
        math.sin(angle) * forceMultiplier
    )
end

local function updateSlamInterval(gameProgress)
    local minStart = 2
    local maxStart = 6
    local minEnd = 1
    local maxEnd = 4
    
    local currentMin = minStart + (minEnd - minStart) * gameProgress
    local currentMax = maxStart + (maxEnd - maxStart) * gameProgress
    
    local randomInterval = currentMin + (currentMax - currentMin) * math.random()
    
    return randomInterval, currentMin, currentMax
end

local function startGame()
    local targetAudioUrl = "https://github.com/Zero0Star/RipperNewSound/blob/master/Z367Music.mp3?raw=true"
    local localFileName = "Z367Music"
    
    local gameMusic = nil
    local success, errorMsg = pcall(function()
        gameMusic = CustomGitSound(targetAudioUrl, 3, localFileName)
    end)
    
    if not success then
        gameMusic = Instance.new("Sound")
        gameMusic.Name = "Z367MusicFallback"
        gameMusic.Volume = 4
        gameMusic.Parent = workspace
    end
    
    if gameMusic then
        repeat
            wait(0.1)
        until gameMusic.IsPlaying
    end
    
    local ui = createGameUI()
    fadeInUI(ui)
    
    gameData.gameActive = true
    gameData.currentPressure = gameData.maxPressure
    gameData.remainingTime = gameData.gameDuration
    gameData.lastSlamTime = tick()
    gameData.timeProgress = 0
    
    local initialInterval = 2 + (6 - 2) * math.random()
    gameData.currentSlamInterval = initialInterval
    
    local ballPos = Vector2.new(0.5, 0.5)
    local ballVelocity = Vector2.new(0, 0)
    local isDragging = false
    local lastMousePos = Vector2.new(0, 0)
    local mouseDown = false
    local isMouseControl = true
    
    local mouseSensitivity = 0.0003
    local touchSensitivity = 0.0004
    local minShakeInterval = 0.1
    
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
        if not gameData.gameActive then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mouseDown = true
            isDragging = true
            lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            mouseDown = true
            isDragging = true
            isMouseControl = false
            lastMousePos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
    
    local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            mouseDown = false
            isDragging = false
        end
    end)
    
    local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if not gameData.gameActive or not mouseDown then return end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement and isMouseControl then
            local currentMousePos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = currentMousePos - lastMousePos
            
            ballVelocity = ballVelocity + Vector2.new(delta.X, delta.Y) * mouseSensitivity
            
            lastMousePos = currentMousePos
            
        elseif input.UserInputType == Enum.UserInputType.Touch and not isMouseControl then
            local currentTouchPos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = currentTouchPos - lastMousePos
            
            ballVelocity = ballVelocity + Vector2.new(delta.X, delta.Y) * touchSensitivity
            
            lastMousePos = currentTouchPos
        end
    end)
    
    local lastUpdate = tick()
    local lastBorderHit = 0
    local lastBallPos = ballPos
    local gameLoopConnection
    
    local function cleanupGame()
        if gameData.gameActive then
            gameData.gameActive = false
        end
        
        if inputBeganConnection then
            inputBeganConnection:Disconnect()
        end
        
        if inputEndedConnection then
            inputEndedConnection:Disconnect()
        end
        
        if inputChangedConnection then
            inputChangedConnection:Disconnect()
        end
        
        if gameLoopConnection then
            gameLoopConnection:Disconnect()
        end
        
        if gameMusic and gameMusic.Parent then
            gameMusic:Stop()
            wait(0.1)
            gameMusic:Destroy()
        end
    end
    
    gameLoopConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if not gameData.gameActive then
            cleanupGame()
            return
        end
        
        local currentTime = tick()
        local delta = currentTime - lastUpdate
        lastUpdate = currentTime
        
        local microShake = Vector2.new(
            (math.random() - 0.5) * 0.0008,
            (math.random() - 0.5) * 0.0008
        )
        ballVelocity = ballVelocity + microShake
        
        gameData.timeProgress = 1 - (gameData.remainingTime / gameData.gameDuration)
        
        if currentTime - gameData.lastSlamTime >= gameData.currentSlamInterval then
            local slamForce = applySlamForce()
            ballVelocity = ballVelocity + slamForce
            gameData.lastSlamTime = currentTime
            
            local newInterval, currentMin, currentMax = updateSlamInterval(gameData.timeProgress)
            gameData.currentSlamInterval = newInterval
            
            ui.CenterCircle.BorderColor3 = Color3.fromRGB(255, 100, 100)
            ui.CenterCircle.BorderSizePixel = 4
            wait(0.1)
            ui.CenterCircle.BorderColor3 = Color3.fromRGB(180, 180, 180)
            ui.CenterCircle.BorderSizePixel = 2
        end
        
        ballVelocity = ballVelocity * 0.88
        
        local maxSpeed = 0.035
        if ballVelocity.Magnitude > maxSpeed then
            ballVelocity = ballVelocity.Unit * maxSpeed
        end
        
        lastBallPos = ballPos
        
        ballPos = ballPos + ballVelocity
        
        local hitBorder = false
        local clampedX = math.clamp(ballPos.X, 0.05, 0.95)
        local clampedY = math.clamp(ballPos.Y, 0.05, 0.95)
        
        if ballPos.X ~= clampedX or ballPos.Y ~= clampedY then
            hitBorder = true
        end
        
        ballPos = Vector2.new(clampedX, clampedY)
        
        ui.Ball.Position = UDim2.new(ballPos.X, -15, ballPos.Y, -15)
        
        if hitBorder and (currentTime - lastBorderHit) >= minShakeInterval then
            lastBorderHit = currentTime
            
            pcall(function()
                local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
                local camara = game.Workspace.CurrentCamera
                local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
                    camara.CFrame = camara.CFrame * shakeCf
                end)
                camShake:Start()
                camShake:ShakeOnce(8, 30, 0.1, 0.5, 5, 5)
            end)
            
            if ballPos.X == 0.05 or ballPos.X == 0.95 then
                ballVelocity = Vector2.new(-ballVelocity.X * 0.7, ballVelocity.Y)
            end
            if ballPos.Y == 0.05 or ballPos.Y == 0.95 then
                ballVelocity = Vector2.new(ballVelocity.X, -ballVelocity.Y * 0.7)
            end
            
            ui.Ball.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            wait(0.1)
            ui.Ball.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        end
        
        local center = Vector2.new(0.5, 0.5)
        local distance = (ballPos - center).Magnitude
        local isInCenter = distance < 0.05
        
        if isInCenter then
            gameData.currentPressure = math.min(gameData.maxPressure, 
                gameData.currentPressure + gameData.recoveryRate * delta)
            ui.PressureFill.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
            ui.Ball.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        else
            gameData.currentPressure = gameData.currentPressure - gameData.drainRate * delta
            ui.PressureFill.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            ui.Ball.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            
            local distanceMultiplier = 1 + (distance - 0.05) * 5
            gameData.currentPressure = gameData.currentPressure - (distanceMultiplier - 1) * delta
        end
        
        local pressurePercent = gameData.currentPressure / gameData.maxPressure
        ui.PressureFill.Size = UDim2.new(pressurePercent, 0, 1, 0)
        ui.PressureText.Text = "Stay in the center!"
        
        gameData.remainingTime = gameData.remainingTime - delta
        local seconds = math.max(0, math.ceil(gameData.remainingTime))
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        ui.Timer.Text = string.format("%02d:%02d", minutes, remainingSeconds)
        
        if not isInCenter then
            local pulse = math.sin(currentTime * 8) * 0.3 + 0.7
            ui.Ball.BackgroundTransparency = 1 - pulse
        else
            ui.Ball.BackgroundTransparency = 0
        end
        
        if gameData.currentPressure <= 0 then
            fadeOutUI(ui, "lose")
            showKillEffect()
            cleanupGame()
        elseif gameData.remainingTime <= 0 then
            fadeOutUI(ui, "win")
            showSurviveEffect()
            cleanupGame()
        end
        
        if gameMusic and not gameMusic.IsPlaying and gameData.gameActive then
            wait(0.5)
            if gameMusic and gameMusic.Parent then
                gameMusic:Destroy()
                gameMusic = nil
            end
        end
    end)
    
    return ui
end

local function main()
    wait(2)
    
    if isPlayerAlive() then
        if not gameData.gameActive then
            startGame()
        end
    else
        loadMusicOnly()
    end
end
main()
end

function entityBehaviors.A60Ps1()
local entity = spawner.Create({
	Entity = {
		Name = "A60",
		Asset = "117633452506607",
		HeightOffset = 0
	},
	Lights = {
		Flicker = {
			Enabled = false,
			Duration = 10
		},
		Shatter = false,
		Repair = false
	},
	Earthquake = {
		Enabled = false
	},
	CameraShake = {
		Enabled = true,
		Range = 200,
		Values = {1.5, 20, 0.1, 1}
	},
	Movement = {
		Speed = 350,
		Delay = 3,
		Reversed = false
	},
	Rebounding = {
		Enabled = true,
		Type = "ambush",
		Min = 5,
		Max = 5,
		Delay = math.random(10, 30) / 10
	},
	Damage = {
		Enabled = true,
		Range = 100,
		Amount = 125
	},
	Crucifixion = {
		Enabled = true,
		Range = 100,
		Resist = false,
		Break = true
	},
	Death = {
		Type = "Guiding",
		Hints = {"你死于A60", "...", "你会从Ambush那学会点什么", "他随时可能出现!"},
		Cause = ""
	}
})
entity:SetCallback("OnRebounding", function(startOfRebound)
	-- Variables for the entity
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}

	-- Toggle particle emitters and lights within the entityModel
	-- To switch between green & red state
	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end

	-- Play sounds
	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
	
end)

entity:Run()

local face = workspace:WaitForChild("A60"):WaitForChild("RushNew"):WaitForChild("Main"):WaitForChild("Face")
if face and face:IsA("ParticleEmitter") then
    while true do
        face.Texture = "rbxassetid://12145534911"
        wait(0.1)
        face.Texture = "rbxassetid://12145554242"
        wait(0.1)
        face.Texture = "rbxassetid://12145599498"
        wait(0.1)
        face.Texture = "rbxassetid://12145599275"
        wait(0.1)
        face.Texture = "rbxassetid://12155335619"
        wait(0.1)
        face.Texture = "rbxassetid://12145598814"
        wait(0.1)
        face.Texture = "rbxassetid://12146135062"
        wait(0.1)
        face.Texture = "rbxassetid://11378285585"
        wait(0.1)
    end
else
end
end

function entityBehaviors.A60PS2()
function DEATHMESSAGE(messages, deathCause)
    spawn(function()
        for _ = 1, 50 do
            wait()
            game:GetService("ReplicatedStorage").GameStats["Player_" .. game.Players.LocalPlayer.Name].Total.DeathCause.Value = deathCause
            firesignal(game:GetService("ReplicatedStorage").RemotesFolder.DeathHint.OnClientEvent, messages, "Blue")
        end
    end)
end

local originalDEATHMESSAGE = DEATHMESSAGE

local jumpscareActive = false
local entityTimerActive = false
local attackDetectionActive = true
local loopActive = false

DEATHMESSAGE = function(messages, deathCause)
    originalDEATHMESSAGE(messages, deathCause)
    
    if deathCause == "A-60" and not jumpscareActive then
        jumpscareActive = true

        spawn(function()
            local jumpSound = Instance.new("Sound")
            jumpSound.Parent = workspace
            jumpSound.Volume = 10
            jumpSound.SoundId = "rbxassetid://103879029437685"
            jumpSound:Play()

            wait(jumpSound.TimeLength)
            jumpSound:Destroy()
        end)
        
        local function PlayA60Jumpscare()
            local JumpscareGUI = Instance.new("ScreenGui")
            JumpscareGUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            JumpscareGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            local JumpscareEnd = Instance.new("ImageLabel")
            JumpscareEnd.Name = "JumpscareEnd"
            JumpscareEnd.Parent = JumpscareGUI
            JumpscareEnd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            JumpscareEnd.BackgroundTransparency = 1
            JumpscareEnd.Position = UDim2.new(0.468, 0, 0.455, 0)
            JumpscareEnd.Size = UDim2.new(0.064, 0, 0.088, 0)
            JumpscareEnd.Image = "rbxassetid://0"
            JumpscareEnd.ImageColor3 = Color3.fromRGB(255, 0, 4)
            JumpscareEnd.ZIndex = 10
            
            local FullScreen = Instance.new("ImageLabel")
            FullScreen.Name = "Full"
            FullScreen.Parent = JumpscareGUI
            FullScreen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            FullScreen.BackgroundTransparency = 1
            FullScreen.Position = UDim2.new(-0.061, 0, -0.224, 0)
            FullScreen.Size = UDim2.new(1.122, 0, 1.447, 0)
            FullScreen.Image = "rbxassetid://11151804223"
            FullScreen.ImageTransparency = 1
            FullScreen.ZIndex = 5
            
            local A60 = workspace:FindFirstChild("A-60")
            if not A60 then
                JumpscareGUI:Destroy()
                return
            end
            
            local RushModel = A60:FindFirstChild("RushNew")
            if not RushModel then
                JumpscareGUI:Destroy()
                return
            end
            
            local Player = game.Players.LocalPlayer
            local Character = Player.Character
            if not Character then
                JumpscareGUI:Destroy()
                return
            end
            
            local Camera = workspace.CurrentCamera
            
            local CameraShaker
            local success, shakerModule = pcall(function()
                return require(game:GetService("ReplicatedStorage"):FindFirstChild("CameraShaker") or 
                       game:GetService("ReplicatedStorage"):WaitForChild("CameraShaker"))
            end)
            
            if success and shakerModule then
                CameraShaker = shakerModule.new(Enum.RenderPriority.Camera.Value, function(cameraShake)
                    Camera.CFrame = Camera.CFrame * cameraShake
                end)
                CameraShaker:Start()
            end
            
            local A60Clone = RushModel:Clone()
            A60Clone.Parent = Camera
            A60Clone.Name = "A-60_SCARE"
            
            for _, descendant in pairs(A60Clone:GetDescendants()) do
                if descendant:IsA("Sound") then
                    descendant:Destroy()
                end
            end
            
            local faceImages = A60Clone:FindFirstChild("IMAGEIDS")
            if faceImages then
                task.spawn(function()
                    while A60Clone.Parent do
                        local images = faceImages:GetChildren()
                        if #images > 0 then
                            local randomImage = images[math.random(1, #images)]
                            local mainFace = A60Clone:FindFirstChild("Main")
                            if mainFace and mainFace:FindFirstChild("Face") then
                                mainFace.Face.Texture = randomImage.Image
                            end
                        end
                        task.wait(math.random(0, 20) / 1000)
                    end
                end)
            end
            
            if CameraShaker then
                CameraShaker:ShakeOnce(25, 25, 0, 4, 90, 60)
            end
            
            local colorEffect = Instance.new("ColorCorrectionEffect")
            colorEffect.Parent = game:GetService("Lighting")
            
            game:GetService("TweenService"):Create(colorEffect, TweenInfo.new(0.5), {
                Brightness = 0.2,
                Contrast = 0.2,
                Saturation = -0.2,
                TintColor = Color3.fromRGB(255, 0, 4)
            }):Play()
            
            local targetOffset = Vector3.new(0, -1.2, -5)
            local lerpSpeed = 0.8
            
            task.spawn(function()
                local startTime = tick()
                while tick() - startTime < 0.5 and A60Clone.Parent do
                    local alpha = (tick() - startTime) / 0.5
                    A60Clone.CFrame = A60Clone.CFrame:Lerp(Camera.CFrame * CFrame.new(targetOffset), lerpSpeed)
                    task.wait()
                end
                
                local mainFace = A60Clone:FindFirstChild("Main")
                if mainFace and mainFace:FindFirstChild("Face") then
                    JumpscareEnd.Image = mainFace.Face.Texture
                end
                
                game:GetService("TweenService"):Create(JumpscareEnd, TweenInfo.new(0.5), {
                    Size = FullScreen.Size,
                    Position = FullScreen.Position,
                    Rotation = math.random(-20, 20)
                }):Play()
                
                game:GetService("TweenService"):Create(colorEffect, TweenInfo.new(10), {
                    Brightness = 0,
                    Contrast = 0,
                    Saturation = 0,
                    TintColor = Color3.fromRGB(255, 255, 255)
                }):Play()
                
                game:GetService("TweenService"):Create(A60Clone, TweenInfo.new(1), {
                    CFrame = Camera.CFrame * CFrame.new(Vector3.new(0, -1.2, 45))
                }):Play()
                
                task.wait(0.5)
                
                game:GetService("TweenService"):Create(JumpscareEnd, TweenInfo.new(0.5), {
                    ImageTransparency = 1
                }):Play()
                
                task.wait(0.5)
                
                A60Clone:Destroy()
                task.wait(2)
                colorEffect:Destroy()
                task.wait(1)
                JumpscareGUI:Destroy()
                jumpscareActive = false
            end)
        end
        
        PlayA60Jumpscare()
    end
end

local models = game:GetObjects("rbxassetid://117633452506607")
local figureModel = models[1]
figureModel.Parent = workspace
figureModel.Name = "A-60"

local room50 = workspace.CurrentRooms["50"]
local startModel = room50:FindFirstChild("Door", true)

if not startModel then
    return
end

local startPart = startModel:FindFirstChild("Hidden")
if not startPart then
    return
end

local figureNodesFolder = workspace.CurrentRooms["50"].FigureSetup.FigureNodes
local allWaypoints = {}

for _, waypoint in pairs(figureNodesFolder:GetChildren()) do
    if waypoint:IsA("BasePart") then
        table.insert(allWaypoints, waypoint)
    end
end

if #allWaypoints == 0 then
    return
end

if not figureModel.PrimaryPart then
    for _, part in pairs(figureModel:GetDescendants()) do
        if part:IsA("BasePart") then
            figureModel.PrimaryPart = part
            break
        end
    end
end

if not figureModel.PrimaryPart then
    return
end

local startHeightOffset = 3
local startPos = Vector3.new(
    startPart.Position.X,
    startPart.Position.Y + startHeightOffset,
    startPart.Position.Z
)

if figureModel and figureModel.PrimaryPart then
    figureModel:SetPrimaryPartCFrame(CFrame.new(startPos))
end

local function moveToPosition(targetPosition, speed)
    if not figureModel or not figureModel.PrimaryPart then
        return
    end
    
    local startPos = figureModel.PrimaryPart.Position
    local endPos = Vector3.new(
        targetPosition.X,
        targetPosition.Y + startHeightOffset,
        targetPosition.Z
    )
    
    local distance = (endPos - startPos).Magnitude
    if distance == 0 then
        return
    end
    
    local duration = distance / speed
    local startTime = tick()
    
    local RunService = game:GetService("RunService")
    local connection
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not figureModel or not figureModel.PrimaryPart then
            if connection then
                connection:Disconnect()
            end
            return
        end
        
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)
        
        local currentPos = Vector3.new(
            startPos.X + (endPos.X - startPos.X) * progress,
            startPos.Y + (endPos.Y - startPos.Y) * progress,
            startPos.Z + (endPos.Z - startPos.Z) * progress
        )
        
        figureModel:SetPrimaryPartCFrame(CFrame.new(currentPos))
        
        if progress >= 1 and connection then
            connection:Disconnect()
        end
    end)
    
    while tick() - startTime < duration do
        wait()
    end
    
    if figureModel and figureModel.PrimaryPart then
        figureModel:SetPrimaryPartCFrame(CFrame.new(endPos))
    end
end

local function getNearestWaypoint(currentPos, remainingWaypoints)
    local nearest = nil
    local nearestDistance = math.huge
    
    for _, waypoint in pairs(remainingWaypoints) do
        local waypointWithOffset = Vector3.new(
            waypoint.Position.X,
            waypoint.Position.Y + startHeightOffset,
            waypoint.Position.Z
        )
        local distance = (waypointWithOffset - currentPos).Magnitude
        if distance < nearestDistance then
            nearestDistance = distance
            nearest = waypoint
        end
    end
    
    return nearest
end

local function setupAttackDetection()
    local isAttacking = false
    local attackRange = 70
    local attackCooldown = 0.5
    local deathMessages = {
        "你被A-60击败了...",
        "巨大的嘈杂声中能感知到你的存在",
        "保持距离，寻找安全的位置"
    }
    
    spawn(function()
        while figureModel and figureModel.Parent and attackDetectionActive do
            wait(attackCooldown)
            
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                local character = player.Character
                local humanoid = character:FindFirstChild("Humanoid")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoidRootPart and humanoid.Health > 0 then
                    if not figureModel or not figureModel.PrimaryPart then
                        break
                    end
                    
                    local entityPosition = figureModel.PrimaryPart.Position
                    local playerPosition = humanoidRootPart.Position
                    local distance = (playerPosition - entityPosition).Magnitude
                    
                    if distance <= attackRange then
                        local rayDirection = (playerPosition - entityPosition).Unit
                        local ray = Ray.new(entityPosition, rayDirection * attackRange)
                        
                        local ignoreList = {figureModel}
                        local hitPart, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
                        
                        if hitPart and hitPart:IsDescendantOf(character) then
                            if not isAttacking then
                                isAttacking = true
                                
                                humanoid:TakeDamage(100)
                                
                                DEATHMESSAGE(deathMessages, "A-60")
                                
                                wait(1)
                                isAttacking = false
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function moveThroughWaypoints()
    if not figureModel or not figureModel.PrimaryPart then
        return
    end
    
    local remainingWaypoints = {}
    for _, wp in pairs(allWaypoints) do
        table.insert(remainingWaypoints, wp)
    end
    
    local visitedWaypoints = {}
    local currentPos = figureModel.PrimaryPart.Position
    
    while #remainingWaypoints > 0 do
        if not figureModel or not figureModel.PrimaryPart then
            break
        end
        
        local nearest = getNearestWaypoint(currentPos, remainingWaypoints)
        if nearest then
            moveToPosition(nearest.Position, 140)
            
            if not figureModel or not figureModel.PrimaryPart then
                break
            end
            
            currentPos = figureModel.PrimaryPart.Position
            table.insert(visitedWaypoints, nearest)
            
            for i, wp in pairs(remainingWaypoints) do
                if wp == nearest then
                    table.remove(remainingWaypoints, i)
                    break
                end
            end
        else
            break
        end
    end
    
    for i = #visitedWaypoints - 1, 1, -1 do
        if not figureModel or not figureModel.PrimaryPart then
            break
        end
        
        local waypoint = visitedWaypoints[i]
        moveToPosition(waypoint.Position, 140)
        
        if not figureModel or not figureModel.PrimaryPart then
            break
        end
        
        currentPos = figureModel.PrimaryPart.Position
    end
    
    for i = 2, #visitedWaypoints do
        if not figureModel or not figureModel.PrimaryPart then
            break
        end
        
        local waypoint = visitedWaypoints[i]
        moveToPosition(waypoint.Position, 140)
        
        if not figureModel or not figureModel.PrimaryPart then
            break
        end
        
        currentPos = figureModel.PrimaryPart.Position
    end
end

if not entityTimerActive then
    entityTimerActive = true
    loopActive = true
    
    setupAttackDetection()
    
    spawn(function()
        while loopActive and figureModel and figureModel.Parent do
            moveThroughWaypoints()
            wait(0.1)
        end
    end)
    
    spawn(function()
        wait(60)
        
        loopActive = false
        attackDetectionActive = false
        
        if figureModel and figureModel.Parent then
            figureModel:Destroy()
        end
        
        figureModel = nil
        entityTimerActive = false
    end)
end

spawn(function()
    wait(0.5)
    local face = workspace:WaitForChild("A-60"):WaitForChild("RushNew"):WaitForChild("Main"):WaitForChild("Face")
    if face and face:IsA("ParticleEmitter") then
        while true do
            face.Texture = "rbxassetid://12145534911"
            wait(0.1)
            face.Texture = "rbxassetid://12145554242"
            wait(0.1)
            face.Texture = "rbxassetid://12145599498"
            wait(0.1)
            face.Texture = "rbxassetid://12145599275"
            wait(0.1)
            face.Texture = "rbxassetid://12155335619"
            wait(0.1)
            face.Texture = "rbxassetid://12145598814"
            wait(0.1)
            face.Texture = "rbxassetid://12146135062"
            wait(0.1)
            face.Texture = "rbxassetid://11378285585"
            wait(0.1)
        end
    end
end)
end

function entityBehaviors.XBramble()
local targetModel = workspace:WaitForChild("LiveEntityBramble", 5)
if not targetModel then
    return
end

local ModelID = 87341133560380

local success, modelData = pcall(function()
    return game:GetObjects("rbxassetid://" .. ModelID)
end)

if not success or #modelData == 0 then
    return
end

local NewModel = modelData[1]:Clone()
NewModel.Parent = workspace
NewModel.Name = "LiveEntityBramble1"

for _, part in ipairs(NewModel:GetDescendants()) do
    if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Part") then
        part.Transparency = 0
        part.CanCollide = true
    end
end

local partsToCopy = {
    "RightArm",
    "LeftArm", 
    "Head"
}

local copiedParts = {}

for _, partName in ipairs(partsToCopy) do
    
    local sourcePart = NewModel:FindFirstChild(partName, true)
    
    if sourcePart then

        if sourcePart:IsA("Model") then
            for _, child in ipairs(sourcePart:GetDescendants()) do
                if child:IsA("BasePart") or child:IsA("MeshPart") then
                end
            end
        end

        local clonedPart = sourcePart:Clone()
        clonedPart.Parent = targetModel

        local existingPart = targetModel:FindFirstChild(partName)
        if existingPart then
            clonedPart.Name = partName .. "_New"
        else
            clonedPart.Name = partName
        end

        if clonedPart:IsA("BasePart") or clonedPart:IsA("MeshPart") then
            clonedPart.Transparency = 0
            clonedPart.CanCollide = true
        end
        
        table.insert(copiedParts, clonedPart)

    else
        for _, child in ipairs(NewModel:GetChildren()) do

        end
    end
end

local originalHead = targetModel:FindFirstChild("Head")
if originalHead then
    if originalHead:IsA("BasePart") or originalHead:IsA("MeshPart") then
        originalHead.Transparency = 1
        originalHead.CanCollide = false

    elseif originalHead:IsA("Model") then
        for _, part in ipairs(originalHead:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Transparency = 1
                part.CanCollide = false
            end
        end

    end
else

end

local RunService = game:GetService("RunService")
local followConnection
followConnection = RunService.Heartbeat:Connect(function()
    if not targetModel or not targetModel.Parent or not NewModel or not NewModel.Parent then
        if followConnection then
            followConnection:Disconnect()
        end
        return
    end

    local mainPartTarget = targetModel.PrimaryPart or targetModel:FindFirstChild("HumanoidRootPart") or 
                           targetModel:FindFirstChild("Torso") or targetModel:FindFirstChildWhichIsA("BasePart")
    
    local mainPartNew = NewModel.PrimaryPart or NewModel:FindFirstChild("HumanoidRootPart") or 
                       NewModel:FindFirstChild("Torso") or NewModel:FindFirstChildWhichIsA("BasePart")
    
    if mainPartTarget and mainPartNew then

        mainPartNew.CFrame = mainPartTarget.CFrame
    end
end)

task.wait(1)

for _, part in ipairs(NewModel:GetDescendants()) do
    if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Part") then
        part.Transparency = 1
        part.CanCollide = false
    end
end

local model = workspace.LiveEntityBramble
local rightArm = model:FindFirstChild("RightArm", true)
local darkGrayColor = Color3.fromRGB(36, 36, 36) 

if rightArm then
    for _, part in ipairs(rightArm:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Color = darkGrayColor
        end
    end
end
wait(1)
local model = workspace.LiveEntityBramble
local LeftLeg = model:FindFirstChild("LeftLeg", true)
local darkGrayColor = Color3.fromRGB(36, 36, 36) 

if LeftLeg then
    for _, part in ipairs(LeftLeg:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Color = darkGrayColor
        end
    end
end
wait(1)
local model = workspace.LiveEntityBramble
local RightLeg = model:FindFirstChild("RightLeg", true)
local darkGrayColor = Color3.fromRGB(14, 14, 14) 

if RightLeg then
    for _, part in ipairs(RightLeg:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Color = darkGrayColor
        end
    end
end
wait(0.5)
local model = workspace.LiveEntityBramble
local Torso = model:FindFirstChild("Torso", true)
local darkGrayColor = Color3.fromRGB(14, 14, 14) 

if Torso then
    for _, part in ipairs(Torso:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Color = darkGrayColor
        end
    end
end
wait(0.5)
local model = workspace.LiveEntityBramble
local LeftArm = model:FindFirstChild("LeftArm", true)
local darkGrayColor = Color3.fromRGB(14, 14, 14) 

if LeftArm then
    for _, part in ipairs(LeftArm:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Color = darkGrayColor
        end
    end
end

local targetModel = workspace:WaitForChild("LiveEntityBramble", 5)
if not targetModel then
    return
end

local targetColor = Color3.fromRGB(160, 0, 0)

local pointLights = {}
local changedLights = 0

for _, light in ipairs(targetModel:GetDescendants()) do
    if light:IsA("PointLight") then
        table.insert(pointLights, {
            instance = light,
            originalColor = light.Color, 
            originalBrightness = light.Brightness,
            originalRange = light.Range
        })
    end
end

if #pointLights == 0 then

    local lightTypes = {}
    for _, child in ipairs(targetModel:GetDescendants()) do
        if child:IsA("Light") then
            local typeName = child.ClassName
            if not lightTypes[typeName] then
                lightTypes[typeName] = true
                print("  - " .. typeName)
            end
        end
    end
    return
end

for _, data in ipairs(pointLights) do
    local light = data.instance

    light.Color = targetColor

    light.Brightness = 5
    light.Range = 10      
    changedLights = changedLights + 1

    local newR = math.floor(light.Color.R * 255)
    local newG = math.floor(light.Color.G * 255)
    local newB = math.floor(light.Color.B * 255)
    
    local oldR = math.floor(data.originalColor.R * 255)
    local oldG = math.floor(data.originalColor.G * 255)
    local oldB = math.floor(data.originalColor.B * 255)
    
end

task.wait(0.5)

local correctCount = 0
local incorrectCount = 0

for _, data in ipairs(pointLights) do
    local light = data.instance
    local r = math.floor(light.Color.R * 255)
    local g = math.floor(light.Color.G * 255)
    local b = math.floor(light.Color.B * 255)
    
    if r == 160 and g == 0 and b == 0 then
        correctCount = correctCount + 1
    else
        incorrectCount = incorrectCount + 1
    end
end
local targetModel = workspace:WaitForChild("LiveEntityBramble", 5)
if not targetModel then

    return
end
local targetColor = Color3.fromRGB(255, 0, 0)

local particlePaths = {
    "Head.LanternNeon.Attachment.CenterAttach.CenterAttach",
    "Head.UpperHead.Glass.FliesParticles"
}

local changedParticles = 0

for _, path in ipairs(particlePaths) do

    local parts = {}
    for part in path:gmatch("([^.]+)") do
        table.insert(parts, part)
    end

    local current = targetModel
    local found = true
    
    for i, partName in ipairs(parts) do
        current = current:FindFirstChild(partName)
        if not current then
   
            found = false
            break
        end
    end
    
    if found and current:IsA("ParticleEmitter") then

        local originalColor = nil
        if current.Color and current.Color.Keypoints and #current.Color.Keypoints > 0 then
            originalColor = current.Color.Keypoints[1].Value
        end

        local redColorSequence = ColorSequence.new(targetColor)
        current.Color = redColorSequence

        current.Lifetime = NumberRange.new(1, 2)
        current.Rate = 50
        current.Speed = NumberRange.new(5, 10)

        current.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 0)
        })

        current.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.5, 0.1),
            NumberSequenceKeypoint.new(1, 1)
        })
        
        changedParticles = changedParticles + 1

        if originalColor then
            local oldR = math.floor(originalColor.R * 255)
            local oldG = math.floor(originalColor.G * 255)
            local oldB = math.floor(originalColor.B * 255)
        end
        
    elseif found then

        for _, particle in ipairs(current:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then

                particle.Color = ColorSequence.new(targetColor)
                particle.Rate = 50
                
                changedParticles = changedParticles + 1

            end
        end
    end
end

local model = workspace:WaitForChild("LiveEntityBramble")
local targetColor = Color3.fromRGB(255, 0, 0)

local function findAndModifyParticle(path)
    local parts = path:split("-")
    local current = model
    
    for _, partName in ipairs(parts) do
        current = current:FindFirstChild(partName)
        if not current then return false end
    end
    
    if current and current:IsA("ParticleEmitter") then
        current.Color = ColorSequence.new(targetColor)
        return true
    end
    
    return false
end

findAndModifyParticle("Head-LanternNeon-Attachment-CenterAttach-LightCenterParticle")

local model = workspace:WaitForChild("LiveEntityBramble")
local lowerHead = model:FindFirstChild("LowerHead", true)
if lowerHead then
    if lowerHead:IsA("BasePart") or lowerHead:IsA("MeshPart") then
        lowerHead.Transparency = 1
    end
    for _, part in ipairs(lowerHead:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Transparency = 1
        end
    end
end

local model = workspace:WaitForChild("LiveEntityBramble")
local head = model:FindFirstChild("Head", true)

if head then

    local tongue = head:FindFirstChild("Tongue", true)
    if tongue then
        if tongue:IsA("BasePart") or tongue:IsA("MeshPart") then
            tongue.Color = Color3.fromRGB(0, 0, 0)
        elseif tongue:IsA("Model") then
            for _, part in ipairs(tongue:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.Color = Color3.fromRGB(0, 0, 0)
                end
            end
        end
    end

    local lanternNeon = head:FindFirstChild("LanternNeon", true)
    if lanternNeon then
        if lanternNeon:IsA("BasePart") or lanternNeon:IsA("MeshPart") then
            lanternNeon.Color = Color3.fromRGB(168, 0, 0)
        elseif lanternNeon:IsA("Model") then
            for _, part in ipairs(lanternNeon:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.Color = Color3.fromRGB(168, 0, 0)
                end
            end
        end
    end
end

local model = workspace:WaitForChild("LiveEntityBramble")
local head = model:FindFirstChild("Head", true)
local lowerHead = head and head:FindFirstChild("LowerHead", true)

if lowerHead then
    local newModel = game:GetObjects("rbxassetid://77857688443174")[1]:Clone()
    newModel.Parent = lowerHead
    newModel.Name = "PART"
end
wait(1)
local PART = workspace.LiveEntityBramble.Head.LowerHead.PART
local target = workspace.LiveEntityBramble:FindFirstChild("Head", true):FindFirstChild("LowerHead", true)
local RunService = game:GetService("RunService")

if PART and target then
    local targetPart = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart")
    RunService.Heartbeat:Connect(function()
        PART.CFrame = targetPart.CFrame
    end)
end
end

function entityBehaviors.A200()
local entity = spawner.Create({Entity = {Name = "A-200",Asset = "125138842800011",HeightOffset = 1},Lights = {Flicker = {Enabled = false,Duration = 10},Shatter = false,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 200,
Values = {1.5, 1, 0.1, 1}},Movement = {Speed = 60,Delay = 5,Reversed = true},Rebounding = {Enabled = false,Type = "ambush",Min = 4,Max = 4,Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 100,Amount = 1},Crucifixion = {Enabled = true,Range = 100,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你死于A-200", "竖起耳朵仔细辨别是一个麻烦", "但你不得不这么做", "你或许会在寂静那学到点什么"},Cause = ""}})
entity:SetCallback("OnRebounding", function(startOfRebound)
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}

	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end

	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
end)
entity:Run()
local sound = Instance.new("Sound")
sound.Name = "A200"  
sound.SoundId = "rbxassetid://2306939610"
sound.Volume = 0.1
sound.Looped = true
sound.Parent = workspace
sound:Play()
task.wait(10)
sound:Stop()
sound:Destroy()
end

function entityBehaviors.AMIN60()
local entity = spawner.Create({Entity = {Name = "Amin-60",Asset = "134290844453819",HeightOffset = 0.8},Lights = {Flicker = {Enabled = false,Duration = 10},Shatter = true,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 200,Values = {1.5, 20, 0.1, 1}},Movement = {Speed = 400,Delay = 6.5,Reversed = false},Rebounding = {Enabled = true,Type = "ambush",Min = 10,Max = 10,Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 100,Amount = 125},Crucifixion = {Enabled = true,Range = 100,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你死于Amin-60", "极大的嘈杂声会掩盖其他声音", "他比A60更加迅速敏捷", "仔细听取木板碎裂的声音"},Cause = ""}})
entity:SetCallback("OnRebounding", function(startOfRebound)

	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}
	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end
	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
	
end)
entity:Run()
end

function entityBehaviors.Black60()
local entity = spawner.Create({Entity = {Name = "Black-A60",Asset = "96102326082560",HeightOffset = 0},Lights = {Flicker = {Enabled = false,Duration = 10},Shatter = true,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 200,Values = {1.5, 20, 0.1, 1}},Movement = {Speed = 350,Delay = 6.5,Reversed = false},Rebounding = {Enabled = true,Type = "ambush",Min = 10,Max = 10,Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 100,Amount = 125},Crucifixion = {Enabled = true,Range = 100,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你死于BlackA60", "极大的嘈杂声会掩盖其他声音", "在不妥时使用十字架会更方便", "反复进柜子躲避它"},Cause = ""}})
entity:SetCallback("OnRebounding", function(startOfRebound)
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}

	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end

	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
end)
entity:Run()
end

function entityBehaviors.Silence()
local entity = spawner.Create({Entity = {Name = "Silence",Asset = "115741296805200",HeightOffset = 1},Lights = {Flicker = {Enabled = false,Duration = 0.1},Shatter = true,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 20,Values = {1.5, 20, 0.1, 1}},Movement = {Speed = 35,Delay = 2,Reversed = false},Rebounding = {Enabled = false,Type = "Blitz",Min = 1,Max = math.random(1, 2),Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 200,Amount = 125},Crucifixion = {Enabled = true,Range = 200,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你被 Silence 吞噬了...", "你该学会不在寂静中消亡", "请仔细辨别环境中的声音", "他随时都可能出现"},Cause = ""}})
entity:SetCallback("OnRebounding", function(startOfRebound)

	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}

	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end

	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
	
end)
entity:Run()
end

function entityBehaviors.ForstBite()
function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end

local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")

function LoadCustomInstance(source, parent)
    local model

    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end

    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end

    return model
end

local s = LoadCustomInstance("91600860859120", workspace)
if not s then
    return
end

local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(0, 5, -15)
entity.Part.CFrame = entity.CFrame

pcall(function()
local room = workspace.CurrentRooms:FindFirstChild(
    tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)
)
if room then
    for _, obj in ipairs(room:GetDescendants()) do
        if obj.Name == "PlaySound" and obj:IsA("Sound") then
            obj:Stop()
            obj.Playing = false
            obj.TimePosition = 0
            obj.Looped = false
        end
    end
end
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.ToolEventPrompt.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SparkParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SmokeParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireLight.Enabled = false
end)


local pointLight = Instance.new("PointLight")
pointLight.Color = Color3.new(255, 255, 255)
pointLight.Range = 60
pointLight.Brightness = 99999
pointLight.Parent = entity

tweenservice:Create(pointLight, TweenInfo.new(3), {
    Brightness = 0
}):Play()

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://137044859218769"
sound.Looped = false
sound.Volume = 5
sound.Parent = s
sound:Play()

local frost = Instance.new("ColorCorrectionEffect")
frost.Parent = game.Lighting
tweenservice:Create(frost, TweenInfo.new(10), {
    TintColor = Color3.fromRGB(217, 250, 255),
    Saturation = -0.7,
    Contrast = 0.2
}):Play()

for _, v in ipairs({"face", "Heylois", "BlackTrai2l", "BlackTrai3l"}) do
    if entity:FindFirstChild("Attachment") and entity.Attachment:FindFirstChild(v) then
        entity.Attachment[v].Enabled = false
    end
end
wait(8)
local roomChanged = false
local roomChangedConnection
roomChangedConnection = game.ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function()
    roomChanged = true
    if roomChangedConnection then
        roomChangedConnection:Disconnect()
    end
end)
for _, v in ipairs({"face", "Heylois", "BlackTrai2l", "BlackTrai3l"}) do
    if entity:FindFirstChild("Attachment") and entity.Attachment:FindFirstChild(v) then
        entity.Attachment[v].Enabled = true
    end
end
wait(2)

if roomChanged then
    for _, v in ipairs({"face", "Heylois", "BlackTrai2l", "BlackTrai3l"}) do
        if entity:FindFirstChild("Attachment") and entity.Attachment:FindFirstChild(v) then
            entity.Attachment[v].Enabled = false
        end
    end
    
    pcall(function() entity.Ambience:Stop() end)
    pcall(function() entity.AmbienceFar:Stop() end)
    
    local des = Instance.new("Sound")
    des.SoundId = "rbxassetid://109891187801924"
    des.Looped = false
    des.Volume = 2.5
    des.Parent = s
    des:Play()
    
    wait(5)
    s:Destroy()
    
    tweenservice:Create(frost, TweenInfo.new(5), {
        TintColor = Color3.fromRGB(255, 255, 255),
        Saturation = 0,
        Contrast = 0
    }):Play()
    wait(5)
    frost:Destroy()
    return
end
pcall(function() entity.Ambience:Play() end)
pcall(function() entity.AmbienceFar:Play() end)

local dmg = true
task.spawn(function()
    while dmg and not roomChanged do
        wait(1)
        local lighter = chr:FindFirstChild("Lighter")
        local safe = false
        if lighter then
            local handle = lighter:FindFirstChild("Handle")
            if handle then
                local holder = handle:FindFirstChild("EffectsHolder")
                if holder then
                    local attach = holder:FindFirstChild("AttachOn")
                    if attach then
                        local main = attach:FindFirstChild("MainLight")
                        if main and main:IsA("PointLight") then
                            safe = main.Enabled
                        end
                    end
                end
            end
        end
        if not safe and not roomChanged then
            pcall(function()
                chr.Humanoid.Health -= 5
                game.ReplicatedStorage.GameStats["Player_" .. plr.Name].Total.DeathCause.Value = "Frostbite"
                
                firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
                        "It's a bit cold here, isn't it?",
                        "You froze to death by something.",
                        "Maybe you need some cold prevention measures. I heard that humans are very sensitive to the cold..",
                        "Try using your lighter to keep warm.",
                        "This may be a bit tricky and noisy.",
                        "You should try again.",
                        "By the way, the name of the thing that killed you is Frostbite."
                    }, "Yellow")
            end)
        end
    end
    dmg = false
end)

game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait()

dmg = false
roomChanged = true

if roomChangedConnection then
    roomChangedConnection:Disconnect()
end

for _, v in ipairs({"face", "Heylois", "BlackTrai2l", "BlackTrai3l"}) do
    if entity:FindFirstChild("Attachment") and entity.Attachment:FindFirstChild(v) then
        entity.Attachment[v].Enabled = false
    end
end

pcall(function() entity.Ambience:Stop() end)
pcall(function() entity.AmbienceFar:Stop() end)

local des = Instance.new("Sound")
des.SoundId = "rbxassetid://111715441853991"
des.Looped = false
des.Volume = 2.5
des.Parent = s
des:Play()

wait(5)
s:Destroy()

tweenservice:Create(frost, TweenInfo.new(5), {
    TintColor = Color3.fromRGB(255, 255, 255),
    Saturation = 0,
    Contrast = 0
}):Play()
wait(5)
frost:Destroy()
end
function entityBehaviors.INGODONE()
local entity = spawner.Create({Entity = {Name = "@&%^#*$Indescribable God!@$*&^!Q(* ",Asset = "115187708721417",HeightOffset = 1},Lights = {Flicker = {Enabled = false,Duration = 50},Shatter = true,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 1500,Values = {0.5, 20, 0.1, 1}},Movement = {Speed = 20,Delay = 2,Reversed = false},Rebounding = {Enabled = true,Type = "Ambush",Min = 3,Max = 5,Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 40,Amount = 200},Crucifixion = {Enabled = true,Range = 40,Resist = true,Break = true},Death = {Type = "Curious",Hints = {"It seems you are so unfortunate...", "You died by the ??? God", "That powerful force will drag you into the abyss.","The cross cannot guarantee your safety.","See you next time."},Cause = ""},})
entity:SetCallback("OnRebounding", function(startOfRebound)
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}
	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end
	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
	
end)
entity:Run()
end

function entityBehaviors.Subspace()
local sound = Instance.new("Sound")
sound.Name = "Subspace"
sound.SoundId = "rbxassetid://108345344203629"
sound.Volume = 4
sound.Parent = workspace

sound.Ended:Connect(function()
    sound:Destroy()
end)

sound:Play()
wait(5)
    local sound = Instance.new("Sound")
sound.Name = "Subspace"
sound.SoundId = "rbxassetid://134461834055887"
sound.Volume = 4
sound.Parent = workspace

sound.Ended:Connect(function()
    sound:Destroy()
end)

sound:Play()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SHAKE_INTENSITY = 20
local SHAKE_DURATION = 7
local SHAKE_SPEED = 70
local player = Players.LocalPlayer
if not player then return end
local camera = workspace.CurrentCamera
local startTime = tick()
local originalPosition = camera.CFrame.Position
local connection
connection = RunService.RenderStepped:Connect(function()
    local elapsed = tick() - startTime
    if elapsed < SHAKE_DURATION then
        local decay = 1 - (elapsed / SHAKE_DURATION)
        local intensity = SHAKE_INTENSITY * decay
        local time = elapsed * SHAKE_SPEED
        local offset = Vector3.new(
            math.sin(time * 1.1) * intensity * 0.5 + math.random(-intensity, intensity) * 0.3,
            math.cos(time * 0.9) * intensity * 0.5 + math.random(-intensity, intensity) * 0.3,
            math.sin(time * 1.0) * intensity * 0.3
        )
        local lookVector = camera.CFrame.LookVector
        local upVector = camera.CFrame.UpVector
        local rightVector = camera.CFrame.RightVector
        local currentPos = camera.CFrame.Position
        local newPos = currentPos + offset
        camera.CFrame = CFrame.new(newPos, newPos + lookVector) * CFrame.Angles(0, 0, 0)
        
    else

        if connection then
            connection:Disconnect()
        end
    end
end)
local Workspace = game:GetService("Workspace")
local function RandomUnanchor(count)
    count = count or 1800
    local parts = {}
      for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Anchored and not string.find(part.Name:lower(), "floor") then
            table.insert(parts, part)
        end
    end
    if #parts == 0 then
        return
    end
    local targetCount = math.min(count, #parts)
    local indices = {}

    for i = 1, #parts do
        indices[i] = i
    end
    for i = #indices, 2, -1 do
        local j = math.random(1, i)
        indices[i], indices[j] = indices[j], indices[i]
    end
    local unanchored = 0
    for i = 1, targetCount do
        local part = parts[indices[i]]
        if part and part.Anchored then
            part.Anchored = false
            unanchored = unanchored + 1

            if i % 100 == 0 then
            
            end
        end
    end
    return unanchored
end
RandomUnanchor(1800)
end

function entityBehaviors.INGODTWO()
 local entity = spawner.Create({
        Entity = {Name = "@&%^#*$Indescribable God!@$*&^!Q(*", Asset = "85650922684960", HeightOffset = -0.8},
        Lights = {Flicker = {Enabled = true, Duration = 50}, Shatter = true, Repair = true},
        Earthquake = {Enabled = false},
        CameraShake = {Enabled = true, Range = 1500, Values = {0.5, 20, 0.1, 1}},
        Movement = {Speed = 15, Delay = 2, Reversed = false},
        Rebounding = {Enabled = false, Type = "Blitz", Min = 1, Max = math.random(1, 2), Delay = math.random(10, 30) / 10},
        Damage = {Enabled = true, Range = 40, Amount = 200},
        Crucifixion = {Enabled = true, Range = 40, Resist = true, Break = true},
        Death = {
            Type = "Curious", 
            Hints = {
                "看来你遭遇了糟糕的事情。", 
                "你死于 %@&*$^%@&*!^$%(*&!^@$((!@&*$%", 
                "或许有时旁观并不会带给你友好的收益。", 
                "急速奔跑是你本能的求生欲。", 
                "下次见。"}, Cause = ""}})
    entity:SetCallback("OnRebounding", function(startOfRebound)
        local entityModel = entity.Model
        local main = entityModel:WaitForChild("Main")
        local attachment = main:WaitForChild("Attachment")
        local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
        local sounds = {
            footsteps = main:WaitForChild("Footsteps"),
            playSound = main:WaitForChild("PlaySound"),
            switch = main:WaitForChild("Switch"),
            switchBack = main:WaitForChild("SwitchBack")
        }
        
        for _, c in attachment:GetChildren() do
            c.Enabled = (not startOfRebound)
        end
        
        for _, c in AttachmentSwitch:GetChildren() do
            c.Enabled = startOfRebound
        end
        
        if startOfRebound == true then
            sounds.footsteps.PlaybackSpeed = 0.35
            sounds.playSound.PlaybackSpeed = 0.25
            sounds.switch:Play()
        else
            sounds.footsteps.PlaybackSpeed = 0.25
            sounds.playSound.PlaybackSpeed = 0.16
            sounds.switchBack:Play()
        end
    end)
    entity:Run()
end

function entityBehaviors.DELALL()
 local Event = game:GetService("ReplicatedStorage").RemotesFolder.AdminPanelRunCommand
Event:FireServer(
    "DELETE ALL",
    {}
)
    local function deleteDirectChildModels()
    local workspace = game:GetService("Workspace")
    local modelNames = {
        "A-200", "A60", "Amin-60", "Black-A60", "Deer god", "DeerGod",
        "Frostbite", "@&%^#*$Indescribable God!@$*&^!Q(* ", "LightSpeed",
        "Rebound", "Ripper", "Following_ENEMY", "Silence","Dread","Muffler","Common Sence","Fluster","Kitty","Broken eyes","Angry Munci","Shadow","LEVEL0","Him","Hunger","WH1T3","Obsession","HimMoving","smiler", "Chainsmoker"
    }
    for _, name in ipairs(modelNames) do
        local model = workspace:FindFirstChild(name)
        if model and model:IsA("Model") then
            model:Destroy()
        end
    end
end
deleteDirectChildModels()
end

function entityBehaviors.Smiler()
local entity = spawner.Create({Entity = {Name = "smiler",Asset = "108450814500304",HeightOffset = 0},Lights = {Flicker = {Enabled = true,Duration = 10},Shatter = false,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 200,Values = {1.5, 20, 0.1, 1}},Movement = {Speed = 450,Delay = 11,Reversed = false},Rebounding = {Enabled = true,Type = "ambush",Min = 8,Max = 8,Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 200,Amount = 125},Crucifixion = {Enabled = true,Range = 200,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你死于Smiler", "或许你需要在Ambush那学会点东西", "在闪灯数秒后他会出现", "加油,我相信你可以做到"},Cause = ""}})
entity:SetCallback("OnRebounding", function(startOfRebound)
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}

	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end

	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
	
end)
entity:Run()
end
function entityBehaviors.WhoopDaShoop()
local RunService = game:GetService("RunService")
local modelId = 86112457302745
local loadedModel
local success, result = pcall(function()
    return game:GetObjects("rbxassetid://" .. modelId)[1]
end)
if success and result and result:IsA("Model") then
    loadedModel = result
    loadedModel.Parent = workspace
else
    return
end

if not loadedModel.PrimaryPart then
    local rootPart = loadedModel:FindFirstChild("HumanoidRootPart") or loadedModel:FindFirstChildWhichIsA("BasePart")
    if rootPart then
        loadedModel.PrimaryPart = rootPart
    else
        return
    end
end

local function findGroundskeeper()
    local currentRooms = workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return nil end

    for _, room in ipairs(currentRooms:GetChildren()) do
        if room:IsA("Model") then
            local target = room:FindFirstChild("Groundskeeper", true)
            if target and target:IsA("Model") then
                return target
            end
        end
    end
    return nil
end

local targetModel = findGroundskeeper()
if not targetModel then
    return
end

if not targetModel.PrimaryPart then
    local rootPart = targetModel:FindFirstChild("HumanoidRootPart") or targetModel:FindFirstChildWhichIsA("BasePart")
    if rootPart then
        targetModel.PrimaryPart = rootPart
    else
        return
    end
end

local function processHideModel(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
            descendant.Transparency = 1
            if descendant:IsA("MeshPart") then
                descendant.RenderFidelity = Enum.RenderFidelity.Performance
            end
        end
        if descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant.Transparency = 1
        end
        if descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
            descendant.Enabled = false
        end
        if descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
            descendant:Destroy()
        end
        if descendant:IsA("ParticleEmitter") then
            descendant.Enabled = false
        end
        if descendant:IsA("Fire") or descendant:IsA("Smoke") then
            descendant.Enabled = false
        end
    end
end

local function hideGroundskeeper()
    local foundAny = false
    local function searchAndHide(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name == "Groundskeeper" and child:IsA("Model") then
                processHideModel(child)
                foundAny = true
            end
            searchAndHide(child)
        end
    end
    searchAndHide(workspace)
    return foundAny
end

hideGroundskeeper()

local function setupHideMonitor()
    local connections = {}
    local function monitorChildAdded(parent)
        local connection = parent.ChildAdded:Connect(function(child)
            if child.Name == "Groundskeeper" and child:IsA("Model") then
                task.wait(0.1)
                processHideModel(child)
            end
            monitorChildAdded(child)
        end)
        table.insert(connections, connection)
    end
    monitorChildAdded(workspace)
    return function()
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
    end
end

local hideMonitor = setupHideMonitor()

local function processDeleteSounds(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("Sound") then
            descendant:Destroy()
        end
    end
end

local function deleteGroundskeeperSounds()
    local foundAny = false
    local function searchAndDelete(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name == "Groundskeeper" and child:IsA("Model") then
                processDeleteSounds(child)
            end
            searchAndDelete(child)
        end
    end
    searchAndDelete(workspace)
    return foundAny
end

deleteGroundskeeperSounds()

local function setupSoundDeletionMonitor()
    local connections = {}
    local function processNewSound(sound)
        if not sound:IsA("Sound") then return end
        local current = sound
        while current and current ~= game do
            if current.Name == "Groundskeeper" and current:IsA("Model") then
                sound:Destroy()
                break
            end
            current = current.Parent
        end
    end
    local function monitorDescendantAdded(parent)
        local connection = parent.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Sound") then
                processNewSound(descendant)
            end
        end)
        table.insert(connections, connection)
    end
    monitorDescendantAdded(workspace)
    local groundskeeperConnection
    groundskeeperConnection = workspace.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "Groundskeeper" and descendant:IsA("Model") then
            task.wait(0.1)
            processDeleteSounds(descendant)
        end
    end)
    table.insert(connections, groundskeeperConnection)
    return function()
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
    end
end

local soundMonitor = setupSoundDeletionMonitor()

local followConnection
followConnection = RunService.Heartbeat:Connect(function()
    if not targetModel or not targetModel.PrimaryPart or not loadedModel or not loadedModel.PrimaryPart or not targetModel.PrimaryPart.Parent or not loadedModel.Parent then
        if followConnection then
            followConnection:Disconnect()
        end
        return
    end
    local targetCFrame = targetModel.PrimaryPart.CFrame
    loadedModel:PivotTo(targetCFrame)
end)

return function()
    if followConnection then
        followConnection:Disconnect()
    end
    if hideMonitor then
        hideMonitor()
    end
    if soundMonitor then
        soundMonitor()
    end
    if loadedModel and loadedModel.Parent then
        loadedModel:Destroy()
    end
end
end

function entityBehaviors.WhoopDaShoopTwo()
 local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://138148333"
sound.Name = "WHOOP"
sound.Parent = workspace
sound:Play()

local targetModel = workspace:FindFirstChild("Following_ENEMY")
if not targetModel then return end

if not targetModel.PrimaryPart then
    local rootPart = targetModel:FindFirstChild("HumanoidRootPart") or targetModel:FindFirstChildWhichIsA("BasePart")
    if rootPart then targetModel.PrimaryPart = rootPart else return end
end

local currentRooms = Workspace:FindFirstChild("CurrentRooms")
local groundskeeperModel
if currentRooms then
    for _, room in ipairs(currentRooms:GetChildren()) do
        if room:IsA("Folder") or room:IsA("Model") then
            local groundskeeper = room:FindFirstChild("Groundskeeper")
            if groundskeeper and groundskeeper:IsA("Model") then
                groundskeeperModel = groundskeeper
                break
            end
        end
    end
end
if not groundskeeperModel then return end

if not groundskeeperModel.PrimaryPart then
    local rootPart = groundskeeperModel:FindFirstChild("HumanoidRootPart") or groundskeeperModel:FindFirstChildWhichIsA("BasePart")
    if rootPart then groundskeeperModel.PrimaryPart = rootPart else return end
end

task.wait(1.8)

local laser1Id = 75823189898619
local laser1Model
local laser1Success, laser1Result = pcall(function()
    return game:GetObjects("rbxassetid://" .. laser1Id)[1]
end)
if laser1Success and laser1Result and laser1Result:IsA("Model") then
    laser1Model = laser1Result
    laser1Model.Name = "Laser1"
    laser1Model.Parent = workspace
    if not laser1Model.PrimaryPart then
        local rootPart = laser1Model:FindFirstChild("HumanoidRootPart") or laser1Model:FindFirstChildWhichIsA("BasePart")
        if rootPart then laser1Model.PrimaryPart = rootPart end
    end
else
    return
end

local function hideModel(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
            descendant.Transparency = 1
        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant.Transparency = 1
        elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
            descendant.Enabled = false
        end
    end
end

local function restoreModelExceptRootPart(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant.Name ~= "HumanoidRootPart" then
            if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
                descendant.Transparency = 0
            elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                descendant.Transparency = 0
            elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
                descendant.Enabled = true
            end
        end
    end
end

local laser1FollowConnection
if groundskeeperModel and groundskeeperModel.PrimaryPart and laser1Model and laser1Model.PrimaryPart then
    laser1Model:PivotTo(groundskeeperModel.PrimaryPart.CFrame)
    hideModel(targetModel)
    laser1FollowConnection = RunService.Heartbeat:Connect(function()
        if not groundskeeperModel or not groundskeeperModel.PrimaryPart or not laser1Model or not laser1Model.PrimaryPart or 
           not groundskeeperModel.PrimaryPart.Parent or not laser1Model.Parent then
            if laser1FollowConnection then laser1FollowConnection:Disconnect() end
            return
        end
        laser1Model:PivotTo(groundskeeperModel.PrimaryPart.CFrame)
    end)
else
    return
end

task.wait(1.3)

local laser2Id = 74088823220607
local laser2Model
local laser2Success, laser2Result = pcall(function()
    return game:GetObjects("rbxassetid://" .. laser2Id)[1]
end)
if laser2Success and laser2Result and laser2Result:IsA("Model") then
    laser2Model = laser2Result
    laser2Model.Name = "Laser2"
    laser2Model.Parent = workspace
    if not laser2Model.PrimaryPart then
        local rootPart = laser2Model:FindFirstChild("HumanoidRootPart") or laser2Model:FindFirstChildWhichIsA("BasePart")
        if rootPart then laser2Model.PrimaryPart = rootPart end
    end
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local SHAKE_INTENSITY = 2
    local SHAKE_DURATION = 10
    local SHAKE_SPEED = 70
    local player = Players.LocalPlayer
    if not player then return end
    local camera = workspace.CurrentCamera
    local startTime = tick()
    local originalPosition = camera.CFrame.Position
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        if elapsed < SHAKE_DURATION then
            local decay = 1 - (elapsed / SHAKE_DURATION)
            local intensity = SHAKE_INTENSITY * decay
            local time = elapsed * SHAKE_SPEED
            local offset = Vector3.new(
                math.sin(time * 1.1) * intensity * 0.5 + math.random(-intensity, intensity) * 0.3,
                math.cos(time * 0.9) * intensity * 0.5 + math.random(-intensity, intensity) * 0.3,
                math.sin(time * 1.0) * intensity * 0.3
            )
            local lookVector = camera.CFrame.LookVector
            local upVector = camera.CFrame.UpVector
            local rightVector = camera.CFrame.RightVector
            local currentPos = camera.CFrame.Position
            local newPos = currentPos + offset
            camera.CFrame = CFrame.new(newPos, newPos + lookVector) * CFrame.Angles(0, 0, 0)
        else
            if connection then connection:Disconnect() end
        end
    end)
else
    return
end

local laser2FollowConnection
if groundskeeperModel and groundskeeperModel.PrimaryPart and laser2Model and laser2Model.PrimaryPart then
    laser2Model:PivotTo(groundskeeperModel.PrimaryPart.CFrame)
    hideModel(laser1Model)
    laser2FollowConnection = RunService.Heartbeat:Connect(function()
        if not groundskeeperModel or not groundskeeperModel.PrimaryPart or not laser2Model or not laser2Model.PrimaryPart or 
           not groundskeeperModel.PrimaryPart.Parent or not laser2Model.Parent then
            if laser2FollowConnection then laser2FollowConnection:Disconnect() end
            return
        end
        laser2Model:PivotTo(groundskeeperModel.PrimaryPart.CFrame)
    end)
else
    return
end

local soundFinished = false
local soundConnection
soundConnection = sound.Ended:Connect(function()
    soundFinished = true
    if soundConnection then soundConnection:Disconnect() end
end)
while not soundFinished do task.wait(0.1) end
if targetModel then restoreModelExceptRootPart(targetModel) end
if laser1FollowConnection then laser1FollowConnection:Disconnect() end
if laser2FollowConnection then laser2FollowConnection:Disconnect() end
if laser1Model and laser1Model.Parent then laser1Model:Destroy() end
if laser2Model and laser2Model.Parent then laser2Model:Destroy() end
if sound and sound.Parent then sound:Destroy() end
end

function entityBehaviors.ChainSmoker()
local entity = spawner.Create({Entity = {Name = "Chainsmoker",Asset = "91743718986054",HeightOffset = 1},Lights = {Flicker = {Enabled = true,Duration = 1},Shatter = true,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 10,Values = {1.5, 20, 0.1, 1}},Movement = {Speed = 30,Delay = 1,Reversed = false},Rebounding = {Enabled = false,Type = "ambush",Min = 4,Max = 4,Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 5,Amount = 125},Crucifixion = {Enabled = true,Range = 20,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你死于Chainsmoker", "......", "或许我不能告诉你他的信息", "总而言之，当心闪灯"},Cause = ""}})
entity:SetCallback("OnRebounding", function(startOfRebound)
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}
	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end
	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end

end)
entity:Run()
end

function entityBehaviors.DeergodDDH()
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FadeTextGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local textLabel = Instance.new("TextLabel")
textLabel.Name = "FadeText"
textLabel.Size = UDim2.new(0, 520, 0, 58)
textLabel.Position = UDim2.new(0.5, 0, 1, -180)
textLabel.AnchorPoint = Vector2.new(0.5, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextSize = 38
textLabel.TextTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(179, 0, 255)
textLabel.FontFace = Font.new("rbxassetid://12187367901")
textLabel.Parent = screenGui

local phrases = {
	"Kid, why are you running away?",
	"It's all just an illusion.",
	"Stop walking and feel everything",
	"Your soul will nourish my child",
	"Do you feel guilty when you're looking at this conversation through the screen?",
	"You're just virtual",
	"I can hear all your voices"
}

local function playPhrase(text)
	textLabel.Text = text
	textLabel.TextTransparency = 1

	local fadeIn = TweenService:Create(
		textLabel,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	)
	local fadeOut = TweenService:Create(
		textLabel,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{TextTransparency = 1}
	)

	fadeIn:Play()
	fadeIn.Completed:Wait()
	task.wait(2)
	fadeOut:Play()
	fadeOut.Completed:Wait()
end

local startTime = tick()
while tick() - startTime < 29 do
	local randomIndex = math.random(1, #phrases)
	playPhrase(phrases[randomIndex])

	if tick() - startTime >= 24 then break end
	task.wait(5)
end
end

function GitAud(soundgit, filename)
    local url = soundgit
    local fileName = filename or "temp_audio"
    local fullFileName = fileName .. ".mp3"
    local success, audioData = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        return nil
    end
    local writeSuccess, writeError = pcall(function()
        writefile(fullFileName, audioData)
    end)
    if not writeSuccess then
        return nil
    end
    local assetPath
    if getsynasset then
        assetPath = getsynasset(fullFileName)
    elseif getcustomasset then
        assetPath = getcustomasset(fullFileName)
    else
        return nil
    end
    return assetPath
end

local deerGodMusicUrl = "https://github.com/Zero0Star/RipperNewSound/blob/master/NoRunning.mp3?raw=true"
local cachedAudioAsset = GitAud(deerGodMusicUrl, "DeerGodMusic")
function entityBehaviors.Deergod()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local entityModel
    local chaseConnection = nil
    local customSpeed = 20
    local activationRange = 75
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local ids = {"rbxassetid://8116159092","rbxassetid://435812828","rbxassetid://860440643"}

local gui = Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
gui.Name = "SnowGlitchEnhanced"
gui.IgnoreGuiInset = true

local mainImg = Instance.new("ImageLabel",gui)
mainImg.Size = UDim2.new(1,0,1,0)
mainImg.BackgroundTransparency = 1
mainImg.ImageTransparency = 0.88
mainImg.Image = ids[math.random(#ids)]
mainImg.ScaleType = Enum.ScaleType.Tile
mainImg.TileSize = UDim2.new(0,64,0,64)

local flashFrame = Instance.new("Frame",gui)
flashFrame.Size = UDim2.new(1,0,1,0)
flashFrame.BackgroundColor3 = Color3.new(1,1,1)
flashFrame.BackgroundTransparency = 1
flashFrame.BorderSizePixel = 0

local start = tick()
local lastFlash = tick()
local flashInterval = 0.15
local flashDuration = 0.05

local conn = RunService.RenderStepped:Connect(function()
    local elapsed = tick() - start
    if elapsed >= 60 then
        conn:Disconnect()
        gui:Destroy()
        return
    end
    
    mainImg.Image = ids[math.random(#ids)]
    mainImg.ImageTransparency = 0.78 + math.random()*0.18
    local sz = 48 + math.random(0,32)
    mainImg.TileSize = UDim2.new(0,sz,0,sz)
    local r = math.random(80,120)/100
    local g = math.random(70,110)/100
    local b = math.random(90,130)/100
    mainImg.ImageColor3 = Color3.new(r,g,b)
    
    if tick() - lastFlash >= flashInterval then
        flashFrame.BackgroundTransparency = 0.65 + math.random()*0.25
        lastFlash = tick()
    else
        flashFrame.BackgroundTransparency = 1
    end
    
    if math.random() < 0.03 then
        local x = math.random(0,800)
        local y = math.random(0,600)
        local w = math.random(20,80)
        local h = math.random(10,40)
        local highlight = Instance.new("Frame",gui)
        highlight.Size = UDim2.new(0,w,0,h)
        highlight.Position = UDim2.new(0,x,0,y)
        highlight.BackgroundColor3 = Color3.new(1,1,1)
        highlight.BackgroundTransparency = 0.5 + math.random()*0.3
        highlight.BorderSizePixel = 0
        game:GetService("Debris"):AddItem(highlight,0.06)
    end
end)
    local entity = spawner.Create({
        Entity = {
            Name = "Deer god",
            Asset = "92755817727288",
            HeightOffset = -0.8
        },
        Lights = {
            Flicker = { Enabled = true, Duration = 50 },
            Shatter = true,
            Repair = false
        },
        Earthquake = { Enabled = false },
        CameraShake = {
            Enabled = true,
            Range = 1500,
            Values = {0.5, 5, 0.1, 1}
        },
        Movement = {
            Speed = 20,
            Delay = 2,
            Reversed = false
        },
        Rebounding = {
            Enabled = false,
            Type = "Blitz",
            Min = 1,
            Max = math.random(1, 2),
            Delay = math.random(10, 30) / 10
        },
        Damage = {
            Enabled = true,
            Range = 10,
            Amount = 200
        },
        Crucifixion = {
            Enabled = true,
            Range = 40,
            Resist = true,
            Break = true
        },
        Death = {
            Type = "Curious",
            Hints = {
                "看起来你真倒霉...", 
                "你被所谓的鹿神击杀了", 
                "那股强大的力量会把你拉入深渊",
                "十字架不能保证你的安全",
                "下次见"
            },
            Cause = ""
        }
    })

    local function startChaseSystem()
        if not entityModel or not entityModel.PrimaryPart then
            return
        end

        if chaseConnection then
            chaseConnection:Disconnect()
            chaseConnection = nil
        end

        chaseConnection = RunService.Heartbeat:Connect(function(dt)
            if not entityModel 
                or not entityModel.PrimaryPart 
            then 
                return 
            end

            local nearestPlayer = nil
            local nearestDist = math.huge
            local entityPos = entityModel.PrimaryPart.Position

            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    local humanoid = char.Humanoid
                    if humanoid.Health > 0 then
                        local targetRoot = char.HumanoidRootPart
                        local dist = (targetRoot.Position - entityPos).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestPlayer = player
                        end
                    end
                end
            end

            if not nearestPlayer then return end

            local targetChar = nearestPlayer.Character
            if not targetChar then return end

            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then return end

            local pos = entityModel.PrimaryPart.Position
            local target = targetRoot.Position
            local distance = (target - pos).Magnitude

            if distance <= activationRange then
                local dir = (target - pos).Unit
                local moveVec = dir * customSpeed * dt
                local newCFrame = CFrame.new(pos + moveVec, target)
                entityModel:SetPrimaryPartCFrame(newCFrame)
            end
        end)
    end

    entity:SetCallback("OnSpawned", function()
        entityModel = entity.Model
        if entityModel then
            if not entityModel.PrimaryPart then
                local primaryPart = entityModel:FindFirstChild("Main") or entityModel:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    entityModel.PrimaryPart = primaryPart
                end
            end
        end
        startChaseSystem()
    end)

    entity:SetCallback("OnDespawning", function()
        if chaseConnection then
            chaseConnection:Disconnect()
            chaseConnection = nil
        end
    end)

    entity:SetCallback("OnDamagePlayer", function(newHealth)
        if newHealth == 0 then
            if chaseConnection then
                chaseConnection:Disconnect()
                chaseConnection = nil
            end
            if entityModel and entityModel.PrimaryPart then
                local currentPos = entityModel.PrimaryPart.Position
                local forwardDir = entityModel.PrimaryPart.CFrame.LookVector
                local targetPos = currentPos + forwardDir * 10
                entityModel:SetPrimaryPartCFrame(CFrame.new(currentPos, targetPos))
            end
        end
    end)

    entity:SetCallback("OnRebounding", function(startOfRebound)
        if not entityModel then return end
        
        local main = entityModel:FindFirstChild("Main")
        if not main then return end
        
        local attachment = main:WaitForChild("Attachment")
        local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
        local sounds = {
            footsteps = main:WaitForChild("Footsteps"),
            playSound = main:WaitForChild("PlaySound"),
            switch = main:WaitForChild("Switch"),
            switchBack = main:WaitForChild("SwitchBack")
        }

        for _, c in attachment:GetChildren() do
            c.Enabled = (not startOfRebound)
        end
        for _, c in AttachmentSwitch:GetChildren() do
            c.Enabled = startOfRebound
        end

        if startOfRebound == true then
            sounds.footsteps.PlaybackSpeed = 0.35
            sounds.playSound.PlaybackSpeed = 0.25
            sounds.switch:Play()
        else
            sounds.footsteps.PlaybackSpeed = 0.25
            sounds.playSound.PlaybackSpeed = 0.16
            sounds.switchBack:Play()
        end
    end)

    entity:Run()

    if cachedAudioAsset then
        local musicInstance = Instance.new("Sound")
        musicInstance.SoundId = cachedAudioAsset
        musicInstance.Volume = 4
        musicInstance.Name = "DeerGodMusic_" .. tick()
        musicInstance.Parent = workspace
        musicInstance:Play()

        musicInstance.Ended:Connect(function()
            musicInstance:Destroy()
        end)
    end
end

function entityBehaviors.LightSpeed()
local entity = spawner.Create({Entity = {Name = "LightSpeed",Asset = "87015961601567",HeightOffset = 1},Lights = {Flicker = {Enabled = false,Duration = 0.1},Shatter = false,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 20,Values = {90, 50, 20, 20}},Movement = {Speed = 1400,Delay = 20,Reversed = false},Rebounding = {Enabled = false,Type = "Blitz",Min = 1,Max = math.random(1, 2),Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 50,Amount = 40},Crucifixion = {Enabled = true,Range = 50,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你死于光速", "在他来临时保证自己以最快的速度作出反应", "伴随着灯光变黄与巨大的雷电轰鸣声", "或许并不致命但总是一个威胁"},Cause = ""}})
entity:SetCallback("OnRebounding", function(startOfRebound)
	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}
	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end
	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
	
end)
entity:Run()
end

function entityBehaviors.A200Jump()
 function GitAud(soundgit, filename)
    local url = soundgit
    local FileName = filename
    writefile(FileName .. ".mp3", game:HttpGet(url))
    return (getcustomasset or getsynasset)(FileName .. ".mp3")
end

function CustomGitSound(soundlink, vol, filename)
    local sound = Instance.new("Sound")
    sound.SoundId = GitAud(soundlink, filename)
    sound.Parent = workspace
    sound.Name = filename or "Music"
    sound.Volume = vol or 1
    sound:Play()
    return sound
end

function ExecuteJumpScare()

    local targetAudioUrl = "https://raw.githubusercontent.com/Zero0Star/RipperMPSound/master/A120Jump.mp3"
    local volume = 4
    local localFileName = "JumpScareSound"
    
    local jumpSound = CustomGitSound(targetAudioUrl, volume, localFileName)

    task.wait(0.1)
    
    local images = {113886624548165, 16907654704, 91100683423814}
    local container = Instance.new("Folder", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    local redGui = Instance.new("ScreenGui", container)
    redGui.Name = "RedLayer"
    redGui.ResetOnSpawn = false
    redGui.IgnoreGuiInset = true
    redGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    redGui.DisplayOrder = 0
    local redOverlay = Instance.new("Frame", redGui)
    redOverlay.Name = "RedBg"
    redOverlay.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    redOverlay.BackgroundTransparency = 1
    redOverlay.Size = UDim2.new(1, 0, 1, 0)
    redOverlay.Position = UDim2.new(0, 0, 0, 0)
    redOverlay.BorderSizePixel = 0

    local imageGui = Instance.new("ScreenGui", container)
    imageGui.Name = "ImageLayer"
    imageGui.ResetOnSpawn = false
    imageGui.IgnoreGuiInset = true
    imageGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    imageGui.DisplayOrder = 1 
    local img = Instance.new("ImageLabel", imageGui)
    img.AnchorPoint = Vector2.new(0.5, 0.5)
    img.Size = UDim2.new(0, 100, 0, 100)
    img.Position = UDim2.new(0.5, 0, 0.5, 0)
    img.BackgroundTransparency = 1
    img.ImageTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.ZIndex = 10
    local ts = game:GetService("TweenService")
    replicatesignal(game.Players.LocalPlayer.Kill)
    ts:Create(redOverlay, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()

img.Image = "rbxassetid://" .. images[1]
ts:Create(img, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
ts:Create(img, TweenInfo.new(0.3), {Size = UDim2.new(0, 300, 0, 300)}):Play()
task.wait(0.08)

img.Image = "rbxassetid://" .. images[2]
ts:Create(img, TweenInfo.new(0.3), {Size = UDim2.new(0, 700, 0, 700)}):Play()
task.wait(0.08)
ts:Create(redOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
img.Image = "rbxassetid://" .. images[3]
ts:Create(img, TweenInfo.new(0.8), {Size = UDim2.new(0, 1500, 0, 1500)}):Play()
task.wait(0.5)
ts:Create(redOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.05}):Play()
task.wait(0.8 + 0.5)
ts:Create(img, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
ts:Create(redOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
task.wait(0.5)
ts:Create(redOverlay, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
task.wait(0.8)
    container:Destroy()
    if jumpSound and jumpSound.Playing then
        jumpSound.Ended:Wait()
        task.wait(1)
        jumpSound:Destroy()
    end
end
ExecuteJumpScare()
end

function entityBehaviors.EndRooms()
require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("End Room Task",true)
end

function entityBehaviors.Blast()
require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("这把枪支看起来生锈..我小心使用..",true)
end

function entityBehaviors.Cease()
local Event = game:GetService("ReplicatedStorage").RemotesFolder.AdminPanelRunCommand
Event:FireServer(
    "LightRoom",
    {
        ["Light Color"] = Color3.new(0, 0.098297834396362, 1)
    }
)
local entity = spawner.Create({Entity = {Name = "Cease",Asset = "74118615017772",HeightOffset = 1},Lights = {Flicker = {Enabled = false,Duration = 10},Shatter = false,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 200,Values = {1.5, 20, 0.1, 1}},Movement = {Speed = 100,Delay = 5,Reversed = false},Rebounding = {Enabled = false,Type = "ambush",Min = 4,Max = 4,Delay = math.random(10, 30) / 10},Damage = {Enabled = false,Range = 100,Amount = 125},Crucifixion = {Enabled = true,Range = 100,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"CEASE", "你该学会辨别", "听取周围的声音", "反复进柜子躲避它"},Cause = ""}})
entity:SetCallback("OnRebounding", function(startOfRebound)

	local entityModel = entity.Model
	local main = entityModel:WaitForChild("Main")
	local attachment = main:WaitForChild("Attachment")
	local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}

	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end

	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
	
end)
entity:Run()
wait(7)
local Event = game:GetService("ReplicatedStorage").RemotesFolder.AdminPanelRunCommand
Event:FireServer(
    "LightRoom",
    {
        ["Light Color"] = Color3.new(0, 0, 0)
    }
)
end

function entityBehaviors.SHADOWSW()
function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end

local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")

function LoadCustomInstance(source, parent)
    local model

    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end

    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end

    return model
end

local s = LoadCustomInstance(76157710463326, workspace)  -- 可以直接使用数字ID
if not s then
    return
end

local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(0, 5, -15)
entity.Part.CFrame = entity.CFrame

pcall(function()
local room = workspace.CurrentRooms:FindFirstChild(
    tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)
)
if room then
    for _, obj in ipairs(room:GetDescendants()) do
        if obj.Name == "PlaySound" and obj:IsA("Sound") then
            obj:Stop()
            obj.Playing = false
            obj.TimePosition = 0
            obj.Looped = false
        end
    end
end
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.ToolEventPrompt.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SparkParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SmokeParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireLight.Enabled = false
end)
end

function entityBehaviors.DeerGodJump()
local Event = game:GetService("ReplicatedStorage").RemotesFolder.AdminPanelRunCommand
Event:FireServer(
    "Break Lights",
    {
        ["Lights Affected"] = 100,
        ["Affect All Rooms"] = true
    }
)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

function LoadCustomInstance(source, parent)
    local model
    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end

    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    warn("Executor không hỗ trợ file APIs.")
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end
    return model
end

local function createJumpScareAtPlayer()
    local jumpModel = LoadCustomInstance(78610714185582, workspace)
    if not jumpModel then
        return
    end
    
    jumpModel.Name = "DGJF"
    
    local primaryPart
    if jumpModel:IsA("Model") then
        primaryPart = jumpModel.PrimaryPart or jumpModel:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            jumpModel.PrimaryPart = primaryPart
        end
    else
        primaryPart = jumpModel
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart and primaryPart then
        local angle = math.random() * 2 * math.pi
        local distance = math.random(5, 15)
        local offset = Vector3.new(
            math.cos(angle) * distance,
            -0.8,
            math.sin(angle) * distance
        )
        
        local spawnPosition = rootPart.Position + offset
        
        if jumpModel:IsA("Model") and jumpModel.PrimaryPart then
            jumpModel:SetPrimaryPartCFrame(CFrame.new(spawnPosition))
        else
            jumpModel.CFrame = CFrame.new(spawnPosition)
        end
        
        local camera = workspace.CurrentCamera
        local originalCameraType = camera.CameraType
        local originalSubject = camera.CameraSubject
        
        camera.CameraType = Enum.CameraType.Scriptable
        
        local lookAtPos = primaryPart.Position
        local cameraPos = lookAtPos + Vector3.new(0, 3, -7)
        camera.CFrame = CFrame.lookAt(cameraPos, lookAtPos)
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end
        
        spawn(function()
            createScreenFlash()
        end)
        
        wait(5)

require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("我们又见面了",true)
wait(2)
require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("这次还是一样，你依赖你那可笑的躲藏点与衣柜",true)
wait(2)
        local TweenService = game:GetService("TweenService")

local function showFullscreenImage()
    local player = game.Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui", gui)
    screenGui.Name = "FullscreenImage"
    screenGui.IgnoreGuiInset = true  
    
    local image = Instance.new("ImageLabel", screenGui)
    image.Name = "FullscreenImageLabel"
    
    image.Image = "rbxassetid://115142446909754"
    image.Size = UDim2.new(2, 0, 1, 0)
    image.Position = UDim2.new(-0.5, 0, 0, 0)
    image.BackgroundTransparency = 1
    image.ImageTransparency = 1

    image.ScaleType = Enum.ScaleType.Fit
    image.BackgroundColor3 = Color3.new(0, 0, 0)
    
    local fadeIn = TweenService:Create(image, TweenInfo.new(0.01, Enum.EasingStyle.Linear), {ImageTransparency = 0})
    fadeIn:Play()

    fadeIn.Completed:Wait()
local sound = Instance.new("Sound", workspace)
sound.SoundId = "rbxassetid://116282238939992"
sound.Volume = 1
sound:Play()

replicatesignal(game.Players.LocalPlayer.Kill)
    wait(0.1)

    local fadeOut = TweenService:Create(image, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {ImageTransparency = 1})
    fadeOut:Play()
    
sound.Ended:Wait()
sound:Destroy() 
    fadeOut.Completed:Wait()
    screenGui:Destroy()
end
showFullscreenImage()

        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        if camera then
            camera.CameraType = originalCameraType
            camera.CameraSubject = originalSubject
        end
    end
    
    jumpModel:Destroy()
end
local function triggerJumpScare()
    if not character or not character.Parent then
        return
    end
    
    createJumpScareAtPlayer()
end
local ripperCheckConnection
local function startRipperCheck()
    if ripperCheckConnection then
        ripperCheckConnection:Disconnect()
    end
    ripperCheckConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not character or not character.Parent then
            if ripperCheckConnection then
                ripperCheckConnection:Disconnect()
            end
            return
        end
        local ripperModel = workspace:FindFirstChild("Ripper")
        
        if not ripperModel then
            if ripperCheckConnection then
                ripperCheckConnection:Disconnect()
            end
            triggerJumpScare()
        end
    end)
end
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name == "DGJF" then
        obj:Destroy()
    end
end
startRipperCheck()
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(1)
    startRipperCheck()
end)
end

function entityBehaviors.CL()
 local Event = game:GetService("ReplicatedStorage").RemotesFolder.AdminPanelRunCommand
    Event:FireServer("Break Lights", {["Lights Affected"] = 100, ["Affect All Rooms"] = true})
    task.wait(1)
    Event:FireServer("LightRoom", {["Light Color"] = Color3.new(0.80784314870834, 0.63644915819168, 0)})
    task.wait(0.1)
    Event:FireServer("DELETE ALL", {})
    task.wait(2)
    
    local function deleteDirectChildModels()
        for _, name in ipairs({"A-200", "A60", "Amin-60", "Black-A60", "Deer god", "DeerGod", "Frostbite", "@&%^#*$Indescribable God!@$*&^!Q(* ", "LightSpeed", "Rebound", "Ripper", "Following_ENEMY", "Silence", "smiler", "Chainsmoker"}) do
            local model = workspace:FindFirstChild(name)
            if model and model:IsA("Model") then model:Destroy() end
        end
    end
    deleteDirectChildModels()
    
    function GetRoom()
        return workspace.CurrentRooms:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
    end
    
    function LoadCustomInstance(source)
        local model
        while task.wait() and not model do
            if tonumber(source) then
                local success, result = pcall(function() return game:GetObjects("rbxassetid://"..tostring(source))[1] end)
                if success and result then model = result end
            end
        end
        if model then
            model.Parent = workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then obj:Destroy() end
            end
        end
        return model
    end
    
    local s = LoadCustomInstance("78378481962514")
    if not s then return end
    s.Name = "CuriLight"
    
    local entity = s:FindFirstChildWhichIsA("BasePart")
    if entity then entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(0,5,-25) end
    
    pcall(function()
        local room = workspace.CurrentRooms:FindFirstChild(tostring(game.ReplicatedStorage.GameData.LatestRoom.Value))
        if room then
            for _, obj in ipairs(room:GetDescendants()) do
                if obj.Name == "PlaySound" and obj:IsA("Sound") then
                    obj:Stop() obj.Playing = false obj.TimePosition = 0 obj.Looped = false
                end
            end
            local fireplace = room.Assets.Fireplace.Fireplace_Logs
            fireplace.ToolEventPrompt.Enabled = false
            local log = fireplace.Log
            log.SparkParticles.Enabled = false
            log.SmokeParticles.Enabled = false
            log.FireParticles.Enabled = false
            log.FireLight.Enabled = false
        end
    end)
    task.wait(0.5)
    
    function GitAud(soundgit, filename)
        local url = soundgit
        local FileName = filename
        writefile(FileName..".mp3", game:HttpGet(url))
        return (getcustomasset or getsynasset)(FileName..".mp3")
    end
    function CustomGitSound(soundlink, vol, filename)
        local sound = Instance.new("Sound")
        sound.SoundId = GitAud(soundlink, filename)
        sound.Parent = workspace
        sound.Name = filename or "CL"
        sound.Volume = vol or 1
        sound:Play()
        return sound
    end
    
    local targetAudioUrl = "https://github.com/Zero0star/RipperMPSound/blob/master/CuriLightSpeak.mp3?raw=true"
    local volume = 2
    local localFileName = "CruiMu"
    
    local function setupCuriLightFeatures()
        local CuriLight = workspace:FindFirstChild("CuriLight")
        if not CuriLight or not CuriLight:IsA("Model") then return end
        
        local humanoid = CuriLight:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            humanoid = Instance.new("Humanoid")
            humanoid.Name = "Humanoid"
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.AutoRotate = false
            humanoid.Parent = CuriLight
        end
        
        local function playAnimation()
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if not animator then animator = Instance.new("Animator") animator.Parent = humanoid end
            
            local animationId = "rbxassetid://122746752555782"
            local success, errorMsg = pcall(function()
                local animation = Instance.new("Animation")
                animation.AnimationId = animationId
                animation.Name = "CuriLightAnimation"
                local animationTrack = humanoid:LoadAnimation(animation)
                if animationTrack then 
                    animationTrack.Looped = true
                    animationTrack:Play()
                    return animationTrack
                end
                return nil
            end)
            
            if not success then warn("NO:", errorMsg) end
        end
        
        playAnimation()
        
        local function getPrimaryPart(model)
            if model.PrimaryPart then return model.PrimaryPart end
            local parts = {"HumanoidRootPart", "Head", "Torso", "UpperTorso", "Part"}
            for _, partName in ipairs(parts) do
                local part = model:FindFirstChild(partName)
                if part and part:IsA("BasePart") then return part end
            end
            for _, child in ipairs(model:GetChildren()) do
                if child:IsA("BasePart") then return child end
            end
            return nil
        end
        
        local curiLightPart = getPrimaryPart(CuriLight)
        if not curiLightPart then return end
        
        local CONFIG = {ROTATION_SPEED = 5, SMOOTHNESS = 0.1, HEIGHT_OFFSET = 0, MAX_DISTANCE = 100, ENABLED = true}
        local lastUpdateTime = tick()
        local connection
        
        local function updateLookAt()
            if not CONFIG.ENABLED then return end
            local character = game.Players.LocalPlayer.Character
            if not character then return end
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            local distance = (humanoidRootPart.Position - curiLightPart.Position).Magnitude
            if distance > CONFIG.MAX_DISTANCE then return end
            local targetPosition = humanoidRootPart.Position + Vector3.new(0, CONFIG.HEIGHT_OFFSET, 0)
            local curiLightPosition = curiLightPart.Position
            local direction = (targetPosition - curiLightPosition).Unit
            local targetLookAt = CFrame.lookAt(curiLightPosition, curiLightPosition + direction)
            local _, currentY, _ = curiLightPart.CFrame:ToOrientation()
            local _, targetY, _ = targetLookAt:ToOrientation()
            local yawDifference = targetY - currentY
            if yawDifference > math.pi then yawDifference = yawDifference - 2 * math.pi
            elseif yawDifference < -math.pi then yawDifference = yawDifference + 2 * math.pi end
            local deltaTime = tick() - lastUpdateTime
            lastUpdateTime = tick()
            local lerpAmount = 1 - math.exp(-CONFIG.ROTATION_SPEED * deltaTime)
            local lerpedY = currentY + yawDifference * lerpAmount
            local newCFrame = CFrame.new(curiLightPosition) * CFrame.Angles(0, lerpedY, 0)
            curiLightPart.CFrame = newCFrame
        end
        
        connection = game:GetService("RunService").Heartbeat:Connect(updateLookAt)
        
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == Enum.KeyCode.T and not gameProcessed then CONFIG.ENABLED = not CONFIG.ENABLED end
        end)
        
        return CuriLight, connection
    end
    local curiModel, curiConnection = setupCuriLightFeatures()
    task.wait(5)
    local sound = CustomGitSound(targetAudioUrl, volume, localFileName)
    task.wait(1)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("Dead Again",true)
    task.wait(3)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("You know better than I how to save yourself.",true)
    task.wait(2.5)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("OH",true)
    task.wait(1.4)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("I think you are using something called admin.",true)
    task.wait(2.8)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("Sorry..",true)
    task.wait(2.2)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("But my appearance is not to save you.",true)
    task.wait(2.5)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("In short, be careful next time...",true)
    task.wait(2.2)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("However, I will always keep an eye on you.",true)
    task.wait(4)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("Okey..",true)
    task.wait(2)
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).caption("See U Again",true)
    sound.Ended:Wait()
    if curiConnection then curiConnection:Disconnect() end
    if curiModel then curiModel:Destroy() end
end

function entityBehaviors.Shok()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function spawnShocker()
    local shockerModel = game:GetObjects("rbxassetid://129658537539698")[1]
    local camera = Workspace.CurrentCamera

    local rootPart = shockerModel:FindFirstChild("HumanoidRootPart") or shockerModel:FindFirstChildWhichIsA("Part")
    shockerModel.PrimaryPart = rootPart
    shockerModel:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, 0, -7))
    shockerModel.Parent = Workspace

    local oogaBoogaaPart = shockerModel:WaitForChild("OOGA BOOGAAAA")
    local horrorScream = oogaBoogaaPart:WaitForChild("HORROR SCREAM 15")
    local boneSound = oogaBoogaaPart:FindFirstChild("Bone")

    local lookDuration = 2
    local lookStart = nil
    local hasTriggered = false
    local hasFallen = false

    local function fallToGround()
        if hasFallen then return end
        hasFallen = true

        oogaBoogaaPart.Anchored = false
        oogaBoogaaPart.CanCollide = false

        task.delay(2, function()
            if shockerModel then
                shockerModel:Destroy()
            end
        end)
    end

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        if hasTriggered then connection:Disconnect() return end

        local directionToShocker = (oogaBoogaaPart.Position - camera.CFrame.Position).Unit
        local playerLookVector = camera.CFrame.LookVector
        local dot = directionToShocker:Dot(playerLookVector)

        if dot > 0.85 then
            if not lookStart then
                lookStart = tick()
            elseif tick() - lookStart >= lookDuration then
                hasTriggered = true
                connection:Disconnect()

                horrorScream:Play()
                if boneSound then boneSound:Play() end
                humanoid:TakeDamage(30)
                local targetPos = character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
                local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                local tween = TweenService:Create(oogaBoogaaPart, tweenInfo, {Position = targetPos})
                tween:Play()

                tween.Completed:Connect(function()
                    fallToGround()
                end)

                ReplicatedStorage.GameStats["Player_".. player.Name].Total.DeathCause.Value = "Shocker"
                firesignal(ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
                    "You died to who you call Shocker...",
                    "Don't look at it or it stuns you!"
                }, "Blue")
            end
        else
            connection:Disconnect()
            fallToGround()
        end
    end)

    task.delay(5, function()
        if not hasTriggered and not hasFallen then
            fallToGround()
        end
    end)
end
spawnShocker()
end

function entityBehaviors.MLcur()
local modelID = 90889178594108
local targetName = "Repentance_Skinned"
local loadedModel = nil
local targetModel = nil
local anchorPart = nil
local connections = {}
local isFollowing = false
local fadeStartTime = nil
local isFading = false
local isProcessing = false
local processedModels = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cachedModel
local function preloadModel()
    if cachedModel and cachedModel.Parent then
        cachedModel:Destroy()
        cachedModel = nil
    end
    
    local success, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(modelID))
    end)
    
    if not success or not result or not result[1] then
        return nil
    end
    
    cachedModel = result[1]
    cachedModel.Name = "Preloaded_VFX_Model"
    cachedModel.Parent = ReplicatedStorage
    
    for _, part in ipairs(cachedModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Massless = true
        end
    end
    
    return cachedModel
end

local function getModelFromCache()
    if not cachedModel or not cachedModel.Parent then
        return nil
    end
    
    local modelClone = cachedModel:Clone()
    modelClone.Parent = workspace
    modelClone.Name = "Follow_Model"
    
    return modelClone
end

local function createAnchorAtEntity()
    if not targetModel or not targetModel.Parent then 
        return nil 
    end
    
    local entity = targetModel:FindFirstChild("Entity")
    if not entity then
        return nil
    end
    
    local anchor = Instance.new("Part")
    anchor.Name = "Entity_Anchor"
    anchor.Size = Vector3.new(0.01, 0.01, 0.01)
    anchor.Transparency = 1
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanTouch = false
    anchor.CanQuery = false
    anchor.Massless = true
    anchor.CFrame = entity.CFrame + Vector3.new(0, 6.5, 0)
    anchor.Parent = workspace
    
    return anchor
end

local function deleteTargetParts()
    if not targetModel or not targetModel.Parent then return end
    
    local crucifix = targetModel:FindFirstChild("Crucifix")
    if crucifix then
        crucifix:Destroy()
    end
end

local function playAudioOnce()
    if not cachedModel or not cachedModel.Parent then
        return
    end
    
    local reversalRed = cachedModel:FindFirstChild("Reversal Red")
    if not reversalRed then
        for _, descendant in ipairs(cachedModel:GetDescendants()) do
            if descendant.Name:lower() == "reversal red" then
                reversalRed = descendant
                break
            end
        end
    end
    
    if reversalRed then
        local doorsCrucifix = reversalRed:FindFirstChild("doors crucifix")
        if not doorsCrucifix then
            for _, descendant in ipairs(reversalRed:GetDescendants()) do
                if descendant:IsA("Sound") and descendant.Name:lower() == "doors crucifix" then
                    doorsCrucifix = descendant
                    break
                end
            end
        end
        
        if doorsCrucifix and doorsCrucifix:IsA("Sound") then
            local sound = doorsCrucifix:Clone()
            sound.Parent = workspace
            sound:Play()
            
            sound.Ended:Connect(function()
                if sound and sound.Parent then
                    sound:Destroy()
                end
            end)
        end
    end
end

local function loadModel()
    if loadedModel and loadedModel.Parent then
        loadedModel:Destroy()
        loadedModel = nil
    end
    
    local model = getModelFromCache()
    
    if model then
        playAudioOnce()
    end
    
    return model
end

local function fadeOutModel()
    if not loadedModel or not loadedModel.Parent then return end
    
    isFading = true
    local fadeDuration = 2
    local startTime = tick()
    
    while loadedModel and loadedModel.Parent and tick() - startTime < fadeDuration do
        local progress = (tick() - startTime) / fadeDuration
        
        for _, part in ipairs(loadedModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = progress
            elseif part:IsA("ParticleEmitter") then
                part.Rate = part.Rate * (1 - progress)
            end
        end
        
        RunService.Heartbeat:Wait()
    end
    
    if loadedModel and loadedModel.Parent then
        loadedModel:Destroy()
        loadedModel = nil
    end
    
    isFading = false
    isProcessing = false
    
    if anchorPart and anchorPart.Parent then
        anchorPart:Destroy()
        anchorPart = nil
    end
    
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    
    delay(0.5, function()
        if cachedModel and cachedModel.Parent then
            cachedModel:Destroy()
            cachedModel = nil
        end
    end)
end

local function followTarget()
    if not anchorPart or not anchorPart.Parent or not loadedModel or not loadedModel.Parent then
        isFollowing = false
        return
    end
    
    isFollowing = true
    loadedModel:PivotTo(anchorPart.CFrame)
    fadeStartTime = tick()
    
    while isFollowing and anchorPart and anchorPart.Parent and loadedModel and loadedModel.Parent do
        RunService.Heartbeat:Wait()
        
        loadedModel:PivotTo(anchorPart.CFrame)
        
        if not isFading and tick() - fadeStartTime >= 8 then
            fadeOutModel()
        end
    end
end

local function processTarget()
    if isProcessing or processedModels[targetModel] then
        return
    end
    
    local entity = targetModel:FindFirstChild("Entity")
    if not entity then
        return
    end
    
    processedModels[targetModel] = true
    isProcessing = true
    isFollowing = false
    isFading = false
    fadeStartTime = nil
    
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    
    if loadedModel and loadedModel.Parent then
        loadedModel:Destroy()
        loadedModel = nil
    end
    
    if anchorPart and anchorPart.Parent then
        anchorPart:Destroy()
        anchorPart = nil
    end
    
    if not targetModel or not targetModel.Parent or not targetModel:IsA("Model") then
        processedModels[targetModel] = nil
        isProcessing = false
        return
    end
    deleteTargetParts()
    anchorPart = createAnchorAtEntity()
    if not anchorPart then
        processedModels[targetModel] = nil
        isProcessing = false
        return
    end
    loadedModel = loadModel()
    if not loadedModel then
        anchorPart:Destroy()
        anchorPart = nil
        processedModels[targetModel] = nil
        isProcessing = false
        return
    end
    local conn1 = targetModel.AncestryChanged:Connect(function(_, parent)
        if not parent then
            isFollowing = false
            if loadedModel and loadedModel.Parent then
                loadedModel:Destroy()
                loadedModel = nil
            end
            if anchorPart and anchorPart.Parent then
                anchorPart:Destroy()
                anchorPart = nil
            end
        end
    end)
    local conn2 = loadedModel.AncestryChanged:Connect(function(_, parent)
        if not parent then
            isFollowing = false
            loadedModel = nil
        end
    end)
    local conn3 = anchorPart.AncestryChanged:Connect(function(_, parent)
        if not parent then
            isFollowing = false
            anchorPart = nil
        end
    end)
    table.insert(connections, conn1)
    table.insert(connections, conn2)
    table.insert(connections, conn3)
    coroutine.wrap(followTarget)()
end
workspace.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "Entity" then
        local model = descendant.Parent
        if model and model.Name == targetName and model:IsA("Model") and not processedModels[model] and not isProcessing then
            wait(0.1)
            targetModel = model
            processTarget()
        end
    end
    if descendant.Name == targetName and descendant:IsA("Model") and not processedModels[descendant] and not isProcessing then
        wait(0.2)
        local entity = descendant:FindFirstChild("Entity")
        if entity then
            targetModel = descendant
            processTarget()
        end
    end
end)
local preloadSuccess = pcall(preloadModel)
if not preloadSuccess or not cachedModel then
    return
end
wait(2)
end

function entityBehaviors.Bombie()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local REPLACEMENT_CONFIG = {
    ["compass"] = {assetId = 111123143736711}
}
local CHECK_INTERVAL = 0.3
local trackedTargets = {}

local OFFSET_LEFT = Vector3.new(-10, 0, 0)
local OFFSET_UP = Vector3.new(0, 5, 0)
local TOTAL_OFFSET = OFFSET_LEFT + OFFSET_UP

local function loadAssetLocally(assetId)
    local success, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. assetId)[1]
    end)
    if success and result then
        return result:Clone()
    end
    return nil
end

local function disableModelCollision(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
        end
    end
end

local function hideCompassParts(compass)
    if not compass or not compass.Parent then return end
    
    local function hideRecursive(obj)
        if obj:IsA("MeshPart") or obj:IsA("BasePart") then
            if not trackedTargets[compass] then
                trackedTargets[compass] = {originalParts = {}}
            end
            trackedTargets[compass].originalParts[obj] = {transparency = obj.Transparency}
            obj.Transparency = 1
        end
        
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            if not trackedTargets[compass] then
                trackedTargets[compass] = {originalParts = {}}
            end
            trackedTargets[compass].originalParts[obj] = {enabled = obj.Enabled}
            obj.Enabled = false
        end
        
        if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
            if not trackedTargets[compass] then
                trackedTargets[compass] = {originalParts = {}}
            end
            trackedTargets[compass].originalParts[obj] = {transparency = obj.Transparency}
            obj.Transparency = 1
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            hideRecursive(child)
        end
    end
    
    hideRecursive(compass)
end
local function restoreCompass(compass)
    local data = trackedTargets[compass]
    if not data or not data.originalParts then return end
    
    for part, partData in pairs(data.originalParts) do
        if part and part.Parent then
            if (part:IsA("MeshPart") or part:IsA("BasePart")) and partData.transparency then
                part.Transparency = partData.transparency
            elseif (part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Trail")) and partData.enabled ~= nil then
                part.Enabled = partData.enabled
            elseif (part:IsA("Texture") or part:IsA("Decal") or part:IsA("SurfaceAppearance")) and partData.transparency then
                part.Transparency = partData.transparency
            end
        end
    end
end

local function getItemConfig(itemName)
    local nameLower = itemName:lower()
    return REPLACEMENT_CONFIG[nameLower]
end
local function getTargetCFrame(target)
    if target:IsA("BasePart") or target:IsA("MeshPart") then
        return target.CFrame
    elseif target:IsA("Tool") and target:FindFirstChild("Handle") then
        return target.Handle.CFrame
    elseif target:IsA("Model") then
        if target.PrimaryPart then
            return target:GetPivot()
        elseif target:FindFirstChildWhichIsA("BasePart") then
            return target:FindFirstChildWhichIsA("BasePart").CFrame
        end
    end
    return nil
end

local function createFollowEffect(target, assetId)
    local effectModel = loadAssetLocally(assetId)
    if not effectModel then 
        return nil 
    end
    
    effectModel.Name = "Compass_Follower"
    effectModel.Parent = workspace
    disableModelCollision(effectModel)
    
    if not effectModel.PrimaryPart then
        if effectModel:FindFirstChildWhichIsA("BasePart") then
            effectModel.PrimaryPart = effectModel:FindFirstChildWhichIsA("BasePart")
        else
            effectModel:Destroy()
            return nil
        end
    end
    
    local targetCFrame = getTargetCFrame(target)
    if targetCFrame then
        local offsetCFrame = targetCFrame + TOTAL_OFFSET
        effectModel:PivotTo(offsetCFrame)
    end
    
    return effectModel
end

local function updateEffectPosition(data, target)
    if not data.effect or not data.effect.Parent or not target or not target.Parent then
        return false
    end
    
    local targetCFrame = getTargetCFrame(target)
    if not targetCFrame then
        return false
    end

    local offsetCFrame = targetCFrame + TOTAL_OFFSET
    data.effect:PivotTo(offsetCFrame)
    return true
end

local function startTrackingTarget(target, config)
    if trackedTargets[target] then 
        return trackedTargets[target] 
    end
    
    local effectModel = createFollowEffect(target, config.assetId)
    if not effectModel then 
        return nil 
    end
    
    hideCompassParts(target)
    
    trackedTargets[target] = {
        effect = effectModel, 
        target = target,
        config = config
    }
    
    local data = trackedTargets[target]
    
    data.connection = RunService.RenderStepped:Connect(function()
        if not updateEffectPosition(data, target) then
            if data.connection then
                data.connection:Disconnect()
            end
            if data.effect and data.effect.Parent then
                data.effect:Destroy()
            end
            trackedTargets[target] = nil
        end
    end)
    
    return trackedTargets[target]
end

local function stopTrackingTarget(target, restoreVisibility)
    local data = trackedTargets[target]
    if not data then return end
    
    if restoreVisibility then
        restoreCompass(target)
    end
    
    if data.effect and data.effect.Parent then
        data.effect:Destroy()
    end
    
    if data.connection then
        data.connection:Disconnect()
    end
    
    trackedTargets[target] = nil
end

local function cleanupDestroyedTargets()
    for target, data in pairs(trackedTargets) do
        if not target or not target.Parent then
            if data.effect and data.effect.Parent then
                data.effect:Destroy()
            end
            if data.connection then
                data.connection:Disconnect()
            end
            trackedTargets[target] = nil
        end
    end
end

local function findAllCompasses()
    local targets = {}
    
    local function findCompassesRecursive(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name:lower() == "compass" then
                local config = getItemConfig(child.Name)
                if config then
                    table.insert(targets, {target = child, config = config})
                end
            end
            findCompassesRecursive(child)
        end
    end
    
    findCompassesRecursive(workspace)
    return targets
end

local function startDetection()
    local lastCheckTime = 0
    
    while true do
        local currentTime = tick()
        
        if currentTime - lastCheckTime >= CHECK_INTERVAL then
            lastCheckTime = currentTime
            
            cleanupDestroyedTargets()
            
            local allCompasses = findAllCompasses()
            
            for _, targetData in ipairs(allCompasses) do
                if not trackedTargets[targetData.target] then
                    startTrackingTarget(targetData.target, targetData.config)
                end
            end
            
            for target, data in pairs(trackedTargets) do
                if target and target.Parent then
                    local isValid = false
                    local parent = target.Parent
                    
                    while parent do
                        if parent == workspace then
                            isValid = true
                            break
                        end
                        parent = parent.Parent
                    end
                    
                    if not isValid then
                        stopTrackingTarget(target, true)
                    end
                end
            end
        end
        
        RunService.Heartbeat:Wait()
    end
end
local function initialize()
    task.spawn(startDetection)
end
local function cleanup()
    for target, _ in pairs(trackedTargets) do
        stopTrackingTarget(target, true)
    end
    trackedTargets = {}
end
local function setupPlayerEvents()
    local player = Players.LocalPlayer
    if player then
        player:GetPropertyChangedSignal("Character"):Connect(function()
            cleanupDestroyedTargets()
        end)
        
        player.AncestryChanged:Connect(function(_, parent)
            if not parent then
                cleanup()
            end
        end)
    end
end
initialize()
setupPlayerEvents()
end

function entityBehaviors.HUMANSW()
function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end

local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")

function LoadCustomInstance(source, parent)
    local model

    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end

    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end

    return model
end

local s = LoadCustomInstance(131784429865597, workspace)
if not s then
    return
end

local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(-20, -2.5, -10)
entity.Part.CFrame = entity.CFrame

pcall(function()
local room = workspace.CurrentRooms:FindFirstChild(
    tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)
)
if room then
    for _, obj in ipairs(room:GetDescendants()) do
        if obj.Name == "PlaySound" and obj:IsA("Sound") then
            obj:Stop()
            obj.Playing = false
            obj.TimePosition = 0
            obj.Looped = false
        end
    end
end
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.ToolEventPrompt.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SparkParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SmokeParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireLight.Enabled = false
end)
end

function entityBehaviors.Booom()
local soundService = game:GetService("SoundService")
local workspace = game.Workspace
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

local firstSound = Instance.new("Sound")
firstSound.SoundId = "rbxassetid://139207403536718"
firstSound.Volume = 3
firstSound.Parent = workspace

local playCount = 0
local screenGuis = {}

local function createWhiteScreenEffect(player)
    if not player then return nil, nil end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        player.CharacterAdded:Wait()
        playerGui = player:WaitForChild("PlayerGui")
    end
    
    local oldGui = playerGui:FindFirstChild("WhiteScreenEffect")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WhiteScreenEffect"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    local whiteFrame = Instance.new("Frame")
    whiteFrame.Name = "WhiteOverlay"
    whiteFrame.Size = UDim2.new(1, 0, 1, 0)
    whiteFrame.Position = UDim2.new(0, 0, 0, 0)
    whiteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    whiteFrame.BackgroundTransparency = 1
    whiteFrame.BorderSizePixel = 0
    whiteFrame.ZIndex = 999
    
    whiteFrame.Parent = screenGui
    screenGui.Parent = playerGui
    
    screenGuis[player] = {screenGui = screenGui, whiteFrame = whiteFrame}
    
    return screenGui, whiteFrame
end

local function playWhiteScreenEffect()
    for _, player in ipairs(players:GetPlayers()) do
        coroutine.wrap(function()
            local screenGui, whiteFrame = createWhiteScreenEffect(player)
            if not screenGui or not whiteFrame then return end
            
            local fadeInInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local fadeInGoal = {BackgroundTransparency = 0}
            local fadeInTween = tweenService:Create(whiteFrame, fadeInInfo, fadeInGoal)
            
            local fadeOutInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local fadeOutGoal = {BackgroundTransparency = 1}
            local fadeOutTween = tweenService:Create(whiteFrame, fadeOutInfo, fadeOutGoal)
            
            fadeInTween:Play()
            fadeInTween.Completed:Wait()
            
            wait(4)
            
            fadeOutTween:Play()
            fadeOutTween.Completed:Wait()
            
            if screenGui and screenGui.Parent then
                screenGui:Destroy()
            end
            screenGuis[player] = nil
        end)()
    end
end

local function changeAllPartsToBlack()
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("BasePart") and item.Name ~= "Floor" then
            item.Anchored = false
            item.BrickColor = BrickColor.new("Really black")
            item.Color = Color3.new(0, 0, 0)
            
            local surfaceAppearance = item:FindFirstChildOfClass("SurfaceAppearance")
            if surfaceAppearance then
                surfaceAppearance:Destroy()
            end
        end
        
        if item:IsA("Model") then
            for _, part in ipairs(item:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "Floor" then
                    part.Anchored = false
                    part.BrickColor = BrickColor.new("Really black")
                    part.Color = Color3.new(0, 0, 0)
                    
                    local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
                    if surfaceAppearance then
                        surfaceAppearance:Destroy()
                    end
                end
            end
        end
    end
end

local function startCameraShake()
    local SHAKE_INTENSITY = 50
    local SHAKE_DURATION = 10
    local SHAKE_SPEED = 70
    
    for _, player in ipairs(players:GetPlayers()) do
        coroutine.wrap(function()
            if not player then return end
            
            local camera = workspace.CurrentCamera
            local startTime = tick()
            local originalPosition = camera.CFrame.Position
            local connection
            
            connection = runService.RenderStepped:Connect(function()
                local elapsed = tick() - startTime
                
                if elapsed < SHAKE_DURATION then
                    local decay = 1 - (elapsed / SHAKE_DURATION)
                    local intensity = SHAKE_INTENSITY * decay
                    
                    local time = elapsed * SHAKE_SPEED
                    local offset = Vector3.new(
                        math.sin(time * 1.1) * intensity * 0.5 + math.random(-intensity, intensity) * 0.3,
                        math.cos(time * 0.9) * intensity * 0.5 + math.random(-intensity, intensity) * 0.3,
                        math.sin(time * 1.0) * intensity * 0.3
                    )
                    
                    local lookVector = camera.CFrame.LookVector
                    local currentPos = camera.CFrame.Position
                    local newPos = currentPos + offset
                    
                    camera.CFrame = CFrame.new(newPos, newPos + lookVector) * CFrame.Angles(0, 0, 0)
                else
                    if connection then
                        connection:Disconnect()
                    end
                end
            end)
        end)()
    end
end

firstSound.Ended:Connect(function()
    playCount = playCount + 1
    
    if playCount >= 3 then
        local secondSound = Instance.new("Sound")
        secondSound.SoundId = "rbxassetid://132158324987663"
        secondSound.Volume = 10
        secondSound.Parent = workspace
        
        playWhiteScreenEffect()
        startCameraShake()
        
        wait(0.05)
        secondSound:Play()
        
        secondSound.Ended:Connect(function()
            changeAllPartsToBlack()
            secondSound:Destroy()
        end)
        
        firstSound:Destroy()
    else
        wait(0.1)
        firstSound:Play()
    end
end)

firstSound:Play()

players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if firstSound and firstSound.Parent then
            firstSound:Destroy()
        end
    end)
    
    if screenGuis[player] then
        screenGuis[player].screenGui:Destroy()
        screenGuis[player] = nil
    end
end)

players.PlayerRemoving:Connect(function(player)
    if screenGuis[player] then
        screenGuis[player].screenGui:Destroy()
        screenGuis[player] = nil
    end
end)

for _, player in ipairs(players:GetPlayers()) do
    if not screenGuis[player] then
        screenGuis[player] = nil
    end
end
end

function entityBehaviors.SuperDread()
function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end

local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")

function LoadCustomInstance(source, parent)
    local model

    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end

    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    warn("Executor không hỗ trợ file APIs.")
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end

    return model
end

local s = LoadCustomInstance(140017686556165, workspace) 
if not s then
    return
end

local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(0, 1, -15)
entity.Part.CFrame = entity.CFrame

pcall(function()
local room = workspace.CurrentRooms:FindFirstChild(
    tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)
)
if room then
    for _, obj in ipairs(room:GetDescendants()) do
        if obj.Name == "PlaySound" and obj:IsA("Sound") then
            obj:Stop()
            obj.Playing = false
            obj.TimePosition = 0
            obj.Looped = false
        end
    end
end
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.ToolEventPrompt.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SparkParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SmokeParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireLight.Enabled = false
end)
end

function entityBehaviors.DreadJump()
local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)
function GitAud(soundgit, filename)
    local url = soundgit
    local fileName = filename or "temp_audio"
    local fullFileName = fileName .. ".mp3"
    
    local success, audioData = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        return nil
    end
    
    local writeSuccess, writeError = pcall(function()
        writefile(fullFileName, audioData)
    end)
    
    if not writeSuccess then
        return nil
    end
    
    local assetPath
    if getsynasset then
        assetPath = getsynasset(fullFileName)
    elseif getcustomasset then
        assetPath = getcustomasset(fullFileName)
    else
        return nil
    end
    
    return assetPath
end

function CustomGitSound(soundlink, vol, filename)
    local sound = Instance.new("Sound")
    local soundId = GitAud(soundlink, filename)
    
    if not soundId then
        return nil
    end
    
    sound.SoundId = soundId
    sound.Parent = workspace
    sound.Name = filename .. "_" .. tick()
    sound.Volume = vol or 1
    sound.Loaded:Wait()
    sound:Play()
    return sound
end
local githubAudioUrl = "https://github.com/Zero0Star/RipperNewSound/blob/master/DreadJumpFace.mp3?raw=true"
local volume = 2
local saveName = "DreadNEW"
local part = Instance.new("Part")
part.Name = "Bound_" .. tick()
part.Parent = workspace
part.Size = Vector3.new(5, 5, 5)
part.Position = Vector3.new(0, 5, 0)
part.Anchored = true
part.Color = Color3.new(1, 0, 0)

local startSound = CustomGitSound(githubAudioUrl, volume, saveName)

if startSound then

    local isPlaying = true

    task.wait(3)
    local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SHAKE_INTENSITY = 1
local SHAKE_DURATION = 15
local SHAKE_SPEED = 70

local player = Players.LocalPlayer
if not player then return end

local camera = workspace.CurrentCamera
local startTime = tick()
local originalPosition = camera.CFrame.Position
local connection

connection = RunService.RenderStepped:Connect(function()
    local elapsed = tick() - startTime
    
    if elapsed < SHAKE_DURATION then

        local decay = 1 - (elapsed / SHAKE_DURATION)
        local intensity = SHAKE_INTENSITY * decay

        local time = elapsed * SHAKE_SPEED
        local offset = Vector3.new(
            math.sin(time * 1.1) * intensity * 0.5 + math.random(-intensity, intensity) * 0.3,
            math.cos(time * 0.9) * intensity * 0.5 + math.random(-intensity, intensity) * 0.3,
            math.sin(time * 1.0) * intensity * 0.3
        )

        local lookVector = camera.CFrame.LookVector
        local upVector = camera.CFrame.UpVector
        local rightVector = camera.CFrame.RightVector

        local currentPos = camera.CFrame.Position
        local newPos = currentPos + offset
        

        camera.CFrame = CFrame.new(newPos, newPos + lookVector) * CFrame.Angles(0, 0, 0)
        
    else

        if connection then
            connection:Disconnect()
        end
    end
end)

    local function getAllParts()
        local parts = {}
        local function collectParts(object)
            for _, child in ipairs(object:GetChildren()) do
                if child:IsA("BasePart") then
                    table.insert(parts, child)
                end
                collectParts(child)
            end
        end
        collectParts(workspace)
        return parts
    end

    local allParts = getAllParts()
    
    local colorSwitchCoroutine = coroutine.create(function()
        local isBlack = true
        
        while isPlaying do

            local targetColor = isBlack and BLACK or WHITE
            isBlack = not isBlack

            for _, part in ipairs(allParts) do
                part.Color = targetColor
            end

            task.wait(0.01)
        end
    end)

    coroutine.resume(colorSwitchCoroutine)

    startSound.Ended:Connect(function()
        isPlaying = false
        startSound:Destroy()
    end)

    startSound.Stopped:Connect(function()
        isPlaying = false
        startSound:Destroy()
    end)
    
else
end
end

function entityBehaviors.LightOSs()
 function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end

local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")

function LoadCustomInstance(source, parent)
    local model

    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end

    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    warn("Executor không hỗ trợ file APIs.")
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end

    return model
end

local s = LoadCustomInstance(106818719931200, workspace)
if not s then
    return
end

local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(0, 7, -15)
entity.Part.CFrame = entity.CFrame
end

function entityBehaviors.LOOKSW()
function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end

local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local tweenservice = game:GetService("TweenService")

function LoadCustomInstance(source, parent)
    local model

    local function NormalizeGitHubURL(url)
        if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
            return url .. "?raw=true"
        end
        return url
    end

    while task.wait() and not model do
        if tonumber(source) then
            local success, result = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(source))[1]
            end)
            if success and result then
                model = result
            end
        elseif typeof(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
            local url = NormalizeGitHubURL(source)
            local success, result = pcall(function()
                local filename = "temp_" .. math.random(100000, 999999) .. ".rbxm"
                local content = game:HttpGet(url)
                if writefile and (getcustomasset or getsynasset) and isfile and delfile then
                    writefile(filename, content)
                    local assetFunc = getcustomasset or getsynasset
                    local obj = game:GetObjects(assetFunc(filename))[1]
                    delfile(filename)
                    return obj
                else
                    return nil
                end
            end)
            if success and result then
                model = result
            end
        else
            break
        end

        if model then
            model.Parent = parent or workspace
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        end
    end

    return model
end

local s = LoadCustomInstance(124094609630783, workspace)
if not s then
    return
end

local entity = s:FindFirstChildWhichIsA("BasePart")
entity.CFrame = GetRoom():WaitForChild("RoomEntrance").CFrame * CFrame.new(30, 1.2, -10)
entity.Part.CFrame = entity.CFrame

pcall(function()
local room = workspace.CurrentRooms:FindFirstChild(
    tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)
)
if room then
    for _, obj in ipairs(room:GetDescendants()) do
        if obj.Name == "PlaySound" and obj:IsA("Sound") then
            obj:Stop()
            obj.Playing = false
            obj.TimePosition = 0
            obj.Looped = false
        end
    end
end
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.ToolEventPrompt.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SparkParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.SmokeParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireParticles.Enabled = false
workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Fireplace.Fireplace_Logs.Log.FireLight.Enabled = false
end)
end

local entityConfig = {
    ["rbxassetid://140338542312593"] = entityBehaviors.FigureSpawn,
    ["rbxassetid://140612367685491"] = entityBehaviors.GodOFOne,
    ["rbxassetid://140537774926087"] = entityBehaviors.GodOfTwo, 
    ["rbxassetid://140311790133562"] = entityBehaviors.GodOFThree,  
    ["rbxassetid://140083448239444"] = entityBehaviors.GodOFFour,     
    ["rbxassetid://111351357978027"] = entityBehaviors.Z367Game,     
    ["rbxassetid://8325526433"] = entityBehaviors.A60Ps1,    
    ["rbxassetid://139308622787703"] = entityBehaviors.A60PS2,       
    ["rbxassetid://140731983342235"] = entityBehaviors.A500RUN,     
    ["rbxassetid://116898205685143"] = entityBehaviors.XBramble,    
    ["rbxassetid://7298463798"] = entityBehaviors.A200,      
    ["rbxassetid://4004052860"] = entityBehaviors.AMIN60,    
    ["rbxassetid://4903742660"] = entityBehaviors.Black60,
    ["rbxassetid://3308152153"] = entityBehaviors.ForstBite,
    ["rbxassetid://138586264525744"] = entityBehaviors.INGODONE,
    ["rbxassetid://124942412759969"] = entityBehaviors.Subspace,
    ["rbxassetid://118662411300943"] = entityBehaviors.INGODTWO,
    ["rbxassetid://140736591220630"] = entityBehaviors.DELALL,
    ["rbxassetid://140721035016341"] = entityBehaviors.Smiler, 
    ["rbxassetid://140719303781203"] = entityBehaviors.WhoopDaShoop,
    ["rbxassetid://9044461391"] = entityBehaviors.WhoopDaShoopTwo,
    ["rbxassetid://18926010713"] = entityBehaviors.ChainSmoker,
    ["rbxassetid://110532875373161"] = entityBehaviors.Deergod,
    ["rbxassetid://1079408535"] = entityBehaviors.LightSpeed,
    ["rbxassetid://93679208285508"] = entityBehaviors.A200Jump,
    ["rbxassetid://96703287490096"] = entityBehaviors.HUMANSW, 
    ["rbxassetid://140723850841863"] = entityBehaviors.EndRooms, 
    ["rbxassetid://140722528152072"] = entityBehaviors.Blast,
    ["rbxassetid://103515031866941"] = entityBehaviors.Cease, 
    ["rbxassetid://109318460496354"] = entityBehaviors.SHADOWSW, 
    ["rbxassetid://140690368868329"] = entityBehaviors.DeerGodJump, 
    ["rbxassetid://100192030036066"] = entityBehaviors.CL, 
    ["rbxassetid://9113115842"] = entityBehaviors.Shok,
    ["rbxassetid://92260310162120"] = entityBehaviors.MLcur,
    ["rbxassetid://83742851388096"] = entityBehaviors.Bombie,
    ["rbxassetid://8307248039"] = entityBehaviors.Booom,
    ["rbxassetid://109690961059477"] = entityBehaviors.LightOSs,
    ["rbxassetid://85554051164113"] = entityBehaviors.FigureXF,
    ["rbxassetid://80450670780109"] = entityBehaviors.SuperDread,
    ["rbxassetid://140701104317815"] = entityBehaviors.DreadJump,
    ["rbxassetid://50"] = entityBehaviors.LOOKSW,
    ["rbxassetid://104"] = entityBehaviors.DeergodDDH,      
    ["rbxassetid://135376180128296"] = entityBehaviors.Silence
}
local checkedEntities = {}

local function universalCheckSound(sound)
    if not sound:IsA("Sound") then return end

    local soundId = sound.SoundId
    local targetBehavior = entityConfig[soundId]

    if targetBehavior then
        local parent = sound.Parent
        if parent and parent.Name == "############" then
            local grandParent = parent.Parent
            if grandParent and grandParent.Name == "CustomEntity" then
                if not checkedEntities[grandParent] then
                    checkedEntities[grandParent] = true
                    targetBehavior()
                end
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    wait(0.1)
    universalCheckSound(obj)
end)

for _, entity in pairs(workspace:GetChildren()) do
    if entity.Name == "CustomEntity" then
        local scary = entity:FindFirstChild("############")
        if scary then
            for _, child in pairs(scary:GetChildren()) do
                universalCheckSound(child)
            end
        end
    end
end
local hint = Instance.new("Hint", Workspace)
hint.Text = "Loading... Doors HardCore V10.5 By Mr.key & HeavenNow :)"
game.Debris:AddItem(hint, 3)