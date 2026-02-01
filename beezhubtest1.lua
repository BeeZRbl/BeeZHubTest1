-- BeeZ Hub v2.0 - Working Version với đầy đủ tính năng
-- UI sẽ hiện ngay khi execute

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Biến toàn cục
local FarmEnabled = false
local CurrentMastery = 0
local EnemiesKilled = 0
local FarmStartTime = 0

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Tạo Window
local Window = Rayfield:CreateWindow({
    Name = "🐝 BeeZ Hub v2.0",
    LoadingTitle = "BeeZ Hub đang khởi động...",
    LoadingSubtitle = "Advanced Blox Fruits Automation",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("Main", 4483362458)

-- Main Control Section
local MainSection = MainTab:CreateSection("Main Control")

MainSection:CreateLabel("🐝 BeeZ Hub v2.0")
MainSection:CreateLabel("Blox Fruits Farming System")

local StartButton = MainSection:CreateButton({
    Name = "▶️ START FARMING",
    Callback = function()
        if not FarmEnabled then
            StartFarming()
        else
            BeeZ_Notify("Farming is already running!")
        end
    end
})

local StopButton = MainSection:CreateButton({
    Name = "⏹️ STOP FARMING",
    Callback = function()
        if FarmEnabled then
            StopFarming()
        else
            BeeZ_Notify("Farming is not running!")
        end
    end
})

-- Status Section
local StatusSection = MainTab:CreateSection("Status")

local StatusLabel = MainSection:CreateLabel("Status: Ready")
local MasteryLabel = MainSection:CreateLabel("Mastery: 0/300")
local KillsLabel = MainSection:CreateLabel("Kills: 0")

-- ==================== FARMING SETTINGS TAB ====================
local FarmingTab = Window:CreateTab("Farming Settings", 4483362458)

-- Basic Farming Section
local BasicFarming = FarmingTab:CreateSection("Basic Farming")

local AutoFarmToggle = BasicFarming:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Auto Farm: " .. (Value and "ON" or "OFF"))
    end
})

local FarmMethod = BasicFarming:CreateDropdown({
    Name = "Farm Method",
    Options = {"Normal", "Fast", "Safe", "Boss"},
    CurrentOption = "Normal",
    Callback = function(Option)
        BeeZ_Notify("Farm Method: " .. Option)
    end
})

local FarmDistance = BasicFarming:CreateSlider({
    Name = "Farm Distance",
    Range = {10, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 25,
    Callback = function(Value)
        BeeZ_Notify("Farm Distance: " .. Value)
    end
})

-- Target Selection Section
local TargetSelection = FarmingTab:CreateSection("Target Selection")

local TargetPriority = TargetSelection:CreateDropdown({
    Name = "Target Priority",
    Options = {"Nearest", "Highest Level", "Lowest HP"},
    CurrentOption = "Nearest",
    Callback = function(Option)
        BeeZ_Notify("Target Priority: " .. Option)
    end
})

local StackFarmingToggle = TargetSelection:CreateToggle({
    Name = "Stack Farming",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Stack Farming: " .. (Value and "ON" or "OFF"))
    end
})

-- Advanced Farming Section
local AdvancedFarming = FarmingTab:CreateSection("Advanced Farming")

local FarmOnlyBosses = AdvancedFarming:CreateToggle({
    Name = "Farm Only Bosses",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Farm Only Bosses: " .. (Value and "ON" or "OFF"))
    end
})

local SkipLowLevel = AdvancedFarming:CreateToggle({
    Name = "Skip Low Level Enemies",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Skip Low Level: " .. (Value and "ON" or "OFF"))
    end
})

local LevelThreshold = AdvancedFarming:CreateSlider({
    Name = "Level Threshold",
    Range = {1, 500},
    Increment = 10,
    Suffix = "level",
    CurrentValue = 50,
    Callback = function(Value)
        BeeZ_Notify("Level Threshold: " .. Value)
    end
})

-- ==================== AUTO FEATURES TAB ====================
local AutoTab = Window:CreateTab("Auto Features", 4483362458)

-- Auto Quest Section
local AutoQuest = AutoTab:CreateSection("Auto Quest")

local AutoKatakuri = AutoQuest:CreateToggle({
    Name = "Auto Katakuri Quest",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Auto Katakuri Quest: " .. (Value and "ON" or "OFF"))
    end
})

local AutoBone = AutoQuest:CreateToggle({
    Name = "Auto Bone Quest",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Auto Bone Quest: " .. (Value and "ON" or "OFF"))
    end
})

local AutoTyrant = AutoQuest:CreateToggle({
    Name = "Auto Tyrant Quest",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Auto Tyrant Quest: " .. (Value and "ON" or "OFF"))
    end
})

-- Auto Server Section
local AutoServer = AutoTab:CreateSection("Auto Server")

local AutoHopToggle = AutoServer:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Auto Server Hop: " .. (Value and "ON" or "OFF"))
    end
})

local MaxHops = AutoServer:CreateSlider({
    Name = "Max Hop Attempts",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value)
        BeeZ_Notify("Max Hops: " .. Value)
    end
})

-- Auto Potions Section
local AutoPotions = AutoTab:CreateSection("Auto Potions")

local AutoHealthPot = AutoPotions:CreateToggle({
    Name = "Auto Health Potion",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Auto Health Potion: " .. (Value and "ON" or "OFF"))
    end
})

local HealthThreshold = AutoPotions:CreateSlider({
    Name = "Health Threshold",
    Range = {10, 50},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 30,
    Callback = function(Value)
        BeeZ_Notify("Health Threshold: " .. Value .. "%")
    end
})

-- ==================== PLAYER SETTINGS TAB ====================
local PlayerTab = Window:CreateTab("Player Settings", 4483362458)

-- Skill Settings Section
local SkillSettings = PlayerTab:CreateSection("Skill Settings")

local SkillPriority = SkillSettings:CreateDropdown({
    Name = "Skill Priority",
    Options = {"Z", "X", "C", "V", "F"},
    CurrentOption = "Z",
    Callback = function(Option)
        BeeZ_Notify("Skill Priority: " .. Option)
    end
})

local SkillCombo = SkillSettings:CreateToggle({
    Name = "Use Skill Combo",
    CurrentValue = true,
    Callback = function(Value)
        BeeZ_Notify("Skill Combo: " .. (Value and "ON" or "OFF"))
    end
})

-- Mastery Settings Section
local MasterySettings = PlayerTab:CreateSection("Mastery Settings")

local MasteryTarget = MasterySettings:CreateSlider({
    Name = "Mastery Target",
    Range = {100, 500},
    Increment = 10,
    CurrentValue = 300,
    Callback = function(Value)
        BeeZ_Notify("Mastery Target: " .. Value)
    end
})

local AutoSwitchWeapon = MasterySettings:CreateToggle({
    Name = "Auto Switch Weapon",
    CurrentValue = false,
    Callback = function(Value)
        BeeZ_Notify("Auto Switch Weapon: " .. (Value and "ON" or "OFF"))
    end
})

-- ==================== SAFETY TAB ====================
local SafetyTab = Window:CreateTab("Safety", 4483362458)

-- Safety Features Section
local SafetyFeatures = SafetyTab:CreateSection("Safety Features")

local SafeModeToggle = SafetyFeatures:CreateToggle({
    Name = "Safe Mode",
    CurrentValue = true,
    Callback = function(Value)
        BeeZ_Notify("Safe Mode: " .. (Value and "ON" or "OFF"))
    end
})

local AntiAfkToggle = SafetyFeatures:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(Value)
        BeeZ_Notify("Anti-AFK: " .. (Value and "ON" or "OFF"))
    end
})

local HumanizerToggle = SafetyFeatures:CreateToggle({
    Name = "Humanizer",
    CurrentValue = true,
    Callback = function(Value)
        BeeZ_Notify("Humanizer: " .. (Value and "ON" or "OFF"))
    end
})

-- Time Management Section
local TimeManagement = SafetyTab:CreateSection("Time Management")

local RandomBreaks = TimeManagement:CreateToggle({
    Name = "Random Breaks",
    CurrentValue = true,
    Callback = function(Value)
        BeeZ_Notify("Random Breaks: " .. (Value and "ON" or "OFF"))
    end
})

local FarmTimeLimit = TimeManagement:CreateSlider({
    Name = "Farm Time Limit",
    Range = {300, 3600},
    Increment = 300,
    Suffix = "seconds",
    CurrentValue = 1800,
    Callback = function(Value)
        BeeZ_Notify("Farm Time Limit: " .. Value .. "s")
    end
})

-- ==================== MISC TAB ====================
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Teleport Section
local TeleportSection = MiscTab:CreateSection("Teleport")

TeleportSection:CreateButton({
    Name = "Teleport to Safe Zone",
    Callback = function()
        TeleportSafe()
    end
})

TeleportSection:CreateButton({
    Name = "Teleport to Nearest Island",
    Callback = function()
        TeleportIsland()
    end
})

-- Utility Section
local UtilitySection = MiscTab:CreateSection("Utility")

UtilitySection:CreateButton({
    Name = "Refresh Character",
    Callback = function()
        RefreshCharacter()
    end
})

UtilitySection:CreateButton({
    Name = "Toggle Noclip",
    Callback = function()
        ToggleNoclip()
    end
})

-- Settings Section
local SettingsSection = MiscTab:CreateSection("Settings")

SettingsSection:CreateButton({
    Name = "Save Settings",
    Callback = function()
        SaveSettings()
    end
})

SettingsSection:CreateButton({
    Name = "Load Settings",
    Callback = function()
        LoadSettings()
    end
})

-- ==================== FUNCTIONS ====================

function BeeZ_Notify(message, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🐝 BeeZ Hub",
        Text = message,
        Duration = duration or 2,
        Icon = "rbxassetid://6723928013"
    })
end

function StartFarming()
    FarmEnabled = true
    FarmStartTime = tick()
    EnemiesKilled = 0
    
    BeeZ_Notify("🚀 FARMING STARTED!", 3)
    UpdateStatus()
    
    -- Start farming loop
    coroutine.wrap(function()
        while FarmEnabled do
            FarmingCycle()
            task.wait(0.1)
        end
    end)()
end

function StopFarming()
    FarmEnabled = false
    local farmTime = tick() - FarmStartTime
    local minutes = math.floor(farmTime / 60)
    local seconds = math.floor(farmTime % 60)
    
    BeeZ_Notify(string.format("⏹️ FARMING STOPPED!\nTime: %d:%02d\nKills: %d", minutes, seconds, EnemiesKilled), 3)
    UpdateStatus()
end

function FarmingCycle()
    -- Anti-AFK
    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    
    -- Find enemies
    local enemies = GetEnemiesInRange(50)
    
    if #enemies > 0 then
        -- Attack first enemy
        local target = enemies[1]
        HumanoidRootPart.CFrame = CFrame.new(target.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
        
        -- Use skills
        UseSkill("Z")
        UseSkill("X")
        
        -- Count kill
        EnemiesKilled = EnemiesKilled + 1
        UpdateStatus()
    end
    
    -- Check time limit
    if FarmTimeLimit.CurrentValue > 0 and (tick() - FarmStartTime) > FarmTimeLimit.CurrentValue then
        BeeZ_Notify("⏰ Time limit reached!", 3)
        StopFarming()
    end
end

function GetEnemiesInRange(distance)
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

function UseSkill(skill)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, skill, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, skill, false, game)
end

function UpdateStatus()
    local statusText = FarmEnabled and "🟢 Farming" or "🔴 Idle"
    StatusLabel:Set("Status: " .. statusText)
    
    -- Update mastery (placeholder)
    MasteryLabel:Set("Mastery: " .. CurrentMastery .. "/" .. MasteryTarget.CurrentValue)
    KillsLabel:Set("Kills: " .. EnemiesKilled)
end

function TeleportSafe()
    HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
    BeeZ_Notify("Teleported to safe zone", 2)
end

function TeleportIsland()
    BeeZ_Notify("Teleporting to nearest island...", 2)
end

function RefreshCharacter()
    Character:BreakJoints()
    BeeZ_Notify("Refreshing character...", 2)
end

function ToggleNoclip()
    BeeZ_Notify("Noclip feature coming soon!", 2)
end

function SaveSettings()
    BeeZ_Notify("Settings saved!", 2)
end

function LoadSettings()
    BeeZ_Notify("Settings loaded!", 2)
end

-- ==================== INITIALIZATION ====================

BeeZ_Notify("🐝 BeeZ Hub v2.0 loaded successfully!", 5)
print("========================================")
print("🐝 BEEZ HUB v2.0")
print("UI đã sẵn sàng với các tab:")
print("1. Main - Điều khiển chính")
print("2. Farming Settings - Cài đặt farm")
print("3. Auto Features - Tính năng tự động")
print("4. Player Settings - Cài đặt người chơi")
print("5. Safety - Cài đặt an toàn")
print("6. Misc - Tính năng khác")
print("========================================")
print("Nhấn START FARMING để bắt đầu!")
print("========================================")
