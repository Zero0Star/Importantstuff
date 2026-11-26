
if workspace:FindFirstChild("HardcoreTwo") then
    return
end
local marker = Instance.new("BoolValue")
marker.Name = "HardcoreTwo"
marker.Value = true
marker.Parent = workspace
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()
local entityBehaviors = {}

function entityBehaviors.MOSCJ()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Env = getgenv()

local AchievementTitle = "Someone Else's Turn"
local AchievementDescription = "It tried on every face you fear, grew bored of yours, and moved on."
local AchievementImage = "rbxassetid://137217897206292"

local function FindSound(Name)
    local Folder = workspace:FindFirstChild("HardCoreSound") or workspace:WaitForChild("HardCoreSound", 8)
    local Sound = Folder and Folder:FindFirstChild(Name)
    if Sound and Sound:IsA("Sound") then
        return Sound
    end
    return nil
end

local function CreateSound(Source, Name, Volume, Looped)
    if not Source then
        return nil
    end

    local Sound = Source:Clone()
    Sound.Name = Name
    Sound.Volume = Volume
    Sound.Looped = Looped
    Sound.TimePosition = 0
    Sound.SoundGroup = nil
    Sound.Parent = SoundService
    return Sound
end

local GlitchSound = CreateSound(FindSound("MultiAchievementGlitch"), "MultiMonsterGlitchPlayback", 10, true)
local UnlockSound = CreateSound(FindSound("MultiAchievement"), "MultiMonsterUnlockPlayback", 2, false)

if GlitchSound or UnlockSound then
    task.spawn(function()
        pcall(function()
            local Sounds = {}
            if GlitchSound then
                table.insert(Sounds, GlitchSound)
            end
            if UnlockSound then
                table.insert(Sounds, UnlockSound)
            end
            ContentProvider:PreloadAsync(Sounds)
        end)
    end)
end

local function HasRequiredParts(Achievement)
    if not Achievement or not Achievement:IsA("GuiObject") then
        return false
    end

    local Frame = Achievement:FindFirstChild("Frame")
    local Details = Frame and Frame:FindFirstChild("Details")
    return Frame ~= nil
        and Details ~= nil
        and Details:FindFirstChild("Title") ~= nil
        and Details:FindFirstChild("Desc") ~= nil
        and Details:FindFirstChild("Reason") ~= nil
        and Frame:FindFirstChild("TextLabel") ~= nil
        and Frame:FindFirstChild("ImageLabel") ~= nil
end

local function FindNativeTemplate()
    for _, Child in ipairs(PlayerGui:GetDescendants()) do
        if Child.Name == "AchievementsHolder" then
            local Template = Child:FindFirstChild("Achievement")
            if HasRequiredParts(Template) then
                local Screen = Template:FindFirstAncestorWhichIsA("ScreenGui")
                if not Screen or Screen.Enabled then
                    return Template, Child
                end
            end
        end
    end
    return nil, nil
end

local function CreateFallbackLabel(Parent, Name, Text, Position, Size, TextSize, Color)
    local Label = Instance.new("TextLabel")
    Label.Name = Name
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.TextWrapped = true
    Label.TextColor3 = Color
    Label.TextSize = TextSize
    Label.Font = Enum.Font.Oswald
    Label.Text = Text
    Label.Position = Position
    Label.Size = Size
    Label.ZIndex = 52
    Label.Parent = Parent
    return Label
end

local function CreateFallback()
    local Old = PlayerGui:FindFirstChild("MultiMonsterStandaloneAchievementUI")
    if Old then
        Old:Destroy()
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "MultiMonsterStandaloneAchievementUI"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999999
    Gui.Parent = PlayerGui

    local Holder = Instance.new("Frame")
    Holder.Name = "AchievementsHolder"
    Holder.BackgroundTransparency = 1
    Holder.Size = UDim2.fromScale(1, 1)
    Holder.Parent = Gui

    local Achievement = Instance.new("Frame")
    Achievement.Name = "LiveAchievement"
    Achievement.BackgroundTransparency = 1
    Achievement.Size = UDim2.fromOffset(420, 136)
    Achievement.Position = UDim2.new(1, -435, 0, 68)
    Achievement.ClipsDescendants = false
    Achievement.Parent = Holder

    local Card = Instance.new("Frame")
    Card.Name = "Frame"
    Card.BackgroundColor3 = Color3.fromRGB(23, 4, 4)
    Card.BackgroundTransparency = 0.08
    Card.BorderSizePixel = 0
    Card.Size = UDim2.fromScale(1, 1)
    Card.Position = UDim2.new(1.1, 0, 0, 0)
    Card.ZIndex = 50
    Card.Parent = Achievement

    local Accent = Instance.new("Frame")
    Accent.Name = "Accent"
    Accent.BorderSizePixel = 0
    Accent.BackgroundColor3 = Color3.fromRGB(220, 22, 22)
    Accent.Size = UDim2.new(0, 5, 1, 0)
    Accent.ZIndex = 51
    Accent.Parent = Card

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "ImageLabel"
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.fromOffset(18, 32)
    Icon.Size = UDim2.fromOffset(68, 68)
    Icon.Image = AchievementImage
    Icon.ZIndex = 52
    Icon.Parent = Card

    CreateFallbackLabel(Card, "TextLabel", "UNLOCKED ACHIEVEMENT", UDim2.fromOffset(103, 9), UDim2.fromOffset(302, 23), 19, Color3.fromRGB(255, 48, 48))

    local Details = Instance.new("Frame")
    Details.Name = "Details"
    Details.BackgroundTransparency = 1
    Details.Position = UDim2.fromOffset(103, 34)
    Details.Size = UDim2.fromOffset(302, 98)
    Details.ZIndex = 51
    Details.Parent = Card

    CreateFallbackLabel(Details, "Title", AchievementTitle, UDim2.fromOffset(0, 0), UDim2.fromOffset(299, 31), 25, Color3.fromRGB(255, 80, 80))
    CreateFallbackLabel(Details, "Desc", AchievementDescription, UDim2.fromOffset(0, 32), UDim2.fromOffset(299, 52), 16, Color3.fromRGB(220, 181, 181))
    CreateFallbackLabel(Details, "Reason", "", UDim2.fromOffset(0, 83), UDim2.fromOffset(299, 14), 13, Color3.fromRGB(200, 160, 160))

    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.BackgroundTransparency = 1
    Glow.ImageTransparency = 1
    Glow.Size = UDim2.fromScale(1, 1)
    Glow.ZIndex = 49
    Glow.Parent = Card

    return Achievement, Holder, Gui, false
end

local function CreateAchievement()
    local Template, Holder = FindNativeTemplate()
    if not Template then
        local Deadline = os.clock() + 1.5
        while os.clock() < Deadline do
            task.wait(0.15)
            Template, Holder = FindNativeTemplate()
            if Template then
                break
            end
        end
    end

    if not Template then
        return CreateFallback()
    end

    local Achievement = Template:Clone()
    Achievement.Name = "LiveAchievement"
    Achievement.Visible = true
    Achievement.Size = UDim2.new(0, 0, 0, 0)
    Achievement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
    Achievement.Parent = Holder

    local BaseH = select(1, Color3.fromRGB(255, 0, 0):ToHSV())

    for _, Object in ipairs(Achievement:GetDescendants()) do
        if Object:IsA("GuiObject") then
            local _, Saturation, Value = Object.BackgroundColor3:ToHSV()
            Object.BackgroundColor3 = Color3.fromHSV(BaseH, math.clamp(Saturation * 2.5, 0, 1), Value)
        end
        if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
            local _, Saturation, Value = Object.TextColor3:ToHSV()
            Object.TextColor3 = Color3.fromHSV(BaseH, math.clamp(Saturation * 2.5, 0, 1), Value)
        end
        if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
            local _, Saturation, Value = Object.ImageColor3:ToHSV()
            Object.ImageColor3 = Color3.fromHSV(BaseH, math.clamp(Saturation * 2.5, 0, 1), Value)
        end
        if Object:IsA("UIStroke") then
            local _, Saturation, Value = Object.Color:ToHSV()
            Object.Color = Color3.fromHSV(BaseH, math.clamp(Saturation * 2.5, 0, 1), Value)
        end
    end

    return Achievement, Holder, nil, true
end

local function CorruptText(Text)
    local Characters = {}
    for _, Codepoint in utf8.codes(Text) do
        table.insert(Characters, utf8.char(Codepoint))
    end
    if #Characters == 0 then
        return Text
    end
    for _ = 1, 3 do
        local Index = math.random(1, #Characters)
        if Characters[Index] ~= " " then
            Characters[Index] = math.random(1, 2) == 1 and "☐" or "⌷"
        end
    end
    return table.concat(Characters)
end

local Achievement, Holder, StandaloneGui, NativeTemplate = CreateAchievement()
local Card = Achievement.Frame
local Details = Card.Details
local Title = Details.Title

Card.TextLabel.Text = "UNLOCKED ACHIEVEMENT"
Title.Text = AchievementTitle
Details.Desc.Text = AchievementDescription
Details.Reason.Text = ""
Card.ImageLabel.Image = AchievementImage

if NativeTemplate then
    Achievement:TweenSize(UDim2.new(1, 0, 0.2, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.8, true)
    task.wait(0.8)
end

Card:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
task.wait(0.5)

Env.MultiMonsterAchievementPlayed = true

local Glow = Card:FindFirstChild("Glow")
if Glow and Glow:IsA("ImageLabel") then
    TweenService:Create(Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
end

local GlitchContainer = Instance.new("Frame")
GlitchContainer.Name = "GlitchContainer"
GlitchContainer.BackgroundTransparency = 1
GlitchContainer.BorderSizePixel = 0
GlitchContainer.Size = UDim2.fromScale(1, 1)
GlitchContainer.ZIndex = 9999
GlitchContainer.ClipsDescendants = false
GlitchContainer.Parent = Achievement

local Glitching = true
local OriginalText = Title.Text

local function MakeGlitchFrame()
    if not Glitching or not GlitchContainer.Parent then
        return
    end
    local Frame = Instance.new("Frame")
    Frame.Name = "GlitchFrame"
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 10000
    Frame.Size = UDim2.fromOffset(math.random(20, 80), math.random(12, 55))
    Frame.Position = UDim2.new(math.random(10, 95) / 100, math.random(-100, 80), math.random(15, 85) / 100, math.random(-20, 20))
    Frame.Parent = GlitchContainer
    Debris:AddItem(Frame, 0.45)
end

task.spawn(function()
    while Glitching and Achievement.Parent do
        Title.Text = CorruptText(OriginalText)
        task.wait(0.035)
        if Glitching and Title.Parent then
            Title.Text = OriginalText
        end
        task.wait(0.025)
    end
    if Title.Parent then
        Title.Text = OriginalText
    end
end)

task.spawn(function()
    while Glitching and Achievement.Parent do
        MakeGlitchFrame()
        task.wait(0.5)
    end
end)

if GlitchSound then
    GlitchSound:Stop()
    GlitchSound.TimePosition = 0
    GlitchSound:Play()
end

task.wait(2)
Glitching = false
Title.Text = OriginalText
GlitchContainer:Destroy()

if GlitchSound then
    GlitchSound:Stop()
    GlitchSound:Destroy()
end

if UnlockSound then
    UnlockSound:Stop()
    UnlockSound.TimePosition = 0
    UnlockSound:Play()
    Debris:AddItem(UnlockSound, math.max(10, UnlockSound.TimeLength + 2))
end

task.wait(7)

if Achievement.Parent then
    Card:TweenPosition(UDim2.new(1.1, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true)
    task.wait(0.5)
    if NativeTemplate then
        Achievement:TweenSize(UDim2.new(1, 0, -0.1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.5, true)
        task.wait(0.5)
    end
    Achievement:Destroy()
end

if StandaloneGui and StandaloneGui.Parent then
    StandaloneGui:Destroy()
end
end

function entityBehaviors.GrimReaper()
local soundFolder = game:GetService("Workspace"):WaitForChild("HardCoreSound")
local loadedSound = soundFolder:WaitForChild("BossTime")

if loadedSound and loadedSound:IsA("Sound") then
    loadedSound:Stop()
    loadedSound.Looped = false
    loadedSound.TimePosition = 0
    loadedSound.Volume = 1
    loadedSound:Play()
end

local mainGame = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)

mainGame.caption("Hello.", true)
mainGame.titlelocation("Survive the Grim Reaper", true)

wait(2)
mainGame.caption("...", true)

wait(4)
mainGame.caption("I am very unfamiliar, right?", true)

wait(4)
mainGame.caption("You don't need to know this.", true)

wait(4)
mainGame.caption("In short, I wish you good luck.", true)

wait(4)
mainGame.caption("Task: Survive...", true)
end

function entityBehaviors.Silence22()
local TweenService = game:GetService("TweenService")
local hardCoreSound = workspace:WaitForChild("HardCoreSound")
local silenceSource = hardCoreSound:WaitForChild("Silence")
local silenceFarSource = hardCoreSound:WaitForChild("SilenceFar")

local function LoadModel(file, url)
	if not isfile(file) then
		writefile(file, game:HttpGet(url))
	end

	return game:GetObjects(getcustomasset(file))[1]
end

local _Idx57 = LoadModel(
		"silencismdj.txt",
		"https://raw.githubusercontent.com/lynguyen26031993-design/-u/refs/heads/main/Place_131351567799504_Model_Silence_1785827465.txt"
	)
	
	local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local HidingFound = false
local CheckingHiding = false

local function CheckHiding()
	CheckingHiding = true
	HidingFound = false

	task.spawn(function()
		while CheckingHiding do
			if Character:GetAttribute("Hiding") == true then
				HidingFound = true
				break
			end

			task.wait(0.1)
		end
	end)
end


local function CheckNoHidingCount()
CheckingHiding = false

if not HidingFound then
		getgenv().NoHidingCount += 1
	end

	if getgenv().NoHidingCount >= 10 then
		if not isfile("AdrenalineGot") then
			writefile("AdrenalineGot", "-- Adrenaline unlocked")

			local CharmsNotify =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/PAKKALCKKWKKJXIODKRBFHHAUJCJJJSNDJ/HAXRHCHHCHCHJSJSLKKKJDPQOIJXHBS/refs/heads/main/CharmUnlock"))()

CharmsNotify({
	Style = "UNLOCKED ACHIEVEMENT",
	Title = "White Knuckles",
	Description = "Just a hallway, the thing in it, and a heart that refuses to quit.",
	Reason = "Survive 10 entity attacks without hiding.",
	Image = "rbxassetid://99618297248695",
	Time = 5
})
			
		end
	end
end

task.spawn(function() 
CheckHiding()
end) 

function GitAud(soundgit, filename)
	local file = filename..".mp3"

	if not isfile(file) then
		writefile(file, game:HttpGet(soundgit))
	end

	return (getcustomasset or getsynasset)(file)
end

local function GetGitSound(GithubSnd, SoundName)
	local url = GithubSnd
	if not isfile(SoundName .. ".ogg") then
		writefile(SoundName .. ".ogg", game:HttpGet(url))
	end
	local sound = Instance.new("Sound")
	sound.SoundId = (getcustomasset or getsynasset)(SoundName .. ".ogg")
	return sound
end

local noChase = false
local currentEntityRoom
local stopChaseTrigger = false
local finalRoom = false
local Fail


function CustomGitSound(soundlink, volume, distance, filename, soundName, parent, looped, mode, emitter)
	local sound = Instance.new("Sound")

	sound.SoundId = GitAud(soundlink, filename)
	sound.Parent = parent or workspace

	sound.Volume = volume or 1

	sound.RollOffMaxDistance = distance or 100
	sound.RollOffMinDistance = 5

	if mode then
		sound.RollOffMode = mode
	end

	sound.EmitterSize = emitter or 100000

	sound.PlaybackSpeed = 1
	sound.Name = soundName or "bgtheme"
	sound.Looped = looped or false

	return sound
end


_Idx57.Parent = workspace
_Idx57.Name = "SilenceReignited"
local playerTriggered = false
local entityLocked = false
local entityMoving = false
local lockedCFrame
local chasing = false
local chaseTrigger = false

local NEAR_SOUND_DISTANCE = 115
local FAR_MAX_DISTANCE = 360
local FAR_MIN_VOLUME = 0.02
local SOUND_CONFIRM_TIME = 0.08

local CeaseRunService = game:GetService("RunService")
local ceaseFreezeActive = false
local ceaseInteractionActive = false
local ceaseSpeedScale = 1
local ceaseEventRunning = true
local ceaseSilenceModel = _Idx57
local ceaseFreezeCycle = 0
local ceaseSavedEffects = {}
local ceaseEffectConnection = nil
local ceaseWorkspaceConnection = nil
local ceaseClockConnection = nil
local ceaseVirtualClock = 0
local ceaseHandledModels = setmetatable({}, {__mode = "k"})
local ceaseTrackedTweens = setmetatable({}, {__mode = "k"})

local function CeaseTime1()
	return ceaseVirtualClock
end

local function CeaseWait1(duration)
	local started = CeaseTime1()

	while ceaseEventRunning
		and ceaseSilenceModel
		and ceaseSilenceModel.Parent
		and CeaseTime1() - started < duration do
		CeaseRunService.Heartbeat:Wait()
	end
end

local function CeaseEasing1(alpha)
	alpha = math.clamp(alpha, 0, 1)
	return alpha * alpha * (3 - 2 * alpha)
end

local function CeaseTrackTween1(tween)
	ceaseTrackedTweens[tween] = true

	tween.Completed:Connect(function()
		ceaseTrackedTweens[tween] = nil
	end)

	return tween
end

local function CeasePauseTweens1()
	for tween in pairs(ceaseTrackedTweens) do
		if tween.PlaybackState == Enum.PlaybackState.Playing then
			pcall(function()
				tween:Pause()
			end)
		end
	end
end

local function CeaseResumeTweens1()
	for tween in pairs(ceaseTrackedTweens) do
		if tween.PlaybackState == Enum.PlaybackState.Paused then
			pcall(function()
				tween:Play()
			end)
		end
	end
end

local function CeaseApply1(scale)
	ceaseSpeedScale = math.clamp(scale, 0, 1)

	for object, saved in pairs(ceaseSavedEffects) do
		if object.Parent then
			if saved.Type == "Particle" then
				pcall(function()
					object.TimeScale = saved.TimeScale * ceaseSpeedScale
				end)
			else
				pcall(function()
					object.PlaybackSpeed = saved.PlaybackSpeed * ceaseSpeedScale
				end)
				pcall(function()
					object.Volume = saved.Volume * ceaseSpeedScale
				end)
			end
		end
	end
end

local function CeaseTrack1(object)
	if not object or not object.Parent or ceaseSavedEffects[object] then
		return
	end

	if object:IsA("ParticleEmitter") then
		ceaseSavedEffects[object] = {
			Type = "Particle",
			TimeScale = object.TimeScale
		}
	elseif object:IsA("Sound") then
		ceaseSavedEffects[object] = {
			Type = "Sound",
			PlaybackSpeed = object.PlaybackSpeed,
			Volume = object.Volume
		}
	else
		return
	end

	local saved = ceaseSavedEffects[object]
	if saved.Type == "Particle" then
		pcall(function()
			object.TimeScale = saved.TimeScale * ceaseSpeedScale
		end)
	else
		pcall(function()
			object.PlaybackSpeed = saved.PlaybackSpeed * ceaseSpeedScale
		end)
		pcall(function()
			object.Volume = saved.Volume * ceaseSpeedScale
		end)
	end
end

local function CeaseRestore1(resumeTweens)
	ceaseFreezeCycle += 1

	if ceaseEffectConnection then
		ceaseEffectConnection:Disconnect()
		ceaseEffectConnection = nil
	end

	if ceaseWorkspaceConnection then
		ceaseWorkspaceConnection:Disconnect()
		ceaseWorkspaceConnection = nil
	end

	for object, saved in pairs(ceaseSavedEffects) do
		if object.Parent then
			if saved.Type == "Particle" then
				pcall(function()
					object.TimeScale = saved.TimeScale
				end)
			else
				pcall(function()
					object.PlaybackSpeed = saved.PlaybackSpeed
					object.Volume = saved.Volume
				end)
			end
		end
	end

	table.clear(ceaseSavedEffects)
	ceaseSpeedScale = 1
	ceaseFreezeActive = false

	if resumeTweens ~= false then
		CeaseResumeTweens1()
	end
end

local function CeaseStart1(ceaseModel)
	if not ceaseEventRunning
		or ceaseFreezeActive
		or ceaseInteractionActive
		or not ceaseSilenceModel
		or not ceaseSilenceModel.Parent
		or not ceaseModel
		or not ceaseModel:IsA("Model")
		or ceaseHandledModels[ceaseModel]
	then
		return
	end

	ceaseHandledModels[ceaseModel] = true
	ceaseFreezeActive = true
	ceaseFreezeCycle += 1
	local cycle = ceaseFreezeCycle

	CeasePauseTweens1()

	for _, object in ipairs(ceaseSilenceModel:GetDescendants()) do
		CeaseTrack1(object)
	end

	local chaseSound = workspace:FindFirstChild("Boso")
	if chaseSound and chaseSound:IsA("Sound") then
		CeaseTrack1(chaseSound)
	end

	ceaseWorkspaceConnection = workspace.DescendantAdded:Connect(function(object)
		if ceaseEventRunning
			and ceaseFreezeCycle == cycle
			and object:IsA("Sound")
			and object.Name == "Boso"
		then
			CeaseTrack1(object)
		end
	end)

	ceaseEffectConnection = ceaseSilenceModel.DescendantAdded:Connect(function(object)
		if ceaseEventRunning and ceaseFreezeCycle == cycle then
			CeaseTrack1(object)
		end
	end)

	task.spawn(function()
		local function valid()
			return ceaseEventRunning
				and ceaseFreezeCycle == cycle
				and ceaseSilenceModel ~= nil
				and ceaseSilenceModel.Parent ~= nil
		end

		local function transition(fromScale, toScale, duration)
			local started = os.clock()

			while valid() do
				local alpha = math.clamp((os.clock() - started) / duration, 0, 1)
				local eased = CeaseEasing1(alpha)
				CeaseApply1(fromScale + (toScale - fromScale) * eased)

				if alpha >= 1 then
					return true
				end

				CeaseRunService.Heartbeat:Wait()
			end

			return false
		end

		if not transition(1, 0, 2.25) then
			if ceaseFreezeCycle == cycle then
				CeaseRestore1()
			end
			return
		end

		local started = os.clock()
		while os.clock() - started < 13 do
			if not valid() then
				if ceaseFreezeCycle == cycle then
					CeaseRestore1()
				end
				return
			end
			task.wait(0.05)
		end

		if not transition(0, 1, 2) then
			if ceaseFreezeCycle == cycle then
				CeaseRestore1()
			end
			return
		end

		if ceaseFreezeCycle == cycle then
			CeaseRestore1()
		end
	end)
end

local function CeaseStop1()
	if not ceaseEventRunning and not ceaseFreezeActive then
		return
	end

	ceaseEventRunning = false
	CeaseRestore1(false)

	if ceaseClockConnection then
		ceaseClockConnection:Disconnect()
		ceaseClockConnection = nil
	end

	ceaseSilenceModel = nil
end

ceaseClockConnection = CeaseRunService.Heartbeat:Connect(function(deltaTime)
	if ceaseEventRunning then
		ceaseVirtualClock += deltaTime * ceaseSpeedScale
	end
end)

_Idx57.Destroying:Connect(CeaseStop1)

task.spawn(function()
	while ceaseEventRunning and ceaseSilenceModel and ceaseSilenceModel.Parent do
		local ceaseModel = workspace:FindFirstChild("Cease", true)
		if ceaseModel and ceaseModel:IsA("Model") then
			CeaseStart1(ceaseModel)
		end
		task.wait(0.1)
	end
end)

local function GetFarVolume(distance)
	if distance <= NEAR_SOUND_DISTANCE then
		return 1
	end

	if distance >= FAR_MAX_DISTANCE then
		return FAR_MIN_VOLUME
	end

	local alpha = (distance - NEAR_SOUND_DISTANCE)
		/ (FAR_MAX_DISTANCE - NEAR_SOUND_DISTANCE)

	return math.clamp(
		(1 - alpha) ^ 1.25,
		FAR_MIN_VOLUME,
		1
	)
end

local soundWatchConnection = nil
local soundWatchCharacter = nil
local soundConnections = {}
local soundConfirmTokens = {}
local soundDetectionActive = false

local function IsRealPlayingPlayerSound(sound)
	local character = Player.Character

	return sound ~= nil
		and sound:IsA("Sound")
		and character ~= nil
		and sound:IsDescendantOf(character)
		and sound.SoundId ~= ""
		and sound.Volume > 0
		and sound.Playing
end

local function IsSilenceWithinSoundRange()
	local character = Player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local entityRoot = _Idx57:FindFirstChild("RushNew")

	if not hrp or not entityRoot or not entityRoot:IsA("BasePart") then
		return false
	end

	return (hrp.Position - entityRoot.Position).Magnitude <= NEAR_SOUND_DISTANCE
end

local function CancelSoundConfirmation(sound)
	soundConfirmTokens[sound] = (soundConfirmTokens[sound] or 0) + 1
end

local function ConfirmPlayingSound(sound)
	if not soundDetectionActive
		or noChase
		or stopChaseTrigger
		or finalRoom
		or entityMoving
		or chasing
		or entityLocked
		or chaseTrigger
		or ceaseFreezeActive
	then
		return
	end

	if not IsRealPlayingPlayerSound(sound) then
		return
	end

	soundConfirmTokens[sound] = (soundConfirmTokens[sound] or 0) + 1
	local token = soundConfirmTokens[sound]

	task.delay(SOUND_CONFIRM_TIME, function()
		if not soundDetectionActive
			or noChase
			or stopChaseTrigger
			or finalRoom
			or entityMoving
			or chasing
			or entityLocked
			or chaseTrigger
			or ceaseFreezeActive
			or soundConfirmTokens[sound] ~= token
			or not sound
			or not sound.Parent
			or not IsRealPlayingPlayerSound(sound)
			or not IsSilenceWithinSoundRange()
		then
			return
		end

		chaseTrigger = true
	end)
end

local function DisconnectWatchedSound(sound)
	local connections = soundConnections[sound]

	if connections then
		for _, connection in ipairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end

	soundConnections[sound] = nil
	soundConfirmTokens[sound] = nil
end

local function WatchPlayerSound(sound)
	if not sound:IsA("Sound") then
		return
	end

	DisconnectWatchedSound(sound)
	soundConnections[sound] = {}

	local function RefreshSoundState()
		if IsRealPlayingPlayerSound(sound) then
			ConfirmPlayingSound(sound)
		else
			CancelSoundConfirmation(sound)
		end
	end

	for _, property in ipairs({"Playing", "SoundId", "Volume"}) do
		table.insert(
			soundConnections[sound],
			sound:GetPropertyChangedSignal(property):Connect(RefreshSoundState)
		)
	end

	table.insert(
		soundConnections[sound],
		sound.AncestryChanged:Connect(function()
			local character = Player.Character

			if not character or not sound:IsDescendantOf(character) then
				CancelSoundConfirmation(sound)
				DisconnectWatchedSound(sound)
			end
		end)
	)

	if sound.Playing then
		ConfirmPlayingSound(sound)
	end
end

local function StopPlayerSoundWatcher()
	soundDetectionActive = false

	if soundWatchConnection then
		soundWatchConnection:Disconnect()
		soundWatchConnection = nil
	end

	local sounds = {}
	for sound in pairs(soundConnections) do
		table.insert(sounds, sound)
	end

	for _, sound in ipairs(sounds) do
		CancelSoundConfirmation(sound)
		DisconnectWatchedSound(sound)
	end

	table.clear(soundConfirmTokens)
	soundWatchCharacter = nil
end

local function StartPlayerSoundWatcher(character)
	if not character then
		return
	end

	if soundDetectionActive and soundWatchCharacter == character then
		return
	end

	StopPlayerSoundWatcher()

	soundDetectionActive = true
	soundWatchCharacter = character

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("Sound") then
			WatchPlayerSound(object)
		end
	end

	soundWatchConnection = character.DescendantAdded:Connect(function(object)
		if soundDetectionActive and object:IsA("Sound") then
			WatchPlayerSound(object)
		end
	end)
end

task.spawn(function()
	repeat
		task.wait()
	until _Idx57:FindFirstChild("RushNew") or not _Idx57.Parent

	while _Idx57.Parent do
		local character = Player.Character
		local shouldListen = currentEntityRoom ~= nil
			and not noChase
			and not stopChaseTrigger
			and not finalRoom
			and not entityMoving
			and not chasing
			and not entityLocked
			and not chaseTrigger
			and not ceaseFreezeActive
			and IsSilenceWithinSoundRange()

		if shouldListen and character then
			StartPlayerSoundWatcher(character)
		elseif soundDetectionActive then
			StopPlayerSoundWatcher()
		end

		task.wait(0.1)
	end

	StopPlayerSoundWatcher()
end)

local function GetPlayerRoom()
	local char = game.Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hrp then return end

	for _,room in pairs(workspace.CurrentRooms:GetChildren()) do
		local cf,size = room:GetBoundingBox()

		local pos = cf:PointToObjectSpace(hrp.Position)

		if math.abs(pos.X) <= size.X/2
		and math.abs(pos.Y) <= size.Y/2
		and math.abs(pos.Z) <= size.Z/2 then

			return room
		end
	end
end

task.spawn(function()
    local SCREAM = silenceSource:Clone()
    SCREAM.Name = "SCREAMOFFSILENCE"
    SCREAM:Stop()
    SCREAM.TimePosition = 0
    SCREAM.Volume = 5
    SCREAM.PlaybackSpeed = 1
    SCREAM.Looped = false
    SCREAM.RollOffMaxDistance = 120
    SCREAM.Parent = _Idx57.RushNew
end)

task.spawn(function()
    local boomSound = silenceFarSource:Clone()
    boomSound.Name = "BOKKOMOFFHSJEJSJSJ"
    boomSound:Stop()
    boomSound.TimePosition = 0
    boomSound.Volume = 0.5
    boomSound.RollOffMaxDistance = 25000
    boomSound.RollOffMinDistance = 5
    boomSound.RollOffMode = Enum.RollOffMode.Linear
    boomSound.EmitterSize = 10000
    boomSound.PlaybackSpeed = 1
    boomSound.Looped = false
    boomSound.Parent = _Idx57.RushNew
end)

local scream

repeat
	scream = _Idx57.RushNew:FindFirstChild("SCREAMOFFSILENCE")
	task.wait()
until scream

local boom

repeat
	boom = _Idx57.RushNew:FindFirstChild("BOKKOMOFFHSJEJSJSJ")
	task.wait()
until boom

local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

local img = Instance.new("ImageLabel")
img.Parent = gui
img.Size = UDim2.fromScale(1, 1)
img.Position = UDim2.fromScale(0.5, 0.5)
img.AnchorPoint = Vector2.new(0.5, 0.5)
img.BackgroundTransparency = 1
img.Image = "rbxassetid://86616651038164"
img.ScaleType = Enum.ScaleType.Stretch

local tween = TweenService:Create(
	img,
	TweenInfo.new(1.5, Enum.EasingStyle.Linear),
	{ImageTransparency = 1}
)

tween:Play()

task.spawn(function()
	while img.Parent do
		img.Rotation += 180
		task.wait(0.05)
	end
end)

task.spawn(function() 
tween.Completed:Wait()
gui:Destroy()
end) 

local BloodRoom = {}

local rots = {90, 180, 270}
local textures = {}
local surfaceGuis = {}
local enabled = false
local textureSession = 0
local textureManagerRunning = false
local textureFaces = Enum.NormalId:GetEnumItems()
local bloodRunService = game:GetService("RunService")
local textureColor = Color3.fromRGB(170, 85, 255)
local textureStartTransparency = 0.3
local textureFadeDelay = 0.5
local textureFadeDuration = 4
local textureRotationInterval = 0.6
local textureUpdateInterval = 0.08
local texturesPerFrame = 12

local function RunBloodTextureManager()
    if textureManagerRunning then
        return
    end

    textureManagerRunning = true
    task.spawn(function()
        local nextRotation = os.clock() + textureRotationInterval

        while enabled or #textures > 0 do
            task.wait(textureUpdateInterval)

            local now = os.clock()
            local rotateNow = enabled and now >= nextRotation
            if rotateNow then
                nextRotation = now + textureRotationInterval
            end

            for i = #textures, 1, -1 do
                local item = textures[i]
                local tex = item.Texture

                if not tex.Parent then
                    textures[i] = textures[#textures]
                    textures[#textures] = nil
                else
                    local age = now - item.CreatedAt
                    if age >= textureFadeDelay + textureFadeDuration then
                        tex:Destroy()
                        textures[i] = textures[#textures]
                        textures[#textures] = nil
                    else
                        if age >= textureFadeDelay then
                            local progress = math.clamp(
                                (age - textureFadeDelay) / textureFadeDuration,
                                0,
                                1
                            )
                            tex.Transparency = textureStartTransparency
                                + (1 - textureStartTransparency) * progress
                        end

                        if rotateNow and item.Session == textureSession then
                            tex.Rotation = rots[math.random(1, #rots)]
                        end
                    end
                end
            end
        end

        textureManagerRunning = false
    end)
end

function BloodRoom.Enable(room)
    if enabled or not room or not room.Parent then
        return
    end

    enabled = true
    textureSession += 1
    local currentSession = textureSession
    RunBloodTextureManager()

    task.spawn(function()
        local createdThisFrame = 0

        for _, part in ipairs(room:GetDescendants()) do
            if not enabled or textureSession ~= currentSession then
                break
            end

            if part:IsA("BasePart") and not (part.Transparency == 1 and part.CanCollide) then
                for _, face in ipairs(textureFaces) do
                    if not enabled or textureSession ~= currentSession or not part.Parent then
                        break
                    end

                    local tex = Instance.new("Texture")
                    tex.Texture = "rbxassetid://11306695974"
                    tex.Color3 = textureColor
                    tex.Face = face
                    tex.StudsPerTileU = 48
                    tex.StudsPerTileV = 48
                    tex.Transparency = textureStartTransparency
                    tex.Parent = part

                    table.insert(textures, {
                        Texture = tex,
                        CreatedAt = os.clock(),
                        Session = currentSession
                    })

                    createdThisFrame += 1
                    if createdThisFrame >= texturesPerFrame then
                        createdThisFrame = 0
                        bloodRunService.Heartbeat:Wait()
                    end
                end
            end
        end
    end)
end

function BloodRoom.Disable()
    if not enabled then
        return
    end

    enabled = false
    textureSession += 1

    for _, gui in ipairs(surfaceGuis) do
        if gui.Parent then
            gui:Destroy()
        end
    end

    table.clear(surfaceGuis)
end


local _call60 = _Idx57:FindFirstChildWhichIsA("BasePart")
local _CurrentRooms62 = workspace.CurrentRooms


local roomQueue = {}
local visited = {}
local running = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local camera = workspace.CurrentCamera


local function ImpactEffect()

	local player = Players.LocalPlayer
	local char = player.Character

	if not char then return end


	local hrp = char:FindFirstChild("HumanoidRootPart")
	local entityRoot = _Idx57.RushNew

	if not hrp or not entityRoot then return end


	local distance = (
		hrp.Position - entityRoot.Position
	).Magnitude


	local oldFov = camera.FieldOfView




	if distance <= 100 then

		local fovLock = true

		RunService:BindToRenderStep(
			"ForceImpactFOV",
			Enum.RenderPriority.Camera.Value + 5,
			function()
				if fovLock then
					camera.FieldOfView = 120
				end
			end
		)


		task.delay(0.25,function()

			fovLock = false

			RunService:UnbindFromRenderStep(
				"ForceImpactFOV"
			)


			local value = Instance.new("NumberValue")
			value.Value = 120


			value.Changed:Connect(function(v)
				camera.FieldOfView = v
			end)


			TweenService:Create(
				value,
				TweenInfo.new(
					2,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),
				{
					Value = oldFov
				}
			):Play()


			task.delay(2,function()
				value:Destroy()
			end)
		end)
	end





	if distance < 100 then



		local CameraShaker = require(game.ReplicatedStorage:WaitForChild("CameraShaker"))
local camera = workspace.CurrentCamera

local spawnShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end)

spawnShake:Start()

spawnShake:ShakeOnce(
	30,
	3,
	0.05,
	3,
	0,
	0.8
)


	else

local CameraShaker = require(game.ReplicatedStorage:WaitForChild("CameraShaker"))
local camera = workspace.CurrentCamera

local spawnShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end)

spawnShake:Start()

spawnShake:ShakeOnce(
	10,
	13,
	0.05,
	1,
	0,
	0.8
)

	end
end


local function addRoom(room)
	local number = tonumber(room.Name)

	if number and not visited[number] then
		visited[number] = true

		table.insert(roomQueue,{
			room = room,
			number = number
		})

		table.sort(roomQueue,function(a,b)
			return a.number < b.number
		end)
	end
end



for _,room in pairs(_CurrentRooms62:GetChildren()) do
	addRoom(room)
end



_CurrentRooms62.ChildAdded:Connect(function(room)
	addRoom(room)
end)

local function GetHighestRoom()
	local highest = -math.huge
	local result = nil

	for _,room in pairs(_CurrentRooms62:GetChildren()) do
		local num = tonumber(room.Name)

		if num and num > highest then
			highest = num
			result = room
		end
	end

	return result
end


local function SpawnInRoom(room)
if chasing then
	return true
end

currentEntityRoom = room

local highestRoom = GetHighestRoom()

if highestRoom == room then
	finalRoom = true
	stopChaseTrigger = true
	noChase = true
	chaseTrigger = false
end

	local parts = room:FindFirstChild("Parts")

	if not parts then
		return
	end

	local floor

repeat
	task.wait(0.1)

	local parts = room:FindFirstChild("Parts")

	if parts then
		floor = parts:FindFirstChild("Floor")
	end

until floor or not room.Parent


if not floor or not _call60 then
	return
end


	local target = floor.CFrame

	_call60.CFrame = target + Vector3.new(0,22,0)
	
	for _,v in ipairs(room:GetDescendants()) do
	if v:IsA("PointLight")
	or v:IsA("SpotLight")
	or v:IsA("SurfaceLight") then

		local originalBrightness = v.Brightness

		v.Brightness = originalBrightness * 3

		task.spawn(function()
			task.wait(0.5)

			local tween = TweenService:Create(
				v,
				TweenInfo.new(
					2,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),
				{
					Brightness = originalBrightness
				}
			)

			tween:Play()
		end)
	end
end
	
	local light = _Idx57.RushNew.PointLight
	light.Color = Color3.new(1, 1, 1)
	light.Range = 70
	light.Brightness = 5

	task.spawn(function()
		task.wait(0.5)

		local tween = TweenService:Create(
			light,
			TweenInfo.new(
				2,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Range = 0
			}
		)

		tween:Play()
		tween.Completed:Wait()
	end)
	
	task.spawn(ImpactEffect)


	local boom = _Idx57.RushNew.BOKKOMOFFHSJEJSJSJ
	local scream = _Idx57.RushNew.SCREAMOFFSILENCE


	local audioRunning = true
	local audioMode = nil

	task.spawn(function()
		while audioRunning and _Idx57.Parent and _Idx57:FindFirstChild("RushNew") do
			if ceaseFreezeActive then
				RunService.Heartbeat:Wait()
				continue
			end

			local character = Player.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			local distance = math.huge

			if hrp then
				distance = (hrp.Position - _Idx57.RushNew.Position).Magnitude
			end

			if distance <= NEAR_SOUND_DISTANCE then
				if audioMode ~= "near" then
					boom:Stop()
					scream:Stop()

					pcall(function()
						boom.TimePosition = 0
						scream.TimePosition = 0
					end)

					scream.Volume = 5
					scream:Play()
					audioMode = "near"
				end
			else
				local farVolume = GetFarVolume(distance)

				if audioMode ~= "far" then
					scream:Stop()
					boom:Stop()

					pcall(function()
						scream.TimePosition = 0
						boom.TimePosition = 0
					end)

					boom.Volume = 0.5 * farVolume
					boom:Play()
					audioMode = "far"
				else
					boom.Volume = 0.5 * farVolume
				end
			end

			RunService.Heartbeat:Wait()
		end

		boom:Stop()
		scream:Stop()
	end)


	local tween = CeaseTrackTween1(TweenService:Create(
		_call60,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			CFrame = target + Vector3.new(0,6,0)
		}
	))

	tween:Play()
	if ceaseFreezeActive then
		tween:Pause()
	end

task.spawn(function() 
tween.Completed:Wait()
if room == GetPlayerRoom() then
BloodRoom.Enable(room)
end
	
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if hrp then
		lockedCFrame = _call60.CFrame

				task.spawn(function()
			local watchingRoom = room

			while _Idx57.Parent 
			and not entityLocked 
			and not finalRoom 
			and not stopChaseTrigger do
				if ceaseFreezeActive then
					RunService.Heartbeat:Wait()
					continue
				end

				if currentEntityRoom ~= watchingRoom then
					break
				end


				if GetPlayerRoom() ~= watchingRoom and not chaseTrigger then
					task.wait()
					continue
				end
				

				if not finalRoom and chaseTrigger then
					chaseTrigger = false
					entityMoving = true
					entityLocked = false
					chasing = true



local hiding = false

task.spawn(function()
	local player = game.Players.LocalPlayer

	while chasing and _Idx57.Parent do
		local char = player.Character

		if char then
			hiding = char:GetAttribute("Hiding") ~= nil
		else
			hiding = false
		end

		task.wait()
	end
end)
				

task.spawn(function()
	CustomGitSound(
	"https://github.com/cakmay227-svg/random/raw/refs/heads/main/XRecorder_Edited_20260729_01.mp3?raw=true",
	1.5,
	25000,
	"COINTDON",
	"Boso",
	workspace,
	false,
	Enum.RollOffMode.Linear,
	10000
)
end)

local obj

repeat
	obj = workspace:FindFirstChild("Boso")
	task.wait()
until obj

obj:Play()

obj.Ended:Connect(function() 
obj:Destroy() 
end) 

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local old = PG:FindFirstChild("SilenceHeardGui")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "SilenceHeardGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.Parent = PG

local text = Instance.new("TextLabel")
text.Name = "HeardText"
text.AnchorPoint = Vector2.new(0.5, 0.5)
text.Position = UDim2.fromScale(0.5, 0.42)
text.Size = UDim2.fromOffset(700, 100)
text.BackgroundTransparency = 1
text.Text = "You were heard."
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
text.TextStrokeTransparency = 0.8
text.TextScaled = true
text.Font = Enum.Font.Oswald
text.Visible = false
text.ZIndex = 10
text.Parent = gui

local basePos = UDim2.fromScale(0.5, 0.42)

local renderConnection
local tweens = {}
local textToken = 0

local tint = Lighting:FindFirstChild("SilenceMonochromeTint")

if not tint then
	tint = Instance.new("ColorCorrectionEffect")
	tint.Name = "SilenceMonochromeTint"
	tint.Saturation = 0
	tint.Contrast = 0
	tint.Brightness = 0
	tint.TintColor = Color3.fromRGB(255, 255, 255)
	tint.Enabled = false
	tint.Parent = Lighting
end

local tintTween
local tintToken = 0

local function StopText()
	textToken += 1

	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	for _, t in ipairs(tweens) do
		t:Cancel()
	end

	table.clear(tweens)

	text.Visible = false
	text.Position = basePos
	text.Rotation = 0
	text.TextTransparency = 0.8
	text.TextStrokeTransparency = 0.8
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
end

local function StopTint(immediate)
	tintToken += 1

	local token = tintToken

	if tintTween then
		tintTween:Cancel()
		tintTween = nil
	end

	if immediate then
		tint.Saturation = 0
		tint.Contrast = 0
		tint.Brightness = 0
		tint.TintColor = Color3.fromRGB(255, 255, 255)
		tint.Enabled = false
	else
		tintTween = TweenService:Create(
			tint,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Saturation = 0,
				Contrast = 0,
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}
		)

		tintTween:Play()

		task.spawn(function()
			tintTween.Completed:Wait()

			if token == tintToken then
				tint.Enabled = false
				tintTween = nil
			end
		end)
	end
end

local function StartTint(red)
	tintToken += 1

	if tintTween then
		tintTween:Cancel()
		tintTween = nil
	end

	tint.Enabled = true
	tint.TintColor = red
		and Color3.fromRGB(255, 110, 110)
		or Color3.fromRGB(255, 255, 255)

	tintTween = TweenService:Create(
		tint,
		TweenInfo.new(0.01, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Saturation = 0.2,
			Contrast = 0.15,
			Brightness = 0.25
		}
	)

	tintTween:Play()
	tintTween.Completed:Wait()

	tintTween = TweenService:Create(
		tint,
		TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Saturation = -1,
			Contrast = 0.15,
			Brightness = -0.05
		}
	)

	tintTween:Play()
end

local function StartText(duration)
	textToken += 1

	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	for _, t in ipairs(tweens) do
		t:Cancel()
	end

	table.clear(tweens)

	text.Visible = true
	text.Position = basePos
	text.Rotation = 0
	text.TextTransparency = 0.8
	text.TextStrokeTransparency = 0.8
	text.TextColor3 = Color3.fromRGB(255, 255, 255)

	local started = os.clock()
	local token = textToken

	renderConnection = RunService.RenderStepped:Connect(function()
		if token ~= textToken then
			return
		end

		local progress = math.clamp(
			(os.clock() - started) / math.max(duration, 0.01),
			0,
			1
		)

		local offset = progress ^ 2 * 32 + 2
		local rotation = progress ^ 2 * 10 + 1

		text.Position = UDim2.new(
			basePos.X.Scale,
			basePos.X.Offset + math.random(-math.floor(offset), math.floor(offset)),
			basePos.Y.Scale,
			basePos.Y.Offset + math.random(-math.floor(offset), math.floor(offset))
		)

		text.Rotation = math.random(
			-math.floor(rotation),
			math.floor(rotation)
		)
	end)
end

local function LaunchText(red)
	textToken += 1

	local token = textToken

	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	for _, t in ipairs(tweens) do
		t:Cancel()
	end

	table.clear(tweens)

	if not text.Visible then
		return
	end

	text.Position = basePos
	text.Rotation = 0
	text.TextColor3 = Color3.fromRGB(255, 255, 255)

	local direction = math.random(1, 2) == 1 and -360 or 360

	local move = TweenService:Create(
		text,
		TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Position = UDim2.fromScale(0.5, 0.32)
		}
	)

	table.insert(tweens, move)
	move:Play()

	local color = TweenService:Create(
		text,
		TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Rotation = direction,
			TextColor3 = red
				and Color3.fromRGB(255, 70, 70)
				or Color3.fromRGB(205, 170, 255)
		}
	)

	table.insert(tweens, color)
	color:Play()

	task.spawn(function()
		move.Completed:Wait()

		if token ~= textToken then
			return
		end

		local exit = TweenService:Create(
			text,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
			{
				Position = UDim2.fromScale(0.5, 1.2)
			}
		)

		table.insert(tweens, exit)
		exit:Play()

		exit.Completed:Wait()

		if token == textToken then
			text.Visible = false
		end
	end)
end

local function Reset()
	StopText()
	StopTint(true)
end

local function SetupCharacter(char)
	local hum = char:WaitForChild("Humanoid")

	hum.Died:Connect(function()
		Reset()
	end)
end

if LP.Character then
	task.spawn(SetupCharacter, LP.Character)
end

LP.CharacterAdded:Connect(function(char)
	Reset()
	SetupCharacter(char)
end)


local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")

task.spawn(function() 
if hum and hum.Health > 0 then
	StartText(3)

	task.wait(3)

	LaunchText(false)
	StartTint(false)
end
end) 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "HeardGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = false
gui.Parent = PlayerGui

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.new(0.5, 0, 0.35, 0)
label.Size = UDim2.new(0, 650, 0, 85)
label.BackgroundTransparency = 1
label.Text = "You were heard."
label.TextTransparency = 0.65
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.FontFace = Font.new(
	"rbxasset://fonts/families/Oswald.json",
	Enum.FontWeight.Regular,
	Enum.FontStyle.Normal
)
label.Parent = gui



local basePos = UDim2.new(0.5, 0, 0.35, 0)

local shakeValue = Instance.new("NumberValue")
shakeValue.Value = 0

local posRange = Instance.new("NumberValue")
posRange.Value = 4

task.delay(0, function()
	TweenService:Create(
		posRange,
		TweenInfo.new(
			3.5,
			Enum.EasingStyle.Linear
		),
		{
			Value = 11
		}
	):Play()
end)

local shaking = true

task.delay(0, function()
	local tween = TweenService:Create(
		shakeValue,
		TweenInfo.new(
			2.8,
			Enum.EasingStyle.Linear
		),
		{
			Value = 6
		}
	)

	tween:Play()

	tween.Completed:Wait()

	task.wait(0)

	shaking = false

	local rotateTween = TweenService:Create(
	label,
	TweenInfo.new(
		0.25,
		Enum.EasingStyle.Exponential,
		Enum.EasingDirection.Out
	),
	{
		Rotation = 140,
		Position = UDim2.new(
			basePos.X.Scale,
			0,
			basePos.Y.Scale - 0.1,
			0
		)
	}
)

rotateTween:Play()

local cc = Instance.new("ColorCorrectionEffect")
cc.Brightness = 0
cc.Parent = game:GetService("Lighting")

task.delay(0.1, function()
	local brightnessTween = TweenService:Create(
		cc,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Brightness = 0
		}
	)

	brightnessTween:Play()

	brightnessTween.Completed:Wait()
	cc:Destroy()
end)

rotateTween.Completed:Wait()

	local exitTween = TweenService:Create(
		label,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Exponential,
			Enum.EasingDirection.In
		),
		{
			Rotation = 160,
			Position = UDim2.new(0.5, 0, 1.5, 0)
		}
	)



local char = Players.LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")

if hrp then
	local oldY = _call60.Position.Y
	local speed = 20
	
	local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

	task.spawn(function()
		while _Idx57.Parent and entityMoving and not noChase do

			local target = Vector3.new(
				hrp.Position.X,
				oldY,
				hrp.Position.Z
			)

			local current = _call60.Position

			local direction = target - current
			local distance = direction.Magnitude

			if distance < 3 and not noChase and not ceaseFreezeActive then
ceaseInteractionActive = true

if not hiding then
tint:Destroy() 
end

	if hiding then
chasing = false
	noChase = true
	entityMoving = false

		function GitAud(soundgit, filename)
	local file = filename..".mp3"

	if not isfile(file) then
		writefile(file, game:HttpGet(soundgit))
	end

	return (getcustomasset or getsynasset)(file)
end

local function GetGitSound(GithubSnd, SoundName)
	local url = GithubSnd
	if not isfile(SoundName .. ".ogg") then
		writefile(SoundName .. ".ogg", game:HttpGet(url))
	end
	local sound = Instance.new("Sound")
	sound.SoundId = (getcustomasset or getsynasset)(SoundName .. ".ogg")
	return sound
end

tint:Destroy()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local model = LoadModel(
		"silencismjjjdjdj.txt",
		"https://raw.githubusercontent.com/lynguyen26031993-design/-u/refs/heads/main/Place_131351567799504_Model_Silence_1785827465.txt"
	)
	
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

model.Parent = workspace

local cf = hrp.CFrame * CFrame.new(0, 0, -4)

if model:IsA("Model") then
	if not model.PrimaryPart then
		model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart", true)
	end

	if model.PrimaryPart then
		model:PivotTo(cf)
	end
elseif model:IsA("BasePart") then
	model.CFrame = cf
end

for _, v in ipairs(model:GetDescendants()) do
	if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
		v.Enabled = false

		v:GetPropertyChangedSignal("Enabled"):Connect(function()
			if v.Enabled then
				v.Enabled = false
			end
		end)
	end
end

local HiddenUI = {}

local FadeProperties = {
	TextLabel = {
		"TextTransparency",
		"TextStrokeTransparency",
		"BackgroundTransparency"
	},
	TextButton = {
		"TextTransparency",
		"TextStrokeTransparency",
		"BackgroundTransparency"
	},
	TextBox = {
		"TextTransparency",
		"TextStrokeTransparency",
		"BackgroundTransparency"
	},
	ImageLabel = {
		"ImageTransparency",
		"BackgroundTransparency"
	},
	ImageButton = {
		"ImageTransparency",
		"BackgroundTransparency"
	},
	Frame = {
		"BackgroundTransparency"
	},
	ScrollingFrame = {
		"BackgroundTransparency",
		"ScrollBarImageTransparency"
	},
	ViewportFrame = {
		"BackgroundTransparency"
	},
	UIStroke = {
		"Transparency"
	}
}

local function FadePlayerGui(time, fadeOut)
	for _, obj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
		if obj:IsDescendantOf(gui) then
			continue
		end

		local props = FadeProperties[obj.ClassName]

		if props then
			local goal = {}

			if fadeOut then
				if not HiddenUI[obj] then
					HiddenUI[obj] = {}

					for _, prop in ipairs(props) do
						pcall(function()
							HiddenUI[obj][prop] = obj[prop]
						end)
					end
				end

				for _, prop in ipairs(props) do
					goal[prop] = 1
				end
			elseif HiddenUI[obj] then
				for prop, value in pairs(HiddenUI[obj]) do
					goal[prop] = value
				end
			end

			if next(goal) then
				TweenService:Create(
					obj,
					TweenInfo.new(time),
					goal
				):Play()
			end
		end
	end

	if not fadeOut then
		table.clear(HiddenUI)
	end
end

FadePlayerGui(3, true)

local Active = true


function CustomGitSound(soundlink, volume, distance, filename, soundName, parent, looped, mode, emitter)
	local sound = Instance.new("Sound")

	sound.SoundId = GitAud(soundlink, filename)
	sound.Parent = parent or workspace

	sound.Volume = volume or 1

	sound.RollOffMaxDistance = distance or 100
	sound.RollOffMinDistance = 5

	if mode then
		sound.RollOffMode = mode
	end

	sound.EmitterSize = emitter or 100000

	sound.PlaybackSpeed = 1
	sound.Name = soundName or "bgtheme"
	sound.Looped = looped or false

	return sound
end

local beat = Instance.new("Sound") 
beat.SoundId = "rbxassetid://135454814111440" 
beat.Volume = 1
beat.Parent = workspace

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "HeartbeatEffect"
cc.Brightness = 0
cc.Saturation = 0
cc.Contrast = 0
cc.TintColor = Color3.fromRGB(255,255,255)
cc.Parent = Lighting

local tween = TweenService:Create(
	cc,
	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{
		Brightness = -0.5,
		Saturation = -1,
		Contrast = 0.2
	}
)

tween:Play()

task.spawn(function()
	CustomGitSound(
	"https://github.com/cakmay227-svg/random/raw/refs/heads/main/XRecorder_Edited_20260729_02.mp3",
	1,
	25000,
	"JEARBT",
	"Heartbeattest",
	workspace,
	false,
	Enum.RollOffMode.Linear,
	10
)
end)

task.spawn(function()
	CustomGitSound(
	"https://github.com/cakmay227-svg/random/raw/refs/heads/main/XRecorder_Edited_20260729_03.mp3",
	0.7,
	1000000,
	"THEMEOFFTHESIOENCE",
	"DSJDJDJDjc",
	workspace,
	true,
	Enum.RollOffMode.Linear,
	10
)
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

local Cleanup
local CanHit
local NextBeat
local Hits

local gui = Instance.new("ScreenGui")
gui.Name = "HeartbeatText"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local function Failsafe()
	if not Active then
		return
	end

	Active = false
	CanHit = false

	if connection then
		connection:Disconnect()
		connection = nil
	end


		
		task.spawn(function() 
local jum = GetGitSound("https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Attann%20(1).mp3?raw=true","polxladdks")
jum.Parent = workspace
jum.Volume = 1
jum.Name = "pppkkkkkksskhch" 
jum.PlaybackSpeed = 1
jum.RollOffMaxDistance = 12000000
jum:Play() 

jum.Ended:Connect(function() 
jum:Destroy() 
end) 
end) 

FadePlayerGui(0, false)

local player = game.Players.LocalPlayer
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

if humanoid then
	humanoid:TakeDamage(400)
end

        game.ReplicatedStorage.GameStats['Player_' .. game.Players.LocalPlayer.Name].Total.DeathCause.Value = 'Silence'
		
		model:Destroy() 
		theme:Destroy() 
		
		cc:Destroy() 
		gui:Destroy() 
	end

task.spawn(function()
	while Active do


		local char = game.Players.LocalPlayer.Character

		if not char then
			Failsafe() 
			break
		end

		local collision

		for _, v in ipairs(char:GetDescendants()) do
			if v.Name == "CollisionPart" and v:IsA("BasePart") then
				collision = v
				break
			end
		end

		if collision and not collision.Anchored then
			Failsafe() 
			break
		end

		task.wait()
	end
end)

local function createText(pos, size, value)
	local text = Instance.new("TextLabel")
	text.Parent = gui

	text.AnchorPoint = Vector2.new(0.5, 0.5)
	text.Position = pos
	text.Size = size

	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.fromRGB(161,161,161)

	text.Font = Enum.Font.Oswald
	text.TextSize = 70

	text.TextXAlignment = Enum.TextXAlignment.Center
	text.TextYAlignment = Enum.TextYAlignment.Center

	text.TextStrokeTransparency = 0.8
	text.TextStrokeColor3 = Color3.fromRGB(0,0,0)

	text.Text = ""

	for i = 1, #value do
		text.Text = string.sub(value, 1, i)
		task.wait(0.03)
	end

	return text
end

createText(
	UDim2.new(0.5,0,0.30,0),
	UDim2.new(0.5,0,0.1,0),
	"Keep your heartbeat still."
)

task.wait(1)

local image = Instance.new("ImageLabel")
image.Parent = gui

image.AnchorPoint = Vector2.new(0.5,0.5)
image.Size = UDim2.new(0.35,0,0.35,0)
image.Name = "Heartbeat" 
image.Position = UDim2.new(0.5,0,1.5,0)

image.BackgroundTransparency = 1
image.Image = "rbxassetid://132760197509952"
image.ImageColor3 = Color3.fromRGB(200,200,200)

local ratio = Instance.new("UIAspectRatioConstraint")
ratio.Parent = image

local tween = TweenService:Create(
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

tween:Play()

task.wait(2)

local secondText = createText(
	UDim2.new(0.5,0,0.45,0),
	UDim2.new(0.5,0,0.1,0),
	"She won't detect you."
)

task.wait(1)

for _,v in pairs(gui:GetChildren()) do
	if v:IsA("TextLabel") then
		v:Destroy()
	end
end

local clone = Instance.new("ImageLabel")
clone.Parent = gui

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
listen.Parent = gui

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
number.Parent = gui

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

local demoPattern = {}

-- 随机节奏等级：0 = 短间隔，1 = 中间隔，2 = 长间隔
for i = 1, 6 do
	demoPattern[i] = math.random(0, 2)
end

local function GetDemoDelay(level)
	return 0.30 + (level * 0.18)
end

task.spawn(function()
	local count = 6

	for beatIndex = 1, 6 do
		task.wait(GetDemoDelay(demoPattern[beatIndex]))

		if not Active then
			return
		end

		if beatIndex > 1 then
			count -= 1
			number.Text = tostring(count)
		end

		HeartBeat()
	end

	task.wait(0.3)

	if count == 1 then
		local fade = TweenService:Create(
			number,
			TweenInfo.new(
				0.3,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				TextTransparency = 1
			}
		)

		fade:Play()

		listen.Text = "Keep the beat."

		local hint = Instance.new("TextLabel")
		hint.Parent = gui

		hint.AnchorPoint = Vector2.new(0.5,0.5)
		hint.Position = UDim2.new(1.5,0,image.Position.X.Offset,image.Position.Y.Offset)
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


		hint.Position = UDim2.new(1.5,0,image.Position.Y.Scale,0)

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
		image.Position.Y.Scale,
		0
	)
}
)

move:Play()
move.Completed:Wait()

task.wait(1)

local UserInputService = game:GetService("UserInputService")

task.spawn(function()
local BeatDelay = 0.65
local Tolerance = 0.14

Hits = 0
NextBeat = tick() + BeatDelay
CanHit = false

task.delay(BeatDelay - Tolerance, function()
if Active then
	CanHit = true
end
end)

task.spawn(function()
while Active do
	if CanHit and tick() > NextBeat + Tolerance then
		Fail()
		break
	end

	task.wait()
end
end)

local connection

Cleanup = function()
Active = false

if connection then
	connection:Disconnect()
end

FadePlayerGui(1, false)

task.delay(1, function()
	if gui then
		gui:Destroy()
	end
end)
end

Fail = function()
if not Active then
	return
end

Active = false
CanHit = false

if connection then
	connection:Disconnect()
	connection = nil
end


	
	task.spawn(function() 
local jum = GetGitSound("https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Attann%20(1).mp3?raw=true","pjxnapllkxddddjd")
jum.Parent = workspace
jum.Volume = 1
jum.Name = "jncjkskkxkkkdjdh" 
jum.PlaybackSpeed = 1
jum.RollOffMaxDistance = 12000000
jum:Play() 

jum.Ended:Connect(function() 
jum:Destroy() 
end) 
end) 

local player = game.Players.LocalPlayer
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

if humanoid then
humanoid:TakeDamage(1000)
end

        game.ReplicatedStorage.GameStats['Player_' .. game.Players.LocalPlayer.Name].Total.DeathCause.Value = 'Silence'
	
	model:Destroy() 
	theme:Destroy() 
	
	cc:Destroy() 
	Cleanup()
end

local function Success()
	if not Active or not CanHit then
		return
	end
	
	noChase = false
	entityMoving = false

	CanHit = false

	Hits += 1

	HeartBeat()

	if Hits >= 6 then
		Active = false

		listen.Text = "Steady."

image.ImageColor3 = Color3.fromRGB(140,244,255)
clone.ImageColor3 = Color3.fromRGB(140,244,255)

local hideHint = TweenService:Create(
hint,
TweenInfo.new(
	0.25,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.InOut
),
{
	Position = UDim2.new(
		1.5,
		0,
		image.Position.Y.Scale,
		0
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
	Position = UDim2.new(0.5,0,1.5,0)
}
):Play()

TweenService:Create(
clone,
TweenInfo.new(0.5),
{
	Position = UDim2.new(0.5,0,1.5,0)
}
):Play()

listen:Destroy()

task.spawn(function() 
local despawn = silenceSource:Clone()
despawn.Name = "DESPAWN"
despawn:Stop()
despawn.TimePosition = 0
despawn.Volume = 0.35
despawn.PlaybackSpeed = 1
despawn.Looped = false
despawn.RollOffMaxDistance = 12000000
despawn.Parent = workspace
despawn.Ended:Once(function()
    if despawn.Parent then
        despawn:Destroy()
    end
end)
game:GetService("Debris"):AddItem(despawn, 30)
despawn:Play() 
end) 

model:Destroy() 
theme:Destroy() 

task.wait(0.5)

Cleanup()

local ccTween = TweenService:Create(
cc,
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

ccTween:Play()
ccTween.Completed:Wait()

cc:Destroy()

return
	end

	NextBeat += BeatDelay

CanHit = false

task.delay(BeatDelay - Tolerance, function()
if Active then
	CanHit = true
end
end)
end

connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not Active then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Keyboard then

		if not CanHit then
			return
		end

		local Diff = math.abs(tick() - NextBeat)

		if Diff <= Tolerance then
			Success()
		else
			Fail()
		end
	end
end)
end)

	end
end)
break
	else
	
	chasing = false
	
	task.spawn(function()
	
local Jumpscare = GetGitSound("https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Attann%20(1).mp3?raw=true","pkkcllalllkkxjjd")
Jumpscare.Parent = workspace
Jumpscare.Volume = 1
Jumpscare.Name = "bla" 
Jumpscare.PlaybackSpeed = 1
Jumpscare:Play()

Jumpscare.Ended:Connect(function() 
Jumpscare:Destroy() 
end) 
end)
	
	local player = game.Players.LocalPlayer
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

if humanoid then
	humanoid:TakeDamage(1000)
end

local cc = game:GetService("Lighting"):FindFirstChild("NoColor")
if cc then
	cc:Destroy()
end

        game.ReplicatedStorage.GameStats['Player_' .. game.Players.LocalPlayer.Name].Total.DeathCause.Value = 'Silence'

	end
	break
end

			local deltaTime = RunService.Heartbeat:Wait()
			local step = math.min(
				speed * deltaTime * ceaseSpeedScale,
				distance
			)

			_call60.CFrame = CFrame.new(
				current + direction.Unit * step
			)
			
			

		end
		
		_Idx57:Destroy()
		task.spawn(function() 
CheckNoHidingCount()
end) 
		entityMoving = false
	end)
end
end)
					
					entityLocked = true
					
					lockedCFrame = _call60.CFrame
					
					break
				end
				
				task.wait()
			end
		end)
end
end) 


		if room == GetPlayerRoom() then
		CeaseWait1(6)
	else
		CeaseWait1(2.5)
	end


audioRunning = false
boom:Stop()
scream:Stop()

pcall(function()
	boom.TimePosition = 0
	scream.TimePosition = 0
end)

BloodRoom.Disable()


if chasing then

	else
	local upTween = CeaseTrackTween1(TweenService:Create(
		_call60,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			CFrame = _call60.CFrame + Vector3.new(0,22,0)
		}
	))

	upTween:Play()
	if ceaseFreezeActive then
		upTween:Pause()
	end
	upTween.Completed:Wait()
	
	currentEntityRoom = nil
end

if entityLocked then
	
	_call60.CFrame = lockedCFrame
	
	while entityLocked do
		task.wait()
	end
	
end

local highestRoom = GetHighestRoom()

if highestRoom == room then
finalRoom = true

stopChaseTrigger = true
chaseTrigger = false
noChase = true

	entityMoving = false
	chasing = false
	entityLocked = false

	for _,v in pairs(_Idx57:GetDescendants()) do
		if v:IsA("Sound") then
			v:Stop()
		end

		if v:IsA("Tween") then
			pcall(function()
				v:Cancel()
			end)
		end
	end


	RunService:UnbindFromRenderStep(
		"ForceImpactFOV"
	)

	RunService:UnbindFromRenderStep(
		"EntityImpactShake"
	)


_call60.Anchored = true
noChase = true
chaseTrigger = false
entityMoving = false
chasing = false
entityLocked = false
_Idx57:Destroy()

task.spawn(function() 
CheckNoHidingCount()
end) 

return true
end
end



local function Start()
	if running then return end
	running = true

	while true do
		local data = table.remove(roomQueue,1)

		if data then
			local destroyed = SpawnInRoom(data.room)

			if destroyed then
				break
			end

			CeaseWait1(1)
		else
			task.wait(0.1)
		end
	end
end
task.spawn(Start)
end

function entityBehaviors.MONTNS()
local concrete = workspace.MonumentEntity.Top.Concrete
local decal = Instance.new("Decal")
decal.Texture = "rbxassetid://155213173"
decal.Parent = concrete
end

function entityBehaviors.bsrebound()
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local function hideOtherPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then

            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part:IsA("Accessory") then

                    local handle = part:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then
                        handle.Transparency = 1
                    end
                end
            end

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then

                for _, clothing in pairs(humanoid:GetChildren()) do
                    if clothing:IsA("ShirtGraphic") or clothing:IsA("Shirt") or clothing:IsA("Pants") then
                        clothing:Destroy()
                    elseif clothing:IsA("CharacterMesh") then
                        clothing:Destroy()
                    end
                end
            end

            local head = player.Character:FindFirstChild("Head")
            if head then
                local nameTag = head:FindFirstChildOfClass("BillboardGui")
                if nameTag then
                    nameTag.Enabled = false
                end
            end
        end
    end
end

hideOtherPlayers()

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(0.1)
        if player ~= LocalPlayer then

            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part:IsA("Accessory") then

                    local handle = part:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then
                        handle.Transparency = 1
                    end
                end
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then

                for _, clothing in pairs(humanoid:GetChildren()) do
                    if clothing:IsA("ShirtGraphic") or clothing:IsA("Shirt") or clothing:IsA("Pants") then
                        clothing:Destroy()
                    elseif clothing:IsA("CharacterMesh") then
                        clothing:Destroy()
                    end
                end
            end

            local head = character:FindFirstChild("Head")
            if head then
                local nameTag = head:FindFirstChildOfClass("BillboardGui")
                if nameTag then
                    nameTag.Enabled = false
                end
            end
        end
    end)
end)

local originalAtmosphere = nil
local hasOriginalAtmosphere = false

for _, child in pairs(Lighting:GetChildren()) do
    if child:IsA("Atmosphere") then
        originalAtmosphere = child:Clone() 
        hasOriginalAtmosphere = true
        break
    end
end

local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalFogColor = Lighting.FogColor
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalBrightness = Lighting.Brightness

if hasOriginalAtmosphere then
    Lighting:WaitForChild("Atmosphere"):Destroy()
end

local fogAtmosphere = Instance.new("Atmosphere")
fogAtmosphere.Name = "ZeroVisibilityFog"
fogAtmosphere.Density = 1.0
fogAtmosphere.Offset = 0.3
fogAtmosphere.Color = Color3.fromRGB(220, 225, 230)
fogAtmosphere.Decay = Color3.fromRGB(5, 5, 8)
fogAtmosphere.Glare = 0.2
fogAtmosphere.Haze = 0.9
fogAtmosphere.Parent = Lighting

Lighting.Ambient = Color3.fromRGB(90, 95, 105)
Lighting.OutdoorAmbient = Color3.fromRGB(70, 75, 85)
Lighting.Brightness = 1.2
Lighting.FogStart = 0
Lighting.FogEnd = 50
Lighting.FogColor = Color3.fromRGB(200, 205, 210)

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9113731836"
sound.Volume = 1
sound.Parent = SoundService
sound:Play()

while true do
    if not sound.IsPlaying then
        sound:Play()
    end
    wait(sound.TimeLength)
end

wait(500)

sound:Stop()
sound:Destroy()

fogAtmosphere:Destroy()

Lighting.Ambient = originalAmbient
Lighting.OutdoorAmbient = originalOutdoorAmbient
Lighting.Brightness = originalBrightness
Lighting.FogStart = originalFogStart
Lighting.FogEnd = originalFogEnd
Lighting.FogColor = originalFogColor

if hasOriginalAtmosphere and originalAtmosphere then
    originalAtmosphere.Parent = Lighting
end
end

function entityBehaviors.bsfigure()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local target = Players:FindFirstChild("sppvve")
if not target then
    return
end

local walkAnimationId = "rbxassetid://18570699250"
local idleAnimationId = "rbxassetid://18540813605"
local walkAnimationTrack = nil
local idleAnimationTrack = nil
local isMoving = false
local lastPosition = nil
local moveThreshold = 0.013

local function makePlayerTransparent(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
    end
end

if target.Character then
    makePlayerTransparent(target.Character)
end

target.CharacterAdded:Connect(function(character)
    wait(0.62)
    makePlayerTransparent(character)
end)

local model = ReplicatedStorage:FindFirstChild("deer")

if not model then
    local success, loadedModel = pcall(function()
        return game:GetObjects("rbxassetid://12576230222")[1]
    end)
    
    if success and loadedModel then
        model = loadedModel
        model.Name = "Figurenow"
        model.Parent = ReplicatedStorage
    else
        return
    end
end

local mainFigurenow = model:Clone()
mainFigurenow.Parent = workspace

if not mainFigurenow.PrimaryPart then
    for _, part in pairs(mainFigurenow:GetDescendants()) do
        if part:IsA("BasePart") then
            mainFigurenow.PrimaryPart = part
            break
        end
    end
end

if not mainFigurenow.PrimaryPart then
    return
end

local function setupAnimationsInFigurenowHumanoid(parentModel)
    local humanoid = parentModel:FindFirstChild("Humanoid")
    if not humanoid then
        return nil, nil
    end
    
    local animator = humanoid:FindFirstChildWhichIsA("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    
    local walkAnimation = Instance.new("Animation")
    walkAnimation.AnimationId = walkAnimationId
    local idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = idleAnimationId
    
    local walkSuccess, walkTrack = pcall(function()
        return animator:LoadAnimation(walkAnimation)
    end)
    
    local idleSuccess, idleTrack = pcall(function()
        return animator:LoadAnimation(idleAnimation)
    end)
    
    if walkSuccess and walkTrack then
        walkTrack.Looped = true
    else
        walkTrack = nil
    end
    
    if idleSuccess and idleTrack then
        idleTrack.Looped = true
    else
        idleTrack = nil
    end
    
    return walkTrack, idleTrack
end

walkAnimationTrack, idleAnimationTrack = setupAnimationsInFigurenowHumanoid(mainFigurenow)

local heightOffset = 3.5

RunService.Heartbeat:Connect(function()
    if not target or not target.Character then
        return
    end
    
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    
    local currentPosition = humanoidRootPart.Position
    if lastPosition then
        local distance = (currentPosition - lastPosition).Magnitude
        local nowMoving = distance > moveThreshold
        
        if nowMoving and not isMoving then
            isMoving = true
            if walkAnimationTrack then
                walkAnimationTrack:Play()
            end
            if idleAnimationTrack then
                idleAnimationTrack:Stop()
            end
        elseif not nowMoving and isMoving then
            isMoving = false
            if walkAnimationTrack then
                walkAnimationTrack:Stop()
            end
            if idleAnimationTrack then
                idleAnimationTrack:Play()
            end
        end
    else
        if idleAnimationTrack then
            idleAnimationTrack:Play()
        end
    end
    
    lastPosition = currentPosition
    
    local targetPosition = humanoidRootPart.Position
    local headPosition = targetPosition + Vector3.new(0, heightOffset, 0)
    local targetRotation = humanoidRootPart.CFrame.Rotation
    local newCFrame = CFrame.new(headPosition) * targetRotation
    
    if mainFigurenow.PrimaryPart then
        mainFigurenow:SetPrimaryPartCFrame(newCFrame)
    end
end)
end

function entityBehaviors.bsripper()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

if Workspace:FindFirstChild("hardcoreInit") then
    return
end

local hardcoreInit = Instance.new("BoolValue")
hardcoreInit.Name = "hardcoreInit"
hardcoreInit.Parent = Workspace

do
    local storage = game:GetService("ReplicatedStorage")
    local misc = storage:FindFirstChild("Misc") or storage:WaitForChild("Misc", 10)

    if misc then
        local original = misc:FindFirstChild("Eyes")

        local loaded, replacement = pcall(function()
            local objects = game:GetObjects("rbxassetid://135846563766272")
            local asset = objects and objects[1]

            if not asset then
                return nil
            end

            local source

            if asset.Name == "Eyes" and (asset:IsA("Folder") or asset:IsA("Model")) then
                source = asset
            else
                for _, descendant in ipairs(asset:GetDescendants()) do
                    if descendant.Name == "Eyes"
                        and (descendant:IsA("Folder") or descendant:IsA("Model")) then
                        source = descendant
                        break
                    end
                end
            end

            if not source then
                asset:Destroy()
                return nil
            end

            source.Parent = nil

            if source ~= asset then
                asset:Destroy()
            end

            if source:IsA("Folder") then
                source.Name = "Eyes"
                return source
            end

            local folder = Instance.new("Folder")
            folder.Name = "Eyes"

            for _, child in ipairs(source:GetChildren()) do
                child.Parent = folder
            end

            source:Destroy()
            return folder
        end)

        if loaded and replacement then
            replacement.Name = "Eyes"

            local installed = pcall(function()
                replacement.Parent = misc
            end)

            if installed then
                if original and original ~= replacement then
                    original:Destroy()
                end
            else
                replacement:Destroy()
            end
        end
    end
end

local LocalPlayer = Players.LocalPlayer
local GameData = ReplicatedStorage:WaitForChild("GameData")
local LatestRoom = GameData:WaitForChild("LatestRoom")

local targetAudioUrl = "https://github.com/Sosnen/Ping-s-Dumbass-projects-/raw/main/Here%20i%20come%20but%20WHAT%20THE%20FUCK.mp3"
local newFileName = "SeekMusicNew"
local volume = 5

local CUSTOM_SEEK_MODEL_ID = "rbxassetid://113994392427255"
local CUSTOM_SEEK_RUN_ANIMATION_ID = "rbxassetid://10729087054"
local CUSTOM_SEEK_RAISE_ANIMATION_ID = "rbxassetid://10954733643"

local seekMusicAsset = nil
local audioLoaded = false
local audioLoading = false

local currentCustomSeek = nil
local currentContext = nil

local pendingSeeks = setmetatable({}, {__mode = "k"})
local processedSeeks = setmetatable({}, {__mode = "k"})

local function applySeekMusic(sound)
    if not sound or not sound:IsA("Sound") then
        return
    end

    if sound.Name ~= "SeekMusic" then
        return
    end

    if not sound.Parent then
        return
    end

    if sound.Parent.Name ~= "SeekMovingNewClone" then
        return
    end

    sound.Volume = volume

    if audioLoaded and seekMusicAsset then
        sound.SoundId = seekMusicAsset
    end
end

local function loadAudioFromGitHub()
    if audioLoading or audioLoaded then
        return
    end

    audioLoading = true

    task.spawn(function()
        local success, result = pcall(function()
            local audioData = game:HttpGet(targetAudioUrl)

            writefile(newFileName .. ".mp3", audioData)

            local assetLoader = getcustomasset or getsynasset

            return assetLoader(newFileName .. ".mp3")
        end)

        audioLoading = false

        if success and result then
            seekMusicAsset = result
            audioLoaded = true

            for _, descendant in ipairs(Workspace:GetDescendants()) do
                applySeekMusic(descendant)
            end
        end
    end)
end

local function replaceSeekMusic()
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") then
            applySeekMusic(descendant)

            if descendant.Name == "SeekMusic"
                and descendant.Parent
                and descendant.Parent.Name == "SeekMovingNewClone" then

                if not audioLoaded then
                    loadAudioFromGitHub()
                end
            end
        end
    end)

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        applySeekMusic(descendant)
    end
end

local function showChaseCaption()
    pcall(function()
        require(
            LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game
        ).caption("使用你的体力!!!", true)
    end)
end

local function playCustomSeekSounds(context)
    if not context.active then
        return
    end

    local customSeekModel = context.customSeek

    if not customSeekModel or not customSeekModel.Parent then
        return
    end

    local figure = customSeekModel:FindFirstChild("Figure")

    if not figure then
        return
    end

    for _, child in ipairs(figure:GetChildren()) do
        if child:IsA("Sound") then
            child:Play()
        end
    end
end

local function cleanupOldSeekModel(context)
    if not context then
        return
    end

    context.active = false
    if context.roomConnection then
        context.roomConnection:Disconnect()
        context.roomConnection = nil
    end

    if context.followConnection then
        context.followConnection:Disconnect()
        context.followConnection = nil
    end

    if context.ancestryConnection then
        context.ancestryConnection:Disconnect()
        context.ancestryConnection = nil
    end

    if context.customSeek and context.customSeek.Parent then
        context.customSeek:Destroy()
    end

    if currentCustomSeek == context.customSeek then
        currentCustomSeek = nil
    end

    if currentContext == context then
        currentContext = nil
    end
end

local function playSeekAnimations(context)
    task.spawn(function()
        local customRig = context.customRig

        if not customRig then
            return
        end

        local animController = customRig:FindFirstChildOfClass("AnimationController")
            or customRig:FindFirstChildOfClass("Humanoid")
        if not animController or not context.active then
            return
        end

        local animator = animController:FindFirstChildOfClass("Animator")
            or animController

        pcall(function()
            local raiseAnimation = Instance.new("Animation")
            raiseAnimation.AnimationId = CUSTOM_SEEK_RAISE_ANIMATION_ID
            raiseAnimation.Parent = customRig

            local raiseAnim = animator:LoadAnimation(raiseAnimation)
            if not context.active then
                return
            end

            raiseAnim.Looped = false
            raiseAnim:Play()
            raiseAnim.Stopped:Wait()

            if not context.active then
                return
            end

            local runAnimation = Instance.new("Animation")
            runAnimation.AnimationId = CUSTOM_SEEK_RUN_ANIMATION_ID
            runAnimation.Parent = customRig

            local runAnim = animator:LoadAnimation(runAnimation)
            if context.active then
                runAnim.Looped = true
                runAnim:Play()
            end
        end)
    end)
end

local function playDelayedSeekSounds(context)
    task.delay(7, function()
        if not context.active or not context.originalSeek.Parent then
            return
        end

        local customSeekModel = context.customSeek

        if not customSeekModel or not customSeekModel.Parent then
            return
        end

        local figure = customSeekModel:FindFirstChild("Figure")

        if not figure then
            return
        end

        local soundNames = {
            "FootstepsFar",
            "Footsteps",
            "Splashing",
            "Splashing Far"
        }

        for _, soundName in ipairs(soundNames) do
            local sound = figure:FindFirstChild(soundName)

            if sound and sound:IsA("Sound") then
                sound:Play()
            end
        end
    end)
end

local function waitForSeekChase(context)
    task.spawn(function()
        local originalSeek = context.originalSeek

        while context.active and originalSeek.Parent do
            local seekMusic = originalSeek:FindFirstChild("SeekMusic")

            if seekMusic and seekMusic:IsA("Sound") and seekMusic.IsPlaying then
                context.roomConnection = LatestRoom.Changed:Connect(function()
                    if context.roomConnection then
                        context.roomConnection:Disconnect()
                        context.roomConnection = nil
                    end

                    if not context.active or not originalSeek.Parent or not context.customSeek.Parent then
                        return
                    end

                    showChaseCaption()
                    playCustomSeekSounds(context)
                end)

                playDelayedSeekSounds(context)
                playSeekAnimations(context)

                return
            end

            task.wait(0.1)
        end
    end)
end

local function replaceSeekModel(originalSeek)
    if not originalSeek or not originalSeek.Parent then
        return
    end

    if processedSeeks[originalSeek] then
        return
    end

    local originalRig = originalSeek:FindFirstChild("SeekRig")

    if not originalRig then
        return
    end

    local originalRoot = originalRig:FindFirstChild("Root")

    if not originalRoot then
        return
    end

    local customSeekModel

    local success = pcall(function()
        customSeekModel = game:GetObjects(CUSTOM_SEEK_MODEL_ID)[1]
    end)

    if not success or not customSeekModel then
        return
    end

    if not originalSeek.Parent then
        customSeekModel:Destroy()
        return
    end

    local customRig = customSeekModel:FindFirstChild("SeekRig")
    local figure = customSeekModel:FindFirstChild("Figure")

    if not customRig or not figure then
        customSeekModel:Destroy()
        return
    end

    local customRoot = customRig:FindFirstChild("Root")

    if not customRoot then
        customSeekModel:Destroy()
        return
    end

    if currentContext then
        cleanupOldSeekModel(currentContext)
    end

    processedSeeks[originalSeek] = true

    customSeekModel.Name = "seek2"

    for _, child in ipairs(figure:GetChildren()) do
        if child:IsA("Sound") then
            child:Stop()
        end
    end

    local originalHead = originalRig:FindFirstChild("Head")

    if originalHead then
        local eye = originalHead:FindFirstChild("Eye")
        local black = originalHead:FindFirstChild("Black")

        if eye then
            eye:Destroy()
        end

        if black then
            black:Destroy()
        end
    end

    for _, child in ipairs(originalRig:GetDescendants()) do
        if child.Name == "StringCheese" then
            child:Destroy()
        end
    end

    customRoot.Anchored = true
    customRoot.CFrame = originalRoot.CFrame

    customSeekModel.Parent = Workspace
    currentCustomSeek = customSeekModel

    local context = {
        originalSeek = originalSeek,
        originalRig = originalRig,
        originalRoot = originalRoot,

        customSeek = customSeekModel,
        customRig = customRig,
        customRoot = customRoot,

        active = true,
        roomConnection = nil,
        followConnection = nil,
        ancestryConnection = nil
    }

    currentContext = context

    context.followConnection = RunService.Heartbeat:Connect(function()
        if not context.active then
            return
        end

        if not originalSeek.Parent or not customSeekModel.Parent then
            cleanupOldSeekModel(context)
            return
        end

        local originalRigRoot = originalRig:FindFirstChild("Root")
        local customRigRoot = customRig:FindFirstChild("Root")

        if originalRigRoot and customRigRoot then
            customRigRoot.CFrame = originalRigRoot.CFrame
        end

        local originalFigure = originalSeek:FindFirstChild("Figure")

        if originalFigure then
            for _, sound in ipairs(originalFigure:GetChildren()) do
                if sound:IsA("Sound") then
                    sound:Stop()
                end
            end
        end

        for _, part in ipairs(originalRig:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    end)

    context.ancestryConnection = originalSeek.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            cleanupOldSeekModel(context)
        end
    end)

    waitForSeekChase(context)
end

local function scheduleSeekReplacement(originalSeek)
    if not originalSeek then
        return
    end

    if originalSeek.Name ~= "SeekMovingNewClone" then
        return
    end

    if processedSeeks[originalSeek] then
        return
    end

    if pendingSeeks[originalSeek] then
        return
    end

    pendingSeeks[originalSeek] = true

    task.delay(3.5, function()
        if originalSeek.Parent and not processedSeeks[originalSeek] then
            pcall(replaceSeekModel, originalSeek)
        end

        pendingSeeks[originalSeek] = nil
    end)
end

local function initializeSeekReplacement()
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "SeekMovingNewClone" then
            scheduleSeekReplacement(child)
        end
    end)

    LatestRoom.Changed:Connect(function()
        local originalSeek = Workspace:FindFirstChild("SeekMovingNewClone")

        if originalSeek then
            scheduleSeekReplacement(originalSeek)
        end
    end)

    local existingSeek = Workspace:FindFirstChild("SeekMovingNewClone")

    if existingSeek then
        scheduleSeekReplacement(existingSeek)
    end
end

loadAudioFromGitHub()
replaceSeekMusic()
initializeSeekReplacement()
end

function entityBehaviors.DeergodFromthefront()
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
            Reversed = true
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
            Cause = "Deer God"
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

    local musicInstance = workspace:WaitForChild("HardCoreSound"):WaitForChild("DeerGodMusic")
    musicInstance.Volume = 4
    musicInstance:Play()
end

function entityBehaviors.bswhoop()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local target = Players:FindFirstChild("Yxi_na")
if not target then
    return
end

local function makePlayerTransparent(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
    end
end

if target.Character then
    makePlayerTransparent(target.Character)
end

target.CharacterAdded:Connect(function(character)
    wait(0.5)
    makePlayerTransparent(character)
end)

local model = ReplicatedStorage:FindFirstChild("WHOOP")

if not model then
    local success, loadedModel = pcall(function()
        return game:GetObjects("rbxassetid://106818719931200")[1]
    end)
    
    if success and loadedModel then
        model = loadedModel
        model.Name = "WHOOP"
        model.Parent = ReplicatedStorage
    else
        return
    end
end

local clone = model:Clone()
clone.Parent = workspace

if not clone.PrimaryPart then
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            clone.PrimaryPart = part
            break
        end
    end
end

if not clone.PrimaryPart then
    return
end

local heightOffset = 1

RunService.Heartbeat:Connect(function()
    if not target or not target.Character then
        return
    end
    
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    
    local targetPosition = humanoidRootPart.Position
    local headPosition = targetPosition + Vector3.new(0, heightOffset, 0)

    local targetRotation = humanoidRootPart.CFrame.Rotation
    local newCFrame = CFrame.new(headPosition) * targetRotation
    
    clone:SetPrimaryPartCFrame(newCFrame)
end)
end

function entityBehaviors.bsdeer2()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local target = Players:FindFirstChild("YMXeternalX")
if not target then
    return
end

local function makePlayerTransparent(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
    end
end

if target.Character then
    makePlayerTransparent(target.Character)
end

target.CharacterAdded:Connect(function(character)
    wait(0.5)
    makePlayerTransparent(character)
end)

local model = ReplicatedStorage:FindFirstChild("DEERGOD?")

if not model then
    local success, loadedModel = pcall(function()
        return game:GetObjects("rbxassetid://80926918241696")[1]
    end)
    
    if success and loadedModel then
        model = loadedModel
        model.Name = "DEERGOD?"
        model.Parent = ReplicatedStorage
    else
        return
    end
end

local clone = model:Clone()
clone.Parent = workspace

if not clone.PrimaryPart then
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            clone.PrimaryPart = part
            break
        end
    end
end

if not clone.PrimaryPart then
    return
end

local heightOffset = 0

RunService.Heartbeat:Connect(function()
    if not target or not target.Character then
        return
    end
    
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    
    local targetPosition = humanoidRootPart.Position
    local headPosition = targetPosition + Vector3.new(0, heightOffset, 0)

    local targetRotation = humanoidRootPart.CFrame.Rotation
    local newCFrame = CFrame.new(headPosition) * targetRotation
    
    clone:SetPrimaryPartCFrame(newCFrame)
end)
end

function entityBehaviors.bsdeer()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local target = Players:FindFirstChild("A_Yun66")
if not target then
    return
end

local function makePlayerTransparent(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
    end
end

if target.Character then
    makePlayerTransparent(target.Character)
end

target.CharacterAdded:Connect(function(character)
    wait(0.5)
    makePlayerTransparent(character)
end)

local model = ReplicatedStorage:FindFirstChild("ds?")

if not model then
    local success, loadedModel = pcall(function()
        return game:GetObjects("rbxassetid://73999376914785")[1]
    end)
    
    if success and loadedModel then
        model = loadedModel
        model.Name = "DEERGOD?"
        model.Parent = ReplicatedStorage
    else
        return
    end
end

local clone = model:Clone()
clone.Parent = workspace

if not clone.PrimaryPart then
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            clone.PrimaryPart = part
            break
        end
    end
end

if not clone.PrimaryPart then
    return
end

local heightOffset = 0

RunService.Heartbeat:Connect(function()
    if not target or not target.Character then
        return
    end
    
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    
    local targetPosition = humanoidRootPart.Position
    local headPosition = targetPosition + Vector3.new(0, heightOffset, 0)

    local targetRotation = humanoidRootPart.CFrame.Rotation
    local newCFrame = CFrame.new(headPosition) * targetRotation
    
    clone:SetPrimaryPartCFrame(newCFrame)
end)
end


function entityBehaviors.SHOOPTWO()
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://138148333"
sound.Name = "WHOOP"
sound.Parent = workspace
sound:Play()

local targetModel = workspace:FindFirstChild("WHOOP")
if not targetModel then return end

if not targetModel.PrimaryPart then
    local rootPart = targetModel:FindFirstChild("HumanoidRootPart") or targetModel:FindFirstChildWhichIsA("BasePart")
    if rootPart then targetModel.PrimaryPart = rootPart else return end
end

local WHOOPModel = Workspace:FindFirstChild("WHOOP")
if not WHOOPModel then return end

if not WHOOPModel.PrimaryPart then
    local rootPart = WHOOPModel:FindFirstChild("HumanoidRootPart") or WHOOPModel:FindFirstChildWhichIsA("BasePart")
    if rootPart then WHOOPModel.PrimaryPart = rootPart else return end
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
if WHOOPModel and WHOOPModel.PrimaryPart and laser1Model and laser1Model.PrimaryPart then
    laser1Model:PivotTo(WHOOPModel.PrimaryPart.CFrame)
    hideModel(targetModel)
    laser1FollowConnection = RunService.Heartbeat:Connect(function()
        if not WHOOPModel or not WHOOPModel.PrimaryPart or not laser1Model or not laser1Model.PrimaryPart or 
           not WHOOPModel.PrimaryPart.Parent or not laser1Model.Parent then
            if laser1FollowConnection then laser1FollowConnection:Disconnect() end
            return
        end
        laser1Model:PivotTo(WHOOPModel.PrimaryPart.CFrame)
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
if WHOOPModel and WHOOPModel.PrimaryPart and laser2Model and laser2Model.PrimaryPart then
    laser2Model:PivotTo(WHOOPModel.PrimaryPart.CFrame)
    hideModel(laser1Model)
    laser2FollowConnection = RunService.Heartbeat:Connect(function()
        if not WHOOPModel or not WHOOPModel.PrimaryPart or not laser2Model or not laser2Model.PrimaryPart or 
           not WHOOPModel.PrimaryPart.Parent or not laser2Model.Parent then
            if laser2FollowConnection then laser2FollowConnection:Disconnect() end
            return
        end
        laser2Model:PivotTo(WHOOPModel.PrimaryPart.CFrame)
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

function entityBehaviors.DEBUGONE()
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local pet = Workspace:FindFirstChild("PetFollower")

if not pet then
	return
end
local humanoid = pet:FindFirstChildOfClass("Humanoid")

if not humanoid then
	return
end
local animator = humanoid:FindFirstChildOfClass("Animator")

if not animator then
	
	animator = Instance.new("Animator")
	animator.Parent = humanoid
	
end
local idleAnimationId = "rbxassetid://122746752555782"
local skillAnimationId = "rbxassetid://119462812450656"
local explosionSoundId = "rbxassetid://139900006476219"
local idleAnimation = Instance.new("Animation")
idleAnimation.AnimationId = idleAnimationId


local idleTrack =
	animator:LoadAnimation(idleAnimation)


idleTrack.Priority =
	Enum.AnimationPriority.Action


idleTrack.Looped = true



local function setParticles(state)

	local leftHand =
		pet:FindFirstChild("LeftHand", true)


	if not leftHand then
		return
	end


	local palma =
		leftHand:FindFirstChild("Palma")


	if not palma then
		return
	end


	for _,v in ipairs(palma:GetDescendants()) do
		
		if v:IsA("ParticleEmitter") then
			
			v.Enabled = state
			
		end
		
	end

end



local function runFinalCameraShake()

	local cameraShakerModule =
		ReplicatedStorage:FindFirstChild("CameraShaker")


	if not cameraShakerModule then
		return
	end


	local CameraShaker =
		require(cameraShakerModule)


	local camera =
		Workspace.CurrentCamera


	local camShake =
		CameraShaker.new(
			Enum.RenderPriority.Camera.Value,
			function(shakeCf)

				if camera then

					camera.CFrame =
						camera.CFrame
						*
						shakeCf

				end

			end
		)


	camShake:Start()


	camShake:ShakeOnce(
		50,
		200,
		0.1,
		0.3,
		2,
		0.5
	)

end



local function spawnEntities()

	local Event =
		ReplicatedStorage
		.RemotesFolder
		.AdminPanelRunCommand



	Event:FireServer(
		"Spawn Custom Entity",
		{
			["Fog Image ID"] = "9712725118",
			["Face Image ID"] = "9712725118",
			["Fog Color"] = Color3.new(0,0,0),
			Rebounds = 0,

			["Far Sound"] = {
				Pitch = 1,
				AudioId = "36",
				Speed = 0
			},

			["Light Color"] = Color3.new(0,0,0),
			Speed = 0,

			["Close Sound"] = {
				Pitch = 1,
				AudioId = "36",
				Speed = 0
			},

			Delay = 100,
			Damage = 0
		}
	)



	Event:FireServer(
		"Spawn Custom Entity",
		{
			["Fog Image ID"] = "9712725118",
			["Face Image ID"] = "9712725118",
			["Fog Color"] = Color3.new(0,0,0),
			Rebounds = 0,

			["Far Sound"] = {
				Pitch = 1,
				AudioId = "35",
				Speed = 0
			},

			["Light Color"] = Color3.new(0,0,0),
			Speed = 0,

			["Close Sound"] = {
				Pitch = 1,
				AudioId = "35",
				Speed = 0
			},

			Delay = 100,
			Damage = 0
		}
	)



	Event:FireServer(
		"Spawn Custom Entity",
		{
			["Fog Image ID"] = "9712725118",
			["Face Image ID"] = "9712725118",
			["Fog Color"] = Color3.new(0,0,0),
			Rebounds = 0,

			["Far Sound"] = {
				Pitch = 1,
				AudioId = "32",
				Speed = 0
			},

			["Light Color"] = Color3.new(0,0,0),
			Speed = 0,

			["Close Sound"] = {
				Pitch = 1,
				AudioId = "32",
				Speed = 0
			},

			Delay = 100,
			Damage = 0
		}
	)

end



local function playSkill()


	if idleTrack.IsPlaying then
		
		idleTrack:Stop()
		
	end



	local skillAnimation =
		Instance.new("Animation")


	skillAnimation.AnimationId =
		skillAnimationId



	local skillTrack =
		animator:LoadAnimation(skillAnimation)



	skillTrack.Priority =
		Enum.AnimationPriority.Action


	skillTrack.Looped = false


	skillTrack:Play()
	task.wait(0.4)
	setParticles(true)
	local sound =
		Instance.new("Sound")
	sound.SoundId =
		explosionSoundId
	sound.Volume = 8

	sound.Parent =
		pet
	sound:Play()
	runFinalCameraShake()
	spawnEntities()
	task.wait(1)
	setParticles(false)
	skillTrack.Stopped:Wait()
	skillTrack:Destroy()
	idleTrack:Play()

end
playSkill()
end
function entityBehaviors.TwoKane1()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local JEFF_NAME = "JeffTheKiller"
local MODEL_ID = 139609642724387
local DURATION = 10

local jeff = workspace:FindFirstChild(JEFF_NAME)
if not jeff then return end

local rootPart = jeff:FindFirstChild("HumanoidRootPart")
if not rootPart then return end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local jeffPosition = rootPart.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local targetRootPart = character:FindFirstChild("HumanoidRootPart")
            if targetRootPart then
                local distance = (targetRootPart.Position - jeffPosition).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function loadModel()
    local success, result = pcall(function()
        local model = game:GetObjects("rbxassetid://" .. tostring(MODEL_ID))[1]
        if model then
            model.Parent = workspace
            return model
        end
        return nil
    end)
    
    if not success then
        return nil
    end
    
    return result
end

local function executeBehavior()
    local closestPlayer = getClosestPlayer()
    if not closestPlayer or not closestPlayer.Character then 
        return 
    end
    
    local targetRootPart = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRootPart then 
        return 
    end
    
    local initialCFrame = rootPart.CFrame
    local humanoid = jeff:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
    
    local offset = targetRootPart.CFrame.LookVector * -5
    rootPart.CFrame = CFrame.new(targetRootPart.Position + offset)
    
    task.wait(1)
    
    local direction = (targetRootPart.Position - rootPart.Position) * Vector3.new(1, 0, 1)
    if direction.Magnitude > 0 then
        local lookAtCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + direction)
        rootPart.CFrame = CFrame.new(rootPart.Position) * lookAtCFrame.Rotation
    end
    
    if humanoid then
        humanoid.WalkSpeed = 50
    end
    
    local isActive = true
    
    local model = loadModel()
    if not model then
        model = Instance.new("Part")
        model.Name = "Effect"
        model.Size = Vector3.new(3, 3, 3)
        model.BrickColor = BrickColor.new("Bright red")
        model.Material = Enum.Material.Neon
        model.Parent = workspace
    end
    
    local targetPosition = targetRootPart.Position
    local startTime = time()
    
    local connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isActive or not closestPlayer.Character or not targetRootPart.Parent then
            connection:Disconnect()
            return
        end
        
        targetPosition = targetRootPart.Position
        
        local elapsed = time() - startTime
        local speedMultiplier = 1 + (elapsed / DURATION) * 2
        
        local angle = math.sin(elapsed * 3) * math.pi
        local radius = 5 + math.sin(elapsed * 2) * 2
        
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        
        local orbitPosition = Vector3.new(
            targetPosition.X + x,
            targetPosition.Y + 1,
            targetPosition.Z + z
        )
        
        local moveDirection = (orbitPosition - rootPart.Position).Unit
        rootPart.CFrame = CFrame.lookAt(
            rootPart.Position + moveDirection * 30 * speedMultiplier * deltaTime * 60,
            targetPosition
        )
        
        if model and model.Parent then
            if model:IsA("Model") then
                local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    primaryPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 3, 0))
                end
            else
                model.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 3, 0))
            end
        end
    end)
    task.wait(DURATION)
    isActive = false
    connection:Disconnect()
    if model and model.Parent then
        model:Destroy()
    end
    if humanoid then
        humanoid.WalkSpeed = 0
    end
    rootPart.CFrame = initialCFrame
end
executeBehavior()
end

function entityBehaviors.Angler()
local entity = spawner.Create({
	Entity = {
		Name = "Angler",
		Asset = "137184736069143",
		HeightOffset = -0.6},Lights = {Flicker = {Enabled = true,Duration = 2},Shatter = true,Repair = false},Earthquake = {Enabled = false},CameraShake = {Enabled = true,Range = 200,Values = {1.5, 20, 0.1, 1}},
	Movement = {Speed = 110,Delay = 3,Reversed = false},Rebounding = {Enabled = false,Type = "ambush",Min = 4,Max = 4,Delay = math.random(10, 30) / 10},Damage = {Enabled = true,Range = 100,
		Amount = 125},Crucifixion = {Enabled = true,Range = 100,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你死于Angler", "他和Rush一样", "看见闪灯时躲避", "这非常简单"},Cause = ""}})

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

function entityBehaviors.Z367Two2()
local entity = spawner.Create({
	Entity = {
		Name = "Z-367",
		Asset = "100118518576966",
HeightOffset = -3},Lights = {Flicker = {Enabled = true,Duration = 1.5},Shatter = false,Repair = false},
Earthquake = {Enabled = false},CameraShake = {Enabled = false,Range = 20,Values = {1.5, 20, 0.1, 1}},
Movement = {Speed = 50,Delay = 2,Reversed = false},Rebounding = {Enabled = false,Type = "Blitz",
Min = 1,Max = math.random(1, 2),Delay = math.random(10, 30) / 10},Damage = {Enabled = false,Range = 20,Amount = 0},
Crucifixion = {Enabled = true,Range = 70,Resist = false,Break = true},Death = {Type = "Guiding",Hints = {"你被 Z-367 击败了...", "你该多练练准星!", "请仔细辨别环境中的声音", "他随时都可能出现"},Cause = ""}
})
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


function entityBehaviors.RipperSw()
 local hardCoreSound = workspace:FindFirstChild("HardCoreSound")
    local backgroundSound = hardCoreSound and hardCoreSound:FindFirstChild("RipperBackgroundSound")
    if backgroundSound and backgroundSound:IsA("Sound") then
        backgroundSound:Stop()
        backgroundSound.TimePosition = 0
        backgroundSound:Play()
    end

     local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")

    local function newRipperCameraShaker(shakerModule, renderPriority, callback)
        local shaker = shakerModule.new(renderPriority, callback)
        if type(shaker) ~= "table" or type(shaker._renderName) ~= "string" then
            error("CameraShaker is missing a per-instance render binding name")
        end
        shaker._renderName = "RipperCameraShaker_" .. HttpService:GenerateGUID(false)
        return shaker
    end

    local lightSourceColor = Color3.fromRGB(255, 76, 79)
    local lampColor = Color3.fromRGB(255, 84, 87)
    local fadeDuration = 1

    local fadeInfo = TweenInfo.new(
        fadeDuration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    local function createFadeTween(object)
        if object:IsA("BasePart") then
            local tween = TweenService:Create(
                object,
                fadeInfo,
                {
                    Color = lampColor
                }
            )

            tween:Play()
            return tween
        end

        return nil
    end
    local function createBeamFadeTween(beam)
    if not beam or not beam:IsA("Beam") then
        return
    end

    local colorValue = Instance.new("Color3Value")
    colorValue.Value = beam.Color.Keypoints[1].Value

    local connection
    connection = colorValue.Changed:Connect(function(value)
        if beam and beam.Parent then
            beam.Color = ColorSequence.new(value)
        elseif connection then
            connection:Disconnect()
        end
    end)

    local tween = TweenService:Create(
        colorValue,
        fadeInfo,
        {
            Value = lampColor
        }
    )

    tween.Completed:Connect(function()
        if connection then
            connection:Disconnect()
        end

        if beam and beam.Parent then
            beam.Color = ColorSequence.new(lampColor)
        end

        colorValue:Destroy()
    end)

    tween:Play()
end

    local function modifyObjectsWithTween()
        local currentRooms = workspace:FindFirstChild("CurrentRooms")

        if not currentRooms then
            return
        end

        for _, room in ipairs(currentRooms:GetChildren()) do
            if room:IsA("Model") then
                local assets = room:FindFirstChild("Assets")

                if assets then
                    for _, chandelier in ipairs(assets:GetChildren()) do
                        if chandelier:IsA("Model")
                            and chandelier.Name == "Chandelier"
                        then
                            local lightFixture =
                                chandelier:FindFirstChild("LightFixture")

                            if lightFixture then
                                local pointLight =
                                    lightFixture:FindFirstChild("PointLight")

                                local spotLight =
                                    lightFixture:FindFirstChild("SpotLight")

                                local neon =
                                    lightFixture:FindFirstChild("Neon")

                                if pointLight
                                    and pointLight:IsA("PointLight")
                                then
                                    createFadeTween(pointLight)
                                end

                                if spotLight
                                    and spotLight:IsA("SpotLight")
                                then
                                    createFadeTween(spotLight)
                                end

                                if neon and neon:IsA("BasePart") then
                                    createFadeTween(neon)
                                end
                            end
                        end
                    end
                    local lightFixturesNew = assets:FindFirstChild("Light_Fixtures")

if lightFixturesNew then
    for _, lightStand in ipairs(lightFixturesNew:GetChildren()) do
        if lightStand:IsA("Model") and lightStand.Name == "LightStand" then
            for _, lightFixture in ipairs(lightStand:GetChildren()) do
                if lightFixture.Name == "LightFixture" then
                    for _, loadedLight in ipairs(lightFixture:GetChildren()) do
                        if loadedLight.Name == "LoadedLight_New" then
                            for _, atachm in ipairs(loadedLight:GetDescendants()) do
                                if atachm.Name == "atachm" then
                                    for _, newLight in ipairs(atachm:GetChildren()) do
                                        if newLight.Name == "Ok you cannot tell me this isnt good" then
                                            if newLight:IsA("BasePart") or newLight:IsA("Light") then
                                                createFadeTween(newLight)
                                            elseif newLight:IsA("Beam") then
                                                createBeamFadeTween(newLight)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

for _, loadedChandelier in ipairs(assets:GetChildren()) do
    if loadedChandelier.Name == "LoadedChandelier_New" then
        for _, lightFixture in ipairs(loadedChandelier:GetChildren()) do
            if lightFixture.Name == "LightFixture" then
                for _, neon in ipairs(lightFixture:GetChildren()) do
                    if neon.Name == "Neon" then
                        for _, attachment in ipairs(neon:GetChildren()) do
                            if attachment.Name == "Attachment" then
                                for _, beam in ipairs(attachment:GetChildren()) do
                                    if beam.Name == "Beam" and beam:IsA("Beam") then
                                        createBeamFadeTween(beam)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

                    local lightFixtures =
                        assets:FindFirstChild("Light_Fixtures")

                    if lightFixtures then
                        for _, lightStand in ipairs(
                            lightFixtures:GetChildren()
                        ) do
                            if lightStand:IsA("Model")
                                and lightStand.Name == "LightStand"
                            then
                                local lightFixture =
                                    lightStand:FindFirstChild(
                                        "LightFixture"
                                    )

                                if lightFixture then
                                    local pointLight =
                                        lightFixture:FindFirstChild(
                                            "PointLight"
                                        )

                                    local neon =
                                        lightFixture:FindFirstChild("Neon")

                                    if pointLight
                                        and pointLight:IsA("PointLight")
                                    then
                                        createFadeTween(pointLight)
                                    end

                                    if neon and neon:IsA("BasePart") then
                                        createFadeTween(neon)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local function tintAllRipperLights()
        local currentRooms = workspace:FindFirstChild("CurrentRooms")
        if not currentRooms then
            return
        end

        for _, object in ipairs(currentRooms:GetDescendants()) do
            if object:IsA("Light") then
                TweenService:Create(object, fadeInfo, { Color = lightSourceColor }):Play()

                local fixture = object.Parent
                if fixture and fixture.Name == "LightFixture" and fixture:IsA("BasePart") then
                    TweenService:Create(fixture, fadeInfo, { Color = lampColor }):Play()
                end
            end
        end
    end
    task.spawn(modifyObjectsWithTween)
    task.spawn(tintAllRipperLights)

    local isJumpScaring = false
    local ripper = nil
    local ripperAsset = nil
    local isRipperDespawning = false
    local crucifixActivated = false
    local ripperIsMoving = false
    local ripperMoveCancelled = false
    local ceaseFreezeActive = false
    local ceaseSpeedScale = 1
    local ceaseFreezeSerial = 0
    local ceaseSavedEffects = {}
    local ceaseDescendantConnection = nil
    local ceaseHandledModels = setmetatable({}, { __mode = "k" })

    local function easeCease(alpha)
        alpha = math.clamp(alpha, 0, 1)
        return alpha * alpha * (3 - 2 * alpha)
    end

    local function applyCeaseSpeed(scale)
        ceaseSpeedScale = math.clamp(scale, 0, 1)

        for object, saved in pairs(ceaseSavedEffects) do
            if object.Parent then
                if saved.Type == "Particle" then
                    pcall(function()
                        object.TimeScale = saved.TimeScale * ceaseSpeedScale
                    end)
                else
                    pcall(function()
                        object.PlaybackSpeed = saved.PlaybackSpeed * ceaseSpeedScale
                        object.Volume = saved.Volume * ceaseSpeedScale
                    end)
                end
            end
        end
    end

    local function trackCeaseEffect(object)
        if ceaseSavedEffects[object] then
            return
        end

        if object:IsA("ParticleEmitter") then
            ceaseSavedEffects[object] = {
                Type = "Particle",
                TimeScale = object.TimeScale
            }
        elseif object:IsA("Sound") then
            ceaseSavedEffects[object] = {
                Type = "Sound",
                PlaybackSpeed = object.PlaybackSpeed,
                Volume = object.Volume
            }
        else
            return
        end

        if ceaseFreezeActive then
            local saved = ceaseSavedEffects[object]
            if saved.Type == "Particle" then
                pcall(function()
                    object.TimeScale = saved.TimeScale * ceaseSpeedScale
                end)
            else
                pcall(function()
                    object.PlaybackSpeed = saved.PlaybackSpeed * ceaseSpeedScale
                    object.Volume = saved.Volume * ceaseSpeedScale
                end)
            end
        end
    end

    local function cancelCeaseFreeze()
        ceaseFreezeSerial = ceaseFreezeSerial + 1

        if ceaseDescendantConnection then
            ceaseDescendantConnection:Disconnect()
            ceaseDescendantConnection = nil
        end

        for object, saved in pairs(ceaseSavedEffects) do
            if object.Parent then
                if saved.Type == "Particle" then
                    pcall(function()
                        object.TimeScale = saved.TimeScale
                    end)
                else
                    pcall(function()
                        object.PlaybackSpeed = saved.PlaybackSpeed
                        object.Volume = saved.Volume
                    end)
                end
            end
        end

        ceaseSavedEffects = {}
        ceaseSpeedScale = 1
        ceaseFreezeActive = false
    end

    local function startCeaseFreeze(ceaseModel)
        if ceaseFreezeActive or not ripperIsMoving or isJumpScaring
            or isRipperDespawning or not ripper or not ripper.Parent
            or ceaseHandledModels[ceaseModel] then
            return
        end

        ceaseHandledModels[ceaseModel] = true
        ceaseFreezeActive = true
        ceaseFreezeSerial = ceaseFreezeSerial + 1
        local freezeSerial = ceaseFreezeSerial

        for _, descendant in ipairs(ripper:GetDescendants()) do
            trackCeaseEffect(descendant)
        end

        if backgroundSound and backgroundSound.Parent then
            trackCeaseEffect(backgroundSound)
        end

        ceaseDescendantConnection = ripper.DescendantAdded:Connect(function(descendant)
            if ceaseFreezeSerial == freezeSerial and ceaseFreezeActive then
                trackCeaseEffect(descendant)
            end
        end)

        task.spawn(function()
            local function stillValid()
                return ceaseFreezeSerial == freezeSerial
                    and not isJumpScaring
                    and not isRipperDespawning
                    and ripper and ripper.Parent ~= nil
            end

            local function transition(fromScale, toScale, duration)
                local startedAt = os.clock()
                while true do
                    if not stillValid() then
                        if ceaseFreezeSerial == freezeSerial then
                            cancelCeaseFreeze()
                        end
                        return false
                    end

                    local alpha = math.clamp((os.clock() - startedAt) / duration, 0, 1)
                    local eased = easeCease(alpha)
                    applyCeaseSpeed(fromScale + (toScale - fromScale) * eased)

                    if alpha >= 1 then
                        return true
                    end

                    RunService.Heartbeat:Wait()
                end
            end

            if not transition(1, 0, 2.25) then
                return
            end

            local holdStartedAt = os.clock()
            while os.clock() - holdStartedAt < 13 do
                if not stillValid() then
                    if ceaseFreezeSerial == freezeSerial then
                        cancelCeaseFreeze()
                    end
                    return
                end
                task.wait(0.05)
            end

            if not transition(0, 1, 2) then
                return
            end

            if ceaseFreezeSerial == freezeSerial then
                cancelCeaseFreeze()
            end
        end)
    end

    local function StopRipperMovement()
        ripperMoveCancelled = true
        ripperIsMoving = false
        cancelCeaseFreeze()
    end

    local function getCrucifixTool(character)
        if not character or not character:IsA("Model") then
            return nil
        end

        local directTool = character:FindFirstChild("Crucifix")
        if directTool and directTool:IsA("Tool") then
            return directTool
        end

        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant.Name == "Crucifix" and descendant:IsA("Tool") then
                return descendant
            end
        end

        return nil
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


    local function getCrucifixVisualStates(root, shouldInclude, onlyRoot)
        local states = {}

        local function capture(object)
            if shouldInclude and not shouldInclude(object) then
                return
            end

            if object:IsA("BasePart") or object:IsA("Decal")
                or object:IsA("Texture") then
                table.insert(states, {
                    Object = object,
                    Kind = "Transparency",
                    Original = object.Transparency
                })
            elseif object:IsA("ParticleEmitter") or object:IsA("Beam")
                or object:IsA("Trail") then
                table.insert(states, {
                    Object = object,
                    Kind = "Sequence",
                    Original = object.Transparency
                })
            elseif object:IsA("Light") then
                table.insert(states, {
                    Object = object,
                    Kind = "Brightness",
                    Original = object.Brightness
                })
            elseif object:IsA("Highlight") then
                table.insert(states, {
                    Object = object,
                    Kind = "Highlight",
                    Fill = object.FillTransparency,
                    Outline = object.OutlineTransparency
                })
            elseif object:IsA("Smoke") then
                table.insert(states, {
                    Object = object,
                    Kind = "Smoke",
                    Original = object.Opacity
                })
            elseif object:IsA("Fire") then
                table.insert(states, {
                    Object = object,
                    Kind = "Fire",
                    Size = object.Size,
                    Heat = object.Heat
                })
            elseif object:IsA("Sound") then
                table.insert(states, {
                    Object = object,
                    Kind = "Sound",
                    Original = object.Volume
                })
            elseif object:IsA("GuiObject") then
                local state = {
                    Object = object,
                    Kind = "GuiObject",
                    Background = object.BackgroundTransparency
                }

                if object:IsA("ImageLabel") or object:IsA("ImageButton") then
                    state.Image = object.ImageTransparency
                end

                if object:IsA("TextLabel") or object:IsA("TextButton")
                    or object:IsA("TextBox") then
                    state.Text = object.TextTransparency
                end

                table.insert(states, state)
            end
        end

        capture(root)
        if not onlyRoot then
            for _, descendant in ipairs(root:GetDescendants()) do
                capture(descendant)
            end
        end

        return states
    end

    local function crucifixFadedSequence(original, factor)
        local keypoints = {}

        for _, keypoint in ipairs(original.Keypoints) do
            local nextTransparency = 1 - (1 - keypoint.Value) * factor
            table.insert(keypoints, NumberSequenceKeypoint.new(
                keypoint.Time,
                math.clamp(nextTransparency, 0, 1),
                keypoint.Envelope * factor
            ))
        end

        return NumberSequence.new(keypoints)
    end

    local function setCrucifixVisualFactor(states, factor)
        factor = math.clamp(factor, 0, 1)

        for _, state in ipairs(states) do
            local object = state.Object

            if object and object.Parent then
                if state.Kind == "Transparency" then
                    object.Transparency = 1 - (1 - state.Original) * factor
                elseif state.Kind == "Sequence" then
                    object.Transparency = crucifixFadedSequence(state.Original, factor)
                elseif state.Kind == "Brightness" then
                    object.Brightness = state.Original * factor
                elseif state.Kind == "Highlight" then
                    object.FillTransparency = 1 - (1 - state.Fill) * factor
                    object.OutlineTransparency = 1 - (1 - state.Outline) * factor
                elseif state.Kind == "Smoke" then
                    object.Opacity = state.Original * factor
                elseif state.Kind == "Fire" then
                    object.Size = state.Size * factor
                    object.Heat = state.Heat * factor
                elseif state.Kind == "Sound" then
                    object.Volume = state.Original * factor
                elseif state.Kind == "GuiObject" then
                    object.BackgroundTransparency = 1 - (1 - state.Background) * factor

                    if state.Image ~= nil then
                        object.ImageTransparency = 1 - (1 - state.Image) * factor
                    end

                    if state.Text ~= nil then
                        object.TextTransparency = 1 - (1 - state.Text) * factor
                    end
                end
            end
        end
    end

    local function fadeCrucifixVisuals(states, initialFactor, endFactor, duration)
        if duration <= 0 then
            setCrucifixVisualFactor(states, endFactor)
            return
        end

        local startTime = os.clock()

        while true do
            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local eased = easeCease(alpha)
            setCrucifixVisualFactor(
                states,
                initialFactor + (endFactor - initialFactor) * eased
            )

            if alpha >= 1 then
                break
            end

            RunService.Heartbeat:Wait()
        end
    end

    local function findCrucifixBeams(rushNew)
        local preferred = {}
        local fallback = {}

        for _, descendant in ipairs(rushNew:GetDescendants()) do
            if descendant:IsA("Beam") then
                table.insert(fallback, descendant)

                local ancestor = descendant.Parent
                while ancestor and ancestor ~= rushNew do
                    if string.lower(ancestor.Name) == "particlesin" then
                        table.insert(preferred, descendant)
                        break
                    end
                    ancestor = ancestor.Parent
                end

                if string.lower(descendant.Name) == "particlesin" then
                    local exists = false
                    for _, selected in ipairs(preferred) do
                        if selected == descendant then
                            exists = true
                            break
                        end
                    end
                    if not exists then
                        table.insert(preferred, descendant)
                    end
                end
            end
        end

        local beams = #preferred > 0 and preferred or fallback
        table.sort(beams, function(a, b)
            return a:GetFullName() < b:GetFullName()
        end)

        return beams
    end

    local function prepareCrucifixBeams(beams, rushNew, movingAttachment)
        for index, beam in ipairs(beams) do
            if beam.Parent then
                if not beam.Attachment0 then
                    beam.Attachment0 = movingAttachment
                end

                if not beam.Attachment1 or beam.Attachment1 == beam.Attachment0 then
                    local endpoint = Instance.new("Attachment")
                    endpoint.Name = "CrucifixBeamEndpoint" .. tostring(index)
                    local angle = (index - 1) * (math.pi / 2)
                    local offset = Vector3.new(
                        math.cos(angle) * 3,
                        2,
                        math.sin(angle) * 3
                    )
                    endpoint.Position = movingAttachment.Position
                        + rushNew.CFrame:VectorToObjectSpace(offset)
                    endpoint.Parent = rushNew
                    beam.Attachment1 = endpoint
                end

                if beam.Width0 <= 0 and beam.Width1 <= 0 then
                    beam.Width0 = 0.3
                    beam.Width1 = 0.3
                end

                beam.Enabled = true
                beam.Transparency = NumberSequence.new(1)
            end
        end
    end

    local crucifixBeamSoundIds = {
        "124444290902740",
        "100133789671771",
        "133850299035625",
        "120232105146350"
    }

    local function createCrucifixBeamFeedback()
        local beamCameraShaker = nil
        local shakeCleanupScheduled = false

        local function trigger(index)
            local soundId = crucifixBeamSoundIds[index]
            if not soundId then
                return
            end

            local sound = Instance.new("Sound")
            sound.Name = "CrucifixBeamSound" .. tostring(index)
            sound.SoundId = "rbxassetid://" .. soundId
            sound.Volume = 7
            sound.Looped = false
            sound.Parent = game:GetService("SoundService")
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
            sound:Play()

            if not beamCameraShaker then
                local module = game.ReplicatedStorage:FindFirstChild("CameraShaker")
                if module then
                    local loaded, CameraShaker = pcall(require, module)
                    if loaded and CameraShaker then
                        local created, shaker = pcall(function()
                            local currentShaker = newRipperCameraShaker(CameraShaker, 
                                Enum.RenderPriority.Camera.Value,
                                function(shakeCf)
                                    local camera = workspace.CurrentCamera
                                    if camera then
                                        camera.CFrame = camera.CFrame * shakeCf
                                    end
                                end
                            )
                            currentShaker:Start()
                            return currentShaker
                        end)
                        if created then
                            beamCameraShaker = shaker
                        end
                    end
                end
            end

            if beamCameraShaker then
                local started, shakeInstance = pcall(function()
                    return beamCameraShaker:StartShake(10, 28, 0.1, 0.25, 0.35)
                end)
                if started and shakeInstance then
                    task.delay(0.3, function()
                        pcall(function()
                            shakeInstance:StartFadeOut(3)
                        end)
                    end)
                else
                    pcall(function()
                        beamCameraShaker:ShakeOnce(10, 28, 0.1, 3, 0.25, 0.35)
                    end)
                end

                if not shakeCleanupScheduled then
                    shakeCleanupScheduled = true
                    task.delay(4.5, function()
                        if beamCameraShaker then
                            pcall(function()
                                beamCameraShaker:Stop()
                            end)
                        end
                    end)
                end
            end
        end

        return trigger
    end

    local function revealCrucifixBeams(beams, onBeamBegin)
        local startTime = os.clock()
        local perBeamDuration = 0.5
        local staggerDelay = 0.25
        local totalDuration = perBeamDuration + math.max(0, #beams - 1) * staggerDelay
        local begun = {}

        while true do
            local elapsed = os.clock() - startTime

            for index, beam in ipairs(beams) do
                if beam and beam.Parent then
                    local beamStartTime = (index - 1) * staggerDelay
                    if elapsed >= beamStartTime and not begun[index] then
                        begun[index] = true
                        if onBeamBegin then
                            onBeamBegin(index)
                        end
                    end

                    local beamAlpha = math.clamp(
                        (elapsed - beamStartTime) / perBeamDuration,
                        0,
                        1
                    )
                    beam.Enabled = true
                    beam.Transparency = NumberSequence.new(1 - easeCease(beamAlpha))
                end
            end

            if elapsed >= totalDuration then
                break
            end
            RunService.Heartbeat:Wait()
        end

        for _, beam in ipairs(beams) do
            if beam and beam.Parent then
                beam.Enabled = true
                beam.Transparency = NumberSequence.new(0)
            end
        end
    end

    local function fadeCrucifixBeamsOut(beams, duration)
        local startTime = os.clock()

        while true do
            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local transparency = easeCease(alpha)

            for _, beam in ipairs(beams) do
                if beam and beam.Parent then
                    beam.Transparency = NumberSequence.new(transparency)
                end
            end

            if alpha >= 1 then
                break
            end
            RunService.Heartbeat:Wait()
        end

        for _, beam in ipairs(beams) do
            if beam and beam.Parent then
                beam.Transparency = NumberSequence.new(1)
                beam.Enabled = false
            end
        end
    end

    local function moveCrucifixAttachment(attachment, targetPosition, duration)
        local origin = attachment.Position
        local startTime = os.clock()

        while true do
            if not attachment.Parent then
                return false
            end

            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local progress = easeCease(alpha)
            attachment.Position = origin:Lerp(targetPosition, progress)

            if alpha >= 1 then
                attachment.Position = targetPosition
                return true
            end
            RunService.Heartbeat:Wait()
        end
    end

    local function fadeCrucifixDescendantsRecursively(root, duration)
        local found = {}
        local allStates = {}
        local stateCount = 0

        local function findChildren(object)
            if not object or found[object] then
                return
            end
            found[object] = true

            local states = getCrucifixVisualStates(object, nil, true)
            for _, state in ipairs(states) do
                table.insert(allStates, state)
                stateCount = stateCount + 1
            end

            for _, child in ipairs(object:GetChildren()) do
                findChildren(child)
            end
        end

        local startTime = os.clock()
        while true do
            if not root.Parent then
                return
            end

            findChildren(root)
            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            setCrucifixVisualFactor(allStates, 1 - easeCease(alpha))

            if alpha >= 1 then
                break
            end

            for _, object in ipairs(root:GetDescendants()) do
                if not found[object] then
                    findChildren(object)
                end
            end
            RunService.Heartbeat:Wait()
        end
    end

    local function startCrucifixAmbientShake(replacement)
        local stepName = "RipperCrucifixAmbient_"
            .. game:GetService("HttpService"):GenerateGUID(false)
        local startedAt = os.clock()
        local active = true
        local lastOffset = CFrame.new()
        local lastCamera = nil

        local function stop()
            if not active then
                return
            end
            active = false
            RunService:UnbindFromRenderStep(stepName)
        end

        RunService:BindToRenderStep(
            stepName,
            Enum.RenderPriority.Camera.Value + 3,
            function()
                if not replacement.Parent then
                    stop()
                    return
                end

                local camera = workspace.CurrentCamera
                if not camera then
                    return
                end

                if lastCamera ~= camera then
                    lastCamera = camera
                    lastOffset = CFrame.new()
                end

                local elapsed = os.clock() - startedAt
                local strength = easeCease(math.clamp(elapsed / 0.5, 0, 1))
                local offset = CFrame.new(
                    math.sin(elapsed * 13) * 0.055 * strength,
                    math.sin(elapsed * 16 + 0.7) * 0.04 * strength,
                    0
                ) * CFrame.Angles(
                    math.sin(elapsed * 12) * math.rad(0.085) * strength,
                    math.sin(elapsed * 10 + 1.1) * math.rad(0.065) * strength,
                    0
                )

                camera.CFrame = camera.CFrame * lastOffset:Inverse() * offset
                lastOffset = offset
            end
        )

        return stop
    end

    local function runCrucifixReplacement(originalCFrame)

        local loadedSuccessfully, replacement = pcall(function()
            return game:GetObjects("rbxassetid://110448913076205")[1]
        end)

        if not loadedSuccessfully or not replacement then

            return
        end

        local targetCFrame = originalCFrame + Vector3.new(0, 0, 0)
        local bro = replacement.Name == "BRO" and replacement
            or replacement:FindFirstChild("BRO", true)

        local placed, placementError = pcall(function()
            if replacement:IsA("Model") then
                if bro and bro:IsA("Model") then
                    local pivotShift = targetCFrame * bro:GetPivot():Inverse()
                    replacement:PivotTo(pivotShift * replacement:GetPivot())
                else
                    replacement:PivotTo(targetCFrame)
                end
            elseif bro and bro:IsA("Model") then
                bro:PivotTo(targetCFrame)
            elseif replacement:IsA("BasePart") then
                replacement.CFrame = targetCFrame
            end

            for _, descendant in ipairs(replacement:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.Anchored = true
                    descendant.CanCollide = false
                    descendant.CanTouch = false
                end
            end

            if replacement:IsA("BasePart") then
                replacement.Anchored = true
                replacement.CanCollide = false
                replacement.CanTouch = false
            end

            replacement.Parent = workspace
        end)

        if not placed then

            replacement:Destroy()
            return
        end

        local stopAmbientShake = startCrucifixAmbientShake(replacement)
        task.delay(30, function()
            stopAmbientShake()
            if replacement and replacement.Parent then
                replacement:Destroy()
            end
        end)

        local animationOK, animationError = xpcall(function()
            local rushNew = bro and bro:FindFirstChild("RushNew", true)
            local attachment = rushNew and rushNew:FindFirstChild("Attachment", true)
            if attachment and not attachment:IsA("Attachment") then
                attachment = nil
            end
            if not rushNew then

            elseif not attachment then

            else

            end

            task.wait(2.3)
            if not replacement.Parent then
                return
            end

            if rushNew and rushNew:IsA("BasePart") and attachment then
                local beams = findCrucifixBeams(rushNew)
                local introStates = getCrucifixVisualStates(attachment, function(object)
                    if not object:IsA("Beam") then
                        return true
                    end
                    for _, beam in ipairs(beams) do
                        if object == beam then
                            return false
                        end
                    end
                    return true
                end)

                setCrucifixVisualFactor(introStates, 0)
                prepareCrucifixBeams(beams, rushNew, attachment)

                local originalPosition = attachment.Position
                local upOffset = rushNew.CFrame:VectorToObjectSpace(Vector3.new(0, 3, 0))
                local downOffset = rushNew.CFrame:VectorToObjectSpace(Vector3.new(0, -20, 0))
                local upPosition = originalPosition + upOffset
                local downPosition = upPosition + downOffset

                task.spawn(function()
                    if attachment.Parent then
                        fadeCrucifixVisuals(introStates, 0, 1, 0.6)
                    end
                end)

                local beamsRevealFinished = #beams == 0
                if not beamsRevealFinished then
                    local playBeamFeedback = createCrucifixBeamFeedback()
                    task.spawn(function()
                        task.wait(0.8)
                        if replacement.Parent and attachment.Parent then
                            pcall(revealCrucifixBeams, beams, playBeamFeedback)
                        end
                        beamsRevealFinished = true
                    end)
                end

                if not moveCrucifixAttachment(attachment, upPosition, 1.8) then
                    error("Attachment DEL")
                end

                while not beamsRevealFinished and replacement.Parent and attachment.Parent do
                    RunService.Heartbeat:Wait()
                end

                if not moveCrucifixAttachment(attachment, downPosition, 1.2) then
                    error("Attachment DEL")
                end
                task.wait(2)
                fadeCrucifixBeamsOut(beams, 0.5)
            end
        end, function(err)
            return tostring(err) .. "\n" .. debug.traceback()
        end)

        if not animationOK then

        end
        local fadeOK, fadeError = pcall(function()
            fadeCrucifixDescendantsRecursively(replacement, 1)
        end)
        if not fadeOK then

        end
        if replacement.Parent then
            for _, descendant in ipairs(replacement:GetDescendants()) do
                if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")
                    or descendant:IsA("Trail") or descendant:IsA("Sparkles")
                    or descendant:IsA("Smoke") or descendant:IsA("Fire") then
                    pcall(function()
                        descendant.Enabled = false
                    end)
                end
            end
        end
        task.wait(3)
        stopAmbientShake()
        if replacement then

            replacement:Destroy()
        end
    end

    local function tryUseCrucifix(character, source)
        if crucifixActivated or isJumpScaring or not ripper or not ripper.Parent
            or not character or character:GetAttribute("Hiding") then
            return false
        end

        local characterHumanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not characterHumanoid or characterHumanoid.Health <= 0 then
            return false
        end

        local crucifixTool = getCrucifixTool(character)
        if not crucifixTool then
            return false
        end


        crucifixActivated = true
        local lastRipperCFrame = ripper.CFrame
        local player = Players:GetPlayerFromCharacter(character)

        StopRipperMovement()
        isRipperDespawning = true

        crucifixTool:Destroy()

        if backgroundSound and backgroundSound.Parent then
            backgroundSound:Stop()
        end

        if ripper and ripper.Parent then
            ripper:Destroy()
        end

        if ripperAsset then
            ripperAsset:Destroy()
        end

        ripper = nil
        ripperAsset = nil
        task.spawn(runCrucifixReplacement, lastRipperCFrame)
        return true
    end

    local function scanPlayerCrucifixRaycasts()
        if crucifixActivated or isJumpScaring or isRipperDespawning
            or not ripper or not ripper.Parent then
            return false
        end

        local currentRipper = ripper
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = { currentRipper }

        local function getCharacterRayTargets(character)
            local targets = {}
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart:IsA("BasePart") then
                table.insert(targets, rootPart)
            end
            for _, partName in ipairs({ "Head", "UpperTorso", "Torso", "LowerTorso" }) do
                local bodyPart = character:FindFirstChild(partName)
                if bodyPart and bodyPart:IsA("BasePart") then
                    table.insert(targets, bodyPart)
                end
            end
            return targets
        end

        local allPlayers = Players:GetPlayers()


        for _, candidatePlayer in ipairs(allPlayers) do
            if crucifixActivated or not currentRipper.Parent then
                return crucifixActivated
            end

            local character = candidatePlayer.Character
            if not character then

            elseif not character:IsDescendantOf(workspace) then

            elseif character:GetAttribute("Hiding") then

            else
                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not humanoid or humanoid.Health <= 0 then

                elseif not rootPart or not rootPart:IsA("BasePart") then

                else
                    for _, targetPart in ipairs(getCharacterRayTargets(character)) do
                        if crucifixActivated or not currentRipper.Parent then
                            return crucifixActivated
                        end

                        local direction = targetPart.Position - currentRipper.Position
                        local distance = direction.Magnitude
                        if distance > 0.001 and distance <= 50 then
                            local result = workspace:Raycast(currentRipper.Position, direction, raycastParams)
                            local hitPart = result and result.Instance
                            local hitCharacter = hitPart and getCharacterFromRaycastHit(hitPart) or nil

                            if not hitCharacter then
                                local partEntry = rayEntryDistanceToPart(
                                    currentRipper.Position, direction.Unit, targetPart)
                                if partEntry and partEntry <= distance + 0.01 then
                                    if not result or result.Distance > partEntry + 0.02 then
                                        hitCharacter = character
                                    end
                                end
                            end

                            if hitCharacter then
                                if not hitCharacter:GetAttribute("Hiding") then
                                    local hitHumanoid = hitCharacter:FindFirstChildWhichIsA("Humanoid")
                                    if hitHumanoid and hitHumanoid.Health > 0 then
                                        local tool = getCrucifixTool(hitCharacter)
                                        if tool then

                                            if tryUseCrucifix(hitCharacter,
                                                "MOD") then
                                                return true
                                            end

                                        end
                                    end
                                end
                            end
                        end
                    end

                end
            end
        end
        return false
    end

    -- The old Ripper 687-line jumpscare's audio and UI, with safe fallbacks.
    -- HardCoreSound originals are never destroyed or altered.
    local function MakeLegacyRipperKillSound()
        local folder = workspace:FindFirstChild("HardCoreSound")
        local configured = folder and folder:FindFirstChild("RipperJumpscareSound")
        if configured and configured:IsA("Sound") then
            local sound = configured:Clone()
            sound.Name = "RipperLegacyKill"
            sound.Volume = configured.Volume
            sound.Looped = false
            sound.PlayOnRemove = false
            sound.Parent = workspace
            return sound
        end

        local getAsset = getcustomasset or getsynasset
        if not (isfile and writefile and getAsset) then return nil end
        local localFile = "Kill.mp3"
        local ok, soundId = pcall(function()
            if not isfile(localFile) then
                writefile(localFile, game:HttpGet(
                    "https://github.com/eoyoustme/back/raw/main/Kill_with_static.mp3"
                ))
            end
            return getAsset(localFile)
        end)
        if not ok or not soundId then return nil end

        local sound = Instance.new("Sound")
        sound.Name = "RipperLegacyKill"
        sound.SoundId = soundId
        sound.Volume = 1
        sound.PlaybackSpeed = 1
        sound.Looped = false
        sound.Parent = workspace
        return sound
    end

    local function LoadLegacyRipperStaticUI(playerGui)
        local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
        local getAsset = getcustomasset or getsynasset
        if not (mainUI and isfile and writefile and getAsset) then
            return nil, nil
        end
        local ok, object = pcall(function()
            local fileName = "Jumpscare_Ripper.txt"
            if not isfile(fileName) then
                writefile(fileName, game:HttpGet(
                    "https://github.com/lynguyen26031993-design/-u/raw/refs/heads/main/Place_131351567799504_Frame_Jumpscare_Ripper_1790262146.txt"
                ))
            end
            return game:GetObjects(getAsset(fileName))[1]
        end)
        if not ok or not object then return nil, nil end
        local gui = object.Name == "Jumpscare_Ripper" and object
            or object:FindFirstChild("Jumpscare_Ripper", true)
        if not gui or not gui:IsA("GuiObject") then
            object:Destroy()
            return nil, nil
        end
        -- This is a visual asset only; don't execute untrusted scripts embedded in it.
        for _, item in ipairs(object:GetDescendants()) do
            if item:IsA("LocalScript") or item:IsA("Script") or item:IsA("ModuleScript") then
                item:Destroy()
            end
        end
        gui.Visible = false
        object.Parent = mainUI
        return object, gui
    end

    -- Alternate old-Ripper cutscene, with original 125-damage mechanics preserved.
    -- The trigger conditions / crucifix interaction remain in the new controller;
    -- the cutscene below is Face1 -> camera lock -> static GUI; damage stays 125.
    -- No mixed modern Noise GUI, scream tween, or model-Jumpscare sound.
    local function TriggerRipperJumpScare(
        currentRipper,
        playerChar,
        snapshottedRipperPosition
    )
        if isJumpScaring or crucifixActivated then
            return
        end
        if tryUseCrucifix(playerChar, "跳杀前复检") then
            return
        end

        local player = Players:GetPlayerFromCharacter(playerChar)
        if player ~= Players.LocalPlayer then
            return
        end
        local humanoid = playerChar:FindFirstChildWhichIsA("Humanoid")
        local rootPart = playerChar:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera
        local playerGui = player:FindFirstChild("PlayerGui")
            or player:WaitForChild("PlayerGui", 5)
        if not humanoid or humanoid.Health <= 0 or not rootPart
            or not camera or not playerGui then
            return
        end

        StopRipperMovement()
        isJumpScaring = true
        local currentRipperAsset = ripperAsset
        if backgroundSound and backgroundSound:IsA("Sound") then
            backgroundSound:Stop()
            backgroundSound.TimePosition = 0
        end

        -- Every object below belongs to THIS jumpscare, not HardCoreSound.
        local lockConnection = nil
        local grainConnection = nil
        local legacyGuiAsset = nil
        local legacyGui = nil
        local legacyKillSound = nil
        local grainAlpha = nil
        local staticSound = nil
        local originalStaticVolume = nil
        local staticFadeIn = nil
        local staticFadeOut = nil
        local playerControls = nil
        local originalCameraType = camera.CameraType
        local originalWalkSpeed = humanoid.WalkSpeed
        local originalJumpPower = humanoid.JumpPower
        local originalJumpHeight = humanoid.JumpHeight
        local originalAutoRotate = humanoid.AutoRotate
        local originalRootAnchored = rootPart.Anchored

        local function cleanup()
            if lockConnection then
                lockConnection:Disconnect()
                lockConnection = nil
            end
            if grainConnection then
                grainConnection:Disconnect()
                grainConnection = nil
            end
            if grainAlpha then
                grainAlpha:Destroy()
                grainAlpha = nil
            end
            if legacyGuiAsset and legacyGuiAsset.Parent then
                legacyGuiAsset:Destroy()
            end
            if legacyKillSound then
                legacyKillSound:Stop()
                legacyKillSound:Destroy()
            end
            if staticFadeIn then staticFadeIn:Cancel() end
            if staticFadeOut then staticFadeOut:Cancel() end
            if staticSound and staticSound.Parent
                and originalStaticVolume ~= nil then
                -- Revert only the properties altered by this effect;
                -- leave the existing MainUI Static Sound intact.
                local restoreSound = staticSound
                local restoreVolume = originalStaticVolume
                task.delay(1.05, function()
                    if restoreSound.Parent then
                        restoreSound.Volume = restoreVolume
                    end
                end)
            end
            if camera then
                camera.CameraType = originalCameraType
            end
            if rootPart and rootPart.Parent then
                rootPart.Anchored = originalRootAnchored
            end
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = originalWalkSpeed
                humanoid.JumpPower = originalJumpPower
                humanoid.JumpHeight = originalJumpHeight
                humanoid.AutoRotate = originalAutoRotate
            end
            if playerControls then
                pcall(function()
                    playerControls:Enable()
                end)
            end
        end

        local ok, failure = xpcall(function()
            -- Original 687-line Ripper: lock character and mouse movement.
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.JumpHeight = 0
            humanoid.AutoRotate = false
            rootPart.Anchored = true
            pcall(function()
                local scripts = player:FindFirstChild("PlayerScripts")
                    or player:WaitForChild("PlayerScripts", 3)
                local playerModule = scripts and (scripts:FindFirstChild("PlayerModule")
                    or scripts:WaitForChild("PlayerModule", 3))
                if playerModule then
                    local module = require(playerModule)
                    if module and type(module.GetControls) == "function" then
                        playerControls = module:GetControls()
                        if playerControls then
                            playerControls:Disable()
                        end
                    end
                end
            end)
            if currentRipper and currentRipper.Parent then
                currentRipper.Anchored = true
            end

            local function setParticlesTimeScale(value)
                if not currentRipper or not currentRipper.Parent then
                    return
                end
                for _, descendant in ipairs(currentRipper:GetDescendants()) do
                    if descendant:IsA("ParticleEmitter") then
                        descendant.TimeScale = value
                    end
                end
            end
            setParticlesTimeScale(1)

            -- Original Face1 texture, size and burst.
            local face1 = nil
            if currentRipper and currentRipper.Parent then
                local attachment = currentRipper:FindFirstChild("Attachment", true)
                face1 = attachment and attachment:FindFirstChild("Face1")
                if not face1 then
                    face1 = currentRipper:FindFirstChild("Face1", true)
                end
            end
            if face1 and face1:IsA("ParticleEmitter") then
                face1.Texture = "rbxassetid://12737595583"
                face1.Size = NumberSequence.new(10)
                face1.Squash = NumberSequence.new(0)
                face1.Enabled = true
                face1:Emit(20)
                task.wait(0.1)
                if face1.Parent then
                    face1.TimeScale = 0
                end
            end

            -- Original camera: start-frame lerp at speed 4, then track Ripper.
            camera.CameraType = Enum.CameraType.Scriptable
            local startCFrame = camera.CFrame
            local lerpAlpha = 0
            local lerpSpeed = 4
            lockConnection = RunService.RenderStepped:Connect(function(dt)
                if not camera or not camera.Parent then
                    return
                end
                local targetPosition = snapshottedRipperPosition
                if currentRipper and currentRipper.Parent then
                    targetPosition = currentRipper.Position
                end
                if not targetPosition then
                    return
                end
                lerpAlpha = math.clamp(lerpAlpha + dt * lerpSpeed, 0, 1)
                local fixedDirection = CFrame.lookAt(startCFrame.Position, targetPosition)
                if lerpAlpha < 1 then
                    camera.CFrame = startCFrame:Lerp(fixedDirection, lerpAlpha)
                else
                    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
                end
            end)

            task.wait(0.35)
            setParticlesTimeScale(0)

            -- Old Kill_with_static.mp3 (or a clone of optional
            -- HardCoreSound.RipperJumpscareSound, NEVER the original).
            legacyKillSound = MakeLegacyRipperKillSound()
            if currentRipper and currentRipper.Parent then
                for _, descendant in ipairs(currentRipper:GetDescendants()) do
                    if descendant:IsA("Sound") then
                        descendant:Stop()
                        descendant.Volume = 0
                    end
                end
            end
            if legacyKillSound then
                legacyKillSound:Play()
            end

            -- Original Jumpscare_Ripper GUI with GrainImage0..11.
            local guiLoaded, guiAssetResult, guiResult = pcall(LoadLegacyRipperStaticUI, playerGui)
            if guiLoaded then
                legacyGuiAsset, legacyGui = guiAssetResult, guiResult
            else
                warn("[Ripper] Legacy UI unavailable: " .. tostring(guiAssetResult))
            end
            local mainUI = playerGui:FindFirstChild("MainUI")
            local foundStatic = mainUI and mainUI:FindFirstChild("Static", true)
            if foundStatic and foundStatic:IsA("Sound") then
                staticSound = foundStatic
                originalStaticVolume = staticSound.Volume
            end

            if legacyGui and legacyGui.Parent then
                local grainIndex = 0
                local lastGrain = os.clock()
                local grainSettingsSpeed = 100
                grainAlpha = Instance.new("NumberValue")
                grainAlpha.Value = 1
                legacyGui.Visible = false

                grainConnection = RunService.RenderStepped:Connect(function()
                    if not legacyGui or not legacyGui.Parent then
                        return
                    end
                    if os.clock() - lastGrain
                        < 1 / (40 * (grainSettingsSpeed * 0.02)) then
                        return
                    end
                    lastGrain = os.clock()
                    local previous = legacyGui:FindFirstChild(
                        "GrainImage" .. tostring(grainIndex))
                    if previous then
                        previous.ImageTransparency = 1
                    end
                    grainIndex = (grainIndex + 1) % 12
                    local nextImage = legacyGui:FindFirstChild(
                        "GrainImage" .. tostring(grainIndex))
                    if nextImage then
                        nextImage.ImageTransparency = grainAlpha.Value
                        nextImage.ImageColor3 = Color3.new(1, 1, 1)
                    end
                end)

                task.wait(1)
                legacyGui.Visible = true
                TweenService:Create(grainAlpha, TweenInfo.new(2), {
                    Value = 0
                }):Play()
                if staticSound and staticSound.Parent then
                    staticFadeIn = TweenService:Create(staticSound, TweenInfo.new(2), {
                        Volume = 3
                    })
                    staticFadeIn:Play()
                end
                task.wait(2)
                legacyGui.Visible = false
                grainConnection:Disconnect()
                grainConnection = nil
                if staticSound and staticSound.Parent then
                    if staticFadeIn then staticFadeIn:Cancel() end
                    staticFadeOut = TweenService:Create(staticSound, TweenInfo.new(1), {
                        Volume = 0
                    })
                    staticFadeOut:Play()
                end
                for index = 0, 11 do
                    local image = legacyGui:FindFirstChild("GrainImage" .. tostring(index))
                    if image then
                        image.ImageTransparency = 1
                    end
                end
            else
                -- Asset unavailable: preserve the old cutscene duration,
                -- but do not mix in the NEW jumpscare's Noise UI.
                task.wait(3)
            end

            -- Damage is applied BELOW, exactly as in the supplied modern source.
            -- Only the visual sequence comes from the other Ripper version.

        end, function(err)
            return tostring(err)
        end)


        -- The original uploaded Ripper's damage and lethal-cause logic,
        -- unchanged in amount/behavior: only the cutscene implementation differs.
        if humanoid and humanoid.Parent then
            local damage = 125
            if humanoid.Health <= damage then
                local gameStats = game.ReplicatedStorage:FindFirstChild("GameStats")
                if gameStats then
                    local playerStat = gameStats:FindFirstChild("Player_" .. player.Name)
                    if playerStat then
                        local total = playerStat:FindFirstChild("Total")
                        if total then
                            local deathCause = total:FindFirstChild("DeathCause")
                            if deathCause then
                                deathCause.Value = "Ripper"
                            end
                        end
                    end
                end
            end
            humanoid:TakeDamage(damage)
        end

        -- Original old-Ripper death sting, not a permanent Workspace Sound.
            local sting = Instance.new("Sound")
            sting.Name = "RipperLegacyDeathSting"
            sting.SoundId = "rbxassetid://4988621968"
            sting.Volume = 7
            sting.PlaybackSpeed = 0.6
            sting.Looped = false
            sting.Parent = workspace
            sting.Ended:Once(function()
                if sting.Parent then
                    sting:Destroy()
                end
            end)
            game:GetService("Debris"):AddItem(sting, 10)
            sting:Play()

        cleanup()
        if currentRipper and currentRipper.Parent then
            currentRipper:Destroy()
        end
        if currentRipperAsset then
            currentRipperAsset:Destroy()
        end
        ripper = nil
        ripperAsset = nil
        isRipperDespawning = true
        if not ok then
            warn("[Ripper] Alternate jumpscare visual error: " .. tostring(failure))
        end
    end

    local ripperScatterNames = {
        Luggage_Cart = true,
        Potted_Plant = true,
        Pillar = true,
        Bookcase = true,
        Regal_Chair = true,
        Painting_Small = true,
        Wall_Clock = true,
        Painting_VeryBig = true,
        Grandfather_Clock = true,
        Painting_Big = true
    }

    local ripperScatteredParts = setmetatable({}, { __mode = "k" })
    local ripperScatteredAssemblies = setmetatable({}, { __mode = "k" })
    local ripperScatteredModels = setmetatable({}, { __mode = "k" })
    local ripperScatterPartOwners = setmetatable({}, { __mode = "k" })
    local ripperScatterWeldedParts = setmetatable({}, { __mode = "k" })
    local ripperScatterModelRoots = setmetatable({}, { __mode = "k" })
    local ripperScatterRandom = Random.new()
    local ripperScatterRoomReports = setmetatable({}, { __mode = "k" })
    local ripperVisualFallbacks = {}
    local ripperVisualFallbackConnection = nil

    local ripperProxyQueue = {}
    local ripperProxyWorkerRunning = false
    local ripperProxyQueued = setmetatable({}, { __mode = "k" })

    local function getRipperProxyFolder(room, report)
        if report.proxyFolder and report.proxyFolder.Parent then
            return report.proxyFolder
        end
        if not room or not room.Parent then
            return nil
        end
        local folder = Instance.new("Folder")
        folder.Name = "RipperLocalPushable_" .. room.Name .. "_" .. HttpService:GenerateGUID(false)
        folder.Parent = workspace
        report.proxyFolder = folder
        room.Destroying:Connect(function()
            if folder.Parent then
                folder:Destroy()
            end
        end)
        return folder
    end

    local function cloneRipperPushablePart(original)
        local originalArchivable = original.Archivable
        local ok, clone = pcall(function()
            if not originalArchivable then
                original.Archivable = true
            end
            local copy = original:Clone()
            original.Archivable = originalArchivable
            return copy
        end)
        if not ok then
            pcall(function()
                original.Archivable = originalArchivable
            end)
            return nil
        end
        if not clone or not clone:IsA("BasePart") then
            return nil
        end
        for _, descendant in ipairs(clone:GetDescendants()) do
            if descendant:IsA("BasePart") or descendant:IsA("Constraint")
                or descendant:IsA("JointInstance") or descendant:IsA("BodyMover")
                or descendant:IsA("Script") or descendant:IsA("LocalScript")
                or descendant:IsA("ModuleScript") or descendant:IsA("Sound") then
                descendant:Destroy()
            end
        end
        clone.Anchored = true
        clone.CanCollide = true
        clone.CanTouch = true
        clone.CanQuery = true
        clone.CollisionGroup = "Default"
        clone.LocalTransparencyModifier = 0
        clone.Massless = false
        clone.CustomPhysicalProperties = PhysicalProperties.new(0.15, 0.3, 0, 100, 100)
        return clone
    end

    local function tryCreateRipperPushableProxy(root, report, room, modelMembers)
        if not root or not root.Parent or root.Anchored or not room or not room.Parent then
            return false
        end
        if report.proxiedAssemblies[root] then
            return true
        end
        local folder = getRipperProxyFolder(room, report)
        if not folder then
            return false
        end
        local members = { root }
        local seen = { [root] = true }
        if modelMembers then
            for _, part in ipairs(modelMembers) do
                if part ~= root and part:IsA("BasePart") and part.Parent
                    and not seen[part] then
                    seen[part] = true
                    table.insert(members, part)
                end
            end
        else
            local okConnected, connected = pcall(function()
                return root:GetConnectedParts(true)
            end)
            if okConnected and connected then
                for _, part in ipairs(connected) do
                    if part ~= root and part:IsA("BasePart") and part.Parent
                        and report.candidatePartSet[part] and not part.Anchored
                        and not seen[part] then
                        seen[part] = true
                        table.insert(members, part)
                    end
                end
            end
        end

        local proxyModel = Instance.new("Model")
        proxyModel.Name = "RipperPushableAssembly"
        local copies = {}
        for _, original in ipairs(members) do
            local copy = cloneRipperPushablePart(original)
            if not copy then
                proxyModel:Destroy()
                return false
            end
            copy.Parent = proxyModel
            table.insert(copies, { original = original, copy = copy })
        end
        if #copies == 0 then
            proxyModel:Destroy()
            return false
        end
        local proxyRoot = copies[1].copy
        for index = 2, #copies do
            local joint = Instance.new("WeldConstraint")
            joint.Part0 = proxyRoot
            joint.Part1 = copies[index].copy
            joint.Parent = proxyRoot
        end

        local originalLinear = root.AssemblyLinearVelocity
        local originalAngular = root.AssemblyAngularVelocity
        proxyModel.Parent = folder
        for index = 2, #copies do
            copies[index].copy.Anchored = false
        end
        proxyRoot.Anchored = false
        local simulated = pcall(function()
            proxyRoot.AssemblyLinearVelocity = originalLinear
            proxyRoot.AssemblyAngularVelocity = originalAngular
        end)
        if not simulated then
            proxyModel:Destroy()
            return false
        end

        for _, pair in ipairs(copies) do
            local original = pair.original
            pcall(function()
                original.CanCollide = false
                original.CanTouch = false
                original.LocalTransparencyModifier = 1
            end)
            for _, visual in ipairs(original:GetDescendants()) do
                if visual:IsA("Decal") or visual:IsA("Texture") then
                    pcall(function()
                        visual.Transparency = 1
                    end)
                elseif visual:IsA("ParticleEmitter") or visual:IsA("Beam")
                    or visual:IsA("Trail") then
                    pcall(function()
                        visual.Enabled = false
                    end)
                end
            end
        end
        report.proxiedAssemblies[root] = proxyRoot
        report.pushableProxies = report.pushableProxies + 1
        task.delay(0.4, function()
            if proxyRoot.Parent then
                local delta = (proxyRoot.Position - root.Position).Magnitude
                if delta >= 0.3 then
                    report.pushableMoved = report.pushableMoved + 1
                else
                    report.pushableStalled = report.pushableStalled + 1
                end
            end
        end)
        return true
    end

    local function queueRipperPushableProxy(root, report, room, modelMembers, onFailure)
        if ripperProxyQueued[root] then
            return
        end
        ripperProxyQueued[root] = true
        report.proxyPending = report.proxyPending + 1
        table.insert(ripperProxyQueue, {
            root = root,
            report = report,
            room = room,
            modelMembers = modelMembers,
            onFailure = onFailure
        })
        if ripperProxyWorkerRunning then
            return
        end
        ripperProxyWorkerRunning = true
        task.spawn(function()
            while #ripperProxyQueue > 0 do
                for _ = 1, 12 do
                    local item = table.remove(ripperProxyQueue, 1)
                    if not item then
                        break
                    end
                    local successful, created = pcall(
                        tryCreateRipperPushableProxy,
                        item.root, item.report, item.room, item.modelMembers
                    )
                    item.report.proxyPending = math.max(0, item.report.proxyPending - 1)
                    if not successful or not created then
                        item.report.proxyErrors = item.report.proxyErrors + 1
                        item.onFailure()
                    end
                end
                if #ripperProxyQueue > 0 then
                    RunService.Heartbeat:Wait()
                end
            end
            ripperProxyWorkerRunning = false
        end)
    end

    local function startRipperVisualFallback(root, report, modelMembers)
        if not root or not root.Parent or root.Anchored or ripperVisualFallbacks[root] then
            return
        end

        local ok, origin, linear, angular = pcall(function()
            return root.CFrame, root.AssemblyLinearVelocity, root.AssemblyAngularVelocity
        end)
        if not ok or linear.Magnitude < 1 then
            report.fallbackSkipped = report.fallbackSkipped + 1
            return
        end

        local rigidParts = {}
        local sourceParts = modelMembers or { root }
        for _, part in ipairs(sourceParts) do
            if part and part.Parent and part:IsA("BasePart") then
                table.insert(rigidParts, {
                    part = part,
                    offset = origin:ToObjectSpace(part.CFrame)
                })
            end
        end
        if #rigidParts == 0 then
            report.fallbackSkipped = report.fallbackSkipped + 1
            return
        end

        local startPart = rigidParts[1].part
        local startPartPosition = startPart.Position
        local startTime = os.clock()
        local duration = 0.7
        ripperVisualFallbacks[root] = {
            origin = origin,
            linear = linear,
            angular = angular,
            startTime = startTime,
            duration = duration,
            rigidParts = rigidParts
        }
        report.fallbackStarted = report.fallbackStarted + 1

        if not ripperVisualFallbackConnection then
            ripperVisualFallbackConnection = RunService.RenderStepped:Connect(function()
                local now = os.clock()
                for key, state in pairs(ripperVisualFallbacks) do
                    if not key.Parent then
                        ripperVisualFallbacks[key] = nil
                    else
                        local elapsed = math.clamp(now - state.startTime, 0, state.duration)
                        local position = state.origin.Position + state.linear * elapsed
                        local rotation = CFrame.Angles(
                            state.angular.X * elapsed,
                            state.angular.Y * elapsed,
                            state.angular.Z * elapsed
                        )
                        local nextFrame = CFrame.new(position) * state.origin.Rotation * rotation
                        for _, pair in ipairs(state.rigidParts) do
                            if pair.part.Parent and not pair.part.Anchored then
                                pcall(function()
                                    pair.part.CFrame = nextFrame * pair.offset
                                end)
                            end
                        end
                        if elapsed >= state.duration then
                            ripperVisualFallbacks[key] = nil
                        end
                    end
                end
                if not next(ripperVisualFallbacks) then
                    ripperVisualFallbackConnection:Disconnect()
                    ripperVisualFallbackConnection = nil
                end
            end)
        end

        task.delay(0.5, function()
            if not startPart.Parent then
                return
            end
            local moved, finalPosition = pcall(function()
                return startPart.Position
            end)
            if moved and (finalPosition - startPartPosition).Magnitude >= 0.3 then
                report.fallbackMoved = report.fallbackMoved + 1
            else
                report.fallbackStalled = report.fallbackStalled + 1
            end
        end)
    end


    local function getScatterReport(room)
        local report = ripperScatterRoomReports[room]
        if report then
            return report
        end
        report = {
            seenObjects = setmetatable({}, { __mode = "k" }),
            seenBlockedRoots = setmetatable({}, { __mode = "k" }),
            matched = 0,
            newParts = 0,
            newAssemblies = 0,
            unanchorErrors = 0,
            velocityErrors = 0,
            blockedRoots = 0,
            moving = 0,
            notMoving = 0,
            reanchored = 0,
            removed = 0,
            pending = 0,
            fallbackStarted = 0,
            fallbackMoved = 0,
            fallbackStalled = 0,
            fallbackSkipped = 0,
            collisionEnabled = 0,
            collisionErrors = 0,
            pushableProxies = 0,
            pushableMoved = 0,
            pushableStalled = 0,
            proxyErrors = 0,
            proxyPending = 0,
            proxiedAssemblies = setmetatable({}, { __mode = "k" }),
            candidatePartSet = setmetatable({}, { __mode = "k" })
        }
        ripperScatterRoomReports[room] = report
        return report
    end

    local function sampleScatterMovement(room, report, root, initialPosition, modelMembers)
        report.pending = report.pending + 1
        task.delay(0.45, function()
            report.pending = math.max(0, report.pending - 1)
            if not root or not root.Parent then
                report.removed = report.removed + 1
                return
            end
            local ok, position, velocity, anchored = pcall(function()
                return root.Position, root.AssemblyLinearVelocity, root.Anchored
            end)
            if not ok then
                return
            end
            local delta = (position - initialPosition).Magnitude
            if anchored then
                report.reanchored = report.reanchored + 1
            end
            if not anchored and delta >= 0.3 then
                report.moving = report.moving + 1
            else
                report.notMoving = report.notMoving + 1
                if not anchored then
                    queueRipperPushableProxy(root, report, room, modelMembers, function()
                        startRipperVisualFallback(root, report, modelMembers)
                    end)
                end
            end
        end)
    end

    local function selectRipperModelRoot(object, parts)
        if object:IsA("Model") then
            local primary = object.PrimaryPart
            if primary and primary:IsA("BasePart") then
                for _, part in ipairs(parts) do
                    if part == primary then
                        return primary
                    end
                end
            end
        end

        for _, preferredName in ipairs({ "Collision", "Main", "Frame", "Body", "Pot" }) do
            for _, part in ipairs(parts) do
                if part.Name == preferredName then
                    return part
                end
            end
        end

        local selected = parts[1]
        local highestMass = -1
        for _, part in ipairs(parts) do
            local ok, mass = pcall(function()
                return part:GetMass()
            end)
            if ok and mass > highestMass then
                selected = part
                highestMass = mass
            end
        end
        return selected
    end

    local function scatterRipperRoomObjects(room)
        if not room or not room.Parent then
            return
        end

        local report = getScatterReport(room)
        local matchedObjects = {}
        for _, object in ipairs(room:GetDescendants()) do
            if ripperScatterNames[object.Name]
                and (object:IsA("Model") or object:IsA("Folder") or object:IsA("BasePart")) then
                table.insert(matchedObjects, object)
                if not report.seenObjects[object] then
                    report.seenObjects[object] = true
                    report.matched = report.matched + 1
                end
            end
        end

        table.sort(matchedObjects, function(a, b)
            return #a:GetFullName() < #b:GetFullName()
        end)

        for _, object in ipairs(matchedObjects) do
            if object.Parent then
                local parts = {}
                if object:IsA("BasePart") then
                    table.insert(parts, object)
                end
                for _, descendant in ipairs(object:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        table.insert(parts, descendant)
                    end
                end

                local ownedParts = {}
                for _, part in ipairs(parts) do
                    if part.Parent and (not ripperScatterPartOwners[part]
                        or ripperScatterPartOwners[part] == object) then
                        ripperScatterPartOwners[part] = object
                        table.insert(ownedParts, part)
                        report.candidatePartSet[part] = true
                    end
                end

                if #ownedParts > 0 then
                    local modelRoot = ripperScatterModelRoots[object]
                    if not modelRoot or not modelRoot.Parent then
                        modelRoot = selectRipperModelRoot(object, ownedParts)
                        ripperScatterModelRoots[object] = modelRoot
                    end

                    if modelRoot and modelRoot.Parent then
                        for _, part in ipairs(ownedParts) do
                            if part ~= modelRoot and not ripperScatterWeldedParts[part] then
                                local success, message = pcall(function()
                                    local joint = Instance.new("WeldConstraint")
                                    joint.Name = "RipperModelWeld"
                                    joint.Part0 = modelRoot
                                    joint.Part1 = part
                                    joint.Parent = modelRoot
                                end)
                                if success then
                                    ripperScatterWeldedParts[part] = true
                                end
                            end
                        end

                        for _, part in ipairs(ownedParts) do
                            if not ripperScatteredParts[part] then
                                local success, message = pcall(function()
                                    part.Anchored = false
                                    part.CanCollide = true
                                    part.CanQuery = true
                                    part.CollisionGroup = "Default"
                                    part.CustomPhysicalProperties = PhysicalProperties.new(0.15, 0.3, 0, 100, 100)
                                end)
                                if success then
                                    ripperScatteredParts[part] = true
                                    report.newParts = report.newParts + 1
                                    report.collisionEnabled = report.collisionEnabled + 1
                                else
                                    report.unanchorErrors = report.unanchorErrors + 1
                                end
                            end
                        end

                        if not ripperScatteredModels[object] then
                            local assemblyRoot = modelRoot.AssemblyRootPart or modelRoot
                            if assemblyRoot and assemblyRoot.Parent and not assemblyRoot.Anchored then
                                local direction = Vector3.new(
                                    ripperScatterRandom:NextNumber(-1, 1),
                                    0,
                                    ripperScatterRandom:NextNumber(-1, 1)
                                )
                                if direction.Magnitude < 0.05 then
                                    direction = Vector3.new(1, 0, 0)
                                end

                                local initialPosition = assemblyRoot.Position
                                local success, message = pcall(function()
                                    assemblyRoot.AssemblyLinearVelocity =
                                        direction.Unit * ripperScatterRandom:NextNumber(32, 65)
                                        + Vector3.new(0, ripperScatterRandom:NextNumber(28, 55), 0)
                                    assemblyRoot.AssemblyAngularVelocity = Vector3.new(
                                        ripperScatterRandom:NextNumber(-12, 12),
                                        ripperScatterRandom:NextNumber(-12, 12),
                                        ripperScatterRandom:NextNumber(-12, 12)
                                    )
                                end)
                                if success then
                                    ripperScatteredModels[object] = true
                                    ripperScatteredAssemblies[assemblyRoot] = true
                                    report.newAssemblies = report.newAssemblies + 1
                                    sampleScatterMovement(room, report, assemblyRoot, initialPosition, ownedParts)
                                else
                                    report.velocityErrors = report.velocityErrors + 1
                                end
                            elseif assemblyRoot and assemblyRoot.Anchored
                                and not report.seenBlockedRoots[assemblyRoot] then
                                report.seenBlockedRoots[assemblyRoot] = true
                                report.blockedRoots = report.blockedRoots + 1
                            end
                        end
                    end
                end
            end
        end
    end

    local function getOrderedRooms()
        local currentRooms =
            workspace:FindFirstChild("CurrentRooms")

        local orderedRooms = {}

        if not currentRooms then
            return orderedRooms
        end

        for _, room in ipairs(currentRooms:GetChildren()) do
            if room:IsA("Model") then
                local roomNumber = tonumber(room.Name)

                if roomNumber then
                    table.insert(
                        orderedRooms,
                        {
                            Number = roomNumber,
                            Room = room
                        }
                    )
                end
            end
        end

        table.sort(
            orderedRooms,
            function(a, b)
                return a.Number < b.Number
            end
        )

        return orderedRooms
    end

    local function getOrderedNodes(pathfindNodes)
        local orderedNodes = {}

        for _, node in ipairs(
            pathfindNodes:GetChildren()
        ) do
            if node:IsA("BasePart") then
                table.insert(orderedNodes, node)
            end
        end

        table.sort(
            orderedNodes,
            function(a, b)
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
            end
        )

        return orderedNodes
    end

    local function moveRipperTo(targetCFrame, speedFactor)
        if isJumpScaring or crucifixActivated or isRipperDespawning
            or not ripper or not ripper.Parent then
            return false
        end

        local movingRipper = ripper
        ripperMoveCancelled = false
        ripperIsMoving = true

        local startCFrame = movingRipper.CFrame
        local totalDistance = (startCFrame.Position - targetCFrame.Position).Magnitude
        local travelled = 0

        while not ripperMoveCancelled and not isJumpScaring
            and not crucifixActivated and not isRipperDespawning
            and ripper == movingRipper and movingRipper.Parent do
            local deltaTime = RunService.Heartbeat:Wait()

            if ripperMoveCancelled or isJumpScaring or crucifixActivated
                or isRipperDespawning or ripper ~= movingRipper
                or not movingRipper.Parent then
                break
            end

            if totalDistance > 0.001 and travelled < totalDistance then
                travelled = math.min(
                    travelled + math.max(speedFactor, 0) * ceaseSpeedScale * math.min(deltaTime, 0.1),
                    totalDistance
                )
                movingRipper.CFrame = startCFrame:Lerp(targetCFrame, travelled / totalDistance)
            else
                movingRipper.CFrame = targetCFrame
                travelled = totalDistance
            end

            if travelled >= totalDistance and not ceaseFreezeActive then
                ripperIsMoving = false
                return true
            end
        end

        ripperIsMoving = false
        return false
    end

    -- Old eipperspawne RunBla: only the door impact / fallen door segment.
    -- No wind-up, reverse dash, or extra movement logic is transplanted.
    local ripperKnockedDoors = setmetatable({}, { __mode = "k" })

    local function KnockDownRipperEndingDoor(room, ripperPart)
        if not room or not room.Parent or ripperKnockedDoors[room] then
            return false
        end

        local doorModel = room:FindFirstChild("Door")
        if not doorModel then
            return false
        end

        local function findDoorPanel(root)
            if root:IsA("BasePart") and root.Name == "Door" then
                return root
            end
            local fallback = nil
            for _, item in ipairs(root:GetDescendants()) do
                if item:IsA("MeshPart") and item.Name == "Door" then
                    return item
                elseif item:IsA("BasePart") and item.Name == "Door" then
                    fallback = fallback or item
                end
            end
            return fallback
        end

        local originalDoor = findDoorPanel(doorModel)
        if not originalDoor then
            return false
        end

        -- Clone the COMPLETE door hierarchy. Clone() silently skips any
        -- descendants whose Archivable is false, so temporarily enable it
        -- for the root AND every child, then always restore the old values.
        local temporarilyArchivable = {}
        local function enableCloning(object)
            if not object.Archivable then
                table.insert(temporarilyArchivable, object)
                object.Archivable = true
            end
        end

        local ok, doorClone = pcall(function()
            enableCloning(doorModel)
            for _, descendant in ipairs(doorModel:GetDescendants()) do
                enableCloning(descendant)
            end
            return doorModel:Clone()
        end)

        for _, object in ipairs(temporarilyArchivable) do
            pcall(function()
                object.Archivable = false
            end)
        end

        if not ok or not doorClone then
            return false
        end

        doorClone.Name = "RipperEndDoorClone"
        local fallenPanel = findDoorPanel(doorClone)
        if not fallenPanel then
            doorClone:Destroy()
            return false
        end

        -- The door is a local visual duplicate, not a second functional door.
        for _, item in ipairs(doorClone:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript")
                or item:IsA("ModuleScript") or item:IsA("Sound")
                or item:IsA("WeldConstraint") or item:IsA("JointInstance")
                or item:IsA("Constraint") then
                item:Destroy()
            elseif item:IsA("BasePart") then
                item.Anchored = true
                item.CanCollide = false
                item.CanTouch = false
                item.CanQuery = false
                if item.Name == "Hidden" then
                    item.Transparency = 1
                end
            end
        end
        if doorClone:IsA("BasePart") then
            doorClone.Anchored = true
            doorClone.CanCollide = false
            doorClone.CanTouch = false
            doorClone.CanQuery = false
        end

        -- Rotate EVERY cloned BasePart as one rigid door assembly, using
        -- the original door panel as the shared pivot. A single panel.CFrame
        -- assignment left the knob, trims, handles, and nested models upright.
        local originalPanelCFrame = fallenPanel.CFrame
        local targetPanelCFrame = originalPanelCFrame
            * CFrame.Angles(math.rad(-90), 0, 0)
            * CFrame.new(0, 7, -3.7)
        local assemblyTransform = targetPanelCFrame * originalPanelCFrame:Inverse()

        local clonedDoorParts = {}
        if doorClone:IsA("BasePart") then
            table.insert(clonedDoorParts, doorClone)
        end
        for _, descendant in ipairs(doorClone:GetDescendants()) do
            if descendant:IsA("BasePart") then
                table.insert(clonedDoorParts, descendant)
            end
        end

        if #clonedDoorParts == 0 then
            doorClone:Destroy()
            return false
        end

        doorClone.Parent = room
        for _, part in ipairs(clonedDoorParts) do
            part.CFrame = assemblyTransform * part.CFrame
        end

        ripperKnockedDoors[room] = true
        -- Hide the functional original only on this client; never Destroy it.
        -- Non-door trim is replaced by its copy, just like the old effect.
        local function hideOriginal(item)
            if item:IsA("BasePart") then
                item.Transparency = 1
                item.LocalTransparencyModifier = 1
                item.CanCollide = false
                item.CanTouch = false
                item.CanQuery = false
            elseif item:IsA("Decal") or item:IsA("Texture") then
                item.Transparency = 1
            elseif item:IsA("SurfaceGui") then
                item.Enabled = false
            elseif item:IsA("Sound") then
                -- Original eipperspawne RunBla also silences every Sound
                -- owned by the original Door model after the fall.
                -- Stop current playback AND mute future replays.
                -- Keep the original Sound instance intact.
                item:Stop()
                item.Volume = 0
            end
        end
        hideOriginal(doorModel)
        for _, item in ipairs(doorModel:GetDescendants()) do
            hideOriginal(item)
        end

        -- Impact sound: prefer the old DoorOpen1. The normal ending explosion
        -- Sound and camera shake below still run even if it is unavailable.
        local oldDoorSound = (ripperPart and ripperPart:FindFirstChild("DoorOpen1", true))
            or doorModel:FindFirstChild("DoorOpen1", true)
        if oldDoorSound and oldDoorSound:IsA("Sound") then
            local impact = oldDoorSound:Clone()
            impact.Name = "RipperEndDoorImpact"
            impact.Looped = false
            impact.PlayOnRemove = false
            impact.Volume = 5
            impact.Parent = fallenPanel
            impact.Ended:Once(function()
                if impact.Parent then impact:Destroy() end
            end)
            game:GetService("Debris"):AddItem(impact, 12)
            impact:Play()
        end

        -- The clone is parented to CurrentRooms and is therefore cleaned up
        -- automatically when the room unloads. Avoid a permanent Workspace leak.
        return true
    end

    local function ExecuteRipperPathfinding()
        isRipperDespawning = false
        local RIPPER_MODEL_ID = "137652444095718"

        local success, loadedAsset = pcall(function()
            return game:GetObjects(
                "rbxassetid://" .. RIPPER_MODEL_ID
            )[1]
        end)

        if not success or not loadedAsset then
            ripperAsset = nil
            return
        end

        ripperAsset = loadedAsset

        local basePart =
            ripperAsset:FindFirstChildWhichIsA(
                "BasePart",
                true
            )

        if not basePart then
            ripperAsset:Destroy()
            ripperAsset = nil
            return
        end

        ripper = basePart:Clone()
        ripper.Anchored = true
        ripper.CanQuery = true
        ripper.Parent = workspace

        local orderedRooms = getOrderedRooms()

        if #orderedRooms == 0 then
            ripper:Destroy()
            ripper = nil
            ripperAsset:Destroy()
            ripperAsset = nil
            return
        end

        local MAX_RIPPER_ROOMS = 10
        local startRoomIndex = 1

        if #orderedRooms > MAX_RIPPER_ROOMS then
            startRoomIndex = #orderedRooms - 8
        end

        local startRoom = orderedRooms[startRoomIndex].Room
        local startNode = nil
        local startPathfindNodes =
            startRoom:FindFirstChild("PathfindNodes")

        if startPathfindNodes then
            local startNodes =
                getOrderedNodes(startPathfindNodes)

            startNode = startNodes[1]
        end

        if not startNode then
            startNode =
                startRoom:FindFirstChild("RoomExit")
        end

        if not startNode
            or not startNode:IsA("BasePart")
        then
            ripper:Destroy()
            ripper = nil
            ripperAsset:Destroy()
            ripperAsset = nil
            return
        end

        local heightOffset = Vector3.new(0, 1.3, 0)
        local speedFactor = 100

        ripper.CFrame =
            startNode.CFrame + heightOffset

        local cameraShaker = nil
        local cameraShakerModule =
            game.ReplicatedStorage:FindFirstChild(
                "CameraShaker"
            )

        if cameraShakerModule then
            local loaded, CameraShakerModule = pcall(require, cameraShakerModule)

            if loaded and CameraShakerModule then
                cameraShaker = newRipperCameraShaker(CameraShakerModule, 
                    Enum.RenderPriority.Camera.Value,
                    function(shakerTransform)
                        local camera = workspace.CurrentCamera

                        if camera then
                            camera.CFrame = camera.CFrame * shakerTransform
                        end
                    end
                )

                cameraShaker:Start()

                local shakerRipper = ripper
                task.spawn(function()
                    while shakerRipper and shakerRipper.Parent do
                        task.wait(0.25)
                    end

                    if cameraShaker then
                        pcall(function()
                            cameraShaker:Stop()
                        end)
                    end
                end)
            end
        end

        task.spawn(function()
            while ripper and ripper.Parent and not isJumpScaring
                and not isRipperDespawning do
                if ripperIsMoving and not ceaseFreezeActive then
                    local ceaseModel = workspace:FindFirstChild("Cease", true)
                    if ceaseModel and ceaseModel:IsA("Model")
                        and not ceaseHandledModels[ceaseModel] then
                        startCeaseFreeze(ceaseModel)
                    end
                end
                task.wait(0.1)
            end

            if ceaseFreezeActive then
                cancelCeaseFreeze()
            end
        end)

        task.spawn(function()
            while ripper and ripper.Parent and not crucifixActivated
                and not isJumpScaring and not isRipperDespawning do
                if scanPlayerCrucifixRaycasts() then
                    return
                end
                task.wait(0.05)
            end
        end)

        local lastProximityShake = 0

        task.spawn(function()
            while ripper
                and ripper.Parent
                and not crucifixActivated
                and not isJumpScaring
                and not isRipperDespawning
            do
                task.wait(0.12)

                if crucifixActivated or isJumpScaring or isRipperDespawning
                    or not ripper or not ripper.Parent then
                    return
                end

                local visibleRipper = ripper
                local player = Players.LocalPlayer

                if player and player.Character and cameraShaker then
                    local character = player.Character
                    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if humanoid and rootPart and humanoid.Health > 0 then
                        local distance = (visibleRipper.Position - rootPart.Position).Magnitude

                        if distance <= 80
                            and os.clock() - lastProximityShake >= 0.12
                        then
                            local alpha = math.clamp(1 - distance / 80, 0, 1)
                            local amplitude = (0.3 + 8.2 * (alpha ^ 1.35)) * 3
                            local roughness = 45 + 35 * alpha
                            local positionInfluence = 0.35 + 0.4 * alpha
                            local rotationInfluence = 0.3 + 0.4 * alpha

                            cameraShaker:ShakeOnce(
                                amplitude,
                                roughness,
                                0.01,
                                0.16,
                                positionInfluence,
                                rotationInfluence
                            )

                            lastProximityShake = os.clock()
                        end

                    end
                end
            end
        end)

        task.spawn(function()
            while ripper
                and ripper.Parent
                and not crucifixActivated
                and not isJumpScaring
                and not isRipperDespawning
            do
                RunService.RenderStepped:Wait()

                if crucifixActivated or isJumpScaring or isRipperDespawning
                    or not ripper or not ripper.Parent then
                    return
                end

                local visibleRipper = ripper
                local player = Players.LocalPlayer

                if player and player.Character then
                    local character = player.Character
                    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")

                    if humanoid and rootPart and humanoid.Health > 0 then
                        local distance = (visibleRipper.Position - rootPart.Position).Magnitude

                        if distance <= 50 and not character:GetAttribute("Hiding") then
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                            raycastParams.FilterDescendantsInstances = { visibleRipper }

                            local targets = { rootPart }
                            for _, name in ipairs({ "Head", "UpperTorso", "Torso", "LowerTorso" }) do
                                local bodyPart = character:FindFirstChild(name)
                                if bodyPart and bodyPart:IsA("BasePart") then
                                    table.insert(targets, bodyPart)
                                end
                            end

                            for _, targetPart in ipairs(targets) do
                                local direction = targetPart.Position - visibleRipper.Position
                                local rayDistance = direction.Magnitude

                                if rayDistance > 0.001 and rayDistance <= 50 then
                                    local raycastResult = workspace:Raycast(
                                        visibleRipper.Position,
                                        direction,
                                        raycastParams
                                    )
                                    local hitCharacter = raycastResult
                                        and getCharacterFromRaycastHit(raycastResult.Instance)

                                    if hitCharacter and hitCharacter ~= character then
                                        if tryUseCrucifix(hitCharacter, "AWF") then
                                            return
                                        end
                                    end

                                    local hitsPlayer = hitCharacter == character

                                    if not hitsPlayer then
                                        local entryDistance = rayEntryDistanceToPart(
                                            visibleRipper.Position,
                                            direction.Unit,
                                            targetPart
                                        )
                                        if entryDistance
                                            and entryDistance <= rayDistance + 0.01
                                            and (not raycastResult
                                                or raycastResult.Distance > entryDistance + 0.02)
                                        then
                                            hitsPlayer = true
                                        end
                                    end

                                    if hitsPlayer then
                                        if tryUseCrucifix(character, "EFAF") then
                                            return
                                        end

                                        TriggerRipperJumpScare(
                                            visibleRipper,
                                            character,
                                            visibleRipper.Position
                                        )
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)

        local targetRoomIndex =
            math.max(1, #orderedRooms - 1)

        local reachedFinalRoom = false
        local completedRoomIndex = 0

        for roomIndex = startRoomIndex, targetRoomIndex do
            if isJumpScaring
                or crucifixActivated
                or isRipperDespawning
                or not ripper
                or not ripper.Parent
            then
                break
            end

            local roomData =
                orderedRooms[roomIndex]

            local room =
                roomData and roomData.Room

            if not room or not room.Parent then
                local refreshDeadline =
                    os.clock() + 5

                repeat
                    task.wait(0.1)

                    orderedRooms =
                        getOrderedRooms()

                    roomData =
                        orderedRooms[roomIndex]

                    room =
                        roomData and roomData.Room
                until room
                    or os.clock()
                        >= refreshDeadline
                    or isJumpScaring
                    or crucifixActivated
                    or isRipperDespawning
                    or not ripper
                    or not ripper.Parent
            end

            if not room or not room.Parent then
                break
            end

            scatterRipperRoomObjects(room)
            local roomScatterActive = true
            local roomScatterScheduled = false
            local roomScatterConnection = room.DescendantAdded:Connect(function(descendant)
                if not roomScatterActive then
                    return
                end
                if not descendant:IsA("BasePart")
                    and not (ripperScatterNames[descendant.Name]
                        and (descendant:IsA("Model") or descendant:IsA("Folder"))) then
                    return
                end

                local current = descendant
                local relevant = false
                while current and current ~= room do
                    if ripperScatterNames[current.Name] then
                        relevant = true
                        break
                    end
                    current = current.Parent
                end
                if relevant and not roomScatterScheduled then
                    roomScatterScheduled = true
                    task.defer(function()
                        roomScatterScheduled = false
                        if roomScatterActive and room.Parent then
                            scatterRipperRoomObjects(room)
                        end
                    end)
                end
            end)

            local roomCompleted = false
            local pathfindNodes =
                room:FindFirstChild(
                    "PathfindNodes"
                )

            if pathfindNodes then
                local orderedNodes =
                    getOrderedNodes(
                        pathfindNodes
                    )

                if #orderedNodes > 0 then
                    roomCompleted = true

                    for _, node in ipairs(
                        orderedNodes
                    ) do
                        if isJumpScaring
                            or crucifixActivated
                            or isRipperDespawning
                            or not ripper
                            or not ripper.Parent
                        then
                            roomCompleted = false
                            break
                        end

                        local moved =
                            moveRipperTo(
                                node.CFrame
                                    + heightOffset,
                                speedFactor
                            )

                        if not moved then
                            roomCompleted = false
                            break
                        end
                    end
                end
            end

            if not roomCompleted then
                local roomExit =
                    room:FindFirstChild(
                        "RoomExit"
                    )

                if roomExit
                    and roomExit:IsA(
                        "BasePart"
                    )
                then
                    roomCompleted =
                        moveRipperTo(
                            roomExit.CFrame
                                + heightOffset,
                            speedFactor
                        )
                end
            end

            roomScatterActive = false
            roomScatterConnection:Disconnect()
            if roomCompleted then
                scatterRipperRoomObjects(room)
            end

            if not roomCompleted then
                break
            end

            completedRoomIndex = roomIndex

            if roomIndex
                == targetRoomIndex
            then
                reachedFinalRoom = true
            end
        end


        if isJumpScaring
            or crucifixActivated
            or not ripper
            or not ripper.Parent
        then
            ripper = nil
            ripperAsset = nil
            return
        end

        if isJumpScaring then
            return
        end

        if not reachedFinalRoom
            or completedRoomIndex
                < targetRoomIndex
        then
            if ripper and ripper.Parent then
                ripper:Destroy()
            end

            if ripperAsset then
                ripperAsset:Destroy()
            end

            ripper = nil
            ripperAsset = nil
            return
        end

        isRipperDespawning = true
        if backgroundSound and backgroundSound:IsA("Sound") then
            backgroundSound:Stop()
            backgroundSound.TimePosition = 0
        end
        local NEAR_EXPLOSION_DISTANCE = 80
        local FAR_EXPLOSION_DISTANCE = 220
        local SHAKE_MAX_DISTANCE = 350
        local MAX_EXPLOSION_SHAKE = 24

        local localPlayer = Players.LocalPlayer
        local playerRoot = nil

        if localPlayer and localPlayer.Character then
            playerRoot =
                localPlayer.Character:FindFirstChild(
                    "HumanoidRootPart"
                )
        end

        local ripperDistance = math.huge

        if playerRoot and ripper and ripper.Parent then
            ripperDistance =
                (
                    playerRoot.Position
                    - ripper.Position
                ).Magnitude
        end

        local rushNew = nil

        if ripper and ripper.Parent then
            if ripper.Name == "RushNew" then
                rushNew = ripper
            else
                rushNew =
                    ripper:FindFirstChild(
                        "RushNew",
                        true
                    )
            end
        end

        if not rushNew
            and ripperAsset
        then
            rushNew =
                ripperAsset:FindFirstChild(
                    "RushNew",
                    true
                )
        end

        local explodeSound = nil

        if ripperDistance
            <= NEAR_EXPLOSION_DISTANCE
        then
            local explosionSound =
                hardCoreSound and hardCoreSound:FindFirstChild("RipperExplosionSound")

            if explosionSound
                and explosionSound:IsA("Sound")
            then
                explodeSound = Instance.new("Sound")
                explodeSound.SoundId =
                    explosionSound.SoundId
                explodeSound.Volume = 5
                explodeSound.PlaybackSpeed =
                    explosionSound.PlaybackSpeed
                explodeSound.Parent = ripper
            end
        elseif ripperDistance
            <= FAR_EXPLOSION_DISTANCE
        then
            local despawn2 =
                rushNew
                and rushNew:FindFirstChild(
                    "Despawn2"
                )

            if despawn2
                and despawn2:IsA("Sound")
            then
                explodeSound = despawn2:Clone()
                explodeSound.Volume = 10
                explodeSound.Parent = ripper
            end
        else
            local despawn3 =
                rushNew
                and rushNew:FindFirstChild(
                    "Despawn3"
                )

            if despawn3
                and despawn3:IsA("Sound")
            then
                explodeSound = despawn3:Clone()
                explodeSound.Volume = 10
                explodeSound.Parent = ripper
            end
        end

        if not explodeSound then
            local explosionSound =
                hardCoreSound and hardCoreSound:FindFirstChild("RipperExplosionSound")

            if explosionSound
                and explosionSound:IsA("Sound")
            then
                explodeSound = Instance.new("Sound")
                explodeSound.SoundId =
                    explosionSound.SoundId
                explodeSound.Volume = 5
                explodeSound.PlaybackSpeed =
                    explosionSound.PlaybackSpeed
                explodeSound.Parent = ripper
            end
        end

        -- Knock down the panel exactly when the ending explosion hits.
        -- Ripper finishes at the penultimate ordered room's RoomExit.
        local endingRoomData = orderedRooms[targetRoomIndex]
        local endingRoom = endingRoomData and endingRoomData.Room
        if endingRoom and ripper and ripper.Parent then
            pcall(KnockDownRipperEndingDoor, endingRoom, ripper)
        end

        if explodeSound then
            explodeSound:Play()
        end

        local shakeAmplitude = 0

        if ripperDistance
            <= NEAR_EXPLOSION_DISTANCE
        then
            shakeAmplitude = MAX_EXPLOSION_SHAKE
        elseif ripperDistance
            < SHAKE_MAX_DISTANCE
        then
            local alpha =
                1
                - (
                    ripperDistance
                    - NEAR_EXPLOSION_DISTANCE
                )
                / (
                    SHAKE_MAX_DISTANCE
                    - NEAR_EXPLOSION_DISTANCE
                )

            shakeAmplitude =
                MAX_EXPLOSION_SHAKE
                * math.clamp(alpha, 0, 1)
        end

        if cameraShakerModule
            and shakeAmplitude > 0
        then
            local endExplosionCameraShaker =
                require(cameraShakerModule)

            local endExplosionCam =
                workspace.CurrentCamera

            local endExplosionCamShake =
                newRipperCameraShaker(endExplosionCameraShaker, 
                    Enum.RenderPriority.Camera.Value,
                    function(shakeCf)
                        if endExplosionCam then
                            endExplosionCam.CFrame =
                                endExplosionCam.CFrame
                                * shakeCf
                        end
                    end
                )

            endExplosionCamShake:Start()

            endExplosionCamShake:ShakeOnce(
                shakeAmplitude,
                28,
                0.03,
                0.4,
                0.25,
                0.35
            )

            task.delay(1, function()
                pcall(function()
                    endExplosionCamShake:Stop()
                end)
            end)
        end

        task.wait(1)


        for _, playerToCheck in ipairs(Players:GetPlayers()) do
            local candidateCharacter = playerToCheck.Character
            if candidateCharacter and getCrucifixTool(candidateCharacter) then

                if tryUseCrucifix(candidateCharacter, "DV Hiding FD") then
                    return
                end
            end
        end

        local finalRipperPosition = nil

        if ripper and ripper.Parent then
            finalRipperPosition = ripper.Position
            ripper.Anchored = false
            ripper.CanCollide = false
            ripper.CanTouch = false
            ripper.CanQuery = false
        end

        if isJumpScaring or not ripper or not ripper.Parent then
            return
        end

        local player = Players.LocalPlayer

        if player and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")

            if humanoid
                and humanoid.Health > 0
                and not character:GetAttribute("Hiding")
                and finalRipperPosition
            then
                TriggerRipperJumpScare(
                    ripper,
                    character,
                    finalRipperPosition
                )
                return
            end
        end

        local fallingRipper = ripper
        local fallingAsset = ripperAsset
        ripperAsset = nil

        task.delay(10, function()
            if fallingRipper and fallingRipper.Parent then
                fallingRipper:Destroy()
            end

            if fallingAsset then
                fallingAsset:Destroy()
            end

            if ripper == fallingRipper then
                ripper = nil
            end

            if ripperAsset == fallingAsset then
                ripperAsset = nil
            end
        end)
    end

    task.spawn(function()
        task.wait(7)
        ExecuteRipperPathfinding()
    end)

    local function runFinalCameraShake()
        local cameraShakerModule =
            game.ReplicatedStorage:FindFirstChild(
                "CameraShaker"
            )

        if not cameraShakerModule then
            return
        end

        local CameraShaker =
            require(cameraShakerModule)

        local camera =
            workspace.CurrentCamera

        local camShake =
            newRipperCameraShaker(CameraShaker, 
                Enum.RenderPriority.Camera.Value,
                function(shakeCf)
                    if camera then
                        camera.CFrame =
                            camera.CFrame
                            * shakeCf
                    end
                end
            )

        camShake:Start()

        camShake:ShakeOnce(
            5,
            200,
            0.1,
            6,
            2,
            0.5
        )

        task.delay(7, function()
            pcall(function()
                camShake:Stop()
            end)
        end)
    end
    runFinalCameraShake()
end

function entityBehaviors.GodEgg()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local REPLACEMENT_CONFIG = {
    ["generatorfuse"] = {assetId = 138693840664582}
}
local CHECK_INTERVAL = 0.3
local trackedTargets = {}

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

local function hideGeneratorFuseParts(generatorFuse)
    if not generatorFuse or not generatorFuse.Parent then return end
    
    local function hideRecursive(obj)
        if obj:IsA("MeshPart") or obj:IsA("BasePart") then
            if not trackedTargets[generatorFuse] then
                trackedTargets[generatorFuse] = {originalParts = {}}
            end
            trackedTargets[generatorFuse].originalParts[obj] = {transparency = obj.Transparency}
            obj.Transparency = 1
        end
        
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            if not trackedTargets[generatorFuse] then
                trackedTargets[generatorFuse] = {originalParts = {}}
            end
            trackedTargets[generatorFuse].originalParts[obj] = {enabled = obj.Enabled}
            obj.Enabled = false
        end
        
        if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
            if not trackedTargets[generatorFuse] then
                trackedTargets[generatorFuse] = {originalParts = {}}
            end
            trackedTargets[generatorFuse].originalParts[obj] = {transparency = obj.Transparency}
            obj.Transparency = 1
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            hideRecursive(child)
        end
    end
    
    hideRecursive(generatorFuse)
end

local function restoreGeneratorFuse(generatorFuse)
    local data = trackedTargets[generatorFuse]
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
    
    effectModel.Name = "GeneratorFuse_Follower"
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
        effectModel:PivotTo(targetCFrame)
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
    
    data.effect:PivotTo(targetCFrame)
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
    
    hideGeneratorFuseParts(target)
    
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
        restoreGeneratorFuse(target)
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

local function findAllGeneratorFuses()
    local targets = {}
    
    local function findGeneratorFusesRecursive(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name:lower() == "generatorfuse" then
                local config = getItemConfig(child.Name)
                if config then
                    table.insert(targets, {target = child, config = config})
                end
            end
            findGeneratorFusesRecursive(child)
        end
    end
    
    findGeneratorFusesRecursive(workspace)
    return targets
end

local function startDetection()
    local lastCheckTime = 0
    
    while true do
        local currentTime = tick()
        
        if currentTime - lastCheckTime >= CHECK_INTERVAL then
            lastCheckTime = currentTime
            
            cleanupDestroyedTargets()
            
            local allGeneratorFuses = findAllGeneratorFuses()
            
            for _, targetData in ipairs(allGeneratorFuses) do
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

function entityBehaviors.MLbody()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local REPLACEMENT_CONFIG = {
    ["starjug"] = {assetId = 89687019396850}
}
local CHECK_INTERVAL = 0.3
local trackedTargets = {}

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

local function hideStarJugParts(starJug)
    if not starJug or not starJug.Parent then return end
    
    local function hideRecursive(obj)
        if obj:IsA("MeshPart") or obj:IsA("BasePart") then
            if not trackedTargets[starJug] then
                trackedTargets[starJug] = {originalParts = {}}
            end
            trackedTargets[starJug].originalParts[obj] = {transparency = obj.Transparency}
            obj.Transparency = 1
        end
        
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            if not trackedTargets[starJug] then
                trackedTargets[starJug] = {originalParts = {}}
            end
            trackedTargets[starJug].originalParts[obj] = {enabled = obj.Enabled}
            obj.Enabled = false
        end
        
        if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
            if not trackedTargets[starJug] then
                trackedTargets[starJug] = {originalParts = {}}
            end
            trackedTargets[starJug].originalParts[obj] = {transparency = obj.Transparency}
            obj.Transparency = 1
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            hideRecursive(child)
        end
    end
    
    hideRecursive(starJug)
end

local function restoreStarJug(starJug)
    local data = trackedTargets[starJug]
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
    effectModel.Name = "StarJug_Follower"
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
        effectModel:PivotTo(targetCFrame)
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
    
    data.effect:PivotTo(targetCFrame)
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
    
    hideStarJugParts(target)
    
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
        restoreStarJug(target)
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
local function findAllStarJugs()
    local targets = {}
    local function findStarJugsRecursive(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name:lower() == "starjug" then
                local config = getItemConfig(child.Name)
                if config then
                    table.insert(targets, {target = child, config = config})
                end
            end
            findStarJugsRecursive(child)
        end
    end
    findStarJugsRecursive(workspace)
    return targets
end

local function startDetection()
    local lastCheckTime = 0
    
    while true do
        local currentTime = tick()
        if currentTime - lastCheckTime >= CHECK_INTERVAL then
            lastCheckTime = currentTime
            
            cleanupDestroyedTargets()
            
            local allStarJugs = findAllStarJugs()
            
            for _, targetData in ipairs(allStarJugs) do
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

function entityBehaviors.guidingjug()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local REPLACEMENT_CONFIG = {
    ["starjug"] = {assetId = 90395549970314}
}
local CHECK_INTERVAL = 0.3
local trackedTargets = {}

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

local function hideStarJugParts(starJug)
    if not starJug or not starJug.Parent then return end
    
    local function hideRecursive(obj)
        if obj:IsA("MeshPart") or obj:IsA("BasePart") then
            if not trackedTargets[starJug] then
                trackedTargets[starJug] = {originalParts = {}}
            end
            trackedTargets[starJug].originalParts[obj] = {transparency = obj.Transparency}
            obj.Transparency = 1
        end
        
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            if not trackedTargets[starJug] then
                trackedTargets[starJug] = {originalParts = {}}
            end
            trackedTargets[starJug].originalParts[obj] = {enabled = obj.Enabled}
            obj.Enabled = false
        end
        
        if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
            if not trackedTargets[starJug] then
                trackedTargets[starJug] = {originalParts = {}}
            end
            trackedTargets[starJug].originalParts[obj] = {transparency = obj.Transparency}
            obj.Transparency = 1
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            hideRecursive(child)
        end
    end
    
    hideRecursive(starJug)
end

local function restoreStarJug(starJug)
    local data = trackedTargets[starJug]
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
    
    effectModel.Name = "StarJug_Follower"
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
        effectModel:PivotTo(targetCFrame)
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
    
    data.effect:PivotTo(targetCFrame)
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
    
    hideStarJugParts(target)
    
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
        restoreStarJug(target)
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

local function findAllStarJugs()
    local targets = {}
    
    local function findStarJugsRecursive(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name:lower() == "starjug" then
                local config = getItemConfig(child.Name)
                if config then
                    table.insert(targets, {target = child, config = config})
                end
            end
            findStarJugsRecursive(child)
        end
    end
    
    findStarJugsRecursive(workspace)
    return targets
end

local function startDetection()
    local lastCheckTime = 0
    
    while true do
        local currentTime = tick()
        
        if currentTime - lastCheckTime >= CHECK_INTERVAL then
            lastCheckTime = currentTime
            
            cleanupDestroyedTargets()
            
            local allStarJugs = findAllStarJugs()
            
            for _, targetData in ipairs(allStarJugs) do
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

function entityBehaviors.gunjeffkq()
local sound = Instance.new("Sound")
sound.Name = "Subspace"
sound.SoundId = "rbxassetid://89344175304287"
sound.Volume = 4
sound.Parent = workspace

sound.Ended:Connect(function()
    sound:Destroy()
end)
sound:Play()
end

function entityBehaviors.JEFFGUN2()
local RunService = game:GetService("RunService")
local V1 = game:GetObjects("rbxassetid://134258088105212")[1]
V1.Parent = workspace
local V2 = workspace:WaitForChild("JeffTheKiller")

local xOffset = 0
local yOffset = 0
local zOffset = 0

if V1:IsA("Model") then
    local primary = V1:FindFirstChildWhichIsA("BasePart")
    if primary then
        V1.PrimaryPart = primary
    end
end

local function HS()
    if not V2 then return end
    
    local function HP(obj)
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.CanCollide = false
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
                child.Transparency = 1
            elseif child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
                child.Enabled = false
            end
            
            HP(child)
        end
    end
    
    local p1 = V2:FindFirstChild("Knife")
    local p2 = V2:FindFirstChild("Head")
    local p3 = V2:FindFirstChild("BoyAnimeHair_Black")
    if p1 then HP(p1) end
    if p2 then HP(p2) end
    if p3 then
        local h = p3:Clone()
        h.Parent = V2
        HP(h)
    end
    
    local leftArm = V2:FindFirstChild("Left Arm")
    local rightArm = V2:FindFirstChild("Right Arm")
    if leftArm then HP(leftArm) end
    if rightArm then HP(rightArm) end
end

HS()

local connection
connection = V2.AncestryChanged:Connect(function(_, parent)
    if not parent then
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not V2 or not V2.Parent then 
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
        return 
    end

    local function findRootPart(model)
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
        if root then 
            return root 
        end
        
        for _, child in pairs(model:GetDescendants()) do
            if (child.Name == "HumanoidRootPart" or child.Name == "Torso") and child:IsA("BasePart") then
                return child
            end
        end
        return nil
    end
    
    local root = findRootPart(V2)
    if not root then 
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
        return
    end
    if V1:IsA("Model") then
        if not V1.PrimaryPart then
            local part = V1:FindFirstChildWhichIsA("BasePart")
            if part then
                V1.PrimaryPart = part
            end
        end
        
        if V1.PrimaryPart then
            local newCFrame = CFrame.new(
                root.CFrame.Position.X + xOffset,
                root.CFrame.Position.Y + yOffset,
                root.CFrame.Position.Z + zOffset
            ) * root.CFrame.Rotation
            V1:SetPrimaryPartCFrame(newCFrame)
        end
    elseif V1:IsA("BasePart") then
        local newCFrame = CFrame.new(
            root.CFrame.Position.X + xOffset,
            root.CFrame.Position.Y + yOffset,
            root.CFrame.Position.Z + zOffset
        ) * root.CFrame.Rotation
        V1.CFrame = newCFrame
    end
end)
end

function entityBehaviors.JEFFGUN3()
local RunService = game:GetService("RunService")
local V1 = game:GetObjects("rbxassetid://128269554312849")[1]
V1.Parent = workspace
local V2 = workspace:WaitForChild("JeffTheKiller")

local xOffset = 0
local yOffset = 0
local zOffset = 0

if V1:IsA("Model") then
    local primary = V1:FindFirstChildWhichIsA("BasePart")
    if primary then
        V1.PrimaryPart = primary
    end
end

local function HS()
    if not V2 then return end
    
    local function HP(obj)
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.CanCollide = false
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
                child.Transparency = 1
            elseif child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
                child.Enabled = false
            end
            
            HP(child)
        end
    end
    
    local p1 = V2:FindFirstChild("Knife")
    local p2 = V2:FindFirstChild("Head")
    local p3 = V2:FindFirstChild("BoyAnimeHair_Black")
    if p1 then HP(p1) end
    if p2 then HP(p2) end
    if p3 then
        local h = p3:Clone()
        h.Parent = V2
        HP(h)
    end
    
    local leftArm = V2:FindFirstChild("Left Arm")
    local rightArm = V2:FindFirstChild("Right Arm")
    if leftArm then HP(leftArm) end
    if rightArm then HP(rightArm) end
end

HS()

local connection
connection = V2.AncestryChanged:Connect(function(_, parent)
    if not parent then
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not V2 or not V2.Parent then 
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
        return 
    end

    local function findRootPart(model)
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
        if root then 
            return root 
        end
        
        for _, child in pairs(model:GetDescendants()) do
            if (child.Name == "HumanoidRootPart" or child.Name == "Torso") and child:IsA("BasePart") then
                return child
            end
        end
        return nil
    end
    
    local root = findRootPart(V2)
    if not root then 
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
        return
    end
    if V1:IsA("Model") then
        if not V1.PrimaryPart then
            local part = V1:FindFirstChildWhichIsA("BasePart")
            if part then
                V1.PrimaryPart = part
            end
        end
        
        if V1.PrimaryPart then
            local newCFrame = CFrame.new(
                root.CFrame.Position.X + xOffset,
                root.CFrame.Position.Y + yOffset,
                root.CFrame.Position.Z + zOffset
            ) * root.CFrame.Rotation
            V1:SetPrimaryPartCFrame(newCFrame)
        end
    elseif V1:IsA("BasePart") then
        local newCFrame = CFrame.new(
            root.CFrame.Position.X + xOffset,
            root.CFrame.Position.Y + yOffset,
            root.CFrame.Position.Z + zOffset
        ) * root.CFrame.Rotation
        V1.CFrame = newCFrame
    end
end)
end


function entityBehaviors.A333ONE()
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local random = Random.new()
local latestRoom = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom")
local music = Workspace:WaitForChild("HardCoreSound"):WaitForChild("A333Music")

latestRoom.Changed:Wait()

local function getRoom()
    return Workspace:WaitForChild("CurrentRooms"):FindFirstChild(tostring(latestRoom.Value))
end

local model
local loaded = pcall(function()
    local room = getRoom()
    if not room then
        error("Current room not found")
    end

    local entrance = room:WaitForChild("RoomEntrance")
    local objects = game:GetObjects("rbxassetid://129270013455588")
    model = objects[1]
    if not model then
        error("Model failed to load")
    end

    model.Parent = Workspace
    local spawnCFrame = entrance.CFrame * CFrame.new(0, 2, -15)

    if model:IsA("Model") then
        model:PivotTo(spawnCFrame)
    elseif model:IsA("BasePart") then
        model.CFrame = spawnCFrame
        local innerPart = model:FindFirstChild("Part")
        if innerPart and innerPart:IsA("BasePart") then
            innerPart.CFrame = spawnCFrame
        end
    else
        local part = model:FindFirstChildWhichIsA("BasePart", true)
        if part then
            part.CFrame = spawnCFrame
        end
    end
end)

if not loaded then
    if model then
        model:Destroy()
    end
    return
end

local function fadeAndDestroyModel(target, duration)
    if not target or not target.Parent then
        return
    end

    local emitters = {}
    for _, descendant in ipairs(target:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") then
            table.insert(emitters, {
                emitter = descendant,
                keypoints = descendant.Transparency.Keypoints
            })
        end
    end

    local started = os.clock()
    while target.Parent do
        local alpha = math.clamp((os.clock() - started) / duration, 0, 1)

        for _, entry in ipairs(emitters) do
            if entry.emitter.Parent then
                local points = {}
                for _, keypoint in ipairs(entry.keypoints) do
                    table.insert(points, NumberSequenceKeypoint.new(
                        keypoint.Time,
                        keypoint.Value + (1 - keypoint.Value) * alpha,
                        keypoint.Envelope * (1 - alpha)
                    ))
                end
                entry.emitter.Transparency = NumberSequence.new(points)
            end
        end

        if alpha >= 1 then
            break
        end
        RunService.Heartbeat:Wait()
    end

    if target.Parent then
        target:Destroy()
    end
end

task.delay(4, function()
    fadeAndDestroyModel(model, 1.5)
end)

local running = true
local spectator = false
local screenGui
local currentImage
local camShake
local characterAddedConnection
local characterRemovingConnection
local diedConnection

local function removeEffects()
    if currentImage then
        currentImage:Destroy()
        currentImage = nil
    end
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
    end
    if camShake then
        pcall(function()
            camShake:Stop()
        end)
        camShake = nil
    end
end

local function becomeSpectator()
    if spectator then
        return
    end
    spectator = true
    removeEffects()
end

local function hasDeathFlag(instance)
    if not instance then
        return false
    end
    return instance:GetAttribute("Dead") == true
        or instance:GetAttribute("IsDead") == true
        or instance:GetAttribute("Alive") == false
end

local function isPlayerActive()
    if spectator then
        return false
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end

    if humanoid.Health <= 0
        or humanoid:GetState() == Enum.HumanoidStateType.Dead
        or hasDeathFlag(character)
        or hasDeathFlag(player) then
        becomeSpectator()
        return false
    end

    return true
end

local function watchCharacter(character)
    if diedConnection then
        diedConnection:Disconnect()
        diedConnection = nil
    end

    task.spawn(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
        if not running or spectator or player.Character ~= character or not humanoid then
            return
        end
        diedConnection = humanoid.Died:Connect(becomeSpectator)
        isPlayerActive()
    end)
end

characterAddedConnection = player.CharacterAdded:Connect(watchCharacter)
characterRemovingConnection = player.CharacterRemoving:Connect(function()
    becomeSpectator()
end)

if player.Character then
    watchCharacter(player.Character)
end

local function finishGame()
    if not running then
        return
    end
    running = false
    removeEffects()
    if diedConnection then
        diedConnection:Disconnect()
        diedConnection = nil
    end
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
        characterAddedConnection = nil
    end
    if characterRemovingConnection then
        characterRemovingConnection:Disconnect()
        characterRemovingConnection = nil
    end
end

local endedConnection = music.Ended:Connect(finishGame)
local stoppedConnection = music.Stopped:Connect(finishGame)
local destroyingConnection = music.Destroying:Connect(finishGame)

local function isMusicRunning()
    return running and music.Parent ~= nil and music.IsPlaying
end

local function waitForMusicTime(seconds)
    while isMusicRunning() and music.TimePosition < seconds do
        if not spectator then
            isPlayerActive()
        end
        task.wait(0.03)
    end
    return isMusicRunning()
end

local function caption(message)
    if not isPlayerActive() or not isMusicRunning() then
        return
    end
    pcall(function()
        require(player.PlayerGui.MainUI.Initiator.Main_Game).caption(message, true)
    end)
end

local function shakeCamera()
    if not isPlayerActive() or not isMusicRunning() then
        return
    end

    if not camShake then
        local ok, shakerModule = pcall(function()
            return require(ReplicatedStorage:WaitForChild("CameraShaker"))
        end)
        if not ok then
            return
        end

        local created, instance = pcall(function()
            local shaker = shakerModule.new(Enum.RenderPriority.Camera.Value + 1, function(shakeCf)
                local camera = Workspace.CurrentCamera
                if camera and isPlayerActive() then
                    camera.CFrame = camera.CFrame * shakeCf
                end
            end)
            shaker:Start()
            return shaker
        end)
        if not created then
            return
        end
        camShake = instance
    end

    pcall(function()
        camShake:ShakeOnce(10, 3, 0.1, 6, 2, 0.5)
    end)
end

local function getScreenGui()
    if screenGui and screenGui.Parent then
        return screenGui
    end
    if not isPlayerActive() then
        return nil
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "A333JumpScareGui"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000
    gui.Parent = player:WaitForChild("PlayerGui")
    screenGui = gui
    return gui
end

local function isHiding()
    local character = player.Character
    return character ~= nil and character:GetAttribute("Hiding") == true
end

local function showJumpScareAndCheck(shouldHide)
    if not isMusicRunning() or not isPlayerActive() then
        return
    end

    local gui = getScreenGui()
    if not gui then
        return
    end

    local image = Instance.new("ImageLabel")
    image.Name = "A333JumpScare"
    image.BackgroundTransparency = 1
    image.Image = "rbxassetid://122543847993550"
    image.ImageTransparency = 1
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.Position = UDim2.fromScale(0.5, 0.5)
    local size = random:NextNumber(1.08, 1.22)
    image.Size = UDim2.fromScale(size, size)
    image.ScaleType = Enum.ScaleType.Crop
    image.ZIndex = 10
    image.Parent = gui
    currentImage = image

    local damaged = false
    local started = os.clock()

    while isMusicRunning() and isPlayerActive() and image.Parent do
        local elapsed = os.clock() - started
        if elapsed >= 0.4 then
            break
        end

        if elapsed < 0.1 then
            image.ImageTransparency = 1 - 0.5 * (elapsed / 0.1)
        elseif elapsed < 0.3 then
            image.ImageTransparency = 0.5
        else
            image.ImageTransparency = 0.5 + 0.5 * ((elapsed - 0.3) / 0.1)
        end

        image.Position = UDim2.new(0.5, random:NextInteger(-25, 25), 0.5, random:NextInteger(-25, 25))
        image.Rotation = random:NextInteger(-12, 12)

        if not damaged and isHiding() ~= shouldHide then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                damaged = true
                humanoid:TakeDamage(90)
                isPlayerActive()
            end
        end

        RunService.RenderStepped:Wait()
    end

    if currentImage == image then
        currentImage = nil
    end
    image:Destroy()
end

local function runChallenge(shouldHide)
    if not isMusicRunning() or not isPlayerActive() then
        return
    end

    caption(shouldHide and "躲藏" or "不躲藏")
    shakeCamera()

    local started = os.clock()
    while isMusicRunning() and isPlayerActive() and os.clock() - started < 0.8 do
        task.wait(0.02)
    end

    if isMusicRunning() and isPlayerActive() then
        showJumpScareAndCheck(shouldHide)
    end
end

music.Looped = false
music:Play()

if waitForMusicTime(10) and isPlayerActive() then
    caption("good luck")
end

local function isFinalTwentySeconds()
    return music.TimeLength > 0 and music.TimePosition >= math.max(0, music.TimeLength - 20)
end

if waitForMusicTime(14) then
    while isMusicRunning() do
        if spectator then
            break
        end

        if isPlayerActive() then
            local roundStart = music.TimePosition
            local shouldHide = random:NextInteger(1, 2) == 1
            runChallenge(shouldHide)

            local finalPhase = isFinalTwentySeconds()
            local nextRoundAt = roundStart + (finalPhase and random:NextNumber(3, 5) or random:NextNumber(5, 10))

            while isMusicRunning() and not spectator and music.TimePosition < nextRoundAt do
                isPlayerActive()
                if not finalPhase and isFinalTwentySeconds() then
                    finalPhase = true
                    nextRoundAt = music.TimePosition + random:NextNumber(3, 5)
                end
                task.wait(0.03)
            end
        else
            task.wait(0.1)
        end
    end
end

while isMusicRunning() do
    task.wait(0.1)
end

finishGame()
endedConnection:Disconnect()
stoppedConnection:Disconnect()
destroyingConnection:Disconnect()
end

function entityBehaviors.SCURE()
local modelID = 76379083600613
local targetName = "Repentance_Skinned"
local loadedVFX = nil
local targetModel = nil
local connections = {}
local isFollowing = false

local RunService = game:GetService("RunService")

local function loadVFXPart()
    if loadedVFX and loadedVFX.Parent then
        loadedVFX:Destroy()
        loadedVFX = nil
    end
    
    local success, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(modelID))
    end)
    
    if not success or not result or not result[1] then
        return nil
    end
    
    local model = result[1]
    
    local vfxPart
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("BasePart") and child.Name:lower() == "vfx" then
            vfxPart = child:Clone()
            break
        end
    end
    
    if not vfxPart then
        return nil
    end
    
    vfxPart.Anchored = true
    vfxPart.CanCollide = false
    vfxPart.Transparency = 1
    vfxPart.CanTouch = false
    vfxPart.CanQuery = false
    vfxPart.Massless = true
    vfxPart.Parent = workspace
    vfxPart.Name = "Following_VFX"
    
    return vfxPart
end

local function fadeOutVFX()
    if not loadedVFX or not loadedVFX.Parent then return end
    
    local fadeDuration = 2
    local fadeStart = tick()
    
    while loadedVFX and loadedVFX.Parent and tick() - fadeStart < fadeDuration do
        local progress = (tick() - fadeStart) / fadeDuration
        local transparency = progress
        
        for _, descendant in ipairs(loadedVFX:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Transparency = transparency
            elseif descendant:IsA("Beam") then
                descendant.Transparency = NumberSequence.new(transparency)
            elseif descendant:IsA("ParticleEmitter") then
                descendant.Rate = descendant.Rate * (1 - progress)
            end
        end
        
        RunService.Heartbeat:Wait()
    end
    
    if loadedVFX and loadedVFX.Parent then
        loadedVFX:Destroy()
        loadedVFX = nil
    end
end

local function followTarget()
    if not targetModel or not targetModel.Parent or not loadedVFX or not loadedVFX.Parent then
        isFollowing = false
        return
    end
    
    isFollowing = true
    loadedVFX.Anchored = true
    
    local loadTime = tick()
    local fadeStarted = false
    
    while isFollowing and targetModel and targetModel.Parent and loadedVFX and loadedVFX.Parent do
        RunService.Heartbeat:Wait()
        
        if loadedVFX.Anchored == false then
            loadedVFX.Anchored = true
        end
        
        if tick() - loadTime >= 8 and not fadeStarted then
            fadeStarted = true
            coroutine.wrap(fadeOutVFX)()
        end
        
        if fadeStarted then
            isFollowing = false
            break
        end
        
        local targetPos
        if targetModel:IsA("Model") then
            local primary = targetModel.PrimaryPart
            if primary then
                targetPos = primary.CFrame
            else
                for _, child in ipairs(targetModel:GetDescendants()) do
                    if child:IsA("BasePart") then
                        targetPos = child.CFrame
                        break
                    end
                end
            end
        elseif targetModel:IsA("BasePart") then
            targetPos = targetModel.CFrame
        end
        
        if targetPos then
            loadedVFX.CFrame = targetPos + Vector3.new(0, 4, 0)
        end
    end
end

local function start()
    isFollowing = false
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    
    if loadedVFX and loadedVFX.Parent then
        loadedVFX:Destroy()
        loadedVFX = nil
    end
    
    targetModel = workspace:FindFirstChild(targetName)
    if not targetModel or not targetModel:IsA("Model") then
        return
    end
    
    loadedVFX = loadVFXPart()
    if not loadedVFX then
        return
    end
    
    local conn1 = targetModel.AncestryChanged:Connect(function(_, parent)
        if not parent then
            isFollowing = false
            if loadedVFX and loadedVFX.Parent then
                loadedVFX:Destroy()
                loadedVFX = nil
            end
        end
    end)
    
    local conn2 = loadedVFX.AncestryChanged:Connect(function(_, parent)
        if not parent then
            isFollowing = false
            loadedVFX = nil
        end
    end)
    
    table.insert(connections, conn1)
    table.insert(connections, conn2)
    
    coroutine.wrap(followTarget)()
end

local function init()
    pcall(start)
    
    workspace.ChildAdded:Connect(function(child)
        if child.Name == targetName and child:IsA("Model") then
            wait(0.5)
            pcall(start)
        end
    end)
end
wait(2)
init()
coroutine.wrap(function()
    while true do
        wait(5)
        if loadedVFX and loadedVFX.Parent and loadedVFX.Anchored == false then
            loadedVFX.Anchored = true
        end
    end
end)()
end

function entityBehaviors.MLTHREE()
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local audioUrl = "https://github.com/Zero0Star/RipperNewSound/raw/master/8d341ae5854f0d734fced2ba0605c0a3.mp3?raw=true"
local audioFileName = "custom_audio"

local function loadAndPlayAudio()
    pcall(function()
        local audioData = game:HttpGet(audioUrl)
        writefile(audioFileName .. ".mp3", audioData)
        local customAsset = (getcustomasset or getsynasset)(audioFileName .. ".mp3")
        
        local sound = Instance.new("Sound")
        sound.Name = "ML"
        sound.SoundId = customAsset
        sound.Looped = true
        sound.Volume = 0
        sound.Parent = Workspace
        sound:Play()
    end)
end

loadAndPlayAudio()

function GetRoom()
    local gruh = workspace.CurrentRooms
    return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end

local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()

function LoadCustomInstance(source, parent, timeout)
    timeout = timeout or 10
    local startTime = tick()
    local model

    local success, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(source))[1]
    end)
    
    if success and result then
        model = result

    else

        return nil
    end

    if model then
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                obj:Destroy()
            end
        end
        model.Parent = parent or Workspace
    end
    
    return model
end

local s = LoadCustomInstance(121103157413966, Workspace)
if not s then

    return
end

local room = GetRoom()
if room and room:FindFirstChild("RoomEntrance") then
    local entity = s:FindFirstChildWhichIsA("BasePart")
    if entity then
        entity.CFrame = room.RoomEntrance.CFrame * CFrame.new(0, 5, -15)
        if entity:FindFirstChild("Part") then
            entity.Part.CFrame = entity.CFrame
        end

    end
end

pcall(function()
    local roomValue = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomValue))
    
    if currentRoom then

        for _, obj in ipairs(currentRoom:GetDescendants()) do
            if obj.Name == "PlaySound" and obj:IsA("Sound") then
                obj:Stop()
            end
        end

        local fireplace = currentRoom:FindFirstChild("Assets")
        if fireplace and fireplace:FindFirstChild("Fireplace") then
            local logs = fireplace.Fireplace.Fireplace_Logs
            if logs then
                pcall(function() logs.ToolEventPrompt.Enabled = false end)
                pcall(function() logs.Log.SparkParticles.Enabled = false end)
                pcall(function() logs.Log.SmokeParticles.Enabled = false end)
                pcall(function() logs.Log.FireParticles.Enabled = false end)
                pcall(function() logs.Log.FireLight.Enabled = false end)
            end
        end
    end
end)

local MISHX = Workspace:FindFirstChild("MISHX")
if MISHX then

    local player = Players.LocalPlayer
    local rootPart = MISHX:FindFirstChild("HumanoidRootPart") or MISHX:FindFirstChildWhichIsA("BasePart")
    
    if rootPart then
        local smoothness = 0.1
        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = player.Character.HumanoidRootPart.Position
                local currentPos = rootPart.Position
                local lookVector = Vector3.new(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z)
                
                if lookVector.Magnitude > 0 then
                    local targetCFrame = CFrame.new(currentPos, currentPos + lookVector)
                    local currentCFrame = rootPart.CFrame
                    local newCFrame = currentCFrame:Lerp(targetCFrame, smoothness)
                    rootPart.CFrame = newCFrame
                end
            end
        end)

    end

    local humanoid = MISHX:FindFirstChildOfClass("Humanoid")
    if not humanoid and MISHX:IsA("Model") then
        humanoid = Instance.new("Humanoid")
        humanoid.Parent = MISHX
    end
    
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        
        local animationId = "rbxassetid://111408250277560"
        pcall(function()
            local animation = Instance.new("Animation")
            animation.AnimationId = animationId
            local animationTrack = humanoid:LoadAnimation(animation)
            if animationTrack then
                animationTrack.Looped = true
                animationTrack:Play()
            end
        end)
    end
end

pcall(function()
    local mainGame = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
    mainGame.caption(".......", true)
    wait(10)
    mainGame.caption("I know I am not real", true)
    wait(10)
    mainGame.caption("But you are real", true)
    wait(10)
    mainGame.caption("But you are destined not to in this game.", true)
end)
wait(6)
if Workspace:FindFirstChild("MISHX") then
    Workspace["MISHX"]:Destroy()

end
local sound = Workspace:FindFirstChild("ML")
if sound and sound:IsA("Sound") then

    repeat
        wait(1)
    until not sound or not sound.Parent or sound.TimeLength > 0 and sound.TimePosition >= sound.TimeLength

    if sound and sound.Parent then
        sound:Destroy()
    end
else
end
end

function entityBehaviors.JEFFTWO()
local RunService = game:GetService("RunService")
local V1 = game:GetObjects("rbxassetid://132473459444776")[1]
V1.Parent = workspace
local V2 = workspace:WaitForChild("JeffTheKiller")
local function HS()
    if not V2 then return end
    
    local function HP(obj)
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.CanCollide = false
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
                child.Transparency = 1
            elseif child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
                child.Enabled = false
            end
            
            HP(child)
        end
    end
    local p1 = V2:FindFirstChild("Knife")
    local p2 = V2:FindFirstChild("Head")
    local p3 = V2:FindFirstChild("BoyAnimeHair_Black")
    if p1 then HP(p1) end
    if p2 then HP(p2) end
    if p3 then
        local handle = p3:FindFirstChild("Handle")
        if handle then HP(handle) end
    end
end
HS()
local connection
connection = V2.AncestryChanged:Connect(function(_, parent)
    if not parent then
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not V2 or not V2.Parent then 
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
        return 
    end
    local root = V2:FindFirstChild("HumanoidRootPart") or V2:FindFirstChild("Torso")
    if not root then return end
    if V1:IsA("Model") and V1.PrimaryPart then
        V1:SetPrimaryPartCFrame(root.CFrame)
    elseif V1:IsA("BasePart") then
        V1.CFrame = root.CFrame
    end
end)
end

function entityBehaviors.HATRED()
local HATRED_PREPARED_SOUND = nil

local function getHatredSound()
    local folder = game:GetService("Workspace"):FindFirstChild("HardCoreSound")
    if not folder then
        return nil
    end

    local sound = folder:FindFirstChild("HATRED")
    if sound and sound:IsA("Sound") then
        HATRED_PREPARED_SOUND = sound
        return sound
    end

    return nil
end

local function createPreparedHatredSound()
    return getHatredSound()
end

do
    createPreparedHatredSound()
end

_G.entityBehaviors = entityBehaviors
if type(getgenv) == "function" then
    getgenv().entityBehaviors = entityBehaviors
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
if not player then
    return
end

if type(_G.HatredBossController) == "table"
    and type(_G.HatredBossController.Stop) == "function" then
    pcall(_G.HatredBossController.Stop)
end

local CONFIG = {
    ModelId = 73721595292832,
    MusicVolume = 0.8,
    IntroSoundId = 6814463121,
    IntroSoundVolume = 0.3,
    IntroSoundFadeDuration = 1.6,
    MiniGameFadeDuration = 1.2,
    IntroBlurSize = 2,
    UITextureId = "108241048414941",
    ScreenFadeDuration = 5,
    EndMusicFadeDuration = 8,
    CameraLookDownOffset = 1.5,

    StartDistance = 120,
    StopDistance = 15,
    ApproachDuration = 20,
    IntroTargetSpeed = -20,
    SpawnHeight = 15,
    HoverHeight = 8,

    FlickerFlashDuration = 0.08,
    FlickerIntervalMin = 0.7,
    FlickerIntervalMax = 2,
    ShakeIntensity = 0.045,

    PhaseGoals = {4, 5, 5, 6, 6},
    PhaseTimes = {25, 28, 30, 32, 35},
    PhaseRedSizes = {80, 78, 78, 76, 76},
    PhaseRedMoveDurations = {0.60, 0.65, 0.95, 0.75, 0.75},
    PhaseRedMoveIntervals = {2.4, 2.3, 2.8, 2.3, 2.2},
    PhaseBlueMoveDurations = {0.65, 0.65, 0.95, 0.80, 0.80},
    PhaseBlueMoveIntervals = {3.1, 3.0, 3.3, 3.0, 2.9},
    BluePenalty = 1.5,
    PhaseTransitionSoundId = 102844356541414,
    PhaseTransitionDelay = 2.2,

    FailureFadeDuration = 5,
    FailureStormDuration = 13,
    FailureVoidDuration = 2.5,
    FaceSwapDuration = 0.1,
    FaceSwapMinDelay = 1.4,
    FaceSwapMaxDelay = 3.2,
    FailureSoundId = 139866863795650,
    FailureSoundVolume = 4,
}

local COLORS = {
    Background = Color3.fromRGB(8, 4, 7),
    Panel = Color3.fromRGB(15, 8, 11),
    Panel2 = Color3.fromRGB(31, 13, 18),
    Text = Color3.fromRGB(243, 227, 225),
    Muted = Color3.fromRGB(177, 140, 144),
    Red = Color3.fromRGB(233, 38, 54),
    RedDark = Color3.fromRGB(105, 13, 25),
    Blue = Color3.fromRGB(74, 174, 231),
    Gold = Color3.fromRGB(221, 151, 143),
    Green = Color3.fromRGB(167, 211, 174),
}

local State = {
    running = false,
    ending = false,
    musicOnly = false,
    cleaned = false,
    token = 0,
    phase = 0,
    clicks = 0,
    deadline = 0,

    connections = {},
    tweens = {},
    targetTweens = {},
    instances = {},

    music = nil,
    musicStartTween = nil,
    musicFadeTween = nil,
    musicFadeGeneration = 0,
    fadingMusic = nil,
    musicLoopOwner = nil,
    musicOriginalLooped = nil,
    introSound = nil,
    phaseSound = nil,
    failureSound = nil,
    boss = nil,
    blur = nil,
    gui = nil,
    ui = nil,
    captionGui = nil,
    captionPlate = nil,
    captionLabel = nil,
    captionTween = nil,
    captionSerial = 0,
    captionText = nil,
    inventory = nil,
    bossConnection = nil,
    mouseConnection = nil,
    movementLock = nil,

    introActive = false,
    introFadeStartedAt = nil,
    cameraFocusPoint = nil,
    introProgress = 0,
    bossArrived = false,
    introGui = nil,
    introColor = nil,
    introHighlight = nil,
    introHumanoid = nil,
    introSpeedConnection = nil,
    introSpeedStepConnection = nil,
    introBaseSpeed = nil,
    introAppliedSpeed = nil,
    flickeringLights = nil,

    originalMouseBehavior = nil,
    originalMouseIconEnabled = nil,
    originalInventoryVisible = nil,
}

local Controller = {}
_G.HatredBossController = Controller

local function alive(token)
    return State.running and not State.cleaned and State.token == token
end

local function addConnection(connection)
    if connection then
        table.insert(State.connections, connection)
    end
    return connection
end

local function disconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function destroy(instance)
    if instance and instance.Parent then
        pcall(function()
            instance:Destroy()
        end)
    end
end

local function playTween(instance, info, goal)
    if not instance or not instance.Parent then
        return nil
    end
    local tween = TweenService:Create(instance, info, goal)
    table.insert(State.tweens, tween)
    tween:Play()
    return tween
end

local function waitCancelable(seconds, token)
    local finishAt = os.clock() + seconds
    while os.clock() < finishAt do
        if not alive(token) then
            return false
        end
        task.wait(math.max(0, math.min(0.1, finishAt - os.clock())))
    end
    return alive(token)
end

local function restoreIntroSpeed(keepCurrent)
    disconnect(State.introSpeedConnection)
    State.introSpeedConnection = nil
    disconnect(State.introSpeedStepConnection)
    State.introSpeedStepConnection = nil

    local humanoid = State.introHumanoid
    local baseSpeed = State.introBaseSpeed
    local appliedSpeed = State.introAppliedSpeed
    State.introHumanoid = nil
    State.introBaseSpeed = nil
    State.introAppliedSpeed = nil

    if humanoid and humanoid.Parent and baseSpeed ~= nil and appliedSpeed ~= nil then
        if keepCurrent then
            if math.abs(humanoid.WalkSpeed - appliedSpeed) < 0.001 then
                return baseSpeed
            end
            return humanoid.WalkSpeed
        end
        pcall(function()
            if math.abs(humanoid.WalkSpeed - appliedSpeed) < 0.001 then
                humanoid.WalkSpeed = baseSpeed
            end
        end)
    end
    return baseSpeed
end

local function stopIntroEffects(immediate)
    if not immediate and State.introFadeStartedAt ~= nil then
        return
    end

    State.introActive = false
    restoreIntroSpeed()
    local gui = State.introGui
    local highlight = State.introHighlight
    local blur = State.blur
    local color = State.introColor

    if immediate then
        State.introFadeStartedAt = nil
        State.cameraFocusPoint = nil
        destroy(gui)
        destroy(highlight)
        destroy(blur)
        destroy(color)
        State.introGui = nil
        State.introHighlight = nil
        State.blur = nil
        State.introColor = nil
        return
    end

    local fadeStartedAt = os.clock()
    State.introFadeStartedAt = fadeStartedAt
    local fadeInfo = TweenInfo.new(CONFIG.ScreenFadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    if gui and gui.Parent then
        for _, item in ipairs(gui:GetDescendants()) do
            if item:IsA("GuiObject") then
                local goal = {BackgroundTransparency = 1}
                if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
                    goal.TextTransparency = 1
                    goal.TextStrokeTransparency = 1
                elseif item:IsA("ImageLabel") or item:IsA("ImageButton") then
                    goal.ImageTransparency = 1
                end
                playTween(item, fadeInfo, goal)
            elseif item:IsA("UIStroke") then
                playTween(item, fadeInfo, {Transparency = 1})
            end
        end
    end

    if highlight and highlight.Parent then
        playTween(highlight, fadeInfo, {FillTransparency = 1, OutlineTransparency = 1})
    end
    if blur and blur.Parent then
        playTween(blur, fadeInfo, {Size = 0})
    end
    if color and color.Parent then
        playTween(color, fadeInfo, {
            Brightness = 0,
            Contrast = 0,
            Saturation = 0,
            TintColor = Color3.new(1, 1, 1),
        })
    end

    task.delay(CONFIG.ScreenFadeDuration, function()
        destroy(gui)
        destroy(highlight)
        destroy(blur)
        destroy(color)
        if State.introGui == gui then State.introGui = nil end
        if State.introHighlight == highlight then State.introHighlight = nil end
        if State.blur == blur then State.blur = nil end
        if State.introColor == color then State.introColor = nil end
        if State.introFadeStartedAt == fadeStartedAt then
            State.introFadeStartedAt = nil
            State.cameraFocusPoint = nil
        end
    end)
end

local SUBTITLE_GLITCH_GLYPHS = {"*", "&", "@", "^", "!", "(", ")", "#", "x", "7", "B", "4", "9", ";"}

local function corruptSubtitle(value)
    local characters = {}
    local eligible = {}
    for _, codepoint in utf8.codes(value) do
        local character = utf8.char(codepoint)
        table.insert(characters, character)
        if not character:match("%s") then
            table.insert(eligible, #characters)
        end
    end
    if #eligible == 0 then
        return value
    end

    local changes = math.min(2, #eligible)
    for _ = 1, changes do
        local slot = math.random(1, #eligible)
        local index = table.remove(eligible, slot)
        local glyphIndex = math.random(1, #SUBTITLE_GLITCH_GLYPHS)
        local replacement = SUBTITLE_GLITCH_GLYPHS[glyphIndex]
        if replacement == characters[index] then
            replacement = SUBTITLE_GLITCH_GLYPHS[(glyphIndex % #SUBTITLE_GLITCH_GLYPHS) + 1]
        end
        characters[index] = replacement
    end
    return table.concat(characters)
end

local function startIntroEffects(humanoid, token)
    State.introActive = true
    State.introFadeStartedAt = nil
    State.cameraFocusPoint = nil
    State.introProgress = 0
    State.bossArrived = false

    if humanoid and humanoid.Parent then
        State.introHumanoid = humanoid
        State.introBaseSpeed = humanoid.WalkSpeed
        local applying = false
        local function applySlow()
            if not State.introActive or State.introHumanoid ~= humanoid or not humanoid.Parent then
                return
            end
            local progress = math.clamp(State.introProgress, 0, 1)
            local easedProgress = progress * progress * (3 - 2 * progress)
            local desired = math.max(0, State.introBaseSpeed
                + (CONFIG.IntroTargetSpeed - State.introBaseSpeed) * easedProgress)
            State.introAppliedSpeed = desired
            if math.abs(humanoid.WalkSpeed - desired) > 0.001 then
                applying = true
                humanoid.WalkSpeed = desired
                applying = false
            end
        end
        State.introSpeedConnection = addConnection(humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if applying or not State.introActive or State.introHumanoid ~= humanoid then
                return
            end
            if math.abs(humanoid.WalkSpeed - (State.introAppliedSpeed or humanoid.WalkSpeed)) > 0.001 then
                State.introBaseSpeed = humanoid.WalkSpeed
                applySlow()
            end
        end))
        State.introSpeedStepConnection = addConnection(RunService.Heartbeat:Connect(function()
            if alive(token) and State.introHumanoid == humanoid then
                applySlow()
            end
        end))
        applySlow()
    end

    local playerGui = player:WaitForChild("PlayerGui", 5)
    if not alive(token) then
        return
    end
    if not playerGui then
        error("PlayerGui was not found")
    end
    destroy(playerGui:FindFirstChild("HatredIntroUI"))
    local gui = Instance.new("ScreenGui")
    gui.Name = "HatredIntroUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 11000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = playerGui
    State.introGui = gui

    local function frame(name, size, position, color, transparency, zIndex)
        local item = Instance.new("Frame")
        item.Name = name
        item.Size = size
        item.Position = position
        item.BackgroundColor3 = color
        item.BackgroundTransparency = transparency
        item.BorderSizePixel = 0
        item.ZIndex = zIndex
        item.Parent = gui
        return item
    end

    local veil = frame("BloodVeil", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0),
        Color3.fromRGB(75, 0, 10), 0.94, 2)
    local function edge(name, size, position, rotation)
        local item = frame(name, size, position, Color3.fromRGB(7, 0, 2), 0.12, 3)
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = rotation
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.05),
            NumberSequenceKeypoint.new(0.48, 0.44),
            NumberSequenceKeypoint.new(1, 1),
        })
        gradient.Parent = item
        return item
    end
    edge("LeftShadow", UDim2.fromScale(0.25, 1), UDim2.fromScale(0, 0), 0)
    edge("RightShadow", UDim2.fromScale(0.25, 1), UDim2.fromScale(0.75, 0), 180)
    edge("UpperShadow", UDim2.fromScale(1, 0.26), UDim2.fromScale(0, 0), 90)
    edge("LowerShadow", UDim2.fromScale(1, 0.26), UDim2.fromScale(0, 0.74), 270)
    frame("UpperBar", UDim2.fromScale(1, 0.075), UDim2.fromScale(0, 0), Color3.new(0, 0, 0), 0.05, 4)
    frame("LowerBar", UDim2.fromScale(1, 0.075), UDim2.fromScale(0, 0.925), Color3.new(0, 0, 0), 0.05, 4)
    local barLine = frame("UpperScar", UDim2.new(0.20, 0, 0, 1), UDim2.fromScale(0.40, 0.075),
        Color3.fromRGB(207, 29, 43), 0.35, 5)

    local whisper = Instance.new("TextLabel")
    whisper.Name = "Whisper"
    whisper.AnchorPoint = Vector2.new(0.5, 0.5)
    whisper.Position = UDim2.fromScale(0.5, 0.83)
    whisper.Size = UDim2.new(0.86, 0, 0, 42)
    whisper.BackgroundTransparency = 1
    whisper.Font = Enum.Font.GothamMedium
    whisper.Text = "You feel a chilling malice..."
    whisper.TextColor3 = Color3.fromRGB(237, 192, 191)
    whisper.TextStrokeColor3 = Color3.new(0, 0, 0)
    whisper.TextStrokeTransparency = 0.35
    whisper.TextScaled = true
    whisper.TextWrapped = true
    whisper.ZIndex = 6
    whisper.Parent = gui
    local textLimit = Instance.new("UITextSizeConstraint")
    textLimit.MinTextSize = 14
    textLimit.MaxTextSize = 23
    textLimit.Parent = whisper

    local threat = Instance.new("TextLabel")
    threat.Name = "Threat"
    threat.AnchorPoint = Vector2.new(0.5, 0.5)
    threat.Position = UDim2.fromScale(0.5, 0.036)
    threat.Size = UDim2.new(0.8, 0, 0, 25)
    threat.BackgroundTransparency = 1
    threat.Font = Enum.Font.GothamBlack
    threat.Text = "H A T R E D    / /    I  S E E  Y O U"
    threat.TextColor3 = Color3.fromRGB(188, 48, 56)
    threat.TextTransparency = 0.35
    threat.TextScaled = true
    threat.ZIndex = 6
    threat.Parent = gui
    local threatLimit = Instance.new("UITextSizeConstraint")
    threatLimit.MaxTextSize = 13
    threatLimit.Parent = threat

    local color = Instance.new("ColorCorrectionEffect")
    color.Name = "HatredIntroColor"
    color.Parent = Lighting
    State.introColor = color

    local blur = Instance.new("BlurEffect")
    blur.Name = "HatredIntroBlur"
    blur.Size = 0
    blur.Parent = Lighting
    State.blur = blur
    playTween(blur, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Size = CONFIG.IntroBlurSize})

    local nextWhisperGlitch = os.clock() + 3.8 + math.random() * 2.0
    local whisperGlitchUntil = 0
    local glitchedWhisper = nil
    addConnection(RunService.RenderStepped:Connect(function()
        if not alive(token) or not State.introActive or not gui.Parent or not color.Parent then
            return
        end
        local progress = math.clamp(State.introProgress, 0, 1)
        local now = os.clock()
        local beat = math.max(0, math.sin(now * (4.0 + progress * 2.0))) ^ 6
        veil.BackgroundTransparency = math.clamp(0.94 - progress * 0.10 - beat * 0.025, 0, 1)
        barLine.BackgroundTransparency = 0.58 - progress * 0.30 - beat * 0.12
        threat.TextTransparency = 0.50 - progress * 0.25 - beat * 0.08
        whisper.Visible = not State.bossArrived
        whisper.TextTransparency = 0.12 + 0.15 * (0.5 + 0.5 * math.sin(now * 2.1))
        local whisperText
        if progress < 0.23 then
            whisperText = "You feel a chilling malice..."
        elseif progress < 0.47 then
            whisperText = "Your steps grow heavier."
        elseif progress < 0.72 then
            whisperText = "It has been watching you."
        elseif progress < 0.91 then
            whisperText = "There is no escape."
        else
            whisperText = "H A T R E D"
        end
        if not State.bossArrived and now >= nextWhisperGlitch then
            glitchedWhisper = corruptSubtitle(whisperText)
            whisperGlitchUntil = now + 0.09
            nextWhisperGlitch = now + 5.5 + math.random() * 3.0
        end
        whisper.Text = now < whisperGlitchUntil and glitchedWhisper or whisperText
        local whisperX = math.noise(now * 2.3, 2, 0) * 1.2
        local whisperY = math.noise(0, now * 2.7, 2) * 0.9
        whisper.Position = UDim2.new(0.5, whisperX, 0.83, whisperY)
        color.Brightness = -0.025 - progress * 0.055 - beat * 0.008
        color.Contrast = 0.07 + progress * 0.16
        color.Saturation = -0.24 - progress * 0.24
        color.TintColor = Color3.fromRGB(255, math.floor(230 - progress * 48), math.floor(230 - progress * 55))
        if State.introHighlight and State.introHighlight.Parent then
            State.introHighlight.OutlineTransparency = 0.48 - progress * 0.25 - beat * 0.10
            State.introHighlight.FillTransparency = 0.96 - progress * 0.10 - beat * 0.025
        end
    end))
end

local function ensureCaptionGui(token)
    if State.captionGui and State.captionGui.Parent and State.captionPlate and State.captionLabel then
        return State.captionPlate, State.captionLabel
    end

    local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3)
    if not playerGui or not alive(token) then
        return nil, nil
    end
    destroy(playerGui:FindFirstChild("HatredCustomDialogue"))

    local gui = Instance.new("ScreenGui")
    gui.Name = "HatredCustomDialogue"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 12000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    local plate = Instance.new("CanvasGroup")
    plate.Name = "CaptionPlate"
    plate.AnchorPoint = Vector2.new(0.5, 0.5)
    plate.Position = UDim2.fromScale(0.5, 0.962)
    plate.Size = UDim2.fromScale(0.88, 0.064)
    plate.BackgroundColor3 = Color3.fromRGB(12, 3, 6)
    plate.BackgroundTransparency = 0.25
    plate.GroupTransparency = 1
    plate.BorderSizePixel = 0
    plate.ClipsDescendants = true
    plate.Active = false
    plate.Parent = gui

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(200, 18)
    sizeConstraint.MaxSize = Vector2.new(850, 52)
    sizeConstraint.Parent = plate

    local plateCorner = Instance.new("UICorner")
    plateCorner.CornerRadius = UDim.new(0, 4)
    plateCorner.Parent = plate

    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(143, 35, 45)
    border.Thickness = 1
    border.Transparency = 0.46
    border.Parent = plate

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 2, 0.70, 0)
    accent.Position = UDim2.fromScale(0.015, 0.15)
    accent.BackgroundColor3 = Color3.fromRGB(217, 40, 55)
    accent.BackgroundTransparency = 0.20
    accent.BorderSizePixel = 0
    accent.Active = false
    accent.Parent = plate

    local label = Instance.new("TextLabel")
    label.Name = "Dialogue"
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.fromScale(0.5, 0.5)
    label.Size = UDim2.fromScale(0.94, 0.90)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = ""
    label.TextColor3 = Color3.fromRGB(247, 226, 222)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.32
    label.TextScaled = true
    label.TextWrapped = true
    label.Active = false
    label.Parent = plate

    local textLimit = Instance.new("UITextSizeConstraint")
    textLimit.MinTextSize = 9
    textLimit.MaxTextSize = 22
    textLimit.Parent = label

    State.captionGui = gui
    State.captionPlate = plate
    State.captionLabel = label

    addConnection(RunService.RenderStepped:Connect(function()
        if not alive(token) or State.captionGui ~= gui or not plate.Parent or not State.captionText then
            return
        end
        local now = os.clock()
        local offsetX = math.noise(now * 2.8, 1, 0) * 1.4
        local offsetY = math.noise(0, now * 3.0, 1) * 0.9
        plate.Position = UDim2.new(0.5, offsetX, 0.962, offsetY)
    end))

    return plate, label
end

local function showCaption(value, seconds)
    local token = State.token
    if not alive(token) then
        return
    end

    local plate, label = ensureCaptionGui(token)
    if not plate or not label then
        return
    end

    State.captionSerial = State.captionSerial + 1
    local serial = State.captionSerial
    local text = tostring(value or "")
    State.captionText = text
    label.Text = text

    if State.captionTween then
        pcall(function()
            State.captionTween:Cancel()
        end)
    end
    State.captionTween = playTween(plate, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {GroupTransparency = 0})

    local displayUntil = os.clock() + math.max(0.1, seconds or 3.0)
    task.spawn(function()
        local nextGlitch = os.clock() + 1.1 + math.random() * 1.3
        while alive(token) and State.captionSerial == serial and label.Parent and os.clock() < displayUntil do
            local now = os.clock()
            if now >= nextGlitch and now + 0.12 < displayUntil then
                label.Text = corruptSubtitle(text)
                if not waitCancelable(0.07 + math.random() * 0.04, token) then
                    return
                end
                if State.captionSerial ~= serial or not label.Parent then
                    return
                end
                label.Text = text
                nextGlitch = os.clock() + 2.4 + math.random() * 2.0
            else
                if not waitCancelable(math.min(0.1, displayUntil - now), token) then
                    return
                end
            end
        end
        if not alive(token) or State.captionSerial ~= serial or not plate.Parent then
            return
        end

        State.captionTween = playTween(plate, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {GroupTransparency = 1})
        if not waitCancelable(0.26, token) then
            return
        end
        if State.captionSerial == serial and label.Parent then
            label.Text = ""
            State.captionText = nil
        end
    end)
end

local function getCharacterParts(timeout)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart", timeout or 5)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid", timeout or 5)
    return character, root, humanoid
end

local function isPlayerDead()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead
end

local function restoreRoomLights(lights)
    if not lights then
        return
    end
    if State.flickeringLights == lights then
        State.flickeringLights = nil
    end
    for _, entry in ipairs(lights) do
        local light = entry.light
        if light and light.Parent then
            pcall(function()
                if math.abs(light.Brightness - entry.dimmed) < 0.001 then
                    light.Brightness = entry.original
                end
            end)
        end
    end
end

local function startRoomFlicker(token)
    task.spawn(function()
        while alive(token) and not State.ending do
            local gameData = ReplicatedStorage:FindFirstChild("GameData")
            local latestRoomValue = gameData and gameData:FindFirstChild("LatestRoom")
            local rooms = Workspace:FindFirstChild("CurrentRooms")
            local room = latestRoomValue and rooms and rooms:FindFirstChild(tostring(latestRoomValue.Value))
            local lights = {}
            State.flickeringLights = lights

            if room then
                for _, light in ipairs(room:GetDescendants()) do
                    if light:IsA("Light") and light.Enabled then
                        local original = light.Brightness
                        local dimmed = original * (0.35 + math.random() * 0.25)
                        table.insert(lights, {light = light, original = original, dimmed = dimmed})
                        light.Brightness = dimmed
                    end
                end
            end

            local canContinue = waitCancelable(CONFIG.FlickerFlashDuration, token)
            restoreRoomLights(lights)
            if not canContinue or State.ending then
                break
            end
            local interval = CONFIG.FlickerIntervalMin
                + math.random() * (CONFIG.FlickerIntervalMax - CONFIG.FlickerIntervalMin)
            if not waitCancelable(interval, token) then
                break
            end
        end
    end)
end

local SHAKE_BIND_NAME = "HatredBossCameraShake"

local function startCameraShake(token)
    pcall(function()
        RunService:UnbindFromRenderStep(SHAKE_BIND_NAME)
    end)

    local startedAt = os.clock()
    RunService:BindToRenderStep(SHAKE_BIND_NAME, Enum.RenderPriority.Camera.Value + 1, function()
        local fadingSince = State.introFadeStartedAt
        if not alive(token) or (not State.introActive and not fadingSince) then
            pcall(function()
                RunService:UnbindFromRenderStep(SHAKE_BIND_NAME)
            end)
            return
        end

        local elapsed = os.clock() - startedAt
        local fadeStrength = fadingSince
            and math.clamp(1 - (os.clock() - fadingSince) / CONFIG.ScreenFadeDuration, 0, 1)
            or 1
        if fadeStrength <= 0 then
            pcall(function()
                RunService:UnbindFromRenderStep(SHAKE_BIND_NAME)
            end)
            return
        end

        local camera = Workspace.CurrentCamera
        if camera then
            local progress = math.clamp(State.introProgress, 0, 1)
            local cameraFrame = camera.CFrame
            local boss = State.boss
            local target = boss and boss.Parent and boss.PrimaryPart
            local focusPoint = target and (target.Position - Vector3.new(0, CONFIG.CameraLookDownOffset, 0))
            if focusPoint then
                State.cameraFocusPoint = focusPoint
            elseif fadingSince then
                focusPoint = State.cameraFocusPoint
            end
            if focusPoint and (focusPoint - cameraFrame.Position).Magnitude > 0.01 then
                local focus = progress * progress * (3 - 2 * progress) * fadeStrength
                local targetFrame = CFrame.lookAt(cameraFrame.Position, focusPoint)
                cameraFrame = cameraFrame:Lerp(targetFrame, focus)
            end

            local power = CONFIG.ShakeIntensity * (0.6 + 0.4 * progress) * fadeStrength
            local x = math.noise(elapsed * 5.1, 0, 0) * power
            local y = math.noise(0, elapsed * 5.7, 0) * power
            local roll = math.noise(0, 0, elapsed * 4.6) * math.rad(power)
            camera.CFrame = cameraFrame * CFrame.new(x, y, 0) * CFrame.Angles(0, 0, roll)
        end
    end)
end

local function startIntroSound()
    destroy(State.introSound)
    local sound = Instance.new("Sound")
    sound.Name = "HatredIntroSound"
    sound.SoundId = "rbxassetid://" .. tostring(CONFIG.IntroSoundId)
    sound.Volume = CONFIG.IntroSoundVolume
    sound.Looped = true
    sound.Parent = SoundService
    State.introSound = sound
    sound:Play()
end

local function fadeIntroSound(seconds, token)
    local sound = State.introSound
    if sound and sound.Parent then
        playTween(sound, TweenInfo.new(seconds, Enum.EasingStyle.Sine), {Volume = 0})
    end
    if not waitCancelable(seconds, token) then
        return false
    end
    if State.introSound == sound then
        State.introSound = nil
    end
    destroy(sound)
    return alive(token)
end

local function cancelMusicFade()
    State.musicFadeGeneration = State.musicFadeGeneration + 1
    if State.musicFadeTween then
        pcall(function()
            State.musicFadeTween:Cancel()
        end)
        State.musicFadeTween = nil
    end
end

local function cancelMusicStartTween()
    if State.musicStartTween then
        pcall(function()
            State.musicStartTween:Cancel()
        end)
        State.musicStartTween = nil
    end
end

local function restoreMusicLoopSetting(sound)
    if State.musicLoopOwner ~= sound then
        return
    end
    local originalLooped = State.musicOriginalLooped
    State.musicLoopOwner = nil
    State.musicOriginalLooped = nil
    if sound and originalLooped ~= nil then
        pcall(function()
            if sound.Looped == true then
                sound.Looped = originalLooped
            end
        end)
    end
end

local function loadBossMusic()
    local sound = HATRED_PREPARED_SOUND
    if not sound or not sound.Parent then
        sound = getHatredSound()
    end
    if not sound or not sound.Parent then
        return nil
    end

    local previousFadingSound = State.fadingMusic
    cancelMusicFade()
    cancelMusicStartTween()
    local previousLoopOwner = State.musicLoopOwner
    if previousLoopOwner and previousLoopOwner ~= sound then
        pcall(function()
            previousLoopOwner:Stop()
        end)
        restoreMusicLoopSetting(previousLoopOwner)
    elseif previousFadingSound and previousFadingSound ~= sound and previousFadingSound.Parent then
        previousFadingSound:Stop()
    end
    if State.musicLoopOwner ~= sound then
        State.musicLoopOwner = sound
        State.musicOriginalLooped = sound.Looped
    end
    State.fadingMusic = nil
    sound:Stop()
    sound.Volume = 0
    sound.Looped = true
    State.music = sound
    sound.TimePosition = 0
    sound:Play()
    State.musicStartTween = playTween(sound, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {Volume = CONFIG.MusicVolume})
    return sound
end

local function fadeMusic(seconds)
    local sound = State.music
    State.music = nil
    if not sound then
        return
    end

    cancelMusicStartTween()
    cancelMusicFade()
    if sound.Parent then
        local duration = seconds or 1.2
        local generation = State.musicFadeGeneration
        State.fadingMusic = sound
        local tween = TweenService:Create(sound, TweenInfo.new(duration, Enum.EasingStyle.Sine), {Volume = 0})
        State.musicFadeTween = tween
        tween:Play()
        task.delay(duration, function()
            if State.musicFadeGeneration ~= generation then
                return
            end
            if sound.Parent then
                pcall(function()
                    sound:Stop()
                end)
            end
            restoreMusicLoopSetting(sound)
            if State.fadingMusic == sound then
                State.fadingMusic = nil
            end
            State.musicFadeTween = nil
        end)
    else
        restoreMusicLoopSetting(sound)
    end
end

local function createGlowingModel()
    local model = Instance.new("Model")
    model.Name = "MovingModel"

    local mainPart = Instance.new("Part")
    mainPart.Name = "Core"
    mainPart.Size = Vector3.new(5, 5, 5)
    mainPart.Shape = Enum.PartType.Ball
    mainPart.Color = Color3.fromRGB(175, 12, 26)
    mainPart.Material = Enum.Material.Neon
    mainPart.Transparency = 0.2
    mainPart.CanCollide = false
    mainPart.Anchored = true
    mainPart.Parent = model

    local pointLight = Instance.new("PointLight")
    pointLight.Color = Color3.fromRGB(190, 20, 34)
    pointLight.Range = 30
    pointLight.Brightness = 5
    pointLight.Parent = mainPart

    model.PrimaryPart = mainPart
    return model
end

local function loadBossModel()
    local success, result = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(CONFIG.ModelId))
        if objects and #objects > 0 then
            return objects[1]:Clone()
        end
        return nil
    end)

    if success and result then
        if result:IsA("Model") and result:FindFirstChildWhichIsA("BasePart", true) then
            return result
        elseif result:IsA("BasePart") then
            local wrapper = Instance.new("Model")
            result.Parent = wrapper
            wrapper.PrimaryPart = result
            return wrapper
        else
            local nestedModel = result:FindFirstChildWhichIsA("Model", true)
            if nestedModel and nestedModel:FindFirstChildWhichIsA("BasePart", true) then
                return nestedModel:Clone()
            end
        end
    end

    local storedModel = ReplicatedStorage:FindFirstChild("HatredModel")
    if storedModel and storedModel:IsA("Model") and storedModel:FindFirstChildWhichIsA("BasePart", true) then
        return storedModel:Clone()
    end

    warn("[Hatred] Unable to load model " .. tostring(CONFIG.ModelId) .. "; using the red fallback model.")
    return createGlowingModel()
end

local function startBossMovement(root, token)
    local model = loadBossModel()
    if not alive(token) then
        if model then model:Destroy() end
        return false
    end
    if not model then
        return false
    end

    model.Name = "HatRed"
    model.Parent = Workspace
    State.boss = model

    local primaryPart = model.PrimaryPart
    if not primaryPart then
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                model.PrimaryPart = part
                primaryPart = part
                break
            end
        end
    end

    if not primaryPart then
        model:Destroy()
        State.boss = nil
        return false
    end

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = true
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "HatredIntroPresence"
    highlight.Adornee = model
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillColor = Color3.fromRGB(128, 0, 13)
    highlight.OutlineColor = Color3.fromRGB(255, 40, 54)
    highlight.FillTransparency = 0.96
    highlight.OutlineTransparency = 0.48
    highlight.Parent = model
    State.introHighlight = highlight

    local playerPos = root.Position
    local hoverY = playerPos.Y + CONFIG.HoverHeight
    local lastHorizontalLook = Vector3.new(0, 0, -1)

    local function horizontalLook()
        local look = root.CFrame.LookVector
        local horizontal = Vector3.new(look.X, 0, look.Z)
        if horizontal.Magnitude > 0.001 then
            lastHorizontalLook = horizontal.Unit
        end
        return lastHorizontalLook
    end

    local function facePlayer(position, playerPosition)
        local direction = Vector3.new(playerPosition.X - position.X, 0, playerPosition.Z - position.Z)
        if direction.Magnitude > 0.1 then
            return CFrame.new(position, position + direction.Unit)
        end
        return CFrame.new(position)
    end

    local playerLook = horizontalLook()
    local startPos = Vector3.new(
        playerPos.X + playerLook.X * CONFIG.StartDistance,
        playerPos.Y + CONFIG.SpawnHeight,
        playerPos.Z + playerLook.Z * CONFIG.StartDistance
    )
    model:SetPrimaryPartCFrame(facePlayer(startPos, playerPos))

    local startTime = tick()
    local isMoving = true
    local isHovering = false
    local connection

    connection = RunService.Heartbeat:Connect(function()
        if not alive(token) or not model or not model.Parent or not model:IsDescendantOf(Workspace) then
            if connection then
                connection:Disconnect()
            end
            return
        end

        if not root or not root.Parent then
            if connection then
                connection:Disconnect()
            end
            if model and model.Parent then
                model:Destroy()
            end
            return
        end

        local currentTime = tick()
        local currentPlayerPos = root.Position
        local playerLookDirection = horizontalLook()
        local targetPos = Vector3.new(
            currentPlayerPos.X + playerLookDirection.X * CONFIG.StopDistance,
            hoverY,
            currentPlayerPos.Z + playerLookDirection.Z * CONFIG.StopDistance
        )

        if isMoving then
            local elapsed = currentTime - startTime
            local progress = math.clamp(elapsed / CONFIG.ApproachDuration, 0, 1)
            State.introProgress = progress
            if progress >= 1 then
                model:SetPrimaryPartCFrame(facePlayer(targetPos, currentPlayerPos))
                isMoving = false
                isHovering = true
                if State.introHumanoid and State.introHumanoid.Parent then
                    State.introAppliedSpeed = 0
                    State.introHumanoid.WalkSpeed = 0
                end
                State.bossArrived = true
                return
            end

            local easedProgress = progress * progress * (3 - 2 * progress)
            local currentPos = startPos:Lerp(targetPos, easedProgress)
            model:SetPrimaryPartCFrame(facePlayer(currentPos, currentPlayerPos))
        elseif isHovering then
            local currentPos = primaryPart.Position
            local smoothedPos = currentPos:Lerp(targetPos, 0.1)
            model:SetPrimaryPartCFrame(facePlayer(smoothedPos, currentPlayerPos))
        end
    end)

    State.bossConnection = connection
    addConnection(connection)
    return true
end

local FACE_NORMAL_ID = 92470122721520
local FACE_GLITCH_IDS = {
    130581413102559,
    94635282583639,
    16804066476,
    16595430194,
}

local function findReboundFace()
    local hatRed = State.boss
    if not hatRed or not hatRed.Parent then
        hatRed = Workspace:FindFirstChild("HatRed")
    end
    if not hatRed then
        return nil
    end

    local face = hatRed:FindFirstChild("FACE", true)
    local attachment = face and face:FindFirstChild("Attachment", true)
    return attachment and attachment:FindFirstChild("Rebound Face", true) or nil
end

local function setFaceTexture(faceObject, assetId)
    if not faceObject or not faceObject.Parent then
        return false
    end

    local asset = "rbxassetid://" .. tostring(assetId)
    local property
    if faceObject:IsA("ImageLabel") or faceObject:IsA("ImageButton") then
        property = "Image"
    elseif faceObject:IsA("MeshPart") then
        property = "TextureID"
    else
        property = "Texture"
    end

    return pcall(function()
        faceObject[property] = asset
    end)
end

local function startFaceChanging(token)
    task.spawn(function()
        while alive(token) and State.boss and State.boss.Parent do
            local delaySeconds = CONFIG.FaceSwapMinDelay
                + math.random() * (CONFIG.FaceSwapMaxDelay - CONFIG.FaceSwapMinDelay)
            if not waitCancelable(delaySeconds, token) then
                return
            end

            local faceObject = findReboundFace()
            if faceObject then
                local randomId = FACE_GLITCH_IDS[math.random(1, #FACE_GLITCH_IDS)]
                setFaceTexture(faceObject, randomId)
                if not waitCancelable(CONFIG.FaceSwapDuration, token) then
                    return
                end
                setFaceTexture(faceObject, FACE_NORMAL_ID)
            else
                task.wait(0.2)
            end
        end
    end)
end

local function hideInventory()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        return
    end

    local mainUI = playerGui:FindFirstChild("MainUI")
    local settings = mainUI and mainUI:FindFirstChild("Settings")
    local inventory = settings and settings:FindFirstChild("Inventory")
    if not inventory then
        for _, item in ipairs(playerGui:GetDescendants()) do
            if item:IsA("GuiObject") and item.Name:lower():find("inventory", 1, true) then
                inventory = item
                break
            end
        end
    end

    if inventory and inventory:IsA("GuiObject") then
        State.inventory = inventory
        State.originalInventoryVisible = inventory.Visible
        inventory.Visible = false
    end
end

local function startMouseOverride(token)
    State.originalMouseBehavior = UserInputService.MouseBehavior
    State.originalMouseIconEnabled = UserInputService.MouseIconEnabled

    State.mouseConnection = addConnection(RunService.RenderStepped:Connect(function()
        if alive(token) and State.gui and State.gui.Parent then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end
    end))
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
end

local function corner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius)
    item.Parent = parent
    return item
end

local function stroke(parent, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color
    item.Thickness = thickness
    item.Transparency = transparency or 0
    item.Parent = parent
    return item
end

local function makeLabel(parent, name, text, size, position, font, color, textSize, alignment)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Font = font or Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = color or COLORS.Text
    label.TextSize = textSize or 18
    label.TextWrapped = true
    label.TextXAlignment = alignment or Enum.TextXAlignment.Center
    label.ZIndex = 15
    label.Parent = parent
    return label
end

local function makeTarget(parent, name, color, diameter)
    local button = Instance.new("TextButton")
    button.Name = name
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Size = UDim2.fromOffset(diameter + 12, diameter + 12)
    button.Position = UDim2.fromScale(0.5, 0.5)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.Active = true
    button.Selectable = true
    button.ZIndex = 20
    button.Parent = parent

    local aura = Instance.new("Frame")
    aura.Name = "Aura"
    aura.AnchorPoint = Vector2.new(0.5, 0.5)
    aura.Position = UDim2.fromScale(0.5, 0.5)
    aura.Size = UDim2.fromScale(1, 1)
    aura.BackgroundColor3 = color
    aura.BackgroundTransparency = 0.92
    aura.BorderSizePixel = 0
    aura.ZIndex = 20
    aura.Parent = button
    corner(aura, 999)
    stroke(aura, color, 1, 0.62)

    local orbit = Instance.new("Frame")
    orbit.Name = "Orbit"
    orbit.AnchorPoint = Vector2.new(0.5, 0.5)
    orbit.Position = UDim2.fromScale(0.5, 0.5)
    orbit.Size = UDim2.fromScale(0.91, 0.91)
    orbit.BackgroundTransparency = 1
    orbit.BorderSizePixel = 0
    orbit.ZIndex = 21
    orbit.Parent = button
    corner(orbit, 999)
    stroke(orbit, color, 1, 0.38)

    local ticks = {
        {UDim2.fromScale(0.5, 0), UDim2.fromOffset(2, 6)},
        {UDim2.fromScale(0.5, 1), UDim2.fromOffset(2, 6)},
        {UDim2.fromScale(0, 0.5), UDim2.fromOffset(6, 2)},
        {UDim2.fromScale(1, 0.5), UDim2.fromOffset(6, 2)},
    }
    for index, entry in ipairs(ticks) do
        local tickMark = Instance.new("Frame")
        tickMark.Name = "Tick" .. index
        tickMark.AnchorPoint = Vector2.new(0.5, 0.5)
        tickMark.Position = entry[1]
        tickMark.Size = entry[2]
        tickMark.BackgroundColor3 = color
        tickMark.BackgroundTransparency = 0.16
        tickMark.BorderSizePixel = 0
        tickMark.ZIndex = 22
        tickMark.Parent = orbit
    end

    local orb = Instance.new("Frame")
    orb.Name = "Orb"
    orb.AnchorPoint = Vector2.new(0.5, 0.5)
    orb.Position = UDim2.fromScale(0.5, 0.5)
    orb.Size = UDim2.fromOffset(diameter, diameter)
    orb.BackgroundColor3 = name == "RedTarget" and Color3.fromRGB(44, 3, 9) or Color3.fromRGB(4, 22, 33)
    orb.BorderSizePixel = 0
    orb.ZIndex = 22
    orb.Parent = button
    corner(orb, 999)
    stroke(orb, color, 2, 0.08)

    local innerRing = Instance.new("Frame")
    innerRing.Name = "InnerRing"
    innerRing.AnchorPoint = Vector2.new(0.5, 0.5)
    innerRing.Position = UDim2.fromScale(0.5, 0.5)
    innerRing.Size = UDim2.fromScale(0.73, 0.73)
    innerRing.BackgroundTransparency = 1
    innerRing.BorderSizePixel = 0
    innerRing.ZIndex = 23
    innerRing.Parent = orb
    corner(innerRing, 999)
    stroke(innerRing, color, 1, 0.62)

    local inner = Instance.new("Frame")
    inner.Name = "Core"
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.Position = UDim2.fromScale(0.5, 0.5)
    inner.Size = UDim2.fromScale(0.48, 0.48)
    inner.BackgroundColor3 = color
    inner.BackgroundTransparency = name == "RedTarget" and 0.35 or 0.54
    inner.BorderSizePixel = 0
    inner.Rotation = 45
    inner.ZIndex = 23
    inner.Parent = orb
    corner(inner, 3)
    local coreGradient = Instance.new("UIGradient")
    coreGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(98, 46, 51))
    coreGradient.Rotation = 45
    coreGradient.Parent = inner

    local mark = Instance.new("TextLabel")
    mark.Name = "Mark"
    mark.Size = UDim2.fromScale(1, 1)
    mark.BackgroundTransparency = 1
    mark.Font = Enum.Font.GothamBlack
    mark.Text = name == "RedTarget" and "+" or "×"
    mark.TextColor3 = Color3.fromRGB(255, 242, 240)
    mark.TextStrokeColor3 = Color3.new(0, 0, 0)
    mark.TextStrokeTransparency = 0.35
    mark.TextScaled = true
    mark.ZIndex = 24
    mark.Parent = orb
    local textLimit = Instance.new("UITextSizeConstraint")
    textLimit.MaxTextSize = 31
    textLimit.Parent = mark

    local scale = Instance.new("UIScale")
    scale.Name = "PopScale"
    scale.Scale = 1
    scale.Parent = button
    return button
end

local function setTargetDiameter(target, diameter)
    if not target then
        return
    end
    target.Size = UDim2.fromOffset(diameter + 12, diameter + 12)
    local orb = target:FindFirstChild("Orb")
    if orb then
        orb.Size = UDim2.fromOffset(diameter, diameter)
    end
end

local function createUI()
    local playerGui = player:WaitForChild("PlayerGui")
    destroy(playerGui:FindFirstChild("HatredBossUI"))

    local gui = Instance.new("ScreenGui")
    gui.Name = "HatredBossUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 10000
    gui.Parent = playerGui
    State.gui = gui

    local function frame(parent, name, size, position, color, transparency, zIndex)
        local item = Instance.new("Frame")
        item.Name = name
        item.Size = size
        item.Position = position
        item.BackgroundColor3 = color
        item.BackgroundTransparency = transparency
        item.BorderSizePixel = 0
        item.Active = false
        item.ZIndex = zIndex
        item.Parent = parent
        return item
    end

    local function label(parent, name, value, size, position, font, color, maxSize, alignment)
        local item = makeLabel(parent, name, value, size, position, font, color, maxSize, alignment)
        item.TextScaled = true
        local constraint = Instance.new("UITextSizeConstraint")
        constraint.MinTextSize = 8
        constraint.MaxTextSize = maxSize
        constraint.Parent = item
        return item
    end

    local dim = frame(gui, "Dim", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(5, 0, 2), 1, 10)

    local panel = Instance.new("CanvasGroup")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromScale(0.88, 0.84)
    panel.BackgroundColor3 = COLORS.Panel
    panel.BackgroundTransparency = 0.025
    panel.GroupTransparency = 1
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.ZIndex = 11
    panel.Parent = gui
    corner(panel, 8)
    stroke(panel, Color3.fromRGB(151, 31, 44), 2, 0.14)

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(280, 260)
    sizeConstraint.MaxSize = Vector2.new(960, 650)
    sizeConstraint.Parent = panel

    local panelScale = Instance.new("UIScale")
    panelScale.Name = "EntranceScale"
    panelScale.Scale = 0.93
    panelScale.Parent = panel

    local foundation = frame(panel, "Foundation", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(15, 7, 10), 0, 1)
    local foundationGradient = Instance.new("UIGradient")
    foundationGradient.Color = ColorSequence.new(Color3.fromRGB(31, 11, 16), Color3.fromRGB(7, 4, 8))
    foundationGradient.Rotation = 90
    foundationGradient.Parent = foundation

    local backdropTexture = Instance.new("ImageLabel")
    backdropTexture.Name = "BackdropTexture"
    backdropTexture.Size = UDim2.fromScale(1, 1)
    backdropTexture.BackgroundTransparency = 1
    backdropTexture.Image = "rbxassetid://" .. tostring(CONFIG.UITextureId)
    backdropTexture.ImageColor3 = Color3.fromRGB(192, 104, 112)
    backdropTexture.ImageTransparency = 0.95
    backdropTexture.ScaleType = Enum.ScaleType.Crop
    backdropTexture.Active = false
    backdropTexture.ZIndex = 2
    backdropTexture.Parent = panel

    local inset = frame(panel, "InsetBorder", UDim2.new(1, -14, 1, -14), UDim2.fromOffset(7, 7), Color3.new(0, 0, 0), 1, 3)
    corner(inset, 5)
    stroke(inset, Color3.fromRGB(92, 31, 40), 1, 0.42)
    frame(panel, "LeftRail", UDim2.new(0, 2, 0.26, 0), UDim2.fromScale(0.012, 0.37), COLORS.RedDark, 0.36, 4)
    frame(panel, "RightRail", UDim2.new(0, 2, 0.26, 0), UDim2.fromScale(0.986, 0.37), COLORS.RedDark, 0.36, 4)
    frame(panel, "HeaderAccent", UDim2.new(0.075, 0, 0, 3), UDim2.fromScale(0.05, 0.027), COLORS.Red, 0.08, 12)

    local headerTag = label(panel, "HeaderTag", "THE SIGNAL  /  ENCOUNTER 05", UDim2.fromScale(0.55, 0.03), UDim2.fromScale(0.14, 0.018), Enum.Font.GothamBold, COLORS.Muted, 10, Enum.TextXAlignment.Left)
    local title = label(panel, "Title", "H A T R E D", UDim2.fromScale(0.57, 0.065), UDim2.fromScale(0.05, 0.055), Enum.Font.GothamBlack, COLORS.Text, 26, Enum.TextXAlignment.Left)
    local phaseLabel = label(panel, "Phase", string.format("PHASE 1 / %d", #CONFIG.PhaseGoals), UDim2.fromScale(0.28, 0.05), UDim2.fromScale(0.67, 0.06), Enum.Font.GothamBold, COLORS.Gold, 16, Enum.TextXAlignment.Right)
    local statusLabel = label(panel, "SignalStatus", "SIGNAL ACTIVE", UDim2.fromScale(0.22, 0.025), UDim2.fromScale(0.73, 0.117), Enum.Font.GothamMedium, COLORS.Muted, 10, Enum.TextXAlignment.Right)
    local signalDot = frame(panel, "SignalDot", UDim2.fromOffset(6, 6), UDim2.fromScale(0.715, 0.125), COLORS.Red, 0.25, 16)
    signalDot.AnchorPoint = Vector2.new(0.5, 0.5)
    corner(signalDot, 999)
    frame(panel, "HeaderDivider", UDim2.new(0.90, 0, 0, 1), UDim2.fromScale(0.05, 0.155), Color3.fromRGB(130, 34, 45), 0.25, 12)

    local phaseRail = frame(panel, "PhaseRail", UDim2.fromScale(0.90, 0.055), UDim2.fromScale(0.05, 0.17), Color3.new(0, 0, 0), 1, 15)
    local phaseMarkers = {}
    for index = 1, #CONFIG.PhaseGoals do
        local marker = frame(phaseRail, "PhaseMarker" .. index, UDim2.fromScale(0.19, 1), UDim2.fromScale((index - 1) * 0.2025, 0), Color3.fromRGB(24, 9, 13), 0.12, 15)
        corner(marker, 3)
        local markerStroke = stroke(marker, Color3.fromRGB(106, 36, 43), 1, 0.48)
        local number = label(marker, "Number", string.format("%02d", index), UDim2.fromScale(1, 0.90), UDim2.fromScale(0, 0), Enum.Font.GothamBold, COLORS.Muted, 13, Enum.TextXAlignment.Center)
        local accent = frame(marker, "Accent", UDim2.new(0.92, 0, 0, 2), UDim2.fromScale(0.04, 0.92), COLORS.Red, 0.90, 16)
        phaseMarkers[index] = {Box = marker, Border = markerStroke, Number = number, Accent = accent}
    end

    local directive = label(panel, "DirectiveTag", "DIRECTIVE", UDim2.fromScale(0.34, 0.025), UDim2.fromScale(0.05, 0.233), Enum.Font.GothamBold, COLORS.Muted, 10, Enum.TextXAlignment.Left)
    local instruction = label(panel, "Instruction", "Click the red mark", UDim2.fromScale(0.90, 0.042), UDim2.fromScale(0.05, 0.258), Enum.Font.GothamMedium, COLORS.Text, 16, Enum.TextXAlignment.Left)

    local statBar = frame(panel, "StatBar", UDim2.fromScale(0.90, 0.105), UDim2.fromScale(0.05, 0.315), Color3.fromRGB(31, 11, 16), 0.06, 16)
    corner(statBar, 4)
    stroke(statBar, Color3.fromRGB(98, 34, 43), 1, 0.28)
    frame(statBar, "DividerLeft", UDim2.new(0, 1, 0.70, 0), UDim2.fromScale(0.25, 0.15), COLORS.RedDark, 0.52, 17)
    frame(statBar, "DividerRight", UDim2.new(0, 1, 0.70, 0), UDim2.fromScale(0.75, 0.15), COLORS.RedDark, 0.52, 17)
    local counterTag = label(statBar, "CounterTag", "MARKS", UDim2.fromScale(0.20, 0.27), UDim2.fromScale(0.025, 0.07), Enum.Font.GothamBold, COLORS.Muted, 10, Enum.TextXAlignment.Left)
    local counter = label(statBar, "Counter", string.format("0 / %d", CONFIG.PhaseGoals[1]), UDim2.fromScale(0.20, 0.54), UDim2.fromScale(0.025, 0.36), Enum.Font.GothamBold, COLORS.Text, 20, Enum.TextXAlignment.Left)
    local progressTag = label(statBar, "ProgressTag", "BREACH PROGRESS", UDim2.fromScale(0.36, 0.27), UDim2.fromScale(0.29, 0.07), Enum.Font.GothamBold, COLORS.Muted, 10, Enum.TextXAlignment.Left)
    local percent = label(statBar, "ProgressPercent", "0%", UDim2.fromScale(0.09, 0.27), UDim2.fromScale(0.64, 0.07), Enum.Font.GothamBold, COLORS.Gold, 10, Enum.TextXAlignment.Right)
    local timerTag = label(statBar, "TimerTag", "TIME", UDim2.fromScale(0.20, 0.27), UDim2.fromScale(0.775, 0.07), Enum.Font.GothamBold, COLORS.Muted, 10, Enum.TextXAlignment.Right)
    local timer = label(statBar, "Timer", string.format("%.1f", CONFIG.PhaseTimes[1]), UDim2.fromScale(0.20, 0.54), UDim2.fromScale(0.775, 0.36), Enum.Font.GothamBlack, COLORS.Text, 21, Enum.TextXAlignment.Right)

    local progressBack = frame(statBar, "ProgressBack", UDim2.fromScale(0.43, 0.12), UDim2.fromScale(0.29, 0.59), Color3.fromRGB(69, 28, 36), 0, 17)
    corner(progressBack, 999)
    local progress = frame(progressBack, "Progress", UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), COLORS.Red, 0, 18)
    corner(progress, 999)
    local progressGradient = Instance.new("UIGradient")
    progressGradient.Color = ColorSequence.new(Color3.fromRGB(255, 100, 102), Color3.fromRGB(172, 17, 34))
    progressGradient.Parent = progress

    local arena = frame(panel, "Arena", UDim2.fromScale(0.90, 0.455), UDim2.fromScale(0.05, 0.435), COLORS.Background, 0, 20)
    arena.ClipsDescendants = true
    corner(arena, 4)
    stroke(arena, Color3.fromRGB(112, 32, 43), 1, 0.24)
    local arenaGradient = Instance.new("UIGradient")
    arenaGradient.Color = ColorSequence.new(Color3.fromRGB(12, 5, 9), Color3.fromRGB(33, 7, 13))
    arenaGradient.Rotation = 32
    arenaGradient.Parent = arena

    local arenaTexture = Instance.new("ImageLabel")
    arenaTexture.Name = "ArenaTexture"
    arenaTexture.Size = UDim2.fromScale(1, 1)
    arenaTexture.BackgroundTransparency = 1
    arenaTexture.Image = "rbxassetid://" .. tostring(CONFIG.UITextureId)
    arenaTexture.ImageColor3 = Color3.fromRGB(255, 154, 160)
    arenaTexture.ImageTransparency = 0.90
    arenaTexture.ScaleType = Enum.ScaleType.Crop
    arenaTexture.Active = false
    arenaTexture.ZIndex = 1
    arenaTexture.Parent = arena

    for index = 1, 6 do
        local line = frame(arena, "GridH" .. index, UDim2.new(1, 0, 0, 1), UDim2.fromScale(0, index / 7), COLORS.RedDark, 0.92, 2)
    end
    for index = 1, 8 do
        local line = frame(arena, "GridV" .. index, UDim2.new(0, 1, 1, 0), UDim2.fromScale(index / 9, 0), COLORS.RedDark, 0.94, 2)
    end
    for index = 1, 8 do
        local scar = frame(arena, "Fracture" .. index, UDim2.new(index % 2 == 0 and 0.30 or 0.18, 0, 0, 1), UDim2.fromScale((index * 0.19) % 1, (index * 0.27) % 1), COLORS.RedDark, 0.79, 3)
        scar.AnchorPoint = Vector2.new(0.5, 0.5)
        scar.Rotation = index % 2 == 0 and -22 or 18
    end
    local brackets = {
        {UDim2.fromOffset(4, 4), UDim2.fromOffset(16, 2)},
        {UDim2.fromOffset(4, 4), UDim2.fromOffset(2, 16)},
        {UDim2.new(1, -20, 0, 4), UDim2.fromOffset(16, 2)},
        {UDim2.new(1, -6, 0, 4), UDim2.fromOffset(2, 16)},
        {UDim2.new(0, 4, 1, -6), UDim2.fromOffset(16, 2)},
        {UDim2.new(0, 4, 1, -20), UDim2.fromOffset(2, 16)},
        {UDim2.new(1, -20, 1, -6), UDim2.fromOffset(16, 2)},
        {UDim2.new(1, -6, 1, -20), UDim2.fromOffset(2, 16)},
    }
    for index, entry in ipairs(brackets) do
        frame(arena, "CornerBracket" .. index, entry[2], entry[1], COLORS.Red, 0.48, 5)
    end
    local arenaScan = frame(arena, "ScanLine", UDim2.new(1, 0, 0, 2), UDim2.fromScale(0, 0), COLORS.Red, 0.94, 4)
    local arenaTag = label(arena, "ArenaTag", "SIGNAL FEED / LIVE", UDim2.fromScale(0.37, 0.08), UDim2.fromScale(0.02, 0.02), Enum.Font.GothamMedium, COLORS.Muted, 10, Enum.TextXAlignment.Left)
    arenaTag.TextTransparency = 0.35

    local redTarget = makeTarget(arena, "RedTarget", COLORS.Red, CONFIG.PhaseRedSizes[1])
    local blueTarget1 = makeTarget(arena, "BlueTarget1", COLORS.Blue, 54)
    local blueTarget2 = makeTarget(arena, "BlueTarget2", COLORS.Blue, 52)
    blueTarget1.Visible = false
    blueTarget2.Visible = false

    local footer = label(panel, "Footer", string.format("RED / STRIKE     BLUE / -%gs", CONFIG.BluePenalty), UDim2.fromScale(0.69, 0.05), UDim2.fromScale(0.05, 0.907), Enum.Font.GothamBold, COLORS.Muted, 12, Enum.TextXAlignment.Left)
    local footerStatus = label(panel, "FooterStatus", "H-05 / LIVE", UDim2.fromScale(0.20, 0.05), UDim2.fromScale(0.75, 0.907), Enum.Font.GothamBold, COLORS.RedDark, 10, Enum.TextXAlignment.Right)

    local phaseSound = Instance.new("Sound")
    phaseSound.Name = "HatredPhaseTransition"
    phaseSound.SoundId = "rbxassetid://" .. tostring(CONFIG.PhaseTransitionSoundId)
    phaseSound.Volume = 0.9
    phaseSound.Parent = SoundService
    State.phaseSound = phaseSound

    local fadeInfo = TweenInfo.new(CONFIG.MiniGameFadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    playTween(dim, fadeInfo, {BackgroundTransparency = 0.27})
    playTween(panel, fadeInfo, {GroupTransparency = 0})
    playTween(panelScale, fadeInfo, {Scale = 1})

    State.ui = {
        Dim = dim,
        Panel = panel,
        PanelScale = panelScale,
        Phase = phaseLabel,
        PhaseMarkers = phaseMarkers,
        Instruction = instruction,
        Counter = counter,
        Timer = timer,
        Progress = progress,
        ProgressPercent = percent,
        Arena = arena,
        ArenaTexture = arenaTexture,
        BackdropTexture = backdropTexture,
        ArenaScan = arenaScan,
        SignalDot = signalDot,
        Red = redTarget,
        Blue1 = blueTarget1,
        Blue2 = blueTarget2,
        RedOrbit = redTarget:FindFirstChild("Orbit"),
        Blue1Orbit = blueTarget1:FindFirstChild("Orbit"),
        Blue2Orbit = blueTarget2:FindFirstChild("Orbit"),
        Footer = footer,
    }
    return State.ui
end

local function startUIAtmosphere(ui, token)
    local startedAt = os.clock()
    local lastUpdate = startedAt - 1
    addConnection(RunService.RenderStepped:Connect(function()
        if not alive(token) or State.ending or State.ui ~= ui or not ui.Panel.Parent then
            return
        end
        local now = os.clock()
        if now - lastUpdate < 1 / 30 then
            return
        end
        lastUpdate = now
        local elapsed = now - startedAt
        local wave = 0.5 + 0.5 * math.sin(elapsed * 0.85)
        ui.ArenaTexture.ImageTransparency = 0.96 - 0.16 * wave
        ui.BackdropTexture.ImageTransparency = 0.98 - 0.08 * wave
        ui.ArenaScan.Position = UDim2.fromScale(0, (elapsed * 0.07) % 1)
        ui.ArenaScan.BackgroundTransparency = 0.94 - 0.06 * wave
        ui.SignalDot.BackgroundTransparency = 0.18 + 0.50 * (1 - wave)
        if ui.RedOrbit and ui.RedOrbit.Parent then ui.RedOrbit.Rotation = (elapsed * 16) % 360 end
        if ui.Blue1Orbit and ui.Blue1Orbit.Parent then ui.Blue1Orbit.Rotation = (-elapsed * 12) % 360 end
        if ui.Blue2Orbit and ui.Blue2Orbit.Parent then ui.Blue2Orbit.Rotation = (elapsed * 11) % 360 end
    end))
end

local function moveTarget(target, speed)
    local ui = State.ui
    if not ui or not target or not target.Visible or not target.Parent then
        return
    end

    local arenaSize = ui.Arena.AbsoluteSize
    local targetSize = target.AbsoluteSize
    if arenaSize.X < 10 or arenaSize.Y < 10 then
        return
    end

    local halfX = targetSize.X * 0.5 + 8
    local halfY = targetSize.Y * 0.5 + 8
    local x = math.random(math.floor(halfX), math.max(math.floor(halfX), math.floor(arenaSize.X - halfX)))
    local y = math.random(math.floor(halfY), math.max(math.floor(halfY), math.floor(arenaSize.Y - halfY)))

    local oldTween = State.targetTweens[target]
    if oldTween then
        pcall(function()
            oldTween:Cancel()
        end)
    end
    local tween = TweenService:Create(target, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromOffset(x, y),
    })
    State.targetTweens[target] = tween
    tween:Play()
end

local function targetPulse(target, color)
    if not target or not target.Parent then
        return
    end
    local scale = target:FindFirstChild("PopScale")
    local orb = target:FindFirstChild("Orb")
    local outline = orb and orb:FindFirstChildOfClass("UIStroke")
    if scale then
        scale.Scale = 0.78
        playTween(scale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
    end
    if outline then
        outline.Color = color
        outline.Transparency = 0
        playTween(outline, TweenInfo.new(0.35), {Transparency = 0.45})
    end
end

local function updateHUD()
    local ui = State.ui
    if not ui or not ui.Panel.Parent or State.phase < 1 then
        return
    end

    local goal = CONFIG.PhaseGoals[State.phase]
    ui.Phase.Text = string.format("PHASE %d / %d", State.phase, #CONFIG.PhaseGoals)
    ui.Counter.Text = string.format("%d / %d", State.clicks, goal)
    local ratio = math.clamp(State.clicks / goal, 0, 1)
    playTween(ui.Progress, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromScale(ratio, 1)})
    ui.ProgressPercent.Text = string.format("%d%%", math.floor(ratio * 100 + 0.5))

    for index, marker in ipairs(ui.PhaseMarkers) do
        if index < State.phase then
            marker.Box.BackgroundColor3 = Color3.fromRGB(55, 12, 19)
            marker.Border.Color = Color3.fromRGB(132, 33, 45)
            marker.Border.Transparency = 0.42
            marker.Accent.BackgroundTransparency = 0.55
            marker.Number.TextColor3 = COLORS.Muted
        elseif index == State.phase then
            marker.Box.BackgroundColor3 = Color3.fromRGB(87, 16, 26)
            marker.Border.Color = COLORS.Red
            marker.Border.Transparency = 0.15
            marker.Accent.BackgroundTransparency = 0.08
            marker.Number.TextColor3 = COLORS.Text
        else
            marker.Box.BackgroundColor3 = Color3.fromRGB(24, 9, 13)
            marker.Border.Color = Color3.fromRGB(106, 36, 43)
            marker.Border.Transparency = 0.55
            marker.Accent.BackgroundTransparency = 0.90
            marker.Number.TextColor3 = Color3.fromRGB(125, 75, 78)
        end
    end

    if State.phase == 1 then
        ui.Phase.TextColor3 = COLORS.Gold
        ui.Instruction.Text = "Click the red mark"
    elseif State.phase == 2 then
        ui.Phase.TextColor3 = COLORS.Gold
        ui.Instruction.Text = "Click red marks · Avoid blue traps"
    else
        ui.Phase.TextColor3 = COLORS.Red
        ui.Instruction.Text = "Click red marks · Avoid blue traps"
    end
end

local function flashMessage(text, color, seconds, token)
    local ui = State.ui
    if not ui or not ui.Instruction.Parent then
        return
    end
    local expectedPhase = State.phase
    ui.Instruction.Text = text
    ui.Instruction.TextColor3 = color
    task.delay(seconds or 0.8, function()
        if alive(token) and State.phase == expectedPhase then
            ui.Instruction.TextColor3 = COLORS.Muted
            updateHUD()
        end
    end)
end

local function beginPhase(phase, token)
    if not alive(token) then
        return
    end
    State.phase = phase
    State.clicks = 0
    State.deadline = os.clock() + CONFIG.PhaseTimes[phase]

    local ui = State.ui
    ui.Progress.Size = UDim2.fromScale(0, 1)
    ui.Red.Visible = true
    ui.Blue1.Visible = phase >= 2
    ui.Blue2.Visible = phase >= 3
    setTargetDiameter(ui.Red, CONFIG.PhaseRedSizes[phase])
    setTargetDiameter(ui.Blue1, phase >= 3 and 52 or 54)
    setTargetDiameter(ui.Blue2, 52)
    updateHUD()

    task.defer(function()
        RunService.Heartbeat:Wait()
        if alive(token) then
            moveTarget(ui.Red, 0)
            moveTarget(ui.Blue1, 0)
            moveTarget(ui.Blue2, 0)
        end
    end)
end

local function removeBoss()
    local model = State.boss
    State.boss = nil
    disconnect(State.bossConnection)
    State.bossConnection = nil
    destroy(model)
end

local function unlockMiniGameMovement()
    local lock = State.movementLock
    State.movementLock = nil
    if not lock then
        return
    end

    disconnect(lock.connection)

    local humanoid = lock.humanoid
    if humanoid and humanoid.Parent then
        pcall(function()
            if humanoid.WalkSpeed == 0 then
                humanoid.WalkSpeed = lock.walkSpeed
            end
        end)
        pcall(function()
            if not humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping) then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, lock.jumpEnabled)
            end
        end)
    end

    local root = lock.root
    if root and root.Parent then
        pcall(function()
            if root.Anchored then
                root.Anchored = lock.wasAnchored
            end
        end)
    end
end

local function lockMiniGameMovement(root, humanoid, token, restoreWalkSpeed)
    local existingLock = State.movementLock
    if existingLock then
        return existingLock.root == root and existingLock.humanoid == humanoid
    end
    if not root or not root.Parent or not humanoid or not humanoid.Parent then
        return false
    end

    local lock = {
        root = root,
        humanoid = humanoid,
        wasAnchored = root.Anchored,
        walkSpeed = restoreWalkSpeed ~= nil and restoreWalkSpeed or humanoid.WalkSpeed,
        jumpEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping),
        connection = nil,
    }
    State.movementLock = lock
    root.Anchored = true
    humanoid.WalkSpeed = 0
    humanoid.Jump = false
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

    lock.connection = addConnection(RunService.Heartbeat:Connect(function()
        if not alive(token) or State.movementLock ~= lock then
            return
        end
        if root.Parent and not root.Anchored then
            lock.wasAnchored = false
            root.Anchored = true
        end
        if humanoid.Parent then
            if humanoid.WalkSpeed ~= 0 then
                lock.walkSpeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = 0
            end
            if humanoid.Jump then
                humanoid.Jump = false
            end
            if humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping) then
                lock.jumpEnabled = true
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            end
        end
    end))
    return true
end

local function restoreLocalState()
    if State.inventory and State.inventory.Parent and State.originalInventoryVisible ~= nil then
        State.inventory.Visible = State.originalInventoryVisible
    end
    State.inventory = nil

    if State.originalMouseBehavior ~= nil then
        UserInputService.MouseBehavior = State.originalMouseBehavior
    end
    if State.originalMouseIconEnabled ~= nil then
        UserInputService.MouseIconEnabled = State.originalMouseIconEnabled
    end
    State.originalMouseBehavior = nil
    State.originalMouseIconEnabled = nil
    State.originalInventoryVisible = nil
end

local function cleanup(immediate, preserveMusic)
    if State.cleaned then
        return
    end
    State.cleaned = true
    State.running = false
    State.phase = 0
    State.token = State.token + 1
    unlockMiniGameMovement()
    stopIntroEffects(true)
    restoreRoomLights(State.flickeringLights)

    pcall(function()
        RunService:UnbindFromRenderStep(SHAKE_BIND_NAME)
    end)

    for _, connection in ipairs(State.connections) do
        disconnect(connection)
    end
    State.connections = {}

    for _, tween in ipairs(State.tweens) do
        pcall(function()
            tween:Cancel()
        end)
    end
    State.tweens = {}
    State.targetTweens = {}
    State.musicStartTween = nil
    State.captionSerial = State.captionSerial + 1
    State.captionTween = nil
    State.captionText = nil
    destroy(State.captionGui)
    State.captionGui = nil
    State.captionPlate = nil
    State.captionLabel = nil

    destroy(State.introSound)
    State.introSound = nil
    if not preserveMusic then
        fadeMusic(immediate and 0.05 or 0.9)
    end
    destroy(State.phaseSound)
    State.phaseSound = nil
    destroy(State.failureSound)
    State.failureSound = nil
    destroy(State.boss)
    State.boss = nil
    destroy(State.blur)
    State.blur = nil
    destroy(State.gui)
    State.gui = nil
    State.ui = nil
    restoreLocalState()
end

local function enterMusicOnly()
    if State.musicOnly then
        return
    end

    local sound = State.music
    cleanup(true, true)
    State.musicOnly = true

    if sound and sound.Parent then
        State.music = sound
        State.musicStartTween = playTween(sound, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {Volume = CONFIG.MusicVolume})
    else
        loadBossMusic()
    end
end

Controller.Stop = function()
    if State.musicOnly then
        State.musicOnly = false
        fadeMusic(0.9)
    end
    cleanup(false)
end

local function defeatPlayer()
    local character, _, humanoid = getCharacterParts(2)
    local signaled = false
    if type(replicatesignal) == "function" then
        signaled = pcall(function()
            replicatesignal(player.Kill)
        end)
    end
    if not signaled and humanoid and humanoid.Parent then
        humanoid.Health = 0
    elseif not signaled and character then
        character:BreakJoints()
    end
end

local FAILURE_TEXTURE_IDS = {
    88894221959954,
    12293713542,
    6214195404,
}

local function createFailureOverlay()
    local gui = State.gui
    if not gui or not gui.Parent then
        return nil
    end

    local old = gui:FindFirstChild("FailureOverlay")
    destroy(old)

    local overlay = Instance.new("Frame")
    overlay.Name = "FailureOverlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ClipsDescendants = true
    overlay.ZIndex = 500
    overlay.Parent = gui

    local textLayer = Instance.new("Frame")
    textLayer.Name = "LoserTextLayer"
    textLayer.Size = UDim2.fromScale(1, 1)
    textLayer.BackgroundTransparency = 1
    textLayer.BorderSizePixel = 0
    textLayer.ZIndex = 510
    textLayer.Parent = overlay

    local glitchBars = {}
    for index = 1, 18 do
        local bar = Instance.new("Frame")
        bar.Name = "EdgeError" .. index
        bar.BackgroundColor3 = COLORS.Red
        bar.BackgroundTransparency = 1
        bar.BorderSizePixel = 0
        bar.ZIndex = 505
        bar.Parent = overlay
        table.insert(glitchBars, bar)
    end

    local glitchImages = {}
    for index = 1, 12 do
        local image = Instance.new("ImageLabel")
        image.Name = "ErrorTexture" .. index
        image.AnchorPoint = Vector2.new(0.5, 0.5)
        image.BackgroundTransparency = 1
        image.BorderSizePixel = 0
        image.Image = "rbxassetid://" .. tostring(FAILURE_TEXTURE_IDS[((index - 1) % #FAILURE_TEXTURE_IDS) + 1])
        image.ImageTransparency = 1
        image.ScaleType = Enum.ScaleType.Stretch
        image.Visible = false
        image.ZIndex = 508 + (index % 3)
        image.Parent = overlay
        table.insert(glitchImages, image)
    end

    destroy(State.failureSound)
    local failureSound = Instance.new("Sound")
    failureSound.Name = "HatredLoserGlitch"
    failureSound.SoundId = "rbxassetid://" .. tostring(CONFIG.FailureSoundId)
    failureSound.Volume = CONFIG.FailureSoundVolume
    failureSound.Parent = SoundService
    State.failureSound = failureSound

    return overlay, textLayer, glitchBars, glitchImages
end

local function updateFailureGlitch(textLayer, glitchBars, glitchImages, intensity)
    if textLayer and textLayer.Parent then
        local jitter = math.floor(2 + intensity * 12)
        textLayer.Position = UDim2.fromOffset(math.random(-jitter, jitter), math.random(-jitter, jitter))
    end

    for index, bar in ipairs(glitchBars) do
        if bar.Parent then
            local side = ((index - 1) % 4) + 1
            local thickness = math.random(2, math.floor(5 + intensity * 25))
            local length = math.random(8, math.floor(20 + intensity * 70)) / 100
            if side == 1 then
                bar.Size = UDim2.new(length, 0, 0, thickness)
                bar.Position = UDim2.new(math.random(), 0, 0, math.random(0, 22))
            elseif side == 2 then
                bar.AnchorPoint = Vector2.new(0, 1)
                bar.Size = UDim2.new(length, 0, 0, thickness)
                bar.Position = UDim2.new(math.random(), 0, 1, -math.random(0, 22))
            elseif side == 3 then
                bar.Size = UDim2.new(0, thickness, length, 0)
                bar.Position = UDim2.new(0, math.random(0, 22), math.random(), 0)
            else
                bar.AnchorPoint = Vector2.new(1, 0)
                bar.Size = UDim2.new(0, thickness, length, 0)
                bar.Position = UDim2.new(1, -math.random(0, 22), math.random(), 0)
            end

            local colorRoll = math.random(1, 5)
            bar.BackgroundColor3 = colorRoll == 1 and Color3.new(1, 1, 1)
                or (colorRoll == 2 and Color3.fromRGB(30, 0, 0) or COLORS.Red)
            bar.BackgroundTransparency = math.random(5, math.floor(35 + (1 - intensity) * 50)) / 100
            bar.Visible = math.random() < (0.35 + intensity * 0.65)
        end
    end

    for _, image in ipairs(glitchImages) do
        if image.Parent then
            local width = math.random(18, math.floor(35 + intensity * 55)) / 100
            local height = math.random(12, math.floor(25 + intensity * 50)) / 100
            image.Size = UDim2.fromScale(width, height)
            image.Position = UDim2.fromScale(math.random(), math.random())
            image.Rotation = math.random(-12, 12)
            image.Image = "rbxassetid://" .. tostring(FAILURE_TEXTURE_IDS[math.random(1, #FAILURE_TEXTURE_IDS)])
            image.ImageColor3 = math.random() < 0.25 and Color3.new(1, 1, 1)
                or Color3.fromRGB(255, math.random(15, 75), math.random(15, 75))
            image.ImageTransparency = math.random(8, math.floor(35 + (1 - intensity) * 45)) / 100
            image.Visible = math.random() < (0.2 + intensity * 0.72)
        end
    end
end

local function spawnLoserText(textLayer, intensity, isFirst)
    if not textLayer or not textLayer.Parent then
        return
    end

    local failureSound = State.failureSound
    if failureSound and failureSound.Parent then
        pcall(function()
            failureSound.TimePosition = 0
            failureSound:Play()
        end)
    end

    local label = Instance.new("TextLabel")
    label.Name = "YOUR_LOSER"
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Size = isFirst and UDim2.fromOffset(420, 100)
        or UDim2.fromOffset(math.random(150, 430), math.random(45, 115))
    label.Position = isFirst and UDim2.fromScale(0.5, 0.5)
        or UDim2.fromScale(math.random(), math.random())
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = math.random() < 0.35 and Enum.Font.Code or Enum.Font.GothamBlack
    label.Text = "YOUR LOSER"
    label.TextColor3 = math.random() < 0.18 and Color3.new(1, 1, 1) or COLORS.Red
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = math.max(0, 0.5 - intensity * 0.45)
    label.TextTransparency = isFirst and 0 or math.random(0, 25) / 100
    label.TextScaled = true
    label.Rotation = isFirst and 0 or math.random(-18, 18)
    label.ZIndex = 520 + math.random(0, 5)
    label.Parent = textLayer

    local scale = Instance.new("UIScale")
    scale.Scale = isFirst and 0.15 or math.random(35, 85) / 100
    scale.Parent = label
    playTween(
        scale,
        TweenInfo.new(isFirst and 0.55 or math.max(0.04, 0.18 - intensity * 0.12), Enum.EasingStyle.Back),
        {Scale = isFirst and 1 or math.random(90, 150) / 100}
    )
end

local function playFailureSequence(token)
    local overlay, textLayer, glitchBars, glitchImages = createFailureOverlay()
    if not overlay then
        return false
    end

    playTween(
        overlay,
        TweenInfo.new(CONFIG.FailureFadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
        {BackgroundTransparency = 0}
    )

    if not waitCancelable(1.4, token) then
        return false
    end

    spawnLoserText(textLayer, 0, true)
    if not waitCancelable(1.1, token) then
        return false
    end
    local stormStart = os.clock()
    local spawned = 1

    while alive(token) do
        local elapsed = os.clock() - stormStart
        local progress = math.clamp(elapsed / CONFIG.FailureStormDuration, 0, 1)
        if progress >= 1 then
            break
        end

        updateFailureGlitch(textLayer, glitchBars, glitchImages, progress)
        local burst = 1 + math.floor(progress * 4)
        for _ = 1, burst do
            if spawned >= 240 then
                break
            end
            spawnLoserText(textLayer, progress, false)
            spawned = spawned + 1
        end

        local interval = 0.92 * ((1 - progress) ^ 2) + 0.045
        if not waitCancelable(interval, token) then
            return false
        end
    end

    if textLayer and textLayer.Parent then
        textLayer:Destroy()
    end
    for _, bar in ipairs(glitchBars) do
        destroy(bar)
    end
    for _, image in ipairs(glitchImages) do
        destroy(image)
    end
    destroy(State.failureSound)
    State.failureSound = nil
    overlay.BackgroundTransparency = 0

    if not waitCancelable(CONFIG.FailureVoidDuration, token) then
        return false
    end
    playTween(overlay, TweenInfo.new(CONFIG.ScreenFadeDuration, Enum.EasingStyle.Sine), {
        BackgroundTransparency = 1,
    })
    return waitCancelable(CONFIG.ScreenFadeDuration, token)
end

local function finish(result, token)
    if State.ending or not alive(token) then
        return
    end
    State.ending = true
    unlockMiniGameMovement()
    local fadeStartedAt = os.clock()
    stopIntroEffects(false)
    restoreRoomLights(State.flickeringLights)

    local ui = State.ui
    if ui then
        ui.Red.Visible = false
        ui.Blue1.Visible = false
        ui.Blue2.Visible = false
        ui.Timer.Text = result == "victory" and "CLEAR" or "FAILED"
        ui.Timer.TextColor3 = result == "victory" and COLORS.Green or COLORS.Red
        ui.Instruction.Text = result == "victory" and "SURVIVED THE HATRED" or "YOUR LOSER"
        ui.Instruction.TextColor3 = result == "victory" and COLORS.Green or COLORS.Red
        local fadeInfo = TweenInfo.new(CONFIG.ScreenFadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        playTween(ui.Panel, fadeInfo, {GroupTransparency = 1})
        playTween(ui.Dim, fadeInfo, {BackgroundTransparency = 1})
    end

    if result == "victory" then
        removeBoss()
        fadeMusic(CONFIG.EndMusicFadeDuration)
        if not waitCancelable(1.1, token) then return end
        showCaption("It looks like you've made progress. Congratulations.", 2.5)
        if not waitCancelable(1.3, token) then return end
        local remainingFade = math.max(0, CONFIG.ScreenFadeDuration - (os.clock() - fadeStartedAt))
        if not waitCancelable(remainingFade, token) then return end
        cleanup(false, true)
    else
        fadeMusic(CONFIG.EndMusicFadeDuration)
        if playFailureSequence(token) and alive(token) then
            defeatPlayer()
        end
        cleanup(true, true)
    end
end

local function startMiniGame(token, root, humanoid)
    if not alive(token) then
        return
    end
    if not lockMiniGameMovement(root, humanoid, token) then
        error("Cannot lock movement: the player character is unavailable")
    end
    local ui = createUI()
    startUIAtmosphere(ui, token)
    hideInventory()
    startMouseOverride(token)
    if not waitCancelable(CONFIG.MiniGameFadeDuration, token) then
        return
    end
    beginPhase(1, token)

    local transitioning = false
    local nextRedMove = 0
    local nextBlue1Move = 0
    local nextBlue2Move = 0

    addConnection(ui.Red.Activated:Connect(function()
        if not alive(token) or State.ending or transitioning then
            return
        end
        State.clicks = State.clicks + 1
        targetPulse(ui.Red, Color3.new(1, 1, 1))
        updateHUD()

        if State.clicks >= CONFIG.PhaseGoals[State.phase] then
            if State.phase >= #CONFIG.PhaseGoals then
                task.spawn(finish, "victory", token)
                return
            end

            transitioning = true
            local nextPhase = State.phase + 1
            State.deadline = math.huge
            ui.Red.Visible = false
            ui.Blue1.Visible = false
            ui.Blue2.Visible = false
            ui.Timer.Text = "READY"
            ui.Timer.TextColor3 = COLORS.Gold
            ui.Instruction.Text = nextPhase >= 3
                and "HATRED IS STILL WATCHING..."
                or "YOU ESCAPED FOR NOW..."
            ui.Instruction.TextColor3 = COLORS.Gold
            if State.phaseSound then
                State.phaseSound.TimePosition = 0
                State.phaseSound:Play()
            end
            task.delay(CONFIG.PhaseTransitionDelay, function()
                if alive(token) then
                    nextRedMove = 0
                    nextBlue1Move = 0
                    nextBlue2Move = 0
                    beginPhase(nextPhase, token)
                    transitioning = false
                end
            end)
        else
            moveTarget(ui.Red, CONFIG.PhaseRedMoveDurations[State.phase])
        end
    end))

    local function blueClicked(target)
        if not alive(token) or State.ending or transitioning or State.phase < 2 then
            return
        end
        State.deadline = State.deadline - CONFIG.BluePenalty
        targetPulse(target, COLORS.Red)
        flashMessage(string.format("-%gs · Avoid blue traps", CONFIG.BluePenalty), COLORS.Red, 0.75, token)
        moveTarget(target, CONFIG.PhaseBlueMoveDurations[State.phase])
    end

    addConnection(ui.Blue1.Activated:Connect(function()
        blueClicked(ui.Blue1)
    end))
    addConnection(ui.Blue2.Activated:Connect(function()
        if State.phase >= 3 then
            blueClicked(ui.Blue2)
        end
    end))

    addConnection(RunService.Heartbeat:Connect(function()
        if not alive(token) or State.ending or State.phase < 1 then
            return
        end

        if transitioning then
            ui.Timer.Text = "READY"
            ui.Timer.TextColor3 = COLORS.Gold
            return
        end

        local now = os.clock()
        local remaining = math.max(0, State.deadline - now)
        ui.Timer.Text = string.format("%.1f", remaining)
        ui.Timer.TextColor3 = remaining <= 5 and COLORS.Red or COLORS.Text

        if not transitioning then
            local redInterval = CONFIG.PhaseRedMoveIntervals[State.phase]
            if now >= nextRedMove then
                moveTarget(ui.Red, CONFIG.PhaseRedMoveDurations[State.phase])
                nextRedMove = now + redInterval
            end
            if State.phase >= 2 and now >= nextBlue1Move then
                moveTarget(ui.Blue1, CONFIG.PhaseBlueMoveDurations[State.phase])
                nextBlue1Move = now + CONFIG.PhaseBlueMoveIntervals[State.phase]
            end
            if State.phase >= 3 and now >= nextBlue2Move then
                moveTarget(ui.Blue2, CONFIG.PhaseBlueMoveDurations[State.phase])
                nextBlue2Move = now + CONFIG.PhaseBlueMoveIntervals[State.phase] + 0.2
            end
        end

        if remaining <= 0 then
            task.spawn(finish, "defeat", token)
        end
    end))
end

local function runEvent()
    if State.running then
        return
    end

    State.cleaned = false
    State.running = true
    State.ending = false
    State.musicOnly = false
    State.phase = 0
    State.clicks = 0
    State.token = State.token + 1
    local token = State.token
    addConnection(player.CharacterRemoving:Connect(function()
        cleanup(true)
    end))

    local ok, errorMessage = xpcall(function()
        startIntroSound()
        if not loadBossMusic() then
            task.spawn(function()
                while alive(token) and not State.ending do
                    if loadBossMusic() then
                        return
                    end
                    if not waitCancelable(0.25, token) then
                        return
                    end
                end
            end)
        end

        local existingHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if existingHumanoid and isPlayerDead() then
            enterMusicOnly()
            return
        end

        local _, root, humanoid = getCharacterParts(6)
        if not alive(token) then
            return
        end
        if isPlayerDead() then
            enterMusicOnly()
            return
        end
        if not root then
            error("HumanoidRootPart was not found")
        end

        if humanoid then
            addConnection(humanoid.Died:Connect(function()
                if not State.ending then
                    enterMusicOnly()
                end
            end))
        end

        startIntroEffects(humanoid, token)
        if not alive(token) then
            return
        end
        startRoomFlicker(token)
        startCameraShake(token)
        showCaption("What is this?", 4.2)
        if not waitCancelable(0.5, token) then
            return
        end
        if isPlayerDead() then
            enterMusicOnly()
            return
        end
        local spawned = startBossMovement(root, token)
        if not alive(token) then
            return
        end
        if not spawned then
            error("Hatred boss model could not be loaded")
        end
        startFaceChanging(token)

        local arrivalTimeout = os.clock() + CONFIG.ApproachDuration + 10
        while alive(token) and not State.bossArrived do
            if not State.boss or not State.boss.Parent or not root.Parent or os.clock() > arrivalTimeout then
                error("Hatred did not arrive; intro cancelled")
            end
            task.wait()
        end
        if not alive(token) then
            return
        end
        local originalWalkSpeed = restoreIntroSpeed(true)
        local locked, lockResult = pcall(lockMiniGameMovement, root, humanoid, token, originalWalkSpeed)
        if not locked or not lockResult then
            if not State.movementLock and humanoid and humanoid.Parent
                and originalWalkSpeed ~= nil and humanoid.WalkSpeed == 0 then
                humanoid.WalkSpeed = originalWalkSpeed
            end
            error(locked and "Cannot lock movement: the player character is unavailable" or tostring(lockResult))
        end
        showCaption("We meet again, little bug.", 3.0)
        if not fadeIntroSound(CONFIG.IntroSoundFadeDuration, token) then return end
        if not waitCancelable(math.max(0, 3.2 - CONFIG.IntroSoundFadeDuration), token) then return end
        showCaption("I hope you can learn a lesson this time.", 3.0)
        if not waitCancelable(3.2, token) then return end
        showCaption("Let's get started.", 1.0)
        if not waitCancelable(1, token) then return end
        if isPlayerDead() then
            enterMusicOnly()
            return
        end

        startMiniGame(token, root, humanoid)
    end, debug.traceback)

    if not ok then
        warn("[Hatred] " .. tostring(errorMessage))
        cleanup(true)
    end
end

Controller.Start = runEvent
task.spawn(runEvent)
end

function entityBehaviors.JEFFGUN()
local RunService = game:GetService("RunService")
local V1 = game:GetObjects("rbxassetid://81046861041760")[1]
V1.Parent = workspace
local V2 = workspace:WaitForChild("JeffTheKiller")

local xOffset = 0
local yOffset = 0
local zOffset = 0

if V1:IsA("Model") then
    local primary = V1:FindFirstChildWhichIsA("BasePart")
    if primary then
        V1.PrimaryPart = primary
    end
end

local function HS()
    if not V2 then return end
    
    local function HP(obj)
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.CanCollide = false
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
                child.Transparency = 1
            elseif child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
                child.Enabled = false
            end
            
            HP(child)
        end
    end
    
    local p1 = V2:FindFirstChild("Knife")
    local p2 = V2:FindFirstChild("Head")
    local p3 = V2:FindFirstChild("BoyAnimeHair_Black")
    if p1 then HP(p1) end
    if p2 then HP(p2) end
    if p3 then
        local h = p3:Clone()
        h.Parent = V2
        HP(h)
    end
    
    local leftArm = V2:FindFirstChild("Left Arm")
    local rightArm = V2:FindFirstChild("Right Arm")
    if leftArm then HP(leftArm) end
    if rightArm then HP(rightArm) end
end

HS()

local connection
connection = V2.AncestryChanged:Connect(function(_, parent)
    if not parent then
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not V2 or not V2.Parent then 
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
        return 
    end

    local function findRootPart(model)
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
        if root then 
            return root 
        end
        
        for _, child in pairs(model:GetDescendants()) do
            if (child.Name == "HumanoidRootPart" or child.Name == "Torso") and child:IsA("BasePart") then
                return child
            end
        end
        return nil
    end
    
    local root = findRootPart(V2)
    if not root then 
        V1:Destroy()
        if connection then
            connection:Disconnect()
        end
        return
    end
    if V1:IsA("Model") then
        if not V1.PrimaryPart then
            local part = V1:FindFirstChildWhichIsA("BasePart")
            if part then
                V1.PrimaryPart = part
            end
        end
        
        if V1.PrimaryPart then
            local newCFrame = CFrame.new(
                root.CFrame.Position.X + xOffset,
                root.CFrame.Position.Y + yOffset,
                root.CFrame.Position.Z + zOffset
            ) * root.CFrame.Rotation
            V1:SetPrimaryPartCFrame(newCFrame)
        end
    elseif V1:IsA("BasePart") then
        local newCFrame = CFrame.new(
            root.CFrame.Position.X + xOffset,
            root.CFrame.Position.Y + yOffset,
            root.CFrame.Position.Z + zOffset
        ) * root.CFrame.Rotation
        V1.CFrame = newCFrame
    end
end)
end

function entityBehaviors.JEFFSTARY()
 local RunService = game:GetService("RunService")

local jeff = workspace:FindFirstChild("JeffTheKiller")
local rootPart = jeff and jeff:FindFirstChild("HumanoidRootPart")

if jeff and rootPart then
    local humanoid = jeff:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
    
    local initialPosition = rootPart.Position
    
    RunService.Heartbeat:Connect(function()
        local jeffPosition = rootPart.Position
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, player in pairs(game.Players:GetPlayers()) do
            local character = player.Character
            if character then
                local targetRootPart = character:FindFirstChild("HumanoidRootPart")
                if targetRootPart then
                    local distance = (targetRootPart.Position - jeffPosition).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        
        if closestPlayer and closestPlayer.Character then
            local targetRootPart = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRootPart then
                local direction = (targetRootPart.Position - jeffPosition) * Vector3.new(1, 0, 1)
                
                if direction.Magnitude > 0 then
                    local lookAtCFrame = CFrame.lookAt(jeffPosition, jeffPosition + direction)
                    rootPart.CFrame = CFrame.new(jeffPosition) * lookAtCFrame.Rotation
                end
            end
        end
        
        rootPart.CFrame = CFrame.new(initialPosition) * rootPart.CFrame.Rotation
    end)
end
end
function entityBehaviors.JEFFGUNST()
local sound1 = Instance.new("Sound")
sound1.SoundId = "rbxassetid://3120031857"
sound1.Volume = 1
sound1.Parent = workspace
local sound2 = Instance.new("Sound")
sound2.SoundId = "rbxassetid://680140087"
sound2.Volume = 1
sound2.Parent = workspace
sound1:Play()
task.wait(1)
sound2:Play()
sound2.Ended:Wait()
sound1:Destroy()
sound2:Destroy()
end
function entityBehaviors.REBOUNDSW()
 
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
    local testModelId = testModelId or "125704657522105"
    local ceaseHandledModels = ceaseHandledModels or setmetatable({}, { __mode = "k" })

    local function createIsolatedReboundShaker(priority, applyShake)
        local shaker = CameraShaker.new(priority, function() end)
        local renderName = "ReboundIsolatedCameraShake_" .. HttpService:GenerateGUID(false)
        local active = false
        local controller = { __ReboundIsolated = true }

        function controller:Start()
            if active then
                return
            end
            active = true
            RunService:BindToRenderStep(renderName, priority, function(deltaTime)
                if not active then
                    return
                end
                local success, shakeCFrame = pcall(shaker.Update, shaker, deltaTime)
                if not success then
                    controller:Stop()
                    return
                end
                if typeof(shakeCFrame) == "CFrame" then
                    applyShake(shakeCFrame)
                end
            end)
        end

        function controller:Stop()
            if not active then
                return
            end
            active = false
            RunService:UnbindFromRenderStep(renderName)
        end

        function controller:ShakeOnce(...)
            return shaker:ShakeOnce(...)
        end

        function controller:StartShake(...)
            return shaker:StartShake(...)
        end

        return controller
    end

    local oldReboundShake = _G.__ReboundMainCameraShake
    if type(oldReboundShake) == "table" and oldReboundShake.__ReboundIsolated then
        pcall(function()
            oldReboundShake:Stop()
        end)
    end

    local reboundCameraShake = createIsolatedReboundShaker(
        Enum.RenderPriority.Camera.Value + 30,
        function(shakeCFrame)
            local activeCamera = workspace.CurrentCamera
            if activeCamera then
                activeCamera.CFrame = activeCamera.CFrame * shakeCFrame
            end
        end
    )
    reboundCameraShake:Start()
    _G.__ReboundMainCameraShake = reboundCameraShake

    local reboundCameraShakeStopped = false
    local function stopReboundCameraShake()
        if reboundCameraShakeStopped then
            return
        end
        reboundCameraShakeStopped = true
        reboundCameraShake:Stop()
        if _G.__ReboundMainCameraShake == reboundCameraShake then
            _G.__ReboundMainCameraShake = nil
        end
    end

    local function PlayPreloadedSound(soundName, volume)
        volume = volume or 1
        local soundFolder = workspace:FindFirstChild("HardCoreSound")
        if not soundFolder then
            return nil
        end

        local sound = soundFolder:FindFirstChild(soundName)
        if sound and sound:IsA("Sound") then
            sound.Volume = volume
            sound:Play()
            return sound
        end

        return nil
    end

    local function GetMaxExistingRoom()
        local rooms = workspace.CurrentRooms:GetChildren()
        local maxNum = 0
        for _, room in ipairs(rooms) do
            local num = tonumber(room.Name)
            if num and num > maxNum then
                maxNum = num
            end
        end
        return maxNum
    end

    local Players = game:GetService("Players")
    local reboundSealed = false
    local doorSignal = nil
    local movingSoundForWave = nil

    local function easeCrucifix(alpha)
        alpha = math.clamp(alpha, 0, 1)
        return alpha * alpha * (3 - 2 * alpha)
    end

    local function getCrucifixTool(character)
        if not character or not character:IsA("Model") then
            return nil
        end

        local directTool = character:FindFirstChild("Crucifix")
        if directTool and directTool:IsA("Tool") then
            return directTool
        end

        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant.Name == "Crucifix" and descendant:IsA("Tool") then
                return descendant
            end
        end

        return nil
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

    local function getCrucifixVisualStates(root, shouldInclude, onlyRoot)
        local states = {}

        local function capture(object)
            if shouldInclude and not shouldInclude(object) then
                return
            end

            if object:IsA("BasePart") or object:IsA("Decal")
                or object:IsA("Texture") then
                table.insert(states, {
                    Object = object,
                    Kind = "Transparency",
                    Original = object.Transparency
                })
            elseif object:IsA("ParticleEmitter") or object:IsA("Beam")
                or object:IsA("Trail") then
                table.insert(states, {
                    Object = object,
                    Kind = "Sequence",
                    Original = object.Transparency
                })
            elseif object:IsA("Light") then
                table.insert(states, {
                    Object = object,
                    Kind = "Brightness",
                    Original = object.Brightness
                })
            elseif object:IsA("Highlight") then
                table.insert(states, {
                    Object = object,
                    Kind = "Highlight",
                    Fill = object.FillTransparency,
                    Outline = object.OutlineTransparency
                })
            elseif object:IsA("Smoke") then
                table.insert(states, {
                    Object = object,
                    Kind = "Smoke",
                    Original = object.Opacity
                })
            elseif object:IsA("Fire") then
                table.insert(states, {
                    Object = object,
                    Kind = "Fire",
                    Size = object.Size,
                    Heat = object.Heat
                })
            elseif object:IsA("Sound") then
                table.insert(states, {
                    Object = object,
                    Kind = "Sound",
                    Original = object.Volume
                })
            elseif object:IsA("GuiObject") then
                local state = {
                    Object = object,
                    Kind = "GuiObject",
                    Background = object.BackgroundTransparency
                }

                if object:IsA("ImageLabel") or object:IsA("ImageButton") then
                    state.Image = object.ImageTransparency
                end

                if object:IsA("TextLabel") or object:IsA("TextButton")
                    or object:IsA("TextBox") then
                    state.Text = object.TextTransparency
                end

                table.insert(states, state)
            end
        end

        capture(root)
        if not onlyRoot then
            for _, descendant in ipairs(root:GetDescendants()) do
                capture(descendant)
            end
        end

        return states
    end

    local function crucifixFadedSequence(original, factor)
        local keypoints = {}

        for _, keypoint in ipairs(original.Keypoints) do
            local nextTransparency = 1 - (1 - keypoint.Value) * factor
            table.insert(keypoints, NumberSequenceKeypoint.new(
                keypoint.Time,
                math.clamp(nextTransparency, 0, 1),
                keypoint.Envelope * factor
            ))
        end

        return NumberSequence.new(keypoints)
    end

    local function setCrucifixVisualFactor(states, factor)
        factor = math.clamp(factor, 0, 1)

        for _, state in ipairs(states) do
            local object = state.Object

            if object and object.Parent then
                if state.Kind == "Transparency" then
                    object.Transparency = 1 - (1 - state.Original) * factor
                elseif state.Kind == "Sequence" then
                    object.Transparency = crucifixFadedSequence(state.Original, factor)
                elseif state.Kind == "Brightness" then
                    object.Brightness = state.Original * factor
                elseif state.Kind == "Highlight" then
                    object.FillTransparency = 1 - (1 - state.Fill) * factor
                    object.OutlineTransparency = 1 - (1 - state.Outline) * factor
                elseif state.Kind == "Smoke" then
                    object.Opacity = state.Original * factor
                elseif state.Kind == "Fire" then
                    object.Size = state.Size * factor
                    object.Heat = state.Heat * factor
                elseif state.Kind == "Sound" then
                    object.Volume = state.Original * factor
                elseif state.Kind == "GuiObject" then
                    object.BackgroundTransparency = 1 - (1 - state.Background) * factor

                    if state.Image ~= nil then
                        object.ImageTransparency = 1 - (1 - state.Image) * factor
                    end

                    if state.Text ~= nil then
                        object.TextTransparency = 1 - (1 - state.Text) * factor
                    end
                end
            end
        end
    end

    local function fadeCrucifixVisuals(states, initialFactor, endFactor, duration)
        if duration <= 0 then
            setCrucifixVisualFactor(states, endFactor)
            return
        end

        local startTime = os.clock()

        while true do
            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local eased = easeCrucifix(alpha)
            setCrucifixVisualFactor(
                states,
                initialFactor + (endFactor - initialFactor) * eased
            )

            if alpha >= 1 then
                break
            end

            RunService.Heartbeat:Wait()
        end
    end

    local function findCrucifixBeams(rushNew)
        local preferred = {}
        local fallback = {}

        for _, descendant in ipairs(rushNew:GetDescendants()) do
            if descendant:IsA("Beam") then
                table.insert(fallback, descendant)

                local ancestor = descendant.Parent
                while ancestor and ancestor ~= rushNew do
                    if string.lower(ancestor.Name) == "particlesin" then
                        table.insert(preferred, descendant)
                        break
                    end
                    ancestor = ancestor.Parent
                end

                if string.lower(descendant.Name) == "particlesin" then
                    local exists = false
                    for _, selected in ipairs(preferred) do
                        if selected == descendant then
                            exists = true
                            break
                        end
                    end
                    if not exists then
                        table.insert(preferred, descendant)
                    end
                end
            end
        end

        local beams = #preferred > 0 and preferred or fallback
        table.sort(beams, function(a, b)
            return a:GetFullName() < b:GetFullName()
        end)

        return beams
    end

    local function prepareCrucifixBeams(beams, rushNew, movingAttachment)
        for index, beam in ipairs(beams) do
            if beam.Parent then
                if not beam.Attachment0 then
                    beam.Attachment0 = movingAttachment
                end

                if not beam.Attachment1 or beam.Attachment1 == beam.Attachment0 then
                    local endpoint = Instance.new("Attachment")
                    endpoint.Name = "CrucifixBeamEndpoint" .. tostring(index)
                    local angle = (index - 1) * (math.pi / 2)
                    local offset = Vector3.new(
                        math.cos(angle) * 3,
                        2,
                        math.sin(angle) * 3
                    )
                    endpoint.Position = movingAttachment.Position
                        + rushNew.CFrame:VectorToObjectSpace(offset)
                    endpoint.Parent = rushNew
                    beam.Attachment1 = endpoint
                end

                if beam.Width0 <= 0 and beam.Width1 <= 0 then
                    beam.Width0 = 0.3
                    beam.Width1 = 0.3
                end

                beam.Enabled = true
                beam.Transparency = NumberSequence.new(1)
            end
        end
    end

    local crucifixBeamSoundIds = {
        "124444290902740",
        "100133789671771",
        "133850299035625",
        "120232105146350"
    }

    local function createCrucifixBeamFeedback()
        local beamCameraShaker = nil
        local shakeCleanupScheduled = false

        local function trigger(index)
            local soundId = crucifixBeamSoundIds[index]
            if not soundId then
                return
            end

            local sound = Instance.new("Sound")
            sound.Name = "CrucifixBeamSound" .. tostring(index)
            sound.SoundId = "rbxassetid://" .. soundId
            sound.Volume = 7
            sound.Looped = false
            sound.Parent = game:GetService("SoundService")
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
            sound:Play()

            if not beamCameraShaker then
                local created, shaker = pcall(function()
                    local currentShaker = createIsolatedReboundShaker(
                        Enum.RenderPriority.Camera.Value,
                        function(shakeCf)
                            local camera = workspace.CurrentCamera
                            if camera then
                                camera.CFrame = camera.CFrame * shakeCf
                            end
                        end
                    )
                    currentShaker:Start()
                    return currentShaker
                end)
                if created then
                    beamCameraShaker = shaker
                end
            end

            if beamCameraShaker then
                local started, shakeInstance = pcall(function()
                    return beamCameraShaker:StartShake(10, 28, 0.1, 0.25, 0.35)
                end)
                if started and shakeInstance then
                    task.delay(0.3, function()
                        pcall(function()
                            shakeInstance:StartFadeOut(3)
                        end)
                    end)
                else
                    pcall(function()
                        beamCameraShaker:ShakeOnce(10, 28, 0.1, 3, 0.25, 0.35)
                    end)
                end

                if not shakeCleanupScheduled then
                    shakeCleanupScheduled = true
                    task.delay(4.5, function()
                        if beamCameraShaker then
                            pcall(function()
                                beamCameraShaker:Stop()
                            end)
                        end
                    end)
                end
            end
        end

        return trigger
    end

    local function revealCrucifixBeams(beams, onBeamBegin)
        local startTime = os.clock()
        local perBeamDuration = 0.5
        local staggerDelay = 0.25
        local totalDuration = perBeamDuration + math.max(0, #beams - 1) * staggerDelay
        local begun = {}

        while true do
            local elapsed = os.clock() - startTime

            for index, beam in ipairs(beams) do
                if beam and beam.Parent then
                    local beamStartTime = (index - 1) * staggerDelay
                    if elapsed >= beamStartTime and not begun[index] then
                        begun[index] = true
                        if onBeamBegin then
                            onBeamBegin(index)
                        end
                    end

                    local beamAlpha = math.clamp(
                        (elapsed - beamStartTime) / perBeamDuration,
                        0,
                        1
                    )
                    beam.Enabled = true
                    beam.Transparency = NumberSequence.new(1 - easeCrucifix(beamAlpha))
                end
            end

            if elapsed >= totalDuration then
                break
            end
            RunService.Heartbeat:Wait()
        end

        for _, beam in ipairs(beams) do
            if beam and beam.Parent then
                beam.Enabled = true
                beam.Transparency = NumberSequence.new(0)
            end
        end
    end

    local function fadeCrucifixBeamsOut(beams, duration)
        local startTime = os.clock()

        while true do
            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local transparency = easeCrucifix(alpha)

            for _, beam in ipairs(beams) do
                if beam and beam.Parent then
                    beam.Transparency = NumberSequence.new(transparency)
                end
            end

            if alpha >= 1 then
                break
            end
            RunService.Heartbeat:Wait()
        end

        for _, beam in ipairs(beams) do
            if beam and beam.Parent then
                beam.Transparency = NumberSequence.new(1)
                beam.Enabled = false
            end
        end
    end

    local function moveCrucifixAttachment(attachment, targetPosition, duration)
        local origin = attachment.Position
        local startTime = os.clock()

        while true do
            if not attachment.Parent then
                return false
            end

            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            local progress = easeCrucifix(alpha)
            attachment.Position = origin:Lerp(targetPosition, progress)

            if alpha >= 1 then
                attachment.Position = targetPosition
                return true
            end
            RunService.Heartbeat:Wait()
        end
    end

    local function fadeCrucifixDescendantsRecursively(root, duration)
        local found = {}
        local allStates = {}
        local stateCount = 0

        local function findChildren(object)
            if not object or found[object] then
                return
            end
            found[object] = true

            local states = getCrucifixVisualStates(object, nil, true)
            for _, state in ipairs(states) do
                table.insert(allStates, state)
                stateCount = stateCount + 1
            end

            for _, child in ipairs(object:GetChildren()) do
                findChildren(child)
            end
        end

        local startTime = os.clock()
        while true do
            if not root.Parent then
                return
            end

            findChildren(root)
            local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
            setCrucifixVisualFactor(allStates, 1 - easeCrucifix(alpha))

            if alpha >= 1 then
                break
            end

            for _, object in ipairs(root:GetDescendants()) do
                if not found[object] then
                    findChildren(object)
                end
            end
            RunService.Heartbeat:Wait()
        end
    end

    local function startCrucifixAmbientShake(replacement)
        local stepName = "ReboundCrucifixAmbient_"
            .. game:GetService("HttpService"):GenerateGUID(false)
        local startedAt = os.clock()
        local active = true
        local lastOffset = CFrame.new()
        local lastCamera = nil

        local function stop()
            if not active then
                return
            end
            active = false
            RunService:UnbindFromRenderStep(stepName)
        end

        RunService:BindToRenderStep(
            stepName,
            Enum.RenderPriority.Camera.Value + 3,
            function()
                if not replacement.Parent then
                    stop()
                    return
                end

                local camera = workspace.CurrentCamera
                if not camera then
                    return
                end

                if lastCamera ~= camera then
                    lastCamera = camera
                    lastOffset = CFrame.new()
                end

                local elapsed = os.clock() - startedAt
                local strength = easeCrucifix(math.clamp(elapsed / 0.5, 0, 1))
                local offset = CFrame.new(
                    math.sin(elapsed * 13) * 0.055 * strength,
                    math.sin(elapsed * 16 + 0.7) * 0.04 * strength,
                    0
                ) * CFrame.Angles(
                    math.sin(elapsed * 12) * math.rad(0.085) * strength,
                    math.sin(elapsed * 10 + 1.1) * math.rad(0.065) * strength,
                    0
                )

                camera.CFrame = camera.CFrame * lastOffset:Inverse() * offset
                lastOffset = offset
            end
        )

        return stop
    end

    local function runCrucifixReplacement(originalCFrame)

        local loadedSuccessfully, replacement = pcall(function()
            return game:GetObjects("rbxassetid://86848040233512")[1]
        end)

        if not loadedSuccessfully or not replacement then

            return
        end

        local targetCFrame = originalCFrame + Vector3.new(0, 0, 0)
        local bro = replacement.Name == "BRO" and replacement
            or replacement:FindFirstChild("BRO", true)

        local placed, placementError = pcall(function()
            if replacement:IsA("Model") then
                if bro and bro:IsA("Model") then
                    local pivotShift = targetCFrame * bro:GetPivot():Inverse()
                    replacement:PivotTo(pivotShift * replacement:GetPivot())
                else
                    replacement:PivotTo(targetCFrame)
                end
            elseif bro and bro:IsA("Model") then
                bro:PivotTo(targetCFrame)
            elseif replacement:IsA("BasePart") then
                replacement.CFrame = targetCFrame
            end

            for _, descendant in ipairs(replacement:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.Anchored = true
                    descendant.CanCollide = false
                    descendant.CanTouch = false
                end
            end

            if replacement:IsA("BasePart") then
                replacement.Anchored = true
                replacement.CanCollide = false
                replacement.CanTouch = false
            end

            replacement.Parent = workspace
        end)

        if not placed then

            replacement:Destroy()
            return
        end

        local stopAmbientShake = startCrucifixAmbientShake(replacement)
        task.delay(30, function()
            stopAmbientShake()
            if replacement and replacement.Parent then
                replacement:Destroy()
            end
        end)

        local animationOK, animationError = xpcall(function()
            local rushNew = (bro and bro:FindFirstChild("RushNew", true))
                or replacement:FindFirstChild("RushNew", true)
            if replacement.Name == "RushNew" and replacement:IsA("BasePart") then
                rushNew = replacement
            end
            local attachment = rushNew and rushNew:FindFirstChild("Attachment", true)
            if attachment and not attachment:IsA("Attachment") then
                attachment = nil
            end
            if not rushNew then

            elseif not attachment then

            else

            end

            task.wait(2.3)
            if not replacement.Parent then
                return
            end

            if rushNew and rushNew:IsA("BasePart") and attachment then
                local beams = findCrucifixBeams(rushNew)
                local introStates = getCrucifixVisualStates(attachment, function(object)
                    if not object:IsA("Beam") then
                        return true
                    end
                    for _, beam in ipairs(beams) do
                        if object == beam then
                            return false
                        end
                    end
                    return true
                end)

                setCrucifixVisualFactor(introStates, 0)
                prepareCrucifixBeams(beams, rushNew, attachment)

                local originalPosition = attachment.Position
                local upOffset = rushNew.CFrame:VectorToObjectSpace(Vector3.new(0, 3, 0))
                local downOffset = rushNew.CFrame:VectorToObjectSpace(Vector3.new(0, -20, 0))
                local upPosition = originalPosition + upOffset
                local downPosition = upPosition + downOffset

                task.spawn(function()
                    if attachment.Parent then
                        fadeCrucifixVisuals(introStates, 0, 1, 0.6)
                    end
                end)

                local beamsRevealFinished = #beams == 0
                if not beamsRevealFinished then
                    local playBeamFeedback = createCrucifixBeamFeedback()
                    task.spawn(function()
                        task.wait(0.8)
                        if replacement.Parent and attachment.Parent then
                            pcall(revealCrucifixBeams, beams, playBeamFeedback)
                        end
                        beamsRevealFinished = true
                    end)
                end

                if not moveCrucifixAttachment(attachment, upPosition, 1.8) then
                    return
                end

                while not beamsRevealFinished and replacement.Parent and attachment.Parent do
                    RunService.Heartbeat:Wait()
                end

                if not moveCrucifixAttachment(attachment, downPosition, 1.2) then
                    return
                end
                task.wait(2)
                fadeCrucifixBeamsOut(beams, 0.5)
            end
        end, function(err)
            return tostring(err) .. "\n" .. debug.traceback()
        end)

        if not animationOK then

        end
        local fadeOK, fadeError = pcall(function()
            fadeCrucifixDescendantsRecursively(replacement, 1)
        end)
        if not fadeOK then

        end
        if replacement.Parent then
            for _, descendant in ipairs(replacement:GetDescendants()) do
                if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")
                    or descendant:IsA("Trail") or descendant:IsA("Sparkles")
                    or descendant:IsA("Smoke") or descendant:IsA("Fire") then
                    pcall(function()
                        descendant.Enabled = false
                    end)
                end
            end
        end
        task.wait(3)
        stopAmbientShake()
        if replacement then

            replacement:Destroy()
        end
    end


    function SpawnReboundEntity(startRoomType)
        if reboundSealed then
            return false
        end
        if not reboundTemplate then
            for attempt = 1, 6 do
                if reboundSealed then
                    return false
                end
                local success, loaded = pcall(function()
                    return game:GetObjects("rbxassetid://" .. testModelId)[1]
                end)
                if success and loaded then
                    reboundTemplate = loaded
                    break
                end
                if attempt < 6 then
                    task.wait(0.4)
                end
            end
        end

        if reboundSealed then
            return false
        end
        if not reboundTemplate then

            return false
        end

        local testEntity = reboundTemplate:Clone()
        if reboundSealed then
            if testEntity then
                testEntity:Destroy()
            end
            return false
        end
        if not testEntity then
            return false
        end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "Rebound" then
                pcall(function()
                    obj:Destroy()
                end)
            end
        end
        testEntity.Name = "Rebound"
        testEntity.Parent = workspace

        local primaryPart
        if testEntity:IsA("Model") then
            primaryPart = testEntity.PrimaryPart or testEntity:FindFirstChildWhichIsA("BasePart", true)
        elseif testEntity:IsA("BasePart") then
            primaryPart = testEntity
        end
        if not primaryPart then
            testEntity:Destroy()
            return false
        end

        primaryPart.Anchored = true
        primaryPart.CanCollide = false

        task.spawn(function()
            if reboundSealed or not primaryPart.Parent then
                return
            end
            local targetRoom
            if startRoomType == "start" then
                targetRoom = workspace.CurrentRooms:FindFirstChild("0")
            else
                local maxRoom = GetMaxExistingRoom()
                targetRoom = workspace.CurrentRooms:FindFirstChild(tostring(maxRoom))
            end

            if targetRoom then
                local targetPart
                if targetRoom:FindFirstChild("Nodes") then
                    targetPart = targetRoom:FindFirstChild("RoomEntrance")
                        or targetRoom:FindFirstChild("RoomExit")
                else
                    targetPart = targetRoom:FindFirstChild("RoomExit")
                        or targetRoom:FindFirstChild("RoomEntrance")
                end
                if not reboundSealed and primaryPart.Parent
                    and targetPart and targetPart:IsA("BasePart") then
                    primaryPart.CFrame = targetPart.CFrame + Vector3.new(0, 1, 0)
                end
            end

            task.wait(2)
            if not reboundSealed and primaryPart.Parent then
                StartEntityLogic(primaryPart, startRoomType)
            end
        end)
        return true
    end

    function StartEntityLogic(primaryPart, startRoomType)
        if reboundSealed or not primaryPart or not primaryPart.Parent then
            return
        end

        local lastProximityShake = 0
        task.spawn(function()
            local RunService = game:GetService("RunService")
            local player = game.Players.LocalPlayer

            while not reboundSealed and primaryPart and primaryPart.Parent do
                RunService.RenderStepped:Wait()
                if reboundSealed or not primaryPart or not primaryPart.Parent then
                    break
                end

                local character = player and player.Character
                local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                if humanoid and rootPart and humanoid.Health > 0 then
                    local distance = (primaryPart.Position - rootPart.Position).Magnitude

                    if distance <= 80 and os.clock() - lastProximityShake >= 0.12 then
                        local alpha = math.clamp(1 - distance / 80, 0, 1)
                        local amplitude = (0.3 + 8.2 * (alpha ^ 1.35)) * 3
                        local roughness = (45 + 35 * alpha) * 0.25
                        local positionInfluence = 0.35 + 0.4 * alpha
                        local rotationInfluence = 0.3 + 0.4 * alpha

                        reboundCameraShake:ShakeOnce(
                            amplitude,
                            roughness,
                            0.01,
                            0.16,
                            positionInfluence,
                            rotationInfluence
                        )

                        lastProximityShake = os.clock()
                    end
                end
            end

        end)

        local v305 = 1.4
        local v306 = 0.4
        local v307 = Vector3.new(0, 0, 0)
        local v310 = workspace.CurrentRooms

        local detectedPlayer = false
        local ceaseSpeedScale = 1
        local ceaseFreezeActive = false
        local ceaseFreezeToken = 0
        local ceaseStoredEffects = {}
        local ceaseDescendantConnection = nil
        local ceaseSoundConnection = nil
        local reboundMoving = false
        local activeMovementTween = nil
        local activeMovementTarget = nil
        local activeMovementOrigin = nil
        local ceaseStopMotionTween = nil
        local ceaseResumeMotionTween = nil
        local reboundMovementEnded = false
        local reboundModel = primaryPart:FindFirstAncestor("Rebound")
        if not reboundModel and primaryPart.Name == "Rebound" then
            reboundModel = primaryPart
        end

        local function easeCease(alpha)
            alpha = math.clamp(alpha, 0, 1)
            return alpha * alpha * (3 - 2 * alpha)
        end

        local function applyCeaseScale(scale)
            ceaseSpeedScale = math.clamp(scale, 0, 1)
            for obj, state in pairs(ceaseStoredEffects) do
                if obj.Parent then
                    if state.IsParticle then
                        pcall(function()
                            obj.TimeScale = state.TimeScale * ceaseSpeedScale
                        end)
                    else
                        pcall(function()
                            obj.PlaybackSpeed = state.PlaybackSpeed * ceaseSpeedScale
                        end)
                        pcall(function()
                            obj.Volume = state.Volume * ceaseSpeedScale
                        end)
                        if ceaseSpeedScale <= 0 then
                            if not state.PausedByCease and obj.IsPlaying then
                                pcall(function()
                                    obj:Pause()
                                    state.PausedByCease = true
                                end)
                            end
                        elseif state.PausedByCease then
                            pcall(function()
                                obj:Resume()
                                state.PausedByCease = false
                            end)
                        end
                    end
                end
            end
        end

        local function trackCeaseEffect(obj)
            if ceaseStoredEffects[obj] then
                return
            end
            if obj:IsA("ParticleEmitter") then
                ceaseStoredEffects[obj] = {
                    IsParticle = true,
                    TimeScale = obj.TimeScale
                }
            elseif obj:IsA("Sound") then
                ceaseStoredEffects[obj] = {
                    IsParticle = false,
                    PlaybackSpeed = obj.PlaybackSpeed,
                    Volume = obj.Volume,
                    PausedByCease = false
                }
            else
                return
            end

            if ceaseFreezeActive then
                local state = ceaseStoredEffects[obj]
                if state.IsParticle then
                    pcall(function()
                        obj.TimeScale = state.TimeScale * ceaseSpeedScale
                    end)
                else
                    pcall(function()
                        obj.PlaybackSpeed = state.PlaybackSpeed * ceaseSpeedScale
                    end)
                    pcall(function()
                        obj.Volume = state.Volume * ceaseSpeedScale
                    end)
                end
            end
        end

        local function restoreCeaseEffects(resumeMovement)
            ceaseFreezeToken = ceaseFreezeToken + 1
            if ceaseStopMotionTween then
                ceaseStopMotionTween:Cancel()
                ceaseStopMotionTween = nil
            end
            if ceaseResumeMotionTween then
                ceaseResumeMotionTween:Cancel()
                ceaseResumeMotionTween = nil
            end
            if ceaseDescendantConnection then
                ceaseDescendantConnection:Disconnect()
                ceaseDescendantConnection = nil
            end
            if ceaseSoundConnection then
                ceaseSoundConnection:Disconnect()
                ceaseSoundConnection = nil
            end
            for obj, state in pairs(ceaseStoredEffects) do
                if obj.Parent then
                    if state.IsParticle then
                        pcall(function()
                            obj.TimeScale = state.TimeScale
                        end)
                    else
                        pcall(function()
                            obj.PlaybackSpeed = state.PlaybackSpeed
                        end)
                        pcall(function()
                            obj.Volume = state.Volume
                        end)
                        if state.PausedByCease then
                            pcall(function()
                                obj:Resume()
                            end)
                        end
                    end
                end
            end
            ceaseStoredEffects = {}
            ceaseSpeedScale = 1
            ceaseFreezeActive = false
            if resumeMovement and not detectedPlayer and primaryPart.Parent and activeMovementTarget then
                local remainingDistance = (activeMovementTarget.Position - primaryPart.Position).Magnitude
                local originalDistance = activeMovementOrigin
                    and (activeMovementTarget.Position - activeMovementOrigin.Position).Magnitude or 0
                local originalSpeed = originalDistance > 0 and originalDistance / v305 or 0
                if remainingDistance > 0.01 then
                    local remainingDuration = originalSpeed > 0
                        and math.max(remainingDistance / originalSpeed, 0.01) or v305
                    activeMovementTween = game.TweenService:Create(
                        primaryPart,
                        TweenInfo.new(remainingDuration, Enum.EasingStyle.Linear),
                        { CFrame = activeMovementTarget }
                    )
                    activeMovementTween:Play()
                end
            end
        end

        local function trySealRebound(character)
            if reboundSealed or not primaryPart.Parent
                or not character or character:GetAttribute("Hiding") then

                return false
            end
            local tool = getCrucifixTool(character)
            if not tool then

                return false
            end


            local sealCFrame = primaryPart.CFrame
            reboundSealed = true
            detectedPlayer = true
            reboundMovementEnded = true
            reboundMoving = false
            stopReboundCameraShake()

            if activeMovementTween then
                activeMovementTween:Cancel()
                activeMovementTween = nil
            end
            if ceaseFreezeActive then
                restoreCeaseEffects(false)
            end
            if movingSoundForWave and movingSoundForWave.Parent then
                movingSoundForWave:Stop()
            end

            tool:Destroy()
            if reboundModel and reboundModel.Parent then
                reboundModel:Destroy()
            elseif primaryPart.Parent then
                primaryPart:Destroy()
            end

            if doorSignal then
                doorSignal:Fire()
            end
            task.spawn(runCrucifixReplacement, sealCFrame)
            return true
        end

        local function triggerCeaseFreeze(ceaseModel)
            if ceaseFreezeActive or not reboundMoving or reboundMovementEnded
                or not primaryPart.Parent or ceaseHandledModels[ceaseModel]
                or not activeMovementTween
                or activeMovementTween.PlaybackState ~= Enum.PlaybackState.Playing then
                return
            end

            ceaseHandledModels[ceaseModel] = true
            ceaseFreezeActive = true
            ceaseFreezeToken = ceaseFreezeToken + 1
            local token = ceaseFreezeToken

            activeMovementTween:Cancel()
            activeMovementTween = nil
            local startCFrame = primaryPart.CFrame
            local destination = activeMovementTarget
            local remainingDistance = (destination.Position - startCFrame.Position).Magnitude
            local originalDistance = activeMovementOrigin
                and (destination.Position - activeMovementOrigin.Position).Magnitude or remainingDistance
            local initialSpeed = originalDistance / v305
            local stopDistance = math.min(remainingDistance, initialSpeed * 2.25 / 5)
            local stopFraction = remainingDistance > 0.001 and stopDistance / remainingDistance or 0
            local stoppingCFrame = startCFrame:Lerp(destination, math.clamp(stopFraction, 0, 1))
            ceaseStopMotionTween = game.TweenService:Create(
                primaryPart,
                TweenInfo.new(2.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { CFrame = stoppingCFrame }
            )
            ceaseStopMotionTween:Play()

            if reboundModel then
                trackCeaseEffect(reboundModel)
                for _, obj in ipairs(reboundModel:GetDescendants()) do
                    trackCeaseEffect(obj)
                end
                ceaseDescendantConnection = reboundModel.DescendantAdded:Connect(function(obj)
                    if ceaseFreezeToken == token and ceaseFreezeActive then
                        trackCeaseEffect(obj)
                    end
                end)
            end

            local soundFolder = workspace:FindFirstChild("HardCoreSound")
            if soundFolder then
                for _, obj in ipairs(soundFolder:GetDescendants()) do
                    if obj:IsA("Sound") and obj.Name:lower():find("rebound", 1, true) then
                        trackCeaseEffect(obj)
                    end
                end
                ceaseSoundConnection = soundFolder.DescendantAdded:Connect(function(obj)
                    if ceaseFreezeToken == token and ceaseFreezeActive
                        and obj:IsA("Sound") and obj.Name:lower():find("rebound", 1, true) then
                        trackCeaseEffect(obj)
                    end
                end)
            end

            task.spawn(function()
                local function isValid()
                    return ceaseFreezeToken == token
                        and primaryPart.Parent ~= nil
                        and not reboundMovementEnded
                end

                local function transition(fromScale, toScale, duration)
                    local startedAt = os.clock()
                    while true do
                        if not isValid() then
                            if ceaseFreezeToken == token then
                                restoreCeaseEffects()
                            end
                            return false
                        end
                        local alpha = math.clamp((os.clock() - startedAt) / duration, 0, 1)
                        applyCeaseScale(fromScale + (toScale - fromScale) * easeCease(alpha))
                        if alpha >= 1 then
                            return true
                        end
                        RunService.Heartbeat:Wait()
                    end
                end

                if not transition(1, 0, 2.25) then
                    return
                end
                if ceaseStopMotionTween then
                    ceaseStopMotionTween:Cancel()
                    ceaseStopMotionTween = nil
                end
                local holdStartedAt = os.clock()
                while os.clock() - holdStartedAt < 13 do
                    if not isValid() then
                        if ceaseFreezeToken == token then
                            restoreCeaseEffects()
                        end
                        return
                    end
                    task.wait(0.05)
                end
                local remainingDistance = (destination.Position - primaryPart.Position).Magnitude
                local recoverDistance = math.min(remainingDistance, initialSpeed * 2 / 5)
                local recoverFraction = remainingDistance > 0.001
                    and recoverDistance / remainingDistance or 0
                local recoveringCFrame = primaryPart.CFrame:Lerp(
                    destination, math.clamp(recoverFraction, 0, 1)
                )
                ceaseResumeMotionTween = game.TweenService:Create(
                    primaryPart,
                    TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    { CFrame = recoveringCFrame }
                )
                ceaseResumeMotionTween:Play()
                if not transition(0, 1, 2) then
                    return
                end
                if ceaseFreezeToken == token then
                    restoreCeaseEffects(true)
                end
            end)
        end

        task.spawn(function()
            while primaryPart.Parent and not reboundMovementEnded and not reboundSealed do
                if reboundMoving and not ceaseFreezeActive then
                    local ceaseModel = workspace:FindFirstChild("Cease", true)
                    if ceaseModel and ceaseModel:IsA("Model")
                        and not ceaseHandledModels[ceaseModel] then
                        triggerCeaseFreeze(ceaseModel)
                    end
                end
                task.wait(0.1)
            end
            if ceaseFreezeActive then
                restoreCeaseEffects()
            end
        end)

        local function startReboundTween(targetCFrame)
            if reboundSealed or not primaryPart.Parent then
                return false
            end
            activeMovementOrigin = primaryPart.CFrame
            activeMovementTarget = targetCFrame
            activeMovementTween = game.TweenService:Create(
                primaryPart,
                TweenInfo.new(v305),
                { CFrame = targetCFrame }
            )
            reboundMoving = true
            activeMovementTween:Play()
            return true
        end

        local function waitReboundStep(duration)
            local elapsed = 0
            while not reboundSealed and elapsed < duration and primaryPart.Parent do
                local dt = RunService.Heartbeat:Wait()
                if not ceaseFreezeActive then
                    elapsed = elapsed + dt
                end
            end
            while not reboundSealed and ceaseFreezeActive and primaryPart.Parent do
                RunService.Heartbeat:Wait()
            end
            return not reboundSealed and primaryPart.Parent ~= nil
        end

        local function waitForReboundArrival()
            local destination = activeMovementTarget
            if not destination then
                return false
            end
            while not reboundSealed and primaryPart.Parent do
                if not ceaseFreezeActive then
                    local remaining = (destination.Position - primaryPart.Position).Magnitude
                    if remaining <= 0.05 then
                        return true
                    end
                    local state = activeMovementTween and activeMovementTween.PlaybackState
                    if not activeMovementTween
                        or state == Enum.PlaybackState.Cancelled
                        or state == Enum.PlaybackState.Completed then
                        local fullDistance = activeMovementOrigin
                            and (destination.Position - activeMovementOrigin.Position).Magnitude or remaining
                        local segmentSpeed = fullDistance > 0 and fullDistance / v305 or 0
                        local duration = segmentSpeed > 0
                            and math.max(remaining / segmentSpeed, 0.01) or v305
                        activeMovementTween = game.TweenService:Create(
                            primaryPart,
                            TweenInfo.new(duration, Enum.EasingStyle.Linear),
                            { CFrame = destination }
                        )
                        activeMovementTween:Play()
                    end
                end
                RunService.Heartbeat:Wait()
            end
            return false
        end

        local function CheckLineOfSight(entityPart, player, maxDistance)
            if not entityPart or not player or not player.Character then
                return false
            end
            if player.Character:GetAttribute("Hiding") then
                return false
            end
            
            local hum = player.Character:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then
                return false
            end
            
            local origin = entityPart.Position
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end
            
            local targetPos = hrp.Position
            local distance = (targetPos - origin).Magnitude
            
            if distance <= 0.001 or distance > maxDistance then
                return false
            end
            local direction = (targetPos - origin).Unit * maxDistance
            local ray = Ray.new(origin, direction)
            local hitPart, _ = workspace:FindPartOnRay(ray, entityPart)
            
            return hitPart and hitPart:IsDescendantOf(player.Character)
        end

        local function CheckCrucifixRaycast(entityPart, player, maxDistance)
            if reboundSealed or not entityPart or not entityPart.Parent or not player then
                return nil
            end
            local character = player.Character
            if not character then

                return nil
            end
            if not character:IsDescendantOf(workspace) then

                return nil
            end
            if character:GetAttribute("Hiding") then

                return nil
            end

            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or humanoid.Health <= 0 then

                return nil
            end
            if not rootPart or not rootPart:IsA("BasePart") then

                return nil
            end

            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = { reboundModel or entityPart }

            local targets = { rootPart }
            for _, partName in ipairs({ "Head", "UpperTorso", "Torso", "LowerTorso" }) do
                local part = character:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    table.insert(targets, part)
                end
            end

            for _, part in ipairs(targets) do
                if reboundSealed or not entityPart.Parent then
                    return nil
                end
                local direction = part.Position - entityPart.Position
                local distance = direction.Magnitude
                if distance > 0.001 and distance <= maxDistance then
                    local result = workspace:Raycast(entityPart.Position, direction, raycastParams)
                    local hitPart = result and result.Instance
                    local hitCharacter = hitPart and getCharacterFromRaycastHit(hitPart) or nil

                    if not hitCharacter then
                        local partEntry = rayEntryDistanceToPart(
                            entityPart.Position, direction.Unit, part)
                        if partEntry and partEntry <= distance + 0.01 then
                            if not result or result.Distance > partEntry + 0.02 then
                                hitCharacter = character
                            end
                        end
                    end

                    if hitCharacter and not hitCharacter:GetAttribute("Hiding") then
                        local hitHumanoid = hitCharacter:FindFirstChildWhichIsA("Humanoid")
                        if hitHumanoid and hitHumanoid.Health > 0 then
                            local tool = getCrucifixTool(hitCharacter)
                            if tool then
                                return hitCharacter
                            end
                        end
                    end
                end
            end

            return nil
        end

        local function ExecutePlayer()
            if reboundSealed or detectedPlayer then return end
            detectedPlayer = true
            if ceaseFreezeActive then
                restoreCeaseEffects()
            end

            local vu321 = Instance.new("ScreenGui")
            local vu322 = Instance.new("ImageLabel")
            local v323 = Instance.new("ImageLabel")
            local v324 = Instance.new("ImageLabel")
            
            vu321.Name = "TestEntityJs"
            vu321.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            
            vu322.Name = "Static"
            vu322.Parent = vu321
            vu322.BackgroundColor3 = Color3.fromRGB(0, 63, 139)
            vu322.BackgroundTransparency = 1
            vu322.BorderSizePixel = 0
            vu322.Size = UDim2.new(1, 0, 1, 0)
            vu322.Image = "rbxassetid://236543215"
            vu322.ImageColor3 = Color3.fromRGB(0, 255, 255)
            vu322.ImageTransparency = 1
            
            v323.Name = "TestEntity"
            v323.Parent = vu321
            v323.BackgroundTransparency = 1
            v323.Position = UDim2.new(0.486631036, 0, 0.479363143, 0)
            v323.Size = UDim2.new(0.0267379656, 0, 0.0387096703, 0)
            v323.Image = "rbxassetid://97823818277141"
            
            v324.Name = "JSSIZE"
            v324.Parent = vu321
            v324.BackgroundTransparency = 1
            v324.Position = UDim2.new(-0.586452842, 0, -1.25140607, 0)
            v324.Size = UDim2.new(2.12834215, 0, 3.08128953, 0)
            v324.Visible = false
            v324.Image = "rbxassetid://10914800940"

            local function v326()
                local v325 = Instance.new("LocalScript", vu322)
                while v325.Parent and v325.Parent.Parent do
                    v325.Parent.Image = "rbxassetid://236543215"
                    task.wait(0.015)
                    v325.Parent.Rotation = 0
                    task.wait(0.015)
                    v325.Parent.Rotation = 180
                    task.wait(0.015)
                    v325.Parent.Image = "rbxassetid://236777652"
                    task.wait(0.015)
                    v325.Parent.Rotation = 0
                    task.wait(0.015)
                    v325.Parent.Rotation = 180
                    task.wait(0.015)
                end
            end
            coroutine.wrap(v326)()

            local v327 = Instance.new("LocalScript", vu321)
            local vu328 = game.ReplicatedStorage
            local vu329 = game.Players.LocalPlayer
            local vu330 = v327.Parent
            local vu331 = vu330.Static
            local vu332 = vu330.TestEntity
            
            local killSound = Instance.new("Sound")
            killSound.SoundId = "rbxassetid://94785993416953"
            killSound.Parent = workspace
            killSound.Volume = 2

            (function()
                game.TweenService:Create(vu331, TweenInfo.new(0.5), {
                    BackgroundTransparency = 0,
                    ImageTransparency = 0.8
                }):Play()
                
                game.TweenService:Create(vu332, TweenInfo.new(0.5), {
                    Size = v324.Size,
                    Position = v324.Position
                }):Play()
                
                killSound:Play()
                
                spawn(function()
                    wait(0.3)
                    if reboundSealed then
                        return
                    end
                    local char = vu329.Character
                    if char then
                        local hum = char:FindFirstChildWhichIsA("Humanoid")
                        if hum and hum.Health > 0 then
                            local damage = 100
                            local willDie = hum.Health <= damage
                            if willDie then
                                local playerStats = vu328.GameStats:FindFirstChild("Player_" .. vu329.Name)
                                local total = playerStats and playerStats:FindFirstChild("Total")
                                local deathCause = total and total:FindFirstChild("DeathCause")
                                if deathCause then
                                    deathCause.Value = "Rebound"
                                end
                            end
                            hum:TakeDamage(damage)
                        end
                    end
                end)
                
                wait(0.5)
                game.TweenService:Create(vu331, TweenInfo.new(1), {
                    BackgroundTransparency = 1,
                    ImageTransparency = 1
                }):Play()
                game.TweenService:Create(vu332, TweenInfo.new(0.3), {
                    ImageTransparency = 1
                }):Play()
                wait(1)
                killSound:Destroy()
                vu330:Destroy()
            end)()
        end

        spawn(function()
            local player = Players.LocalPlayer

            while not reboundSealed and primaryPart and primaryPart.Parent do
                task.wait(0.05)
                if reboundSealed or not primaryPart or not primaryPart.Parent then
                    break
                end
                if workspace:FindFirstChild("SeekMov") or workspace.CurrentRooms:FindFirstChild("50") then
                    break
                end

                for _, candidate in ipairs(Players:GetPlayers()) do
                    local hitCharacter = CheckCrucifixRaycast(primaryPart, candidate, 100)
                    if hitCharacter and getCrucifixTool(hitCharacter) then
                        if trySealRebound(hitCharacter) then
                            break
                        end
                    end
                end

                if reboundSealed then
                    break
                end
                if CheckLineOfSight(primaryPart, player, 100) then
                    ExecutePlayer()
                end
            end
        end)

        if startRoomType == "start" then
            local currentRoom = 0
            local maxRoom = game.ReplicatedStorage.GameData.LatestRoom.Value

            while currentRoom <= maxRoom and not reboundSealed and primaryPart.Parent do
                if workspace:FindFirstChild("SeekMovingNewClone") or workspace.CurrentRooms:FindFirstChild("50") then
                    break
                end

                local targetRoom = v310:FindFirstChild(tostring(currentRoom))
                if targetRoom then
                    local targetCFrame
                    if targetRoom:FindFirstChild("Nodes") then
                        targetCFrame = (targetRoom:FindFirstChild("RoomEntrance") or targetRoom:FindFirstChild("RoomExit")).CFrame
                    else
                        targetCFrame = targetRoom.RoomExit.CFrame
                    end

                    if not startReboundTween(targetCFrame + v307) then
                        break
                    end

                    if not waitReboundStep(v306) then
                        break
                    end
                    if not waitForReboundArrival() then
                        break
                    end
                end

                maxRoom = game.ReplicatedStorage.GameData.LatestRoom.Value
                currentRoom = currentRoom + 1
            end
        else
            local currentRoom = GetMaxExistingRoom()
            local minRoom = math.max(0, currentRoom - 7)

            while currentRoom >= minRoom and not reboundSealed and primaryPart.Parent do
                if workspace:FindFirstChild("SeekMovingNewClone") or workspace.CurrentRooms:FindFirstChild("50") then
                    break
                end

                local targetRoom = v310:FindFirstChild(tostring(currentRoom))
                if targetRoom then
                    local targetCFrame
                    if targetRoom:FindFirstChild("Nodes") then
                        targetCFrame = (targetRoom:FindFirstChild("RoomEntrance") or targetRoom:FindFirstChild("RoomExit")).CFrame
                    else
                        targetCFrame = targetRoom.RoomExit.CFrame
                    end

                    if not startReboundTween(targetCFrame + v307) then
                        break
                    end

                    if not waitReboundStep(v306) then
                        break
                    end
                    if not waitForReboundArrival() then
                        break
                    end
                end

                currentRoom = currentRoom - 1
            end
        end

        while not reboundSealed and ceaseFreezeActive and primaryPart.Parent do
            RunService.Heartbeat:Wait()
        end
        reboundMovementEnded = true
        if ceaseFreezeActive then
            restoreCeaseEffects()
        end
        if primaryPart.Parent then
            primaryPart.Anchored = false
            primaryPart.CanCollide = false
        end
    end

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Rebound" or obj.Name == "Bound" or 
           (obj.Name:find("ReboundMovings") and not obj.Name:find("_Preloaded")) or 
           (obj.Name:find("ReboundSweep") and not obj.Name:find("_Preloaded")) then
            pcall(function() obj:Destroy() end)
        end
    end

    local sweepSound = PlayPreloadedSound("ReboundSweep", 2)
    
    local part = Instance.new("Part")
    part.Name = "Bound_" .. tick()
    part.Parent = workspace
    game.Lighting.MainColorCorrection.TintColor = Color3.fromRGB(61, 171, 98)
    game.Lighting.MainColorCorrection.Contrast = 0.2
    game.Lighting.MainColorCorrection.Saturation = -0.7

    local tween = game:GetService("TweenService")
    tween:Create(game.Lighting.MainColorCorrection, TweenInfo.new(5), {Contrast = 0}):Play()
    tween:Create(game.Lighting.MainColorCorrection, TweenInfo.new(5), {Saturation = 0}):Play()
    local TW = tween:Create(game.Lighting.MainColorCorrection, TweenInfo.new(5), {TintColor = Color3.fromRGB(255, 255, 255)})
    TW:Play()

    reboundCameraShake:ShakeOnce(10, 3, 0.1, 6, 2, 0.5)

    task.wait(3)

    local latestRoom = game.ReplicatedStorage.GameData.LatestRoom
    local doorGateOpen = false
    local acceptedDoorCount = 0
    doorSignal = Instance.new("BindableEvent")
    local doorConnection = latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
        if doorGateOpen and not reboundSealed then
            acceptedDoorCount = acceptedDoorCount + 1
            doorSignal:Fire()
        end
    end)

    local function waitForSoundToFinish(sound)
        if not sound or not sound.Parent then
            return
        end
        local finished = false
        local connection = sound.Ended:Connect(function()
            finished = true
        end)
        local startedAt = os.clock()
        while not reboundSealed and sound.Parent and not finished do
            if os.clock() - startedAt >= 120 then
                break
            end
            if not sound.IsLoaded and os.clock() - startedAt >= 15 then
                break
            end
            task.wait(0.05)
        end
        connection:Disconnect()
    end

    local function waitForNextQualifiedDoor()
        if reboundSealed then
            return false
        end
        local previousAcceptedCount = acceptedDoorCount
        doorGateOpen = true
        while not reboundSealed and acceptedDoorCount == previousAcceptedCount do
            doorSignal.Event:Wait()
        end
        doorGateOpen = false
        return not reboundSealed
    end

    local directions = { "latest", "start", "latest", "start" }
    for waveIndex, startRoomType in ipairs(directions) do
        if reboundSealed then
            break
        end
        SpawnReboundEntity(startRoomType)
        if reboundSealed then
            break
        end
        movingSoundForWave = PlayPreloadedSound("ReboundMovings", 3)
        waitForSoundToFinish(movingSoundForWave)
        movingSoundForWave = nil
        if reboundSealed then
            break
        end
        if waveIndex < #directions then
            if not waitForNextQualifiedDoor() then
                break
            end
        end
    end
    doorGateOpen = false
    doorConnection:Disconnect()
    if doorSignal then
        doorSignal:Destroy()
        doorSignal = nil
    end
    stopReboundCameraShake()
    doorSignal = nil
end

function entityBehaviors.REBOUNDrebound()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then
    return
end

local MODEL_ID = "134376611867298"
local MOVE_SPEED = 200
local HEIGHT_OFFSET = Vector3.new(0, 0, 0)
local HIT_DISTANCE = 100
local SHAKE_DISTANCE = 80
local SHAKE_INTERVAL = 0.12
local DAMAGE = 100
local FLASH_COLOR = Color3.fromRGB(135, 206, 235)
local FLASH_FADE_IN = 0.05
local FLASH_HOLD = 0.2
local FLASH_FADE_OUT = 0.5
local FLASH_TRANSPARENCY = 0.5

local previousRun = _G.__ReboundFourPassSession
if type(previousRun) == "table" and type(previousRun.Stop) == "function" then
    pcall(previousRun.Stop)
end

local session = {Active = true}
_G.__ReboundFourPassSession = session

local entity
local primaryPart
local pivotOffset
local shaker
local renderName
local renderBound = false
local flashGui
local deathTriggered = false

local function stopSession()
    if not session.Active then
        return
    end
    session.Active = false
    if renderBound then
        renderBound = false
        RunService:UnbindFromRenderStep(renderName)
    end
    if entity and entity.Parent then
        entity:Destroy()
    end
    if flashGui and flashGui.Parent then
        flashGui:Destroy()
    end
    if _G.__ReboundFourPassSession == session then
        _G.__ReboundFourPassSession = nil
    end
end

session.Stop = stopSession

local function flashSkyBlueOnce()
    local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5)
    if not playerGui or not session.Active then
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ReboundFourPassSkyFlash"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000
    gui.Parent = playerGui
    flashGui = gui

    local overlay = Instance.new("Frame")
    overlay.Name = "SkyBlueOverlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.Position = UDim2.fromScale(0, 0)
    overlay.BorderSizePixel = 0
    overlay.BackgroundColor3 = FLASH_COLOR
    overlay.BackgroundTransparency = 1
    overlay.Parent = gui

    local fadeIn = TweenService:Create(overlay, TweenInfo.new(FLASH_FADE_IN, Enum.EasingStyle.Linear), {
        BackgroundTransparency = FLASH_TRANSPARENCY
    })
    fadeIn:Play()
    fadeIn.Completed:Wait()
    if not session.Active or not gui.Parent then
        return
    end

    task.wait(FLASH_HOLD)
    if not session.Active or not gui.Parent then
        return
    end

    local fadeOut = TweenService:Create(overlay, TweenInfo.new(FLASH_FADE_OUT, Enum.EasingStyle.Linear), {
        BackgroundTransparency = 1
    })
    fadeOut:Play()
    fadeOut.Completed:Wait()
    if gui.Parent then
        gui:Destroy()
    end
    if flashGui == gui then
        flashGui = nil
    end
end

local function initializeShaker()
    local module = ReplicatedStorage:FindFirstChild("CameraShaker")
    if not module then
        return
    end
    local loaded, CameraShaker = pcall(require, module)
    if not loaded or not CameraShaker then
        return
    end
    local created, instance = pcall(function()
        return CameraShaker.new(Enum.RenderPriority.Camera.Value + 30, function() end)
    end)
    if not created or not instance then
        return
    end
    shaker = instance
    renderName = "ReboundFourPassShake_" .. HttpService:GenerateGUID(false)
    renderBound = true
    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 30, function(deltaTime)
        if not session.Active then
            return
        end
        local ok, offset = pcall(shaker.Update, shaker, deltaTime)
        if not ok then
            renderBound = false
            RunService:UnbindFromRenderStep(renderName)
            return
        end
        if typeof(offset) == "CFrame" then
            local camera = workspace.CurrentCamera
            if camera then
                camera.CFrame = camera.CFrame * offset
            end
        end
    end)
end

local function shakeOnce(...)
    if shaker and session.Active then
        pcall(shaker.ShakeOnce, shaker, ...)
    end
end

local function getOrderedNodes(folder)
    local nodes = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(nodes, child)
        end
    end
    table.sort(nodes, function(a, b)
        local an = tonumber(a.Name)
        local bn = tonumber(b.Name)
        if an and bn then
            return an < bn
        elseif an then
            return true
        elseif bn then
            return false
        end
        return a.Name < b.Name
    end)
    return nodes
end

local function getPathPositions()
    local currentRooms = workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then
        return {}
    end

    local rooms = {}
    for _, room in ipairs(currentRooms:GetChildren()) do
        local number = tonumber(room.Name)
        if number and room:IsA("Model") then
            table.insert(rooms, {Number = number, Room = room})
        end
    end
    table.sort(rooms, function(a, b)
        return a.Number < b.Number
    end)

    local points = {}
    local function append(part)
        if not part or not part:IsA("BasePart") then
            return
        end
        local position = part.Position + HEIGHT_OFFSET
        if #points == 0 or (points[#points] - position).Magnitude > 0.05 then
            table.insert(points, position)
        end
    end

    for _, entry in ipairs(rooms) do
        local room = entry.Room
        append(room:FindFirstChild("RoomEntrance"))
        local nodeFolder = room:FindFirstChild("Nodes") or room:FindFirstChild("PathfindNodes")
        if nodeFolder then
            for _, node in ipairs(getOrderedNodes(nodeFolder)) do
                append(node)
            end
        end
        append(room:FindFirstChild("RoomExit"))
    end
    return points
end

local function buildFourPassRoute(points)
    local route = {}
    for index = 1, #points do
        table.insert(route, points[index])
    end
    for index = #points - 1, 1, -1 do
        table.insert(route, points[index])
    end
    for index = 2, #points do
        table.insert(route, points[index])
    end
    for index = #points - 1, 1, -1 do
        table.insert(route, points[index])
    end
    return route
end

local function loadEntity()
    local loaded, asset = pcall(function()
        return game:GetObjects("rbxassetid://" .. MODEL_ID)[1]
    end)
    if not loaded or not asset then
        return false
    end

    if not asset:IsA("Model") and not asset:IsA("BasePart") then
        local nested = asset:FindFirstChildWhichIsA("Model", true)
            or asset:FindFirstChildWhichIsA("BasePart", true)
        if not nested then
            asset:Destroy()
            return false
        end
        entity = nested:Clone()
        asset:Destroy()
    else
        entity = asset
    end

    if entity:IsA("Model") then
        primaryPart = entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart", true)
    else
        primaryPart = entity
    end
    if not primaryPart then
        entity:Destroy()
        entity = nil
        return false
    end

    for _, part in ipairs(entity:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
        end
    end
    if entity:IsA("BasePart") then
        entity.Anchored = true
        entity.CanCollide = false
        entity.CanTouch = false
    end

    if entity:IsA("Model") then
        pivotOffset = primaryPart.CFrame:ToObjectSpace(entity:GetPivot())
    end
    entity.Name = "ReboundFourPass"
    entity.Parent = workspace
    return true
end

local function placeEntity(position, direction)
    if not entity or not entity.Parent then
        return
    end
    local horizontal = Vector3.new(direction.X, 0, direction.Z)
    local targetCFrame
    if horizontal.Magnitude > 0.001 then
        targetCFrame = CFrame.lookAt(position, position + horizontal.Unit)
    else
        targetCFrame = CFrame.new(position)
    end

    if entity:IsA("Model") then
        entity:PivotTo(targetCFrame * pivotOffset)
    else
        entity.CFrame = targetCFrame
    end
end

local function checkLineOfSight()
    if deathTriggered or not session.Active or not primaryPart or not primaryPart.Parent then
        return false
    end
    local character = player.Character
    if not character or character:GetAttribute("Hiding") then
        return false
    end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not rootPart then
        return false
    end

    local origin = primaryPart.Position
    local direction = rootPart.Position - origin
    local distance = direction.Magnitude
    if distance <= 0.001 or distance > HIT_DISTANCE then
        return false
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {entity}
    local result = workspace:Raycast(origin, direction, params)
    return result ~= nil and result.Instance:IsDescendantOf(character)
end

local function triggerJumpScare()
    if deathTriggered or not session.Active then
        return
    end
    deathTriggered = true
    task.spawn(function()
        local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5)
        if not playerGui or not session.Active then
            return
        end

        local gui = Instance.new("ScreenGui")
        gui.Name = "TestEntityJs"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 1001
        gui.Parent = playerGui

        local static = Instance.new("ImageLabel")
        static.Name = "Static"
        static.Size = UDim2.fromScale(1, 1)
        static.BackgroundColor3 = Color3.fromRGB(0, 63, 139)
        static.BackgroundTransparency = 1
        static.BorderSizePixel = 0
        static.Image = "rbxassetid://236543215"
        static.ImageColor3 = Color3.fromRGB(0, 255, 255)
        static.ImageTransparency = 1
        static.Parent = gui

        local face = Instance.new("ImageLabel")
        face.Name = "TestEntity"
        face.BackgroundTransparency = 1
        face.Position = UDim2.new(0.486631036, 0, 0.479363143, 0)
        face.Size = UDim2.new(0.0267379656, 0, 0.0387096703, 0)
        face.Image = "rbxassetid://97823818277141"
        face.Parent = gui

        local flickerActive = true
        task.spawn(function()
            while flickerActive and static.Parent do
                static.Image = "rbxassetid://236543215"
                static.Rotation = 0
                task.wait(0.015)
                static.Rotation = 180
                task.wait(0.015)
                static.Image = "rbxassetid://236777652"
                static.Rotation = 0
                task.wait(0.015)
                static.Rotation = 180
                task.wait(0.015)
            end
        end)

        local killSound = Instance.new("Sound")
        killSound.SoundId = "rbxassetid://94785993416953"
        killSound.Volume = 2
        killSound.Parent = workspace

        TweenService:Create(static, TweenInfo.new(0.5), {
            BackgroundTransparency = 0,
            ImageTransparency = 0.8
        }):Play()
        TweenService:Create(face, TweenInfo.new(0.5), {
            Size = UDim2.new(2.12834215, 0, 3.08128953, 0),
            Position = UDim2.new(-0.586452842, 0, -1.25140607, 0)
        }):Play()
        killSound:Play()

        task.delay(0.3, function()
            if not session.Active then
                return
            end
            local character = player.Character
            local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if humanoid.Health <= DAMAGE then
                    local stats = ReplicatedStorage:FindFirstChild("GameStats")
                    local playerStats = stats and stats:FindFirstChild("Player_" .. player.Name)
                    local total = playerStats and playerStats:FindFirstChild("Total")
                    local deathCause = total and total:FindFirstChild("DeathCause")
                    if deathCause then
                        pcall(function()
                            deathCause.Value = "Rebound"
                        end)
                    end
                end
                humanoid:TakeDamage(DAMAGE)
            end
        end)

        task.wait(0.5)
        if static.Parent and face.Parent then
            TweenService:Create(static, TweenInfo.new(1), {
                BackgroundTransparency = 1,
                ImageTransparency = 1
            }):Play()
            TweenService:Create(face, TweenInfo.new(0.3), {
                ImageTransparency = 1
            }):Play()
        end
        task.wait(1)
        flickerActive = false
        killSound:Destroy()
        if gui.Parent then
            gui:Destroy()
        end
    end)
end

local function startHitAndShakeDetection()
    task.spawn(function()
        local lastShake = 0
        while session.Active and primaryPart and primaryPart.Parent do
            RunService.RenderStepped:Wait()
            local character = player.Character
            local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart and humanoid.Health > 0 then
                local distance = (primaryPart.Position - rootPart.Position).Magnitude
                if distance <= SHAKE_DISTANCE and os.clock() - lastShake >= SHAKE_INTERVAL then
                    local alpha = math.clamp(1 - distance / SHAKE_DISTANCE, 0, 1)
                    local amplitude = (0.3 + 8.2 * (alpha ^ 1.35)) * 3
                    local roughness = (45 + 35 * alpha) * 0.25
                    local positionInfluence = 0.35 + 0.4 * alpha
                    local rotationInfluence = 0.3 + 0.4 * alpha
                    shakeOnce(amplitude, roughness, 0.01, 0.16, positionInfluence, rotationInfluence)
                    lastShake = os.clock()
                end
            end
        end
    end)

    task.spawn(function()
        while session.Active and primaryPart and primaryPart.Parent and not deathTriggered do
            if checkLineOfSight() then
                triggerJumpScare()
                return
            end
            task.wait(0.05)
        end
    end)
end

local function runFourPasses(route)
    local position = route[1]
    local waypointIndex = 2
    local travelDirection = route[2] - route[1]
    placeEntity(position, travelDirection)

    while session.Active and entity and entity.Parent and waypointIndex <= #route do
        local deltaTime = RunService.Heartbeat:Wait()
        local remainingTravel = MOVE_SPEED * math.min(math.max(deltaTime, 0), 0.1)

        while remainingTravel > 0 and waypointIndex <= #route do
            local difference = route[waypointIndex] - position
            local distance = difference.Magnitude
            if distance <= 0.001 then
                position = route[waypointIndex]
                waypointIndex = waypointIndex + 1
            elseif remainingTravel >= distance then
                travelDirection = difference.Unit
                position = route[waypointIndex]
                remainingTravel = remainingTravel - distance
                waypointIndex = waypointIndex + 1
            else
                travelDirection = difference.Unit
                position = position + travelDirection * remainingTravel
                remainingTravel = 0
            end
        end
        placeEntity(position, travelDirection)
    end
end

task.spawn(flashSkyBlueOnce)
initializeShaker()
shakeOnce(10, 3, 0.1, 6, 2, 0.5)

local points = getPathPositions()
if #points < 2 or not loadEntity() then
    stopSession()
    return
end

local route = buildFourPassRoute(points)
placeEntity(route[1], route[2] - route[1])
startHitAndShakeDetection()
runFourPasses(route)
stopSession()
end

function entityBehaviors.bsseek()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local target = Players:FindFirstChild("goat_qiu")
if not target then
	return
end

local walkAnimationId = "rbxassetid://7758895278"
local idleAnimationId = "rbxassetid://93784727849711"
local walkAnimationTrack = nil
local idleAnimationTrack = nil
local isMoving = false
local lastPosition = nil
local moveThreshold = 0.015

local function makePlayerTransparent(character)
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		elseif part:IsA("Decal") or part:IsA("Texture") then
			part.Transparency = 1
		end
	end
end

if target.Character then
	makePlayerTransparent(target.Character)
end

target.CharacterAdded:Connect(function(character)
	wait(0.5)
	makePlayerTransparent(character)
end)

local model = ReplicatedStorage:FindFirstChild("SeekRig")

if not model then
	local success, loadedModel = pcall(function()
		return game:GetObjects("rbxassetid://85799275308475")[1]
	end)
	
	if success and loadedModel then
		model = loadedModel
		model.Name = "SeekRig"
		model.Parent = ReplicatedStorage
	else
		return
	end
end

local mainSeekRig = model:Clone()
mainSeekRig.Parent = workspace

if not mainSeekRig.PrimaryPart then
	for _, part in pairs(mainSeekRig:GetDescendants()) do
		if part:IsA("BasePart") then
			mainSeekRig.PrimaryPart = part
			break
		end
	end
end

if not mainSeekRig.PrimaryPart then
	return
end

local function setupAnimationsInNestedSeekRig(parentModel)
	local innerSeekRig = parentModel:FindFirstChild("SeekRig")
	if not innerSeekRig or not innerSeekRig:IsA("Model") then
		return nil, nil
	end
	
	local animationController = innerSeekRig:FindFirstChildWhichIsA("AnimationController")
	if not animationController then
		return nil, nil
	end
	
	local animator = animationController:FindFirstChildWhichIsA("Animator")
	if not animator then
		return nil, nil
	end
	
	local walkAnimation = Instance.new("Animation")
	walkAnimation.AnimationId = walkAnimationId
	local idleAnimation = Instance.new("Animation")
	idleAnimation.AnimationId = idleAnimationId
	
	local walkSuccess, walkTrack = pcall(function()
		return animator:LoadAnimation(walkAnimation)
	end)
	
	local idleSuccess, idleTrack = pcall(function()
		return animator:LoadAnimation(idleAnimation)
	end)
	
	if walkSuccess and walkTrack then
		walkTrack.Looped = true
	else
		walkTrack = nil
	end
	
	if idleSuccess and idleTrack then
		idleTrack.Looped = true
	else
		idleTrack = nil
	end
	
	return walkTrack, idleTrack
end

walkAnimationTrack, idleAnimationTrack = setupAnimationsInNestedSeekRig(mainSeekRig)

local heightOffset = -0.7

RunService.Heartbeat:Connect(function()
	if not target or not target.Character then
		return
	end
	
	local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	
	local currentPosition = humanoidRootPart.Position
	if lastPosition then
		local distance = (currentPosition - lastPosition).Magnitude
		local nowMoving = distance > moveThreshold
		
		if nowMoving and not isMoving then
			isMoving = true
			if walkAnimationTrack then
				walkAnimationTrack:Play()
			end
			if idleAnimationTrack then
				idleAnimationTrack:Stop()
			end
		elseif not nowMoving and isMoving then
			isMoving = false
			if walkAnimationTrack then
				walkAnimationTrack:Stop()
			end
			if idleAnimationTrack then
				idleAnimationTrack:Play()
			end
		end
	end
	lastPosition = currentPosition
	
	local targetPosition = humanoidRootPart.Position
	local headPosition = targetPosition + Vector3.new(0, heightOffset, 0)
	local targetRotation = humanoidRootPart.CFrame.Rotation
	local newCFrame = CFrame.new(headPosition) * targetRotation * CFrame.Angles(-math.rad(20), 0, 0)
	
	if mainSeekRig.PrimaryPart then
		mainSeekRig:SetPrimaryPartCFrame(newCFrame)
	end
end)
end

local entityConfig = {
    ["rbxassetid://129108783729677"]  = entityBehaviors.TwoKane1, 
    ["rbxassetid://119672184905651"]  = entityBehaviors.Angler,
    ["rbxassetid://1845474773"]  = entityBehaviors.Z367Two2,  
    ["rbxassetid://101665501585468"]  = entityBehaviors.RipperSw,       
    ["rbxassetid://140510675673683"]  = entityBehaviors.GodEgg,           
    ["rbxassetid://94313092216761"]  = entityBehaviors.MLbody,        
    ["rbxassetid://152019307"]  = entityBehaviors.guidingjug,           
    ["rbxassetid://136073454817575"]  = entityBehaviors.A333ONE,
    ["rbxassetid://1845303150"]  = entityBehaviors.SCURE,
    ["rbxassetid://123091058956674"]  = entityBehaviors.MLTHREE,
    ["rbxassetid://9045341575"]  = entityBehaviors.JEFFTWO,
    ["rbxassetid://86930884029006"]  = entityBehaviors.HATRED,
    ["rbxassetid://103972512702681"]  = entityBehaviors.JEFFGUN,
    ["rbxassetid://126590329938074"]  = entityBehaviors.JEFFSTARY,       
    ["rbxassetid://83225089316779"]  = entityBehaviors.JEFFGUNST,
    ["rbxassetid://14093035297"]  = entityBehaviors.REBOUNDSW,
    ["rbxassetid://139660109011119"]  = entityBehaviors.DEBUGONE,
    ["rbxassetid://82747438998584"]  = entityBehaviors.SHOOPTWO,
    ["rbxassetid://100685649863483"]  = entityBehaviors.bswhoop,
    ["rbxassetid://139899811957414"]  = entityBehaviors.bsripper,
    ["rbxassetid://17663852143"]  = entityBehaviors.bsdeer,
    ["rbxassetid://103505137367929"]  = entityBehaviors.bsfigure,
    ["rbxassetid://128032522960947"]  = entityBehaviors.bsrebound,
    ["rbxassetid://3007484871"]  = entityBehaviors.bsseek,
    ["rbxassetid://80"]  = entityBehaviors.JEFFGUN2,
    ["rbxassetid://82"]  = entityBehaviors.JEFFGUN3,
    ["rbxassetid://81"]  = entityBehaviors.gunjeffkq,
    ["rbxassetid://83"]  = entityBehaviors.bsdeer2,
    ["rbxassetid://84"]  = entityBehaviors.GrimReaper,
    ["rbxassetid://103"]  = entityBehaviors.REBOUNDrebound,
    ["rbxassetid://9000"]  = entityBehaviors.MONTNS,
    ["rbxassetid://654"]  = entityBehaviors.DeergodFromthefront,
    ["rbxassetid://98465"]  = entityBehaviors.Silence22,
    ["rbxassetid://98464"]  = entityBehaviors.MOSCJ
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
hint.Text = "LoadingTwo... Doors HardCore V10.7.1 By HeavenNow & Number303 :)"
game.Debris:AddItem(hint, 2)
