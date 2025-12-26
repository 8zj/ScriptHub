-- // --- PICK | AUTO STRATEGY FULL INTEGRATED V2 --- //

-- // UI Configuration
local ACCENT_COLOR = Color3.fromRGB(150, 200, 60)
local BG_COLOR = Color3.fromRGB(10, 10, 10)
local HEADER_COLOR = Color3.fromRGB(20, 20, 20)

-- // UI Build
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
if not success_ui then ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

MainFrame.Name = "PickLogger"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.Position = UDim2.new(1, -20, 1, -20); MainFrame.AnchorPoint = Vector2.new(1, 1); MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Active = true; MainFrame.Draggable = true 

MainCorner.CornerRadius = UDim.new(0, 6); MainCorner.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(40, 40, 40); MainStroke.Thickness = 1; MainStroke.Parent = MainFrame

Header.Name = "Header"; Header.Parent = MainFrame; Header.BackgroundColor3 = HEADER_COLOR; Header.Size = UDim2.new(1, 0, 0, 35); Header.BorderSizePixel = 0
Title.Parent = Header; Title.BackgroundTransparency = 1; Title.Size = UDim2.new(1, 0, 1, 0); Title.Font = Enum.Font.Code; Title.RichText = true
Title.Text = '<font color="rgb(150, 200, 60)"><b> PICK </b></font> <font color="rgb(100, 100, 100)">|</font> <font color="rgb(255, 255, 255)">Auto Strategy</font>'
Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Center

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

-- // --- MAIN SCRIPT --- //

if not game:IsLoaded() then game.Loaded:Wait() end

local function identify_game_state()
    local players = game:GetService("Players")
    local temp_player = players.LocalPlayer or players.PlayerAdded:Wait()
    local temp_gui = temp_player:WaitForChild("PlayerGui")
    while true do
        if temp_gui:FindFirstChild("LobbyGui") then return "LOBBY"
        elseif temp_gui:FindFirstChild("GameGui") then return "GAME" end
        task.wait(1)
    end
end

local game_state = identify_game_state()
AddLog("Detected State: " .. game_state, Color3.new(1, 1, 1))

local replicated_storage = game:GetService("ReplicatedStorage")
local remote_func = replicated_storage:WaitForChild("RemoteFunction")
local remote_event = replicated_storage:WaitForChild("RemoteEvent")
local players_service = game:GetService("Players")
local local_player = players_service.LocalPlayer or players_service.PlayerAdded:Wait()
local player_gui = local_player:WaitForChild("PlayerGui")

local TDS = { placed_towers = {}, active_strat = true }

-- // --- HELPER FUNCTIONS --- //

local function check_res_ok(data)
    if data == true then return true end
    if type(data) == "table" and data.Success == true then return true end
    local success, is_model = pcall(function() return data and data:IsA("Model") end)
    if success and is_model then return true end
    return type(data) == "userdata"
end

local function get_current_wave()
    local success, label = pcall(function() return player_gui:WaitForChild("ReactGameTopGameDisplay").Frame.wave.container.value end)
    if not success then return 0 end
    local wave_num = label.Text:match("^(%d+)")
    return tonumber(wave_num) or 0
end

-- // --- ATTACHING ALL API METHODS --- //

function TDS:Loadout(...)
    if game_state ~= "LOBBY" then return false end
    local towers = {...}
    AddLog("Equipping Loadout...", ACCENT_COLOR)
    for _, tower_name in ipairs(towers) do
        if tower_name and tower_name ~= "" then
            pcall(function() remote_func:InvokeServer("Inventory", "Equip", "tower", tower_name) end)
            task.wait(0.3)
        end
    end
end

function TDS:Mode(difficulty)
    if game_state ~= "LOBBY" then return false end
    AddLog("Selecting Mode: " .. difficulty, ACCENT_COLOR)
    local ok, res = pcall(function()
        if difficulty == "Hardcore" then
            return remote_func:InvokeServer("Multiplayer", "v2:start", {mode = "hardcore", count = 1})
        else
            return remote_func:InvokeServer("Multiplayer", "v2:start", {difficulty = difficulty, mode = "survival", count = 1})
        end
    end)
    return ok and check_res_ok(res)
end

function TDS:Place(t_name, px, py, pz)
    if game_state ~= "GAME" then return false end
    AddLog("Placing " .. t_name .. "...", ACCENT_COLOR)
    local existing = {}
    for _, child in ipairs(workspace.Towers:GetChildren()) do existing[child] = true end
    
    local ok, res
    repeat
        ok, res = pcall(function()
            return remote_func:InvokeServer("Troops", "Pl\208\176ce", {Rotation = CFrame.new(), Position = Vector3.new(px, py, pz)}, t_name)
        end)
        task.wait(0.3)
    until ok and check_res_ok(res)

    local new_t
    repeat
        for _, child in ipairs(workspace.Towers:GetChildren()) do
            if not existing[child] then new_t = child break end
        end
        task.wait(0.05)
    until new_t
    table.insert(self.placed_towers, new_t)
    AddLog("Placed Tower #" .. #self.placed_towers, Color3.new(1,1,1))
    return #self.placed_towers
end

function TDS:Upgrade(idx, p_id)
    local t = self.placed_towers[idx]
    if t then
        AddLog("Upgrading #" .. idx .. " Path " .. (p_id or 1), Color3.fromRGB(100, 180, 255))
        repeat
            local ok, res = pcall(function() return remote_func:InvokeServer("Troops", "Upgrade", "Set", {Troop = t, Path = p_id or 1}) end)
            task.wait(0.2)
        until ok and check_res_ok(res)
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

function TDS:SetTarget(idx, target_type)
    local t = self.placed_towers[idx]
    if t then
        AddLog("Targeting #" .. idx .. " -> " .. target_type, Color3.fromRGB(200, 200, 200))
        remote_func:InvokeServer("Troops", "Target", "Set", {Troop = t, Target = target_type})
    end
end

function TDS:Ability(idx, ab_name, ab_data, is_looping)
    local t_obj = self.placed_towers[idx]
    if not t_obj then return end
    AddLog("Ability: " .. ab_name .. " on #" .. idx, Color3.fromRGB(200, 100, 255))

    local function attempt()
        local data = type(ab_data) == "table" and table.clone(ab_data) or nil
        if data then
            if data.towerPosition then data.towerPosition = data.towerPosition[math.random(#data.towerPosition)] end
            if data.towerToClone then data.towerToClone = TDS.placed_towers[data.towerToClone] end
            if data.towerTarget then data.towerTarget = TDS.placed_towers[data.towerTarget] end
        end
        return pcall(function() return remote_func:InvokeServer("Troops", "Abilities", "Activate", {Troop = t_obj, Name = ab_name, Data = data}) end)
    end

    if is_looping then
        task.spawn(function() while t_obj.Parent do attempt() task.wait(1) end end)
    else
        attempt()
    end
end

function TDS:VoteSkip()
    AddLog("Skipping Wave...", Color3.fromRGB(255, 200, 50))
    pcall(function() remote_func:InvokeServer("Voting", "Skip") end)
end

function TDS:TimeScale(val)
    AddLog("Setting Speed: x" .. val, ACCENT_COLOR)
    task.spawn(function()
        for i=1, 4 do 
            remote_func:InvokeServer("TicketsManager", "CycleTimeScale") 
            task.wait(0.5) 
        end
    end)
end

function TDS:AutoChain(...)
    local tower_indices = {...}
    if #tower_indices == 0 then return end
    AddLog("AutoChain Enabled", ACCENT_COLOR)
    local running = true
    task.spawn(function()
        local i = 1
        while running do
            local tower = self.placed_towers[tower_indices[i]]
            if tower then pcall(function() remote_func:InvokeServer("Troops", "Abilities", "Activate", {Troop = tower, Name = "Call to Arms"}) end) end
            task.wait(local_player.TimescaleTickets.Value >= 1 and 5.5 or 10.5)
            i = (i % #tower_indices) + 1
        end
    end)
    return function() running = false end
end

-- // --- BACKGROUND LOOPS --- //

task.spawn(function() -- Auto Skip
    while true do
        if _G.AutoSkip then
            local skip_v = player_gui:FindFirstChild("ReactOverridesVote", true)
            if skip_v then TDS:VoteSkip() task.wait(5) end
        end
        task.wait(1)
    end
end)

AddLog("Pick Strategy Ready", Color3.new(1,1,1))
return TDS
