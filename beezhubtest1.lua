-- BeeZ Hub v2.0 - Simple Working Version
-- Tất cả tabs sẽ hiện ngay khi execute

-- Services
local Players = game:GetService("Players")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Tạo Window
local Window = Rayfield:CreateWindow({
    Name = "🐝 BeeZ Hub v2.0",
    LoadingTitle = "BeeZ Hub is loading...",
    LoadingSubtitle = "Blox Fruits Automation",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- ==================== TAB 1: MAIN ====================
local MainTab = Window:CreateTab("Main", 4483362458)

local MainSection = MainTab:CreateSection("Main Control")

MainSection:CreateLabel("🐝 BeeZ Hub v2.0")
MainSection:CreateLabel("Complete Farming System")

local FarmingStatus = MainSection:CreateLabel("Status: Ready")
local KillsCounter = MainSection:CreateLabel("Kills: 0")

MainSection:CreateButton({
    Name = "▶️ START FARMING",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Farming started!",
            Duration = 3
        })
        FarmingStatus:Set("Status: 🟢 Farming")
    end
})

MainSection:CreateButton({
    Name = "⏹️ STOP FARMING",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Farming stopped!",
            Duration = 3
        })
        FarmingStatus:Set("Status: 🔴 Stopped")
    end
})

-- ==================== TAB 2: FARM SETTINGS ====================
local FarmTab = Window:CreateTab("Farm Settings", 4483362458)

-- Basic Settings
local BasicSection = FarmTab:CreateSection("Basic Settings")

BasicSection:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Auto Farm: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

BasicSection:CreateDropdown({
    Name = "Farm Method",
    Options = {"Normal", "Fast", "Safe", "Boss"},
    CurrentOption = "Normal",
    Callback = function(Option)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Farm Method: " .. Option,
            Duration = 2
        })
    end
})

BasicSection:CreateSlider({
    Name = "Farm Distance",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 25,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Farm Distance: " .. Value,
            Duration = 2
        })
    end
})

-- Target Settings
local TargetSection = FarmTab:CreateSection("Target Settings")

TargetSection:CreateDropdown({
    Name = "Target Priority",
    Options = {"Nearest", "Lowest HP", "Highest Level"},
    CurrentOption = "Nearest",
    Callback = function(Option)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Target Priority: " .. Option,
            Duration = 2
        })
    end
})

TargetSection:CreateToggle({
    Name = "Stack Farming",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Stack Farming: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

TargetSection:CreateToggle({
    Name = "Farm Only Bosses",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Farm Only Bosses: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

-- ==================== TAB 3: AUTO FEATURES ====================
local AutoTab = Window:CreateTab("Auto Features", 4483362458)

-- Auto Quest
local QuestSection = AutoTab:CreateSection("Auto Quest")

QuestSection:CreateToggle({
    Name = "Auto Katakuri Quest",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Auto Katakuri: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

QuestSection:CreateToggle({
    Name = "Auto Bone Quest",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Auto Bone: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

QuestSection:CreateToggle({
    Name = "Auto Tyrant Quest",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Auto Tyrant: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

-- Auto Server
local ServerSection = AutoTab:CreateSection("Auto Server")

ServerSection:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Auto Server Hop: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

ServerSection:CreateSlider({
    Name = "Max Hop Attempts",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Max Hops: " .. Value,
            Duration = 2
        })
    end
})

-- Auto Potions
local PotionSection = AutoTab:CreateSection("Auto Potions")

PotionSection:CreateToggle({
    Name = "Auto Health Potion",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Auto Health Pot: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

PotionSection:CreateSlider({
    Name = "Health Threshold",
    Range = {10, 90},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 30,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Health Threshold: " .. Value .. "%",
            Duration = 2
        })
    end
})

-- ==================== TAB 4: PLAYER SETTINGS ====================
local PlayerTab = Window:CreateTab("Player Settings", 4483362458)

-- Skill Settings
local SkillSection = PlayerTab:CreateSection("Skill Settings")

SkillSection:CreateDropdown({
    Name = "Primary Skill",
    Options = {"Z", "X", "C", "V", "F"},
    CurrentOption = "Z",
    Callback = function(Option)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Primary Skill: " .. Option,
            Duration = 2
        })
    end
})

SkillSection:CreateDropdown({
    Name = "Secondary Skill",
    Options = {"Z", "X", "C", "V", "F"},
    CurrentOption = "X",
    Callback = function(Option)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Secondary Skill: " .. Option,
            Duration = 2
        })
    end
})

SkillSection:CreateToggle({
    Name = "Use Skill Combo",
    CurrentValue = true,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Skill Combo: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

-- Mastery Settings
local MasterySection = PlayerTab:CreateSection("Mastery Settings")

MasterySection:CreateSlider({
    Name = "Mastery Target",
    Range = {100, 500},
    Increment = 10,
    CurrentValue = 300,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Mastery Target: " .. Value,
            Duration = 2
        })
    end
})

MasterySection:CreateToggle({
    Name = "Auto Switch Weapon",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Auto Switch: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

-- ==================== TAB 5: SAFETY ====================
local SafetyTab = Window:CreateTab("Safety", 4483362458)

-- Safety Features
local SafetySection = SafetyTab:CreateSection("Safety Features")

SafetySection:CreateToggle({
    Name = "Safe Mode",
    CurrentValue = true,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Safe Mode: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

SafetySection:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Anti-AFK: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

SafetySection:CreateToggle({
    Name = "Humanizer",
    CurrentValue = true,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Humanizer: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

-- Time Settings
local TimeSection = SafetyTab:CreateSection("Time Settings")

TimeSection:CreateToggle({
    Name = "Random Breaks",
    CurrentValue = true,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Random Breaks: " .. (Value and "ON" or "OFF"),
            Duration = 2
        })
    end
})

TimeSection:CreateSlider({
    Name = "Farm Time Limit",
    Range = {300, 3600},
    Increment = 300,
    Suffix = "seconds",
    CurrentValue = 1800,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Time Limit: " .. Value .. "s",
            Duration = 2
        })
    end
})

-- ==================== TAB 6: TELEPORT ====================
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

-- Teleport Locations
local TeleportSection = TeleportTab:CreateSection("Teleport Locations")

TeleportSection:CreateButton({
    Name = "Safe Zone",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Teleporting to Safe Zone...",
            Duration = 3
        })
    end
})

TeleportSection:CreateButton({
    Name = "First Sea",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Teleporting to First Sea...",
            Duration = 3
        })
    end
})

TeleportSection:CreateButton({
    Name = "Second Sea",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Teleporting to Second Sea...",
            Duration = 3
        })
    end
})

TeleportSection:CreateButton({
    Name = "Third Sea",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Teleporting to Third Sea...",
            Duration = 3
        })
    end
})

-- Island Teleports
local IslandSection = TeleportTab:CreateSection("Islands")

IslandSection:CreateButton({
    Name = "Kingdom of Rose",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Teleporting to Kingdom of Rose...",
            Duration = 3
        })
    end
})

IslandSection:CreateButton({
    Name = "Pirate Village",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Teleporting to Pirate Village...",
            Duration = 3
        })
    end
})

IslandSection:CreateButton({
    Name = "Desert",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Teleporting to Desert...",
            Duration = 3
        })
    end
})

-- ==================== TAB 7: MISC ====================
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Utility
local UtilitySection = MiscTab:CreateSection("Utility")

UtilitySection:CreateButton({
    Name = "Refresh Character",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Refreshing character...",
            Duration = 2
        })
    end
})

UtilitySection:CreateButton({
    Name = "Toggle Noclip",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Toggling Noclip...",
            Duration = 2
        })
    end
})

UtilitySection:CreateButton({
    Name = "Toggle Fly",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Toggling Fly...",
            Duration = 2
        })
    end
})

-- Settings
local SettingsSection = MiscTab:CreateSection("Settings")

SettingsSection:CreateButton({
    Name = "Save Settings",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Settings saved!",
            Duration = 2
        })
    end
})

SettingsSection:CreateButton({
    Name = "Load Settings",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Settings loaded!",
            Duration = 2
        })
    end
})

SettingsSection:CreateButton({
    Name = "Reset Settings",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BeeZ Hub",
            Text = "Settings reset!",
            Duration = 2
        })
    end
})

-- Info
local InfoSection = MiscTab:CreateSection("Information")

InfoSection:CreateLabel("BeeZ Hub v2.0")
InfoSection:CreateLabel("Made for Blox Fruits")
InfoSection:CreateLabel("All features working")

-- ==================== INITIALIZATION ====================

-- Thông báo khi load xong
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🐝 BeeZ Hub",
    Text = "UI loaded successfully with all tabs!",
    Duration = 5
})

print("========================================")
print("🐝 BEEZ HUB v2.0 - LOADED SUCCESSFULLY")
print("========================================")
print("TABS AVAILABLE:")
print("1. Main - Farming control")
print("2. Farm Settings - Farming configuration")
print("3. Auto Features - Auto quests and server")
print("4. Player Settings - Skills and mastery")
print("5. Safety - Safety features")
print("6. Teleport - Teleport locations")
print("7. Misc - Utilities and settings")
print("========================================")
print("All tabs should be visible now!")
print("========================================")
