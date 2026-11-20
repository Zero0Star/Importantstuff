if workspace:FindFirstChild("HardcoreFive") then
    return
end
local marker = Instance.new("BoolValue")
marker.Name = "HardcoreFive"
marker.Value = true
marker.Parent = workspace
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()
local entityBehaviors = {}

function entityBehaviors.Mush()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local MODEL_ID = "rbxassetid://79993520223456"

local SPAWN_DELAY = 5
local SPAWN_HEIGHT = 5.5

local RISE_HEIGHT = 9
local RISE_DURATION = 5
local DESCEND_DURATION = 5

local SHAKE_MAGNITUDE = 0.12
local SHAKE_ROUGHNESS = 8
local SHAKE_FADE_TIME = 1

local FOG_DELAY = 7

local MUSIC_FADE_IN = 2
local MUSIC_FADE_OUT = 2

local DISAPPEAR_DELAY = 10
local DISAPPEAR_DURATION = 1.5

local DARKNESS_DURATION = 18
local RECOVERY_DURATION = 2.5
local DAMAGE_AMOUNT = 200
local SPEED_REDUCTION = 0.85

local MOVE_SOUND_ID = "rbxassetid://87388390529602"
local FOG_SOUND_ID = "rbxassetid://4772620521"
local AMBIENT_SOUND_ID = "rbxassetid://112638428800232"

local phantomImages = {
    "rbxassetid://11380666994",
    "rbxassetid://9718225621",
    "rbxassetid://1188034146"
}

local function smoothstep(value)
    value = math.clamp(value, 0, 1)
    return value * value * (3 - 2 * value)
end

local function playOneShot(soundId, playbackSpeed, onEnded)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 1
    sound.PlaybackSpeed = playbackSpeed or 1
    sound.Looped = false
    sound.Parent = SoundService

    sound.Ended:Once(function()
        sound:Destroy()

        if onEnded then
            onEnded()
        end
    end)

    sound:Play()

    return sound
end

local function fadeOutSound(sound, duration)
    if not sound or not sound.Parent then
        return
    end

    local tween = TweenService:Create(
        sound,
        TweenInfo.new(
            duration,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out
        ),
        {
            Volume = 0
        }
    )

    tween.Completed:Once(function()
        if sound.Parent then
            sound:Stop()
            sound:Destroy()
        end
    end)

    tween:Play()
end

local function createVisionEffects()
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MushHallucinationEffects"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local darkness = Instance.new("Frame")
    darkness.Name = "Darkness"
    darkness.Size = UDim2.fromScale(1, 1)
    darkness.Position = UDim2.fromScale(0, 0)
    darkness.BackgroundColor3 = Color3.new(0, 0, 0)
    darkness.BackgroundTransparency = 1
    darkness.BorderSizePixel = 0
    darkness.ZIndex = 5
    darkness.Parent = screenGui

    local edges = {}

    local function createEdge(name, position, size, rotation)
        local edge = Instance.new("Frame")
        edge.Name = name
        edge.Position = position
        edge.Size = size
        edge.BackgroundColor3 = Color3.new(0, 0, 0)
        edge.BackgroundTransparency = 1
        edge.BorderSizePixel = 0
        edge.ZIndex = 6
        edge.Parent = screenGui

        local gradient = Instance.new("UIGradient")
        gradient.Rotation = rotation
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.25, 0.08),
            NumberSequenceKeypoint.new(0.6, 0.48),
            NumberSequenceKeypoint.new(1, 1)
        })
        gradient.Parent = edge

        table.insert(edges, edge)
    end

    createEdge(
        "Left",
        UDim2.fromScale(0, 0),
        UDim2.fromScale(0.48, 1),
        0
    )

    createEdge(
        "Right",
        UDim2.fromScale(0.52, 0),
        UDim2.fromScale(0.48, 1),
        180
    )

    createEdge(
        "Top",
        UDim2.fromScale(0, 0),
        UDim2.fromScale(1, 0.48),
        90
    )

    createEdge(
        "Bottom",
        UDim2.fromScale(0, 0.52),
        UDim2.fromScale(1, 0.48),
        270
    )

    local blur = Instance.new("BlurEffect")
    blur.Name = "MushVisionBlur"
    blur.Size = 0
    blur.Parent = Lighting

    local colorEffect = Instance.new("ColorCorrectionEffect")
    colorEffect.Name = "MushVisionColor"
    colorEffect.Brightness = 0
    colorEffect.Contrast = 0
    colorEffect.Saturation = 0
    colorEffect.Parent = Lighting

    local function applyVision(strength)
        strength = math.clamp(strength, 0, 1)

        darkness.BackgroundTransparency = 1 - strength * 0.27

        for _, edge in ipairs(edges) do
            edge.BackgroundTransparency = 1 - strength * 0.98
        end

        blur.Size = strength * 9
        colorEffect.Brightness = -strength * 0.12
        colorEffect.Contrast = strength * 0.18
        colorEffect.Saturation = -strength * 0.7
    end

    local function createPhantom()
        if not screenGui.Parent then
            return
        end

        local side = math.random(1, 2)
        local x

        if side == 1 then
            x = math.random(8, 38) / 100
        else
            x = math.random(62, 92) / 100
        end

        local y = math.random(25, 75) / 100

        local ghost = Instance.new("ImageLabel")
        ghost.Name = "Phantom"
        ghost.AnchorPoint = Vector2.new(0.5, 0.5)
        ghost.Position = UDim2.fromScale(x, y)
        ghost.Size = UDim2.fromOffset(
            math.random(130, 210),
            math.random(180, 280)
        )
        ghost.BackgroundTransparency = 1
        ghost.Image = phantomImages[
            math.random(1, #phantomImages)
        ]
        ghost.ImageTransparency = 1
        ghost.ImageColor3 = Color3.fromRGB(190, 195, 215)
        ghost.ScaleType = Enum.ScaleType.Fit
        ghost.ZIndex = 8
        ghost.Parent = screenGui

        local targetTransparency = math.random(35, 60) / 100

        local appearTween = TweenService:Create(
            ghost,
            TweenInfo.new(
                0.18,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            ),
            {
                ImageTransparency = targetTransparency
            }
        )

        appearTween:Play()

        local driftTween = TweenService:Create(
            ghost,
            TweenInfo.new(
                1.5,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            ),
            {
                Position = UDim2.fromScale(
                    x + math.random(-4, 4) / 100,
                    y - math.random(2, 6) / 100
                )
            }
        )

        driftTween:Play()

        task.spawn(function()
            task.wait(math.random(15, 35) / 100)

            if not ghost.Parent then
                return
            end

            for i = 1, math.random(1, 3) do
                ghost.ImageTransparency = math.min(
                    1,
                    targetTransparency + 0.35
                )

                task.wait(0.06)

                if not ghost.Parent then
                    return
                end

                ghost.ImageTransparency = targetTransparency

                task.wait(0.08)
            end

            task.wait(0.3)

            if ghost.Parent then
                local disappearTween = TweenService:Create(
                    ghost,
                    TweenInfo.new(
                        0.75,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.Out
                    ),
                    {
                        ImageTransparency = 1
                    }
                )

                disappearTween:Play()
                disappearTween.Completed:Wait()

                if ghost.Parent then
                    ghost:Destroy()
                end
            end
        end)
    end

    local function destroyEffects()
        if screenGui.Parent then
            screenGui:Destroy()
        end

        if blur.Parent then
            blur:Destroy()
        end

        if colorEffect.Parent then
            colorEffect:Destroy()
        end
    end

    return applyVision, createPhantom, destroyEffects
end

task.spawn(function()
    local currentRooms = workspace:WaitForChild("CurrentRooms")

    if workspace:FindFirstChild("SeekMovingNewClone")
        or currentRooms:FindFirstChild("50") then
        return
    end

    local latestRoom = ReplicatedStorage
        :WaitForChild("GameData")
        :WaitForChild("LatestRoom")

    local objects = game:GetObjects(MODEL_ID)
    local model = objects[1]

    if not model then
        return
    end

    local room = currentRooms:FindFirstChild(
        tostring(latestRoom.Value)
    )

    if not room then
        model:Destroy()
        return
    end

    local nodeFolder = room:FindFirstChild("Nodes")
        or room:FindFirstChild("PathfindNodes")

    local spawnPart

    if nodeFolder then
        local nodes = {}

        for _, node in ipairs(nodeFolder:GetChildren()) do
            if node:IsA("BasePart") then
                table.insert(nodes, node)
            end
        end

        table.sort(nodes, function(a, b)
            local na = tonumber(a.Name)
            local nb = tonumber(b.Name)

            if na and nb then
                return na < nb
            elseif na then
                return true
            elseif nb then
                return false
            end

            return a.Name < b.Name
        end)

        local middle = math.max(
            1,
            math.floor(#nodes / 2)
        )

        spawnPart = nodes[middle]
    end

    if not spawnPart then
        for _, name in ipairs({
            room.Name,
            "RoomEntrance",
            "RoomExit"
        }) do
            local candidate = room:FindFirstChild(name)

            if candidate and candidate:IsA("BasePart") then
                spawnPart = candidate
                break
            end
        end

        if not spawnPart then
            spawnPart = room.PrimaryPart
        end
    end

    if not spawnPart then
        model:Destroy()
        return
    end

    model.Parent = workspace

    model:PivotTo(
        spawnPart.CFrame + Vector3.new(0, SPAWN_HEIGHT, 0)
    )

    local mush = model:FindFirstChild("Mush", true)
    local lowFog = model:FindFirstChild("LowFog", true)
    local fog = lowFog and lowFog:FindFirstChild("Fog")

    if not mush or not mush:IsA("MeshPart") then
        warn("Mush MeshPart not found")
        model:Destroy()
        return
    end

    if not fog then
        warn("LowFog.Fog not found")
        model:Destroy()
        return
    end

    mush.Anchored = true

    local CameraShaker = require(
        ReplicatedStorage:WaitForChild("CameraShaker")
    )

    local shaker = CameraShaker.new(
        Enum.RenderPriority.Camera.Value,
        function(shakeCFrame)
            local camera = workspace.CurrentCamera

            if camera then
                camera.CFrame = camera.CFrame * shakeCFrame
            end
        end
    )

    task.wait(SPAWN_DELAY)

    local riseTween = TweenService:Create(
        mush,
        TweenInfo.new(
            RISE_DURATION,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out
        ),
        {
            CFrame = mush.CFrame
                + Vector3.new(0, RISE_HEIGHT, 0)
        }
    )

    shaker:Start()

    local shakeInstance = shaker:StartShake(
        SHAKE_MAGNITUDE,
        SHAKE_ROUGHNESS,
        0
    )

    playOneShot(MOVE_SOUND_ID, 0.8)

    riseTween:Play()

    task.delay(
        math.max(0, RISE_DURATION - SHAKE_FADE_TIME),
        function()
            if shakeInstance
                and riseTween.PlaybackState
                    == Enum.PlaybackState.Playing then

                shakeInstance:StartFadeOut(
                    SHAKE_FADE_TIME
                )
            end
        end
    )

    riseTween.Completed:Wait()

    shaker:Stop()

    task.wait(FOG_DELAY)

    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    local originalWalkSpeed = humanoid
        and humanoid.WalkSpeed or 16

    local applyVision, createPhantom, destroyEffects =
        createVisionEffects()

    local exitTriggered = false
    local damageApplied = false

    local recovering = false
    local recoveryStart = 0
    local recoveryFrom = 0

    local visionStrength = 0
    local effectStart = 0

    local ambientSound = nil
    local ambientFadeInTween = nil
    local renderConnection

    local function updateWalkSpeed(strength)
        if humanoid and humanoid.Parent
            and humanoid.Health > 0 then

            humanoid.WalkSpeed =
                originalWalkSpeed * (1 - SPEED_REDUCTION * strength)
        end
    end

    fog.Enabled = true

    effectStart = os.clock()

    task.delay(DARKNESS_DURATION, function()
        if not exitTriggered and not damageApplied then
            damageApplied = true

            if humanoid and humanoid.Parent
                and humanoid.Health > 0 then

                humanoid:TakeDamage(DAMAGE_AMOUNT)
            end
        end
    end)

    playOneShot(FOG_SOUND_ID, 1, function()
        if exitTriggered then
            return
        end

        ambientSound = Instance.new("Sound")
        ambientSound.SoundId = AMBIENT_SOUND_ID
        ambientSound.Volume = 0
        ambientSound.PlaybackSpeed = 1
        ambientSound.Looped = true
        ambientSound.Parent = SoundService

        ambientSound:Play()

        ambientFadeInTween = TweenService:Create(
            ambientSound,
            TweenInfo.new(
                MUSIC_FADE_IN,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            ),
            {
                Volume = 1
            }
        )

        ambientFadeInTween:Play()
    end)

    renderConnection = RunService.RenderStepped:Connect(function()
        if recovering then
            local elapsed = os.clock() - recoveryStart

            local progress = math.clamp(
                elapsed / RECOVERY_DURATION,
                0,
                1
            )

            local eased = smoothstep(progress)

            visionStrength = recoveryFrom * (1 - eased)

            applyVision(visionStrength)
            updateWalkSpeed(visionStrength)

            if progress >= 1 then
                applyVision(0)

                if humanoid and humanoid.Parent then
                    humanoid.WalkSpeed = originalWalkSpeed
                end

                renderConnection:Disconnect()
                destroyEffects()
            end

            return
        end

        local elapsed = os.clock() - effectStart

        local progress = math.clamp(
            elapsed / DARKNESS_DURATION,
            0,
            1
        )

        visionStrength = smoothstep(progress)

        applyVision(visionStrength)
        updateWalkSpeed(visionStrength)
    end)

    task.spawn(function()
        while not exitTriggered do
            local interval = 2.5 - visionStrength * 1.5

            task.wait(math.max(0.8, interval))

            if exitTriggered then
                break
            end

            if visionStrength >= 0.16 then
                createPhantom()

                if visionStrength >= 0.7
                    and math.random() < 0.35 then

                    task.delay(0.25, function()
                        if not exitTriggered then
                            createPhantom()
                        end
                    end)
                end
            end
        end
    end)

    latestRoom.Changed:Wait()

    exitTriggered = true

    recovering = true
    recoveryStart = os.clock()
    recoveryFrom = visionStrength

    if ambientFadeInTween then
        ambientFadeInTween:Cancel()
    end

    if ambientSound and ambientSound.Parent then
        fadeOutSound(ambientSound, MUSIC_FADE_OUT)
    end

    local descendTween = TweenService:Create(
        mush,
        TweenInfo.new(
            DESCEND_DURATION,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        ),
        {
            CFrame = mush.CFrame
                - Vector3.new(0, RISE_HEIGHT, 0)
        }
    )

    playOneShot(MOVE_SOUND_ID, 0.8)

    descendTween:Play()
    descendTween.Completed:Wait()

    fog.Enabled = false

    task.wait(DISAPPEAR_DELAY)

    local disappearInfo = TweenInfo.new(
        DISAPPEAR_DURATION,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out
    )

    local disappearTweens = {}

    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("BasePart")
            or object:IsA("Decal")
            or object:IsA("Texture") then

            local tween = TweenService:Create(
                object,
                disappearInfo,
                {
                    Transparency = 1
                }
            )

            table.insert(disappearTweens, tween)
        end
    end

    for _, tween in ipairs(disappearTweens) do
        tween:Play()
    end

    if #disappearTweens > 0 then
        disappearTweens[1].Completed:Wait()
    end

    model:Destroy()
end)
end

function entityBehaviors.Happy()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local CONFIG = {
    MODEL_ID = 72292591411637,
    END_SOUND_ID = "rbxassetid://127327591850649",
    HEIGHT_OFFSET = 0,
    SPAWN_SOUND_AT = 5,
    MOVE_AT = 10,
    START_SPEED = 500,
    BOUNCE_START_SPEED = 50,
    MAX_SPEED = 1000,
    ROUND_TRIPS = 30,
    DAMAGE = 125,
    DAMAGE_RANGE = 50,
    RAY_SAMPLE_STEP = 5,
    BLACKOUT_DURATION = 1,
    CEASE_SLOW_TIME = 2.25,
    CEASE_HOLD_TIME = 13,
    CEASE_RESUME_TIME = 2,
    END_SOUND_VOLUME = 1,
    SHAKE_RANGE = 80,
    SHAKE_INTERVAL = 0.12,
}

local EPSILON = 0.00001
local isServer = RunService:IsServer()
local monster = nil
local disposed = false
local spawnSound = nil
local modelDescendantConnection = nil
local proximityShaker = nil
local proximityShakeConnection = nil
local ceaseScale = 1
local ceaseActive = false
local ceaseStartedAt = 0
local ceaseEffects = {}
local ceaseConnection = nil
local handledCease = setmetatable({}, { __mode = "k" })
local damagedHumanoids = setmetatable({}, { __mode = "k" })

local function isAlive()
    return not disposed and monster ~= nil and monster.Parent ~= nil
end

local function stopProximityShake()
    if proximityShakeConnection then
        proximityShakeConnection:Disconnect()
        proximityShakeConnection = nil
    end
    if proximityShaker then
        local shaker = proximityShaker
        proximityShaker = nil
        pcall(function()
            shaker:Stop()
        end)
    end
end

local function startProximityShake()
    if isServer or proximityShaker or not isAlive() then
        return
    end

    local module = game:GetService("ReplicatedStorage"):FindFirstChild("CameraShaker")
    if not module then
        return
    end

    local loaded, CameraShakerModule = pcall(require, module)
    if not loaded or not isAlive() then
        return
    end

    local started = pcall(function()
        proximityShaker = CameraShakerModule.new(
            Enum.RenderPriority.Camera.Value + 1,
            function(shakerTransform)
                local camera = workspace.CurrentCamera
                if camera then
                    camera.CFrame = camera.CFrame * shakerTransform
                end
            end
        )
        proximityShaker:Start()
    end)
    if not started or not isAlive() then
        stopProximityShake()
        return
    end

    local lastProximityShake = 0
    proximityShakeConnection = RunService.RenderStepped:Connect(function()
        if not isAlive() then
            stopProximityShake()
            return
        end

        local player = Players.LocalPlayer
        local character = player and player.Character
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not rootPart or not rootPart:IsA("BasePart") then
            return
        end

        local distance = (monster:GetPivot().Position - rootPart.Position).Magnitude
        local now = os.clock()
        if distance > CONFIG.SHAKE_RANGE or now - lastProximityShake < CONFIG.SHAKE_INTERVAL then
            return
        end

        local alpha = math.clamp(1 - distance / CONFIG.SHAKE_RANGE, 0, 1)
        local amplitude = (0.3 + 8.2 * (alpha ^ 1.35)) * 3
        local roughness = 45 + 35 * alpha
        local positionInfluence = 0.35 + 0.4 * alpha
        local rotationInfluence = 0.3 + 0.4 * alpha

        lastProximityShake = now
        local shaken = pcall(function()
            proximityShaker:ShakeOnce(
                amplitude,
                roughness,
                0.01,
                0.16,
                positionInfluence,
                rotationInfluence
            )
        end)
        if not shaken then
            stopProximityShake()
        end
    end)
end

local function darkenRoomLights()
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not rooms then
        return
    end

    local states = {}
    local fixtureNames = {
        Chandelier = true,
        Light_Fixtures = true,
        LoadedChandelier_New = true,
    }

    for _, room in ipairs(rooms:GetChildren()) do
        local assets = room:IsA("Model") and room:FindFirstChild("Assets")
        if assets then
            for _, fixture in ipairs(assets:GetChildren()) do
                if fixtureNames[fixture.Name] then
                    for _, object in ipairs(fixture:GetDescendants()) do
                        if object:IsA("Light") then
                            table.insert(states, {
                                Object = object, Kind = "Light",
                                Color = object.Color, Brightness = object.Brightness,
                            })
                        elseif object:IsA("Beam") then
                            table.insert(states, {
                                Object = object, Kind = "Beam", Color = object.Color,
                            })
                        elseif object:IsA("BasePart") and (
                            object.Name == "Neon"
                            or object.Name == "Ok you cannot tell me this isnt good"
                        ) then
                            table.insert(states, {
                                Object = object, Kind = "Part", Color = object.Color,
                            })
                        end
                    end
                end
            end
        end
    end

    task.spawn(function()
        local startedAt = os.clock()
        local black = Color3.new(0, 0, 0)
        while true do
            local alpha = math.clamp(
                (os.clock() - startedAt) / CONFIG.BLACKOUT_DURATION, 0, 1
            )
            for _, state in ipairs(states) do
                local object = state.Object
                if object.Parent then
                    if state.Kind == "Beam" then
                        local points = {}
                        for _, keypoint in ipairs(state.Color.Keypoints) do
                            table.insert(points, ColorSequenceKeypoint.new(
                                keypoint.Time, keypoint.Value:Lerp(black, alpha)
                            ))
                        end
                        object.Color = ColorSequence.new(points)
                    else
                        object.Color = state.Color:Lerp(black, alpha)
                        if state.Kind == "Light" then
                            object.Brightness = state.Brightness * (1 - alpha)
                        end
                    end
                end
            end
            if alpha >= 1 then
                return
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

local function getOrderedRooms()
    local rooms = workspace:FindFirstChild("CurrentRooms")
    assert(rooms, "找不到 workspace.CurrentRooms")
    local result = {}
    for _, room in ipairs(rooms:GetChildren()) do
        local number = tonumber(room.Name)
        if room:IsA("Model") and number then
            table.insert(result, { Number = number, Room = room })
        end
    end
    table.sort(result, function(a, b)
        return a.Number < b.Number
    end)
    return result
end

local function getOrderedNodes(folder)
    local nodes = {}
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("BasePart") then
                table.insert(nodes, child)
            end
        end
    end
    table.sort(nodes, function(a, b)
        local numberA, numberB = tonumber(a.Name), tonumber(b.Name)
        if numberA and numberB and numberA ~= numberB then
            return numberA < numberB
        elseif numberA and not numberB then
            return true
        elseif numberB and not numberA then
            return false
        end
        return a.Name < b.Name
    end)
    return nodes
end

local function captureRoute()
    local rooms = getOrderedRooms()
    assert(#rooms > 0, "CurrentRooms 内没有数字命名的房间")

    local startIndex = #rooms > 10 and (#rooms - 8) or 1
    local endIndex = math.max(1, #rooms - 1)
    local route = {}
    local rayExclusions = {}
    local heightOffset = Vector3.new(0, CONFIG.HEIGHT_OFFSET, 0)

    for index = startIndex, endIndex do
        local room = rooms[index].Room
        local folder = room:FindFirstChild("PathfindNodes")
        local nodes = getOrderedNodes(folder)
        if folder then
            table.insert(rayExclusions, folder)
        end
        if #nodes == 0 then
            local exit = room:FindFirstChild("RoomExit")
            assert(exit and exit:IsA("BasePart"),
                "房间 " .. room.Name .. " 缺少 PathfindNodes 和 RoomExit")
            nodes = { exit }
            table.insert(rayExclusions, exit)
        end
        for _, node in ipairs(nodes) do
            local target = node.CFrame + heightOffset
            local previous = route[#route]

            if previous and (previous.Position - target.Position).Magnitude <= EPSILON then
                route[#route] = target
            else
                table.insert(route, target)
            end
        end
    end

    assert(#route >= 2, "至少需要两个不同位置的路径点，才能执行终点往返")

    return route, rayExclusions
end

local function loadWholeModel()
    local objects
    if isServer then
        objects = { game:GetService("AssetService"):LoadAssetAsync(CONFIG.MODEL_ID) }
    else
        objects = game:GetObjects("rbxassetid://" .. tostring(CONFIG.MODEL_ID))
    end

    assert(objects and #objects > 0, "模型资源为空")
    local pivotSource = nil
    if #objects == 1 and objects[1]:IsA("Model") then
        monster = objects[1]
        local children = monster:GetChildren()
        if isServer and #children == 1 and children[1]:IsA("Model") then
            pivotSource = children[1]
        end
    else
        monster = Instance.new("Model")
        for _, object in ipairs(objects) do
            if not pivotSource and object:IsA("Model") then
                pivotSource = object
            end
            object.Parent = monster
        end
    end

    monster.Name = "Happy"
    assert(monster:FindFirstChildWhichIsA("BasePart", true), "怪物模型内没有 BasePart")
    if pivotSource and not monster.PrimaryPart then
        if pivotSource.PrimaryPart then
            monster.PrimaryPart = pivotSource.PrimaryPart
        else
            monster.WorldPivot = pivotSource:GetPivot()
        end
    end

    local function prepareObject(object)
        if object:IsA("BasePart") then
            object.Anchored = true
            object.CanCollide = false
        elseif object:IsA("Sound") and object.Name == "Spwan" and not spawnSound then
            spawnSound = object
            object:Stop()
            object.Looped = false
            object.TimePosition = 0
        end
    end
    modelDescendantConnection = monster.DescendantAdded:Connect(prepareObject)
    for _, object in ipairs(monster:GetDescendants()) do
        prepareObject(object)
    end
end

local function applyEffectScale(object, saved, scale)
    if not object.Parent then
        return
    end
    if saved.Kind == "Particle" then
        object.TimeScale = saved.TimeScale * scale
    else
        object.Volume = saved.Volume * scale
        if scale <= EPSILON then

            if object.IsPlaying then
                saved.PausedByCease = true
                object:Pause()
            end
        else
            object.PlaybackSpeed = math.max(0.01, saved.PlaybackSpeed * scale)
            if saved.PausedByCease then
                saved.PausedByCease = false
                object:Resume()
            end
        end
    end
end

local function trackCeaseEffect(object)
    if ceaseEffects[object] then
        return
    end
    if object:IsA("ParticleEmitter") then
        ceaseEffects[object] = { Kind = "Particle", TimeScale = object.TimeScale }
    elseif object:IsA("Sound") then
        ceaseEffects[object] = {
            Kind = "Sound", Volume = object.Volume,
            PlaybackSpeed = object.PlaybackSpeed, PausedByCease = false,
        }
    end
    if ceaseEffects[object] then
        applyEffectScale(object, ceaseEffects[object], ceaseScale)
    end
end

local function cancelCeaseFreeze()
    if ceaseConnection then
        ceaseConnection:Disconnect()
        ceaseConnection = nil
    end
    for object, saved in pairs(ceaseEffects) do
        if object.Parent then
            applyEffectScale(object, saved, 1)
            if saved.Kind == "Sound" then
                object.PlaybackSpeed = saved.PlaybackSpeed
            end
        end
    end
    ceaseEffects = {}
    ceaseScale = 1
    ceaseActive = false
end

local function easeCease(alpha)
    alpha = math.clamp(alpha, 0, 1)
    return alpha * alpha * (3 - 2 * alpha)
end

local function updateCeaseFreeze(canStart)
    if not ceaseActive and canStart then
        local cease = workspace:FindFirstChild("Cease", true)
        if cease and cease:IsA("Model") and not handledCease[cease] then
            handledCease[cease] = true
            ceaseActive = true
            ceaseStartedAt = os.clock()
            for _, object in ipairs(monster:GetDescendants()) do
                trackCeaseEffect(object)
            end
            ceaseConnection = monster.DescendantAdded:Connect(trackCeaseEffect)
        end
    end

    if not ceaseActive then
        return
    end
    local elapsed = os.clock() - ceaseStartedAt
    local slowEnd = CONFIG.CEASE_SLOW_TIME
    local holdEnd = slowEnd + CONFIG.CEASE_HOLD_TIME
    local resumeEnd = holdEnd + CONFIG.CEASE_RESUME_TIME
    if elapsed < slowEnd then
        ceaseScale = 1 - easeCease(elapsed / CONFIG.CEASE_SLOW_TIME)
    elseif elapsed < holdEnd then
        ceaseScale = 0
    elseif elapsed < resumeEnd then
        ceaseScale = easeCease((elapsed - holdEnd) / CONFIG.CEASE_RESUME_TIME)
    else
        cancelCeaseFreeze()
        return
    end
    for object, saved in pairs(ceaseEffects) do
        applyEffectScale(object, saved, ceaseScale)
    end
end

local function rayEntryDistanceToPart(origin, directionUnit, part)
    local localOrigin = part.CFrame:PointToObjectSpace(origin)
    local localDirection = part.CFrame:VectorToObjectSpace(directionUnit)
    local half = part.Size * 0.5
    local entry, exit = 0, math.huge
    for _, axis in ipairs({ "X", "Y", "Z" }) do
        local position, velocity, extent = localOrigin[axis], localDirection[axis], half[axis]
        if math.abs(velocity) < EPSILON then
            if position < -extent or position > extent then
                return nil
            end
        else
            local near = (-extent - position) / velocity
            local far = (extent - position) / velocity
            if near > far then
                near, far = far, near
            end
            entry = math.max(entry, near)
            exit = math.min(exit, far)
            if exit < entry then
                return nil
            end
        end
    end
    return entry
end

local function collectDamageTargets()
    local targets = {}
    local players = isServer and Players:GetPlayers() or { Players.LocalPlayer }
    for _, player in ipairs(players) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and root and root:IsA("BasePart") and humanoid.Health > 0
            and not damagedHumanoids[humanoid] and not character:GetAttribute("Hiding") then
            local parts = { root }
            for _, name in ipairs({ "Head", "UpperTorso", "Torso", "LowerTorso" }) do
                local part = character:FindFirstChild(name)
                if part and part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
            table.insert(targets, {
                Character = character, Humanoid = humanoid, Root = root, Parts = parts,
            })
        end
    end
    return targets
end

local function damageFrom(origin, targets, rayParams)
    for _, target in ipairs(targets) do
        local humanoid, character = target.Humanoid, target.Character
        if humanoid.Parent and humanoid.Health > 0 and target.Root.Parent
            and not damagedHumanoids[humanoid] and not character:GetAttribute("Hiding")
            and (target.Root.Position - origin).Magnitude <= CONFIG.DAMAGE_RANGE then
            for _, part in ipairs(target.Parts) do
                if part.Parent then
                    local direction = part.Position - origin
                    local distance = direction.Magnitude
                    local visible = distance <= EPSILON
                    if distance > EPSILON and distance <= CONFIG.DAMAGE_RANGE then
                        local result = workspace:Raycast(origin, direction, rayParams)
                        visible = result ~= nil and result.Instance:IsDescendantOf(character)
                        if not visible then
                            local entry = rayEntryDistanceToPart(origin, direction.Unit, part)
                            visible = entry ~= nil and entry <= distance + 0.01
                                and (not result or result.Distance > entry + 0.02)
                        end
                    end
                    if visible then
                        damagedHumanoids[humanoid] = true
                        humanoid:TakeDamage(CONFIG.DAMAGE)
                        break
                    end
                end
            end
        end
    end
end

local function scanTravel(fromPosition, toPosition, targets, rayParams)
    local distance = (toPosition - fromPosition).Magnitude
    local samples = math.max(1, math.ceil(distance / CONFIG.RAY_SAMPLE_STEP))
    for index = 0, samples do
        damageFrom(fromPosition:Lerp(toPosition, index / samples), targets, rayParams)
    end
end

local function buildSegments(route)
    local segments = {}
    for index = 2, #route do
        table.insert(segments, { Target = route[index], Speed = CONFIG.START_SPEED })
    end

    local previousPoint, finalPoint = route[#route - 1], route[#route]
    local totalLegs = CONFIG.ROUND_TRIPS * 2
    for leg = 1, totalLegs do
        local alpha = totalLegs > 1 and ((leg - 1) / (totalLegs - 1)) or 0
        table.insert(segments, {
            Target = leg % 2 == 1 and previousPoint or finalPoint,
            Speed = CONFIG.BOUNCE_START_SPEED + (CONFIG.MAX_SPEED - CONFIG.BOUNCE_START_SPEED) * alpha,
        })
    end
    return segments
end

local function runMovement(route, rayExclusions)
    local segments = buildSegments(route)
    local segmentIndex = 1
    table.insert(rayExclusions, monster)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = rayExclusions

    while isAlive() and segmentIndex <= #segments do
        local deltaTime = RunService.Heartbeat:Wait()
        if not isAlive() then
            break
        end
        updateCeaseFreeze(segmentIndex <= #segments)
        local targets = collectDamageTargets()
        local timeLeft = deltaTime

        damageFrom(monster:GetPivot().Position, targets, rayParams)
        while timeLeft > EPSILON and ceaseScale > EPSILON and segmentIndex <= #segments do
            local segment = segments[segmentIndex]
            local from = monster:GetPivot()
            local distance = (segment.Target.Position - from.Position).Magnitude
            if distance <= EPSILON then
                monster:PivotTo(segment.Target)
                segmentIndex = segmentIndex + 1
            else
                local speed = segment.Speed * ceaseScale
                local travel = math.min(distance, speed * timeLeft)
                local destination = from:Lerp(segment.Target, travel / distance)
                scanTravel(from.Position, destination.Position, targets, rayParams)
                monster:PivotTo(destination)
                timeLeft = math.max(0, timeLeft - travel / speed)
                if travel >= distance then
                    segmentIndex = segmentIndex + 1
                end
            end
        end

    end
    return isAlive() and segmentIndex > #segments
end

local function waitUntil(spawnedAt, seconds)
    while isAlive() and os.clock() - spawnedAt < seconds do
        RunService.Heartbeat:Wait()
    end
    return isAlive()
end

local function playFinalSound()
    local sound = Instance.new("Sound")
    sound.Name = "HappyFinalSound"
    sound.SoundId = CONFIG.END_SOUND_ID
    sound.Volume = CONFIG.END_SOUND_VOLUME
    sound.Looped = false
    sound.PlayOnRemove = false

    sound.Parent = SoundService
    sound.Ended:Once(function()
        sound:Destroy()
    end)
    sound:Play()

    task.delay(30, function()
        if sound.Parent and not sound.IsLoaded then
            sound:Destroy()
        end
    end)
end

local function cleanup()
    disposed = true
    stopProximityShake()
    if modelDescendantConnection then
        modelDescendantConnection:Disconnect()
        modelDescendantConnection = nil
    end
    cancelCeaseFreeze()
    if monster then
        monster:Destroy()
        monster = nil
    end
end

local function run()
    loadWholeModel()
    local route, rayExclusions = captureRoute()
    monster:PivotTo(route[1])
    monster.Parent = workspace
    local spawnedAt = os.clock()
    darkenRoomLights()
    task.spawn(startProximityShake)

    task.spawn(function()
        local assets = { CONFIG.END_SOUND_ID }
        for _, object in ipairs(monster:GetDescendants()) do
            if object:IsA("Sound") then
                table.insert(assets, object)
            end
        end

        pcall(function()
            ContentProvider:PreloadAsync(assets)
        end)
    end)

    if not waitUntil(spawnedAt, CONFIG.SPAWN_SOUND_AT) then
        return
    end
    if spawnSound and spawnSound.Parent then
        spawnSound.Looped = false
        spawnSound.TimePosition = 0
        spawnSound.Playing = true
    end
    if not waitUntil(spawnedAt, CONFIG.MOVE_AT) then
        return
    end

    if runMovement(route, rayExclusions) then
        cleanup()
        playFinalSound()
    end
end

pcall(run)
if not disposed then
    cleanup()
end
end
function entityBehaviors.Z19()
loadstring(game:HttpGet("https://raw.githubusercontent.com/idkman60093/Custom-Entity/refs/heads/main/Questioner-Entity"))()
end

function entityBehaviors.Bear()
local neededFiles = {}
for i = 1, 20 do
    local n = string.format("%03d", i)
    table.insert(neededFiles, "Fredscare/ezgif-frame-" .. n .. ".png")
end
table.insert(neededFiles, "Fredbear.rbxmx")

local cleanupSteps = {}
local cleaned = false

local function registerCleanup(callback)
    if cleaned then
        pcall(callback)
    else
        table.insert(cleanupSteps, callback)
    end
end

local function own(instance)
    if instance then
        registerCleanup(function() instance:Destroy() end)
    end
    return instance
end

local function trackConnection(connection)
    registerCleanup(function() connection:Disconnect() end)
    return connection
end

local function cleanup()
    if cleaned then return end
    cleaned = true
    for i = #cleanupSteps, 1, -1 do
        pcall(cleanupSteps[i])
    end
    if type(delfile) == "function" and type(isfile) == "function" then
        for _, path in ipairs(neededFiles) do
            pcall(function()
                if isfile(path) then delfile(path) end
            end)
        end
    end
end

local function ensureFredbearFiles()

    local hasFiles = true
    for _, file in ipairs(neededFiles) do
        if not isfile(file) then
            hasFiles = false
            break
        end
    end
    if hasFiles then return end

    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    if cleaned then return end
    local screenGui = own(Instance.new("ScreenGui"))
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.Parent = screenGui

    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 50)
    loadingText.Position = UDim2.new(0, 0, 0.3, 0)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading..."
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextScaled = true
    loadingText.Parent = frame

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, 0, 0, 30)
    infoText.Position = UDim2.new(0, 0, 0.48, 0)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Loading assets..."
    infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoText.TextScaled = true
    infoText.Parent = frame

    local barBackground = Instance.new("Frame")
    barBackground.AnchorPoint = Vector2.new(0.5, 0.5)
    barBackground.Position = UDim2.new(0.5, 0, 0.8, 0)
    barBackground.Size = UDim2.new(0.6, 0, 0.05, 0)
    barBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    barBackground.Parent = frame

    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 12)
    backgroundCorner.Parent = barBackground

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 230, 0)
    bar.Parent = barBackground

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 12)
    barCorner.Parent = bar

    if not isfolder("Fredscare") then makefolder("Fredscare") end
    local total, count = 21, 0
    local function updateBar()
        bar.Size = UDim2.new(count / total, 0, 1, 0)
    end
    for i = 1, 20 do
        local n = string.format("%03d", i)
        local path = "Fredscare/ezgif-frame-" .. n .. ".png"
        if cleaned then return end
        if not isfile(path) then
            local content = game:HttpGet("https://raw.githubusercontent.com/ian49972/IMAGES/refs/heads/main/ezgif-frame-" .. n .. ".png")
            if cleaned then return end
            writefile(path, content)
            if cleaned then
                if type(delfile) == "function" then pcall(delfile, path) end
                return
            end
        end
        count = count + 1
        updateBar()
    end
    if cleaned then return end
    if not isfile("Fredbear.rbxmx") then
        local content = game:HttpGet("https://raw.githubusercontent.com/ian49972/RBXMS/refs/heads/main/Fredbear.rbxmx")
        if cleaned then return end
        writefile("Fredbear.rbxmx", content)
        if cleaned then
            if type(delfile) == "function" then pcall(delfile, "Fredbear.rbxmx") end
            return
        end
    end
    count = count + 1
    updateBar()
    screenGui:Destroy()
end

local function runFredbear()
ensureFredbearFiles()
if cleaned then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
if cleaned then return end

local NPC = own(game:GetObjects(getcustomasset("Fredbear.rbxmx"))[1])
if cleaned or not NPC then return end
local Fredbear = NPC:WaitForChild("Fredbear", 30)
local KeyframesFolder = NPC:WaitForChild("Keyframes", 30)
if cleaned or not Fredbear or not KeyframesFolder then return end
local RunKeyframe = KeyframesFolder:WaitForChild("Run", 30)
local WalkKeyframe = KeyframesFolder:WaitForChild("Walk", 30)
local LookAroundKeyframe = KeyframesFolder:WaitForChild("LookAround", 30)

local humanoid = Fredbear:WaitForChild("Humanoid", 30)
local rootPart = Fredbear.PrimaryPart
if cleaned or not RunKeyframe or not WalkKeyframe or not LookAroundKeyframe or not humanoid or not rootPart then return end

local EasingStyleMap = {
	[Enum.PoseEasingStyle.Linear]   = Enum.EasingStyle.Linear,
	[Enum.PoseEasingStyle.Bounce]   = Enum.EasingStyle.Bounce,
	[Enum.PoseEasingStyle.Cubic]    = Enum.EasingStyle.Cubic,
	[Enum.PoseEasingStyle.Elastic]  = Enum.EasingStyle.Elastic,
	[Enum.PoseEasingStyle.Constant] = Enum.EasingStyle.Linear,
}

local EasingDirectionMap = {
	[Enum.PoseEasingDirection.In]    = Enum.EasingDirection.In,
	[Enum.PoseEasingDirection.Out]   = Enum.EasingDirection.Out,
	[Enum.PoseEasingDirection.InOut] = Enum.EasingDirection.InOut,
}

local currentAnim = nil
local wanderThread = nil
local chaseThread = nil
local distractThread = nil
local footstepThread = nil

local Chase_Speed = 15
humanoid.WalkSpeed = Chase_Speed

local footstepSound = own(Instance.new("Sound"))
footstepSound.SoundId = "rbxassetid://107928272700538"
footstepSound.Volume = 0.8
footstepSound.Parent = rootPart

local function PlayKeyframeSequence(Model, KeyframeSequence, SpeedMult)
	SpeedMult = SpeedMult or 1
	if currentAnim and currentAnim.Stop then currentAnim:Stop() end

	local keyframes = {}
	for _, kf in ipairs(KeyframeSequence:GetKeyframes()) do
		table.insert(keyframes, {Time = kf.Time, KF = kf})
	end
	table.sort(keyframes, function(a,b) return a.Time < b.Time end)
	if #keyframes == 0 then return end

	local motorMap = {}
	local boneMap = {}
	local valueMap = {}
	local tweenList = {}

	local function ResolveInstance(pose)
		local name = pose.Name
		if motorMap[name] then return motorMap[name], "Motor6D" end
		if boneMap[name] then return boneMap[name], "Bone" end
		for _, motor in ipairs(Model:GetDescendants()) do
			if motor:IsA("Motor6D") and motor.Part1 and motor.Part0 then
				if motor.Part1.Name == name and motor.Part0.Name == pose.Parent.Name then
					motorMap[name] = motor
					return motor, "Motor6D"
				end
			end
		end
		for _, bone in ipairs(Model:GetDescendants()) do
			if bone:IsA("Bone") and bone.Name == name and bone.Parent and bone.Parent.Name == pose.Parent.Name then
				boneMap[name] = bone
				return bone, "Bone"
			end
		end
		return nil, nil
	end

	local poseTables = {}
	for i, entry in ipairs(keyframes) do
		local tab = {Time = entry.Time, Poses = {}}
		for _, pose in ipairs(entry.KF:GetDescendants()) do
			if pose:IsA("Pose") and pose.Weight > 0 then
				local instance, typ = ResolveInstance(pose)
				if instance then
					if not valueMap[pose.Name] then
						local val = Instance.new("CFrameValue")
						val.Name = "AnimValue"
						val.Parent = instance
						valueMap[pose.Name] = val
					end
					tab.Poses[pose.Name] = {
						Instance = instance,
						Type = typ,
						CFrame = pose.CFrame,
						Style = pose.EasingStyle,
						Dir = pose.EasingDirection,
					}
				end
			end
		end
		poseTables[i] = tab
	end

	for i = 1, #poseTables-1 do
		local kf1 = poseTables[i]
		local kf2 = poseTables[i+1]
		local duration = (kf2.Time - kf1.Time) / SpeedMult
		local group = {Duration = duration, Tweens = {}}
		for name, data2 in pairs(kf2.Poses) do
			local data1 = kf1.Poses[name] or poseTables[1].Poses[name]
			if data1 then
				local ti = TweenInfo.new(
					duration,
					EasingStyleMap[data2.Style] or Enum.EasingStyle.Linear,
					EasingDirectionMap[data2.Dir] or Enum.EasingDirection.InOut
				)
				local tween = TweenService:Create(valueMap[name], ti, {Value = data2.CFrame})
				group.Tweens[name] = tween
			end
		end
		table.insert(tweenList, group)
	end

	local heartbeatConn
	local playing = true
	heartbeatConn = trackConnection(RunService.Heartbeat:Connect(function()
		for name, valObj in pairs(valueMap) do
			local cf = valObj.Value
			local entry = poseTables[1].Poses[name]
			if entry then
				entry.Instance.Transform = cf
			end
		end
	end))

	local function PlayOnce()
		for _, group in ipairs(tweenList) do
			if not playing then break end
			for _, tween in pairs(group.Tweens) do
				tween:Play()
			end
			task.wait(group.Duration)
		end
	end

	task.spawn(function()
		while playing and Model and Model.Parent do
			PlayOnce()
			task.wait()
		end
	end)

	local animLength = poseTables[#poseTables].Time / SpeedMult
	currentAnim = {
		Stop = function()
			playing = false
			if heartbeatConn then heartbeatConn:Disconnect() end
			for _, group in ipairs(tweenList) do
				for _, tween in pairs(group.Tweens) do
					tween:Cancel()
				end
			end
			for _, v in pairs(valueMap) do
				v:Destroy()
			end
		end,
		Length = animLength,
		KeyframeSequence = KeyframeSequence
	}
	return currentAnim
end

local jumpscareSound = own(Instance.new("Sound"))
jumpscareSound.SoundId = "rbxassetid://85349172482807"
jumpscareSound.Volume = 2
jumpscareSound.Parent = workspace

local hitbox = own(Instance.new("Part"))
hitbox.Size = Vector3.new(8, 6, 12)
hitbox.Transparency = 1
hitbox.CanCollide = false
hitbox.Anchored = true
hitbox.Parent = workspace

local jumpscareGui = own(Instance.new("ScreenGui"))
jumpscareGui.Name = "FredbearJumpscare"
jumpscareGui.IgnoreGuiInset = true
jumpscareGui.ResetOnSpawn = false
jumpscareGui.Enabled = false
jumpscareGui.Parent = playerGui

local frameCount = 20
local frameSpeed = 0.07
local frames = {}
for i = 1, frameCount do
	local num = string.format("%03d", i)
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.fromScale(1,1)
	img.BackgroundTransparency = 1
	local imageAsset = getcustomasset("Fredscare/ezgif-frame-"..num..".png")
	if cleaned then img:Destroy() return end
	img.Image = imageAsset
	img.Visible = false
	img.Parent = jumpscareGui
	frames[i] = img
end

local jumpscareVersion = 0
local jumpscareFadeTween = nil

local function resetJumpscare()
    jumpscareVersion = jumpscareVersion + 1
    if jumpscareFadeTween then
        local tween = jumpscareFadeTween
        jumpscareFadeTween = nil
        tween:Cancel()
    end
    jumpscareGui.Enabled = false
    for _, frame in ipairs(frames) do
        frame.Visible = false
        frame.ImageTransparency = 0
    end
end

registerCleanup(resetJumpscare)

local function playJumpscareFrames()
    resetJumpscare()
    local version = jumpscareVersion
    jumpscareGui.Enabled = true
    task.spawn(function()
        for i = 1, frameCount do
            if version ~= jumpscareVersion then return end
            for _, frame in ipairs(frames) do frame.Visible = false end
            frames[i].Visible = true
            task.wait(frameSpeed)
        end
        if version ~= jumpscareVersion then return end
        local tween = TweenService:Create(
            frames[frameCount],
            TweenInfo.new(0.5, Enum.EasingStyle.Linear),
            {ImageTransparency = 1}
        )
        jumpscareFadeTween = tween
        tween:Play()
        tween.Completed:Wait()
        if version == jumpscareVersion then
            resetJumpscare()
        end
    end)
end

local currentConnection = nil
local currentPath = nil
local isChasing = false
local isDistracted = false
local canKill = true

registerCleanup(function()
    isChasing = false
    local function cancelThread(thread)
        if thread and thread ~= coroutine.running() then pcall(task.cancel, thread) end
    end
    cancelThread(wanderThread)
    cancelThread(chaseThread)
    cancelThread(distractThread)
    cancelThread(footstepThread)
    if currentAnim and currentAnim.Stop then pcall(function() currentAnim:Stop() end) end
    if currentPath then pcall(function() currentPath:Destroy() end) end
end)

local targetPlayer = nil
local targetCharacter = nil
local targetHumanoid = nil
local targetScanPending = false

local function chooseNearestLivingPlayer()
    local nearestPlayer, nearestCharacter, nearestHumanoid = nil, nil, nil
    local nearestDistance = math.huge
    local candidates = Players:GetPlayers()
    for _, candidate in ipairs(candidates) do
        local character = candidate.Character
        local candidateHumanoid = character and character:FindFirstChildOfClass("Humanoid")
        local candidateRoot = character and character:FindFirstChild("HumanoidRootPart")
        if candidateHumanoid and candidateHumanoid.Health > 0 and candidateRoot then
            local distance = (candidateRoot.Position - rootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer, nearestCharacter, nearestHumanoid = candidate, character, candidateHumanoid
            end
        end
    end
    targetPlayer, targetCharacter, targetHumanoid = nearestPlayer, nearestCharacter, nearestHumanoid
    if targetPlayer then
        canKill = true
    end
end

local function watchPlayer(candidate)
    local function characterReady(character)
        task.spawn(function()
            local candidateHumanoid = character:WaitForChild("Humanoid", 20)
            local candidateRoot = character:WaitForChild("HumanoidRootPart", 20)
            if not cleaned and candidate.Character == character and candidateHumanoid and candidateRoot
                and candidateHumanoid.Health > 0 and not targetPlayer then
                targetScanPending = true
            end
        end)
    end
    trackConnection(candidate.CharacterAdded:Connect(characterReady))
    if candidate.Character then characterReady(candidate.Character) end
end

local function beginTargetMonitoring()
    for _, candidate in ipairs(Players:GetPlayers()) do watchPlayer(candidate) end
    trackConnection(Players.PlayerAdded:Connect(watchPlayer))
    targetScanPending = true
    trackConnection(RunService.Heartbeat:Connect(function()
        if cleaned then return end
        if targetPlayer and (targetPlayer.Parent ~= Players
            or targetPlayer.Character ~= targetCharacter
            or not targetHumanoid.Parent or targetHumanoid.Health <= 0) then
            targetPlayer, targetCharacter, targetHumanoid = nil, nil, nil
            targetScanPending = true
        end
        if targetScanPending then
            targetScanPending = false
            if not targetPlayer then chooseNearestLivingPlayer() end
        end
    end))
end

local function followPath(targetPos)
	if currentPath then currentPath:Destroy() end
	currentPath = PathfindingService:CreatePath({AgentRadius = 5, AgentHeight = 7, AgentCanJump = true, AgentMaxSlope = 50, WaypointSpacing = 4, Costs = {Water = 20}})
	local success = pcall(function() currentPath:ComputeAsync(rootPart.Position, targetPos) end)
	if not success or currentPath.Status ~= Enum.PathStatus.Success then return false end
	for _, waypoint in ipairs(currentPath:GetWaypoints()) do
		if not (isChasing or isDistracted or wanderThread) then break end
		if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
		humanoid:MoveTo(waypoint.Position)
		humanoid.MoveToFinished:Wait(3)
	end
	return true
end

local function getSafeWanderPos()
	local rayOrigin = rootPart.Position + Vector3.new(0, 50, 0)
	local rayDirection = Vector3.new(0, -100, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {Fredbear}
	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	local y = result and result.Position.Y + 5 or rootPart.Position.Y + 5
	local pos = rootPart.Position + Vector3.new(math.random(-45,45), 0, math.random(-45,45))
	return Vector3.new(pos.X, y, pos.Z)
end

local function startFootstepLoop(interval)
	if footstepThread then task.cancel(footstepThread) end
	footstepThread = task.spawn(function()
		while not cleaned and rootPart.Parent do
			footstepSound.TimePosition = 0
			footstepSound:Play()
			task.wait(interval)
		end
	end)
end

local function stopFootstepLoop()
	if footstepThread then
		task.cancel(footstepThread)
		footstepThread = nil
	end
end

local function updateFootstepLoop()
	if not currentAnim or not currentAnim.KeyframeSequence then
		stopFootstepLoop()
		return
	end
	if currentAnim.KeyframeSequence == WalkKeyframe then
		startFootstepLoop(0.6)
	elseif currentAnim.KeyframeSequence == RunKeyframe then
		startFootstepLoop(0.1)
	else
		stopFootstepLoop()
	end
end

local function startWandering()
	if wanderThread then task.cancel(wanderThread) end
	PlayKeyframeSequence(Fredbear, WalkKeyframe, 1.0)
	humanoid.WalkSpeed = Chase_Speed
	updateFootstepLoop()

	wanderThread = task.spawn(function()
		while not isChasing and not isDistracted do
			local pos = getSafeWanderPos()
			followPath(pos)
			task.wait(0.1)
		end
	end)
end

local function startChasing()
    if chaseThread then task.cancel(chaseThread) end
    if wanderThread then task.cancel(wanderThread) wanderThread = nil end
    PlayKeyframeSequence(Fredbear, RunKeyframe, 1.4)
    humanoid.WalkSpeed = Chase_Speed
    updateFootstepLoop()

    chaseThread = task.spawn(function()
        while isChasing and not cleaned and rootPart.Parent do
            local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                humanoid:MoveTo(targetRoot.Position)
            end
            task.wait(0.1)
        end
    end)
end

local function killPlayer()
    if not canKill or targetPlayer ~= player or not targetHumanoid or targetHumanoid.Health <= 0 then return end
    canKill = false
    jumpscareSound:Play()
    playJumpscareFrames()
    targetHumanoid.Health = 0
end

local function startAI()
    if currentConnection then currentConnection:Disconnect() end
    if currentPath then currentPath:Destroy() end
    if wanderThread then task.cancel(wanderThread) wanderThread = nil end
    if chaseThread then task.cancel(chaseThread) chaseThread = nil end
    if distractThread then task.cancel(distractThread) distractThread = nil end
    stopFootstepLoop()

    isChasing = false
    isDistracted = false

    currentConnection = trackConnection(RunService.Heartbeat:Connect(function()
        if cleaned or not rootPart or not rootPart.Parent then return end
        hitbox.CFrame = rootPart.CFrame * CFrame.new(0, 0, -6)

        if targetPlayer and targetHumanoid and targetHumanoid.Health > 0 then
            if isDistracted then
                isDistracted = false
                if distractThread then task.cancel(distractThread) distractThread = nil end
            end
            if not isChasing then
                isChasing = true
                startChasing()
            end
        elseif isChasing then
            isChasing = false
            if chaseThread then task.cancel(chaseThread) chaseThread = nil end
            humanoid:MoveTo(rootPart.Position)
            stopFootstepLoop()
            if currentAnim and currentAnim.Stop then currentAnim:Stop() end
            currentAnim = nil
        end
    end))

    trackConnection(hitbox.Touched:Connect(function(hit)
        if canKill and hit and targetCharacter and hit.Parent == targetCharacter then killPlayer() end
    end))
    trackConnection(rootPart.Touched:Connect(function(hit)
        if canKill and hit and targetCharacter and hit.Parent == targetCharacter then killPlayer() end
    end))
end

trackConnection(player.CharacterAdded:Connect(function()
    resetJumpscare()
end))

local function getLatestRoom()
    local rooms = workspace:WaitForChild("CurrentRooms", 30)
    local gameData = game:GetService("ReplicatedStorage"):WaitForChild("GameData", 30)
    local latestRoom = gameData and gameData:WaitForChild("LatestRoom", 30)
    if not rooms or not latestRoom then
        return nil
    end
    local deadline = os.clock() + 30
    repeat
        local room = rooms:FindFirstChild(tostring(latestRoom.Value))
        if room and room:IsA("Model") then return room end
        task.wait(0.1)
    until os.clock() >= deadline
    return nil
end

local room = getLatestRoom()
if cleaned or not room then return end
local entrance = room:WaitForChild("RoomEntrance", 30)
if cleaned or not entrance or not entrance:IsA("BasePart") then return end
Fredbear:PivotTo(entrance.CFrame * CFrame.new(0, 2, -5))
NPC.Parent = workspace

beginTargetMonitoring()
task.spawn(function()
    task.wait(10.5)
    if not cleaned then pcall(startAI) end
end)
end

task.delay(400, cleanup)
pcall(runFredbear)
end

function entityBehaviors.A20()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function spawnShocker()
    local shockerModel = game:GetObjects("rbxassetid://100028546503408")[1]
    local camera = Workspace.CurrentCamera

    local rootPart = shockerModel:FindFirstChild("HumanoidRootPart") or shockerModel:FindFirstChildWhichIsA("BasePart", true)
    shockerModel.PrimaryPart = rootPart
    shockerModel:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, 0, -7))
    shockerModel.Parent = Workspace

    local oogaBoogaaPart = shockerModel:WaitForChild("OOGA BOOGAAAA")
    local horrorScream = oogaBoogaaPart:WaitForChild("HORROR SCREAM 15")
    local boneSound = oogaBoogaaPart:FindFirstChild("Bone")

    local lookDuration = 2
    local awayDuration = 0.5
    local lookStart = nil
    local awayStart = nil
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
    connection = RunService.RenderStepped:Connect(function()
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        if hasTriggered or hasFallen then
            connection:Disconnect()
            return
        end

        local offset = oogaBoogaaPart.Position - camera.CFrame.Position
        if offset.Magnitude == 0 then return end

        local directionToShocker = offset.Unit
        local playerLookVector = camera.CFrame.LookVector
        local dot = directionToShocker:Dot(playerLookVector)

        if dot > 0.85 then
            awayStart = nil

            if not lookStart then
                lookStart = tick()
            elseif tick() - lookStart >= lookDuration then
                hasTriggered = true
                connection:Disconnect()
                fallToGround()
            end
        else
            lookStart = nil

            if not awayStart then
                awayStart = tick()
            elseif tick() - awayStart >= awayDuration then
                hasTriggered = true
                connection:Disconnect()

                horrorScream:Play()
                if boneSound then boneSound:Play() end

                humanoid:TakeDamage(40)

                local targetPos = character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
                local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                local tween = TweenService:Create(oogaBoogaaPart, tweenInfo, {Position = targetPos})
                tween:Play()

                tween.Completed:Connect(function()
                    fallToGround()
                end)

                ReplicatedStorage.GameStats["Player_" .. player.Name].Total.DeathCause.Value = "A-20"

                firesignal(ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
                    "You died to who you call A-20...",
                    "Keep an eye on him!"
                }, "Blue")
            end
        end
    end)

    task.delay(5, function()
        if not hasTriggered and not hasFallen then
            connection:Disconnect()
            fallToGround()
        end
    end)
end

spawnShocker()
end

function entityBehaviors.PRINCIPAL()
local RunService = game:GetService("RunService")

local MODEL_ID = 137575158482605
local MOVE_SPEED = 25
local HEIGHT_OFFSET = Vector3.new(0, 0, 0)
local RAYCAST_DISTANCE = 100
local RUNNING_SPEED = 15

local currentRooms = workspace:WaitForChild("CurrentRooms")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local movementPaused = false

local function getOrderedRooms()
    local orderedRooms = {}

    for _, room in ipairs(currentRooms:GetChildren()) do
        if room:IsA("Model") then
            local number = tonumber(room.Name)
            if number then
                table.insert(orderedRooms, {
                    Number = number,
                    Room = room
                })
            end
        end
    end

    table.sort(orderedRooms, function(a, b)
        return a.Number < b.Number
    end)

    return orderedRooms
end

local function getOrderedNodes(room)
    local orderedNodes = {}
    local pathfindNodes = room:FindFirstChild("PathfindNodes")

    if pathfindNodes then
        for _, node in ipairs(pathfindNodes:GetChildren()) do
            if node:IsA("BasePart") then
                table.insert(orderedNodes, node)
            end
        end

        table.sort(orderedNodes, function(a, b)
            local numberA = tonumber(a.Name)
            local numberB = tonumber(b.Name)

            if numberA and numberB then
                return numberA < numberB
            elseif numberA then
                return true
            elseif numberB then
                return false
            end

            return a.Name < b.Name
        end)
    end

    if #orderedNodes == 0 then
        local roomExit = room:FindFirstChild("RoomExit")
        if roomExit and roomExit:IsA("BasePart") then
            table.insert(orderedNodes, roomExit)
        end
    end

    return orderedNodes
end

local function loadModel()
    local success, asset = pcall(function()
        return game:GetObjects("rbxassetid://" .. MODEL_ID)[1]
    end)

    if not success or not asset then
        warn("模型加载失败：", asset)
        return nil
    end

    if not asset:IsA("Model") then
        asset:Destroy()
        warn("加载的资源不是 Model")
        return nil
    end

    for _, descendant in ipairs(asset:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
        elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
            descendant.Enabled = false
        end
    end

    return asset
end

local function moveModelTo(model, targetCFrame)
    local startCFrame = model:GetPivot()
    local distance = (startCFrame.Position - targetCFrame.Position).Magnitude

    if distance <= 0.001 then
        model:PivotTo(targetCFrame)
        return true
    end

    local travelled = 0

    while travelled < distance do
        local deltaTime = RunService.Heartbeat:Wait()

        if not model.Parent then
            return false
        end

        if not movementPaused then
            travelled = math.min(
                travelled + MOVE_SPEED * math.min(deltaTime, 0.1),
                distance
            )

            model:PivotTo(startCFrame:Lerp(targetCFrame, travelled / distance))
        end
    end

    return true
end

local function getCharacterFromRaycastHit(hitInstance)
    local current = hitInstance

    while current and current ~= workspace do
        if current:IsA("Model") and Players:GetPlayerFromCharacter(current) then
            return current
        end

        current = current.Parent
    end

    return nil
end

local function rayEntryDistanceToPart(origin, directionUnit, part)
    if not part or not part.Parent or not part:IsA("BasePart") then
        return nil
    end

    local localOrigin = part.CFrame:PointToObjectSpace(origin)
    local localDirection = part.CFrame:VectorToObjectSpace(directionUnit)
    local half = part.Size * 0.5
    local entry, exit = 0, math.huge

    for _, axis in ipairs({ "X", "Y", "Z" }) do
        local position = localOrigin[axis]
        local velocity = localDirection[axis]
        local extent = half[axis]

        if math.abs(velocity) < 0.00001 then
            if position < -extent or position > extent then
                return nil
            end
        else
            local near = (-extent - position) / velocity
            local far = (extent - position) / velocity

            if near > far then
                near, far = far, near
            end

            entry = math.max(entry, near)
            exit = math.min(exit, far)

            if exit < entry then
                return nil
            end
        end
    end

    return entry
end

local function findDecalSound(model, soundName)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant.Name == "DecalPart" and descendant:IsA("BasePart") then
            local sound = descendant:FindFirstChild(soundName, true)
            if sound and sound:IsA("Sound") then
                return sound
            end
        end
    end

    return nil
end

local function playSoundOnce(model, soundName, waitUntilFinished)
    local sound = findDecalSound(model, soundName)

    if not sound then
        return
    end

    sound.Looped = false
    sound.TimePosition = 0

    if not waitUntilFinished then
        sound.Playing = true
        return
    end

    local completed = false
    local connection = sound.Ended:Connect(function()
        completed = true
    end)

    sound.Playing = true
    local deadline = os.clock() + math.max(sound.TimeLength + 3, 15)

    while model.Parent and sound.Parent and not completed and os.clock() < deadline do
        task.wait(0.05)
    end

    connection:Disconnect()

    if sound.Parent and not completed then
        sound.Playing = false
    end
end

local function scanVisibleCharacters(model)
    local origin = model:GetPivot().Position
    local visibleCharacters = {}
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { model }

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character

        if character and character:IsDescendantOf(workspace)
            and not character:GetAttribute("Hiding") then
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoid.Health > 0
                and rootPart and rootPart:IsA("BasePart") then
                local targets = { rootPart }

                for _, partName in ipairs({ "Head", "UpperTorso", "Torso", "LowerTorso" }) do
                    local targetPart = character:FindFirstChild(partName)
                    if targetPart and targetPart:IsA("BasePart") then
                        table.insert(targets, targetPart)
                    end
                end

                for _, targetPart in ipairs(targets) do
                    local direction = targetPart.Position - origin
                    local distance = direction.Magnitude

                    if distance > 0.001 and distance <= RAYCAST_DISTANCE then
                        local result = workspace:Raycast(origin, direction, raycastParams)
                        local hitCharacter = result
                            and getCharacterFromRaycastHit(result.Instance) or nil

                        if not hitCharacter then
                            local entryDistance = rayEntryDistanceToPart(
                                origin, direction.Unit, targetPart
                            )

                            if entryDistance and entryDistance <= distance + 0.01
                                and (not result or result.Distance > entryDistance + 0.02) then
                                hitCharacter = character
                            end
                        end

                        if hitCharacter and not hitCharacter:GetAttribute("Hiding") then
                            local hitHumanoid = hitCharacter:FindFirstChildWhichIsA("Humanoid")
                            if hitHumanoid and hitHumanoid.Health > 0 then
                                visibleCharacters[hitCharacter] = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    return visibleCharacters
end

local orderedRooms = getOrderedRooms()

if #orderedRooms == 0 then
    warn("CurrentRooms 中没有数字命名的房间")
    return
end

local startRoomIndex = 1

if #orderedRooms > 10 then
    startRoomIndex = #orderedRooms - 8
end

local targetRoomIndex = math.max(1, #orderedRooms - 1)
local lastRoomNodes = getOrderedNodes(orderedRooms[targetRoomIndex].Room)

if #lastRoomNodes == 0 then
    warn("反向起点房间没有可用节点")
    return
end

local model = loadModel()

if not model then
    return
end

model.Name = "Principal"
model:PivotTo(lastRoomNodes[#lastRoomNodes].CFrame + HEIGHT_OFFSET)
model.Parent = workspace

task.delay(2, function()
    if not model.Parent then
        return
    end

    playSoundOnce(model, "sounds", false)
end)

task.wait(3)

local warnedCharacters = setmetatable({}, { __mode = "k" })
local selfPenaltyApplied = false
local warningActive = false

local function applySelfPenalty(character)
    if selfPenaltyApplied or not localPlayer or localPlayer.Character ~= character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    selfPenaltyApplied = true
    local originalWalkSpeed = humanoid.WalkSpeed
    local penaltyStartedAt = os.clock()

    task.spawn(function()
        while humanoid.Parent and os.clock() - penaltyStartedAt < 30 do
            humanoid.WalkSpeed = -100
            RunService.Heartbeat:Wait()
        end

        if humanoid.Parent then
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end)
end

task.spawn(function()
    while model.Parent do
        local visibleCharacters = scanVisibleCharacters(model)
        local warningEligible = {}
        local newRunner = nil

        for character in pairs(visibleCharacters) do
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart:IsA("BasePart") then
                local velocity = rootPart.AssemblyLinearVelocity
                local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

                if horizontalSpeed >= RUNNING_SPEED then
                    if localPlayer and localPlayer.Character == character then
                        applySelfPenalty(character)
                    end
                    warningEligible[character] = true

                    if not warningActive and not warnedCharacters[character] and not newRunner then
                        newRunner = character
                    end
                end
            end
        end

        for character in pairs(warnedCharacters) do
            if not warningEligible[character] then
                warnedCharacters[character] = nil
            end
        end

        if newRunner and not warningActive then
            warnedCharacters[newRunner] = true
            warningActive = true
            movementPaused = true

            task.spawn(function()
                playSoundOnce(model, "norunning", true)
                playSoundOnce(model, "whistle", true)
                playSoundOnce(model, "detentionforyou", true)

                if model.Parent then
                    playSoundOnce(model, "whenwillyoulearn", false)
                end

                movementPaused = false
                warningActive = false
            end)
        end

        task.wait(0.05)
    end
end)

for roomIndex = targetRoomIndex, startRoomIndex, -1 do
    local room = orderedRooms[roomIndex].Room
    local nodes = room.Parent and getOrderedNodes(room) or {}

    if #nodes == 0 then
        break
    end

    for nodeIndex = #nodes, 1, -1 do
        if not moveModelTo(model, nodes[nodeIndex].CFrame + HEIGHT_OFFSET) then
            model:Destroy()
            return
        end
    end
end

while movementPaused and model.Parent do
    task.wait(0.05)
end

model:Destroy()
end

function entityBehaviors.Scribblet()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
if not player then
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local currentRooms = workspace:WaitForChild("CurrentRooms")
local hardCoreSound = workspace:WaitForChild("HardCoreSound")
local endSound = hardCoreSound:WaitForChild("EndS")
local startSound = hardCoreSound:WaitForChild("StartS")

local INTRO_DURATION = 8
local BLACKOUT_DURATION = 2
local HIDE_DURATION = 15
local ROUND_COUNT = 4
local FLYBY_MODEL_ID = 119948154036388
local FLYBY_DISTANCE = 50
local FLYBY_SPEED = 5
local FLYBY_DEPTH = 20
local COUNTDOWN_SOUND_ID = 137727855471828
local ROUND_BLACKOUT_RELEASE = 9
local BAR_HEIGHT = 1 / 3
local BAR_TWEEN_DURATION = 1.35
local BAR_IMAGE_ID = "rbxassetid://14827943434"
local FLYBY_DELAY_MIN = 6
local FLYBY_DELAY_MAX = 18

local random = Random.new()
local active = true
local filterStrength = 0
local savedObjects = setmetatable({}, { __mode = "k" })
local trackedSounds = setmetatable({}, { __mode = "k" })
local flyingModels = {}
local currentFlybyToken = nil
local soundAddedConnection = nil
local stepName = "ScribbletSway_" .. HttpService:GenerateGUID(false)
local lastCamera = nil
local lastCameraOffset = CFrame.new()
local startedAt = os.clock()

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "ScribbletColorCorrection"
colorCorrection.Saturation = 0
colorCorrection.Contrast = 0
colorCorrection.Brightness = 0
colorCorrection.Parent = Lighting

local gui = Instance.new("ScreenGui")
gui.Name = "ScribbletExperience"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 900
gui.Parent = playerGui

local barGui = Instance.new("ScreenGui")
barGui.Name = "ScribbletCinematicBars"
barGui.IgnoreGuiInset = true
barGui.ResetOnSpawn = false
barGui.DisplayOrder = -999
barGui.Parent = playerGui

local topBar = Instance.new("ImageLabel")
topBar.Name = "TopBar"
topBar.BackgroundTransparency = 1
topBar.Image = BAR_IMAGE_ID
topBar.ImageTransparency = 1
topBar.ScaleType = Enum.ScaleType.Stretch
topBar.Rotation = 180
topBar.Size = UDim2.fromScale(1, BAR_HEIGHT)
topBar.Position = UDim2.fromScale(0, -BAR_HEIGHT)
topBar.ZIndex = 20
topBar.Parent = barGui

local bottomBar = Instance.new("ImageLabel")
bottomBar.Name = "BottomBar"
bottomBar.BackgroundTransparency = 1
bottomBar.Image = BAR_IMAGE_ID
bottomBar.ImageTransparency = 1
bottomBar.ScaleType = Enum.ScaleType.Stretch
bottomBar.Size = UDim2.fromScale(1, BAR_HEIGHT)
bottomBar.AnchorPoint = Vector2.new(0, 1)
bottomBar.Position = UDim2.fromScale(0, 1 + BAR_HEIGHT)
bottomBar.ZIndex = 20
bottomBar.Parent = barGui

local hideLabel = Instance.new("TextLabel")
hideLabel.Name = "HideCountdown"
hideLabel.AnchorPoint = Vector2.new(0.5, 1)
hideLabel.Position = UDim2.fromScale(0.5, 0.94)
hideLabel.Size = UDim2.fromScale(0.8, 0.065)
hideLabel.BackgroundTransparency = 1
hideLabel.Text = ""
hideLabel.TextScaled = true
hideLabel.TextStrokeTransparency = 0.5
hideLabel.TextStrokeColor3 = Color3.fromRGB(18, 18, 18)
hideLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
hideLabel.Visible = false
hideLabel.ZIndex = 22
hideLabel.Parent = gui

local fontLoaded, customFont = pcall(function()
    return Font.fromId(8764312106, Enum.FontWeight.Bold)
end)

if fontLoaded and customFont then
    hideLabel.FontFace = customFont
else
    hideLabel.Font = Enum.Font.GothamBold
end

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 105, 105)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))
})
gradient.Offset = Vector2.new(-0.4, 0)
gradient.Parent = hideLabel

local gradientTween = TweenService:Create(
    gradient,
    TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Offset = Vector2.new(0.4, 0) }
)
gradientTween:Play()

local blackoutGui = Instance.new("ScreenGui")
blackoutGui.Name = "ScribbletBlackoutLayer"
blackoutGui.IgnoreGuiInset = true
blackoutGui.ResetOnSpawn = false
blackoutGui.DisplayOrder = -1000
blackoutGui.Parent = playerGui

local blackScreen = Instance.new("Frame")
blackScreen.Name = "BlackScreen"
blackScreen.Size = UDim2.fromScale(1, 1)
blackScreen.BackgroundColor3 = Color3.new(0, 0, 0)
blackScreen.BackgroundTransparency = 1
blackScreen.BorderSizePixel = 0
blackScreen.Active = false
blackScreen.Parent = blackoutGui

local function playTween(object, duration, properties)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        properties
    )
    tween:Play()
    return tween
end

playTween(topBar, BAR_TWEEN_DURATION, {
    Position = UDim2.fromScale(0, 0),
    ImageTransparency = 0
})
playTween(bottomBar, BAR_TWEEN_DURATION, {
    Position = UDim2.fromScale(0, 1),
    ImageTransparency = 0
})

local function registerSound(sound)
    if not sound:IsA("Sound") or trackedSounds[sound]
        or sound == endSound or sound == startSound then
        return
    end

    local echo = Instance.new("EchoSoundEffect")
    echo.Name = "ScribbletEarlyEcho"
    echo.Delay = 0.25
    echo.Feedback = 0.38
    echo.DryLevel = -2
    echo.WetLevel = -80

    local reverb = Instance.new("ReverbSoundEffect")
    reverb.Name = "ScribbletCathedralReverb"
    reverb.DecayTime = 8.5
    reverb.Density = 0.96
    reverb.Diffusion = 0.92
    reverb.DryLevel = -2
    reverb.WetLevel = -80

    local success = pcall(function()
        echo.Parent = sound
        reverb.Parent = sound
    end)

    if not success then
        echo:Destroy()
        reverb:Destroy()
        return
    end

    trackedSounds[sound] = { Echo = echo, Reverb = reverb }
    echo.WetLevel = -80 + 72 * filterStrength
    reverb.WetLevel = -80 + 82 * filterStrength
end

local function setFilterStrength(strength)
    filterStrength = math.clamp(strength, 0, 1)
    colorCorrection.Saturation = -filterStrength
    colorCorrection.Contrast = 0.14 * filterStrength
    colorCorrection.Brightness = 0.035 * filterStrength

    for sound, effects in pairs(trackedSounds) do
        if sound.Parent then
            if effects.Echo.Parent then
                effects.Echo.WetLevel = -80 + 72 * filterStrength
            end
            if effects.Reverb.Parent then
                effects.Reverb.WetLevel = -80 + 82 * filterStrength
            end
        end
    end
end

for _, descendant in ipairs(game:GetDescendants()) do
    if descendant:IsA("Sound") then
        registerSound(descendant)
    end
end

soundAddedConnection = game.DescendantAdded:Connect(function(descendant)
    if active and descendant:IsA("Sound") then
        registerSound(descendant)
    end
end)

RunService:BindToRenderStep(stepName, Enum.RenderPriority.Camera.Value + 2, function()
    if not active then
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    if lastCamera ~= camera then
        lastCamera = camera
        lastCameraOffset = CFrame.new()
    end

    local elapsed = os.clock() - startedAt
    local strength = 0.3 + 0.7 * filterStrength
    local nextOffset = CFrame.new(
        math.sin(elapsed * 1.65) * 0.045 * strength,
        math.sin(elapsed * 1.13 + 0.8) * 0.012 * strength,
        0
    ) * CFrame.Angles(
        0,
        0,
        math.sin(elapsed * 1.4) * math.rad(0.24) * strength
    )

    camera.CFrame = camera.CFrame * lastCameraOffset:Inverse() * nextOffset
    lastCameraOffset = nextOffset
end)

local function playSound(sound, waitForEnd)
    if not sound or not sound:IsA("Sound") then
        return
    end

    sound.Looped = false
    sound.TimePosition = 0

    if not waitForEnd then
        sound.Playing = true
        return
    end

    local finished = false
    local connection = sound.Ended:Connect(function()
        finished = true
    end)
    sound.Playing = true

    local loadDeadline = os.clock() + 5
    while active and sound.Parent and not sound.IsLoaded
        and not finished and os.clock() < loadDeadline do
        task.wait(0.05)
    end

    local deadline = os.clock() + math.max(sound.TimeLength + 3, 20)

    while active and sound.Parent and not finished and os.clock() < deadline do
        task.wait(0.05)
    end

    connection:Disconnect()
end

local function saveModelState(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if not savedObjects[descendant] then
            if descendant:IsA("BasePart") then
                savedObjects[descendant] = {
                    Kind = "Part",
                    Transparency = descendant.Transparency,
                    Color = descendant.Color,
                    CanCollide = descendant.CanCollide,
                    CanTouch = descendant.CanTouch
                }
            elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                savedObjects[descendant] = {
                    Kind = "Surface",
                    Transparency = descendant.Transparency
                }
            elseif descendant:IsA("ProximityPrompt") then
                savedObjects[descendant] = {
                    Kind = "Prompt",
                    Enabled = descendant.Enabled
                }
            elseif descendant:IsA("ClickDetector") then
                savedObjects[descendant] = {
                    Kind = "Click",
                    Distance = descendant.MaxActivationDistance
                }
            end
        end
    end
end

local function restoreObjects()
    for object, state in pairs(savedObjects) do
        if object.Parent then
            if state.Kind == "Part" then
                object.Transparency = state.Transparency
                object.Color = state.Color
                object.CanCollide = state.CanCollide
                object.CanTouch = state.CanTouch
            elseif state.Kind == "Surface" then
                object.Transparency = state.Transparency
            elseif state.Kind == "Prompt" then
                object.Enabled = state.Enabled
            elseif state.Kind == "Click" then
                object.MaxActivationDistance = state.Distance
            end
        end
    end
end

local function getHidingModels()
    local wardrobes = {}
    local beds = {}

    for _, descendant in ipairs(currentRooms:GetDescendants()) do
        if descendant:IsA("Model") then
            if descendant.Name == "Wardrobe" then
                table.insert(wardrobes, descendant)
            elseif descendant.Name == "Bed" then
                table.insert(beds, descendant)
            end
        end
    end

    return wardrobes, beds
end

local function chooseHidingModel(wardrobes, beds)
    local candidates

    if #wardrobes > 0 and #beds > 0 then
        candidates = random:NextInteger(1, 2) == 1 and wardrobes or beds
    elseif #wardrobes > 0 then
        candidates = wardrobes
    else
        candidates = beds
    end

    if #candidates == 0 then
        return nil
    end

    return candidates[random:NextInteger(1, #candidates)]
end

local function setHidingModelEnabled(model, enabled)
    for _, descendant in ipairs(model:GetDescendants()) do
        local state = savedObjects[descendant]

        if state then
            if state.Kind == "Part" then
                descendant.Transparency = enabled and state.Transparency or 1
                descendant.Color = state.Color
                descendant.CanCollide = enabled and state.CanCollide or false
                descendant.CanTouch = enabled and state.CanTouch or false
            elseif state.Kind == "Surface" then
                descendant.Transparency = enabled and state.Transparency or 1
            elseif state.Kind == "Prompt" then
                descendant.Enabled = enabled and state.Enabled or false
            elseif state.Kind == "Click" then
                descendant.MaxActivationDistance = enabled and state.Distance or 0
            end
        end
    end
end

local function disableAllHidingPrompts(models)
    for _, model in ipairs(models) do
        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                descendant.Enabled = false
            elseif descendant:IsA("ClickDetector") then
                descendant.MaxActivationDistance = 0
            end
        end
    end
end

local function flickerModels(models, state)
    local parts = {}

    for _, model in ipairs(models) do
        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("BasePart") then
                table.insert(parts, descendant)
            end
        end
    end

    task.spawn(function()
        while active and state.Flickering do
            for _, part in ipairs(parts) do
                if part.Parent then
                    local white = random:NextNumber() > 0.45
                    part.Color = white
                        and Color3.fromRGB(245, 245, 245)
                        or Color3.fromRGB(12, 12, 12)
                end
            end
            task.wait(0.12)
        end
    end)
end

local function loadFlybyModel()
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(FLYBY_MODEL_ID))
    end)

    local asset = success and objects and objects[1] or nil

    if not asset then
        local source = ReplicatedStorage:FindFirstChild("ScribbletModel", true)
        if source then
            asset = source:Clone()
        end
    end

    if not asset then
        return nil
    end

    if not asset:IsA("Model") then
        local wrapper = Instance.new("Model")
        asset.Parent = wrapper
        asset = wrapper
    end

    for _, descendant in ipairs(asset:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
        elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
            descendant.Enabled = false
        end
    end

    asset.Name = "A120_Scribblet"
    asset.Parent = workspace
    return asset
end

local function runFlyby(token)
    local model = loadFlybyModel()
    if not model then
        return
    end

    flyingModels[model] = true
    local height = random:NextNumber(-1.5, 1.5)
    local startTime = os.clock()
    local duration = FLYBY_DISTANCE / FLYBY_SPEED
    local camera = workspace.CurrentCamera

    if not camera then
        model:Destroy()
        flyingModels[model] = nil
        return
    end

    local fixedCameraCFrame = camera.CFrame

    while active and token.Active and model.Parent do
        local elapsed = os.clock() - startTime
        local distanceTravelled = math.min(elapsed * FLYBY_SPEED, FLYBY_DISTANCE)
        local x = FLYBY_DISTANCE / 2 - distanceTravelled
        model:PivotTo(
            fixedCameraCFrame
            * CFrame.new(x, height, -FLYBY_DEPTH)
            * CFrame.Angles(0, math.pi, 0)
        )

        if elapsed >= duration then
            break
        end

        RunService.RenderStepped:Wait()
    end

    if model.Parent then
        model:Destroy()
    end
    flyingModels[model] = nil
end

local function isHiding()
    local character = player.Character
    return (character and character:GetAttribute("Hiding") == true)
        or player:GetAttribute("Hiding") == true
end

local function isPlayerDead()
    local character = player.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    return not humanoid or humanoid.Health <= 0
end

local function runRoundBlackout(transition)
    local startTime = os.clock()

    while active and transition.Active do
        local elapsed = os.clock() - startTime
        local opacity

        if elapsed < 1.4 then
            local progress = math.clamp(elapsed / 1.4, 0, 1)
            local flicker = math.abs(math.sin(elapsed * 29)) * 0.22
            opacity = math.clamp(progress + flicker * (1 - progress), 0, 1)
        elseif elapsed < ROUND_BLACKOUT_RELEASE then
            opacity = 1
        elseif elapsed < ROUND_BLACKOUT_RELEASE + 1.4 then
            local progress = math.clamp(
                (elapsed - ROUND_BLACKOUT_RELEASE) / 1.4, 0, 1
            )
            local flicker = math.abs(math.sin(elapsed * 32)) * 0.2
            opacity = math.clamp(1 - progress - flicker * progress, 0, 1)
        else
            break
        end

        blackScreen.BackgroundTransparency = 1 - opacity
        RunService.RenderStepped:Wait()
    end

    blackScreen.BackgroundTransparency = 1
    transition.Done = true
end

local function playCountdownSound()
    local sound = Instance.new("Sound")
    sound.Name = "ScribbletHideCountdown"
    sound.SoundId = "rbxassetid://" .. tostring(COUNTDOWN_SOUND_ID)
    sound.Volume = 1.5
    sound.Looped = false
    sound.Parent = SoundService
    registerSound(sound)

    sound.Ended:Connect(function()
        if sound.Parent then
            sound:Destroy()
        end
    end)

    task.delay(60, function()
        if sound.Parent then
            sound:Destroy()
        end
    end)

    playSound(sound, false)
end

local function runCountdown()
    hideLabel.Visible = true
    local startTime = os.clock()
    local demonstrationOnly = isPlayerDead()
    local hasBeenOutside = demonstrationOnly or not isHiding()
    local passed = false
    local lastDisplayedSecond = nil

    while active do
        local elapsed = os.clock() - startTime
        local remaining = math.max(0, HIDE_DURATION - elapsed)
        local displayedSecond = math.ceil(remaining)

        if displayedSecond ~= lastDisplayedSecond then
            lastDisplayedSecond = displayedSecond
            hideLabel.Text = "HIDE : " .. tostring(displayedSecond) .. "s"
            if displayedSecond > 0 then
                playCountdownSound()
            end
        end

        if not demonstrationOnly then
            if isPlayerDead() then
                demonstrationOnly = true
            elseif not isHiding() then
                hasBeenOutside = true
            elseif hasBeenOutside then
                passed = true
                break
            end
        end

        if remaining <= 0 then
            break
        end

        RunService.Heartbeat:Wait()
    end

    hideLabel.Visible = false
    return passed or demonstrationOnly
end

local function runRound()
    local wardrobes, beds = getHidingModels()
    local allModels = {}

    for _, model in ipairs(wardrobes) do
        table.insert(allModels, model)
    end

    for _, model in ipairs(beds) do
        table.insert(allModels, model)
    end

    local chosen = chooseHidingModel(wardrobes, beds)
    if not chosen then
        return nil
    end

    for _, model in ipairs(allModels) do
        saveModelState(model)
    end

    restoreObjects()
    disableAllHidingPrompts(allModels)

    local state = { Flickering = true }
    local flybyToken = { Active = true }
    local transition = { Active = true, Done = false }
    currentFlybyToken = flybyToken
    flickerModels(allModels, state)
    task.spawn(function()
        task.wait(random:NextNumber(FLYBY_DELAY_MIN, FLYBY_DELAY_MAX))
        if active and flybyToken.Active then
            runFlyby(flybyToken)
        end
    end)
    task.spawn(runRoundBlackout, transition)
    playSound(startSound, true)
    while active and not transition.Done do
        task.wait(0.05)
    end
    transition.Active = false
    state.Flickering = false
    restoreObjects()

    for _, model in ipairs(allModels) do
        if model.Parent then
            setHidingModelEnabled(model, model == chosen)
        end
    end

    local passed = runCountdown()
    return passed
end

local function fadeOutAndCleanUp()
    hideLabel.Visible = false
    local start = os.clock()
    local fromStrength = filterStrength
    local fromBlack = blackScreen.BackgroundTransparency

    while os.clock() - start < 2.5 do
        local progress = math.clamp((os.clock() - start) / 2.5, 0, 1)
        local eased = progress * progress * (3 - 2 * progress)
        setFilterStrength(fromStrength * (1 - eased))
        blackScreen.BackgroundTransparency = fromBlack + (1 - fromBlack) * eased
        RunService.Heartbeat:Wait()
    end

    setFilterStrength(0)
    restoreObjects()
    active = false

    if currentFlybyToken then
        currentFlybyToken.Active = false
    end

    if soundAddedConnection then
        soundAddedConnection:Disconnect()
    end

    for model in pairs(flyingModels) do
        if model.Parent then
            model:Destroy()
        end
    end

    RunService:UnbindFromRenderStep(stepName)

    if lastCamera and lastCamera.Parent then
        lastCamera.CFrame = lastCamera.CFrame * lastCameraOffset:Inverse()
    end

    for _, effects in pairs(trackedSounds) do
        if effects.Echo.Parent then
            effects.Echo:Destroy()
        end
        if effects.Reverb.Parent then
            effects.Reverb:Destroy()
        end
    end

    colorCorrection:Destroy()
    gradientTween:Cancel()
    playTween(topBar, BAR_TWEEN_DURATION, {
        Position = UDim2.fromScale(0, -BAR_HEIGHT),
        ImageTransparency = 1
    })
    playTween(bottomBar, BAR_TWEEN_DURATION, {
        Position = UDim2.fromScale(0, 1 + BAR_HEIGHT),
        ImageTransparency = 1
    }).Completed:Wait()
    blackoutGui:Destroy()
    barGui:Destroy()
    gui:Destroy()
end

local introStarted = os.clock()

while active do
    local elapsed = os.clock() - introStarted
    local alpha = math.clamp(elapsed / INTRO_DURATION, 0, 1)
    setFilterStrength(alpha * alpha * (3 - 2 * alpha))

    if alpha >= 1 then
        break
    end

    RunService.Heartbeat:Wait()
end

setFilterStrength(1)
blackScreen.BackgroundTransparency = 0
task.wait(BLACKOUT_DURATION)
playTween(blackScreen, 0.4, { BackgroundTransparency = 1 }).Completed:Wait()
playSound(endSound, true)

local won = true
local startedRounds = 0

for round = 1, ROUND_COUNT do
    startedRounds = round
    local result = runRound()

    if result == nil then
        won = false
        break
    end

    if not result then
        won = false
        local character = player.Character
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid:TakeDamage(400)
        end
        break
    end
end

if won and startedRounds == ROUND_COUNT then
    blackScreen.BackgroundTransparency = 0
    task.wait(0.18)
    blackScreen.BackgroundTransparency = 1
end

playSound(endSound, false)
fadeOutAndCleanUp()
end

function entityBehaviors.SLD()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then
    return
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
if not camera then
    return
end

local distance = 8
local heightOffset = -5
local duration = 10
local escapeThreshold = 8

local success, objects = pcall(function()
    return game:GetObjects("rbxassetid://81308817927391")
end)

local model = success and objects and objects[1]
if not model or not model:IsA("Model") then
    return
end

for _, descendant in ipairs(model:GetDescendants()) do
    if descendant:IsA("Script") or descendant:IsA("LocalScript") then
        descendant.Enabled = false
    elseif descendant:IsA("BasePart") then
        descendant.Anchored = true
    elseif descendant:IsA("Animator") then
        for _, track in ipairs(descendant:GetPlayingAnimationTracks()) do
            track:Stop(0)
        end
    end
end

model.Parent = workspace

local forwardPosition = root.Position + root.CFrame.LookVector * distance
local spawnPosition = Vector3.new(forwardPosition.X, root.Position.Y + heightOffset, forwardPosition.Z)
model:PivotTo(CFrame.new(spawnPosition) * model:GetPivot().Rotation)

local frozenTransforms = {}
for _, descendant in ipairs(model:GetDescendants()) do
    if descendant:IsA("BasePart") then
        frozenTransforms[descendant] = descendant.CFrame
    end
end

local freezeConnection = RunService.Heartbeat:Connect(function()
    for part, originalCFrame in pairs(frozenTransforms) do
        if part.Parent and part.CFrame ~= originalCFrame then
            part.CFrame = originalCFrame
        end
    end
end)

local lookPart = model:FindFirstChild("Look", true)
local effectPart = model:FindFirstChild("pART", true)

if not lookPart or not lookPart:IsA("BasePart") then
    freezeConnection:Disconnect()
    model:Destroy()
    return
end

local playtime = effectPart and effectPart:FindFirstChild("Playtime", true)
local playImage
if playtime then
    if playtime:IsA("ImageLabel") then
        playImage = playtime
    else
        playImage = playtime:FindFirstChildWhichIsA("ImageLabel", true)
    end
end

if playImage and effectPart and effectPart:IsA("BasePart") then
    local billboard = playImage:FindFirstAncestorWhichIsA("BillboardGui")
    if billboard then
        local adornee = billboard.Adornee
        local center = effectPart.Position
        if adornee and adornee:IsA("BasePart") then
            center = adornee.Position
        elseif adornee and adornee:IsA("Attachment") then
            center = adornee.WorldPosition
        end

        center = center
            + effectPart.CFrame:VectorToWorldSpace(billboard.StudsOffset)
            + billboard.StudsOffsetWorldSpace

        local distanceToCamera = math.max(1, (camera.CFrame.Position - center).Magnitude)
        local viewportHeight = camera.ViewportSize.Y > 0 and camera.ViewportSize.Y or 720
        local pixelsPerStud = math.max(
            1,
            viewportHeight / (2 * distanceToCamera * math.tan(math.rad(camera.FieldOfView) / 2))
        )
        local widthPixels = math.max(64, math.abs(billboard.Size.X.Scale) * pixelsPerStud + math.abs(billboard.Size.X.Offset))
        local heightPixels = math.max(64, math.abs(billboard.Size.Y.Scale) * pixelsPerStud + math.abs(billboard.Size.Y.Offset))

        local plane = Instance.new("Part")
        plane.Name = "FixedPlaytimePlane"
        plane.Anchored = true
        plane.CanCollide = false
        plane.CanTouch = false
        plane.CanQuery = false
        plane.Transparency = 1
        plane.Size = Vector3.new(widthPixels / pixelsPerStud, heightPixels / pixelsPerStud, 0.05)
        plane.CFrame = CFrame.lookAt(center, root.Position)
        plane.Parent = model
        frozenTransforms[plane] = plane.CFrame

        local fixedGui = Instance.new("SurfaceGui")
        fixedGui.Name = "FixedPlaytime"
        fixedGui.Adornee = plane
        fixedGui.Face = Enum.NormalId.Front
        fixedGui.AlwaysOnTop = true
        fixedGui.LightInfluence = billboard.LightInfluence
        fixedGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
        fixedGui.CanvasSize = Vector2.new(math.round(widthPixels), math.round(heightPixels))
        fixedGui.ZIndexBehavior = billboard.ZIndexBehavior
        fixedGui.Parent = plane

        for _, child in ipairs(billboard:GetChildren()) do
            child.Parent = fixedGui
        end

        billboard:Destroy()
    end
end

local staticSound = effectPart and effectPart:FindFirstChild("Static", true)
if staticSound and not staticSound:IsA("Sound") then
    staticSound = nil
end

local originalWalkSpeed = humanoid.WalkSpeed
local walkSpeedRestored = false
humanoid.WalkSpeed = -20

local walkSpeedConnection = RunService.Heartbeat:Connect(function()
    if humanoid.Parent then
        humanoid.WalkSpeed = -20
    end
end)

local function restoreWalkSpeed()
    if walkSpeedRestored then
        return
    end
    walkSpeedRestored = true
    walkSpeedConnection:Disconnect()
    if humanoid.Parent then
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

task.wait(1)

if humanoid.Health <= 0 or not model.Parent then
    restoreWalkSpeed()
    freezeConnection:Disconnect()
    model:Destroy()
    return
end

local oldCameraType = camera.CameraType
local oldCameraSubject = camera.CameraSubject
local oldMouseBehavior = UserInputService.MouseBehavior
local cameraPosition = camera.CFrame.Position

local gui = Instance.new("ScreenGui")
gui.Name = "LookTrapOverlay"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local blackout = Instance.new("Frame")
blackout.Name = "Blackout"
blackout.BackgroundColor3 = Color3.new(0, 0, 0)
blackout.BackgroundTransparency = 1
blackout.BorderSizePixel = 0
blackout.Size = UDim2.fromScale(1, 1)
blackout.ZIndex = 9
blackout.Parent = gui

local columns = 12
local rows = 8
local tileOrder = {}
local overlayImages = {}

for y = 0, rows - 1 do
    for x = 0, columns - 1 do
        table.insert(tileOrder, Vector2.new(x, y))
    end
end

for i = #tileOrder, 2, -1 do
    local j = math.random(1, i)
    tileOrder[i], tileOrder[j] = tileOrder[j], tileOrder[i]
end

local function fillTiles(targetCount)
    while #overlayImages < targetCount do
        local cell = tileOrder[#overlayImages + 1]
        if not cell then
            break
        end

        local image = Instance.new("ImageLabel")
        image.Name = "BlackImage"
        image.BackgroundTransparency = 1
        image.Image = "rbxassetid://12293713542"
        image.ImageColor3 = Color3.new(0, 0, 0)
        image.ScaleType = Enum.ScaleType.Crop
        image.Position = UDim2.fromScale(cell.X / columns, cell.Y / rows)
        image.Size = UDim2.fromScale(1 / columns + 0.002, 1 / rows + 0.002)
        image.ZIndex = 10
        image.Parent = gui
        table.insert(overlayImages, image)
    end
end

local imageBasePosition = playImage and playImage.Position

if playImage then
    playImage.Visible = true
end

local running = true
local resolved = false
local cleaning = false
local effort = 0
local yaw = 0
local pitch = 0
local inputConnection
local cameraConnection
local diedConnection

local function restoreCamera()
    if inputConnection then
        inputConnection:Disconnect()
        inputConnection = nil
    end
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    if diedConnection then
        diedConnection:Disconnect()
        diedConnection = nil
    end
    camera.CameraType = oldCameraType
    camera.CameraSubject = oldCameraSubject
    UserInputService.MouseBehavior = oldMouseBehavior
end

local function fadeAndRemove()
    if cleaning then
        return
    end
    cleaning = true
    running = false
    restoreWalkSpeed()
    freezeConnection:Disconnect()

    local fadeInfo = TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if blackout.Parent then
        TweenService:Create(blackout, fadeInfo, {BackgroundTransparency = 1}):Play()
    end

    for _, image in ipairs(overlayImages) do
        if image.Parent then
            TweenService:Create(image, fadeInfo, {ImageTransparency = 1}):Play()
        end
    end

    if playImage and playImage.Parent then
        TweenService:Create(playImage, fadeInfo, {ImageTransparency = 1}):Play()
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("Sound") then
            TweenService:Create(descendant, fadeInfo, {Volume = 0}):Play()
        elseif descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
            TweenService:Create(descendant, fadeInfo, {Transparency = 1}):Play()
        end
    end

    task.delay(0.7, function()
        if gui.Parent then
            gui:Destroy()
        end
        if model.Parent then
            model:Destroy()
        end
    end)
end

local function resolve(escaped)
    if resolved then
        return
    end
    resolved = true
    running = false
    restoreWalkSpeed()
    restoreCamera()

    if escaped then
        fadeAndRemove()
        return
    end

    fillTiles(#tileOrder)
    blackout.BackgroundTransparency = 0
    humanoid:TakeDamage(100)

    if staticSound and staticSound.Parent then
        staticSound.Looped = false
        local endedConnection
        endedConnection = staticSound.Ended:Connect(function()
            if endedConnection then
                endedConnection:Disconnect()
            end
            fadeAndRemove()
        end)
        staticSound:Play()
        task.delay(8, function()
            if endedConnection then
                endedConnection:Disconnect()
            end
            fadeAndRemove()
        end)
    else
        task.delay(0.5, fadeAndRemove)
    end
end

local function applySwipe(delta)
    if not running then
        return
    end

    local smallerSide = math.max(1, math.min(camera.ViewportSize.X, camera.ViewportSize.Y))
    local movement = delta.Magnitude
    effort = effort + math.min(movement / smallerSide, 0.8)
    yaw = math.clamp(yaw - delta.X * 0.003, -1.1, 1.1)
    pitch = math.clamp(pitch - delta.Y * 0.003, -0.85, 0.85)

    if effort >= escapeThreshold then
        resolve(true)
    end
end

camera.CameraType = Enum.CameraType.Scriptable
if UserInputService.MouseEnabled and not UserInputService.TouchEnabled then
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

local startTime = os.clock()

task.spawn(function()
    while running do
        local progress = math.clamp((os.clock() - startTime) / duration, 0, 1)
        local targetCount = math.max(1, math.floor(#tileOrder * progress ^ 3))
        fillTiles(targetCount)
        blackout.BackgroundTransparency = 1 - progress ^ 7
        task.wait(0.05)
    end
end)

inputConnection = UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        applySwipe(Vector2.new(input.Delta.X, input.Delta.Y))
    elseif input.UserInputType == Enum.UserInputType.MouseMovement then
        applySwipe(Vector2.new(input.Delta.X, input.Delta.Y))
    end
end)

cameraConnection = RunService.RenderStepped:Connect(function(dt)
    if not running then
        return
    end

    if not lookPart.Parent then
        resolve(true)
        return
    end

    yaw = yaw * math.exp(-10 * dt)
    pitch = pitch * math.exp(-10 * dt)
    effort = math.max(0, effort - 0.08 * dt)

    camera.CFrame = CFrame.lookAt(cameraPosition, lookPart.Position) * CFrame.Angles(pitch, yaw, 0)
    camera.Focus = CFrame.new(lookPart.Position)
end)

diedConnection = humanoid.Died:Connect(function()
    if not resolved then
        resolve(true)
    end
end)

if playImage then
    task.spawn(function()
        while running and playImage.Parent do
            local dx = math.random(-3, 3)
            playImage.Position = UDim2.new(
                imageBasePosition.X.Scale,
                imageBasePosition.X.Offset + dx,
                imageBasePosition.Y.Scale,
                imageBasePosition.Y.Offset
            )
            task.wait(0.03)
        end
    end)
end

task.delay(duration, function()
    if not resolved then
        resolve(false)
    end
end)
end

function entityBehaviors.Bite()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then
    return
end

local currentRooms = workspace:WaitForChild("CurrentRooms")
local latestRoom = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom")
local startRoom = latestRoom.Value

if workspace:FindFirstChild("SeekMovingNewClone") or currentRooms:FindFirstChild("50") then
    return
end

local room = currentRooms:FindFirstChild(tostring(startRoom))
    or currentRooms:WaitForChild(tostring(startRoom), 5)
if not room or latestRoom.Value ~= startRoom then
    return
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function findSpawnPart()
    local nodeFolder = room:FindFirstChild("Nodes") or room:FindFirstChild("PathfindNodes")
    if nodeFolder then
        local nodes = {}
        for _, node in ipairs(nodeFolder:GetChildren()) do
            if node:IsA("BasePart") then
                table.insert(nodes, node)
            end
        end
        table.sort(nodes, function(a, b)
            local na, nb = tonumber(a.Name), tonumber(b.Name)
            if na and nb then
                return na < nb
            elseif na then
                return true
            elseif nb then
                return false
            end
            return a.Name < b.Name
        end)
        if #nodes > 0 then
            return nodes[math.max(1, math.floor(#nodes / 2))]
        end
    end

    for _, name in ipairs({room.Name, "RoomEntrance", "RoomExit"}) do
        local part = room:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end

    return room.PrimaryPart
end

local spawnPart = findSpawnPart()
if not spawnPart then
    return
end

local loaded, objects = pcall(function()
    return game:GetObjects("rbxassetid://77820002550007")
end)

local model = loaded and objects and objects[1]
if not model or not model:IsA("Model") then
    return
end

local rushPart = model:FindFirstChild("RushNew", true)
if not rushPart or not rushPart:IsA("BasePart") then
    model:Destroy()
    return
end

local attachment = rushPart:FindFirstChild("Attachment", true)
local bitesTrail = attachment and attachment:FindFirstChild("Bites Trail", true)

local targetEmitter = rushPart:FindFirstChild("ParticleEmitter", true)
if not targetEmitter or not targetEmitter:IsA("ParticleEmitter") then
    targetEmitter = nil
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") and descendant.Name == "ParticleEmitter" then
            targetEmitter = descendant
            break
        end
    end
end

if not targetEmitter or not bitesTrail
    or not (bitesTrail:IsA("ParticleEmitter") or bitesTrail:IsA("Trail")) then
    model:Destroy()
    return
end

local lightSources = {}
local lightParts = {}

for _, descendant in ipairs(model:GetDescendants()) do
    if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
        descendant.Enabled = false
    elseif descendant:IsA("Light") then
        descendant.Enabled = true
        descendant.Brightness = math.max(1, descendant.Brightness)
        descendant.Range = math.max(12, descendant.Range)
        table.insert(lightSources, descendant)
    elseif descendant:IsA("BasePart") then
        descendant.Anchored = true
        if descendant.Name:lower() == "light" then
            descendant.Transparency = 0
            table.insert(lightParts, descendant)
        end
    elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
        descendant.Enabled = false
    end
end

model.Parent = workspace

local partOffset = model:GetPivot():ToObjectSpace(rushPart.CFrame)
local destination = spawnPart.CFrame + Vector3.new(0, 4, 0)
model:PivotTo(destination * partOffset:Inverse())

local monsterRoar = model:FindFirstChild("Monster Roar", true)
if monsterRoar and not monsterRoar:IsA("Sound") then
    monsterRoar = nil
end
if monsterRoar then
    monsterRoar:Stop()
end

local active = true
local cleaning = false
local roared = false
local roomConnection
local damageConnection
local diedConnection

local function playToggleSound()
    if not active or not rushPart.Parent then
        return
    end

    local sound = Instance.new("Sound")
    sound.Name = "RushSwitchSound"
    sound.SoundId = "rbxassetid://134847459602515"
    sound.Volume = 1
    sound.Looped = false
    sound.Parent = rushPart
    sound.Ended:Once(function()
        if sound.Parent then
            sound:Destroy()
        end
    end)
    sound:Play()

    task.delay(30, function()
        if sound.Parent then
            sound:Destroy()
        end
    end)
end

local function cleanup()
    if cleaning then
        return
    end

    cleaning = true
    active = false

    if roomConnection then
        roomConnection:Disconnect()
    end
    if damageConnection then
        damageConnection:Disconnect()
    end
    if diedConnection then
        diedConnection:Disconnect()
    end

    if bitesTrail.Parent then
        bitesTrail.Enabled = false
    end
    if targetEmitter.Parent then
        targetEmitter.Enabled = false
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
            descendant.Enabled = false
        end
    end

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, light in ipairs(lightSources) do
        if light.Parent then
            TweenService:Create(light, tweenInfo, {Range = 0, Brightness = 0}):Play()
        end
    end

    for _, part in ipairs(lightParts) do
        if part.Parent then
            local size = part.Size
            TweenService:Create(part, tweenInfo, {
                Transparency = 1,
                Size = Vector3.new(
                    math.max(0.05, size.X * 0.05),
                    math.max(0.05, size.Y * 0.05),
                    math.max(0.05, size.Z * 0.05)
                )
            }):Play()
        end
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("Sound") then
            TweenService:Create(descendant, tweenInfo, {Volume = 0}):Play()
        end
    end

    task.delay(1.1, function()
        if model.Parent then
            model:Destroy()
        end
    end)
end

roomConnection = latestRoom.Changed:Connect(function(newRoom)
    if newRoom ~= startRoom then
        cleanup()
    end
end)

diedConnection = humanoid.Died:Connect(function()
    if active and not roared then
        roared = true
        if monsterRoar and monsterRoar.Parent then
            monsterRoar.Looped = false
            monsterRoar:Stop()
            monsterRoar:Play()
        end
    end
end)

damageConnection = RunService.Heartbeat:Connect(function(dt)
    if not active then
        return
    end
    if not model.Parent then
        cleanup()
        return
    end
    if not targetEmitter.Parent or not targetEmitter.Enabled then
        return
    end
    if humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0.05 then
        humanoid:TakeDamage(60 * dt)
    end
end)

if latestRoom.Value ~= startRoom then
    cleanup()
    return
end

task.spawn(function()
    task.wait(0.8)
    if not active then
        return
    end

    bitesTrail.Enabled = true

    task.wait(0.8)
    if not active then
        return
    end

    targetEmitter.Enabled = true
    playToggleSound()

    while active do
        task.wait(7)
        if not active or not targetEmitter.Parent then
            break
        end
        targetEmitter.Enabled = not targetEmitter.Enabled
        playToggleSound()
    end
end)
end
function entityBehaviors.MEshis()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local TARGET_PLAYER = "goat_qiu"
local MODEL_ID = "rbxassetid://117182846262688"

local RIGHT_OFFSET = 5.5
local BACK_OFFSET = 4.5
local HEIGHT_OFFSET = 0

local FOLLOW_SMOOTHNESS = 5
local ROTATION_SMOOTHNESS = 4
local MOVEMENT_THRESHOLD = 0.6

local IDLE_DURATION = 30
local TALK_DURATION = 30
local TRANSITION_TIME = 0.45
local FADE_DURATION = 1.5

local targetPlayer = Players:WaitForChild(TARGET_PLAYER)

local success, model = pcall(function()
    return game:GetObjects(MODEL_ID)[1]
end)

if not success or not model then
    return
end

if not model:IsA("Model") then
    model:Destroy()
    return
end

model.Name = "PetFolDower_" .. TARGET_PLAYER
model.Parent = Workspace

local rootPart =
    model:FindFirstChild("HumanoidRootPart", true)
    or model:FindFirstChild("Root", true)
    or model.PrimaryPart
    or model:FindFirstChildWhichIsA("BasePart", true)

local animationController =
    model:FindFirstChildWhichIsA("AnimationController", true)

local animSaves = model:FindFirstChild("AnimSaves", true)

if not rootPart or not animationController or not animSaves then
    model:Destroy()
    return
end

local animator =
    animationController:FindFirstChildOfClass("Animator")

if not animator then
    animator = Instance.new("Animator")
    animator.Parent = animationController
end

local idleAnimation = animSaves:FindFirstChild("idle")
local talkStartAnimation = animSaves:FindFirstChild("talk start")
local talkLoopAnimation = animSaves:FindFirstChild("talk loop")
local talkEndAnimation = animSaves:FindFirstChild("talk end")

if not idleAnimation
    or not talkStartAnimation
    or not talkLoopAnimation
    or not talkEndAnimation then

    model:Destroy()
    return
end

model.PrimaryPart = rootPart

for _, part in ipairs(model:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Anchored = part == rootPart
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false

        if part ~= rootPart then
            part.Massless = true
        end
    end
end

local alive = true
local followConnection = nil
local animationConnection = nil
local deathConnection = nil
local characterConnection = nil

local lastPlayerRoot = nil
local lastPlayerPosition = nil

local currentPosition = nil
local targetPosition = nil
local currentRotation = nil
local targetRotation = nil

local activeAnimation = nil
local motorMap = {}
local motors = {}
local animationCache = {}

local EasingStyleMap = {
    [Enum.PoseEasingStyle.Linear] = Enum.EasingStyle.Linear,
    [Enum.PoseEasingStyle.Bounce] = Enum.EasingStyle.Bounce,
    [Enum.PoseEasingStyle.Cubic] = Enum.EasingStyle.Cubic,
    [Enum.PoseEasingStyle.Elastic] = Enum.EasingStyle.Elastic
}

local EasingDirectionMap = {
    [Enum.PoseEasingDirection.In] = Enum.EasingDirection.In,
    [Enum.PoseEasingDirection.Out] = Enum.EasingDirection.Out,
    [Enum.PoseEasingDirection.InOut] = Enum.EasingDirection.InOut
}

for _, joint in ipairs(model:GetDescendants()) do
    if joint:IsA("Motor6D") and joint.Part0 and joint.Part1 then
        local key =
            joint.Part0.Name .. "\0" .. joint.Part1.Name

        motorMap[key] = joint
        table.insert(motors, joint)
    end
end

local function getFlatCFrame(root)
    local look = root.CFrame.LookVector
    local flatLook = Vector3.new(look.X, 0, look.Z)

    if flatLook.Magnitude < 0.001 then
        flatLook = Vector3.new(0, 0, -1)
    end

    return CFrame.lookAt(
        root.Position,
        root.Position + flatLook.Unit
    )
end

local function getFollowTarget(root)
    local base = getFlatCFrame(root)

    local offset = base * CFrame.new(
        RIGHT_OFFSET,
        HEIGHT_OFFSET,
        BACK_OFFSET
    )

    return offset.Position, base.Rotation
end

local function setModelCFrame(position, rotation)
    if not alive or not rootPart.Parent then
        return
    end

    rootPart.CFrame = CFrame.new(position) * rotation
end

local function initializeFollower(root)
    local position, rotation = getFollowTarget(root)

    currentPosition = position
    targetPosition = position

    currentRotation = rotation
    targetRotation = rotation

    lastPlayerPosition = root.Position
    lastPlayerRoot = root

    setModelCFrame(position, rotation)
end

local function prepareKeyframeSequence(sequence)
    if animationCache[sequence] then
        return animationCache[sequence]
    end

    local keyframes = sequence:GetKeyframes()

    table.sort(keyframes, function(a, b)
        return a.Time < b.Time
    end)

    local poseTracks = {}

    for _, keyframe in ipairs(keyframes) do
        for _, pose in ipairs(keyframe:GetDescendants()) do
            if pose:IsA("Pose") and pose.Weight > 0 then
                local parent = pose.Parent

                if parent and parent:IsA("Pose") then
                    local key =
                        parent.Name .. "\0" .. pose.Name

                    local motor = motorMap[key]

                    if motor then
                        if not poseTracks[motor] then
                            poseTracks[motor] = {}
                        end

                        table.insert(poseTracks[motor], {
                            Time = keyframe.Time,
                            CFrame = pose.CFrame,
                            Style = pose.EasingStyle,
                            Direction = pose.EasingDirection
                        })
                    end
                end
            end
        end
    end

    for _, frames in pairs(poseTracks) do
        table.sort(frames, function(a, b)
            return a.Time < b.Time
        end)
    end

    local duration = 0

    if #keyframes > 0 then
        duration = keyframes[#keyframes].Time
    end

    local data = {
        Duration = duration,
        Tracks = poseTracks
    }

    animationCache[sequence] = data

    return data
end

local function evaluatePose(frames, timePosition)
    if not frames or #frames == 0 then
        return CFrame.new()
    end

    if timePosition <= frames[1].Time then
        return frames[1].CFrame
    end

    if timePosition >= frames[#frames].Time then
        return frames[#frames].CFrame
    end

    for i = 1, #frames - 1 do
        local first = frames[i]
        local second = frames[i + 1]

        if timePosition >= first.Time
            and timePosition <= second.Time then

            local duration = second.Time - first.Time

            if duration <= 0 then
                return second.CFrame
            end

            local alpha = math.clamp(
                (timePosition - first.Time) / duration,
                0,
                1
            )

            if second.Style == Enum.PoseEasingStyle.Constant then
                alpha = alpha >= 1 and 1 or 0
            else
                alpha = TweenService:GetValue(
                    alpha,
                    EasingStyleMap[second.Style]
                        or Enum.EasingStyle.Linear,
                    EasingDirectionMap[second.Direction]
                        or Enum.EasingDirection.InOut
                )
            end

            return first.CFrame:Lerp(
                second.CFrame,
                alpha
            )
        end
    end

    return frames[#frames].CFrame
end

local function stopAnimation(immediate)
    if not activeAnimation then
        return
    end

    local old = activeAnimation
    activeAnimation = nil

    if old.Kind == "Animation" and old.Track then
        local fadeTime = immediate and 0.05 or TRANSITION_TIME

        old.Track:Stop(fadeTime)

        task.delay(fadeTime + 0.1, function()
            pcall(function()
                old.Track:Destroy()
            end)
        end)
    end
end

local function playAnimation(animationObject, looped)
    if not alive or not model.Parent then
        return nil
    end

    local previous = activeAnimation

    if animationObject:IsA("KeyframeSequence") then
        local data = prepareKeyframeSequence(animationObject)

        if previous and previous.Kind == "Animation" then
            stopAnimation(false)
        end

        local startingPoses = {}

        for _, motor in ipairs(motors) do
            if motor.Parent then
                startingPoses[motor] = motor.Transform
            end
        end

        local state = {
            Kind = "Keyframe",
            Data = data,
            Duration = data.Duration,
            Elapsed = 0,
            Started = os.clock(),
            Looped = looped,
            StartingPoses = startingPoses,
            BlendDuration = TRANSITION_TIME
        }

        activeAnimation = state

        return state
    end

    if animationObject:IsA("Animation") then
        local loaded, track = pcall(function()
            return animator:LoadAnimation(animationObject)
        end)

        if not loaded or not track then
            return nil
        end

        track.Priority = Enum.AnimationPriority.Action
        track.Looped = looped

        local state = {
            Kind = "Animation",
            Track = track,
            Started = os.clock(),
            Looped = looped
        }

        activeAnimation = state

        track:Play(TRANSITION_TIME, 1, 1)

        if previous and previous.Kind == "Animation" then
            local oldTrack = previous.Track

            oldTrack:Stop(TRANSITION_TIME)

            task.delay(TRANSITION_TIME + 0.1, function()
                pcall(function()
                    oldTrack:Destroy()
                end)
            end)
        end

        return state
    end

    return nil
end

animationConnection = RunService.PreSimulation:Connect(function(dt)
    if not alive or not model.Parent then
        return
    end

    local state = activeAnimation

    if not state or state.Kind ~= "Keyframe" then
        return
    end

    state.Elapsed = state.Elapsed + dt

    local duration = state.Duration
    local timePosition = 0

    if duration > 0 then
        if state.Looped then
            timePosition = state.Elapsed % duration
        else
            timePosition = math.min(state.Elapsed, duration)
        end
    end

    local blendAlpha = math.clamp(
        state.Elapsed / math.max(state.BlendDuration, 0.001),
        0,
        1
    )

    blendAlpha = TweenService:GetValue(
        blendAlpha,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    )

    for _, motor in ipairs(motors) do
        if motor.Parent then
            local frames = state.Data.Tracks[motor]
            local targetPose = evaluatePose(
                frames,
                timePosition
            )

            if blendAlpha < 1 then
                local startingPose =
                    state.StartingPoses[motor]
                    or CFrame.new()

                motor.Transform = startingPose:Lerp(
                    targetPose,
                    blendAlpha
                )
            else
                motor.Transform = targetPose
            end
        end
    end
end)

local function waitAlive(duration)
    local deadline = os.clock() + duration

    while alive
        and model.Parent
        and os.clock() < deadline do

        task.wait(0.03)
    end

    return alive and model.Parent ~= nil
end

local function waitForAnimationEnding(state)
    if not state then
        return alive
    end

    local startTime = os.clock()

    while alive and model.Parent and activeAnimation == state do
        local elapsed = os.clock() - startTime
        local duration = 0

        if state.Kind == "Keyframe" then
            duration = state.Duration
        elseif state.Kind == "Animation" then
            duration = state.Track.Length
        end

        if duration > 0 then
            local transitionStart = math.max(
                0,
                duration - TRANSITION_TIME * 0.65
            )

            if elapsed >= transitionStart then
                break
            end
        elseif elapsed >= 8 then
            break
        end

        if state.Kind == "Animation"
            and not state.Track.IsPlaying
            and elapsed > 0.2 then
            break
        end

        task.wait(0.03)
    end

    return alive and model.Parent ~= nil
end

local function fadeAndDestroy()
    if not alive then
        return
    end

    alive = false

    stopAnimation(true)

    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end

    if animationConnection then
        animationConnection:Disconnect()
        animationConnection = nil
    end

    if deathConnection then
        deathConnection:Disconnect()
        deathConnection = nil
    end

    if characterConnection then
        characterConnection:Disconnect()
        characterConnection = nil
    end

    local tweenInfo = TweenInfo.new(
        FADE_DURATION,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    for _, instance in ipairs(model:GetDescendants()) do
        if instance:IsA("BasePart")
            or instance:IsA("Decal")
            or instance:IsA("Texture") then

            TweenService:Create(
                instance,
                tweenInfo,
                {
                    Transparency = 1
                }
            ):Play()
        end
    end

    task.wait(FADE_DURATION)

    if model.Parent then
        model:Destroy()
    end
end

local function bindCharacter(character)
    if deathConnection then
        deathConnection:Disconnect()
        deathConnection = nil
    end

    lastPlayerRoot = nil
    lastPlayerPosition = nil

    task.spawn(function()
        local humanoid = character:WaitForChild("Humanoid", 10)

        if not humanoid or not alive then
            return
        end

        if targetPlayer.Character ~= character then
            return
        end

        if humanoid.Health <= 0 then
            fadeAndDestroy()
            return
        end

        deathConnection = humanoid.Died:Connect(function()
            fadeAndDestroy()
        end)
    end)
end

characterConnection = targetPlayer.CharacterAdded:Connect(
    bindCharacter
)

if targetPlayer.Character then
    bindCharacter(targetPlayer.Character)
end

followConnection = RunService.RenderStepped:Connect(function(dt)
    if not alive or not model.Parent then
        return
    end

    local character = targetPlayer.Character

    if not character then
        return
    end

    local playerRoot =
        character:FindFirstChild("HumanoidRootPart")

    if not playerRoot then
        return
    end

    if playerRoot ~= lastPlayerRoot then
        initializeFollower(playerRoot)
        return
    end

    local playerPosition = playerRoot.Position
    local displacement = playerPosition - lastPlayerPosition

    local horizontalDisplacement = Vector3.new(
        displacement.X,
        0,
        displacement.Z
    )

    local playerSpeed =
        horizontalDisplacement.Magnitude
        / math.max(dt, 0.001)

    local isMoving = playerSpeed > MOVEMENT_THRESHOLD

    if isMoving then
        local newPosition, newRotation =
            getFollowTarget(playerRoot)

        targetPosition = newPosition
        targetRotation = newRotation
    else
        targetRotation = currentRotation
    end

    lastPlayerPosition = playerPosition

    local distance =
        (targetPosition - currentPosition).Magnitude

    local adaptiveSmoothness =
        FOLLOW_SMOOTHNESS
        + math.min(distance * 0.15, 4)

    local positionAlpha =
        1 - math.exp(-adaptiveSmoothness * dt)

    local rotationAlpha =
        1 - math.exp(-ROTATION_SMOOTHNESS * dt)

    currentPosition = currentPosition:Lerp(
        targetPosition,
        positionAlpha
    )

    currentRotation = currentRotation:Lerp(
        targetRotation,
        rotationAlpha
    )

    setModelCFrame(
        currentPosition,
        currentRotation
    )
end)

task.spawn(function()
    while alive and model.Parent do
        playAnimation(idleAnimation, true)

        if not waitAlive(IDLE_DURATION) then
            break
        end

        local talkStart = playAnimation(
            talkStartAnimation,
            false
        )

        if not waitForAnimationEnding(talkStart) then
            break
        end

        playAnimation(talkLoopAnimation, true)

        if not waitAlive(TALK_DURATION) then
            break
        end

        local talkEnd = playAnimation(
            talkEndAnimation,
            false
        )

        if not waitForAnimationEnding(talkEnd) then
            break
        end
    end

    stopAnimation(true)
end)
end

function entityBehaviors.MESHI()
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local MODEL_NAME = "PetFolDower_goat_qiu"
local SOUND_ID = "rbxassetid://131999546232546"

local SOUND_START = 3.8
local JEFF_START = 4
local JEFF_MOVE_DURATION = 2
local ATTACH_OFFSET = CFrame.new(0, 0, 0)

local function isValidModel(instance)
    if not instance:IsA("Model") then
        return false
    end

    local arm = instance:FindFirstChild("RLowerArm", true)

    return arm ~= nil and arm:IsA("BasePart")
end

local function findModel()
    local named = Workspace:FindFirstChild(MODEL_NAME, true)

    if named and isValidModel(named) then
        return named
    end

    local alternate =
        Workspace:FindFirstChild("PetFolDower_QWQ75321", true)

    if alternate and isValidModel(alternate) then
        return alternate
    end

    for _, instance in ipairs(Workspace:GetDescendants()) do
        if isValidModel(instance)
            and instance:FindFirstChild("AnimSaves", true) then
            return instance
        end
    end

    return nil
end

local model
local deadline = os.clock() + 30

while os.clock() < deadline do
    model = findModel()

    if model then
        break
    end

    task.wait(0.25)
end

if not model then
    return
end

local arm = model:FindFirstChild("RLowerArm", true)

if not arm or not arm:IsA("BasePart") then
    return
end

local function playEffectSound()
    if not model.Parent or not arm.Parent then
        return
    end

    local sound = Instance.new("Sound")
    sound.Name = "DreamyEffectSound"
    sound.SoundId = SOUND_ID
    sound.Volume = 1
    sound.Looped = false
    sound.Parent = arm

    sound.Ended:Once(function()
        if sound.Parent then
            sound:Destroy()
        end
    end)

    sound:Play()

    task.delay(30, function()
        if sound.Parent then
            sound:Destroy()
        end
    end)
end

local jeffFollowConnection = nil
local jeffAttached = false
local jeffMoving = false

local function moveJeffToArm()
    if jeffAttached or jeffMoving then
        return
    end

    local jeff = Workspace:FindFirstChild("JeffTheKiller")

    if not jeff then
        return
    end

    if not jeff:IsA("Model")
        and not jeff:IsA("BasePart") then
        return
    end

    jeffMoving = true

    local function preparePart(part)
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
    end

    if jeff:IsA("BasePart") then
        preparePart(jeff)
    else
        for _, part in ipairs(jeff:GetDescendants()) do
            if part:IsA("BasePart") then
                preparePart(part)
            end
        end
    end

    local startPivot = jeff:GetPivot()
    local startPosition = startPivot.Position
    local startRotation = startPivot.Rotation

    local elapsed = 0

    while elapsed < JEFF_MOVE_DURATION
        and jeff.Parent
        and arm.Parent
        and model.Parent do

        local dt = RunService.Heartbeat:Wait()

        elapsed = math.min(
            elapsed + dt,
            JEFF_MOVE_DURATION
        )

        local alpha = math.clamp(
            elapsed / JEFF_MOVE_DURATION,
            0,
            1
        )

        local eased = TweenService:GetValue(
            alpha,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )

        local target = arm.CFrame * ATTACH_OFFSET

        local position = startPosition:Lerp(
            target.Position,
            eased
        )

        local rotation = startRotation:Lerp(
            target.Rotation,
            eased
        )

        local spin = CFrame.Angles(
            0,
            math.pi * 2 * eased,
            0
        )

        jeff:PivotTo(
            CFrame.new(position)
            * rotation
            * spin
        )
    end

    jeffMoving = false

    if not jeff.Parent or not arm.Parent or not model.Parent then
        return
    end

    jeff:PivotTo(arm.CFrame * ATTACH_OFFSET)

    jeffAttached = true

    if jeffFollowConnection then
        jeffFollowConnection:Disconnect()
        jeffFollowConnection = nil
    end

    jeffFollowConnection = RunService.RenderStepped:Connect(function()
        if not jeff.Parent or not arm.Parent or not model.Parent then
            if jeffFollowConnection then
                jeffFollowConnection:Disconnect()
                jeffFollowConnection = nil
            end

            jeffAttached = false
            return
        end

        jeff:PivotTo(
            arm.CFrame * ATTACH_OFFSET
        )
    end)
end

task.delay(SOUND_START, function()
    playEffectSound()
end)

task.delay(JEFF_START, function()
    moveJeffToArm()
end)
end
function entityBehaviors.Limbo()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraShaker = require(
	ReplicatedStorage:WaitForChild("CameraShaker")
)

local WalkSpeedControl = true

local Lighting = game:GetService("Lighting")

local VignetteColor = Color3.fromRGB(96, 0, 150)
local MaxBlur = 14
local MaxSaturation = -0.45

local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Name = "LimboSickness"
ColorCorrection.TintColor = Color3.fromRGB(255,255,255)
ColorCorrection.Saturation = 0
ColorCorrection.Parent = Lighting

local Blur = Instance.new("BlurEffect")
Blur.Name = "LimboBlur"
Blur.Size = 0
Blur.Parent = Lighting

local EffectTween

local function UpdateEffect(value)
	value = math.clamp(value, 0, 1)

	ColorCorrection.TintColor =
		Color3.fromRGB(255,255,255):Lerp(VignetteColor, value)

	ColorCorrection.Saturation = MaxSaturation * value
	Blur.Size = MaxBlur * value
end

local Camera = workspace.CurrentCamera

local CameraShake = CameraShaker.new(
	Enum.RenderPriority.Camera.Value,
	function(cf)
		Camera.CFrame *= cf
	end
)

CameraShake:Start()

CameraShake:ShakeOnce(
	10,
	2,
	0.3,
	3
)

local HardCoreSound = workspace:WaitForChild("HardCoreSound", 15)
assert(HardCoreSound, "[Limbo] Missing Workspace.HardCoreSound")

local function GetHardCoreSound(name)
    local sound = HardCoreSound:WaitForChild(name, 15)
    assert(sound and sound:IsA("Sound"),
        "[Limbo] Expected Sound at Workspace.HardCoreSound." .. name)
    return sound
end

local StormTemplate = GetHardCoreSound("LimboStorm")
local ThemeSound = GetHardCoreSound("LimboTheme")
local BlaBoomSound = GetHardCoreSound("LimboBlaBoom")
local EndSound = GetHardCoreSound("LimboEnd")
local JumpscareSound = GetHardCoreSound("LimboJumpsjc")

local function PlayFromStart(sound)
    sound:Stop()
    sound.TimePosition = 0
    sound:Play()
end

local function PlayOneShot(sound)
    sound.Looped = false
    sound.Ended:Once(function()
        if sound.Parent then
            sound:Stop()
            sound.TimePosition = 0
        end
    end)
    PlayFromStart(sound)
end

local LimboOwnedSounds = setmetatable({}, {__mode = "k"})

local function OwnLimboSound(sound)
    LimboOwnedSounds[sound] = true
    return sound
end

local function DestroyLimboSound(sound)
    if not sound then return end
    LimboOwnedSounds[sound] = nil
    if sound.Parent then
        sound:Stop()
        sound:Destroy()
    end
end

local function CleanupLimboSounds()
    for sound in pairs(LimboOwnedSounds) do
        DestroyLimboSound(sound)
    end
end

local WindowLights = {}
local WindowModels = {}
local CreatedLights = {}
local NeonOriginalColors = {}
local HitboxDisabled = false
local LightStandMap = {}
local LightOriginalColors = {}

local LightStandOriginalColors = {}
local LightStandNeons = {}

local DimNeonColor = Color3.fromRGB(127, 105, 92)
local WindowParticles = {}
local ParticleOriginalColors = {}
local FixtureLights = {}
local FixtureLightOriginalColors = {}
local ThemeEndedCount = 0
local RoomConnection
local RoomRemovalConnection
local BarDestroyed = false

local TweenService = game:GetService("TweenService")
local LocalPlayer = game.Players.LocalPlayer

local t2 = {
	BarColor = Color3.fromRGB(126, 34, 206),
	BarBackground = Color3.fromRGB(18, 4, 26)
}

local StormParts = {}
local StormPartByRoom = setmetatable({}, {__mode = "k"})
local NeonParts = {}

local function ProcessLightStands(room)
	for _, stand in ipairs(room:GetDescendants()) do
		if stand:IsA("Model") and (stand.Name == "LightStand" or stand.Name == "Chandelier") then
			for _, obj in ipairs(stand:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name == "Neon" then
					if not LightStandOriginalColors[obj] then
						LightStandOriginalColors[obj] = obj.Color
						LightStandNeons[#LightStandNeons + 1] = obj
					end

					TweenService:Create(
						obj,
						TweenInfo.new(
							0.8,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							Color = DimNeonColor
						}
					):Play()

				elseif obj:IsA("PointLight") then
					if not LightStandOriginalColors[obj] then
						LightStandOriginalColors[obj] = obj.Color
					end

					TweenService:Create(
						obj,
						TweenInfo.new(
							0.8,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							Color = DimNeonColor
						}
					):Play()
				end
			end
		end
	end
end

local LimboBar = Instance.new("ScreenGui")
LimboBar.Name = "LimboBar"
LimboBar.ResetOnSpawn = false
LimboBar.IgnoreGuiInset = true
LimboBar.DisplayOrder = 12
LimboBar.Parent = LocalPlayer:WaitForChild("PlayerGui")


local Holder = Instance.new("Frame")
Holder.Name = "Holder"
Holder.AnchorPoint = Vector2.new(0, 0.5)
Holder.Position = UDim2.new(-0.12, 0, 0.5, 0)
Holder.Size = UDim2.new(0, 22, 0.55, 0)
Holder.BackgroundColor3 = t2.BarBackground
Holder.BackgroundTransparency = 0.3
Holder.BorderSizePixel = 0
Holder.Parent = LimboBar


local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Holder


local UIStroke = Instance.new("UIStroke")
UIStroke.Color = t2.BarColor
UIStroke.Thickness = 2
UIStroke.Parent = Holder


local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingBottom = UDim.new(0,3)
UIPadding.PaddingTop = UDim.new(0,3)
UIPadding.PaddingLeft = UDim.new(0,3)
UIPadding.PaddingRight = UDim.new(0,3)
UIPadding.Parent = Holder


local Fill = Instance.new("Frame")
Fill.Name = "Fill"
Fill.AnchorPoint = Vector2.new(0.5,1)
Fill.Position = UDim2.new(0.5,0,1,0)
Fill.Size = UDim2.new(1,0,0,0)
Fill.BackgroundColor3 = t2.BarColor
Fill.BorderSizePixel = 0
Fill.Parent = Holder


local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0,5)
UICorner2.Parent = Fill

local OverlayTween


TweenService:Create(
	Holder,
	TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{
		Position = UDim2.new(0, 3, 0.5, 0)
	}
):Play()

local function TweenBarPercent(percent, speed)
	percent = math.clamp(percent, 0, 100)

	TweenService:Create(
		Fill,
		TweenInfo.new(
			speed or 0.5,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.new(1, 0, percent / 100, 0)
		}
	):Play()
end

local StormRange = 65
local MaxBar = 100
local StormSpeed = 40 / 3.5
local LightningRadius = 65
local StormProgress = 0

local BarDecayDelay = 10
local BarDecaySpeed = 2.35
local BarStableTime = 0
local BarDecaying = false
local LastBarProgress = 0


local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude

local function IsInStormRange(hrp)
	if HitboxDisabled then
		return false
	end

	RayParams.FilterDescendantsInstances = {
		LocalPlayer.Character
	}

	for _, light in ipairs(WindowLights) do
		if light.Parent and light.Enabled then
			local part = light.Parent

			if part:IsA("Attachment") then
				part = part.Parent
			end

			if part:IsA("BasePart") then
				local offset = hrp.Position - part.Position
				local dist = offset.Magnitude

				if dist <= (light.Range * 0.9) then
					local direction = offset.Unit
					local forward = part.CFrame.LookVector

					local angle = math.deg(
						math.acos(
							math.clamp(forward:Dot(direction), -1, 1)
						)
					)

					if angle <= light.Angle / 2.5 then
						
						local ray = workspace:Raycast(
							part.Position,
							offset,
							RayParams
						)

						if not ray then
							return true
						end

						local hit = ray.Instance

						if hit:IsDescendantOf(part.Parent) then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

local rooms = workspace:FindFirstChild("CurrentRooms")
local Storm = StormTemplate -- source for positional copies (one per windowed room)
local Shutdown = false
local BlaBoom = BlaBoomSound
BlaBoom.Looped = false

local BlaBoomPlaying = false
local BlaBoomCooldown = math.random(20, 30)
local BlaBoomCooldownRunning = false

local function GetPlayerRoom()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hrp or not rooms then
		return nil
	end

	for _, room in ipairs(rooms:GetChildren()) do
		if room:IsA("Model") then
			local cf, size = room:GetBoundingBox()
			local pos = cf:PointToObjectSpace(hrp.Position)

			if math.abs(pos.X) <= size.X / 2
				and math.abs(pos.Y) <= size.Y / 2
				and math.abs(pos.Z) <= size.Z / 2 then
				return room
			end
		end
	end

	return nil
end

local function CanBlaBoomPlay()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hrp or not rooms then
		return false
	end

	if char:GetAttribute("Hiding") == true then
		return false
	end

	local room = GetPlayerRoom()

	if not room then
		return false
	end

	local HasWindow = false

	for _, obj in ipairs(room:GetDescendants()) do
		if obj:IsA("Model") then
			if obj.Name == "Windows"
				or obj.Name == "Window"
				or obj.Name == "Window_Tall" then
				HasWindow = true
				break
			end
		end
	end

	if not HasWindow then
		return true
	end

	return not IsInStormRange(hrp)
end

task.spawn(function()
	while not Shutdown do
		local allowed = CanBlaBoomPlay()

		if BlaBoomPlaying then
			if allowed then
				if BlaBoom.IsPaused then
					BlaBoom:Resume()
				end
			else
				if BlaBoom.IsPlaying then
					BlaBoom:Pause()
				end
			end
		else
			if allowed then
				BlaBoomCooldownRunning = true
				BlaBoomCooldown -= 0.1

				if BlaBoomCooldown <= 0 then
					BlaBoomCooldown = 0
					BlaBoomPlaying = true
					BlaBoomCooldownRunning = false
					PlayFromStart(BlaBoom)
				
					
					CameraShake:ShakeOnce(
	10,
	20,
	0.1,
	2
)

					BlaBoom.Ended:Once(function()
						if Shutdown then
							return
						end

						BlaBoomPlaying = false
						BlaBoomCooldown = math.random(20, 30)
						BlaBoomCooldownRunning = true
					end)
				end
			else
				BlaBoomCooldownRunning = false
			end
		end

		task.wait(0.1)
	end
end)

local theme = ThemeSound
-- Required: Ended must fire for the 1- or 2-play shutdown rules.
theme.Looped = false

local ThemeEndMode = math.random(1, 3)
local ThemeSecondPlayed = false
local ThemeShutdownScheduled = false

if not theme.IsLoaded then
	theme.Loaded:Wait()
end

PlayFromStart(theme)

local function TweenFade() 
	local tween = TweenService:Create(
		Holder,
		TweenInfo.new(
			0.6,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		),
		{
			Position = UDim2.new(-0.12,0,0.5,0)
		}
	)
	
	tween:Play() 
	
	tween.Completed:Wait()

	if LimboBar then
		LimboBar:Destroy()
	end
end

local Flickering = false
local StopRequested = false

local function ShutdownStorm()
	if Shutdown then
		return
	end
	
		WalkSpeedControl = false
	
	if ColorCorrection then
	ColorCorrection:Destroy()
end

if Blur then
	Blur:Destroy()
end
	
    Shutdown = true
    Flickering = false
    StopRequested = true

    -- Stop reusable event sounds, but do not delete the folder assets.
    BlaBoom:Stop()
    BlaBoom.TimePosition = 0
    theme:Stop()
    theme.TimePosition = 0

    task.spawn(function()
        PlayOneShot(EndSound)
    end)

	TweenFade() 

    -- A name-based workspace scan could destroy someone else's sounds.
    -- Clean up only sounds made/cloned by this Limbo instance.
    if RoomRemovalConnection then
        RoomRemovalConnection:Disconnect()
        RoomRemovalConnection = nil
    end
    CleanupLimboSounds()

	for _, light in ipairs(CreatedLights) do
		if light and light.Parent then
			light:Destroy()
		end
	end

	for _, part in ipairs(StormParts) do
		if part and part.Parent then
			part:Destroy()
		end
	end
	
	for part, color in pairs(NeonOriginalColors) do
		if part and part.Parent then
			part.Color = color
		end
	end

	for light, color in pairs(LightOriginalColors) do
		if light and light.Parent then
			light.Color = color
		end
	end

	for light, color in pairs(FixtureLightOriginalColors) do
		if light and light.Parent then
			TweenService:Create(
				light,
				TweenInfo.new(1, Enum.EasingStyle.Linear),
				{
					Color = color
				}
			):Play()
		end
	end

	for particle, color in pairs(ParticleOriginalColors) do
		if particle and particle.Parent then
			particle.Color = color
		end
	end
	
	for obj, color in pairs(LightStandOriginalColors) do
	if obj and obj.Parent then
		TweenService:Create(
			obj,
			TweenInfo.new(
				0.8,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Color = color
			}
		):Play()
	end
end

	table.clear(WindowLights)
	table.clear(StormParts)
	table.clear(WindowModels)
	table.clear(CreatedLights)
	table.clear(NeonOriginalColors)
	table.clear(NeonParts)
	table.clear(WindowParticles)
	table.clear(ParticleOriginalColors)

	Shake = 0
end


theme.Ended:Connect(function()
	if Shutdown then
		return
	end

	ThemeEndedCount += 1

	if ThemeEndedCount == 1 then
		if ThemeEndMode == 1 then
			if Flickering then
				repeat
					task.wait()
				until not Flickering
			end

			if RoomConnection then
				RoomConnection:Disconnect()
				RoomConnection = nil
			end

			ShutdownStorm()
			return
		end

		ThemeSecondPlayed = true

		if not theme.IsLoaded then
			theme.Loaded:Wait()
		end

		theme.TimePosition = 0
		theme:Play()

		if ThemeEndMode == 2 then
			local length = theme.TimeLength

			if length > 0 then
				task.delay(length / 2, function()
					if Shutdown or ThemeShutdownScheduled then
						return
					end

					ThemeShutdownScheduled = true

					if Flickering then
						repeat
							task.wait()
						until not Flickering or Shutdown
					end

					if not Shutdown then
						if RoomConnection then
							RoomConnection:Disconnect()
							RoomConnection = nil
						end

						ShutdownStorm()
					end
				end)
			end
		end

		return
	end

	if ThemeEndedCount == 2 then
		if ThemeEndMode == 3 then
			if Flickering then
				repeat
					task.wait()
				until not Flickering or Shutdown
			end

			if Shutdown then
				return
			end

			if RoomConnection then
				RoomConnection:Disconnect()
				RoomConnection = nil
			end

			ShutdownStorm()
		end
	end
end)

if not rooms then
	return
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Camera = workspace.CurrentCamera

local Shake = 0
local MaxDist = 85
	
task.spawn(function()
	-- Fixed 10-second attack starts; keep original 3.5-second attack and fade-out.
	local nextAttackAt = os.clock() + 10
	while not Shutdown do
		task.wait(math.max(0, nextAttackAt - os.clock()))
		if Shutdown then break end
		nextAttackAt = os.clock() + 10

		Flickering = true
		
		for _, part in ipairs(workspace:GetChildren()) do
			if part.Name == "StormPart" then
				local sound = part:FindFirstChild("Storm")

				if sound and not sound.IsPlaying then
					sound:Play()
				end
			end
		end

		task.wait(3.5)

		StopRequested = true

		repeat
			task.wait()
		until not Flickering or Shutdown

		StopRequested = false
	end
end)

local SkyBoxOriginalColors = {}
local AmbientSkyboxTweens = {}  -- only used to avoid an ambient flash overriding attack white

local function FlashWindowSkyBoxes()
	for _, window in ipairs(WindowModels) do
		if window and window.Parent then
			for _, obj in ipairs(window:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name == "Skybox" then
					if not SkyBoxOriginalColors[obj] then
						SkyBoxOriginalColors[obj] = obj.Color
					end

					-- Cancel any earlier ambient Skybox color tween before applying solid white.
					local ambientTween = AmbientSkyboxTweens[obj]
					if ambientTween then
						ambientTween:Cancel()
						AmbientSkyboxTweens[obj] = nil
					end
					obj.Color = Color3.new(1, 1, 1)
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		if not Flickering then
			task.wait()
			continue
		end
	

		for _, light in ipairs(WindowLights) do
			if light.Parent then
				light.Enabled = true
			end
		end

		while Flickering do
	if Shutdown then
		return
	end
	
	task.spawn(function() 
	task.wait(0.1)
	FlashWindowSkyBoxes()
	end) 

	for _, light in ipairs(WindowLights) do
	if light.Parent then
		light.Brightness = 5
	end
end

			local tweens = {}

			for _, light in ipairs(WindowLights) do
				if light.Parent then
					light.Brightness = 5

					tweens[#tweens + 1] = TweenService:Create(
						light,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear),
						{
							Brightness = 0
						}
					)
				end
			end

			for _, tween in ipairs(tweens) do
				tween:Play()
			end

			if #tweens > 0 then
				tweens[1].Completed:Wait()
			end

			if StopRequested then
				break
			end
		end

		for _, light in ipairs(WindowLights) do
	if light.Parent then
		light.Brightness = 5
	end
end

local fades = {}

for _, light in ipairs(WindowLights) do
	if light.Parent then
		local tween = TweenService:Create(
			light,
			TweenInfo.new(1, Enum.EasingStyle.Linear),
			{
				Brightness = 0
			}
		)

		fades[#fades + 1] = tween
		tween:Play()
	end
end

for obj, originalColor in pairs(SkyBoxOriginalColors) do
	if obj and obj.Parent then
		TweenService:Create(
			obj,
			TweenInfo.new(
				1.5,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.Out
			),
			{
				Color = originalColor
			}
		):Play()
	end
end

if #fades > 0 then
	fades[1].Completed:Wait()
end

		for _, light in ipairs(WindowLights) do
			if light.Parent then
				light.Enabled = false
			end
		end

		Flickering = false
		
		for _, part in ipairs(workspace:GetChildren()) do
			if part.Name == "StormPart" then
				local sound = part:FindFirstChild("Storm")

				if sound then
					sound:Stop()
				end
			end
		end
	end
end)

-- 2. Phần xử lí room (Gộp logic xử lý từng phòng vào 1 hàm)
local function ProcessRoom(room)
	if not room:IsA("Model") then return end

	for _, roomDesc in ipairs(room:GetDescendants()) do
		if roomDesc:IsA("Model") then
			local n = roomDesc.Name

			if n == "Windows" or n == "Window" or n == "Window_Tall" then
				table.insert(WindowModels, roomDesc)

				for _, v in ipairs(roomDesc:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						WindowParticles[#WindowParticles + 1] = v
						ParticleOriginalColors[v] = v.Color

						v.Color = ColorSequence.new(Color3.fromRGB(255,0,0))
					end
				end

				for _, obj in ipairs(roomDesc:GetDescendants()) do
					if obj:IsA("Light") and obj.Name == "Lightning" then
						local clone = obj:Clone()
						clone.Angle = 70
						clone.Range = 65
						clone.Brightness = 0
						clone.Parent = obj.Parent
						clone.Enabled = false

						table.insert(CreatedLights, clone)

						local clone2 = obj:Clone()
						clone2.Angle = 80
						clone2.Range = math.huge
						clone2.Brightness = 1
						clone2.Name = "Nono"
						clone2.Color = Color3.fromRGB(144,0,255)
						clone2.Enabled = true
						clone2.Parent = obj.Parent

						table.insert(CreatedLights, clone2)

						local red = Instance.new("PointLight")
						red.Parent = obj.Parent.Parent.Glass
						red.Color = Color3.fromRGB(255,0,0)

						table.insert(CreatedLights, red)

						clone2:GetPropertyChangedSignal("Brightness"):Connect(function()
							if clone2.Brightness ~= 1 then
								clone2.Brightness = 1
							end
						end)

						table.insert(WindowLights, clone)
LightOriginalColors[clone] = clone.Color
					end
				end
			end
		end
	end

	local HasWindow = false

	for _, obj in ipairs(room:GetDescendants()) do
		if obj:IsA("Model") then
			local n = obj.Name

			if n == "Windows" or n == "Window" or n == "Window_Tall" then
				HasWindow = true
				break
			end
		end
	end

	local fixtures = room:FindFirstChild("Assets")
		and room.Assets:FindFirstChild("Light_Fixtures", true)

	if fixtures then
		for _, v in ipairs(fixtures:GetDescendants()) do
			if v:IsA("Light") then
				if not FixtureLightOriginalColors[v] then
					FixtureLights[#FixtureLights + 1] = v
					FixtureLightOriginalColors[v] = v.Color
				end
			end
		end

		for _, obj in ipairs(fixtures:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
				if not NeonOriginalColors[obj] then
					table.insert(NeonParts, obj)
					NeonOriginalColors[obj] = obj.Color

					local current = obj
					local stand

					while current do
						if current:IsA("Model")
							and (current.Name == "LightStand" or current.Name == "LightStands") then
							stand = current
							break
						end

						current = current.Parent
					end

					if stand then
						local lights = {}

						for _, v in ipairs(stand:GetDescendants()) do
							if v:IsA("Light") then
								lights[#lights + 1] = v

								if not LightOriginalColors[v] then
									LightOriginalColors[v] = v.Color
								end
							end
						end

						LightStandMap[obj] = lights
					end
				end
			end
		end
	end

	if HasWindow then
		local floor = room:FindFirstChild("Parts")
			and room.Parts:FindFirstChild("Floor")

		if floor then
			local StormPart = Instance.new("Part")
			StormPart.Name = "StormPart"
			StormPart.Anchored = true
			StormPart.CanCollide = false
			StormPart.CanQuery = false
			StormPart.CanTouch = false
			StormPart.Transparency = 1
			StormPart.Size = Vector3.new(1,1,1)
			StormPart.CFrame = floor.CFrame + Vector3.new(0,6,0)
			StormPart.Parent = workspace

			local sound = OwnLimboSound(Storm:Clone())
			sound.Name = "Storm" -- Existing room-audio playback searches for this name.
			sound.Looped = false
			sound.RollOffMaxDistance = 120
			sound.RollOffMinDistance = 5
			sound.RollOffMode = Enum.RollOffMode.Inverse
			sound.EmitterSize = 5
			sound.Parent = StormPart

            StormPartByRoom[room] = StormPart
			table.insert(StormParts, StormPart)
		end
	end
end

local function InitializeRooms()
	for _, room in ipairs(rooms:GetChildren()) do
		ProcessRoom(room)
		ProcessLightStands(room)
	end
end

InitializeRooms()

-- Release each room's extra Storm Sound when DOORS unloads the old room.
-- This prevents long sessions from accumulating one audio clone per room.
RoomRemovalConnection = rooms.ChildRemoved:Connect(function(room)
    local stormPart = StormPartByRoom[room]
    if not stormPart then return end
    StormPartByRoom[room] = nil

    local sound = stormPart:FindFirstChild("Storm")
    if sound and LimboOwnedSounds[sound] then
        DestroyLimboSound(sound)
    end
    if stormPart.Parent then
        stormPart:Destroy()
    end
    for index = #StormParts, 1, -1 do
        if StormParts[index] == stormPart then
            table.remove(StormParts, index)
            break
        end
    end
end)

task.spawn(function()
	while not Shutdown do
		task.wait(math.random(1, 3))

		if Shutdown then
			break
		end

		for _, light in ipairs(WindowLights) do
			if light and light.Parent then
				light.Enabled = true
				light.Brightness = 5
				light.Color = Color3.new(1, 1, 1)

				TweenService:Create(
					light,
					TweenInfo.new(
						0.55,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					),
					{
						Brightness = 0
					}
				):Play()
			end
		end

		if not Flickering then
		for _, window in ipairs(WindowModels) do
			if window and window.Parent then
				for _, obj in ipairs(window:GetDescendants()) do
					if obj:IsA("BasePart") and obj.Name == "Skybox" then
						local original = SkyBoxOriginalColors[obj]

						if original then
							obj.Color = Color3.new(1, 1, 1)

							local ambientTween = TweenService:Create(
								obj,
								TweenInfo.new(
									0.55,
									Enum.EasingStyle.Quad,
									Enum.EasingDirection.Out
								),
								{
									Color = original
								}
							)
							AmbientSkyboxTweens[obj] = ambientTween
							ambientTween:Play()
						end
					end
				end
			end
		end
		end -- if not Flickering (Skybox only)
	end
end)

task.spawn(function()
	while not Shutdown do
		task.wait(math.random(2,5))

		if Shutdown then
			break
		end

		local chosen = {}
		local amount = math.random(2,4)

		for i = 1, amount do
			if Shutdown then
				break
			end

			if #NeonParts > 0 then
				local part = NeonParts[math.random(1,#NeonParts)]

				if part and part.Parent then
					table.insert(chosen, part)
				end
			end
		end

		for _, part in ipairs(chosen) do
			task.spawn(function()
				if Shutdown then
					return
				end

				if part and part.Parent then
					local oldColor = part.Color

					task.wait(math.random(0,10)/100)

					if Shutdown then
						if part.Parent then
							part.Color = oldColor

							local lights = LightStandMap[part]

							if lights then
								for _, light in ipairs(lights) do
									if light.Parent then
										light.Color = LightOriginalColors[light] or oldColor
									end
								end
							end
						end
						return
					end

					part.Color = Color3.fromRGB(157,3,252)

					local lights = LightStandMap[part]

					if lights then
						for _, light in ipairs(lights) do
							if light.Parent then
								light.Color = Color3.fromRGB(157,3,252)
							end
						end
					end
					
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrentRooms = workspace:WaitForChild("CurrentRooms")
local Module_Events = require(
	ReplicatedStorage.ModulesClient.Module_Events
)

local FlickeredRooms = {}

for _, room in ipairs(CurrentRooms:GetChildren()) do
	if room:IsA("Model") and not FlickeredRooms[room] then
		FlickeredRooms[room] = true
		Module_Events.flicker(room, 1)
	end
end

					task.wait(1.3)

					if not Shutdown and part.Parent then
						part.Color = oldColor

						if lights then
							for _, light in ipairs(lights) do
								if light.Parent then
									light.Color = LightOriginalColors[light] or oldColor
								end
							end
						end
					end
				end
			end)
		end
	end
end)

task.spawn(function()
	while not Shutdown do
		local char = LocalPlayer.Character

		if char then
			HitboxDisabled = char:GetAttribute("Hiding") == true
		else
			HitboxDisabled = false
		end

		task.wait(0.5)
	end
end)

local LastShake = 0

local BaseWalkSpeed = 15

local function UpdateWalkSpeed(progress)
	if not WalkSpeedControl then
		return
	end

	local value = math.clamp(progress / 100, 0, 1)

	local speed

	if value <= 0.6 then
		speed = BaseWalkSpeed - (value / 0.6) * 4
	else
		speed = 12 - ((value - 0.6) / 0.4) * 5
	end

	local char = LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = speed
	end
end

RunService.RenderStepped:Connect(function(dt)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hrp then
		return
	end

		local InStorm = false

	if Flickering and not char:GetAttribute("Hiding") then
		InStorm = IsInStormRange(hrp)
	end

local PreviousProgress = StormProgress

if InStorm then
	StormProgress = math.clamp(
		StormProgress + (dt * StormSpeed),
		0,
		MaxBar
	)
end

local BarIncreased = StormProgress > PreviousProgress + 0.001

if BarIncreased then
	BarStableTime = 0
	BarDecaying = false
elseif StormProgress > 0 and not BarDecaying then
	BarStableTime += dt

	if BarStableTime >= BarDecayDelay then
		BarDecaying = true
	end
end

if BarDecaying then
	if InStorm then
		BarDecaying = false
		BarStableTime = 0
	else
		StormProgress = math.max(
			0,
			StormProgress - (BarDecaySpeed * dt)
		)

		if StormProgress <= 0 then
			StormProgress = 0
			BarDecaying = false
			BarStableTime = 0
		end
	end
end

local effectValue = math.clamp(StormProgress / 100, 0, 1)

UpdateEffect(effectValue)
UpdateWalkSpeed(StormProgress)

	if not BarDestroyed and StormProgress >= MaxBar then
		BarDestroyed = true

		if LimboBar then
			LimboBar:Destroy()
		end

		local character = game.Players.LocalPlayer.Character
			or game.Players.LocalPlayer.CharacterAdded:Wait()

		local humanoid = character:WaitForChild("Humanoid")

		humanoid:TakeDamage(1000)

        -- Play the preloaded death sound; the original Sound is retained.
        PlayOneShot(JumpscareSound)

		game.ReplicatedStorage.GameStats[
			"Player_" .. game.Players.LocalPlayer.Name
		].Total.DeathCause.Value = "Limbo"
	end

	if BarDestroyed then
		return
	end

	TweenBarPercent(StormProgress, 0.1)

	local target = 0

	for i = #WindowLights, 1, -1 do
		local light = WindowLights[i]

		if not light.Parent then
			table.remove(WindowLights, i)
		elseif light.Brightness > 0 then
			local part = light.Parent

			if part:IsA("Attachment") then
				part = part.Parent
			end

			if part and part:IsA("BasePart") then
				local dist = (hrp.Position - part.Position).Magnitude

				if dist <= MaxDist then
					local strength =
						(1 - dist / MaxDist) *
						(light.Brightness / 5)

					target = math.max(target, strength)
				end
			end
		end
	end

	if target > 0.01 then
		local now = tick()

		if now - LastShake >= 0.12 then
			LastShake = now

			CameraShake:ShakeOnce(
				target * 7,
				12,
				0.05,
				0.03
			)
		end
	end
end)

RoomConnection = rooms.ChildAdded:Connect(function(room)
	task.spawn(function()
		task.wait(0.5)

		if Shutdown or not room.Parent then
			return
		end

		ProcessRoom(room)
		ProcessLightStands(room)
	end)
end)
end
function entityBehaviors.Surge()

local breakingb = false

local hardCoreSound = workspace:FindFirstChild("HardCoreSound")
if not hardCoreSound then
    return
end

local SoundTemplates = {}
for i = 1, 7 do
    local name = "Surge" .. i
    local template = hardCoreSound:FindFirstChild(name)
    if not (template and template:IsA("Sound")) then
        return
    end
    SoundTemplates[i] = template
end
local Debris = game:GetService("Debris")

local function PlayTemporarySound(template, parent, lifetime)
    local sound = template:Clone()
    sound.Looped = false
    sound.Parent = parent or workspace
    sound.TimePosition = 0
    sound.Ended:Once(function()
        if sound.Parent then
            sound:Destroy()
        end
    end)
    Debris:AddItem(sound, lifetime or 30)
    sound:Play()
    return sound
end
local function LoadModel(file, url)
if not isfile(file) then
writefile(file, game:HttpGet(url))
end

return game:GetObjects((getcustomasset or getsynasset)(file))[1]

end


local dmg = SoundTemplates[1]

local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
local CameraShaker = require(game.ReplicatedStorage:WaitForChild("CameraShaker"))
local camera = workspace.CurrentCamera

local spawnShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end)

spawnShake:Start()

local function ElectrocutedLight(light)
local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")
local cs = game:GetService("CollectionService")

local lr = rs.GameData.LatestRoom
local room = workspace.CurrentRooms:FindFirstChild(tostring(lr.Value))
local fixtures = room and room:FindFirstChild("Assets")
and room.Assets:FindFirstChild("Light_Fixtures")

if not fixtures then return end

local ev = require(rs.ModulesClient.Module_Events)
local lights = {}
local models = {}

for _, v in ipairs(fixtures:GetChildren()) do
if v:IsA("Model") and v.Name == "LightStand" then
table.insert(models, v)
end
end

for i = #models, 2, -1 do
local j = math.random(1, i)
models[i], models[j] = models[j], models[i]
end

for i = 1, math.min(light, #models) do
table.insert(lights, models[i])
end

for _, v in ipairs(lights) do
ev.breakSingleLight(v)
task.wait(0.2)
end

task.wait(1.3)



local elec = SoundTemplates[2]  
local sound1 = SoundTemplates[3] 
local sound2 = SoundTemplates[4]

local src = LoadModel(
"SurgeLocalCenter.txt",
"https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Place_74871629393921_Attachment_SurgeLocalCenter_1791729897.txt"
)

if not src then return end
local dmggui = LoadModel(
"SurgeDamageUi.txt",
"https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Place_131351567799504_ScreenGui_SurgeReignitedUI_1792302581.txt"
)

dmggui.Parent = game.Players.LocalPlayer.PlayerGui

for _, stand in ipairs(lights) do
if stand.Parent then
for _, p in ipairs(stand:GetDescendants()) do
if p.Name == "LightFixture" and p:IsA("BasePart") then
local clone = src:Clone()
clone.Parent = p


local a1, a2, beam, beam2
local active = false

local hitBeam = false
local dmgCooldown = false
for _, v in ipairs(clone:GetChildren()) do
    if v:IsA("Attachment") and v.Name == "SurgeActiveSpark" then
        local hasSound = false

        for _, obj in ipairs(v:GetChildren()) do
            if obj:IsA("Sound") then
                hasSound = true
                break
            end
        end

        if hasSound then
            a1 = v
        else
            a2 = v
        end
    end
end

if a1 and a2 then
    beam = a1:FindFirstChild("SparkBeam", true)

    if beam and beam:IsA("Beam") then
        beam.Attachment0 = a2
        beam.Enabled = false
    else
        beam = nil
    end
end

if a1 and a2 then
    beam2 = a2:FindFirstChild("SparkBeam", true)


end


            task.spawn(function()
                local sparks = {}
                local shock = {}
                local sounds = {}

                for _, v in ipairs(clone:GetDescendants()) do
                    if v:IsA("Sound") and v.Name == "Sound" then
                        v.SoundId = elec.SoundId
                        table.insert(sounds, v)
                    end

                    if v.Name == "SurgeActiveSpark" and v:IsA("Attachment") then
                        for _, obj in ipairs(v:GetDescendants()) do
                            if obj.Name == "SparkParticle" and obj:IsA("ParticleEmitter") then
                                table.insert(sparks, obj)
                            end
                        end
                    elseif v.Name == "SurgeShockLight" and v:IsA("PointLight") then
                        table.insert(shock, v)
                    end
                end

                local residual = clone:FindFirstChild("SurgeResidual", true)
                local electricity = residual and residual:FindFirstChild("SurgeElectricity", true)

task.spawn(function()
    while clone.Parent do
        task.wait(0.1)

        if not dmgCooldown and active and a2 and a2.Parent then
            local pla = game:GetService("Players").LocalPlayer
            local char = pla.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local root = hrp and hrp:FindFirstChild("RootAttachment")

            if hum and hrp and root and hum.Health > 0
            and (hrp.Position - p.Position).Magnitude < 10 then

                dmgCooldown = true

                if beam2 and beam2.Parent then
    beam2.Attachment0 = root
    beam2.Enabled = true
end

                hum:TakeDamage(5)

local img = dmggui:FindFirstChildWhichIsA("ImageLabel", true)

if img then
    img.Visible = true
    local cur = (img:GetAttribute("AnimId") or 0) + 1
    img:SetAttribute("AnimId", cur)

    task.spawn(function()
        local start = tick()

        while img.Parent and img.Visible
        and img:GetAttribute("AnimId") == cur
        and tick() - start < 2 do
            img.Rotation = 180
            task.wait(0.2)

            if not img.Parent or not img.Visible
            or img:GetAttribute("AnimId") ~= cur
            or tick() - start >= 2 then break end

            img.Rotation = 360
            task.wait(0.2)
        end

        if img.Parent and img:GetAttribute("AnimId") == cur then
            img.Visible = false
        end
    end)
end
                PlayTemporarySound(dmg, hrp, 15)

                task.delay(1.5, function()
                    if beam2 and beam2.Parent then
                        beam2.Enabled = false
                        beam2.Attachment0 = a2
                    end
                end)

                task.delay(4, function()
                    dmgCooldown = false
                end)
            end
        end
    end
end)
                task.spawn(function()
                    while clone.Parent do
                        task.wait(math.random(10, 20) / 10)
                        if not clone.Parent then break end
                        
                        active = true

task.delay(0.5, function()
    active = false
end)

if math.random(1,2) == 1 then
PlayTemporarySound(sound1, p, 15)
else
PlayTemporarySound(sound2, p, 15)
end

                        
if a2 and a2.Parent and beam and beam.Parent then
    beam.Enabled = true

    local cf = p.CFrame
    local pos = cf:PointToWorldSpace(Vector3.new(
        math.random(-400, 400) / 100,
        math.random(-400, 400) / 100,
        math.random(-400, 400) / 100
    ))

    local rot = a2.WorldCFrame - a2.WorldPosition
    a2.WorldCFrame = CFrame.new(pos) * rot
end

for _, v in ipairs(sparks) do
    if v.Parent then
        v.Enabled = true
    end
end
                        for _, sound in ipairs(sounds) do
                            if sound.Parent and not sound.IsPlaying then
                                if sound.TimeLength > 0 then
                                    sound.TimePosition = math.random() * sound.TimeLength
                                end
                                sound:Play()
                            end
                        end

                        for _, v in ipairs(shock) do
                            if v.Parent then
                                local range = v.Range
                                v.Enabled = true

                                local fade = ts:Create(
                                    v,
                                    TweenInfo.new(0.5),
                                    {Range = 0}
                                )

                                fade:Play()

                                task.spawn(function()
                                    fade.Completed:Wait()
                                    if v.Parent then
                                        v.Range = range
                                        v.Enabled = false
                                    end
                                end)
                            end
                        end

                        task.delay(0.3, function()
                            for _, v in ipairs(sparks) do
                                if v.Parent then
                                    v.Enabled = false
                                end
                            end
                            
                            if beam and beam.Parent and beam ~= beam2 then
    beam.Enabled = false
end

                            for _, sound in ipairs(sounds) do
                                if sound.Parent then
                                    sound:Stop()
                                end
                            end
                        end)

                        task.wait(0.5)
                    end
                end)

                task.spawn(function()
                    while clone.Parent do
                        task.wait(math.random(15, 30) / 10)
                        if not clone.Parent then break end

                        if electricity and electricity:IsA("PointLight") and electricity.Parent then
                            electricity.Enabled = true
                        end

                        for _, v in ipairs(sparks) do
                            if v.Parent then
                                v.Enabled = true
                            end
                        end

                        task.wait(0.07)

                        if electricity and electricity.Parent then
                            electricity.Enabled = false
                        end

                        for _, v in ipairs(sparks) do
                            if v.Parent then
                                v.Enabled = false
                            end
                        end
                    end
                end)
            end)
        end
    end
end

end
end

local finished = false

PlayTemporarySound(SoundTemplates[5], workspace, 45) -- Surge5: opening thunder

local surgestart = SoundTemplates[6] -- Surge6: attack start

local rs = game:GetService("ReplicatedStorage")
local lr = rs.GameData.LatestRoom
local conn

conn = lr:GetPropertyChangedSignal("Value"):Connect(function()
    local room = workspace.CurrentRooms:FindFirstChild(tostring(lr.Value))
    if not room then return end

    local windows = {}
    local windowFolder = room.Assets:FindFirstChild("Windows") 

    for _, v in ipairs(room.Assets:GetChildren()) do
        if v:IsA("Model") and (v.Name == "Window" or v.Name == "Window_Tall") then
            table.insert(windows, v)
        end
    end
    
    if windowFolder then
    for _, v in ipairs(windowFolder:GetChildren()) do
        if v:IsA("Model") and (v.Name == "Window" or v.Name == "Window_Tall") then
            table.insert(windows, v)
        end
    end
    end
    
    for _, v in ipairs(room.Assets:GetChildren()) do
        if v:IsA("Model") and (v.Name == "Window" or v.Name == "Window_Tall") then
            table.insert(windows, v)
        end
    end
    
    task.spawn(function() 
    if #windows == 0 and math.random(1,3) == 1 then
    task.wait(0.5)
    ElectrocutedLight(6)
    end
    end) 

    if #windows == 0 then return end

    conn:Disconnect()
    
    task.wait(1)
    
    task.spawn(function() 
while not finished do
spawnShake:ShakeOnce(
	4,   -- Magnitude (mạnh)
	10,   -- Roughness
	0, -- FadeIn
	0.09, -- FadeOut
	0,    -- PositionInfluence
	0.8   -- RotationInfluence
)
task.wait(0.04)
end
end) 

PlayTemporarySound(surgestart, workspace, 45)

local windowsounds = {}
local winconn

for _, model in ipairs(windows) do
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("Sound") then
            windowsounds[v] = {
                Volume = v.Volume,
                RollOffMaxDistance = v.RollOffMaxDistance
            }

            v.Volume = v.Volume * 2
            v.RollOffMaxDistance = v.RollOffMaxDistance * 1.5
        end
    end
end

winconn = game:GetService("RunService").Heartbeat:Connect(function()
    if not finished then return end

    winconn:Disconnect()

    for v, data in pairs(windowsounds) do
        if v.Parent then
            v.Volume = data.Volume
            v.RollOffMaxDistance = data.RollOffMaxDistance
        end
    end

    table.clear(windowsounds)
end)

local starttodie = LoadModel(
"SurgeDamageUi.txt",
"https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Place_131351567799504_ScreenGui_SurgeReignitedUI_1792302581.txt"
)

starttodie.Parent = game.Players.LocalPlayer.PlayerGui

local ts = game:GetService("TweenService")
local gui = starttodie

if gui then
    for _, img in ipairs(gui:GetDescendants()) do
        if img:IsA("ImageLabel") then
        img.Visible = true
            img.Size = UDim2.new(1.5, 0, 1.5, 0)

            ts:Create(img, TweenInfo.new(5), {
                Size = UDim2.new(1.1, 0, 1.1, 0)
            }):Play()

            task.spawn(function()
            if finished and img.Parent then
        img:Destroy()
    end
    
    while img.Parent and not finished do
        img.Rotation = img.Rotation + 180
        task.wait(0.1)
    end

    
end)
        end
    end
end

    local col = Color3.fromRGB(255, 241, 115)
local cons = {}
local old = {}
local active = true

local function Restore()
    if not active then return end
    active = false

    for _, c in ipairs(cons) do
        c:Disconnect()
    end

    for v, data in pairs(old) do
        if v.Parent then
            v.Color = data.Color
            if data.Brightness ~= nil then
                v.Brightness = data.Brightness
            end
            if data.Enabled ~= nil then
                v.Enabled = data.Enabled
            end
        end
    end
end

task.spawn(function()
    while not finished and active do
        task.wait(0.05)
    end
    Restore()
end)

for _, model in ipairs(windows) do
    for _, v in ipairs(model:GetDescendants()) do
        if finished then
            Restore()
            break
        end

        if v.Name == "SkyBox" or v.Name == "Skybox" then
            if v:IsA("BasePart") then
                old[v] = {
                    Color = v.Color
                }

                v.Color = col

                table.insert(cons, v:GetPropertyChangedSignal("Color"):Connect(function()
                    if active and v.Parent and v.Color ~= col then
                        v.Color = col
                    end
                end))
            end
        end

        if v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight") then
            if not old[v] then
                old[v] = {
                    Color = v.Color,
                    Brightness = v.Brightness,
                    Enabled = v.Enabled
                }
            end

            v.Color = col
            v.Enabled = true
            v.Brightness = 0.7

            table.insert(cons, v:GetPropertyChangedSignal("Color"):Connect(function()
                if active and v.Parent then
                    v.Color = col
                end
            end))

            table.insert(cons, v:GetPropertyChangedSignal("Brightness"):Connect(function()
                if active and v.Parent and v.Brightness ~= 0.5 and v.Brightness ~= 0.7 then
                    v.Brightness = 0.7
                end
            end))

            table.insert(cons, v:GetPropertyChangedSignal("Enabled"):Connect(function()
                if active and v.Parent and not v.Enabled then
                    v.Enabled = true
                end
            end))

            task.spawn(function()
                while active and v.Parent and not finished do
                    v.Brightness = 0.5
                    task.wait(0.03)

                    if not active or finished or not v.Parent then break end

                    v.Brightness = 0.7
                    task.wait(0.03)
                end
            end)
        end
    end
end

task.delay(6, function()
breakingb = true
ElectrocutedLight(100)
    
local pla = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")
local run = game:GetService("RunService")
local lpla = pla.LocalPlayer
local char = lpla.Character or lpla.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local idle = SoundTemplates[7] -- Surge7: SoundId assigned to SurgeMoving model sounds

local file = "SurgeMoving.txt"
local url = "https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Place_131351567799504_Part_SurgeMoving_1792299088.txt"

if not isfile(file) then
    writefile(file, game:HttpGet(url))
end

local obj = game:GetObjects((getcustomasset or getsynasset)(file))[1]
if not obj then return end

local lr = rs.GameData.LatestRoom
local room = workspace.CurrentRooms:FindFirstChild(tostring(lr.Value))
local assets = room and room:FindFirstChild("Assets")
local windows = {}
local windowFolder = assets:FindFirstChild("Windows") 

if assets then
if windowFolder then
    for _, v in ipairs(windowFolder:GetChildren()) do
        if v:IsA("Model") and (v.Name == "Window" or v.Name == "Window_Tall") then
            table.insert(windows, v)
        end
    end
    end
    
    for _, v in ipairs(assets:GetChildren()) do
        if v:IsA("Model") and (v.Name == "Window" or v.Name == "Window_Tall") then
            table.insert(windows, v)
        end
    end
end

if #windows == 0 then
    obj:Destroy()
    return
end

local win = windows[math.random(1, #windows)]
obj.Parent = workspace
obj:PivotTo(win:GetPivot())

local spawnTime = os.clock()
local ending = false

for _, v in ipairs(obj:GetDescendants()) do
    if v:IsA("Sound") then
        v.SoundId = idle.SoundId
        v.Volume = v.Volume * 2
    end
end

if obj:IsA("BasePart") then
    for _, v in ipairs(obj:GetChildren()) do
        if v:IsA("Sound") then
            v.SoundId = idle.SoundId
        end
    end
end

task.wait(1)

local function GetOrigin()
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        return obj:GetPivot().Position
    end
end

local part
if obj:IsA("BasePart") then
    part = obj
elseif obj:IsA("Model") then
    part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
end

if not part then
    obj:Destroy()
    return
end

local hitbox = Instance.new("Part")
hitbox.Name = "SurgeHitbox"
hitbox.Size = Vector3.new(80, 80, 80)
hitbox.Transparency = 1
hitbox.CanCollide = false
hitbox.CanTouch = false
hitbox.CanQuery = false
hitbox.Massless = true
hitbox.Anchored = false
hitbox.CFrame = part.CFrame
hitbox.Parent = workspace

local weld = Instance.new("WeldConstraint")
weld.Part0 = part
weld.Part1 = hitbox
weld.Parent = hitbox

local rooms = workspace:WaitForChild("CurrentRooms")
local parts = {}

local function AddPart(v)
    if v:IsA("BasePart") and not v:IsDescendantOf(obj) then
        if not table.find(parts, v) then
            table.insert(parts, v)
        end
    end
end

local function RemovePart(v)
    local i = table.find(parts, v)
    if i then
        table.remove(parts, i)
    end
end

for _, v in ipairs(rooms:GetDescendants()) do
    AddPart(v)
end

local addConn = rooms.DescendantAdded:Connect(AddPart)
local remConn = rooms.DescendantRemoving:Connect(RemovePart)

local beams = {}
local paused = {}
local targets = {}

for _, v in ipairs(obj:GetDescendants()) do
    if v:IsA("Beam") then
        table.insert(beams, v)
        v.Enabled = true
        paused[v] = false

        for i = 1, 2 do
            local clone = v:Clone()
            clone.Enabled = true
            clone.Parent = v.Parent
            paused[clone] = false
            table.insert(beams, clone)
        end
    end
end

local moving = false
local triggerRequested = false

local function IsBlocked(pos, rot)
    local pivot = CFrame.new(pos) * rot
    local boxcf
    local size

    if obj:IsA("Model") then
        boxcf, size = obj:GetBoundingBox()
    else
        boxcf = obj.CFrame
        size = obj.Size
    end

    local offset = obj:GetPivot():ToObjectSpace(boxcf)
    local filter = {obj, hitbox, win}

    char = lpla.Character
    if char then
        table.insert(filter, char)
    end

    local op = OverlapParams.new()
    op.FilterType = Enum.RaycastFilterType.Exclude
    op.FilterDescendantsInstances = filter

    local found = workspace:GetPartBoundsInBox(
        pivot * offset,
        size * 0.8,
        op
    )

    for _, v in ipairs(found) do
        if v:IsA("BasePart") and v.CanCollide then
            return true
        end
    end

    return false
end

local function MoveTo(target, duration, wander)
    local pivot = obj:GetPivot()
    local start = pivot.Position
    local rot = pivot - start
    local elapsed = 0

    while elapsed < duration and obj.Parent and not ending do
        local dt = run.Heartbeat:Wait()
        elapsed += dt

        if wander and triggerRequested then
            return false
        end

        local alpha = math.clamp(elapsed / duration, 0, 1)
        local pos = start:Lerp(target, alpha)

        obj:PivotTo(CFrame.new(pos) * rot)
    end

    return true
end

char = lpla.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")

task.spawn(function()
    while obj.Parent and not ending do
        task.wait(0.05)

        

        local hiding = char and char:GetAttribute("Hiding") == true
        local detected = false

        if hrp and hitbox.Parent then
            local d = hrp.Position - hitbox.Position

            detected =
                math.abs(d.X) <= hitbox.Size.X / 2
                and math.abs(d.Y) <= hitbox.Size.Y / 2
                and math.abs(d.Z) <= hitbox.Size.Z / 2
        end

        triggerRequested = hiding or detected

        if not triggerRequested or moving or not hrp then
            continue
        end

        moving = true

        local angle = math.random() * math.pi * 2
        local dist = math.random(1, 30)

        local target = Vector3.new(
            hrp.Position.X + math.cos(angle) * dist,
            hrp.Position.Y,
            hrp.Position.Z + math.sin(angle) * dist
        )

        MoveTo(target, 0.35, false)

        moving = false
        task.wait(math.random(2, 8) / 20)
    end
end)

task.spawn(function()
    while obj.Parent and not ending do
        if triggerRequested or moving then
            task.wait(0.05)
            continue
        end

        task.wait(math.random(1, 20) / 10)

        if ending or triggerRequested or moving then
            continue
        end
        
        local folder = room and room:FindFirstChild("Parts")
        local floors = {}

        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("BasePart") and v.Name == "Floor" then
                    table.insert(floors, v)
                end
            end
        end

        if #floors == 0 then
            continue
        end

        local floor = floors[math.random(1, #floors)]
        local cf = floor.CFrame
        local size = floor.Size

        local x = (math.random() - 0.5) * size.X
        local z = (math.random() - 0.5) * size.Z
        local surface = cf:PointToWorldSpace(Vector3.new(x, size.Y / 2, z))
        local origin = GetOrigin()

        if not origin then
            continue
        end

        local target = Vector3.new(
            surface.X,
            surface.Y + (origin.Y - floor.Position.Y),
            surface.Z
        )

        moving = true
        MoveTo(target, math.random(25, 60) / 100, true)
        moving = false
    end
end)

for _, beam in ipairs(beams) do
    task.spawn(function()
        local att

        while beam.Parent and obj.Parent and not ending do
            task.wait(0.1)

            if ending or not beam.Parent or not obj.Parent then
                break
            end

            if paused[beam] then
                continue
            end

            local origin = GetOrigin()
            if not origin then break end

            local valid = {}

            for _, p in ipairs(parts) do
                if p.Parent
                and not p:IsDescendantOf(obj)
                and (p.Position - origin).Magnitude < 20 then
                    table.insert(valid, p)
                end
            end

            if #valid > 0 then
                local p = valid[math.random(1, #valid)]

                if att then
                    att:Destroy()
                end

                att = Instance.new("Attachment")
                att.Name = "SurgeTarget"
                att.Parent = p

                targets[beam] = att
                beam.Attachment0 = att
            else
                if att then
                    att:Destroy()
                    att = nil
                end

                targets[beam] = nil
                beam.Attachment0 = nil
            end
        end

        if att then
            att:Destroy()
        end
    end)
end

local dmg2 = false

task.spawn(function()
    while obj.Parent and not ending do
        task.wait(0.1)

        if ending or dmg2 then
            continue
        end

        char = lpla.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")

        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = hrp and hrp:FindFirstChild("RootAttachment")
        local origin = GetOrigin()

        if hum and hum.Health > 0 and root and origin
        and (hrp.Position - origin).Magnitude < 10
        and #beams > 0 then

            local available = {}

            for _, beam in ipairs(beams) do
                if beam.Parent and not paused[beam] then
                    table.insert(available, beam)
                end
            end

            if #available == 0 then
                continue
            end

            dmg2 = true

            local beam = available[math.random(1, #available)]
            local old = beam.Attachment0

            beam.Attachment0 = root
            local hiding = char and char:GetAttribute("Hiding") == true
            if not hiding then
            PlayTemporarySound(dmg, workspace, 15)
            hum:TakeDamage(15)
            game.ReplicatedStorage.GameStats["Player_".. game.Players.LocalPlayer.Name].Total.DeathCause.Value = "Surge"
            end

            task.wait(0.4)

            if beam.Parent and not ending then
                beam.Attachment0 = old
            end

            dmg2 = false
        end
    end
end)

task.spawn(function()
    task.wait(math.max(0, 15 - (os.clock() - spawnTime)))



    if not obj.Parent or ending then
        return
    end

    ending = true
    triggerRequested = false

    if hitbox.Parent then
        hitbox:Destroy()
    end
    
    finished = true
    
    if dmggui and dmggui.Parent then
        dmggui:Destroy()
    end

    if starttodie and starttodie.Parent then
        starttodie:Destroy()
    end

    for _, beam in ipairs(beams) do
        if beam.Parent then
            beam:Destroy()
        end
    end

    addConn:Disconnect()
    remConn:Disconnect()

    local tweens = {}
    local emitters = {}

    for _, v in ipairs(obj:GetDescendants()) do
        if v:IsA("Sound") then
            table.insert(tweens, ts:Create(
                v,
                TweenInfo.new(4),
                {PlaybackSpeed = 0}
            ))
        elseif v:IsA("PointLight")
        or v:IsA("SpotLight")
        or v:IsA("SurfaceLight") then
            table.insert(tweens, ts:Create(
                v,
                TweenInfo.new(4),
                {Range = 0}
            ))
        elseif v:IsA("ParticleEmitter") then
            emitters[v] = v.Transparency
        end
    end

    for _, tw in ipairs(tweens) do
        tw:Play()
    end

    local startTime = os.clock()

    while os.clock() - startTime < 4 and obj.Parent do
        local alpha = math.clamp((os.clock() - startTime) / 4, 0, 1)

        for em, seq in pairs(emitters) do
            if em.Parent then
                local keys = {}

                for _, kp in ipairs(seq.Keypoints) do
                    table.insert(keys, NumberSequenceKeypoint.new(
                        kp.Time,
                        kp.Value * (1 - alpha),
                        kp.Envelope * (1 - alpha)
                    ))
                end

                em.Transparency = NumberSequence.new(keys)
            end
        end

        run.Heartbeat:Wait()
    end

    if obj.Parent then
        obj:Destroy()
    end
    
end)

end)
end)
end
function entityBehaviors.Silence3()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Hum = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid", 5)
local PlayerAliveAtStart = Hum ~= nil and Hum.Health > 0 and Hum:GetState() ~= Enum.HumanoidStateType.Dead
local ActiveMoveTween
local HeardChasing = false
local HeardTouched = false
local HeardChaseConnection
local HideHeartbeatGui
local ShakeLoop = false
local CameraShakeStopped = false
local spawnShake
local SilenceShakeRenderName = "SilenceIndependentCameraShake_" .. HttpService:GenerateGUID(false)
local SilenceShakeBound = false
local SilenceShakeSessionKey = "__SilenceIndependentCameraShakeSession"
local SilenceShakeSession = {}
local PreviousSilenceShakeSession = _G[SilenceShakeSessionKey]
if type(PreviousSilenceShakeSession) == "table" and type(PreviousSilenceShakeSession.Stop) == "function" then
    pcall(PreviousSilenceShakeSession.Stop)
end
_G[SilenceShakeSessionKey] = SilenceShakeSession
local LatestRoom = game.ReplicatedStorage.GameData:WaitForChild("LatestRoom")
local PathMovementInterrupted = false
local PathCopyToken = 0
local SilenceShutdown = false
local LatestRoomCount = 0
local LatestRoomConnection
local ShutdownConnections = {}
local HeardBoso
local ProximityPromptService = game:GetService("ProximityPromptService")

local SilenceAudioObjects = {}

local function TrackSilenceAudio(sound, preserveUntilEnded)
	if not sound or not sound:IsA("Sound") then
		return sound
	end

	if SilenceAudioObjects[sound] == nil then
		sound.Destroying:Connect(function()
			SilenceAudioObjects[sound] = nil
		end)
	end

	SilenceAudioObjects[sound] =
		preserveUntilEnded == true or SilenceAudioObjects[sound] == true

	return sound
end

local function CleanupSilenceAudio(preserveFinalCues)
	for sound, preserve in pairs(SilenceAudioObjects) do
		if sound and sound.Parent and not (preserveFinalCues and preserve) then
			pcall(function()
				sound:Stop()
				sound:Destroy()
			end)
		end
	end
end

local HardCoreSoundFolder = workspace:WaitForChild("HardCoreSound")

local function GetHardCoreSoundTemplate(soundName)
	local sound = HardCoreSoundFolder:WaitForChild(soundName)
	assert(sound:IsA("Sound"), soundName .. " must be a Sound")
	return sound
end

local function CloneHardCoreSound(soundName, parent)
	local sound = TrackSilenceAudio(GetHardCoreSoundTemplate(soundName):Clone())
	sound.Parent = parent or workspace
	return sound
end


local function StopCameraShake()
	ShakeLoop = false
	CameraShakeStopped = true
	if spawnShake then
		pcall(function()
			spawnShake:StopSustained(0)
		end)
	end
	if SilenceShakeBound then
		SilenceShakeBound = false
		RunService:UnbindFromRenderStep(SilenceShakeRenderName)
	end
	if _G[SilenceShakeSessionKey] == SilenceShakeSession then
		_G[SilenceShakeSessionKey] = nil
	end
end

SilenceShakeSession.Stop = StopCameraShake

local function SetSilenceDeathCause()
	pcall(function()
		game.ReplicatedStorage.GameStats["Player_" .. LocalPlayer.Name].Total.DeathCause.Value = "Silence"
	end)
end


local ModelFile = "Place_131351567799504_Model_Silemxkknce_1789918857.txt"
local ModelUrl = "https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Place_131351567799504_Model_Silemxkknce_1789918857.txt"

local SilenceModel

if PlayerAliveAtStart then
	if not isfile(ModelFile) then
		writefile(ModelFile, game:HttpGet(ModelUrl))
	end

	local ModelObjects = game:GetObjects(getcustomasset(ModelFile))
	SilenceModel = ModelObjects and ModelObjects[1]

	if SilenceModel and Hum and Hum.Health > 0 and Hum:GetState() ~= Enum.HumanoidStateType.Dead then
		SilenceModel.Parent = workspace
	elseif SilenceModel then
		SilenceModel:Destroy()
		SilenceModel = nil
	end
end



local Ambi = CloneHardCoreSound("NopeMoskx")
		Ambi.Volume = 3
		Ambi.RollOffMaxDistance = 25000
		Ambi.RollOffMinDistance = 5


		Ambi.PlaybackSpeed = 1
		Ambi.Name = "NopeMoskx"
		Ambi.Looped = true
		
local RushNew = SilenceModel and SilenceModel:FindFirstChild("RushNew", true)

if SilenceModel and (not RushNew or not RushNew:IsA("BasePart")) then
	SilenceModel:Destroy()
	SilenceModel = nil
	RushNew = nil
end

local EntityEnabled = SilenceModel ~= nil and RushNew ~= nil

local MainColorCorrection =
	Lighting:FindFirstChild("MainColorCorrection")

if not MainColorCorrection then
	MainColorCorrection = Instance.new("ColorCorrectionEffect")
	MainColorCorrection.Name = "MainColorCorrection"
	MainColorCorrection.Brightness = 0
	MainColorCorrection.Contrast = 0
	MainColorCorrection.Saturation = 0
	MainColorCorrection.TintColor = Color3.new(1, 1, 1)
	MainColorCorrection.Parent = Lighting
end


local HRP


local Gui
local GrainImages = {}
local HighestNumber = -1

local GuiFile = "Place_131351567799504_Frame_SilenceRoomStatic_1789918766.txt"
local GuiUrl = "https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Place_131351567799504_Frame_SilenceRoomStatic_1789918766.txt"

if not isfile(GuiFile) then
	writefile(GuiFile, game:HttpGet(GuiUrl))
end

Gui = game:GetObjects(getcustomasset(GuiFile))[1]

if not Gui then
	return
end

Gui.Parent = LocalPlayer.PlayerGui:WaitForChild("MainUI")

if Gui:IsA("Frame") then
	Gui.Visible = true
end

for _, obj in ipairs(Gui:GetDescendants()) do
	if obj:IsA("ImageLabel") then
		local number = obj.Name:match("^GrainImage(%d+)$")

		if number then
			number = tonumber(number)

			GrainImages[number] = obj
			obj.ImageTransparency = 1
			obj.Visible = false
		else
			obj.ImageTransparency = 0
		end
	end
end

for number in pairs(GrainImages) do
	if number > HighestNumber then
		HighestNumber = number
	end
end


local HeartbeatGui
local HeartbeatFrame
local HeartbeatShake
local HeartbeatShakeScale
local HeartbeatLocked = false

local HeartbeatGuiStarted = false
local HeartbeatScaleLoop = false
local HeartbeatAllowed = false
local HeartbeatHeart
local HeartbeatOriginalColor

local HeartbeatShakeRange = 20
local HeartbeatMaxShake = 8
local HeartbeatPositionTween
local HeartbeatHideToken = 0
local HeartbeatScaleTween
local HeartbeatDistanceLoop = false

local HeartbeatShakePosition
local HeartbeatShakeRotation

local HeartbeatMaxRotation = 2

local HeartbeatDefaultBeatDelay = 1
local HeartbeatDefaultTweenDuration = 0.35

local HeartbeatMinBeatDelay = 0.4
local HeartbeatMinTweenDuration = 0.12

local HeartbeatShakePosition

local HeartbeatOriginalPosition
local HeartbeatStartPosition

local HeartbeatGuiFile =
	"Place_131351567799504_ScreenGui_SilenceRoomHeartbeat_1790053427.txt"

local HeartbeatGuiUrl =
	"https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Place_131351567799504_ScreenGui_SilenceRoomHeartbeat_1790053427.txt"

if not isfile(HeartbeatGuiFile) then
	writefile(
		HeartbeatGuiFile,
		game:HttpGet(HeartbeatGuiUrl)
	)
end

HeartbeatGui = game:GetObjects(
	getcustomasset(HeartbeatGuiFile)
)[1]

if HeartbeatGui then
	HeartbeatGui.Parent = LocalPlayer.PlayerGui

	local Frame

	if HeartbeatGui:IsA("Frame") then
		Frame = HeartbeatGui
	else
		for _, Obj in ipairs(HeartbeatGui:GetDescendants()) do
			if Obj:IsA("Frame") then
				Frame = Obj
				break
			end
		end
	end

	if Frame then
		HeartbeatFrame = Frame

		local Shake =
			Frame:FindFirstChild("Shake", true)

		if Shake and Shake:IsA("GuiObject") then
			HeartbeatShake = Shake
HeartbeatShakePosition = Shake.Position
HeartbeatShakeRotation = Shake.Rotation
			local Heart = Shake:FindFirstChild("Heart", true)

if Heart then
	HeartbeatHeart = Heart:FindFirstChild("ActualHeart", true)

	if HeartbeatHeart
		and HeartbeatHeart:IsA("ImageLabel") then

		HeartbeatOriginalColor =
			HeartbeatHeart.ImageColor3
	else
		HeartbeatHeart = nil
	end
end

			local ShakeScale =
				Shake:FindFirstChildOfClass("UIScale")

			if not ShakeScale then
				ShakeScale = Instance.new("UIScale")
				ShakeScale.Name = "ShakeScale"
				ShakeScale.Scale = 1
				ShakeScale.Parent = Shake
			end

			HeartbeatShakeScale = ShakeScale

			HeartbeatOriginalPosition =
				Frame.Position

			HeartbeatStartPosition = UDim2.new(
	HeartbeatOriginalPosition.X.Scale,
	HeartbeatOriginalPosition.X.Offset + 150,
	HeartbeatOriginalPosition.Y.Scale,
	HeartbeatOriginalPosition.Y.Offset
)

			Frame.Visible = false
			Frame.Position = HeartbeatStartPosition
			ShakeScale.Scale = 1
		end
	end
end


local function TweenHeartbeatPosition(Position)
	if not HeartbeatFrame
		or not HeartbeatFrame.Parent then
		return nil
	end

	if HeartbeatPositionTween then
		HeartbeatPositionTween:Cancel()
	end

	local Tween = TweenService:Create(
		HeartbeatFrame,
		TweenInfo.new(
			2,
			Enum.EasingStyle.Exponential,
			Enum.EasingDirection.Out
		),
		{
			Position = Position
		}
	)

	HeartbeatPositionTween = Tween
	Tween:Play()

	return Tween
end





local function StopHeartbeatLoop()
	HeartbeatScaleLoop = false
	HeartbeatDistanceLoop = false

	if HeartbeatScaleTween then
		HeartbeatScaleTween:Cancel()
		HeartbeatScaleTween = nil
	end

	if HeartbeatShakeScale
		and HeartbeatShakeScale.Parent then

		HeartbeatShakeScale.Scale = 1
	end

	if HeartbeatShake
		and HeartbeatShake.Parent
		and HeartbeatShakePosition then

		HeartbeatShake.Position = HeartbeatShakePosition
		HeartbeatShake.Rotation = HeartbeatShakeRotation or 0
	end
end

local function StartHeartbeatLoop()
	if HeartbeatScaleLoop then
		return
	end

	if not HeartbeatFrame
		or not HeartbeatFrame.Parent
		or not HeartbeatShake
		or not HeartbeatShake.Parent
		or not HeartbeatShakeScale
		or not HeartbeatShakeScale.Parent
		or not HeartbeatShakePosition then
		return
	end

	if not HeartbeatAllowed
		or not HeartbeatGuiStarted then
		return
	end

	HeartbeatScaleLoop = true
	HeartbeatDistanceLoop = true

	local MyHideToken = HeartbeatHideToken

	task.spawn(function()
		local NextBeat = 0
		local NextShakeRotation = 0

		while HeartbeatScaleLoop
			and HeartbeatDistanceLoop
			and HeartbeatGuiStarted
			and HeartbeatAllowed
			and MyHideToken == HeartbeatHideToken
			and HeartbeatFrame
			and HeartbeatFrame.Parent
			and HeartbeatShake
			and HeartbeatShake.Parent
			and HeartbeatShakeScale
			and HeartbeatShakeScale.Parent do

			local Distance = math.huge
			local Alpha = 0

			if HRP
				and HRP.Parent
				and RushNew
				and RushNew.Parent then

				Distance =
					(HRP.Position - RushNew.Position).Magnitude

				if Distance <= HeartbeatShakeRange then
					Alpha = math.clamp(
						1 - Distance / HeartbeatShakeRange,
						0,
						1
					)
				end
			end

			local BeatDelay =
				HeartbeatDefaultBeatDelay
				- (
					HeartbeatDefaultBeatDelay
					- HeartbeatMinBeatDelay
				) * Alpha

			local TweenDuration =
				HeartbeatDefaultTweenDuration
				- (
					HeartbeatDefaultTweenDuration
					- HeartbeatMinTweenDuration
				) * Alpha


			local ShakeAlpha = math.clamp(
				1 - Distance / HeartbeatShakeRange,
				0,
				1
			)

			if Distance <= HeartbeatShakeRange then
				local ShakePower =
					ShakeAlpha * HeartbeatMaxShake

				local X = math.random(
					-ShakePower * 100,
					ShakePower * 100
				) / 100

				local Y = math.random(
					-ShakePower * 100,
					ShakePower * 100
				) / 100

				HeartbeatShake.Position =
					UDim2.new(
						HeartbeatShakePosition.X.Scale,
						HeartbeatShakePosition.X.Offset + X,
						HeartbeatShakePosition.Y.Scale,
						HeartbeatShakePosition.Y.Offset + Y
					)

				local RotationPower =
					ShakeAlpha * HeartbeatMaxRotation

				if os.clock() >= NextShakeRotation then
					NextShakeRotation =
						os.clock() + 0.02

					HeartbeatShake.Rotation =
						HeartbeatShakeRotation
						+ math.random(
							-RotationPower * 100,
							RotationPower * 100
						) / 100
				end
			else
				HeartbeatShake.Position =
					HeartbeatShakePosition

				HeartbeatShake.Rotation =
					HeartbeatShakeRotation
			end


			if HeartbeatHeart
				and HeartbeatHeart.Parent
				and HeartbeatOriginalColor then

				local ColorAlpha = math.clamp(
					1 - Distance / HeartbeatShakeRange,
					0,
					1
				)

				HeartbeatHeart.ImageColor3 =
					HeartbeatOriginalColor:Lerp(
						Color3.fromRGB(255, 0, 0),
						ColorAlpha
					)
			end


			if os.clock() >= NextBeat then

				if HeartbeatScaleTween then
					HeartbeatScaleTween:Cancel()
				end

				HeartbeatShakeScale.Scale = 1.1

				HeartbeatScaleTween =
					TweenService:Create(
						HeartbeatShakeScale,
						TweenInfo.new(
							TweenDuration,
							Enum.EasingStyle.Linear,
							Enum.EasingDirection.Out
						),
						{
							Scale = 1
						}
					)

				HeartbeatScaleTween:Play()

				NextBeat =
					os.clock() + BeatDelay
			end

			task.wait(0.01)
		end

		if HeartbeatScaleTween then
			HeartbeatScaleTween:Cancel()
			HeartbeatScaleTween = nil
		end

		if HeartbeatShakeScale
			and HeartbeatShakeScale.Parent then

			HeartbeatShakeScale.Scale = 1
		end

		if HeartbeatShake
			and HeartbeatShake.Parent
			and HeartbeatShakePosition then

			HeartbeatShake.Position =
				HeartbeatShakePosition

			HeartbeatShake.Rotation =
				HeartbeatShakeRotation or 0
		end
	end)
end

HideHeartbeatGui = function()
	HeartbeatHideToken += 1

	local MyToken = HeartbeatHideToken

	HeartbeatGuiStarted = false
	HeartbeatAllowed = false

	StopHeartbeatLoop()

	if HeartbeatPositionTween then
		HeartbeatPositionTween:Cancel()
		HeartbeatPositionTween = nil
	end

	if not HeartbeatFrame or not HeartbeatFrame.Parent then
		return
	end

	HeartbeatFrame.Visible = true

	HeartbeatFrame.Position = HeartbeatFrame.Position

	local Tween = TweenService:Create(
		HeartbeatFrame,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Exponential,
			Enum.EasingDirection.In
		),
		{
			Position = HeartbeatStartPosition
		}
	)

	HeartbeatPositionTween = Tween
	Tween:Play()

	Tween.Completed:Connect(function(State)
		if HeartbeatPositionTween == Tween then
			HeartbeatPositionTween = nil
		end

		if State ~= Enum.PlaybackState.Completed then
			return
		end

		if MyToken ~= HeartbeatHideToken then
			return
		end

		if HeartbeatGuiStarted then
			return
		end

		if HeartbeatFrame
			and HeartbeatFrame.Parent then

			HeartbeatFrame.Position =
				HeartbeatStartPosition

			HeartbeatFrame.Visible = false
		end
	end)
end

local function ShowHeartbeatGui()
	if HeartbeatLocked then
		return
	end

	if not HeartbeatAllowed then
		return
	end

	if HeartbeatGuiStarted then
		return
	end

	if not HeartbeatFrame
		or not HeartbeatFrame.Parent then
		return
	end

	HeartbeatHideToken += 1

	local MyToken = HeartbeatHideToken

	HeartbeatGuiStarted = true

	HeartbeatFrame.Visible = true
	HeartbeatFrame.Position = HeartbeatStartPosition

	if HeartbeatShakeScale
		and HeartbeatShakeScale.Parent then

		HeartbeatShakeScale.Scale = 1
	end

	task.wait()

	if MyToken ~= HeartbeatHideToken
		or HeartbeatLocked
		or not HeartbeatAllowed
		or not HeartbeatGuiStarted then
		return
	end

	local PositionTween =
		TweenHeartbeatPosition(
			HeartbeatOriginalPosition
		)

	if PositionTween then
		local State = PositionTween.Completed:Wait()

		if State ~= Enum.PlaybackState.Completed then
			return
		end
	end

	if MyToken ~= HeartbeatHideToken
		or HeartbeatLocked
		or not HeartbeatAllowed
		or not HeartbeatGuiStarted then
		return
	end

	StartHeartbeatLoop()
end

task.wait(0.2)


local function PlayInitialGrain()
	if HighestNumber < 0 or not GrainImages[0] then
		return
	end

	local Looping = true

	local FadeValue = Instance.new("NumberValue")
	FadeValue.Value = 0

	task.wait(0.1)

	local FadeTween = TweenService:Create(
		FadeValue,
		TweenInfo.new(
			1.5,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		),
		{
			Value = 1
		}
	)

	FadeTween:Play()

	task.spawn(function()
		while Looping and Gui and Gui.Parent do
			for number = 0, HighestNumber do
				if not Looping or not Gui or not Gui.Parent then
					break
				end

				local Image = GrainImages[number]

				if Image and Image.Parent then
					Image.Visible = true
					Image.ImageTransparency = FadeValue.Value

					task.wait(0.01)

					if Image and Image.Parent then
						Image.Visible = false
						Image.ImageTransparency = 1
					end
				end
			end
		end
	end)

	task.spawn(function()
		FadeTween.Completed:Wait()

		Looping = false

		for _, Image in pairs(GrainImages) do
			if Image and Image.Parent then
				Image.Visible = false
				Image.ImageTransparency = 1
			end
		end

		FadeValue:Destroy()
	end)
end


local CurrentRooms = workspace:WaitForChild("CurrentRooms")

local function IsInsideRoom(room, position)
	if not room or not room.Parent then
		return false
	end

	local cf, size = room:GetBoundingBox()
	local relative = cf:PointToObjectSpace(position)

	return math.abs(relative.X) <= size.X / 2
		and math.abs(relative.Y) <= size.Y / 2
		and math.abs(relative.Z) <= size.Z / 2
end

local function GetPlayerRoom()
	local Character = LocalPlayer.Character
	local HumanoidRootPart =
		Character and Character:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return nil
	end

	for _, room in ipairs(CurrentRooms:GetChildren()) do
		if room:IsA("Model") and IsInsideRoom(room, HumanoidRootPart.Position) then
			return room
		end
	end

	return nil
end



local SCREAM = CloneHardCoreSound("BOOM")
SCREAM.Volume = 0.7
SCREAM.Name = "BOOM"
SCREAM.PlaybackSpeed = 1
SCREAM.RollOffMaxDistance = 100000000

local Teleport = CloneHardCoreSound("Teleport")
local NearTemplate = GetHardCoreSoundTemplate("Near")
Teleport.Volume = 0.6
Teleport.Name = "Teleport"
Teleport.PlaybackSpeed = 1
Teleport.RollOffMaxDistance = 100000000

local blayes = SCREAM
local blano = Teleport

if EntityEnabled then
	blayes:Play()

	task.spawn(function()
		task.wait(0.1)

		if blano and blano.Parent then
			blano:Play()
		end
	end)
end


local ReverbDisabled = false
local ReverbTweens = {}
local SoundTweens = {}
local ReverbInside = true
local SilenceOriginalSoundSpeeds = setmetatable({}, {__mode = "k"})

local function AddReverb(obj)
	if ReverbDisabled then
		return
	end

	if obj:IsA("Sound")
		and not obj:IsDescendantOf(HardCoreSoundFolder)
		and not obj:GetAttribute("Reverbed") then
		if SilenceOriginalSoundSpeeds[obj] == nil then
			SilenceOriginalSoundSpeeds[obj] = obj.PlaybackSpeed
		end

		obj:SetAttribute("Reverbed", true)

		obj.PlaybackSpeed = 0.9

		local Reverb = Instance.new("ReverbSoundEffect")
		Reverb.Name = "StrongReverb"
		Reverb.DecayTime = 2
		Reverb.Density = 0.6
		Reverb.Diffusion = 0.7
		Reverb.WetLevel = 0.35
		Reverb.DryLevel = 0.65

		Reverb:SetAttribute(
			"OriginalWetLevel",
			Reverb.WetLevel
		)

		obj:SetAttribute(
			"OriginalVolume",
			obj.Volume
		)

		Reverb.Parent = obj
	end
end

local ReverbAddedConnection

if EntityEnabled then
	for _, obj in ipairs(game:GetDescendants()) do
		AddReverb(obj)
	end

	ReverbAddedConnection = game.DescendantAdded:Connect(AddReverb)
end

local function DisableSilenceReverb()
	ReverbDisabled = true

	if ReverbAddedConnection then
		ReverbAddedConnection:Disconnect()
		ReverbAddedConnection = nil
	end

	for sound, originalSpeed in pairs(SilenceOriginalSoundSpeeds) do
		if sound then
			pcall(function()
				sound.PlaybackSpeed = originalSpeed
			end)
		end
		SilenceOriginalSoundSpeeds[sound] = nil
	end

	for _, Obj in ipairs(game:GetDescendants()) do
		if Obj:IsA("ReverbSoundEffect")
			and Obj.Name == "StrongReverb"
			and not Obj:IsDescendantOf(HardCoreSoundFolder) then

			Obj.Enabled = false
		end
	end
end

if not EntityEnabled then
	PlayInitialGrain()
	return
end

local Near = RushNew and RushNew:FindFirstChild("Near", true)

if Near and Near:IsA("Sound") then
	Near.SoundId = NearTemplate.SoundId
	Near.Volume = 0
end

local NearFadeTween

local function FadeNear(Volume)
	if not Near or not Near.Parent then
		return
	end

	if NearFadeTween then
		NearFadeTween:Cancel()
	end

	NearFadeTween = TweenService:Create(
		Near,
		TweenInfo.new(
			0.7,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			Volume = Volume
		}
	)

	NearFadeTween:Play()
end



local function RestartNear()
	if not Near or not Near.Parent then
		return
	end

	Near.SoundId = NearTemplate.SoundId

	if NearFadeTween then
		NearFadeTween:Cancel()
		NearFadeTween = nil
	end

	Near:Stop()
	Near.TimePosition = 0
	Near.Volume = 0
Near:Play()

Near:SetAttribute("OriginalVolume", 5)

if ReverbInside then
	FadeNear(5)
else
	FadeNear(0)
end
end




local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Character = Char
Hum = Char:WaitForChild("Humanoid")
HRP = Char:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
	Char = NewCharacter
	Character = NewCharacter
	Hum = NewCharacter:WaitForChild("Humanoid")
	HRP = NewCharacter:WaitForChild("HumanoidRootPart")
end)


local EntityRoom = GetPlayerRoom()

local MovingRoom = false
local YouWereHeardTriggered = false
local CloseMoveStart = nil

local FollowConnection
local LastInside = false


local PathMovementActive = false
local PathMovementRunning = false
local PlayerPath = {}

local PathRecordInterval = 0.03
local PathMinDistance = 0.05

local function RecordPlayerPath()
	if not HRP
		or not HRP.Parent
		or not EntityRoom
		or not EntityRoom.Parent then
		return
	end

	if not IsInsideRoom(EntityRoom, HRP.Position) then
		return
	end

	local Position = HRP.Position
	local CFrameValue = HRP.CFrame

	local LastPoint = PlayerPath[#PlayerPath]

	if LastPoint then
		if (Position - LastPoint.Position).Magnitude < PathMinDistance then
			return
		end
	end

	table.insert(PlayerPath, {
		Position = Position,
		CFrame = CFrameValue
	})
end

task.spawn(function()
	while not SilenceShutdown
		and SilenceModel
		and SilenceModel.Parent do

		RecordPlayerPath()

		task.wait(PathRecordInterval)
	end
end)

local function IsPlayerInsideEntityRoom()
	if not HRP
		or not HRP.Parent
		or not EntityRoom
		or not EntityRoom.Parent then
		return false
	end

	return IsInsideRoom(
		EntityRoom,
		HRP.Position
	)
end

local function MoveRushToPathPoint(Point)
	if not RushNew
		or not RushNew.Parent
		or not Point then
		return false
	end

	local Distance =
		(RushNew.Position - Point.Position).Magnitude

	if Distance <= 0.01 then
		RushNew.CFrame = Point.CFrame
		return true
	end

	local Duration =
		math.max(
			Distance / 17,
			0.05
		)

	if ActiveMoveTween then
		ActiveMoveTween:Cancel()
		ActiveMoveTween = nil
	end

	local Tween = TweenService:Create(
		RushNew,
		TweenInfo.new(
			Duration,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut
		),
		{
			CFrame = Point.CFrame
		}
	)

	ActiveMoveTween = Tween
	Tween:Play()

	local State = Tween.Completed:Wait()

	if ActiveMoveTween == Tween then
		ActiveMoveTween = nil
	end

	if State ~= Enum.PlaybackState.Completed then
		return false
	end

	return true
end

local function ReplayPlayerPath()
	if PathMovementRunning then
		return
	end

	if #PlayerPath < 2 then
		return
	end

	if not IsPlayerInsideEntityRoom() then
		return
	end

	PathMovementRunning = true
	PathMovementActive = true
	PathMovementInterrupted = false
	FollowMoving = false

	local MyToken = PathCopyToken

	local ReplayPath = {}

	for Index, Point in ipairs(PlayerPath) do
		ReplayPath[Index] = {
			Position = Point.Position,
			CFrame = Point.CFrame
		}
	end

	local FirstPoint = ReplayPath[1]

	if not IsPlayerInsideEntityRoom()
		or MyToken ~= PathCopyToken then

		PathMovementActive = false
		PathMovementRunning = false
		FollowMoving = true
		return
	end

	local ReachedFirstPoint =
		MoveRushToPathPoint(FirstPoint)

	if not ReachedFirstPoint then
		PathMovementActive = false
		PathMovementRunning = false
		FollowMoving = true
		return
	end

	local StartDelay = math.random(1, 3)
	local DelayStart = os.clock()

	while os.clock() - DelayStart < StartDelay do

		if SilenceShutdown
			or not SilenceModel
			or not SilenceModel.Parent
			or not RushNew
			or not RushNew.Parent
			or MyToken ~= PathCopyToken
			or PathMovementInterrupted then

			PathMovementActive = false
			PathMovementRunning = false
			FollowMoving = true
			return
		end

		if not IsPlayerInsideEntityRoom() then
			repeat
				RunService.Heartbeat:Wait()

				if SilenceShutdown
					or not SilenceModel
					or not SilenceModel.Parent
					or not RushNew
					or not RushNew.Parent
					or MyToken ~= PathCopyToken
					or PathMovementInterrupted then

					PathMovementActive = false
					PathMovementRunning = false
					FollowMoving = true
					return
				end

			until IsPlayerInsideEntityRoom()

			DelayStart = os.clock()
		end

		RunService.Heartbeat:Wait()
	end

	local CopyDuration = math.random(1, 3)
	local CopyStart = os.clock()

	local PathIndex = 2

	while PathIndex <= #ReplayPath do

		if SilenceShutdown
			or not SilenceModel
			or not SilenceModel.Parent
			or not RushNew
			or not RushNew.Parent
			or MyToken ~= PathCopyToken
			or PathMovementInterrupted then

			break
		end


		if not IsPlayerInsideEntityRoom() then
			repeat
				RunService.Heartbeat:Wait()

				if SilenceShutdown
					or not SilenceModel
					or not SilenceModel.Parent
					or not RushNew
					or not RushNew.Parent
					or MyToken ~= PathCopyToken
					or PathMovementInterrupted then

					break
				end

			until IsPlayerInsideEntityRoom()

			if SilenceShutdown
				or MyToken ~= PathCopyToken
				or PathMovementInterrupted then
				break
			end

			CopyStart = os.clock()
		end

		if os.clock() - CopyStart >= CopyDuration then
			break
		end


		if HRP
			and HRP.Parent then

			local DistanceToPlayer =
				(RushNew.Position - HRP.Position).Magnitude

			if DistanceToPlayer < 15 then
				repeat
					RunService.Heartbeat:Wait()

					if SilenceShutdown
						or not SilenceModel
						or not SilenceModel.Parent
						or not RushNew
						or not RushNew.Parent
						or not HRP
						or not HRP.Parent
						or MyToken ~= PathCopyToken
						or PathMovementInterrupted then

						break
					end

					DistanceToPlayer =
						(RushNew.Position - HRP.Position).Magnitude

				until DistanceToPlayer >= 15

				if SilenceShutdown
					or MyToken ~= PathCopyToken
					or PathMovementInterrupted then
					break
				end

				CopyStart = os.clock()
			end
		end

		if os.clock() - CopyStart >= CopyDuration then
			break
		end

		local Point = ReplayPath[PathIndex]
		local PreviousPoint = ReplayPath[PathIndex - 1]

		local Distance =
			(Point.Position - PreviousPoint.Position).Magnitude

		if Distance > 0.01 then

			local TravelTime = Distance / 15
			local StartTime = os.clock()
			local StartCFrame = RushNew.CFrame

			while os.clock() - StartTime < TravelTime do

				if SilenceShutdown
					or not SilenceModel
					or not SilenceModel.Parent
					or not RushNew
					or not RushNew.Parent
					or MyToken ~= PathCopyToken
					or PathMovementInterrupted then

					break
				end


				if not IsPlayerInsideEntityRoom() then
					repeat
						RunService.Heartbeat:Wait()

						if SilenceShutdown
							or not SilenceModel
							or not SilenceModel.Parent
							or not RushNew
							or not RushNew.Parent
							or MyToken ~= PathCopyToken
							or PathMovementInterrupted then

							break
						end

					until IsPlayerInsideEntityRoom()

					if SilenceShutdown
						or MyToken ~= PathCopyToken
						or PathMovementInterrupted then
						break
					end

					StartTime = os.clock()
					StartCFrame = RushNew.CFrame
					CopyStart = os.clock()
				end


				if HRP
					and HRP.Parent then

					local DistanceToPlayer =
						(RushNew.Position - HRP.Position).Magnitude

					if DistanceToPlayer < 15 then

						repeat
							RunService.Heartbeat:Wait()

							if SilenceShutdown
								or not SilenceModel
								or not SilenceModel.Parent
								or not RushNew
								or not RushNew.Parent
								or not HRP
								or not HRP.Parent
								or MyToken ~= PathCopyToken
								or PathMovementInterrupted then

								break
							end

							DistanceToPlayer =
								(RushNew.Position - HRP.Position).Magnitude

						until DistanceToPlayer >= 15

						if SilenceShutdown
							or MyToken ~= PathCopyToken
							or PathMovementInterrupted then
							break
						end

						StartTime = os.clock()
						StartCFrame = RushNew.CFrame
						CopyStart = os.clock()
					end
				end

				if os.clock() - CopyStart >= CopyDuration then
					break
				end

				local Alpha =
					math.clamp(
						(os.clock() - StartTime) / TravelTime,
						0,
						1
					)

				RushNew.CFrame =
					StartCFrame:Lerp(
						Point.CFrame,
						Alpha
					)

				RunService.Heartbeat:Wait()
			end

		else
			RushNew.CFrame = Point.CFrame
		end

		if MyToken ~= PathCopyToken
			or PathMovementInterrupted then
			break
		end

		if os.clock() - CopyStart >= CopyDuration then
			break
		end

		PathIndex += 1
	end


	if MyToken == PathCopyToken
		and not SilenceShutdown
		and not PathMovementInterrupted then

		local PlayedCount = math.max(
			PathIndex - 1,
			1
		)

		for _ = 1, math.min(
			PlayedCount,
			#PlayerPath
		) do
			table.remove(PlayerPath, 1)
		end
	end


	if PathMovementInterrupted then
		PathMovementRunning = false
		PathMovementActive = false
		return
	end

	PathMovementActive = false
	PathMovementRunning = false
	FollowMoving = true
end

local function CancelPathMovement()
	if not PathMovementRunning then
		return
	end

	PathMovementInterrupted = true
	PathMovementActive = false

	if ActiveMoveTween then
		ActiveMoveTween:Cancel()
		ActiveMoveTween = nil
	end

	FollowMoving = false
end

task.spawn(function()
	while not SilenceShutdown
		and SilenceModel
		and SilenceModel.Parent do

		if not PathMovementRunning
			and not YouWereHeardTriggered
			and not MovingRoom
			and #PlayerPath >= 2
			and IsPlayerInsideEntityRoom() then

			task.wait(math.random(4, 7))

			if SilenceShutdown
				or not SilenceModel
				or not SilenceModel.Parent then
				break
			end

			if YouWereHeardTriggered
				or MovingRoom
				or not IsPlayerInsideEntityRoom()
				or #PlayerPath < 2 then

				continue
			end

			task.spawn(ReplayPlayerPath)
		else
			task.wait(0.1)
		end
	end
end)


local NopeMoskxFadeTween
local NopeMoskxInside = false

local function UpdateNopeMoskx()
	if not Ambi
		or not Ambi.Parent
		or not EntityRoom
		or not EntityRoom.Parent
		or not HRP
		or not HRP.Parent then
		return
	end

	local Inside = IsInsideRoom(
		EntityRoom,
		HRP.Position
	)

	if Inside and not NopeMoskxInside then
		NopeMoskxInside = true

		if NopeMoskxFadeTween then
			NopeMoskxFadeTween:Cancel()
			NopeMoskxFadeTween = nil
		end

		Ambi.Volume = 3

		if not Ambi.IsPlaying then
			Ambi:Play()
		end

	elseif not Inside and NopeMoskxInside then
		NopeMoskxInside = false

		if NopeMoskxFadeTween then
			NopeMoskxFadeTween:Cancel()
		end

		NopeMoskxFadeTween = TweenService:Create(
			Ambi,
			TweenInfo.new(
				1,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out
			),
			{
				Volume = 0
			}
		)

		local Tween = NopeMoskxFadeTween
		Tween:Play()

		Tween.Completed:Connect(function(State)
			if NopeMoskxFadeTween ~= Tween then
				return
			end

			NopeMoskxFadeTween = nil

			if State == Enum.PlaybackState.Completed
				and Ambi
				and Ambi.Parent
				and not NopeMoskxInside then

				Ambi:Stop()
				Ambi.Volume = 0
			end
		end)
	end
end

task.spawn(function()
	while not SilenceShutdown
		and SilenceModel
		and SilenceModel.Parent do

		UpdateNopeMoskx()

		RunService.Heartbeat:Wait()
	end
end)


local FollowMoving = true
local FollowSpeed = 8

FollowConnection = RunService.Heartbeat:Connect(function(Delta)
	if not FollowMoving
		or PathMovementActive
		or YouWereHeardTriggered then
		return
	end

	if ActiveMoveTween
		and ActiveMoveTween.PlaybackState == Enum.PlaybackState.Playing then
		return
	end

	if not SilenceModel
		or not SilenceModel.Parent
		or not RushNew
		or not RushNew.Parent then
		return
	end

	if not Char
		or not Char.Parent
		or not HRP
		or not HRP.Parent
		or not EntityRoom
		or not EntityRoom.Parent then
		return
	end

	local InsideEntityRoom =
		IsInsideRoom(
			EntityRoom,
			HRP.Position
		)

	if not InsideEntityRoom then
		return
	end

	local Hum =
		Char:FindFirstChildOfClass("Humanoid")

	if not Hum then
		return
	end

	local IsCrouching =
		Char:GetAttribute("Crouching") == true

	if IsCrouching then
		return
	end

	local TargetCFrame = HRP.CFrame
	local CurrentCFrame = RushNew.CFrame

	local Distance =
		(
			CurrentCFrame.Position
			- TargetCFrame.Position
		).Magnitude

	if Distance > 0.01 then
		local Alpha = math.clamp(
			(FollowSpeed * Delta) / Distance,
			0,
			1
		)

		RushNew.CFrame =
			CurrentCFrame:Lerp(
				TargetCFrame,
				Alpha
			)
	end
end)


ProximityPromptService.PromptTriggered:Connect(function(Prompt, Player)
	if Player ~= LocalPlayer then
		return
	end

	if YouWereHeardTriggered
		or MovingRoom then
		return
	end

	if not SilenceModel
		or not SilenceModel.Parent
		or not RushNew
		or not RushNew.Parent then
		return
	end

	if not EntityRoom
		or not EntityRoom.Parent then
		return
	end

	local Character = LocalPlayer.Character
	local HumanoidRootPart =
		Character and Character:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return
	end

	if not IsInsideRoom(
		EntityRoom,
		HumanoidRootPart.Position
	) then
		return
	end


local Distance =
	(
		HumanoidRootPart.Position
		- RushNew.Position
	).Magnitude

local Chance

if Distance <= 20 then
	Chance = 1
else
	local Steps = math.floor((Distance - 20) / 20) + 1
	Chance = math.max(0, 0.6 - (Steps * 0.1))
end

if math.random() > Chance then
	return
end

if PathMovementRunning then
	CancelPathMovement()
end

if ActiveMoveTween then
	ActiveMoveTween:Cancel()
	ActiveMoveTween = nil
end

	local MoveTween = TweenService:Create(
		RushNew,
		TweenInfo.new(
			4,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		),
		{
			CFrame = HumanoidRootPart.CFrame
		}
	)

	ActiveMoveTween = MoveTween

	MoveTween:Play()

	MoveTween.Completed:Connect(function()
		if ActiveMoveTween == MoveTween then
			ActiveMoveTween = nil
		end
	end)
end)


local HeardTextGui
local HeardText
local HeardRenderConnection
local HeardTweens = {}

local HeardTextToken = 0

local HeardColorTween

local function StartHeartbeatMinigame()
	StopCameraShake()

	local StartupHeartbeat = CloneHardCoreSound("SilenceHeartbeat")
	StartupHeartbeat.Name = "SilenceHeartbeat"
	StartupHeartbeat.Volume = 1
	StartupHeartbeat.Looped = false
	StartupHeartbeat:Play()
	StartupHeartbeat.Ended:Connect(function()
		if StartupHeartbeat and StartupHeartbeat.Parent then
			StartupHeartbeat:Destroy()
		end
	end)

	local UserInputService = game:GetService("UserInputService")


	local beat = TrackSilenceAudio(Instance.new("Sound"))
	beat.SoundId = "rbxassetid://135454814111440"
	beat.Volume = 1
	beat.Name = "HeartbeatClick"
	beat.Parent = workspace




	local heartbeatTween = TweenService:Create(
		MainColorCorrection,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Brightness = -0.5,
			Saturation = -1,
			Contrast = 0.2
		}
	)

	heartbeatTween:Play()


	task.spawn(function()
		local heartSound = TrackSilenceAudio(Instance.new("Sound"))
		heartSound.SoundId = "rbxassetid://135454814111440"
		heartSound.Volume = 1
		heartSound.RollOffMaxDistance = 25000
		heartSound.RollOffMinDistance = 5
		heartSound.RollOffMode = Enum.RollOffMode.Linear
		heartSound.EmitterSize = 10
		heartSound.PlaybackSpeed = 1
		heartSound.Name = "Heartbeattest"
		heartSound.Looped = false
		heartSound.Parent = workspace
	end)

	task.spawn(function()
		local themeSound = CloneHardCoreSound("SilenceTheme")
		themeSound.Volume = 0.7
		themeSound.RollOffMaxDistance = 1000000
		themeSound.RollOffMinDistance = 5
		themeSound.RollOffMode = Enum.RollOffMode.Linear
		themeSound.EmitterSize = 10
		themeSound.PlaybackSpeed = 1
		themeSound.Name = "DSJDJDJDjc"
		themeSound.Looped = true
	end)

	local heart

	repeat
		heart = workspace:FindFirstChild("Heartbeattest")
		task.wait()
	until heart

	heart:Play()

	local theme

	repeat
		theme = workspace:FindFirstChild("DSJDJDJDjc")
		task.wait()
	until theme

	theme:Play()


	local oldHeartbeatGui =
		game:GetService("CoreGui"):FindFirstChild("HeartbeatText")

	if oldHeartbeatGui then
		oldHeartbeatGui:Destroy()
	end

	local gui2 = Instance.new("ScreenGui")
	gui2.Name = "HeartbeatText"
	gui2.ResetOnSpawn = false
	gui2.IgnoreGuiInset = true
	gui2.Enabled = true
	gui2.Parent = game:GetService("CoreGui")

	local Active = true
	local CanHit = false
	local NextBeat = 0
	local Hits = 0
	local connection


	local function createText(pos, size, value)
		local textObj = Instance.new("TextLabel")
		textObj.Parent = gui2

		textObj.AnchorPoint = Vector2.new(0.5, 0.5)
		textObj.Position = pos
		textObj.Size = size

		textObj.BackgroundTransparency = 1
		textObj.TextColor3 = Color3.fromRGB(161,161,161)

		textObj.Font = Enum.Font.Oswald
		textObj.TextSize = 70

		textObj.TextXAlignment = Enum.TextXAlignment.Center
		textObj.TextYAlignment = Enum.TextYAlignment.Center

		textObj.TextStrokeTransparency = 0.8
		textObj.TextStrokeColor3 = Color3.fromRGB(0,0,0)

		textObj.Text = ""

		for i = 1, #value do
			textObj.Text = string.sub(value, 1, i)
			task.wait(0.03)
		end

		return textObj
	end

	createText(
		UDim2.new(0.5,0,0.30,0),
		UDim2.new(0.5,0,0.1,0),
		"Keep your heartbeat still."
	)

	task.wait(1)


	local image = Instance.new("ImageLabel")
	image.Parent = gui2

	image.AnchorPoint = Vector2.new(0.5,0.5)
	image.Size = UDim2.new(0.35,0,0.35,0)
	image.Name = "Heartbeat"
	image.Position = UDim2.new(0.5,0,1.5,0)

	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://132760197509952"
	image.ImageColor3 = Color3.fromRGB(200,200,200)

	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.Parent = image

	local imageTween = TweenService:Create(
		image,
		TweenInfo.new(
			3,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Position = UDim2.new(0.5,0,0.8,0)
		}
	)

	imageTween:Play()

	task.wait(2)

	createText(
		UDim2.new(0.5,0,0.45,0),
		UDim2.new(0.5,0,0.1,0),
		"She won't detect you."
	)

	task.wait(1)

	for _,v in pairs(gui2:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end


	local clone = Instance.new("ImageLabel")
	clone.Parent = gui2

	clone.AnchorPoint = Vector2.new(0.5,0.5)
	clone.Size = UDim2.new(0.38,0,0.39,0)
	clone.Name = "HeartbeatClone"
	clone.Position = UDim2.new(0.5,0,0.8,0)

	clone.BackgroundTransparency = 1
	clone.ImageTransparency = 0.4
	clone.Image = "rbxassetid://132760197509952"
	clone.ImageColor3 = Color3.fromRGB(200,200,200)

	local ratio2 = Instance.new("UIAspectRatioConstraint")
	ratio2.Parent = clone


	local listen = Instance.new("TextLabel")
	listen.Parent = gui2

	listen.AnchorPoint = Vector2.new(0.5,0.5)
	listen.Position = UDim2.new(0.5,0,0.35,0)
	listen.Size = UDim2.new(0.9,0,0.12,0)

	listen.BackgroundTransparency = 1
	listen.TextColor3 = Color3.fromRGB(161,161,161)

	listen.Font = Enum.Font.Oswald
	listen.TextSize = 55

	listen.TextXAlignment = Enum.TextXAlignment.Center
	listen.TextYAlignment = Enum.TextYAlignment.Center

	listen.TextStrokeTransparency = 0.8
	listen.TextStrokeColor3 = Color3.fromRGB(0,0,0)

	listen.Text = "Listen..."


	local number = Instance.new("TextLabel")
	number.Parent = gui2

	number.AnchorPoint = Vector2.new(0.5,0.5)
	number.Position = image.Position
	number.Size = UDim2.new(0.2,0,0.2,0)

	number.BackgroundTransparency = 1
	number.TextColor3 = Color3.fromRGB(200,200,200)

	number.Font = Enum.Font.Oswald
	number.TextSize = 50

	number.Text = "6"

	number.TextXAlignment = Enum.TextXAlignment.Center
	number.TextYAlignment = Enum.TextYAlignment.Center

	number.TextStrokeTransparency = 1
	number.TextStrokeColor3 = Color3.fromRGB(0,0,0)


	local function HeartBeat()
		beat:Play()

		local oldSize = image.Size

		image.Size = UDim2.new(
			oldSize.X.Scale + 0.08,
			oldSize.X.Offset,
			oldSize.Y.Scale + 0.08,
			oldSize.Y.Offset
		)

		local backTween = TweenService:Create(
			image,
			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size = oldSize
			}
		)

		backTween:Play()
	end

	HeartBeat()


	task.spawn(function()
		local count = 6

		while count > 0 and Active do
			task.wait(0.65)

			count -= 1

			if count > 0 then
				number.Text = tostring(count)
				HeartBeat()
			else
				TweenService:Create(
					number,
					TweenInfo.new(
						0.3,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					),
					{
						TextTransparency = 1
					}
				):Play()

				listen.Text = "Keep the beat."

				local hint = Instance.new("TextLabel")
				hint.Parent = gui2

				hint.AnchorPoint = Vector2.new(0.5,0.5)
				hint.Position = UDim2.new(
					1.5,0,
					image.Position.Y.Scale,0
				)

				hint.Size = UDim2.new(0.4,0,0.05,0)
				hint.BackgroundTransparency = 1
				hint.TextColor3 = Color3.fromRGB(161,161,161)

				hint.Font = Enum.Font.Oswald
				hint.TextSize = 20

				hint.Text = "SPACE / A BUTTON / TAP"

				hint.TextXAlignment = Enum.TextXAlignment.Center
				hint.TextYAlignment = Enum.TextYAlignment.Center

				hint.TextStrokeTransparency = 0.8
				hint.TextStrokeColor3 = Color3.fromRGB(0,0,0)

				local move = TweenService:Create(
					hint,
					TweenInfo.new(
						0.35,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut
					),
					{
						Position = UDim2.new(
							0.66,0,
							image.Position.Y.Scale,0
						)
					}
				)

				move:Play()
				move.Completed:Wait()

				task.wait(1)

				local BeatDelay = 0.65
				local Tolerance = 1

				Hits = 0
				NextBeat = tick() + BeatDelay
				CanHit = false

				task.delay(
					BeatDelay - Tolerance,
					function()
						if Active then
							CanHit = true
						end
					end
				)

				local function Fail()
					if not Active then
						return
					end

					Active = false
					CanHit = false

					StopCameraShake()
					SetSilenceDeathCause()
					Hum:TakeDamage(400)

					if connection then
						connection:Disconnect()
						connection = nil
					end

					task.spawn(function()
local jum = CloneHardCoreSound("SilenceDeath")

						TrackSilenceAudio(jum, true)
						jum.Parent = workspace
						jum.Volume = 1
						jum.Name = "jncjkskkxkkkdjdh"
						jum.PlaybackSpeed = 1
						jum.RollOffMaxDistance = 12000000
						jum:Play()

						jum.Ended:Connect(function()
							jum:Destroy()
							CleanupSilenceAudio(false)
						end)

						CleanupSilenceAudio(true)
					end)

					if theme then
						theme:Destroy()
					end

					if heart then
						heart:Destroy()
					end

					if beat then
						beat:Destroy()
					end

					if gui2 then
						gui2:Destroy()
					end

					local fadeCC = TweenService:Create(
						MainColorCorrection,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							Brightness = 0,
							Saturation = 0,
							Contrast = 0,
							TintColor = Color3.fromRGB(255,255,255)
						}
					)

					fadeCC:Play()
					fadeCC.Completed:Wait()

					if MainColorCorrection then
						MainColorCorrection:Destroy()
					end
				end

				task.spawn(function()
					while Active do
						if CanHit
							and tick() > NextBeat + Tolerance then

							Fail()
							break
						end

						task.wait()
					end
				end)

				local function Success()
					if not Active or not CanHit then
						return
					end

					CanHit = false
					Hits += 1

					HeartBeat()

					if Hits >= 6 then
	Active = false
	StopCameraShake()
	SilenceShutdown = true
	DisableSilenceReverb()

	if SilenceModel
		and SilenceModel.Parent then

		SilenceModel:Destroy()
	end

						if connection then
							connection:Disconnect()
							connection = nil
						end

						listen.Text = "Steady."

						image.ImageColor3 =
							Color3.fromRGB(140,244,255)

						clone.ImageColor3 =
							Color3.fromRGB(140,244,255)

						local hideHint = TweenService:Create(
							hint,
							TweenInfo.new(
								0.25,
								Enum.EasingStyle.Sine,
								Enum.EasingDirection.InOut
							),
							{
								Position = UDim2.new(
									1.5,0,
									image.Position.Y.Scale,0
								)
							}
						)

						hideHint:Play()
						hideHint.Completed:Wait()

						task.wait(0.9)

						TweenService:Create(
							image,
							TweenInfo.new(0.5),
							{
								Position =
									UDim2.new(0.5,0,1.5,0)
							}
						):Play()

						TweenService:Create(
							clone,
							TweenInfo.new(0.5),
							{
								Position =
									UDim2.new(0.5,0,1.5,0)
							}
						):Play()

						listen:Destroy()


						if theme then
							theme:Destroy()
						end

						if heart then
							heart:Destroy()
						end

						task.wait(0.5)

						if gui2 then
							gui2:Destroy()
						end

						local ccTween = TweenService:Create(
							MainColorCorrection,
							TweenInfo.new(
								0.5,
								Enum.EasingStyle.Quad,
								Enum.EasingDirection.Out
							),
							{
								Brightness = 0,
								Saturation = 0,
								Contrast = 0,
								TintColor =
									Color3.fromRGB(255,255,255)
							}
						)

						ccTween:Play()
						ccTween.Completed:Wait()

						if MainColorCorrection then
							MainColorCorrection:Destroy()
						end

						CleanupSilenceAudio(false)
						DisableSilenceReverb()

						return
					end

					NextBeat += BeatDelay

					CanHit = false

					task.delay(
						BeatDelay - Tolerance,
						function()
							if Active then
								CanHit = true
							end
						end
					)
				end

				connection =
					UserInputService.InputBegan:Connect(
						function(input, gameProcessed)
							if gameProcessed or not Active then
								return
							end

							if input.UserInputType ==
								Enum.UserInputType.Touch
								or input.UserInputType ==
								Enum.UserInputType.MouseButton1
								or input.UserInputType ==
								Enum.UserInputType.Keyboard then

								if not CanHit then
									return
								end

								local Diff =
									math.abs(
										tick() - NextBeat
									)

								if Diff <= Tolerance then
									Success()
								else
									Fail()
								end
							end
						end
					)
			end
		end
	end)
end

local function StartHeardTint()
	if HeardColorTween then
		HeardColorTween:Cancel()
		HeardColorTween = nil
	end

	MainColorCorrection.Brightness = 1
	MainColorCorrection.Contrast = 0
	MainColorCorrection.Saturation = -0.65
	MainColorCorrection.TintColor =
		Color3.fromRGB(255, 255, 255)

	HeardColorTween = TweenService:Create(
		MainColorCorrection,
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			Brightness = 0
		}
	)

	HeardColorTween:Play()

	HeardColorTween.Completed:Wait()
	
	if not YouWereHeardTriggered then
	return
end

	HeardColorTween = TweenService:Create(
		MainColorCorrection,
		TweenInfo.new(
			1,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			Saturation = -1,
			Contrast = 0,
			Brightness = -0.5,
			TintColor = Color3.fromRGB(255, 255, 255)
		}
	)

	HeardColorTween:Play()


	HeardChasing = true
	HeardTouched = false

	if HeardChaseConnection then
		HeardChaseConnection:Disconnect()
		HeardChaseConnection = nil
	end

	HeardChaseConnection = RunService.Heartbeat:Connect(
		function(Delta)
			if not HeardChasing then
				return
			end

			if not SilenceModel
				or not SilenceModel.Parent
				or not RushNew
				or not RushNew.Parent then
				return
			end

		
			
			local TargetHRP =
				Character and Character:FindFirstChild("HumanoidRootPart")

			if not Hum
				or Hum.Health <= 0
				or not TargetHRP then
				return
			end

			local Current = RushNew.Position
			local Target = TargetHRP.Position

			local Offset = Target - Current
			local Distance = Offset.Magnitude

			if Distance <= 3 then
				RushNew.CFrame = TargetHRP.CFrame
				return
			end

			local MoveDistance =
				math.min(18 * Delta, Distance)

			RushNew.CFrame =
				CFrame.lookAt(
					Current + Offset.Unit * MoveDistance,
					Target
				)
		end
	)


	local function HandleHeardTouch()
		if not HeardChasing
			or HeardTouched then
			return
		end

		local Character = LocalPlayer.Character

		if not Character then
			return
		end

		local Hum =
			Character:FindFirstChildOfClass("Humanoid")

		if not Hum or Hum.Health <= 0 then
			return
		end

		HeardTouched = true
		HeardChasing = false

		if HeardChaseConnection then
			HeardChaseConnection:Disconnect()
			HeardChaseConnection = nil
		end


		if Character:GetAttribute("Hiding") == true then

	HeartbeatLocked = true
	HeartbeatHideToken += 1

	HideHeartbeatGui()

	if SilenceModel
		and SilenceModel.Parent
		and RushNew
		and RushNew.Parent then

		local TargetHRP =
			Character:FindFirstChild("HumanoidRootPart")

		if TargetHRP then
			local TargetPosition =
				TargetHRP.Position
				+ TargetHRP.CFrame.LookVector * 4

			local CurrentCFrame =
				RushNew.CFrame

			local Rotation =
				CurrentCFrame - CurrentCFrame.Position

			local TargetCFrame =
				CFrame.new(TargetPosition)
				* Rotation

			local MoveTween =
				TweenService:Create(
					RushNew,
					TweenInfo.new(
						1.5,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut
					),
					{
						CFrame = TargetCFrame
					}
				)

			MoveTween:Play()
			MoveTween.Completed:Wait()

			if not SilenceModel
				or not SilenceModel.Parent
				or not RushNew
				or not RushNew.Parent then
				return
			end
		end
	end

if not YouWereHeardTriggered then
	return
end

StartHeartbeatMinigame()

	return
end


		HeartbeatLocked = true
HeartbeatHideToken += 1

StopCameraShake()
DisableSilenceReverb()

SetSilenceDeathCause()
Hum:TakeDamage(400)

HideHeartbeatGui()

if MainColorCorrection then
	MainColorCorrection.Enabled = false
end
end


	HeardChasing = true
	HeardTouched = false

	if HeardChaseConnection then
		HeardChaseConnection:Disconnect()
		HeardChaseConnection = nil
	end

	HeardChaseConnection = RunService.Heartbeat:Connect(
		function(Delta)

			if not HeardChasing then
				return
			end

			if not SilenceModel
				or not SilenceModel.Parent
				or not RushNew
				or not RushNew.Parent then
				return
			end

			local Character = LocalPlayer.Character

			local Hum =
				Character
				and Character:FindFirstChildOfClass("Humanoid")

			local TargetHRP =
				Character
				and Character:FindFirstChild("HumanoidRootPart")

			if not Hum
				or Hum.Health <= 0
				or not TargetHRP then
				return
			end

			local Current = RushNew.Position
			local Target = TargetHRP.Position

			local Offset = Target - Current
			local Distance = Offset.Magnitude

			if Distance <= 10 then
				RushNew.CFrame = TargetHRP.CFrame

				HandleHeardTouch()

				return
			end

			local MoveDistance =
				math.min(18 * Delta, Distance)

			RushNew.CFrame =
				CFrame.lookAt(
					Current + Offset.Unit * MoveDistance,
					Target
				)
		end
	)


	RushNew.Touched:Connect(function(Hit)

		if not HeardChasing
			or HeardTouched then
			return
		end

		local Character = LocalPlayer.Character

		if not Character
			or not Hit
			or not Hit:IsDescendantOf(Character) then
			return
		end

		HandleHeardTouch()
	end)
end

local function StartHeardText(Duration)
	HeardTextToken += 1

	if HeardRenderConnection then
		HeardRenderConnection:Disconnect()
		HeardRenderConnection = nil
	end

	for _, Tween in ipairs(HeardTweens) do
		Tween:Cancel()
	end

	table.clear(HeardTweens)

	HeardText.Visible = true
	HeardText.Position =
		UDim2.fromScale(0.5, 0.42)

	HeardText.Rotation = 0
	HeardText.TextTransparency = 0.8
	HeardText.TextStrokeTransparency = 0.8

	HeardText.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	local Started = os.clock()
	local Token = HeardTextToken

	HeardRenderConnection =
		RunService.RenderStepped:Connect(function()
			if Token ~= HeardTextToken then
				return
			end

			local Progress = math.clamp(
				(os.clock() - Started)
					/ math.max(Duration, 0.01),
				0,
				1
			)

			local Offset =
				Progress ^ 2 * 32 + 2

			local Rotation =
				Progress ^ 2 * 10 + 1

			HeardText.Position =
				UDim2.new(
					0.5,
					0,
					0.42,
					0
				)

			HeardText.Position =
				UDim2.new(
					0.5,
					math.random(
						-math.floor(Offset),
						math.floor(Offset)
					),
					0.42,
					math.random(
						-math.floor(Offset),
						math.floor(Offset)
					)
				)

			HeardText.Rotation =
				math.random(
					-math.floor(Rotation),
					math.floor(Rotation)
				)
		end)
end

local function LaunchHeardText(Red)
	HeardTextToken += 1

	local Token = HeardTextToken

	if HeardRenderConnection then
		HeardRenderConnection:Disconnect()
		HeardRenderConnection = nil
	end

	for _, Tween in ipairs(HeardTweens) do
		Tween:Cancel()
	end

	table.clear(HeardTweens)

	if not HeardText.Visible then
		return
	end

	HeardText.Position =
		UDim2.fromScale(0.5, 0.42)

	HeardText.Rotation = 0

	HeardText.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	local Direction =
		math.random(1, 2) == 1
		and -360
		or 360

	local Move = TweenService:Create(
		HeardText,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Exponential,
			Enum.EasingDirection.Out
		),
		{
			Position =
				UDim2.fromScale(0.5, 0.32)
		}
	)

	table.insert(HeardTweens, Move)
	Move:Play()

	local Color = TweenService:Create(
		HeardText,
		TweenInfo.new(
			2.5,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			Rotation = Direction,

			TextColor3 =
				Red
				and Color3.fromRGB(255, 70, 70)
				or Color3.fromRGB(205, 170, 255)
		}
	)

	table.insert(HeardTweens, Color)
	Color:Play()

	task.spawn(function()
		Move.Completed:Wait()

		if Token ~= HeardTextToken then
			return
		end

		local Exit = TweenService:Create(
			HeardText,
			TweenInfo.new(
				0.5,
				Enum.EasingStyle.Exponential,
				Enum.EasingDirection.In
			),
			{
				Position =
					UDim2.fromScale(0.5, 1.2)
			}
		)

		table.insert(HeardTweens, Exit)
		Exit:Play()

		Exit.Completed:Wait()

		if Token == HeardTextToken
			and HeardText
			and HeardText.Parent then

			HeardText.Visible = false
		end
	end)
end

local function PlayYouWereHeard()
	if YouWereHeardTriggered then
		return
	end

	YouWereHeardTriggered = true
	HeartbeatLocked = true
	CloseMoveStart = nil

	if ActiveMoveTween then
		ActiveMoveTween:Cancel()
		ActiveMoveTween = nil
	end

FollowMoving = false

	task.spawn(function()
		local Sound = CloneHardCoreSound("SilenceChase")
		Sound.Volume = 0.7
		Sound.RollOffMaxDistance = 25000
		Sound.RollOffMinDistance = 5
		Sound.RollOffMode =
			Enum.RollOffMode.Linear
		Sound.EmitterSize = 10000
		Sound.PlaybackSpeed = 0.9
		Sound.Name = "Boso"
		Sound.Looped = false
		
		HeardBoso = Sound
		
		if not YouWereHeardTriggered then
	Sound:Destroy()
	HeardBoso = nil
	return
end

		Sound:Play()

		Sound.Ended:Connect(function()
			Sound:Destroy()
		end)
	end)

	local Old = LocalPlayer.PlayerGui:
		FindFirstChild("SilenceHeardGui")

	if Old then
		Old:Destroy()
	end

	HeardTextGui = Instance.new("ScreenGui")
	HeardTextGui.Name = "SilenceHeardGui"
	HeardTextGui.IgnoreGuiInset = true
	HeardTextGui.ResetOnSpawn = false
	HeardTextGui.DisplayOrder = 1000
	HeardTextGui.Parent = LocalPlayer.PlayerGui

	HeardText = Instance.new("TextLabel")
	HeardText.Name = "HeardText"
	HeardText.AnchorPoint =
		Vector2.new(0.5, 0.5)

	HeardText.Position =
		UDim2.fromScale(0.5, 0.42)

	HeardText.Size =
		UDim2.fromOffset(700, 100)

	HeardText.BackgroundTransparency = 1
	HeardText.Text = "You were heard."

	HeardText.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	HeardText.TextStrokeColor3 =
		Color3.fromRGB(0, 0, 0)

	HeardText.TextStrokeTransparency = 0.8
	HeardText.TextScaled = true
	HeardText.Font = Enum.Font.Oswald
	HeardText.Visible = false
	HeardText.ZIndex = 10
	HeardText.Parent = HeardTextGui

	StartHeardText(3.5)

	task.wait(3.5)

	if not YouWereHeardTriggered then
		return
	end

	LaunchHeardText(false)
	StartHeardTint()

	task.wait(0.5)
end

local function CancelYouWereHeard()
	if not YouWereHeardTriggered then
		return
	end

	YouWereHeardTriggered = false
	HeardChasing = false
	HeardTouched = false
	CloseMoveStart = nil

	ShakeLoop = false

	if HeardChaseConnection then
		HeardChaseConnection:Disconnect()
		HeardChaseConnection = nil
	end

	if ActiveMoveTween then
		ActiveMoveTween:Cancel()
		ActiveMoveTween = nil
	end

	if HeardColorTween then
		HeardColorTween:Cancel()
		HeardColorTween = nil
	end

	if HeardBoso and HeardBoso.Parent then
		local Boso = HeardBoso

		local BosoTween = TweenService:Create(
			Boso,
			TweenInfo.new(
				0.5,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out
			),
			{
				PlaybackSpeed = 0
			}
		)

		BosoTween:Play()

		BosoTween.Completed:Connect(function()
			if Boso and Boso.Parent then
				Boso:Destroy()
			end

			if HeardBoso == Boso then
				HeardBoso = nil
			end
		end)
	else
		local Boso = workspace:FindFirstChild("Boso")

		if Boso and Boso:IsA("Sound") then
			local BosoTween = TweenService:Create(
				Boso,
				TweenInfo.new(
					0.5,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out
				),
				{
					PlaybackSpeed = 0
				}
			)

			BosoTween:Play()

			BosoTween.Completed:Connect(function()
				if Boso and Boso.Parent then
					Boso:Destroy()
				end
			end)
		end
	end

	HeardBoso = nil

	HeardTextToken += 1

	if HeardRenderConnection then
		HeardRenderConnection:Disconnect()
		HeardRenderConnection = nil
	end

	for _, Tween in ipairs(HeardTweens) do
		Tween:Cancel()
	end

	table.clear(HeardTweens)

	if HeardTextGui then
		HeardTextGui:Destroy()
		HeardTextGui = nil
		HeardText = nil
	end

	HeartbeatLocked = false
	HeartbeatHideToken += 1

	FollowMoving = true

	if MainColorCorrection then
		TweenService:Create(
			MainColorCorrection,
			TweenInfo.new(
				0.5,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out
			),
			{
				Brightness = 0,
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.new(1, 1, 1)
			}
		):Play()
	end
end

task.spawn(function()
	while not SilenceShutdown
	and SilenceModel
	and SilenceModel.Parent do

		if YouWereHeardTriggered
			and HRP
			and HRP.Parent
			and EntityRoom
			and EntityRoom.Parent then

			local Inside =
				IsInsideRoom(
					EntityRoom,
					HRP.Position
				)

			if not Inside then
				CancelYouWereHeard()
			end
		end

		RunService.Heartbeat:Wait()
	end
end)


local LastReverbRoom = EntityRoom

local function GetRoomFromPosition(Position)
	for _, room in ipairs(CurrentRooms:GetChildren()) do
		if room:IsA("Model") and IsInsideRoom(room, Position) then
			return room
		end
	end

	return nil
end

local function UpdateEntityRoom()
	if not RushNew or not RushNew.Parent then
		return
	end

	local PlayerRoom = GetPlayerRoom()

	if not PlayerRoom then
		return
	end

	local EntityPositionRoom =
		GetRoomFromPosition(RushNew.Position)

	if EntityPositionRoom == PlayerRoom
		and EntityRoom ~= PlayerRoom then

		EntityRoom = PlayerRoom
		LastReverbRoom = PlayerRoom
	end
end

task.spawn(function()
	while SilenceModel
		and SilenceModel.Parent do

		UpdateEntityRoom()

		local Character = LocalPlayer.Character
		local HumanoidRootPart =
			Character and Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart
			and EntityRoom
			and EntityRoom.Parent then

			local Inside = IsInsideRoom(
				EntityRoom,
				HumanoidRootPart.Position
			)


if not HeartbeatLocked then
	if HeartbeatAllowed
		and HeartbeatGuiStarted then

		if Inside then
			if not HeartbeatScaleLoop then
				local Tween = TweenHeartbeatPosition(
					HeartbeatOriginalPosition
				)

				if Tween then
					Tween.Completed:Wait()
				end

				if HeartbeatAllowed
					and HeartbeatGuiStarted then

					StartHeartbeatLoop()
				end
			end
		else
			if HeartbeatScaleLoop then
				StopHeartbeatLoop()

				TweenHeartbeatPosition(
					HeartbeatStartPosition
				)
			end
		end
	end
end

		else
	if ReverbInside then
		ReverbInside = false
	end

	if HeartbeatGuiStarted and not HeartbeatLocked then
		HideHeartbeatGui()
	end
end

		RunService.Heartbeat:Wait()
	end
end)

task.spawn(function()
	local LastNearInside = false

	while SilenceModel
		and SilenceModel.Parent do

		local Character = LocalPlayer.Character
		local HumanoidRootPart =
			Character and Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart
			and EntityRoom
			and EntityRoom.Parent
			and Near
			and Near.Parent then

			local Inside = IsInsideRoom(
				EntityRoom,
				HumanoidRootPart.Position
			)

			if Inside ~= LastNearInside then
				LastNearInside = Inside

				if Inside then
					FadeNear(1)
				else
					FadeNear(0)
				end
			end
		end

		RunService.Heartbeat:Wait()
	end
end)

task.spawn(function()
	while SilenceModel
		and SilenceModel.Parent do

		local Character = LocalPlayer.Character
		local HumanoidRootPart =
			Character and Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart
			and EntityRoom
			and EntityRoom.Parent then

			local Inside = IsInsideRoom(
				EntityRoom,
				HumanoidRootPart.Position
			)

			if Inside ~= LastInside then
				LastInside = Inside

				if Inside then
					ShakeLoop = true
				else
					ShakeLoop = false
				end
			end
		else
			LastInside = false
			ShakeLoop = false
		end

		RunService.Heartbeat:Wait()
	end
end)

if not EntityRoom then
	return
end


local function GetFloor(room)
	if not room or not room.Parent then
		return nil
	end

	local Parts = room:FindFirstChild("Parts")
	local Floor = Parts and Parts:FindFirstChild("Floor")

	if Floor and Floor:IsA("BasePart") then
		return Floor
	end

	return nil
end

local Floor = GetFloor(EntityRoom)

if not Floor then
	return
end


local BBoxCF, BBoxSize = SilenceModel:GetBoundingBox()
local ModelPivot = SilenceModel:GetPivot()
local BBoxOffset = ModelPivot:ToObjectSpace(BBoxCF)


local function TeleportToFloor(room, Height)
	if not room or not room.Parent then
		return false
	end

	local FloorPart = GetFloor(room)

	if not FloorPart then
		return false
	end

	local FloorTop = FloorPart.Size.Y / 2

	local CurrentPivot = SilenceModel:GetPivot()
	local X, Y, Z = CurrentPivot:ToOrientation()

	local TargetBBoxCF =
		FloorPart.CFrame
		* CFrame.new(
			0,
			FloorTop + Height + BBoxSize.Y / 2,
			0
		)
		* CFrame.Angles(X, Y, Z)

	SilenceModel:PivotTo(
		TargetBBoxCF * BBoxOffset:Inverse()
	)

	return true
end

do
	local PointLight = Instance.new("PointLight")
	PointLight.Name = "SilenceSpawnLight"
	PointLight.Color = Color3.new(1, 1, 1)
	PointLight.Brightness = 3
	PointLight.Range = 15
	PointLight.Parent = RushNew

	TweenService:Create(
		PointLight,
		TweenInfo.new(
			1,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			Range = 0
		}
	):Play()
end


local Face1

do
	local Attachment2 = RushNew:FindFirstChild("Attachment2", true)

	if Attachment2 then
		Face1 = Attachment2:FindFirstChild("Face1", true)

		if Face1 then
			Face1.Enabled = false
		end
	end
end


do
	local FloorCF = Floor.CFrame
	local FloorTop = Floor.Size.Y / 2

	local StartCFrame = RushNew.CFrame
	local X, Y, Z = StartCFrame:ToOrientation()

local FirstCFrame =
		FloorCF
		* CFrame.new(
			0,
			FloorTop + 10,
			0
		)
		* CFrame.Angles(X, Y, Z)
		
		RushNew.CFrame = FirstCFrame

	local TargetCFrame =
		FloorCF
		* CFrame.new(
			0,
			FloorTop + 5,
			0
		)
		* CFrame.Angles(X, Y, Z)
		
		

	TweenService:Create(
		RushNew,
		TweenInfo.new(
			2,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			CFrame = TargetCFrame
		}
	):Play()
end


PlayInitialGrain()





local InRoom = false
local GrainLooping = false
local GrainTweenID = 0

local function TweenGrain(Value)
	GrainTweenID += 1

	local MyID = GrainTweenID
	local Tweens = {}

	for _, Image in pairs(GrainImages) do
		if Image and Image.Parent then
			local Tween = TweenService:Create(
				Image,
				TweenInfo.new(
					0.7,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out
				),
				{
					ImageTransparency = Value
				}
			)

			table.insert(Tweens, Tween)
			Tween:Play()
		end
	end

	if #Tweens > 0 then
		Tweens[1].Completed:Wait()
	end

	if MyID ~= GrainTweenID then
		return
	end

	if Value == 1 and not InRoom then
		GrainLooping = false

		for _, Image in pairs(GrainImages) do
			if Image and Image.Parent then
				Image.Visible = false
				Image.ImageTransparency = 1
			end
		end
	end
end

local function StartGrainLoop()
	if GrainLooping then
		return
	end

	GrainLooping = true

	task.spawn(function()
		while GrainLooping
			and InRoom
			and Gui
			and Gui.Parent
			and SilenceModel
			and SilenceModel.Parent do

			for number = 0, HighestNumber do
				if not GrainLooping or not InRoom then
					break
				end

				local Image = GrainImages[number]

				if Image and Image.Parent then
					Image.Visible = true
					Image.ImageTransparency = 0.9

					task.wait(0.01)

					if Image and Image.Parent then
						Image.Visible = false
					end
				end
			end

			task.wait()
		end
	end)
end


local function FlashLights(room)
	if not room or not room.Parent then
		return
	end

	for _, obj in ipairs(room:GetDescendants()) do
		if obj:IsA("Light") then
			local OriginalBrightness = obj.Brightness

			obj.Brightness = 4

			TweenService:Create(
				obj,
				TweenInfo.new(
					1.5,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				),
				{
					Brightness = OriginalBrightness
				}
			):Play()
		end
	end
end

local CameraShaker = require(game.ReplicatedStorage:WaitForChild("CameraShaker"))
spawnShake = CameraShaker.new(
	Enum.RenderPriority.Camera.Value,
	function() end
)

RunService:BindToRenderStep(
	SilenceShakeRenderName,
	Enum.RenderPriority.Camera.Value + 30,
	function(deltaTime)
		if SilenceShutdown or CameraShakeStopped or not SilenceModel or not SilenceModel.Parent then
			StopCameraShake()
			return
		end

		local succeeded, shakeCf = pcall(spawnShake.Update, spawnShake, deltaTime)
		if not succeeded then
			StopCameraShake()
			return
		end

		if typeof(shakeCf) == "CFrame" then
			local CurrentCamera = workspace.CurrentCamera
			if CurrentCamera then
				CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCf
			end
		end
	end
)
SilenceShakeBound = true

task.spawn(function()
	while not SilenceShutdown and not CameraShakeStopped and SilenceModel and SilenceModel.Parent do
		if ShakeLoop then
			spawnShake:ShakeOnce(
				40,
				math.random(3, 8) / 10,
				10,
				5,
				0,
				0.8
			)

			task.wait(10)
		else
			task.wait(0.1)
		end
	end

	StopCameraShake()
end)


local EffectRoom

local function ApplyRoomEffect(room)
	if not room or not room.Parent then
		return
	end

	EffectRoom = room
	InRoom = true

	local Goal = {
		Brightness = -0.02,
		Contrast = 0.08,
		Saturation = -0.65,
		TintColor = Color3.fromRGB(
			205,
			205,
			205
		)
	}

	TweenService:Create(
		MainColorCorrection,
		TweenInfo.new(
			0.7,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		Goal
	):Play()

	task.spawn(function()
		TweenGrain(0.9)
	end)

	StartGrainLoop()
end


local function ClearRoomEffect()
	if not InRoom then
		return
	end

	InRoom = false

	TweenService:Create(
		MainColorCorrection,
		TweenInfo.new(
			0.7,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.new(1, 1, 1)
		}
	):Play()

	task.spawn(function()
		TweenGrain(1)
	end)
end


local EffectCycle = 0

local function PlayArrivalEffect(room)
	if not room or not room.Parent then
		return
	end
	
	HideHeartbeatGui()
	
	local PointLight = Instance.new("PointLight")
	PointLight.Name = "SilenceSpawnLight"
	PointLight.Color = Color3.new(1, 1, 1)
	PointLight.Brightness = 3
	PointLight.Range = 15
	PointLight.Parent = RushNew

local wee = TweenService:Create(
		PointLight,
		TweenInfo.new(
			2,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			Range = 0
		}
	)
	
	wee:Play() 
	
	task.spawn(function() 
	wee.Completed:Wait() 
	PointLight:Destroy() 
	end) 

	EffectCycle += 1

	local MyCycle = EffectCycle

	InRoom = false
	GrainLooping = false

	if Face1 and Face1.Parent then
		Face1.Enabled = false
	end
	
	if blayes then
	blayes:Play() 
	end

	if blano and blano.Parent then
		blano:Stop()
		blano.TimePosition = 0
		blano:Play()
	end

	FlashLights(room)

	task.spawn(function()
	while MyCycle == EffectCycle
		and blano
		and blano.Parent
		and SilenceModel
		and SilenceModel.Parent do

		if blano.TimePosition >= 1.6 then
			break
		end

		task.wait(0.03)
	end

	if MyCycle ~= EffectCycle then
		return
	end

	if not blano or not blano.Parent then
		return
	end
	
	HeartbeatAllowed = true

RestartNear()

HeartbeatAllowed = true

task.spawn(function() 
task.wait(0.3)
ShowHeartbeatGui()
end)

if Face1 and Face1.Parent then
	Face1.Enabled = true
end

ApplyRoomEffect(room)
end)
end


task.spawn(function()
	task.wait(1.6)

	if blano
		and blano.Parent
		and SilenceModel
		and SilenceModel.Parent then

		HeartbeatAllowed = true
		
		task.spawn(function() 
		task.wait(0.3)
		ShowHeartbeatGui()
		end)

		if Face1 and Face1.Parent then
			Face1.Enabled = true
		end

		ApplyRoomEffect(EntityRoom)
	end
end)


local function GetRoomExit(room)
	if not room or not room.Parent then
		return nil
	end

	local RoomExit = room:FindFirstChild("RoomExit", true)

	if RoomExit and RoomExit:IsA("BasePart") then
		return RoomExit
	end

	return nil
end


local function TweenToPlayer()
	if YouWereHeardTriggered then
		return nil
	end

	local Character = LocalPlayer.Character

	if not Character then
		return nil
	end

	local HumanoidRootPart =
		Character:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return nil
	end

	if ActiveMoveTween then
		ActiveMoveTween:Cancel()
		ActiveMoveTween = nil
	end

	local Tween = TweenService:Create(
		RushNew,
		TweenInfo.new(
			7,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		),
		{
			CFrame = HumanoidRootPart.CFrame
		}
	)

	ActiveMoveTween = Tween

	Tween.Completed:Connect(function()
		if ActiveMoveTween == Tween then
			ActiveMoveTween = nil
		end
	end)

	Tween:Play()

	return Tween
end


task.spawn(function()
	local LastPosition
	local LastSampleTime = os.clock()

	while not SilenceShutdown
		and SilenceModel
		and SilenceModel.Parent
		and RushNew
		and RushNew.Parent do

		if YouWereHeardTriggered then
			break
		end

		local TargetCharacter = LocalPlayer.Character
		local TargetHumanoid = TargetCharacter and TargetCharacter:FindFirstChildOfClass("Humanoid")
		local TargetRoot = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
		local Now = os.clock()

		if TargetHumanoid
			and TargetHumanoid.Health > 0
			and TargetRoot
			and TargetRoot.Parent then

			local Distance = (TargetRoot.Position - RushNew.Position).Magnitude
			local SameRoom = EntityRoom
				and EntityRoom.Parent
				and IsInsideRoom(EntityRoom, TargetRoot.Position)

			local Delta = math.max(Now - LastSampleTime, 0.001)
			local MovedDistance = LastPosition
				and (TargetRoot.Position - LastPosition).Magnitude
				or 0

			local IsActuallyMoving =
				TargetHumanoid.MoveDirection.Magnitude > 0.05
				and MovedDistance >= math.max(0.015, Delta * 0.5)

			if Distance <= 12 and SameRoom and IsActuallyMoving then
				if not CloseMoveStart then
					CloseMoveStart = Now
				end

				if Now - CloseMoveStart >= 1 then
					PlayYouWereHeard()
					break
				end
			else
				CloseMoveStart = nil
			end

			LastPosition = TargetRoot.Position
			LastSampleTime = Now
		else
			CloseMoveStart = nil
			LastPosition = nil
			LastSampleTime = Now
		end

		task.wait(0.05)
	end
end)


local function MoveToNewRoom()
	if MovingRoom then
		return false
	end

	MovingRoom = true

	local OldRoom = EntityRoom
	
PathCopyToken += 1
table.clear(PlayerPath)

PathMovementActive = false
PathMovementRunning = false
FollowMoving = false

if ActiveMoveTween then
	ActiveMoveTween:Cancel()
	ActiveMoveTween = nil
end

	if not OldRoom or not OldRoom.Parent then
		OldRoom = GetPlayerRoom()

		if not OldRoom then
			MovingRoom = false
			return false
		end

		EntityRoom = OldRoom
	end

	ClearRoomEffect()

	task.wait(math.random(2, 5))

	local RoomExit = GetRoomExit(OldRoom)

	if RoomExit and RoomExit.Parent then
		local ExitTween = TweenService:Create(
			RushNew,
			TweenInfo.new(
				math.random(1, 4),
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			),
			{
				CFrame = RoomExit.CFrame
			}
		)

		ExitTween:Play()
		ExitTween.Completed:Wait()
	end

	task.wait(math.random(2, 4))

	local NewRoom = GetPlayerRoom()

	if not NewRoom then
		MovingRoom = false
		return false
	end

EntityRoom = NewRoom
LastReverbRoom = NewRoom

PathCopyToken += 1
table.clear(PlayerPath)

PathMovementActive = false
PathMovementRunning = false
FollowMoving = true



local Character = LocalPlayer.Character
local HumanoidRootPart =
	Character and Character:FindFirstChild("HumanoidRootPart")

	TeleportToFloor(NewRoom, 4)

	local Character = LocalPlayer.Character
	local HumanoidRootPart =
		Character and Character:FindFirstChild("HumanoidRootPart")

	if HumanoidRootPart
		and IsInsideRoom(NewRoom, HumanoidRootPart.Position) then

		ShakeLoop = true
	else
		ShakeLoop = false
	end

	PlayArrivalEffect(NewRoom)

	MovingRoom = false

	return true
end

task.spawn(function()
	while SilenceModel
		and SilenceModel.Parent do

		local Character = LocalPlayer.Character
		local HumanoidRootPart =
			Character and Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart
			and EntityRoom
			and EntityRoom.Parent then

			local Inside = IsInsideRoom(
				EntityRoom,
				HumanoidRootPart.Position
			)

			if Inside then
				ShakeLoop = true
			else
				ShakeLoop = false

				if not MovingRoom then
					task.spawn(function()
						MoveToNewRoom()
					end)
				end
			end
		else
			ShakeLoop = false
		end

		RunService.Heartbeat:Wait()
	end
end)

local LookStartTime = nil
local LookTriggered = false

task.spawn(function()
	while SilenceModel
		and SilenceModel.Parent
		and RushNew
		and RushNew.Parent do
		

		RunService.Heartbeat:Wait()
		

		if MovingRoom
	or YouWereHeardTriggered
	or PathMovementActive then

	LookStartTime = nil
	LookTriggered = false
	continue
end

		local Character = LocalPlayer.Character
		local HumanoidRootPart =
			Character and Character:FindFirstChild("HumanoidRootPart")

		local Hum =
			Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Hum then
			LookStartTime = nil
			LookTriggered = false
			continue
		end

		if not EntityRoom
			or not EntityRoom.Parent then

			EntityRoom = GetPlayerRoom()

			if not EntityRoom then
				LookStartTime = nil
				LookTriggered = false
				continue
			end
		end

		if not IsInsideRoom(
			EntityRoom,
			HumanoidRootPart.Position
		) then

			LookStartTime = nil
			LookTriggered = false
			continue
		end

		if ActiveMoveTween
			and ActiveMoveTween.PlaybackState == Enum.PlaybackState.Playing then

			local IsCrouching =
				Character:GetAttribute("Crouching") == true

			local IsMoving =
				Hum.MoveDirection.Magnitude > 0

			if IsMoving and not IsCrouching then
				ActiveMoveTween:Cancel()
				ActiveMoveTween = nil

				LookStartTime = nil
				LookTriggered = false

				continue
			end
		end

		local ToEntity =
			RushNew.Position - HumanoidRootPart.Position

		if ToEntity.Magnitude <= 0.01 then
			LookStartTime = nil
			LookTriggered = false
			continue
		end

		local Direction =
			ToEntity.Unit

		local Dot =
			HumanoidRootPart.CFrame.LookVector:Dot(Direction)

		if Dot >= 0.8 then
			if not LookStartTime then
				LookStartTime = tick()
			end

			if not LookTriggered
				and tick() - LookStartTime >= 2 then

				LookTriggered = true

				if ActiveMoveTween then
					ActiveMoveTween:Cancel()
					ActiveMoveTween = nil
				end
				
				if PathMovementRunning then
	CancelPathMovement()
end

				local MoveTween =
					TweenService:Create(
						RushNew,
						TweenInfo.new(
							7,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.InOut
						),
						{
							CFrame =
								HumanoidRootPart.CFrame
						}
					)

				ActiveMoveTween = MoveTween

				MoveTween:Play()

				MoveTween.Completed:Connect(function()
					if ActiveMoveTween == MoveTween then
						ActiveMoveTween = nil
					end
				end)
			end
		else
			LookStartTime = nil
			LookTriggered = false
		end
	end
end)


local function ShutdownSilence()
	if SilenceShutdown then
		return
	end

	SilenceShutdown = true
	StopCameraShake()
	DisableSilenceReverb()

	YouWereHeardTriggered = false
	HeardChasing = false
	HeardTouched = false
	FollowMoving = false
	Ambi:Destroy() 

	MovingRoom = true
	ShakeLoop = false

	HeartbeatLocked = true
	HeartbeatAllowed = false
	HeartbeatGuiStarted = false
	HeartbeatScaleLoop = false
	HeartbeatDistanceLoop = false

	InRoom = false
	GrainLooping = false

	HeartbeatHideToken += 1
	HeardTextToken += 1
	GrainTweenID += 1
	EffectCycle += 1

	if ActiveMoveTween then
		ActiveMoveTween:Cancel()
		ActiveMoveTween = nil
	end

	if HeartbeatPositionTween then
		HeartbeatPositionTween:Cancel()
		HeartbeatPositionTween = nil
	end

	if HeartbeatScaleTween then
		HeartbeatScaleTween:Cancel()
		HeartbeatScaleTween = nil
	end

	if NearFadeTween then
		NearFadeTween:Cancel()
		NearFadeTween = nil
	end

	if HeardColorTween then
		HeardColorTween:Cancel()
		HeardColorTween = nil
	end

	if FollowConnection then
		FollowConnection:Disconnect()
		FollowConnection = nil
	end

	if HeardChaseConnection then
		HeardChaseConnection:Disconnect()
		HeardChaseConnection = nil
	end

	if HeardRenderConnection then
		HeardRenderConnection:Disconnect()
		HeardRenderConnection = nil
	end

	if LatestRoomConnection then
		LatestRoomConnection:Disconnect()
		LatestRoomConnection = nil
	end

	if ReverbAddedConnection then
		ReverbAddedConnection:Disconnect()
		ReverbAddedConnection = nil
	end

	if HideHeartbeatGui then
		pcall(HideHeartbeatGui)
	end

	if Gui and Gui.Parent then
		Gui:Destroy()
	end

	if HeartbeatGui and HeartbeatGui.Parent then
		HeartbeatGui:Destroy()
	end

	if HeardTextGui and HeardTextGui.Parent then
		HeardTextGui:Destroy()
	end

	HeardTextGui = nil
	HeardText = nil

	for _, Obj in ipairs({
		SCREAM,
		Teleport,
		HeardBoso
	}) do
		if Obj and Obj.Parent then
			pcall(function()
				Obj:Stop()
				Obj:Destroy()
			end)
		end
	end

	SCREAM = nil
	Teleport = nil
	HeardBoso = nil

	if Near and Near.Parent then
		Near:Stop()
	end

	CleanupSilenceAudio(true)

	if MainColorCorrection
		and MainColorCorrection.Parent then

		MainColorCorrection.Brightness = 0
		MainColorCorrection.Contrast = 0
		MainColorCorrection.Saturation = 0
		MainColorCorrection.TintColor =
			Color3.new(1, 1, 1)
	end

	task.wait(3)

	if SilenceModel
		and SilenceModel.Parent then

		SilenceModel:Destroy()
	end
end

if Hum then
	Hum.Died:Connect(function()
		if not SilenceShutdown then
			task.spawn(ShutdownSilence)
		end
	end)
end

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
	local NewHumanoid = NewCharacter:WaitForChild("Humanoid")
	NewHumanoid.Died:Connect(function()
		if not SilenceShutdown then
			task.spawn(ShutdownSilence)
		end
	end)
end)

LatestRoomConnection =
	LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()

		if SilenceShutdown then
			return
		end

		LatestRoomCount += 1

		if LatestRoomCount >= 5 then
			task.spawn(ShutdownSilence)
			DisableSilenceReverb()
		end
	end)
end
function entityBehaviors.Singularity()
local testmode = true

local HardCoreSoundFolder = workspace:WaitForChild("HardCoreSound")
local BlaSoundTemplate = HardCoreSoundFolder:WaitForChild("BlaSound")
assert(BlaSoundTemplate:IsA("Sound"), "HardCoreSound.BlaSound must be a Sound")

local blaSound

local function PlayBlaSound()
	if blaSound and blaSound.Parent then
		blaSound:Destroy()
	end

	blaSound = BlaSoundTemplate:Clone()
	blaSound.Name = "SingularityBlaSound"
	blaSound.PlaybackSpeed = 1
	blaSound.Looped = false
	blaSound.TimePosition = 0
	blaSound.Volume = 2
	blaSound.RollOffMaxDistance = 1000000000
	blaSound.Parent = workspace

	local activeSound = blaSound
	activeSound.Ended:Connect(function()
		if activeSound and activeSound.Parent then
			activeSound:Destroy()
		end
		if blaSound == activeSound then
			blaSound = nil
		end
	end)

	activeSound:Play()
end

local victimScream
local lastPullFinished = Instance.new("BindableEvent")

local RunService = game:GetService("RunService")

local function GetRoom()
	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then return nil end

	local gameData = game.ReplicatedStorage:FindFirstChild("GameData")
	local latestRoom = gameData and gameData:FindFirstChild("LatestRoom")

	if latestRoom then
		return currentRooms:FindFirstChild(tostring(latestRoom.Value))
	end
	return nil
end

local TweenService = game:GetService("TweenService")

-- Tải Asset an toàn
local success, assets = pcall(function()
	return game:GetObjects("rbxassetid://134261174233456")
end)

if not success or not assets or #assets == 0 then
	return
end

local CameraShaker = require(game.ReplicatedStorage:WaitForChild("CameraShaker"))
local camera = workspace.CurrentCamera

local spawnShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end)

spawnShake:Start()

local s = assets[1]
s.Name = "Singularity"
s.Parent = workspace

for _, v in ipairs(s:GetDescendants()) do
	if v:IsA("ParticleEmitter") and v.Name == "Face11" then
		v.Texture = "rbxassetid://109425641377249"
		v.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	end
end

local spawnSounds = {}
local spawnParticles = {}

for _, v in ipairs(s:GetDescendants()) do
	if v:IsA("Sound") then
		spawnSounds[v] = v.PlaybackSpeed
		v.PlaybackSpeed = 0

	elseif v:IsA("ParticleEmitter") then
		local originalColor = v.Color
		spawnParticles[v] = originalColor

		local keypoints = {}

		for _, kp in ipairs(originalColor.Keypoints) do
			local h, sat, val = kp.Value:ToHSV()

			table.insert(keypoints, ColorSequenceKeypoint.new(
				kp.Time,
				Color3.fromHSV(h, sat, val / 3)
			))
		end

		v.Color = ColorSequence.new(keypoints)
	end
end

for _, v in ipairs(s:GetDescendants()) do
	if v:IsA("Beam") then
		v.Brightness = 1
		v.LightEmission = 0
		v.LightInfluence = 1
		v.Color = ColorSequence.new(Color3.fromRGB(255, 143, 143))
	end
end

local entity = s:FindFirstChild("Singu") or s
if not entity then
	return
end

local light
local lightPart

local room = GetRoom()
if not room then
	return
end

local selectedWardrobe

local function FindFirstRoomWardrobe()
	for _, obj in ipairs(room:GetDescendants()) do
		if obj:IsA("Model") and obj.Name == "Wardrobe" then
			return obj
		end
	end
	return nil
end

selectedWardrobe = FindFirstRoomWardrobe()

if not selectedWardrobe then
	local conn
	local startTime = tick()

	conn = room.DescendantAdded:Connect(function(obj)
		if not selectedWardrobe and obj:IsA("Model") and obj.Name == "Wardrobe" then
			selectedWardrobe = obj
			if conn then
				conn:Disconnect()
			end
		end
	end)

	repeat
		task.wait()
	until selectedWardrobe or (tick() - startTime > 3)

	if conn then
		conn:Disconnect()
	end
end

if not selectedWardrobe then
	s:Destroy()
	return
end

local cf = selectedWardrobe:GetBoundingBox()
local look = selectedWardrobe:GetPivot().LookVector

local spawnCFrame = CFrame.lookAt(
	cf.Position - look * 1.4,
	cf.Position + look
)

if entity:IsA("Model") then
	entity:PivotTo(spawnCFrame)
else
	entity.CFrame = spawnCFrame
end

local activated = false

local function StartEntity()
	if activated then return end
	activated = true

light = Instance.new("PointLight")
light.Color = Color3.fromRGB(255,148,148)
light.Range = 100
light.Enabled = false
light.Brightness = 4

local lightPart = entity

if entity:IsA("Model") then
	lightPart =
		entity.PrimaryPart
		or entity:FindFirstChildWhichIsA("BasePart", true)
end

if lightPart then
	light.Parent = lightPart
end

local spawnTweenInfo = TweenInfo.new(
	1,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

for sound, originalSpeed in pairs(spawnSounds) do
	if sound.Parent then
		TweenService:Create(
			sound,
			spawnTweenInfo,
			{PlaybackSpeed = originalSpeed}
		):Play()
	end
end

task.spawn(function()
	local startTime = tick()

	while true do
		local alpha = math.clamp(
			(tick() - startTime) / 1.5,
			0,
			1
		)

		local eased = TweenService:GetValue(
			alpha,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		)

		for emitter, originalColor in pairs(spawnParticles) do
			if emitter.Parent then
				local keypoints = {}

				for i, kp in ipairs(originalColor.Keypoints) do
					local c = kp.Value

					local h, sat, val = c:ToHSV()

local darkColor = Color3.fromHSV(
	h,
	sat,
	val / 3
)

					table.insert(
						keypoints,
						ColorSequenceKeypoint.new(
							kp.Time,
							darkColor:Lerp(c, eased)
						)
					)
				end

				emitter.Color = ColorSequence.new(keypoints)
			end
		end

		if alpha >= 1 then
			break
		end

		RunService.Heartbeat:Wait()
	end

	for emitter, originalColor in pairs(spawnParticles) do
		if emitter.Parent then
			emitter.Color = originalColor
		end
	end
end)

	local function playSound(soundName)
		local sound = s:FindFirstChild(soundName, true)
		if sound and sound:IsA("Sound") then
		if sound.Name == "Chained" then
		local clone = sound:Clone() 
		clone.Parent = sound.Parent
			clone:Play()
			else
			sound:Play() 
		end
		end
	end

	playSound("Scare")
	playSound("caught")
	playSound("ScreamingInPublicBathroomsPrank")

	local time = entity:FindFirstChild("caught", true)
	if time then time.TimePosition = 0 end
	local time2 = entity:FindFirstChild("Scare", true)
	if time2 then time2.TimePosition = 0 end
	local time3 = entity:FindFirstChild("ScreamingInPublicBathroomsPrank", true)
	if time3 then time3.TimePosition = 0 end

	local player = game.Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid", 5)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)

	local function HasHidingState(instance)
		if not instance then
			return false
		end
		if instance:GetAttribute("Hiding") == true then
			return true
		end
		local value = instance:FindFirstChild("Hiding", true)
		return value ~= nil and value:IsA("BoolValue") and value.Value == true
	end

	local function IsPlayerHiding()
		return HasHidingState(player)
			or HasHidingState(char)
			or HasHidingState(hum)
			or HasHidingState(hrp)
	end

	local function IsPlayerBehindObstacle()
		if not hrp or not hrp.Parent then
			return true
		end

		local entityPosition = entity:IsA("Model") and entity:GetPivot().Position or entity.Position
		local direction = hrp.Position - entityPosition
		if direction.Magnitude <= 0.01 then
			return false
		end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {s, char, selectedWardrobe}
		params.IgnoreWater = true
		return workspace:Raycast(entityPosition, direction, params) ~= nil
	end

	local function CanPullPlayer()
		return hum ~= nil
			and hum.Health > 0
			and hrp ~= nil
			and hrp.Parent ~= nil
			and not IsPlayerHiding()
			and not IsPlayerBehindObstacle()
	end

	local PlayerGui = player:WaitForChild("PlayerGui")

	local Gui = Instance.new("ScreenGui")
	Gui.Name = "FlashingText"
	Gui.ResetOnSpawn = false
	Gui.IgnoreGuiInset = true
	Gui.Enabled = false
	Gui.Parent = PlayerGui

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.fromOffset(900, 70)
	Text.Position = UDim2.fromScale(0.5, 0.5)
	Text.AnchorPoint = Vector2.new(0.5, 0.5)
	Text.BackgroundTransparency = 1
	Text.Text = "insert flashing text here"
	Text.TextColor3 = Color3.new(1, 1, 1)
	Text.TextSize = 55
	Text.ZIndex = 2
	Text.FontFace = Font.new(
		"rbxasset://fonts/families/Roboto.json",
		Enum.FontWeight.Regular,
		Enum.FontStyle.Normal
	)
	Text.Parent = Gui

	local Image = Instance.new("ImageLabel")
	Image.Size = UDim2.fromScale(1, 1)
	Image.Position = UDim2.fromScale(0.5, 0.5)
	Image.AnchorPoint = Vector2.new(0.5, 0.5)
	Image.BackgroundTransparency = 1
	Image.Image = "rbxassetid://73640291479731"
	Image.ImageTransparency = 1
	Image.ZIndex = 1
	Image.Parent = Gui
	Image.ScaleType = Enum.ScaleType.Stretch
	
	local swallowed = false

	task.spawn(function()
		local flashing = false

		while Gui.Parent and not swallowed do
			local entityPos = entity:IsA("Model") and entity:GetPivot().Position or entity.Position
			local dist = (hrp.Position - entityPos).Magnitude

			if dist <= 13 then
				if not flashing then
					flashing = true

					task.spawn(function()
						while flashing and Gui.Parent and not swallowed do
							Gui.Enabled = true
							Text.TextTransparency = 1
							task.wait(0.05)

							Text.TextTransparency = 0
							task.wait(0.05)
						end

						Gui.Enabled = false
						Text.TextTransparency = 1
					end)
				end
			else
				flashing = false
			end

			task.wait(0.1)
		end
	end)

	task.spawn(function()
		while s.Parent and entity.Parent and hrp.Parent do
			local entityPos = entity:IsA("Model") and entity:GetPivot().Position or entity.Position
			local dist = (hrp.Position - entityPos).Magnitude

			if dist <= 20 and not swallowed then
				local alpha = math.clamp(1 - dist / 20, 0, 1)
				Image.ImageTransparency = 1 - alpha
			else
				Image.ImageTransparency = 1
			end

			task.wait()
		end
	end)

	task.spawn(function()
		while s.Parent and entity.Parent and hrp.Parent do
			local entityPos = entity:IsA("Model") and entity:GetPivot().Position or entity.Position
			local dist = (hrp.Position - entityPos).Magnitude

			if dist <= 30 then
				local alpha = 1 - (dist / 30)

				spawnShake:ShakeOnce(
					1 + alpha * 1.65,
					5,
					0.01,
					0.1,
					0,
					0.25
				)
			end

			task.wait(0.1)
		end
	end)

task.wait(1.4) 


for _, v in ipairs(s:GetDescendants()) do
	if v:IsA("Sound") then
		v:Stop()
	end
end

	if hum and hrp then
		local entityPos = entity:IsA("Model") and entity:GetPivot().Position or entity.Position
		local targetCFrame = entity:IsA("Model") and entity:GetPivot() or entity.CFrame

		local targets = {}
local processedModels = {}

local playerDistance = (hrp.Position - entityPos).Magnitude
local playerTargetInstance = hrp

table.insert(targets, {
	instance = hrp,
	distance = playerDistance,
	isPlayer = true
})

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude
overlapParams.FilterDescendantsInstances = {
	s,
	char,
	selectedWardrobe
}

local nearbyParts = workspace:GetPartBoundsInRadius(entityPos, 200, overlapParams)

local blacklist = {
	Drawer = true,
	Dresser = true,
	Rafter = true,
	LightStand = true,
	Chandelier = true,
	KeyObtain = true,
	Wardrobe = true,
	Crucifix = true, 
	Lighter = true, 
	Lockpick = true, 
	Flashlight = true, 
	Skeleton_Key = true, 
	BlockedDoorModel = true, 
	Door = true,
	DoorNormal = true,
	Table = true,
	Table_Cloth = true, 
	End_DoorFrame = true, 
	Start_DoorFrame = true, 
	DropCeiling = true, 
	Bed = true, 
	Double_Bed = true, 
	Curtain = true, 
	Sideroom29 = true, 
	Sideroom28 = true, 
	Sideroom30 = true, 
	Sideroom27 = true, 
	Sideroom31 = true, 
	Window = true, 
	Window_Tall = true, 
	Rug = true
}

for _, part in ipairs(nearbyParts) do
	local assets = room:FindFirstChild("Assets")
if not assets or not part:IsDescendantOf(assets) then
	continue
end

	local model = part:FindFirstAncestorOfClass("Model")
	local blocked = false
local cur = model

while cur and cur ~= room do
	if blacklist[cur.Name] then
		blocked = true
		break
	end
	cur = cur.Parent
end

if blocked then
	continue
end

	if not model or model == s or model == char
		or model == selectedWardrobe
		or processedModels[model] then
		continue
	end

	if not model:IsDescendantOf(room) then
		continue
	end

	if blacklist[model.Name] then
	continue
end

local name = model.Name:lower()
if name:find("floor") or name:find("wall") then
	continue
end

	local pos = model:GetPivot().Position
	processedModels[model] = true

	table.insert(targets, {
		instance = model,
		distance = (pos - entityPos).Magnitude,
		isPlayer = false,
		isModel = true
	})
end

local jeffTargetInstance = workspace:FindFirstChild("JeffTheKiller")
if jeffTargetInstance
	and (jeffTargetInstance:IsA("Model") or jeffTargetInstance:IsA("BasePart"))
	and jeffTargetInstance ~= s
	and jeffTargetInstance ~= selectedWardrobe
	and not processedModels[jeffTargetInstance] then

	local jeffPosition = jeffTargetInstance:IsA("Model")
		and jeffTargetInstance:GetPivot().Position
		or jeffTargetInstance.Position

	processedModels[jeffTargetInstance] = true
	table.insert(targets, {
		instance = jeffTargetInstance,
		distance = (jeffPosition - entityPos).Magnitude,
		isPlayer = false,
		isModel = jeffTargetInstance:IsA("Model")
	})
end

		table.sort(targets, function(a, b)
			return a.distance < b.distance
		end)

		local maxPull = math.min(#targets, math.random(15, 20))

local forcedTargets = {}
if playerTargetInstance then
	table.insert(forcedTargets, playerTargetInstance)
end
if jeffTargetInstance then
	table.insert(forcedTargets, jeffTargetInstance)
end

local forcedSlot = 1
for _, forcedInstance in ipairs(forcedTargets) do
	for targetIndex, target in ipairs(targets) do
		if target.instance == forcedInstance then
			if targetIndex > maxPull and forcedSlot <= maxPull then
				targets[targetIndex], targets[forcedSlot] = targets[forcedSlot], targets[targetIndex]
			end
			forcedSlot += 1
			break
		end
	end
end

local totalPullWindow = 0

local pullDelay = maxPull > 1
	and totalPullWindow / (maxPull - 1)
	or 0
	
		local instancesToDestroy = {}

		local chainStart1 = entity:FindFirstChild("ChainStart1", true)
		local chainStart2 = entity:FindFirstChild("ChainStart2", true)

		local templateChains = {}
		if chainStart1 and chainStart1:FindFirstChild("SingularityChain") then
			table.insert(templateChains, {origin = chainStart1, beam = chainStart1.SingularityChain})
		end
		if chainStart2 and chainStart2:FindFirstChild("SingularityChain") then
			table.insert(templateChains, {origin = chainStart2, beam = chainStart2.SingularityChain})
		end

local createdBeams = {}
	local createdAttachments = {}
	local playerChained = false
	local playerTarget
	local playerPullTween
	local playerChainBeam
	local playerChainAttachment
	local chainTasks = {}

	local function CancelPlayerPull()
		playerChained = false
		if playerPullTween then
			playerPullTween:Cancel()
			playerPullTween = nil
		end
		if playerChainBeam and playerChainBeam.Parent then
			playerChainBeam:Destroy()
		end
		if playerChainAttachment and playerChainAttachment.Parent then
			playerChainAttachment:Destroy()
		end
		if hrp and hrp.Parent then
			hrp.Anchored = false
		end
	end
	
	task.spawn(function()
	local start = tick()

	while tick() - start < 0.3 and light and light.Parent do
		light.Enabled = true
		task.wait(0.1)

		light.Enabled = false
		task.wait(0.1)
	end

	if light and light.Parent then
		light.Enabled = false
	end
end)

	for i = 1, maxPull do
		local target = targets[i]

		if target.isPlayer then
			playerTarget = target
			continue
		end

		local targetPart = target.instance
local targetAttPart = targetPart:IsA("Model")
	and (targetPart.PrimaryPart or targetPart:FindFirstChildWhichIsA("BasePart", true))
	or targetPart

if not targetAttPart then
	continue
end

table.insert(instancesToDestroy, targetPart)

		if targetPart and #templateChains > 0 then
			local template = templateChains[((i - 1) % #templateChains) + 1]
			local originAtt = template.origin:IsA("Attachment") and template.origin or template.origin:FindFirstChildWhichIsA("Attachment")

			if not originAtt then
				originAtt = Instance.new("Attachment")
				originAtt.Name = "SingularityChainOriginAtt"
				originAtt.Parent = template.origin
				table.insert(createdAttachments, originAtt)
			end

			local targetAtt = Instance.new("Attachment")
			targetAtt.Name = "SingularityChainTargetAtt"
			targetAtt.Position = Vector3.zero
			targetAtt.Parent = targetAttPart
			table.insert(createdAttachments, targetAtt)

			local fakePart = Instance.new("Part")
			fakePart.Name = "ChainTween"
			fakePart.Size = Vector3.new(0.1, 0.1, 0.1)
			fakePart.Transparency = 1
			fakePart.CanCollide = false
			fakePart.CanQuery = false
			fakePart.CanTouch = false
			fakePart.Anchored = true
			fakePart.CFrame = originAtt.WorldCFrame
			fakePart.Parent = workspace
			table.insert(instancesToDestroy, fakePart)

			local fakeAtt = Instance.new("Attachment")
			fakeAtt.Parent = fakePart
			table.insert(createdAttachments, fakeAtt)

			local beamToUse
			if i <= #templateChains then
				beamToUse = template.beam
			else
				beamToUse = template.beam:Clone()
				beamToUse.Parent = template.origin
				table.insert(createdBeams, beamToUse)
			end

			beamToUse.Attachment0 = originAtt
			beamToUse.Attachment1 = fakeAtt
			beamToUse.Enabled = true

			local chainTime = math.clamp(target.distance / 10000, 0.001, 0.01)
			local chainTween = TweenService:Create(
				fakePart,
				TweenInfo.new(chainTime, Enum.EasingStyle.Linear),
				{CFrame = targetAtt.WorldCFrame}
			)

			table.insert(chainTasks, task.spawn(function()
				chainTween:Play()
				chainTween.Completed:Wait()

				if beamToUse.Parent and targetAtt.Parent then
					beamToUse.Attachment1 = targetAtt
					playSound("Chained")
				end

				if fakePart.Parent then
					fakePart:Destroy()
				end
			end))
		end
	end

	for _, thread in ipairs(chainTasks) do
		task.wait()
	end

	while true do
		local done = true

		for _, thread in ipairs(chainTasks) do
			if coroutine.status(thread) ~= "dead" then
				done = false
				break
			end
		end

		if done then
			break
		end

		task.wait()
	end

	if playerTarget and #templateChains > 0 then
		task.wait(1)

		local targetPart = playerTarget.instance
		if targetPart and targetPart.Parent and CanPullPlayer() then
			local template = templateChains[1]
			local originAtt = template.origin:IsA("Attachment") and template.origin or template.origin:FindFirstChildWhichIsA("Attachment")

			if originAtt and CanPullPlayer() then
				playerChained = true
				targetPart.Anchored = true
				task.spawn(function()
					while playerChained and targetPart.Parent do
						if IsPlayerHiding() or IsPlayerBehindObstacle() then
							CancelPlayerPull()
							break
						end
						task.wait(0.05)
					end
				end)
				local targetAtt = Instance.new("Attachment")
				targetAtt.Name = "SingularityChainTargetAtt"
				targetAtt.Parent = targetPart
				targetAtt.Position = Vector3.zero
				playerChainAttachment = targetAtt
				table.insert(createdAttachments, targetAtt)

				local fakePart = Instance.new("Part")
				fakePart.Name = "ChainTween"
				fakePart.Size = Vector3.new(0.1, 0.1, 0.1)
				fakePart.Transparency = 1
				fakePart.Anchored = true
				fakePart.CanCollide = false
				fakePart.CanQuery = false
				fakePart.CanTouch = false
				fakePart.CFrame = originAtt.WorldCFrame
				fakePart.Parent = workspace
				table.insert(instancesToDestroy, fakePart)

				local fakeAtt = Instance.new("Attachment")
				fakeAtt.Parent = fakePart
				table.insert(createdAttachments, fakeAtt)

				local beam = template.beam:Clone()
				beam.Parent = template.origin
				beam.Attachment0 = originAtt
				beam.Attachment1 = fakeAtt
				beam.Enabled = true
				playerChainBeam = beam
				table.insert(createdBeams, beam)

				local tween = TweenService:Create(
					fakePart,
					TweenInfo.new(
						math.clamp(playerTarget.distance / 10000, 0.001, 0.01),
						Enum.EasingStyle.Linear
					),
					{CFrame = targetAtt.WorldCFrame}
				)
				
				spawnShake:ShakeOnce(
			6,
			2,
			0.02,
			0.5,
			0,
			0.25
		)

				tween:Play()
				tween.Completed:Wait()

				if playerChained and CanPullPlayer() and beam.Parent and targetAtt.Parent then
					beam.Attachment1 = targetAtt
					playSound("Chained")
				else
					CancelPlayerPull()
				end

				if fakePart.Parent then
					fakePart:Destroy()
				end
			end
		end
	end

task.wait(0.4)

local pulling = Instance.new("Sound")
pulling.Name = "SingularityPulling"
pulling.Volume = 5
pulling.SoundId = "rbxassetid://9117951132"
pulling.Parent = workspace
pulling.RollOffMaxDistance = 10000000
pulling.Ended:Connect(function()
	if pulling and pulling.Parent then
		pulling:Destroy()
	end
end)
pulling:Play()

		local rangeTween = TweenService:Create(
			light,
			TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{Range = 0}
		)
		rangeTween:Play()

		swallowed = true
		flashing = false

		Gui.Enabled = false
		Text.TextTransparency = 1
		Image.ImageTransparency = 1
		Image.Visible = false

		for i = 1, maxPull do
			local target = targets[i]
			if target.isPlayer then
				if playerChained and CanPullPlayer() then
					playerPullTween = TweenService:Create(
						hrp,
						TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
						{CFrame = targetCFrame}
					)
					playerPullTween:Play()

				else
					if playerChained then
						CancelPlayerPull()
					end
				end
			else
	local obj = target.instance

	if obj:IsA("Model") then
		local cf = Instance.new("CFrameValue")
		cf.Value = obj:GetPivot()

		local conn = cf:GetPropertyChangedSignal("Value"):Connect(function()
			if obj.Parent then
				obj:PivotTo(cf.Value)
			end
		end)

		local tween = TweenService:Create(
			cf,
			TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{Value = targetCFrame}
		)

		tween:Play()
		tween.Completed:Once(function()
			conn:Disconnect()
			cf:Destroy()
		end)
	else
		obj.Anchored = true
		obj.CanCollide = false

		TweenService:Create(
			obj,
			TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{CFrame = targetCFrame}
		):Play()
	end
end
		end

		task.wait(0.6)

		if selectedWardrobe and selectedWardrobe.Parent then
			selectedWardrobe:Destroy()
		end

		rangeTween:Cancel()
		light.Range = 20
		light.Brightness = 2

		task.delay(0.5, function()
			TweenService:Create(
				light,
				TweenInfo.new(3),
				{Brightness = 0}
			):Play()
		end)

		for _, template in ipairs(templateChains) do
			if template.beam then
				template.beam.Enabled = false
				template.beam.Attachment1 = nil
			end
		end

		if playerChained and not CanPullPlayer() then
			CancelPlayerPull()
		end

		if playerChained and hum and CanPullPlayer() then
	hum.Health = math.max(0, hum.Health - 60)

	for _, v in ipairs(entity:GetDescendants()) do
		if v:IsA("Sound") and v.Name == "VictimScream" then
			victimScream = v
			break
		end
	end

	if victimScream then
		victimScream.TimePosition = 0
		victimScream:Play()
	end
	
	task.delay(1.5, PlayBlaSound) 

	if hum.Health <= 0 then
		game.ReplicatedStorage.GameStats['Player_' .. game.Players.LocalPlayer.Name].Total.DeathCause.Value = 'Singularity'
	end
end

		for _, beam in ipairs(createdBeams) do
			if beam and beam.Parent then beam:Destroy() end
		end
		for _, att in ipairs(createdAttachments) do
			if att and att.Parent then att:Destroy() end
		end
		for _, inst in ipairs(instancesToDestroy) do
			if inst and inst.Parent then inst:Destroy() end
		end

		if playerChained then
			CancelPlayerPull()
		end

		local Lighting = game:GetService("Lighting")
		local cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "BlackWhiteFX"
		cc.Saturation = -1
		cc.Brightness = -0.1
		cc.Contrast = 0
		cc.Parent = Lighting

		task.spawn(function()
			task.wait(2)
			local tween = TweenService:Create(
				cc,
				TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Saturation = 0,
					Brightness = 0,
					Contrast = 0
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				cc:Destroy()
			end)
		end)

		local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
			camera.CFrame = camera.CFrame * shakeCf
		end)
		camShake:Start()
		camShake:ShakeOnce(20, 6.5, 0.1, 1, 0.1, 0.5)

		playSound("bloood")
		playSound("gore0")
		playSound("gore1")
		playSound("gore2")
		playSound("gore3")

		if entity:FindFirstChild("gore0", true) then entity.gore0.Volume = 3 end
		if entity:FindFirstChild("gore1", true) then entity.gore1.Volume = 3 end
		if entity:FindFirstChild("gore2", true) then entity.gore2.Volume = 3 end
		if entity:FindFirstChild("gore3", true) then entity.gore3.Volume = 3 end

		if entity:FindFirstChild("Blood", true) then
			entity.Blood.Enabled = true
			task.wait(2)
			entity.Blood.Enabled = false
		end

		if s and s.Parent then
			local RunService = game:GetService("RunService")
			local face = s:FindFirstChild("Face11", true)

			if face and face:IsA("ParticleEmitter") then
				local duration = 1
				local start = tick()

				while true do
					local alpha = math.clamp((tick() - start) / duration, 0, 1)

					face.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, alpha),
						NumberSequenceKeypoint.new(1, alpha)
					})

					if alpha >= 1 then
						break
					end

					RunService.Heartbeat:Wait()
				end
			end

			if victimScream and victimScream.IsPlaying then
	victimScream.Ended:Wait()
end

s:Destroy()
Gui:Destroy()
		end
	end
end

if selectedWardrobe then
	for _, prompt in ipairs(selectedWardrobe:GetDescendants()) do
		if prompt:IsA("ProximityPrompt") then
			prompt.Enabled = false
		end
	end

	local animController = selectedWardrobe:FindFirstChildOfClass("AnimationController")
	local animator

	if animController then
		animator = animController:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = animController
		end
	end

	task.spawn(function()
		local Players = game:GetService("Players")

		local function IsAnyPlayerNearWardrobe()
			local boxCFrame, boxSize = selectedWardrobe:GetBoundingBox()
			local halfSize = boxSize * 0.5

			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if root and humanoid and humanoid.Health > 0 then
					local localPosition = boxCFrame:PointToObjectSpace(root.Position)
					local closestPoint = Vector3.new(
						math.clamp(localPosition.X, -halfSize.X, halfSize.X),
						math.clamp(localPosition.Y, -halfSize.Y, halfSize.Y),
						math.clamp(localPosition.Z, -halfSize.Z, halfSize.Z)
					)
					if (localPosition - closestPoint).Magnitude <= 10 then
						return true
					end
				end
			end

			return false
		end

		while selectedWardrobe.Parent and not activated do
			if IsAnyPlayerNearWardrobe() then
				if animator then
					local anim = Instance.new("Animation")
					anim.AnimationId = "rbxassetid://9451146136"

					local track = animator:LoadAnimation(anim)
					track:Play()

					local pauseAt = track.Length > 0 and track.Length / 2 or 0.7
					task.wait(pauseAt)
					if track and track.IsPlaying then
						track:AdjustSpeed(0)
					end
				end

				StartEntity()
				break
			end

			task.wait(0.1)
		end
	end)
end
end

function entityBehaviors.Dozer()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
if not player then return end

local function isAlive(character, humanoid)
    return character ~= nil
        and character.Parent ~= nil
        and player.Character == character
        and humanoid ~= nil
        and humanoid.Parent ~= nil
        and humanoid.Health > 0
        and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

local entryCharacter = player.Character
local entryHumanoid = entryCharacter and entryCharacter:FindFirstChildOfClass("Humanoid")
if not isAlive(entryCharacter, entryHumanoid) then return end

local ORIGINAL_GAME_ID = 6627207668
local ASSET_ROOT = "IndexellScripts/Assets/Dozer"
local ASSET_FILE = ASSET_ROOT .. "/smilegui.rbxm"
local ASSET_URL = "https://github.com/IdkMyNameLoll/34921473024732147312483297412/raw/refs/heads/main/ijustlostmydawg%20(smile%20gui%20btw)%20(1).rbxm"
local IMAGES = {
    intro = "rbxassetid://71147252872275",
    check = "rbxassetid://120437404215276",
    failA = "rbxassetid://103494153774131",
    failB = "rbxassetid://86238018546540"
}
local DEFAULTS = { ticksBeforeChecking = 10, tomorrowTexts = 10 }
local config = type(_G.dozerSpawnerSettings) == "table" and _G.dozerSpawnerSettings or {}
local configTicks = math.max(1, math.floor(tonumber(config.ticksBeforeChecking) or DEFAULTS.ticksBeforeChecking))
local configTomorrow = math.max(0, math.floor(tonumber(config.tomorrowTexts) or DEFAULTS.tomorrowTexts))

if _G.__DozerStage11Running then return end
_G.__DozerStage11Running = true

local gui, soundFolder, mainSound
local savedMainVolume
local finished = false
local cancelAnimation = false
local selector = false
local transitionOverlay
local fadeTween
local moveTween
local skipNextBlend = false
local FRAME_FADE_DURATION = 0.065
local MOTION_DURATION = 0.08

local function restoreVolume()
    if mainSound and mainSound.Parent then
        local original = mainSound:FindFirstChild("OriginalVolume")
        if original and original:IsA("NumberValue") then
            mainSound.Volume = original.Value
        elseif savedMainVolume ~= nil then
            mainSound.Volume = savedMainVolume
        end
    end
end

local function cleanup()
    if finished then return end
    finished = true
    cancelAnimation = true
    if fadeTween then fadeTween:Cancel() end
    if moveTween then moveTween:Cancel() end
    if transitionOverlay and transitionOverlay.Parent then transitionOverlay:Destroy() end
    if gui and gui.Parent then gui:Destroy() end
    if soundFolder and soundFolder.Parent then soundFolder:Destroy() end
    restoreVolume()
    _G.__DozerStage11Running = nil
end

local function withoutEmbeddedScripts(asset)
    for _, child in ipairs(asset:GetDescendants()) do
        if child:IsA("LuaSourceContainer") then
            child:Destroy()
        end
    end
end

local function ensureFolders()
    if type(makefolder) ~= "function" or type(isfolder) ~= "function" then
        return false
    end
    for _, path in ipairs({"IndexellScripts", "IndexellScripts/Assets", ASSET_ROOT}) do
        if not isfolder(path) then makefolder(path) end
    end
    return true
end

local function loadOriginalGui()
    local instance
    if game.GameId == ORIGINAL_GAME_ID then
        local template = ReplicatedStorage:FindFirstChild("smilegui")
        if not template then return nil end
        instance = template:Clone()
    else
        if type(isfile) ~= "function" or not isfile(ASSET_FILE) then
            if not ensureFolders() or type(writefile) ~= "function" then return nil end
            local raw = game:HttpGet(ASSET_URL)
            if type(raw) ~= "string" or #raw <= 64 then return nil end
            writefile(ASSET_FILE, raw)
        end
        local customAsset = getcustomasset or getsynasset
        if type(customAsset) ~= "function" then return nil end
        local objects = game:GetObjects(customAsset(ASSET_FILE))
        if not objects or not objects[1] then return nil end
        instance = objects[1]
    end
    if not instance or not instance:IsA("ScreenGui") then
        if instance then instance:Destroy() end
        return nil
    end
    withoutEmbeddedScripts(instance)
    local smile = instance:FindFirstChild("smile")
    local frame = instance:FindFirstChild("Frame")
    local jumpImage = instance:FindFirstChild("ImageLabel")
    if not (smile and smile:IsA("ImageLabel")
        and frame and frame:IsA("GuiObject")
        and jumpImage and jumpImage:IsA("ImageLabel")) then
        instance:Destroy()
        return nil
    end
    instance.ResetOnSpawn = true
    instance.Parent = player:WaitForChild("PlayerGui")
    smile.Visible = false
    return instance, smile, frame, jumpImage
end

local function setupAudio()
    local folder = Instance.new("Folder")
    folder.Name = "DozerSounds"
    folder.Parent = workspace
    local money = Instance.new("Sound")
    money.Name = "Money"
    money.SoundId = "rbxassetid://3020841054"
    money.RollOffMode = Enum.RollOffMode.Inverse
    money.PlaybackSpeed = 20
    money.Parent = folder
    local menuError = Instance.new("Sound")
    menuError.Name = "Menu Error"
    menuError.SoundId = "rbxassetid://3779045779"
    menuError.RollOffMode = Enum.RollOffMode.Inverse
    menuError.PlaybackSpeed = 1
    menuError.Parent = folder
    local distortion = Instance.new("DistortionSoundEffect")
    distortion.Level = 0.94
    distortion.Priority = 0
    distortion.Parent = menuError
    return folder, money, menuError
end

local function saveAndMuteMainSound()
    local main = SoundService:FindFirstChild("Main")
    if main and main:IsA("Sound") then
        mainSound = main
        savedMainVolume = main.Volume
        local tag = main:FindFirstChild("OriginalVolume")
        if not tag then
            tag = Instance.new("NumberValue")
            tag.Name = "OriginalVolume"
            tag.Value = main.Volume
            tag.Parent = main
        end
        main.Volume = 0
    end
end

local function hasAttribute(object, name)
    for key in pairs(object:GetAttributes()) do
        if key == name then return true end
    end
    return false
end

local function earlyExitReason(character, humanoid)
    if not character or not humanoid or not humanoid.Parent then return "invalid-character" end
    if not isAlive(character, humanoid) then return "dead" end

    if hasAttribute(character, "Hiding") then
        if character:GetAttribute("Hiding") == true then return "hiding" end
        if hasAttribute(character, "InCutscene") and character:GetAttribute("InCutscene") == true then
            return "cutscene"
        end
    end
    return nil
end

local function snapshotVisual(smile)
    return {
        Image = smile.Image,
        ImageRectSize = smile.ImageRectSize,
        ImageRectOffset = smile.ImageRectOffset,
        ScaleType = smile.ScaleType,
        ImageColor3 = smile.ImageColor3,
        Position = smile.Position,
        Rotation = smile.Rotation,
        ImageTransparency = smile.ImageTransparency
    }
end

local function blendPreviousFrame(smile, previous)
    if not previous or previous.Image == "" or not smile.Parent then return end
    if not transitionOverlay or transitionOverlay.Parent ~= smile.Parent then
        transitionOverlay = smile:Clone()
        for _, child in ipairs(transitionOverlay:GetChildren()) do
            if not child:IsA("UIAspectRatioConstraint") and not child:IsA("UISizeConstraint") then
                child:Destroy()
            end
        end
        transitionOverlay.Name = "DozerBlend"
        transitionOverlay.Active = false
        transitionOverlay.Selectable = false
        transitionOverlay.Visible = false
        transitionOverlay.ZIndex = math.min(smile.ZIndex + 1, 10)
        transitionOverlay.Parent = smile.Parent
    end
    if fadeTween then fadeTween:Cancel() end
    transitionOverlay.Image = previous.Image
    transitionOverlay.ImageRectSize = previous.ImageRectSize
    transitionOverlay.ImageRectOffset = previous.ImageRectOffset
    transitionOverlay.ScaleType = previous.ScaleType
    transitionOverlay.ImageColor3 = previous.ImageColor3
    transitionOverlay.AnchorPoint = smile.AnchorPoint
    transitionOverlay.SizeConstraint = smile.SizeConstraint
    transitionOverlay.Position = previous.Position
    transitionOverlay.Rotation = previous.Rotation
    transitionOverlay.Size = smile.Size
    transitionOverlay.ImageTransparency = previous.ImageTransparency
    transitionOverlay.Visible = true
    fadeTween = TweenService:Create(
        transitionOverlay,
        TweenInfo.new(FRAME_FADE_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {ImageTransparency = 1}
    )
    fadeTween:Play()
end

local function switchImage(smile, imageId)
    if smile.Image == imageId then return end
    local previous = snapshotVisual(smile)
    smile.Image = imageId
    if imageId == IMAGES.failA or imageId == IMAGES.failB then
        smile.ImageRectSize = Vector2.zero
        smile.ImageRectOffset = Vector2.zero
        smile.ScaleType = Enum.ScaleType.Fit
    else
        smile.ScaleType = Enum.ScaleType.Crop
    end
    blendPreviousFrame(smile, previous)
    skipNextBlend = true
end

local function oneAtlasFrame(smile, money)
    local previous = snapshotVisual(smile)
    smile.ScaleType = Enum.ScaleType.Crop
    if selector then
        smile.ImageRectSize = Vector2.new(400, 400)
        smile.ImageRectOffset = Vector2.zero
    else
        smile.ImageRectSize = Vector2.new(-400, 400)
        smile.ImageRectOffset = Vector2.new(400, 0)
    end
    local targetPosition = smile.Position + UDim2.fromOffset(
        (math.random() * 2 - 1) * 12,
        (math.random() * 2 - 1) * 12
    )
    local targetRotation = (math.random() * 2 - 1) * 5
    if moveTween then moveTween:Cancel() end
    moveTween = TweenService:Create(
        smile,
        TweenInfo.new(MOTION_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Position = targetPosition, Rotation = targetRotation}
    )
    moveTween:Play()
    if skipNextBlend then
        skipNextBlend = false
    else
        blendPreviousFrame(smile, previous)
    end
    money:Play()
    selector = not selector
end

local function playIntro(smile, money)
    smile.Visible = true
    smile.Image = IMAGES.intro
    local ticks = 0
    while true do
        oneAtlasFrame(smile, money)
        ticks = ticks + 1
        local elapsed = task.wait(0.1)
        if elapsed >= 1.5 or ticks >= configTicks then break end
    end
end

local function startChecking(smile, money)
    switchImage(smile, IMAGES.check)
    cancelAnimation = false

    task.spawn(function()
        while not finished do
            if not smile or not smile.Parent then break end
            oneAtlasFrame(smile, money)
            local elapsed = task.wait(0.1)
            if elapsed >= 1.5 or cancelAnimation then break end
        end
    end)
end

local function runJumpscare(smile, frame, jumpImage, menuError, character, humanoid)
    if not isAlive(character, humanoid) then return end
    switchImage(smile, IMAGES.failA)
    frame.Visible = true
    jumpImage.ScaleType = Enum.ScaleType.Fit
    jumpImage.Visible = true
    task.wait(0.55)
    if finished or not isAlive(character, humanoid) then return end
    switchImage(smile, IMAGES.failB)
    local previous = jumpImage
    for _ = 1, configTomorrow do
        if finished or not isAlive(character, humanoid) then return end
        local clone = previous:Clone()
        clone.ScaleType = Enum.ScaleType.Fit
        clone.Parent = gui
        clone.Position = UDim2.new(
            -0.011, previous.Position.X.Offset + 20,
             1.05, previous.Position.Y.Offset - 20
        )
        previous = clone
        task.wait(0.035)
        menuError:Play()
    end
    menuError:Stop()
    if gui and gui.Parent then gui:Destroy() end
    if isAlive(character, humanoid) then
        humanoid.Health = 0
    end
end

local function handleCrucifix(character)
    local item = character:FindFirstChild("Crucifix")
    if not item then return false end
    item:Destroy()
    if RunService:IsStudio() then
        local special = player.PlayerGui:FindFirstChild("dozerCrucifixed")
        if special and special:IsA("ScreenGui") then
            special.Enabled = true
        end
    end
    return true
end

local function main()
    local character = entryCharacter
    local humanoid = entryHumanoid
    if not isAlive(character, humanoid) then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local smile, frame, jumpImage
    gui, smile, frame, jumpImage = loadOriginalGui()
    if not gui or not isAlive(character, humanoid) then return end
    local money, menuError
    soundFolder, money, menuError = setupAudio()
    saveAndMuteMainSound()

    playIntro(smile, money)
    if finished or earlyExitReason(character, humanoid) then return end

    startChecking(smile, money)
    task.wait(0.2)
    if finished or earlyExitReason(character, humanoid) then return end
    local moving = rootPart.Velocity.Magnitude >= 0.4
    local crouching = (not moving) and character:GetAttribute("Crouching") == true
    if not moving and crouching then
        task.wait(0.35)
        cancelAnimation = true
        if gui and gui.Parent then gui:Destroy() end
        return
    end
    cancelAnimation = true
    if handleCrucifix(character) then return end
    runJumpscare(smile, frame, jumpImage, menuError, character, humanoid)
end

pcall(main)
pcall(cleanup)
_G.__DozerStage11Running = nil
end
local entityConfig = {
    ["rbxassetid://453843"]  = entityBehaviors.Mush, 
    ["rbxassetid://4538455"]  = entityBehaviors.Z19, 
    ["rbxassetid://354843"]  = entityBehaviors.Bear, 
    ["rbxassetid://53893"]  = entityBehaviors.A20, 
    ["rbxassetid://786875"]  = entityBehaviors.PRINCIPAL, 
    ["rbxassetid://583287"]  = entityBehaviors.Scribblet, 
    ["rbxassetid://86863"]  = entityBehaviors.SLD, 
    ["rbxassetid://53843552"]  = entityBehaviors.Bite, 
    ["rbxassetid://8324207"]  = entityBehaviors.MEshis, 
    ["rbxassetid://8324205"]  = entityBehaviors.MESHI, 
    ["rbxassetid://8324278"]  = entityBehaviors.Limbo, 
    ["rbxassetid://832454122"]  = entityBehaviors.Surge, 
    ["rbxassetid://658640484"]  = entityBehaviors.Silence3, 
    ["rbxassetid://26214722"]  = entityBehaviors.Singularity, 
    ["rbxassetid://4583345838"]  = entityBehaviors.Dozer, 
    ["rbxassetid://2456348"]  = entityBehaviors.Happy
}

local checkedEntities = {}

local CONTAINER_NAMES = {"############", "Scary Entity"}

local function universalCheckSound(sound)
    if not sound:IsA("Sound") then return end

    local soundId = sound.SoundId
    local targetBehavior = entityConfig[soundId]

    if targetBehavior then
        local parent = sound.Parent

        if parent and table.find(CONTAINER_NAMES, parent.Name) then
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

        for _, containerName in ipairs(CONTAINER_NAMES) do
            local container = entity:FindFirstChild(containerName)
            if container then
                for _, child in pairs(container:GetChildren()) do
                    universalCheckSound(child)
                end
            end
        end
    end
end
local hint = Instance.new("Hint", Workspace)
hint.Text = "LoadingFive... Doors HardCore V10.7.1 By Number303 & HeavenNow :)"
game.Debris:AddItem(hint, 2)
