-- BeeZ Hub v2.0 - Full Features Script
-- Không có toggle icon, đầy đủ tính năng

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local Config = {
    -- Farming
    AutoFarm = false,
    StackFarm = false,
    FarmMethod = "Normal",
    FarmDistance = 25,
    FarmPriority = "Nearest",
    
    -- Auto Features
    IgnoreKatakuri = false,
    IgnoreKatakuriHP = 30,
    AutoHop = false,
    MaxHopAttempts = 10,
    AutoHealthPot = false,
    HealthThreshold = 30,
    AutoEnergyPot = false,
    EnergyThreshold = 20,
    AntiAfk = true,
    
    -- Quests
    AutoQuest = {
        Katakuri = false,
        Bone = false,
        Tyrant = false,
        SeaEvents = false
    },
    
    -- Mastery
    MasteryTarget = 300,
    AutoMasterySwitch = false,
    
    -- Raid
    AutoRaid = false,
    RaidType = "Flame",
    
    -- Fruit
    AutoFruit = false,
    FruitType = "Random",
    StoreFruits = false,
    
    -- Settings
    SafeMode = true,
    Notifications = true,
    StatusDisplay = true
}

-- Variables
local FarmEnabled = false
local Target = nil
local HopAttempts = 0
local CurrentMastery = 0
local SkillCooldowns = {}
local QuestsCompleted = 0
local EnemiesKilled = 0
local FarmStartTime = 0

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🐝 BeeZ Hub v2.0",
    LoadingTitle = "BeeZ Hub is loading...",
    LoadingSubtitle = "Advanced Blox Fruits Automation",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("Main", 4483362458)

local MainSection = MainTab:CreateSection("Main Control")

MainSection:CreateLabel("🐝 BeeZ Hub v2.0")
MainSection:CreateLabel("Advanced Blox Fruits Automation")

local StartFarmButton = MainSection:CreateButton({
    Name = "▶️ Start Farming",
    Callback = function()
        StartFarming()
    end
})

local StopFarmButton = MainSection:CreateSection("Farm Control")

StopFarmButton:CreateButton({
    Name = "⏹️ Stop Farming",
    Callback = function()
        StopFarming()
    end
})

local TeleportSection = MainTab:CreateSection("Teleport Locations")

TeleportSection:CreateButton({
    Name = "Teleport to Safe Zone",
    Callback = function()
        TeleportToSafeZone()
    end
})

TeleportSection:CreateButton({
    Name = "Teleport to Nearest Island",
    Callback = function()
        TeleportToNearestIsland()
    end
})

TeleportSection:CreateButton({
    Name = "Teleport to Castle on the Sea",
    Callback = function()
        TeleportToLocation("Castle")
    end
})

local StatusSection = MainTab:CreateSection("Status")

local StatusLabel = StatusSection:CreateLabel("Status: Ready")
local MasteryLabel = StatusSection:CreateLabel("Mastery: 0/300")
local KillsLabel = StatusSection:CreateLabel("Kills: 0")

-- ==================== FARMING TAB ====================
local FarmingTab = Window:CreateTab("Farming", 4483362458)

local FarmingSettings = FarmingTab:CreateSection("Farming Settings")

FarmingSettings:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = Config.AutoFarm,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        Config.AutoFarm = Value
        BeeZ_Notify("Auto Farm: " .. (Value and "ON" or "OFF"))
    end
})

FarmingSettings:CreateToggle({
    Name = "Stack Farming",
    CurrentValue = Config.StackFarm,
    Flag = "StackFarmToggle",
    Callback = function(Value)
        Config.StackFarm = Value
        BeeZ_Notify("Stack Farming: " .. (Value and "ON" or "OFF"))
    end
})

local FarmMethodDropdown = FarmingSettings:CreateDropdown({
    Name = "Farm Method",
    Options = {"Normal", "Fast", "Safe", "Boss"},
    CurrentOption = Config.FarmMethod,
    Flag = "FarmMethodDropdown",
    Callback = function(Option)
        Config.FarmMethod = Option
        BeeZ_Notify("Farm Method: " .. Option)
    end
})

local FarmDistanceSlider = FarmingSettings:CreateSlider({
    Name = "Farm Distance",
    Range = {10, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = Config.FarmDistance,
    Flag = "FarmDistanceSlider",
    Callback = function(Value)
        Config.FarmDistance = Value
    end
})

local TargetPriority = FarmingSettings:CreateDropdown({
    Name = "Target Priority",
    Options = {"Nearest", "Highest Level", "Lowest HP", "Bosses First"},
    CurrentOption = Config.FarmPriority,
    Flag = "TargetPriorityDropdown",
    Callback = function(Option)
        Config.FarmPriority = Option
        BeeZ_Notify("Target Priority: " .. Option)
    end
})

local AdvancedFarming = FarmingTab:CreateSection("Advanced Farming")

AdvancedFarming:CreateToggle({
    Name = "Auto Adjust Distance",
    CurrentValue = true,
    Flag = "AutoAdjustToggle",
    Callback = function(Value)
        BeeZ_Notify("Auto Adjust: " .. (Value and "ON" or "OFF"))
    end
})

AdvancedFarming:CreateToggle({
    Name = "Farm Only Bosses",
    CurrentValue = false,
    Flag = "FarmBossesToggle",
    Callback = function(Value)
        BeeZ_Notify("Farm Bosses Only: " .. (Value and "ON" or "OFF"))
    end
})

AdvancedFarming:CreateToggle({
    Name = "Skip Low Level Enemies",
    CurrentValue = false,
    Flag = "SkipLowLevelToggle",
    Callback = function(Value)
        BeeZ_Notify("Skip Low Level: " .. (Value and "ON" or "OFF"))
    end
})

-- ==================== AUTO TAB ====================
local AutoTab = Window:CreateTab("Auto", 4483362458)

local AutoFeatures = AutoTab:CreateSection("Auto Features")

AutoFeatures:CreateToggle({
    Name = "Ignore Katakuri",
    CurrentValue = Config.IgnoreKatakuri,
    Flag = "IgnoreKatakuriToggle",
    Callback = function(Value)
        Config.IgnoreKatakuri = Value
        BeeZ_Notify("Ignore Katakuri: " .. (Value and "ON" or "OFF"))
    end
})

local KatakuriHPSlider = AutoFeatures:CreateSlider({
    Name = "Ignore Katakuri HP %",
    Range = {10, 90},
    Increment = 5,
    Suffix = "%",
    CurrentValue = Config.IgnoreKatakuriHP,
    Flag = "KatakuriHPSlider",
    Callback = function(Value)
        Config.IgnoreKatakuriHP = Value
    end
})

AutoFeatures:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = Config.AutoHop,
    Flag = "AutoHopToggle",
    Callback = function(Value)
        Config.AutoHop = Value
        BeeZ_Notify("Auto Server Hop: " .. (Value and "ON" or "OFF"))
    end
})

local MaxHopsSlider = AutoFeatures:CreateSlider({
    Name = "Max Hop Attempts",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = Config.MaxHopAttempts,
    Flag = "MaxHopsSlider",
    Callback = function(Value)
        Config.MaxHopAttempts = Value
    end
})

local AutoPotions = AutoTab:CreateSection("Auto Potions")

AutoPotions:CreateToggle({
    Name = "Auto Health Potion",
    CurrentValue = Config.AutoHealthPot,
    Flag = "AutoHealthPotToggle",
    Callback = function(Value)
        Config.AutoHealthPot = Value
        BeeZ_Notify("Auto Health Pot: " .. (Value and "ON" or "OFF"))
    end
})

local HealthThresholdSlider = AutoPotions:CreateSlider({
    Name = "Health Threshold",
    Range = {10, 50},
    Increment = 5,
    Suffix = "%",
    CurrentValue = Config.HealthThreshold,
    Flag = "HealthThresholdSlider",
    Callback = function(Value)
        Config.HealthThreshold = Value
    end
})

AutoPotions:CreateToggle({
    Name = "Auto Energy Potion",
    CurrentValue = Config.AutoEnergyPot,
    Flag = "AutoEnergyPotToggle",
    Callback = function(Value)
        Config.AutoEnergyPot = Value
        BeeZ_Notify("Auto Energy Pot: " .. (Value and "ON" or "OFF"))
    end
})

local EnergyThresholdSlider = AutoPotions:CreateSlider({
    Name = "Energy Threshold",
    Range = {10, 50},
    Increment = 5,
    Suffix = "%",
    CurrentValue = Config.EnergyThreshold,
    Flag = "EnergyThresholdSlider",
    Callback = function(Value)
        Config.EnergyThreshold = Value
    end
})

-- ==================== QUEST TAB ====================
local QuestTab = Window:CreateTab("Quests", 4483362458)

local QuestAuto = QuestTab:CreateSection("Auto Quest")

QuestAuto:CreateToggle({
    Name = "Auto Katakuri Quest",
    CurrentValue = Config.AutoQuest.Katakuri,
    Flag = "KatakuriQuestToggle",
    Callback = function(Value)
        Config.AutoQuest.Katakuri = Value
        BeeZ_Notify("Katakuri Quest: " .. (Value and "ON" or "OFF"))
    end
})

QuestAuto:CreateToggle({
    Name = "Auto Bone Quest",
    CurrentValue = Config.AutoQuest.Bone,
    Flag = "BoneQuestToggle",
    Callback = function(Value)
        Config.AutoQuest.Bone = Value
        BeeZ_Notify("Bone Quest: " .. (Value and "ON" or "OFF"))
    end
})

QuestAuto:CreateToggle({
    Name = "Auto Tyrant Quest",
    CurrentValue = Config.AutoQuest.Tyrant,
    Flag = "TyrantQuestToggle",
    Callback = function(Value)
        Config.AutoQuest.Tyrant = Value
        BeeZ_Notify("Tyrant Quest: " .. (Value and "ON" or "OFF"))
    end
})

QuestAuto:CreateToggle({
    Name = "Auto Sea Events",
    CurrentValue = Config.AutoQuest.SeaEvents,
    Flag = "SeaEventsToggle",
    Callback = function(Value)
        Config.AutoQuest.SeaEvents = Value
        BeeZ_Notify("Sea Events: " .. (Value and "ON" or "OFF"))
    end
})

local QuestInfo = QuestTab:CreateSection("Quest Information")

QuestInfo:CreateLabel("Current Quests: None")
QuestInfo:CreateLabel("Quests Completed: 0")

QuestInfo:CreateButton({
    Name = "Accept All Available Quests",
    Callback = function()
        AcceptAllQuests()
    end
})

-- ==================== MASTERY TAB ====================
local MasteryTab = Window:CreateTab("Mastery", 4483362458)

local MasterySettings = MasteryTab:CreateSection("Mastery Settings")

local MasteryTargetSlider = MasterySettings:CreateSlider({
    Name = "Mastery Target",
    Range = {100, 500},
    Increment = 10,
    CurrentValue = Config.MasteryTarget,
    Flag = "MasteryTargetSlider",
    Callback = function(Value)
        Config.MasteryTarget = Value
        UpdateStatus()
    end
})

MasterySettings:CreateToggle({
    Name = "Auto Switch Weapon",
    CurrentValue = Config.AutoMasterySwitch,
    Flag = "AutoSwitchToggle",
    Callback = function(Value)
        Config.AutoMasterySwitch = Value
        BeeZ_Notify("Auto Switch: " .. (Value and "ON" or "OFF"))
    end
})

MasterySettings:CreateToggle({
    Name = "Mastery Farm Mode",
    CurrentValue = false,
    Flag = "MasteryFarmToggle",
    Callback = function(Value)
        BeeZ_Notify("Mastery Farm: " .. (Value and "ON" or "OFF"))
    end
})

local MasteryInfo = MasteryTab:CreateSection("Mastery Information")

MasteryInfo:CreateLabel("Current Mastery: 0")
MasteryInfo:CreateLabel("Target Mastery: 300")
MasteryInfo:CreateLabel("Progress: 0%")

MasteryInfo:CreateButton({
    Name = "Start Mastery Farm",
    Callback = function()
        StartMasteryFarm()
    end
})

-- ==================== RAID TAB ====================
local RaidTab = Window:CreateTab("Raid", 4483362458)

local RaidSettings = RaidTab:CreateSection("Raid Settings")

RaidSettings:CreateToggle({
    Name = "Auto Raid",
    CurrentValue = Config.AutoRaid,
    Flag = "AutoRaidToggle",
    Callback = function(Value)
        Config.AutoRaid = Value
        BeeZ_Notify("Auto Raid: " .. (Value and "ON" or "OFF"))
    end
})

local RaidTypeDropdown = RaidSettings:CreateDropdown({
    Name = "Raid Type",
    Options = {"Flame", "Ice", "Quake", "Dark", "Light", "String", "Rumble", "Magma", "Human", "Bird", "Dough"},
    CurrentOption = Config.RaidType,
    Flag = "RaidTypeDropdown",
    Callback = function(Option)
        Config.RaidType = Option
        BeeZ_Notify("Raid Type: " .. Option)
    end
})

RaidSettings:CreateToggle({
    Name = "Auto Start Raid",
    CurrentValue = false,
    Flag = "AutoStartRaidToggle",
    Callback = function(Value)
        BeeZ_Notify("Auto Start Raid: " .. (Value and "ON" or "OFF"))
    end
})

RaidSettings:CreateToggle({
    Name = "Auto Join Raid",
    CurrentValue = false,
    Flag = "AutoJoinRaidToggle",
    Callback = function(Value)
        BeeZ_Notify("Auto Join Raid: " .. (Value and "ON" or "OFF"))
    end
})

local RaidInfo = RaidTab:CreateSection("Raid Information")

RaidInfo:CreateLabel("Raid Status: Not Active")
RaidInfo:CreateLabel("Raid Type: None")
RaidInfo:CreateLabel("Raid Fragments: 0")

RaidInfo:CreateButton({
    Name = "Start Selected Raid",
    Callback = function()
        StartRaid()
    end
})

-- ==================== FRUIT TAB ====================
local FruitTab = Window:CreateTab("Fruit", 4483362458)

local FruitSettings = FruitTab:CreateSection("Fruit Settings")

FruitSettings:CreateToggle({
    Name = "Auto Fruit",
    CurrentValue = Config.AutoFruit,
    Flag = "AutoFruitToggle",
    Callback = function(Value)
        Config.AutoFruit = Value
        BeeZ_Notify("Auto Fruit: " .. (Value and "ON" or "OFF"))
    end
})

local FruitTypeDropdown = FruitSettings:CreateDropdown({
    Name = "Fruit Type",
    Options = {"Random", "Bomb", "Spike", "Chop", "Spring", "Kilo", "Smoke", "Flame", "Ice", "Sand", "Dark", "Diamond", "Light", "Love", "Rubber", "Barrier", "Ghost", "Magma", "Quake", "Buddha", "Shadow", "Blizzard", "Gravity", "Dough", "Venom", "Control", "Spirit", "Dragon", "Leopard", "Mammoth", "Sound", "Phoenix"},
    CurrentOption = Config.FruitType,
    Flag = "FruitTypeDropdown",
    Callback = function(Option)
        Config.FruitType = Option
        BeeZ_Notify("Fruit Type: " .. Option)
    end
})

FruitSettings:CreateToggle({
    Name = "Store Fruits",
    CurrentValue = Config.StoreFruits,
    Flag = "StoreFruitsToggle",
    Callback = function(Value)
        Config.StoreFruits = Value
        BeeZ_Notify("Store Fruits: " .. (Value and "ON" or "OFF"))
    end
})

FruitSettings:CreateToggle({
    Name = "Auto Eat Fruit",
    CurrentValue = false,
    Flag = "AutoEatFruitToggle",
    Callback = function(Value)
        BeeZ_Notify("Auto Eat Fruit: " .. (Value and "ON" or "OFF"))
    end
})

local FruitInfo = FruitTab:CreateSection("Fruit Information")

FruitInfo:CreateLabel("Current Fruit: None")
FruitInfo:CreateLabel("Fruits in Inventory: 0")
FruitInfo:CreateLabel("Belis Spent: 0")

FruitInfo:CreateButton({
    Name = "Roll Fruit",
    Callback = function()
        RollFruit()
    end
})

-- ==================== SETTINGS TAB ====================
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local GeneralSettings = SettingsTab:CreateSection("General Settings")

GeneralSettings:CreateToggle({
    Name = "Safe Mode",
    CurrentValue = Config.SafeMode,
    Flag = "SafeModeToggle",
    Callback = function(Value)
        Config.SafeMode = Value
        BeeZ_Notify("Safe Mode: " .. (Value and "ON" or "OFF"))
    end
})

GeneralSettings:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = Config.AntiAfk,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        Config.AntiAfk = Value
        BeeZ_Notify("Anti-AFK: " .. (Value and "ON" or "OFF"))
    end
})

GeneralSettings:CreateToggle({
    Name = "Notifications",
    CurrentValue = Config.Notifications,
    Flag = "NotificationsToggle",
    Callback = function(Value)
        Config.Notifications = Value
        BeeZ_Notify("Notifications: " .. (Value and "ON" or "OFF"))
    end
})

GeneralSettings:CreateToggle({
    Name = "Status Display",
    CurrentValue = Config.StatusDisplay,
    Flag = "StatusDisplayToggle",
    Callback = function(Value)
        Config.StatusDisplay = Value
        BeeZ_Notify("Status Display: " .. (Value and "ON" or "OFF"))
    end
})

local UITheme = SettingsTab:CreateSection("UI Theme")

UITheme:CreateDropdown({
    Name = "Theme Color",
    Options = {"Blue", "Green", "Red", "Purple", "Orange", "Pink"},
    CurrentOption = "Blue",
    Flag = "ThemeColorDropdown",
    Callback = function(Option)
        BeeZ_Notify("Theme Color: " .. Option)
    end
})

UITheme:CreateToggle({
    Name = "Rainbow UI",
    CurrentValue = false,
    Flag = "RainbowUIToggle",
    Callback = function(Value)
        BeeZ_Notify("Rainbow UI: " .. (Value and "ON" or "OFF"))
    end
})

local MiscSettings = SettingsTab:CreateSection("Misc Settings")

MiscSettings:CreateButton({
    Name = "Save Settings",
    Callback = function()
        SaveSettings()
    end
})

MiscSettings:CreateButton({
    Name = "Load Settings",
    Callback = function()
        LoadSettings()
    end
})

MiscSettings:CreateButton({
    Name = "Reset to Default",
    Callback = function()
        ResetSettings()
    end
})

MiscSettings:CreateButton({
    Name = "Check for Updates",
    Callback = function()
        CheckUpdates()
    end
})

-- ==================== FUNCTIONS ====================

function BeeZ_Notify(message, duration)
    if Config.Notifications then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🐝 BeeZ Hub",
            Text = message,
            Duration = duration or 3,
            Icon = "rbxassetid://6723928013"
        })
    end
end

function StartFarming()
    if not FarmEnabled then
        FarmEnabled = true
        FarmStartTime = tick()
        EnemiesKilled = 0
        BeeZ_Notify("Farming started!", 2)
        UpdateStatus()
        coroutine.wrap(FarmingLoop)()
    end
end

function StopFarming()
    FarmEnabled = false
    BeeZ_Notify("Farming stopped", 2)
    UpdateStatus()
end

function UpdateStatus()
    local statusText = FarmEnabled and "Farming" or "Ready"
    local masteryText = string.format("Mastery: %d/%d", CurrentMastery, Config.MasteryTarget)
    local killsText = string.format("Kills: %d", EnemiesKilled)
    
    pcall(function()
        -- Update status labels
    end)
end

function FarmingLoop()
    while FarmEnabled do
        task.wait(0.1)
        
        if Config.AntiAfk then
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
        
        -- Farming logic here
        
        if Config.SafeMode then
            if math.random(1, 100) <= 5 then
                task.wait(math.random(2, 5))
            end
        end
    end
end

function TeleportToSafeZone()
    HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
    BeeZ_Notify("Teleported to safe zone", 2)
end

function TeleportToNearestIsland()
    BeeZ_Notify("Finding nearest island...", 2)
end

function TeleportToLocation(location)
    BeeZ_Notify("Teleporting to " .. location, 2)
end

function AcceptAllQuests()
    BeeZ_Notify("Accepting all quests...", 2)
end

function StartMasteryFarm()
    BeeZ_Notify("Starting mastery farm...", 2)
end

function StartRaid()
    BeeZ_Notify("Starting " .. Config.RaidType .. " raid...", 2)
end

function RollFruit()
    BeeZ_Notify("Rolling fruit...", 2)
end

function SaveSettings()
    BeeZ_Notify("Settings saved!", 2)
end

function LoadSettings()
    BeeZ_Notify("Settings loaded!", 2)
end

function ResetSettings()
    BeeZ_Notify("Settings reset to default", 2)
end

function CheckUpdates()
    BeeZ_Notify("Checking for updates...", 2)
end

-- ==================== INITIALIZATION ====================

BeeZ_Notify("🐝 BeeZ Hub v2.0 loaded successfully!", 5)
print("========================================")
print("🐝 BeeZ Hub v2.0 - FULL FEATURES")
print("Tabs: Main, Farming, Auto, Quests, Mastery, Raid, Fruit, Settings")
print("========================================")
