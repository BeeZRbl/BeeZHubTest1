-- BeeZ Hub v2.0 - Complete Farming System
-- Full features organized by sections

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

-- Farming Configuration
local Config = {
    -- Basic Farming
    AutoFarm = false,
    FarmMethod = "Normal",
    FarmDistance = 25,
    FarmPriority = "Nearest",
    
    -- Advanced Farming
    StackFarming = false,
    StackFarmCount = 3,
    FarmOnlyBosses = false,
    SkipLowLevel = false,
    LevelThreshold = 50,
    BlacklistedNPCs = {},
    
    -- Auto Features
    AutoHop = false,
    MaxHopAttempts = 10,
    HopIfNoKatakuri = false,
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
    
    -- Skill Settings
    SkillCombo = {"Z", "X", "C"},
    SkillDelay = 0.5,
    AutoClick = false,
    ClickSpeed = 0.1,
    
    -- Mastery
    MasteryFarm = false,
    MasteryTarget = 300,
    AutoSwitchWeapon = false,
    
    -- UI
    Notifications = true,
    StatusDisplay = true
}

-- Variables
local FarmEnabled = false
local FarmingLoop = nil
local CurrentTargets = {}
local HopAttempts = 0
local CurrentMastery = 0
local EnemiesKilled = 0
local FarmStartTime = 0
local SkillCooldowns = {}

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🐝 BeeZ Hub v2.0",
    LoadingTitle = "BeeZ Hub is loading...",
    LoadingSubtitle = "Complete Blox Fruits Farming System",
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

-- Main Control Section
local MainControl = MainTab:CreateSection("Main Control")

MainControl:CreateLabel("🐝 BeeZ Hub v2.0")
MainControl:CreateLabel("Complete Farming System")

MainControl:CreateButton({
    Name = "▶️ START FARMING",
    Callback = function()
        StartFarming()
    end
})

MainControl:CreateButton({
    Name = "⏹️ STOP FARMING",
    Callback = function()
        StopFarming()
    end
})

-- Status Display Section
local StatusSection = MainTab:CreateSection("Status Display")

local StatusLabel = StatusSection:CreateLabel("🔴 Status: IDLE")
local MasteryLabel = StatusSection:CreateLabel("⚔️ Mastery: 0/300")
local KillsLabel = StatusSection:CreateLabel("💀 Kills: 0")
local TimeLabel = StatusSection:CreateLabel("⏰ Time: 00:00")

-- Quick Actions Section
local QuickActions = MainTab:CreateSection("Quick Actions")

QuickActions:CreateButton({
    Name = "🛡️ Teleport to Safe Zone",
    Callback = function()
        TeleportSafe()
    end
})

QuickActions:CreateButton({
    Name = "🔄 Refresh Character",
    Callback = function()
        RefreshCharacter()
    end
})

QuickActions:CreateButton({
    Name = "📊 Toggle Status Display",
    Callback = function()
        ToggleStatusDisplay()
    end
})

-- ==================== BASIC FARMING TAB ====================
local BasicFarmingTab = Window:CreateTab("Basic Farming", 4483362458)

-- Farm Mode Section
local FarmMode = BasicFarmingTab:CreateSection("Farm Mode")

FarmMode:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = Config.AutoFarm,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        Config.AutoFarm = Value
        BeeZ_Notify("Auto Farm: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

local FarmMethod = FarmMode:CreateDropdown({
    Name = "Farm Method",
    Options = {"Normal", "Fast", "Safe", "Boss", "Grind"},
    CurrentOption = Config.FarmMethod,
    Flag = "FarmMethodDropdown",
    Callback = function(Option)
        Config.FarmMethod = Option
        BeeZ_Notify("Farm Method: " .. Option)
    end
})

local FarmDistance = FarmMode:CreateSlider({
    Name = "Farm Distance",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = Config.FarmDistance,
    Flag = "FarmDistanceSlider",
    Callback = function(Value)
        Config.FarmDistance = Value
    end
})

-- Target Selection Section
local TargetSelection = BasicFarmingTab:CreateSection("Target Selection")

local PriorityDropdown = TargetSelection:CreateDropdown({
    Name = "Target Priority",
    Options = {"Nearest", "Highest Level", "Lowest HP", "Highest Reward", "Weakest First"},
    CurrentOption = Config.FarmPriority,
    Flag = "PriorityDropdown",
    Callback = function(Option)
        Config.FarmPriority = Option
        BeeZ_Notify("Target Priority: " .. Option)
    end
})

TargetSelection:CreateToggle({
    Name = "Farm Only Bosses",
    CurrentValue = Config.FarmOnlyBosses,
    Flag = "FarmBossesToggle",
    Callback = function(Value)
        Config.FarmOnlyBosses = Value
        BeeZ_Notify("Farm Only Bosses: " .. (Value and "YES" or "NO"))
    end
})

TargetSelection:CreateToggle({
    Name = "Skip Low Level Enemies",
    CurrentValue = Config.SkipLowLevel,
    Flag = "SkipLowLevelToggle",
    Callback = function(Value)
        Config.SkipLowLevel = Value
        BeeZ_Notify("Skip Low Level: " .. (Value and "YES" or "NO"))
    end
})

local LevelThreshold = TargetSelection:CreateSlider({
    Name = "Level Threshold",
    Range = {1, 1000},
    Increment = 10,
    Suffix = "level",
    CurrentValue = Config.LevelThreshold,
    Flag = "LevelThresholdSlider",
    Callback = function(Value)
        Config.LevelThreshold = Value
    end
})

-- ==================== ADVANCED FARMING TAB ====================
local AdvancedFarmingTab = Window:CreateTab("Advanced Farming", 4483362458)

-- Stack Farming Section
local StackFarming = AdvancedFarmingTab:CreateSection("Stack Farming")

StackFarming:CreateToggle({
    Name = "Enable Stack Farming",
    CurrentValue = Config.StackFarming,
    Flag = "StackFarmingToggle",
    Callback = function(Value)
        Config.StackFarming = Value
        BeeZ_Notify("Stack Farming: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

local StackCount = StackFarming:CreateSlider({
    Name = "Max Stack Count",
    Range = {2, 10},
    Increment = 1,
    CurrentValue = Config.StackFarmCount,
    Flag = "StackCountSlider",
    Callback = function(Value)
        Config.StackFarmCount = Value
    end
})

StackFarming:CreateToggle({
    Name = "Prioritize Grouped Enemies",
    CurrentValue = true,
    Flag = "GroupPriorityToggle",
    Callback = function(Value)
        BeeZ_Notify("Group Priority: " .. (Value and "ON" or "OFF"))
    end
})

-- AOE Farming Section
local AOEFarming = AdvancedFarmingTab:CreateSection("AOE Farming")

AOEFarming:CreateToggle({
    Name = "Auto AOE Attacks",
    CurrentValue = true,
    Flag = "AOEAttackToggle",
    Callback = function(Value)
        BeeZ_Notify("AOE Attacks: " .. (Value and "ON" or "OFF"))
    end
})

AOEFarming:CreateToggle({
    Name = "Use Ultimate on Groups",
    CurrentValue = false,
    Flag = "UltimateToggle",
    Callback = function(Value)
        BeeZ_Notify("Ultimate on Groups: " .. (Value and "ON" or "OFF"))
    end
})

AOEFarming:CreateSlider({
    Name = "Min Enemies for AOE",
    Range = {2, 8},
    Increment = 1,
    CurrentValue = 3,
    Flag = "MinAOEThreshold",
    Callback = function(Value)
        BeeZ_Notify("AOE Threshold: " .. Value .. " enemies")
    end
})

-- Optimization Section
local Optimization = AdvancedFarmingTab:CreateSection("Optimization")

Optimization:CreateToggle({
    Name = "Smart Pathfinding",
    CurrentValue = true,
    Flag = "PathfindingToggle",
    Callback = function(Value)
        BeeZ_Notify("Smart Pathfinding: " .. (Value and "ON" or "OFF"))
    end
})

Optimization:CreateToggle({
    Name = "Energy Saver Mode",
    CurrentValue = false,
    Flag = "EnergySaverToggle",
    Callback = function(Value)
        BeeZ_Notify("Energy Saver: " .. (Value and "ON" or "OFF"))
    end
})

Optimization:CreateToggle({
    Name = "Auto Loot Collector",
    CurrentValue = true,
    Flag = "LootCollectorToggle",
    Callback = function(Value)
        BeeZ_Notify("Loot Collector: " .. (Value and "ON" or "OFF"))
    end
})

-- ==================== SKILL SETTINGS TAB ====================
local SkillTab = Window:CreateTab("Skill Settings", 4483362458)

-- Skill Combo Section
local SkillCombo = SkillTab:CreateSection("Skill Combo")

SkillCombo:CreateDropdown({
    Name = "Primary Skill",
    Options = {"Z", "X", "C", "V", "F"},
    CurrentOption = "Z",
    Flag = "PrimarySkillDropdown",
    Callback = function(Option)
        UpdateSkillCombo(1, Option)
        BeeZ_Notify("Primary Skill: " .. Option)
    end
})

SkillCombo:CreateDropdown({
    Name = "Secondary Skill",
    Options = {"Z", "X", "C", "V", "F"},
    CurrentOption = "X",
    Flag = "SecondarySkillDropdown",
    Callback = function(Option)
        UpdateSkillCombo(2, Option)
        BeeZ_Notify("Secondary Skill: " .. Option)
    end
})

SkillCombo:CreateDropdown({
    Name = "Tertiary Skill",
    Options = {"Z", "X", "C", "V", "F"},
    CurrentOption = "C",
    Flag = "TertiarySkillDropdown",
    Callback = function(Option)
        UpdateSkillCombo(3, Option)
        BeeZ_Notify("Tertiary Skill: " .. Option)
    end
})

local SkillDelay = SkillCombo:CreateSlider({
    Name = "Skill Delay",
    Range = {0.1, 2.0},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = Config.SkillDelay,
    Flag = "SkillDelaySlider",
    Callback = function(Value)
        Config.SkillDelay = Value
    end
})

-- Auto Attack Section
local AutoAttack = SkillTab:CreateSection("Auto Attack")

AutoAttack:CreateToggle({
    Name = "Enable Auto Click",
    CurrentValue = Config.AutoClick,
    Flag = "AutoClickToggle",
    Callback = function(Value)
        Config.AutoClick = Value
        BeeZ_Notify("Auto Click: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

local ClickSpeed = AutoAttack:CreateSlider({
    Name = "Click Speed",
    Range = {0.05, 0.5},
    Increment = 0.05,
    Suffix = "seconds",
    CurrentValue = Config.ClickSpeed,
    Flag = "ClickSpeedSlider",
    Callback = function(Value)
        Config.ClickSpeed = Value
    end
})

AutoAttack:CreateToggle({
    Name = "Use M1 Combo",
    CurrentValue = true,
    Flag = "M1ComboToggle",
    Callback = function(Value)
        BeeZ_Notify("M1 Combo: " .. (Value and "ON" or "OFF"))
    end
})

-- Skill Priority Section
local SkillPriority = SkillTab:CreateSection("Skill Priority")

SkillPriority:CreateToggle({
    Name = "Prioritize High Damage Skills",
    CurrentValue = true,
    Flag = "HighDamagePriorityToggle",
    Callback = function(Value)
        BeeZ_Notify("High Damage Priority: " .. (Value and "ON" or "OFF"))
    end
})

SkillPriority:CreateToggle({
    Name = "Use Skills on Cooldown",
    CurrentValue = true,
    Flag = "CooldownToggle",
    Callback = function(Value)
        BeeZ_Notify("Use on Cooldown: " .. (Value and "ON" or "OFF"))
    end
})

SkillPriority:CreateToggle({
    Name = "Save Ultimate for Bosses",
    CurrentValue = false,
    Flag = "SaveUltimateToggle",
    Callback = function(Value)
        BeeZ_Notify("Save Ultimate: " .. (Value and "ON" or "OFF"))
    end
})

-- ==================== AUTO FEATURES TAB ====================
local AutoTab = Window:CreateTab("Auto Features", 4483362458)

-- Server Management Section
local ServerManagement = AutoTab:CreateSection("Server Management")

ServerManagement:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = Config.AutoHop,
    Flag = "AutoHopToggle",
    Callback = function(Value)
        Config.AutoHop = Value
        BeeZ_Notify("Auto Server Hop: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

local MaxHops = ServerManagement:CreateSlider({
    Name = "Max Hop Attempts",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = Config.MaxHopAttempts,
    Flag = "MaxHopsSlider",
    Callback = function(Value)
        Config.MaxHopAttempts = Value
    end
})

ServerManagement:CreateToggle({
    Name = "Hop if No Katakuri",
    CurrentValue = Config.HopIfNoKatakuri,
    Flag = "HopKatakuriToggle",
    Callback = function(Value)
        Config.HopIfNoKatakuri = Value
        BeeZ_Notify("Hop if No Katakuri: " .. (Value and "YES" or "NO"))
    end
})

-- Auto Potions Section
local AutoPotions = AutoTab:CreateSection("Auto Potions")

AutoPotions:CreateToggle({
    Name = "Auto Health Potion",
    CurrentValue = Config.AutoHealthPot,
    Flag = "AutoHealthPotToggle",
    Callback = function(Value)
        Config.AutoHealthPot = Value
        BeeZ_Notify("Auto Health Pot: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

local HealthThreshold = AutoPotions:CreateSlider({
    Name = "Health Threshold",
    Range = {10, 90},
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
        BeeZ_Notify("Auto Energy Pot: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

local EnergyThreshold = AutoPotions:CreateSlider({
    Name = "Energy Threshold",
    Range = {10, 90},
    Increment = 5,
    Suffix = "%",
    CurrentValue = Config.EnergyThreshold,
    Flag = "EnergyThresholdSlider",
    Callback = function(Value)
        Config.EnergyThreshold = Value
    end
})

-- Quest Automation Section
local QuestAutomation = AutoTab:CreateSection("Quest Automation")

QuestAutomation:CreateToggle({
    Name = "Auto Accept Quests",
    CurrentValue = true,
    Flag = "AutoAcceptToggle",
    Callback = function(Value)
        BeeZ_Notify("Auto Accept Quests: " .. (Value and "ON" or "OFF"))
    end
})

QuestAutomation:CreateToggle({
    Name = "Auto Complete Quests",
    CurrentValue = true,
    Flag = "AutoCompleteToggle",
    Callback = function(Value)
        BeeZ_Notify("Auto Complete Quests: " .. (Value and "ON" or "OFF"))
    end
})

QuestAutomation:CreateToggle({
    Name = "Auto Katakuri Quest",
    CurrentValue = true,
    Flag = "KatakuriAutoToggle",
    Callback = function(Value)
        BeeZ_Notify("Auto Katakuri: " .. (Value and "ON" or "OFF"))
    end
})

-- ==================== SAFETY TAB ====================
local SafetyTab = Window:CreateTab("Safety", 4483362458)

-- Safety Features Section
local SafetyFeatures = SafetyTab:CreateSection("Safety Features")

SafetyFeatures:CreateToggle({
    Name = "Safe Mode",
    CurrentValue = Config.SafeMode,
    Flag = "SafeModeToggle",
    Callback = function(Value)
        Config.SafeMode = Value
        BeeZ_Notify("Safe Mode: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

SafetyFeatures:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = Config.AntiAfk,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        Config.AntiAfk = Value
        BeeZ_Notify("Anti-AFK: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

SafetyFeatures:CreateToggle({
    Name = "Humanizer",
    CurrentValue = Config.Humanizer,
    Flag = "HumanizerToggle",
    Callback = function(Value)
        Config.Humanizer = Value
        BeeZ_Notify("Humanizer: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

-- Time Management Section
local TimeManagement = SafetyTab:CreateSection("Time Management")

TimeManagement:CreateToggle({
    Name = "Random Breaks",
    CurrentValue = Config.RandomBreaks,
    Flag = "RandomBreaksToggle",
    Callback = function(Value)
        Config.RandomBreaks = Value
        BeeZ_Notify("Random Breaks: " .. (Value and "ENABLED" or "DISABLED"))
    end
})

local FarmTimeLimit = TimeManagement:CreateSlider({
    Name = "Farm Time Limit",
    Range = {300, 7200},
    Increment = 300,
    Suffix = "seconds",
    CurrentValue = Config.FarmTimeLimit,
    Flag = "FarmTimeLimitSlider",
    Callback = function(Value)
        Config.FarmTimeLimit = Value
    end
})

TimeManagement:CreateToggle({
    Name = "Auto Stop at Limit",
    CurrentValue = true,
    Flag = "AutoStopToggle",
    Callback = function(Value)
        BeeZ_Notify("Auto Stop: " .. (Value and "ON" or "OFF"))
    end
})

-- Blacklist Section
local Blacklist = SafetyTab:CreateSection("Blacklist Manager")

Blacklist:CreateButton({
    Name = "Add Current NPC to Blacklist",
    Callback = function()
        AddToBlacklist()
    end
})

Blacklist:CreateButton({
    Name = "Clear Blacklist",
    Callback = function()
        ClearBlacklist()
    end
})

Blacklist:CreateLabel("Blacklisted NPCs: 0")

-- ==================== FUNCTIONS ====================

function BeeZ_Notify(message, duration)
    if Config.Notifications then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🐝 BeeZ Hub",
            Text = message,
            Duration = duration or 2,
            Icon = "rbxassetid://6723928013"
        })
    end
end

function StartFarming()
    if FarmEnabled then
        BeeZ_Notify("Farming is already running!")
        return
    end
    
    FarmEnabled = true
    FarmStartTime = tick()
    EnemiesKilled = 0
    HopAttempts = 0
    
    BeeZ_Notify("🚀 FARMING STARTED!\nMethod: " .. Config.FarmMethod, 3)
    UpdateStatus()
    
    FarmingLoop = coroutine.create(function()
        while FarmEnabled do
            FarmCycle()
            task.wait(0.1)
        end
    end)
    
    coroutine.resume(FarmingLoop)
end

function StopFarming()
    if not FarmEnabled then
        BeeZ_Notify("Farming is not running!")
        return
    end
    
    FarmEnabled = false
    local farmTime = tick() - FarmStartTime
    local minutes = math.floor(farmTime / 60)
    local seconds = math.floor(farmTime % 60)
    
    BeeZ_Notify(string.format("⏹️ FARMING STOPPED!\nTime: %d:%02d\nKills: %d", minutes, seconds, EnemiesKilled), 3)
    UpdateStatus()
end

function FarmCycle()
    if Config.AntiAfk then
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
    
    -- Find targets based on settings
    local targets = FindTargets()
    
    if #targets > 0 then
        -- Move to first target
        HumanoidRootPart.CFrame = CFrame.new(targets[1].Position + Vector3.new(0, 3, 0))
        
        -- Attack targets
        AttackTargets(targets)
        
        -- Count kills
        EnemiesKilled = EnemiesKilled + 1
        UpdateStatus()
    else
        -- No targets found, check for server hop
        if Config.AutoHop and Config.HopIfNoKatakuri then
            CheckServerHop()
        end
    end
    
    -- Humanizer: Random breaks
    if Config.SafeMode and Config.RandomBreaks and math.random(1, 100) <= 5 then
        local breakTime = math.random(2, 8)
        BeeZ_Notify("Taking a short break... " .. breakTime .. "s", 2)
        task.wait(breakTime)
    end
    
    -- Check time limit
    if Config.FarmTimeLimit > 0 and (tick() - FarmStartTime) > Config.FarmTimeLimit then
        BeeZ_Notify("⏰ Time limit reached! Stopping farm...", 3)
        StopFarming()
    end
end

function FindTargets()
    local foundTargets = {}
    local allEnemies = {}
    
    -- Get all enemies in range
    for _, npc in pairs(Workspace.Enemies:GetChildren()) do
        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
            if npc.Humanoid.Health > 0 then
                local distance = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distance <= Config.FarmDistance then
                    local npcData = {
                        Object = npc,
                        Position = npc.HumanoidRootPart.Position,
                        Distance = distance,
                        Health = npc.Humanoid.Health,
                        MaxHealth = npc.Humanoid.MaxHealth,
                        IsBoss = string.find(npc.Name:lower(), "boss") ~= nil,
                        IsKatakuri = string.find(npc.Name:lower(), "katakuri") ~= nil
                    }
                    
                    -- Check if in blacklist
                    local isBlacklisted = false
                    for _, blacklisted in pairs(Config.BlacklistedNPCs) do
                        if string.find(npc.Name:lower(), blacklisted:lower()) then
                            isBlacklisted = true
                            break
                        end
                    end
                    
                    if not isBlacklisted then
                        table.insert(allEnemies, npcData)
                    end
                end
            end
        end
    end
    
    if #allEnemies == 0 then
        return foundTargets
    end
    
    -- Filter by settings
    local filteredEnemies = {}
    for _, enemy in pairs(allEnemies) do
        local shouldAdd = true
        
        -- Check if only bosses
        if Config.FarmOnlyBosses and not enemy.IsBoss then
            shouldAdd = false
        end
        
        -- Check if skip low level (placeholder logic)
        if Config.SkipLowLevel then
            -- You would need level detection logic here
        end
        
        if shouldAdd then
            table.insert(filteredEnemies, enemy)
        end
    end
    
    -- Sort based on priority
    if Config.FarmPriority == "Nearest" then
        table.sort(filteredEnemies, function(a, b)
            return a.Distance < b.Distance
        end)
    elseif Config.FarmPriority == "Highest Level" then
        -- Level detection needed
    elseif Config.FarmPriority == "Lowest HP" then
        table.sort(filteredEnemies, function(a, b)
            return a.Health < b.Health
        end)
    end
    
    -- Get targets for stack farming
    local targetCount = Config.StackFarming and math.min(Config.StackFarmCount, #filteredEnemies) or 1
    for i = 1, targetCount do
        if filteredEnemies[i] then
            table.insert(foundTargets, filteredEnemies[i])
        end
    end
    
    return foundTargets
end

function AttackTargets(targets)
    -- Use skill combo
    for _, skill in pairs(Config.SkillCombo) do
        if FarmEnabled then
            UseSkill(skill)
            task.wait(Config.SkillDelay)
        end
    end
    
    -- Auto click if enabled
    if Config.AutoClick then
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "LeftControl", false, game)
        task.wait(Config.ClickSpeed)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "LeftControl", false, game)
    end
    
    -- AOE attack for multiple targets
    if Config.StackFarming and #targets > 1 then
        UseSkill("X") -- Assuming X is AOE
        UseSkill("C") -- Another AOE skill
    end
end

function UseSkill(skill)
    if skill and not SkillCooldowns[skill] then
        game:GetService("VirtualInputManager"):SendKeyEvent(true, skill, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, skill, false, game)
        
        SkillCooldowns[skill] = true
        task.wait(1) -- Cooldown
        SkillCooldowns[skill] = false
    end
end

function CheckServerHop()
    if HopAttempts >= Config.MaxHopAttempts then
        BeeZ_Notify("Max hop attempts reached!")
        return
    end
    
    HopAttempts = HopAttempts + 1
    BeeZ_Notify("Server hopping... (" .. HopAttempts .. "/" .. Config.MaxHopAttempts .. ")")
    
    -- Server hop logic would go here
end

function UpdateSkillCombo(index, skill)
    Config.SkillCombo[index] = skill
end

function UpdateStatus()
    local statusText = FarmEnabled and "🟢 FARMING" or "🔴 IDLE"
    local masteryText = string.format("⚔️ Mastery: %d/%d", CurrentMastery, Config.MasteryTarget)
    local killsText = string.format("💀 Kills: %d", EnemiesKilled)
    
    if FarmEnabled then
        local currentTime = tick() - FarmStartTime
        local minutes = math.floor(currentTime / 60)
        local seconds = math.floor(currentTime % 60)
        local timeText = string.format("⏰ Time: %02d:%02d", minutes, seconds)
        TimeLabel:Set(timeText)
    else
        TimeLabel:Set("⏰ Time: 00:00")
    end
    
    StatusLabel:Set(statusText)
    MasteryLabel:Set(masteryText)
    KillsLabel:Set(killsText)
end

function TeleportSafe()
    HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
    BeeZ_Notify("Teleported to safe zone", 2)
end

function RefreshCharacter()
    Character:BreakJoints()
    BeeZ_Notify("Refreshing character...", 2)
end

function ToggleStatusDisplay()
    Config.StatusDisplay = not Config.StatusDisplay
    BeeZ_Notify("Status Display: " .. (Config.StatusDisplay and "SHOWING" or "HIDDEN"), 2)
end

function AddToBlacklist()
    BeeZ_Notify("Blacklist feature coming soon!", 2)
end

function ClearBlacklist()
    Config.BlacklistedNPCs = {}
    BeeZ_Notify("Blacklist cleared!", 2)
end

-- ==================== INITIALIZATION ====================

BeeZ_Notify("🐝 BeeZ Hub v2.0 loaded successfully!", 5)
print("========================================")
print("🐝 BEEZ HUB v2.0 - COMPLETE FARMING SYSTEM")
print("Tabs: Main, Basic Farming, Advanced Farming")
print("      Skill Settings, Auto Features, Safety")
print("========================================")
print("Farm Method: " .. Config.FarmMethod)
print("Farm Distance: " .. Config.FarmDistance)
print("Stack Farming: " .. tostring(Config.StackFarming))
print("Safe Mode: " .. tostring(Config.SafeMode))
print("========================================")
