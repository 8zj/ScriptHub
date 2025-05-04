--[[
										This script was made for funs.
	noting to much will plan to update more.				Will Mostlikey be patched
											Made By Pick

]]

local repo = "https://raw.githubusercontent.com/8zj/Uis/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false 
Library.ShowToggleFrameInKeybinds = true


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RemoteEvent = ReplicatedStorage:WaitForChild("RE")
local oreFolder = workspace:WaitForChild("Upgrades"):WaitForChild("Mining"):WaitForChild("Ore")
local mined = {}
local camera = workspace.CurrentCamera

local Window = Library:CreateWindow({
	Title = "[ Pet Incremental ]",
	Footer = "version: 1",
	NotifySide = "Right",
	ShowCustomCursor = false,
})



local MainSettings = {
	--Auto Upgrade Stuff Shit ( Not to good lol )
    AutoUpgrade = false,
    UpgradeName = nil,


	--Gem Upgrade 
	AutoUpgradeGem = false,
	UpgradeNameGem = nil,

	-- Evolve Settings.
	AutoEvale = false,
	DelayEvolve = 1,

	--Auto Farming Toggles.
    AutoEuped = false,
    AutoRankUp = false,
    AutoEgg = false,
	autofarmEnabled = false,
	AutoFarmPlasma = false,

	--Runes Farming
	AutoFarmRunes = false,
	NameOfRunes = "Rune1"
}

local Tabs = {
	Main = Window:AddTab("Main", "user"),
	ExploitsTab = Window:AddTab("AutoFarm", "shield-alert"),
	UISettings = Window:AddTab("UI Settings", "settings"),
}
local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Upgrades")
local GemUpgrade = Tabs.Main:AddRightGroupbox("Gem Upgrades")
local EvolveTab = Tabs.Main:AddLeftGroupbox("Evolve")
local Autofarming = Tabs.ExploitsTab:AddLeftGroupbox("Auto Farm Ores")
local AutoFarmRunes = Tabs.ExploitsTab:AddRightGroupbox("Auto Open Runes")


GemUpgrade:AddDropdown("UpgradeName", {
    Text = "Pick Ur Upgrade",
    Values = {"GemMulti","CoinMulti","MoreGems","PetEquip","CoinSpeed","PetClone"},
    Default = nil,
    AllowNull = true,
    Callback = function(Value)
        MainSettings.UpgradeName = Value
        print("Selected:", Value)
    end,
})


GemUpgrade:AddToggle("MyToggle", {
    Text = "Auto Buy Upgrade",
    Tooltip = "Will auto buy selected GemUpgrade",
    Default = false,
    Callback = function(Value)
        MainSettings.AutoUpgrade = Value
        if MainSettings.AutoUpgrade then
            spawn(function()
                while MainSettings.AutoUpgrade do
                    task.wait()
                    if MainSettings.UpgradeName then
                        game:GetService("ReplicatedStorage").RE:FireServer("GemUpgrade", MainSettings.UpgradeName)
                    end
                end
            end)
        end
    end,
})

AutoFarmRunes:AddDropdown("UpgradeName", {
    Text = "Pick Runes",
    Values = {"Rune1","Rune2"},
    Default = nil,
    AllowNull = true,
    Callback = function(Value)
        MainSettings.NameOfRunes = Value
    end,
})

AutoFarmRunes:AddToggle("MyToggle", {
    Text = "Auto Buy Runes",
    Tooltip = "Will Auto Open Runes",
    DisabledTooltip = "",
    Default = false,
    Visible = true,
    Callback = function(Value)
        MainSettings.AutoFarmRunes = Value
        if MainSettings.AutoFarmRunes then
            spawn(function()
                while MainSettings.AutoFarmRunes do
                    task.wait()
					local ohString1 = "Rune"
					local ohString2 = MainSettings.NameOfRunes
					game:GetService("ReplicatedStorage").RE:FireServer(ohString1, ohString2)
                end
            end)
        end
    end,
})





RunService.Stepped:Connect(function()
    if MainSettings.autofarmEnabled and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local function getOrePart(ore)
    if ore:IsA("Model") then
        if ore.PrimaryPart then
            return ore.PrimaryPart
        else
            for _, part in ipairs(ore:GetDescendants()) do
                if part:IsA("BasePart") then
                    return part
                end
            end
        end
    elseif ore:IsA("BasePart") then
        return ore
    end
end


local function toggleAutofarm(Value)
    MainSettings.autofarmEnabled = Value
    if MainSettings.autofarmEnabled then
        MainSettings.originalPosition = Character:FindFirstChild("HumanoidRootPart").Position

        spawn(function()
            while MainSettings.autofarmEnabled do
                for _, oreModel in ipairs(oreFolder:GetChildren()) do
                    if (oreModel:IsA("Model") or oreModel:IsA("Part")) and not mined[oreModel] then
                        local orePart = getOrePart(oreModel)
                        if orePart and Character:FindFirstChild("HumanoidRootPart") then
                            mined[oreModel] = true
                            Character:MoveTo(orePart.Position + Vector3.new(0, 0.25, 0))
                            for i = 1, 10 do
                                RemoteEvent:FireServer("Mine", oreModel.Name)
                                task.wait()
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    else
        if MainSettings.originalPosition then
            Character:MoveTo(MainSettings.originalPosition)
        end
    end
end



Autofarming:AddToggle("AutoFarmToggle", {
    Text = "Auto Farm",
    Tooltip = "Automatically farm ores when enabled.",
    DisabledTooltip = "Disables autofarming.",
    Default = false,
    Visible = true,
    Callback = function(Value)
        toggleAutofarm(Value)
    end,
})

Autofarming:AddToggle("AutoFarmToggle", {
    Text = "Auto Plasma",
    Tooltip = "Automatically farm Plasma when enabled.",
    DisabledTooltip = "Disables autofarming.",
    Default = false,
    Visible = true,
    Callback = function(Value)
    MainSettings.AutoFarmPlasma = Value
	while MainSettings.AutoFarmPlasma == true do
		task.wait()
		local ohString1 = "Plasma"
		local ohBoolean2 = true
		game:GetService("ReplicatedStorage").RE:FireServer(ohString1, ohBoolean2)
		end
    end,
})

LeftGroupBox:AddDropdown("UpgradeName", {
    Text = "Pick Ur Upgrade",
    Values = {"CoinMulti", "EggSpeed", "EggLuck", "PetEquip", "PetStorage", "EggClone"},
    Default = nil,
    AllowNull = true,
    Callback = function(Value)
        MainSettings.UpgradeName = Value
    end,
})


LeftGroupBox:AddToggle("MyToggle", {
    Text = "Auto Buy Upgrade",
    Tooltip = "Will auto buy upgrades",
    Default = false,
    Callback = function(Value)
        MainSettings.AutoUpgrade = Value
        if MainSettings.AutoUpgrade then
            spawn(function()
                while MainSettings.AutoUpgrade do
                    task.wait()
                    if MainSettings.UpgradeName then
                        game:GetService("ReplicatedStorage").RE:FireServer("GemUpgrade", MainSettings.UpgradeName)
                        print("Upgrading:", MainSettings.UpgradeName)
                    end
                end
            end)
        end
    end,
})




LeftGroupBox:AddToggle("MyToggle", {
	Text = "Auto Equip Best",
	Tooltip = "",
	DisabledTooltip = "",
	Default = false,
	Visible = true,
	Callback = function(Value)
	MainSettings.AutoEuped = Value
	if MainSettings.AutoEuped == true then
		while true do 
			task.wait()
			local ohString1 = "EquipBest"
			game:GetService("ReplicatedStorage").RE:FireServer(ohString1)
			task.wait()
			end
		end
	end,
})


EvolveTab:AddSlider("MySlider", {
    Text = "Auto evolve delay",
    Default = 1,
    Min = 0,
    Max = 20,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        MainSettings.DelayEvolve = Value
    end,
    Tooltip = "Time Delay",
    DisabledTooltip = "I am disabled!",
    Disabled = false,
    Visible = true,
})

EvolveTab:AddToggle("MyToggle", {
    Text = "Auto Evolve [ All ]",
    Tooltip = "",
    DisabledTooltip = "",
    Default = false,
    Visible = true,
    Callback = function(Value)
        MainSettings.AutoEvale = Value
        if MainSettings.AutoEvale then
            spawn(function()
                while MainSettings.AutoEvale do
                    task.wait(MainSettings.DelayEvolve)
                    local ohString1 = "EvolveAll"
                    game:GetService("ReplicatedStorage").RE:FireServer(ohString1)
                end
            end)
        end
    end,
})



local MenuGroup = Tabs.UISettings:AddLeftGroupbox("Menu")
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
Library:SetDPIScale(75)
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
	AutoUpgrade = false
    UpgradeName = "CoinMulti"
	AutoUpgradeGem = false
	UpgradeNameGem = "GemMulti"
	AutoEvale = false
	DelayEvolve = 1
    AutoEuped = false
    AutoRankUp = false
    AutoEgg = false
	autofarmEnabled = false
	AutoFarmPlasma = false
	AutoFarmRunes = false
	NameOfRunes = "Rune1"
end)

Library.ToggleKeybind = Options.MenuKeybind
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("PetIncremental")
SaveManager:SetFolder("PetIncremental/MainHub")
SaveManager:SetSubFolder("PetIncremental")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
