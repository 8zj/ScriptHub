-- // --- PICK | AUTO STRATEGY: THE COMPLETE DEFINITIVE EDITION --- //
-- // Includes: Skeet Watermark, Typing Header, Webhooks, and Tower API

-- // --- SKEET WATERMARK (TOP-LEFT) --- //
local player = game:GetService("Players").LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local stats = game:GetService("Stats")
local http = game:GetService("HttpService")

if pGui:FindFirstChild("SkeetWatermark") then pGui.SkeetWatermark:Destroy() end

local WM_Gui = Instance.new("ScreenGui")
WM_Gui.Name = "SkeetWatermark"; WM_Gui.Parent = pGui

local WM_Frame = Instance.new("Frame")
WM_Frame.Name = "MainFrame"; WM_Frame.Parent = WM_Gui
WM_Frame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
WM_Frame.BorderSizePixel = 1; WM_Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
WM_Frame.Position = UDim2.new(0, 20, 0, 20)
WM_Frame.Size = UDim2.new(0, 200, 0, 26)

local WM_GradientLine = Instance.new("Frame")
WM_GradientLine.Name = "GradientLine"; WM_GradientLine.Parent = WM_Frame
WM_GradientLine.BackgroundColor3 = Color3.new(1, 1, 1); WM_GradientLine.BorderSizePixel = 0
WM_GradientLine.Size = UDim2.new(1, 0, 0, 2)

local WM_UIGradient = Instance.new("UIGradient")
WM_UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})
WM_UIGradient.Parent = WM_GradientLine

local WM_Content = Instance.new("TextLabel")
WM_Content.Parent = WM_Frame; WM_Content.BackgroundTransparency = 1
WM_Content.Size = UDim2.new(1, -10, 1, 0); WM_Content.Position = UDim2.new(0, 8, 0, 1)
WM_Content.Font = Enum.Font.Code; WM_Content.TextColor3 = Color3.fromRGB(255, 255, 255)
WM_Content.TextSize = 13; WM_Content.TextXAlignment = Enum.TextXAlignment.Left

-- Rainbow Animation
task.spawn(function()
    local counter = 0
    while true do
        counter = counter + 0.01
        WM_UIGradient.Offset = Vector2.new(math.sin(counter), 0)
        task.wait(0.01)
    end
end)

-- Stats Loop
task.spawn(function()
    while task.wait(0.5) do
        local fps = math.floor(workspace:GetRealPhysicsFPS())
        local ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        WM_Content.Text = string.format("pick.lua | %s | v2.1 | %dfps | %dms", player.Name:lower(), fps, ping)
        WM_Frame.Size = UDim2.new(0, WM_Content.TextBounds.X + 20, 0, 26)
    end
end)

-- // --- UI CONFIGURATION & TYPING EFFECT --- //
local ACCENT_COLOR = Color3.fromRGB(150, 200, 60)
local BG_COLOR = Color3.fromRGB(10, 10, 10)
local HEADER_COLOR = Color3.fromRGB(20, 20, 20)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
local MainStroke = Instance.new("UIStroke")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local LogContainer = Instance.new("ScrollingFrame")
local UIList = Instance.new("UIListLayout")
local UIPadding = Instance.new("UIPadding")

local success_ui = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success_ui then ScreenGui.Parent = pGui end

MainFrame.Name = "PickLogger"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.Position = UDim2.new(1, -20, 1, -20); MainFrame.AnchorPoint = Vector2.new(1, 1); MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Active = true; MainFrame.Draggable = true 

MainCorner.CornerRadius = UDim.new(0, 6); MainCorner.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(40, 40, 40); MainStroke.Thickness = 1; MainStroke.Parent = MainFrame

Header.Name = "Header"; Header.Parent = MainFrame; Header.BackgroundColor3 = HEADER_COLOR; Header.Size = UDim2.new(1, 0, 0, 35); Header.BorderSizePixel = 0
Title.Parent = Header; Title.BackgroundTransparency = 1; Title.Size = UDim2.new(1, 0, 1, 0); Title.Font = Enum.Font.Code; Title.RichText = true
Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Center

-- Typing Effect with Backspace to "A"
task.spawn(function()
    local prefix = '<font color="rgb(150, 200, 60)"><b> PICK </b></font> <font color="rgb(100, 100, 100)">|</font> '
    local fullText = "Auto Strategy"
    while true do
        for i = 1, #fullText do
            Title.Text = prefix .. '<font color="rgb(255, 255, 255)">' .. fullText:sub(1, i) .. '</font>_'
            task.wait(0.15)
        end
        task.wait(1.5)
        for i = #fullText, 2, -1 do
            Title.Text = prefix .. '<font color="rgb(255, 255, 255)">' .. fullText:sub(1, i) .. '</font>_'
            task.wait(0.08)
        end
        for _ = 1, 3 do
            Title.Text = prefix .. '<font color="rgb(255, 255, 255)">A</font>_'
            task.wait(0.5)
            Title.Text = prefix .. '<font color="rgb(255, 255, 255)">A</font> '
            task.wait(0.5)
        end
    end
end)

LogContainer.Name = "LogContainer"; LogContainer.Parent = MainFrame; LogContainer.BackgroundTransparency = 1; LogContainer.Position = UDim2.new(0, 0, 0, 40); LogContainer.Size = UDim2.new(1, 0, 1, -45)
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 0); LogContainer.ScrollBarThickness = 2; LogContainer.ScrollBarImageColor3 = ACCENT_COLOR
UIList.Parent = LogContainer; UIList.SortOrder = Enum.SortOrder.LayoutOrder; UIList.Padding = UDim.new(0, 2)
UIPadding.Parent = LogContainer; UIPadding.PaddingLeft = UDim.new(0, 12); UIPadding.PaddingRight = UDim.new(0, 12)

local function AddLog(text, color)
    local LogEntry = Instance.new("TextLabel")
    LogEntry.Parent = LogContainer; LogEntry.BackgroundTransparency = 1; LogEntry.Size = UDim2.new(1, 0, 0, 18)
    LogEntry.Font = Enum.Font.Code; LogEntry.RichText = true
    LogEntry.Text = string.format('<font color="rgb(150, 200, 60)">></font> %s', tostring(text))
    LogEntry.TextColor3 = color or Color3.fromRGB(210, 210, 210)
    LogEntry.TextSize = 11; LogEntry.TextXAlignment = Enum.TextXAlignment.Left
    task.wait() 
    LogContainer.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    LogContainer.CanvasPosition = Vector2.new(0, LogContainer.CanvasSize.Y.Offset)
end

-- // --- CORE SCRIPT START --- //
if not game:IsLoaded() then game.Loaded:Wait() end

local replicated_storage = game:GetService("ReplicatedStorage")
local remote_func = replicated_storage:WaitForChild("RemoteFunction")
local remote_event = replicated_storage:WaitForChild("RemoteEvent")
local players_service = game:GetService("Players")
local local_player = players_service.LocalPlayer or players_service.PlayerAdded:Wait()

local function identify_game_state()
    local temp_gui = local_player:WaitForChild("PlayerGui")
    while true do
        if temp_gui:FindFirstChild("LobbyGui") then return "LOBBY"
        elseif temp_gui:FindFirstChild("GameGui") then return "GAME" end
        task.wait(1)
    end
end

local game_state = identify_game_state()
AddLog("State Detected: " .. game_state, Color3.new(1,1,1))

local send_request = request or http_request or httprequest or (GetDevice and GetDevice().request)

-- // --- TOWER CORE API --- //
local TDS = { placed_towers = {}, active_strat = true }

function TDS:Mode(difficulty)
    if game_state ~= "LOBBY" then return end
    AddLog("Setting Mode: " .. difficulty, Color3.fromRGB(200, 200, 200))
    local args = difficulty == "Hardcore" and {mode = "hardcore", count = 1} or {difficulty = difficulty, mode = "survival", count = 1}
    pcall(function() remote_func:InvokeServer("Multiplayer", "v2:start", args) end)
end

function TDS:Place(t_name, px, py, pz)
    AddLog("Placing " .. t_name, ACCENT_COLOR)
    local existing = {}
    for _, child in ipairs(workspace.Towers:GetChildren()) do existing[child] = true end
    repeat
        pcall(function() remote_func:InvokeServer("Troops", "Pl\208\176ce", {Rotation = CFrame.new(), Position = Vector3.new(px, py, pz)}, t_name) end)
        task.wait(0.3)
    until #workspace.Towers:GetChildren() > #TDS.placed_towers
    local new_t
    for _, child in ipairs(workspace.Towers:GetChildren()) do if not existing[child] then new_t = child break end end
    table.insert(self.placed_towers, new_t)
    return #self.placed_towers
end

function TDS:Upgrade(idx, p_id)
    local t = self.placed_towers[idx]
    if t then
        AddLog("Upgrading #" .. idx, Color3.fromRGB(100, 180, 255))
        pcall(function() remote_func:InvokeServer("Troops", "Upgrade", "Set", {Troop = t, Path = p_id or 1}) end)
    end
end

function TDS:Sell(idx)
    local t = self.placed_towers[idx]
    if t then
        AddLog("Selling #" .. idx, Color3.fromRGB(255, 80, 80))
        pcall(function() remote_func:InvokeServer("Troops", "Sell", { Troop = t }) end)
        table.remove(self.placed_towers, idx)
    end
end

function TDS:Ability(idx, name, data, loop)
    local t = self.placed_towers[idx]
    if t then
        local fire = function() pcall(function() remote_func:InvokeServer("Troops", "Abilities", "Activate", {Troop = t, Name = name, Data = data}) end) end
        if loop then task.spawn(function() while t.Parent do fire(); task.wait(1) end end) else fire() end
    end
end

-- // --- BACKGROUND SYSTEMS --- //
task.spawn(function() -- Auto Skip
    while true do
        if _G.AutoSkip then
            pcall(function() remote_func:InvokeServer("Voting", "Skip") end)
        end
        task.wait(2)
    end
end)

task.spawn(function() -- Snowball Farm
    while true do
        if _G.AutoSnowballs then
            local pickups = workspace:FindFirstChild("Pickups")
            local hrp = local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart")
            if pickups and hrp then
                for _, item in ipairs(pickups:GetChildren()) do
                    if item.Name == "SnowCharm" then
                        local old = hrp.CFrame
                        hrp.CFrame = item.CFrame; task.wait(0.1); hrp.CFrame = old
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- Rewards & Webhooks
task.spawn(function()
    while true do
        local ui = pGui:FindFirstChild("ReactGameNewRewards")
        if ui and ui.Enabled then
            AddLog("Match Conclusion Detected", ACCENT_COLOR)
            task.wait(5)
            remote_event:FireServer("Teleport", "BackToLobby")
        end
        task.wait(5)
    end
end)

AddLog("Pick Strategy Full v2.1 Loaded", Color3.new(1,1,1))
return TDS
