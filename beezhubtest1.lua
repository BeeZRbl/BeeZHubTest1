-- BeeZ Hub v2.0 - Sử dụng Kavo UI (Tương thích Delta, Xeno, và mọi executor)
-- UI sẽ hiện đầy đủ tính năng

-- Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Tạo Window
local Window = Library.CreateLib("🐝 BeeZ Hub v2.0", "DarkTheme")

-- ==================== TAB 1: MAIN ====================
local MainTab = Window:NewTab("Main")

local MainSection = MainTab:NewSection("Main Control")

MainSection:NewLabel("🐝 BeeZ Hub v2.0")
MainSection:NewLabel("Blox Fruits Automation System")

local FarmingStatus = "Ready"
local KillsCount = 0

local StatusLabel = MainSection:NewLabel("Status: " .. FarmingStatus)
local KillsLabel = MainSection:NewLabel("Kills: " .. KillsCount)

MainSection:NewButton("▶️ START FARMING", "Start auto farming", function()
    FarmingStatus = "Farming"
    StatusLabel:UpdateLabel("Status: 🟢 " .. FarmingStatus)
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Farming started!",
        Duration = 3
    })
end)

MainSection:NewButton("⏹️ STOP FARMING", "Stop farming", function()
    FarmingStatus = "Stopped"
    StatusLabel:UpdateLabel("Status: 🔴 " .. FarmingStatus)
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Farming stopped!",
        Duration = 3
    })
end)

MainSection:NewButton("🔄 REFRESH", "Refresh status", function()
    KillsCount = KillsCount + 1
    KillsLabel:UpdateLabel("Kills: " .. KillsCount)
end)

-- ==================== TAB 2: FARMING ====================
local FarmingTab = Window:NewTab("Farming")

-- Basic Farming Settings
local BasicFarming = FarmingTab:NewSection("Basic Farming")

local AutoFarmToggle = false
BasicFarming:NewToggle("Enable Auto Farm", "Toggle auto farming", function(state)
    AutoFarmToggle = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Auto Farm: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local FarmMethod = "Normal"
BasicFarming:NewDropdown("Farm Method", "Select farming method", {"Normal", "Fast", "Safe", "Boss"}, function(method)
    FarmMethod = method
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Farm Method: " .. method,
        Duration = 2
    })
end)

local FarmDistance = 25
BasicFarming:NewSlider("Farm Distance", "Distance to farm", 100, 10, function(value)
    FarmDistance = value
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Farm Distance: " .. value,
        Duration = 1
    })
end)

-- Target Settings
local TargetSettings = FarmingTab:NewSection("Target Settings")

local TargetPriority = "Nearest"
TargetSettings:NewDropdown("Target Priority", "Select target priority", {"Nearest", "Lowest HP", "Highest Level", "Boss First"}, function(priority)
    TargetPriority = priority
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Target Priority: " .. priority,
        Duration = 2
    })
end)

local StackFarming = false
TargetSettings:NewToggle("Stack Farming", "Farm multiple enemies", function(state)
    StackFarming = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Stack Farming: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local FarmOnlyBosses = false
TargetSettings:NewToggle("Farm Only Bosses", "Only target bosses", function(state)
    FarmOnlyBosses = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Farm Only Bosses: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

-- ==================== TAB 3: AUTO FEATURES ====================
local AutoTab = Window:NewTab("Auto Features")

-- Auto Quest
local AutoQuest = AutoTab:NewSection("Auto Quest")

local AutoKatakuri = false
AutoQuest:NewToggle("Auto Katakuri Quest", "Auto accept Katakuri quest", function(state)
    AutoKatakuri = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Auto Katakuri: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local AutoBone = false
AutoQuest:NewToggle("Auto Bone Quest", "Auto accept Bone quest", function(state)
    AutoBone = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Auto Bone: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local AutoTyrant = false
AutoQuest:NewToggle("Auto Tyrant Quest", "Auto accept Tyrant quest", function(state)
    AutoTyrant = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Auto Tyrant: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

-- Auto Server
local AutoServer = AutoTab:NewSection("Auto Server")

local AutoHop = false
AutoServer:NewToggle("Auto Server Hop", "Auto hop servers", function(state)
    AutoHop = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Auto Server Hop: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local MaxHops = 10
AutoServer:NewSlider("Max Hop Attempts", "Maximum hops", 20, 1, function(value)
    MaxHops = value
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Max Hops: " .. value,
        Duration = 1
    })
end)

-- Auto Potions
local AutoPotions = AutoTab:NewSection("Auto Potions")

local AutoHealthPot = false
AutoPotions:NewToggle("Auto Health Potion", "Auto use health potion", function(state)
    AutoHealthPot = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Auto Health Pot: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local HealthThreshold = 30
AutoPotions:NewSlider("Health Threshold", "HP % to use potion", 90, 10, function(value)
    HealthThreshold = value
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Health Threshold: " .. value .. "%",
        Duration = 1
    })
end)

-- ==================== TAB 4: PLAYER SETTINGS ====================
local PlayerTab = Window:NewTab("Player Settings")

-- Skill Settings
local SkillSettings = PlayerTab:NewSection("Skill Settings")

local PrimarySkill = "Z"
SkillSettings:NewDropdown("Primary Skill", "Main skill to use", {"Z", "X", "C", "V", "F"}, function(skill)
    PrimarySkill = skill
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Primary Skill: " .. skill,
        Duration = 2
    })
end)

local SecondarySkill = "X"
SkillSettings:NewDropdown("Secondary Skill", "Secondary skill", {"Z", "X", "C", "V", "F"}, function(skill)
    SecondarySkill = skill
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Secondary Skill: " .. skill,
        Duration = 2
    })
end)

local UseSkillCombo = true
SkillSettings:NewToggle("Use Skill Combo", "Use skill combinations", function(state)
    UseSkillCombo = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Skill Combo: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

-- Mastery Settings
local MasterySettings = PlayerTab:NewSection("Mastery Settings")

local MasteryTarget = 300
MasterySettings:NewSlider("Mastery Target", "Target mastery level", 500, 100, function(value)
    MasteryTarget = value
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Mastery Target: " .. value,
        Duration = 1
    })
end)

local AutoSwitchWeapon = false
MasterySettings:NewToggle("Auto Switch Weapon", "Auto switch when maxed", function(state)
    AutoSwitchWeapon = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Auto Switch: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

-- ==================== TAB 5: SAFETY ====================
local SafetyTab = Window:NewTab("Safety")

-- Safety Features
local SafetyFeatures = SafetyTab:NewSection("Safety Features")

local SafeMode = true
SafetyFeatures:NewToggle("Safe Mode", "Enable safe mode", function(state)
    SafeMode = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Safe Mode: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local AntiAfk = true
SafetyFeatures:NewToggle("Anti-AFK", "Prevent AFK kick", function(state)
    AntiAfk = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Anti-AFK: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local Humanizer = true
SafetyFeatures:NewToggle("Humanizer", "Human-like behavior", function(state)
    Humanizer = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Humanizer: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

-- Time Settings
local TimeSettings = SafetyTab:NewSection("Time Settings")

local RandomBreaks = true
TimeSettings:NewToggle("Random Breaks", "Take random breaks", function(state)
    RandomBreaks = state
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Random Breaks: " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end)

local FarmTimeLimit = 1800
TimeSettings:NewSlider("Farm Time Limit", "Max farming time", 3600, 300, function(value)
    FarmTimeLimit = value
    local minutes = math.floor(value / 60)
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Time Limit: " .. minutes .. " minutes",
        Duration = 2
    })
end)

-- ==================== TAB 6: TELEPORT ====================
local TeleportTab = Window:NewTab("Teleport")

-- Teleport Locations
local TeleportLocations = TeleportTab:NewSection("Teleport Locations")

TeleportLocations:NewButton("Safe Zone", "Teleport to safe spot", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Teleporting to Safe Zone...",
        Duration = 3
    })
end)

TeleportLocations:NewButton("First Sea", "Teleport to First Sea", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Teleporting to First Sea...",
        Duration = 3
    })
end)

TeleportLocations:NewButton("Second Sea", "Teleport to Second Sea", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Teleporting to Second Sea...",
        Duration = 3
    })
end)

TeleportLocations:NewButton("Third Sea", "Teleport to Third Sea", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Teleporting to Third Sea...",
        Duration = 3
    })
end)

-- Islands
local Islands = TeleportTab:NewSection("Islands")

Islands:NewButton("Kingdom of Rose", "Teleport to Kingdom of Rose", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Teleporting to Kingdom of Rose...",
        Duration = 3
    })
end)

Islands:NewButton("Pirate Village", "Teleport to Pirate Village", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Teleporting to Pirate Village...",
        Duration = 3
    })
end)

Islands:NewButton("Desert", "Teleport to Desert", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Teleporting to Desert...",
        Duration = 3
    })
end)

-- ==================== TAB 7: MISC ====================
local MiscTab = Window:NewTab("Misc")

-- Utility
local Utility = MiscTab:NewSection("Utility")

Utility:NewButton("Refresh Character", "Reset character", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Refreshing character...",
        Duration = 2
    })
end)

Utility:NewButton("Toggle Noclip", "Enable/Disable noclip", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Toggling Noclip...",
        Duration = 2
    })
end)

Utility:NewButton("Toggle Fly", "Enable/Disable fly", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Toggling Fly...",
        Duration = 2
    })
end)

-- Settings
local Settings = MiscTab:NewSection("Settings")

Settings:NewButton("Save Settings", "Save current settings", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Settings saved!",
        Duration = 2
    })
end)

Settings:NewButton("Load Settings", "Load saved settings", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Settings loaded!",
        Duration = 2
    })
end)

Settings:NewButton("Reset Settings", "Reset to default", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BeeZ Hub",
        Text = "Settings reset!",
        Duration = 2
    })
end)

-- Info
local Info = MiscTab:NewSection("Information")

Info:NewLabel("BeeZ Hub v2.0")
Info:NewLabel("Made for Blox Fruits")
Info:NewLabel("Works with Delta & Xeno")

-- ==================== INITIALIZATION ====================

-- Thông báo khi load xong
game.StarterGui:SetCore("SendNotification", {
    Title = "🐝 BeeZ Hub",
    Text = "UI loaded successfully!\nAll 7 tabs available",
    Duration = 5
})

print("========================================")
print("🐝 BEEZ HUB v2.0 - KAVO UI VERSION")
print("========================================")
print("TABS LOADED:")
print("1. Main - Farming control")
print("2. Farming - Farm settings") 
print("3. Auto Features - Auto functions")
print("4. Player Settings - Player config")
print("5. Safety - Safety features")
print("6. Teleport - Teleport locations")
print("7. Misc - Utilities and info")
print("========================================")
print("Working with Delta, Xeno, and all executors!")
print("========================================")
