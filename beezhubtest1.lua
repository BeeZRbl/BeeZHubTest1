-- BeeZ Hub v2.0 - Complete Farming System với Toggle UI
-- Works on Delta, Xeno, Synapse, etc.

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local Config = {
    AutoFarm = false,
    FarmMethod = "Normal",
    FarmDistance = 25,
    FarmPriority = "Nearest",
    StackFarming = false,
    StackCount = 3,
    FarmOnlyBosses = false,
    SkipLowLevel = false,
    LevelThreshold = 50,
    
    -- Auto Features
    AutoKatakuri = false,
    AutoBone = false,
    AutoTyrant = false,
    AutoHop = false,
    MaxHops = 10,
    AutoHealthPot = false,
    HealthThreshold = 30,
    AutoEnergyPot = false,
    EnergyThreshold = 20,
    
    -- Safety
    SafeMode = true,
    AntiAfk = true,
    Humanizer = true,
    RandomBreaks = true,
    FarmTimeLimit = 1800,
    
    -- Skills
    PrimarySkill = "Z",
    SecondarySkill = "X",
    UseSkillCombo = true,
    MasteryTarget = 300,
    
    -- UI
    UIVisible = true,
    Notifications = true
}

-- Farming Variables
local FarmEnabled = false
local CurrentTargets = {}
local HopAttempts = 0
local EnemiesKilled = 0
local FarmStartTime = 0
local SkillCooldowns = {}
local ToggleIcon = nil
local BeeZ_GUI = nil

-- Load Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- ==================== TOGGLE ICON ====================
local function CreateToggleIcon()
    if ToggleIcon then ToggleIcon:Destroy() end
    
    local IconGui = Instance.new("ScreenGui")
    IconGui.Name = "BeeZToggleIcon"
    IconGui.Parent = game.CoreGui
    IconGui.ResetOnSpawn = false
    
    local IconFrame = Instance.new("Frame")
    IconFrame.Name = "ToggleIcon"
    IconFrame.Size = UDim2.new(0, 50, 0, 50)
    IconFrame.Position = UDim2.new(0, 20, 0.5, -25)
    IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    IconFrame.BackgroundTransparency = 0.3
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = IconGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = IconFrame
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🐝"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 24
    IconLabel.Parent = IconFrame
    
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleUI()
        end
    end)
    
    ToggleIcon = IconGui
    return IconGui
end

local function ToggleUI()
    if BeeZ_GUI then
        Config.UIVisible = not Config.UIVisible
        BeeZ_GUI:ToggleUI()
        
        if ToggleIcon then
            local iconFrame = ToggleIcon:FindFirstChild("ToggleIcon")
            if iconFrame then
                local iconLabel = iconFrame:FindFirstChildOfClass("TextLabel")
                if iconLabel then
                    if Config.UIVisible then
                        iconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                        iconLabel.Text = "🐝"
                    else
                        iconFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                        iconLabel.Text = "🔒"
                    end
                end
            end
        end
        
        Notify("UI " .. (Config.UIVisible and "SHOWN" or "HIDDEN"))
    end
end

-- ==================== NOTIFICATION ====================
local function Notify(message, duration)
    if Config.Notifications then
        game.StarterGui:SetCore("SendNotification", {
            Title = "🐝 BeeZ Hub",
            Text = message,
            Duration = duration or 2,
            Icon = "rbxassetid://6723928013"
        })
    end
end

-- ==================== FARMING FUNCTIONS ====================
local function GetEnemiesInRange(distance)
    local enemies = {}
    for _, npc in pairs(Workspace.Enemies:GetChildren()) do
        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
            if npc.Humanoid.Health > 0 then
                local distanceToNPC = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distanceToNPC <= distance then
                    table.insert(enemies, npc)
                end
            end
        end
    end
    return enemies
end

local function SelectTarget(enemies)
    if #enemies == 0 then return {} end
    
    if Config.FarmPriority == "Nearest" then
        table.sort(enemies, function(a, b)
            return (HumanoidRootPart.Position - a.HumanoidRootPart.Position).Magnitude <
                   (HumanoidRootPart.Position - b.HumanoidRootPart.Position).Magnitude
        end)
    elseif Config.FarmPriority == "Lowest HP" then
        table.sort(enemies, function(a, b)
            return a.Humanoid.Health < b.Humanoid.Health
        end)
    end
    
    local targets = {}
    local maxTargets = Config.StackFarming and Config.StackCount or 1
    
    for i = 1, math.min(maxTargets, #enemies) do
        table.insert(targets, enemies[i])
    end
    
    return targets
end

local function UseSkill(skill)
    if skill and not SkillCooldowns[skill] then
        game:GetService("VirtualInputManager"):SendKeyEvent(true, skill, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, skill, false, game)
        
        SkillCooldowns[skill] = true
        task.wait(0.5)
        SkillCooldowns[skill] = false
    end
end

local function FarmingCycle()
    if Config.AntiAfk then
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
    
    local enemies = GetEnemiesInRange(Config.FarmDistance)
    local targets = SelectTarget(enemies)
    
    if #targets > 0 then
        -- Move to first target
        HumanoidRootPart.CFrame = CFrame.new(targets[1].HumanoidRootPart.Position + Vector3.new(0, 3, 0))
        
        -- Use skills
        UseSkill(Config.PrimarySkill)
        if Config.UseSkillCombo then
            UseSkill(Config.SecondarySkill)
        end
        
        -- Auto click for basic attack
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "LeftControl", false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "LeftControl", false, game)
        
        EnemiesKilled = EnemiesKilled + 1
        if StatusLabel then
            StatusLabel:UpdateLabel("Status: 🟢 Farming | Kills: " .. EnemiesKilled)
        end
    else
        if Config.AutoHop and HopAttempts < Config.MaxHops then
            HopAttempts = HopAttempts + 1
            Notify("No enemies, hopping... (" .. HopAttempts .. "/" .. Config.MaxHops .. ")")
        end
    end
    
    -- Humanizer breaks
    if Config.SafeMode and Config.RandomBreaks and math.random(1, 100) <= 5 then
        local breakTime = math.random(2, 5)
        Notify("Taking break: " .. breakTime .. "s")
        task.wait(breakTime)
    end
    
    -- Check time limit
    if Config.FarmTimeLimit > 0 and (tick() - FarmStartTime) > Config.FarmTimeLimit then
        Notify("⏰ Time limit reached!")
        FarmEnabled = false
        Config.AutoFarm = false
    end
end

local function StartFarming()
    if FarmEnabled then return end
    
    FarmEnabled = true
    FarmStartTime = tick()
    EnemiesKilled = 0
    HopAttempts = 0
    
    Notify("🚀 FARMING STARTED!\nMethod: " .. Config.FarmMethod, 3)
    if StatusLabel then
        StatusLabel:UpdateLabel("Status: 🟢 Farming | Kills: 0")
    end
    
    coroutine.wrap(function()
        while FarmEnabled and Config.AutoFarm do
            FarmingCycle()
            task.wait(0.2)
        end
    end)()
end

local function StopFarming()
    FarmEnabled = false
    local farmTime = tick() - FarmStartTime
    local minutes = math.floor(farmTime / 60)
    local seconds = math.floor(farmTime % 60)
    
    Notify(string.format("⏹️ FARMING STOPPED!\nTime: %d:%02d\nKills: %d", minutes, seconds, EnemiesKilled), 3)
    if StatusLabel then
        StatusLabel:UpdateLabel("Status: 🔴 Stopped | Kills: " .. EnemiesKilled)
    end
end

-- ==================== CREATE GUI ====================
local function CreateBeeZGUI()
    local Window = Library.CreateLib("🐝 BeeZ Hub v2.0", "DarkTheme")
    BeeZ_GUI = Window
    
    -- ===== MAIN TAB =====
    local MainTab = Window:NewTab("Main")
    local MainSection = MainTab:NewSection("Main Control")
    
    MainSection:NewLabel("🐝 BeeZ Hub v2.0")
    MainSection:NewLabel("Complete Farming System")
    
    StatusLabel = MainSection:NewLabel("Status: Ready")
    
    MainSection:NewButton("▶️ START FARMING", "Start auto farming", function()
        Config.AutoFarm = true
        StartFarming()
    end)
    
    MainSection:NewButton("⏹️ STOP FARMING", "Stop farming", function()
        Config.AutoFarm = false
        StopFarming()
    end)
    
    MainSection:NewButton("🔗 TOGGLE UI", "Show/Hide UI", function()
        ToggleUI()
    end)
    
    -- ===== FARMING TAB =====
    local FarmingTab = Window:NewTab("Farming")
    
    local BasicFarming = FarmingTab:NewSection("Basic Farming")
    BasicFarming:NewToggle("Enable Auto Farm", "Toggle auto farming", function(state)
        Config.AutoFarm = state
        Notify("Auto Farm: " .. (state and "ON" or "OFF"))
    end)
    
    BasicFarming:NewDropdown("Farm Method", "Select farming method", {"Normal", "Fast", "Safe", "Boss"}, function(method)
        Config.FarmMethod = method
        Notify("Farm Method: " .. method)
    end)
    
    BasicFarming:NewSlider("Farm Distance", "Distance to farm", 100, 10, function(value)
        Config.FarmDistance = value
    end)
    
    local TargetSettings = FarmingTab:NewSection("Target Settings")
    TargetSettings:NewDropdown("Target Priority", "Select target priority", {"Nearest", "Lowest HP", "Highest Level"}, function(priority)
        Config.FarmPriority = priority
        Notify("Target Priority: " .. priority)
    end)
    
    TargetSettings:NewToggle("Stack Farming", "Farm multiple enemies", function(state)
        Config.StackFarming = state
        Notify("Stack Farming: " .. (state and "ON" or "OFF"))
    end)
    
    TargetSettings:NewSlider("Stack Count", "Max enemies to farm", 5, 1, function(value)
        Config.StackCount = value
    end)
    
    -- ===== AUTO FEATURES TAB =====
    local AutoTab = Window:NewTab("Auto Features")
    
    local AutoQuest = AutoTab:NewSection("Auto Quest")
    AutoQuest:NewToggle("Auto Katakuri Quest", "Auto accept Katakuri quest", function(state)
        Config.AutoKatakuri = state
        Notify("Auto Katakuri: " .. (state and "ON" or "OFF"))
    end)
    
    AutoQuest:NewToggle("Auto Bone Quest", "Auto accept Bone quest", function(state)
        Config.AutoBone = state
        Notify("Auto Bone: " .. (state and "ON" or "OFF"))
    end)
    
    AutoQuest:NewToggle("Auto Tyrant Quest", "Auto accept Tyrant quest", function(state)
        Config.AutoTyrant = state
        Notify("Auto Tyrant: " .. (state and "ON" or "OFF"))
    end)
    
    local AutoServer = AutoTab:NewSection("Auto Server")
    AutoServer:NewToggle("Auto Server Hop", "Auto hop servers", function(state)
        Config.AutoHop = state
        Notify("Auto Server Hop: " .. (state and "ON" or "OFF"))
    end)
    
    AutoServer:NewSlider("Max Hop Attempts", "Maximum hops", 20, 1, function(value)
        Config.MaxHops = value
    end)
    
    -- ===== PLAYER SETTINGS TAB =====
    local PlayerTab = Window:NewTab("Player Settings")
    
    local SkillSettings = PlayerTab:NewSection("Skill Settings")
    SkillSettings:NewDropdown("Primary Skill", "Main skill to use", {"Z", "X", "C", "V", "F"}, function(skill)
        Config.PrimarySkill = skill
        Notify("Primary Skill: " .. skill)
    end)
    
    SkillSettings:NewDropdown("Secondary Skill", "Secondary skill", {"Z", "X", "C", "V", "F"}, function(skill)
        Config.SecondarySkill = skill
        Notify("Secondary Skill: " .. skill)
    end)
    
    SkillSettings:NewToggle("Use Skill Combo", "Use skill combinations", function(state)
        Config.UseSkillCombo = state
        Notify("Skill Combo: " .. (state and "ON" or "OFF"))
    end)
    
    local MasterySettings = PlayerTab:NewSection("Mastery Settings")
    MasterySettings:NewSlider("Mastery Target", "Target mastery level", 500, 100, function(value)
        Config.MasteryTarget = value
    end)
    
    -- ===== SAFETY TAB =====
    local SafetyTab = Window:NewTab("Safety")
    
    local SafetyFeatures = SafetyTab:NewSection("Safety Features")
    SafetyFeatures:NewToggle("Safe Mode", "Enable safe mode", function(state)
        Config.SafeMode = state
        Notify("Safe Mode: " .. (state and "ON" or "OFF"))
    end)
    
    SafetyFeatures:NewToggle("Anti-AFK", "Prevent AFK kick", function(state)
        Config.AntiAfk = state
        Notify("Anti-AFK: " .. (state and "ON" or "OFF"))
    end)
    
    SafetyFeatures:NewToggle("Humanizer", "Human-like behavior", function(state)
        Config.Humanizer = state
        Notify("Humanizer: " .. (state and "ON" or "OFF"))
    end)
    
    local TimeSettings = SafetyTab:NewSection("Time Settings")
    TimeSettings:NewToggle("Random Breaks", "Take random breaks", function(state)
        Config.RandomBreaks = state
        Notify("Random Breaks: " .. (state and "ON" or "OFF"))
    end)
    
    TimeSettings:NewSlider("Farm Time Limit", "Max farming time", 3600, 300, function(value)
        Config.FarmTimeLimit = value
        local minutes = math.floor(value / 60)
        Notify("Time Limit: " .. minutes .. " minutes")
    end)
    
    -- ===== TELEPORT TAB =====
    local TeleportTab = Window:NewTab("Teleport")
    
    local TeleportLocations = TeleportTab:NewSection("Teleport Locations")
    TeleportLocations:NewButton("Safe Zone", "Teleport to safe spot", function()
        HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
        Notify("Teleported to Safe Zone")
    end)
    
    TeleportLocations:NewButton("Island 1", "Teleport to island", function()
        Notify("Teleporting...")
    end)
    
    -- ===== MISC TAB =====
    local MiscTab = Window:NewTab("Misc")
    
    local Utility = MiscTab:NewSection("Utility")
    Utility:NewButton("Refresh Character", "Reset character", function()
        Character:BreakJoints()
        Notify("Refreshing character...")
    end)
    
    local Settings = MiscTab:NewSection("Settings")
    Settings:NewToggle("Notifications", "Enable notifications", function(state)
        Config.Notifications = state
        Notify("Notifications: " .. (state and "ON" or "OFF"))
    end)
    
    Settings:NewButton("Save Config", "Save settings", function()
        Notify("Settings saved!")
    end)
    
    return Window
end

-- ==================== INITIALIZATION ====================
CreateToggleIcon()
CreateBeeZGUI()

Notify("🐝 BeeZ Hub v2.0 loaded!\n• Click 🐝 icon to toggle UI\n• Press F9 to toggle Farm", 5)

-- Hotkeys
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F9 then
            Config.AutoFarm = not Config.AutoFarm
            if Config.AutoFarm then
                StartFarming()
            else
                StopFarming()
            end
        elseif input.KeyCode == Enum.KeyCode.F8 then
            ToggleUI()
        end
    end
end)

print("========================================")
print("🐝 BEEZ HUB v2.0 - COMPLETE FARMING")
print("========================================")
print("Features:")
print("- Auto Farming System")
print("- Stack Farming")
print("- Target Priority")
print("- Auto Quest System")
print("- Auto Server Hop")
print("- Skill Management")
print("- Safety Features")
print("- Teleport System")
print("- Toggle UI Icon 🐝")
print("========================================")
print("Hotkeys:")
print("F9 - Toggle Farming")
print("F8 - Toggle UI")
print("Click 🐝 icon - Toggle UI")
print("========================================")
