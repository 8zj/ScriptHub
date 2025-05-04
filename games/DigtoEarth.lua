--[[
										This script was made for funs.
	noting to much will plan to update more.				Will Mostlikey be patched
											Made By Pick

]]



local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SettingsMain = {
    AutohatchEggs = false,
    SelectedWorld = "World1",
    SelectedEgg = "Egg1",
    AutoDig = false,
    AutoCollectTreasure = false,
    Petname = "Noting",
    AutoGoldPets = false,
    AutoDiamondPets = false,
    AutoGoldChance = 100,
    AutoDiamondChance = 100,
    
    GiveMoneyAmount = 1000,
    GiveGemsAmount = 1000,
    GiveMoney = false,
    GiveGems = false,
    GiveSpinWhalePet = false,
    GiveItemname = "spin",
    GiveItemLoop = false,
}

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Dig To Earth",
    Footer = "Pick Hub | 2025",
    Center = true,
    AutoShow = true,
    Resizable = false,
    ShowCustomCursor = false,
    Size = UDim2.new(0, 790, 0, 500)
})

local Tabs = {
    Main = Window:AddTab("Main", "axe-pickaxe"),
    Exploits = Window:AddTab("Exploits", "hammer"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local MainGroup = Tabs.Main:AddLeftGroupbox("Main Exploits")
local HatchGroup = Tabs.Main:AddRightGroupbox("Auto Hatch")
local GoldAndDiamond = Tabs.Main:AddLeftGroupbox("Gold/Diamond Pets")
local ExploitsGroup = Tabs.Exploits:AddLeftGroupbox("Money & Gems")
local ExploitsGroup1 = Tabs.Exploits:AddRightGroupbox("Give Urself Stuff")
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")



HatchGroup:AddToggle("AutoHatch", {
    Text = "Auto Hatch Egg",
    Default = false,
    Callback = function(state)
        SettingsMain.AutohatchEggs = state
    end,
})

HatchGroup:AddDropdown("WorldDropdown", {
    Values = { "World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8","World9","World10" },
    Default = "World1",
    Text = "Select World",
    Callback = function(world)
        SettingsMain.SelectedWorld = world
    end,
})

HatchGroup:AddDropdown("EggDropdown", {
    Values = {
        "Egg1", "Egg2", "Egg3", "Egg4", "Egg5",
        "Egg6", "Egg7", "Egg8", "Egg9", "Egg10",
        "Egg11", "Egg12", "Egg13","Egg14","Egg15"
    },
    Default = "Egg1",
    Text = "Select Egg",
    Callback = function(egg)
        SettingsMain.SelectedEgg = egg
    end,
})


MainGroup:AddToggle("AutoDig", {
    Text = "Auto Dig",
    Default = false,
    Callback = function(state)
        SettingsMain.AutoDig = state
    end,
})

MainGroup:AddToggle("AutoTreasure", {
    Text = "Auto Collect Treasure",
    Default = false,
    Callback = function(state)
        SettingsMain.AutoCollectTreasure = state
    end,
})


GoldAndDiamond:AddInput("MyTextbox", {
    Default = "Pet Name",
    Numeric = false,
    Finished = false,
    ClearTextOnFocus = true,
    Text = "Will Auto Make gold/diamond",
    Tooltip = "Must be the pet name.",
    Placeholder = "",
    Callback = function(Value)
        SettingsMain.Petname = Value
    end,
})


GoldAndDiamond:AddToggle("AutoGold", {
    Text = "Auto Gold Pets (5 at a time)",
    Default = false,
    Callback = function(state)
        SettingsMain.AutoGoldPets = state
    end,
})

GoldAndDiamond:AddDropdown("GoldChance", {
    Values = { "100", "88", "50", "13" },
    Default = "100",
    Text = "Gold Chance %",
    Callback = function(value)
        SettingsMain.AutoGoldChance = tonumber(value)
    end,
})

GoldAndDiamond:AddToggle("AutoDiamond", {
    Text = "Auto Diamond Pets (5 at a time)",
    Default = false,
    Callback = function(state)
        SettingsMain.AutoDiamondPets = state
    end,
})

GoldAndDiamond:AddDropdown("DiamondChance", {
    Values = { "100", "88", "50", "13" },
    Default = "100",
    Text = "Diamond Chance %",
    Callback = function(value)
        SettingsMain.AutoDiamondChance = tonumber(value)
    end,
})

ExploitsGroup:AddToggle("GiveMoney", {
    Text = "Give Money",
    Default = false,
    Callback = function(state)
        SettingsMain.GiveMoney = state
    end,
})

ExploitsGroup:AddToggle("GiveGems", {
    Text = "Give Gems (1k each)",
    Default = false,
    Callback = function(state)
        SettingsMain.GiveGems = state
    end,
})

ExploitsGroup1:AddToggle("GivePet", {
    Text = "Give SpinWheel Pet",
    Default = false,
    Callback = function(state)
        SettingsMain.GiveSpinWhalePet = state
    end,
})

ExploitsGroup1:AddToggle("StartLoopOfItem", {
    Text = "Start Loop",
    Callback = function(value)
        SettingsMain.GiveItemLoop = value
    end,
})


ExploitsGroup1:AddDropdown("Itemss", {
    Values = { "gems", "spin", "Pet", "PickAxe", "Op Pet", "100000000" },
    Default = "spin",
    Text = "Select item to give yourself",
    Callback = function(value)
        SettingsMain.GiveItemname = value
        if value == "Op Pet" then
            SettingsMain.GiveSpinWhalePet = true
        else
            SettingsMain.GiveSpinWhalePet = false
        end
    end,
})

ExploitsGroup:AddDropdown("MoneyAmount", {
    Values = { "1000", "10000", "100000", "1000000", "10000000", "100000000","999999999999999999999"},
    Default = "1000",
    Text = "Select Money Amount",
    Callback = function(value)
        SettingsMain.GiveMoneyAmount = tonumber(value)
    end,
})

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

Library:SetDPIScale(100)
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("PickScriptHub")
SaveManager:SetFolder("PickScriptHub/DigToEarth")
SaveManager:SetSubFolder("dig-to-earth")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

task.spawn(function()
    while task.wait() do
        if SettingsMain.AutohatchEggs then
            local eggPath = Workspace:FindFirstChild(SettingsMain.SelectedWorld)
            if eggPath then
                local prompts = eggPath:FindFirstChild("Prompts")
                if prompts then
                    local eggs = prompts:FindFirstChild("Eggs")
                    if eggs then
                        local selectedEgg = eggs:FindFirstChild(SettingsMain.SelectedEgg)
                        if selectedEgg then
                            ReplicatedStorage.PetRemotes.HatchServer:InvokeServer(selectedEgg)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if SettingsMain.AutoDig then
            ReplicatedStorage.Remotes.DigEvent:FireServer()
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if SettingsMain.AutoCollectTreasure then
            for _, model in ipairs(workspace.Treasure:GetChildren()) do
                if model:IsA("Model") then
                    ReplicatedStorage.Remotes.TreasureEvent:FireServer(model.Name)
                end
            end
        end
    end
end)


task.spawn(function()
    while task.wait() do
        if SettingsMain.AutoGoldPets then
            ReplicatedStorage.PetRemotes.GoldPetCraftEvent:FireServer(SettingsMain.Petname, SettingsMain.AutoGoldChance)
            task.wait()
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if SettingsMain.AutoDiamondPets then
            ReplicatedStorage.PetRemotes.DiamondPetCraftEvent:FireServer(SettingsMain.Petname, SettingsMain.AutoDiamondChance)
            task.wait()
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if SettingsMain.GiveMoney then
            ReplicatedStorage.Remotes.AddRewardEvent:FireServer("Cash", SettingsMain.GiveMoneyAmount)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if SettingsMain.GiveGems then
            ReplicatedStorage.Remotes.GemEvent:FireServer(SettingsMain.GiveGemsAmount)
        end
    end
end)


task.spawn(function()
    while task.wait() do 
        if SettingsMain.GiveSpinWhalePet then 
            game:GetService("ReplicatedStorage").Remotes.SpinPrizeEvent:FireServer(4)
        end 
    end
end)


task.spawn(function()
    while task.wait() do
        if SettingsMain.GiveItemLoop then
            local item = SettingsMain.GiveItemname
            local amount = 1
            if item == "gems" then
                amount = 1000
                item = "gems"
            elseif item == "spin" then
                amount = 1
                item = "spin"
            elseif item == "Pet" then
                amount = 1
                item = "Pet"
            elseif item == "PickAxe" then
                amount = 1
                item = "PickAxe"
            elseif item == "Op Pet" then
                amount = 1
                item = "Pet"
            elseif item == "100000000" then
                amount = 100000000
                item = "gems"
            end
            if item == "spin" then
                game:GetService("ReplicatedStorage").Remotes.SpinPrizeEvent:FireServer(amount)
            else
                game:GetService("ReplicatedStorage").Remotes.AddRewardEvent:FireServer(item, amount)
            end
        end
    end
end)


task.spawn(function()
    while task.wait() do
        if SettingsMain.AutohatchEggs then
            local eggPath = Workspace:FindFirstChild(SettingsMain.SelectedWorld)
            if eggPath then
                local prompts = eggPath:FindFirstChild("Prompts")
                if prompts then
                    local eggs = prompts:FindFirstChild("Eggs")
                    if eggs then
                        local selectedEgg = eggs:FindFirstChild(SettingsMain.SelectedEgg)
                        if selectedEgg then
                            ReplicatedStorage.PetRemotes.Hatch3Pets:InvokeServer(selectedEgg)
                        end
                    end
                end
            end
        end
    end
end)
