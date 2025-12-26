-- // --- PICK | AUTO STRATEGY: THE COMPLETE DEFINITIVE EDITION --- //

-- // --- UI CONFIGURATION --- //
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

-- // --- CORE SCRIPT START --- //

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
AddLog("State Detected: " .. game_state, Color3.new(1,1,1))

local send_request = request or http_request or httprequest or (GetDevice and GetDevice().request)
if not send_request then warn("failure: no http function") end

-- // Services & Refs
local replicated_storage = game:GetService("ReplicatedStorage")
local remote_func = replicated_storage:WaitForChild("RemoteFunction")
local remote_event = replicated_storage:WaitForChild("RemoteEvent")
local players_service = game:GetService("Players")
local local_player = players_service.LocalPlayer or players_service.PlayerAdded:Wait()
local player_gui = local_player:WaitForChild("PlayerGui")

local back_to_lobby_running = false
local auto_snowballs_running = false
local auto_skip_running = false

local ItemNames = {
    ["17447507910"] = "Timescale Ticket(s)", ["17438486690"] = "Range Flag(s)",
    ["17438486138"] = "Damage Flag(s)", ["17438487774"] = "Cooldown Flag(s)",
    ["17429537022"] = "Blizzard(s)", ["17448596749"] = "Napalm Strike(s)",
    ["18493073533"] = "Spin Ticket(s)", ["17429548305"] = "Supply Drop(s)",
    ["18443277308"] = "Low Grade Consumable Crate(s)", ["136180382135048"] = "Santa Radio(s)",
    ["18443277106"] = "Mid Grade Consumable Crate(s)", ["132155797622156"] = "Christmas Tree(s)",
    ["124065875200929"] = "Fruit Cake(s)", ["17429541513"] = "Barricade(s)",
}

-- // Currency Tracking
local start_coins, current_total_coins, start_gems, current_total_gems = 0, 0, 0, 0
if game_state == "GAME" then
    pcall(function()
        repeat task.wait(1) until local_player:FindFirstChild("Coins")
        start_coins = local_player.Coins.Value; current_total_coins = start_coins
        start_gems = local_player.Gems.Value; current_total_gems = start_gems
    end)
end

-- // Remote Check
local function check_res_ok(data)
    if data == true then return true end
    if type(data) == "table" and data.Success == true then return true end
    local success, is_model = pcall(function() return data and data:IsA("Model") end)
    if success and is_model then return true end
    return type(data) == "userdata"
end

-- // Reward Scraper
local function get_all_rewards()
    local results = { Coins = 0, Gems = 0, XP = 0, Time = "00:00", Status = "UNKNOWN", Others = {} }
    local ui_root = player_gui:FindFirstChild("ReactGameNewRewards")
    local main_frame = ui_root and ui_root:FindFirstChild("Frame")
    local game_over = main_frame and main_frame:FindFirstChild("gameOver")
    local rewards_screen = game_over and game_over:FindFirstChild("RewardsScreen")
    
    local stats_list = rewards_screen and rewards_screen:FindFirstChild("gameStats") and rewards_screen.gameStats:FindFirstChild("stats")
    if stats_list then
        for _, frame in ipairs(stats_list:GetChildren()) do
            local l1, l2 = frame:FindFirstChild("textLabel"), frame:FindFirstChild("textLabel2")
            if l1 and l2 and l1.Text:find("Time Completed:") then results.Time = l2.Text break end
        end
    end

    local top_banner = rewards_screen and rewards_screen:FindFirstChild("RewardBanner")
    if top_banner and top_banner:FindFirstChild("textLabel") then
        local txt = top_banner.textLabel.Text:upper()
        results.Status = txt:find("TRIUMPH") and "WIN" or (txt:find("LOST") and "LOSS" or "UNKNOWN")
    end

    local section_rewards = rewards_screen and rewards_screen:FindFirstChild("RewardsSection")
    if section_rewards then
        for _, item in ipairs(section_rewards:GetChildren()) do
            if tonumber(item.Name) then 
                local icon_id = "0"
                local img = item:FindFirstChildWhichIsA("ImageLabel", true)
                if img then icon_id = img.Image:match("%d+") or "0" end
                for _, child in ipairs(item:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        local text, amt = child.Text, tonumber(child.Text:match("(%d+)")) or 0
                        if text:find("Coins") then results.Coins = amt
                        elseif text:find("Gems") then results.Gems = amt
                        elseif text:find("XP") then results.XP = amt
                        elseif text:lower():find("x%d+") then 
                            table.insert(results.Others, {Amount = text:match("x%d+"), Name = ItemNames[icon_id] or "Unknown ("..icon_id..")"})
                        end
                    end
                end
            end
        end
    end
    return results
end

-- // Lobby Logic
local function send_to_lobby()
    AddLog("Match Ended. Returning to Lobby.", ACCENT_COLOR)
    task.wait(1)
    pcall(function() game.ReplicatedStorage.Network.Teleport["RE:backToLobby"]:FireServer() end)
end

local function handle_post_match()
    local ui_root
    repeat task.wait(1)
        local root = player_gui:FindFirstChild("ReactGameNewRewards")
        local frame = root and root:FindFirstChild("Frame")
        local gOver = frame and frame:FindFirstChild("gameOver")
        local rScreen = gOver and gOver:FindFirstChild("RewardsScreen")
        ui_root = rScreen and rScreen:FindFirstChild("RewardsSection")
    until ui_root
    
    if not _G.SendWebhook then send_to_lobby() return end

    local match = get_all_rewards()
    current_total_coins += match.Coins; current_total_gems += match.Gems

    local bonus_string = ""
    for _, res in ipairs(match.Others) do bonus_string = bonus_string .. "🎁 **" .. res.Amount .. " " .. res.Name .. "**\n" end
    if bonus_string == "" then bonus_string = "_None_" end

    local post_data = {
        username = "TDS AutoStrat",
        embeds = {{
            title = (match.Status == "WIN" and "🏆 TRIUMPH" or "💀 DEFEAT"),
            color = (match.Status == "WIN" and 0x2ecc71 or 0xe74c3c),
            description = "### Match Overview\n> Status: `" .. match.Status .. "`\n> Time: `" .. match.Time .. "`",
            fields = {
                { name = "✨ Rewards", value = "```ansi\nCoins: " .. match.Coins .. "\nGems: " .. match.Gems .. "\nXP: " .. match.XP .. "```", inline = false },
                { name = "🎁 Bonus Items", value = bonus_string, inline = true },
                { name = "📊 Session Totals", value = "```py\nCoins: " .. current_total_coins .. "\nGems: " .. current_total_gems .. "```", inline = true }
            },
            footer = { text = "Logged for " .. local_player.Name },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    pcall(function()
        send_request({ Url = _G.Webhook, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = game:GetService("HttpService"):JSONEncode(post_data) })
    end)
    send_to_lobby()
end

local function log_match_start()
    if not _G.SendWebhook then return end
    local start_payload = {
        username = "TDS AutoStrat",
        embeds = {{
            title = "🚀 **Match Started**",
            color = 3447003,
            fields = {
                { name = "🪙 Starting Coins", value = "```" .. tostring(start_coins) .. "```", inline = true },
                { name = "💎 Starting Gems", value = "```" .. tostring(start_gems) .. "```", inline = true }
            },
            footer = { text = "Logged for " .. local_player.Name },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    pcall(function() send_request({ Url = _G.Webhook, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = game:GetService("HttpService"):JSONEncode(start_payload) }) end)
end

-- // Voting & Map Utility
local function run_vote_skip()
    pcall(function() remote_func:InvokeServer("Voting", "Skip") end)
end

local function match_ready_up()
    AddLog("Match Ready. Skipping Initial Vote.", ACCENT_COLOR)
    run_vote_skip()
    log_match_start()
end

local function cast_map_vote(map_id, pos_vec)
    remote_event:FireServer("LobbyVoting", "Vote", map_id or "Simplicity", pos_vec or Vector3.new(0,0,0))
end

local function lobby_ready_up()
    remote_event:FireServer("LobbyVoting", "Ready")
end

local function select_map_override(map_id)
    AddLog("Overriding Map: " .. map_id, ACCENT_COLOR)
    remote_func:InvokeServer("LobbyVoting", "Override", map_id)
    task.wait(3)
    cast_map_vote(map_id, Vector3.new(12.59, 10.64, 52.01))
    task.wait(1)
    lobby_ready_up()
    task.wait(15)
    match_ready_up()
end

local function cast_modifier_vote(mods_table)
    local bulk = replicated_storage:WaitForChild("Network"):WaitForChild("Modifiers"):WaitForChild("RF:BulkVoteModifiers")
    pcall(function() bulk:InvokeServer(mods_table or {}) end)
end

-- // Timescale
local function set_game_timescale(target_val)
    local speed_list = {0, 0.5, 1, 1.5, 2}
    local speed_label = player_gui.ReactUniversalHotbar.Frame.timescale.Speed
    local current_val = tonumber(speed_label.Text:match("x([%d%.]+)"))
    if not current_val then return end
    
    local target_idx, current_idx
    for i, v in ipairs(speed_list) do if v == target_val then target_idx = i end if v == current_val then current_idx = i end end
    if not target_idx or not current_idx then return end
    
    local diff = target_idx - current_idx
    if diff < 0 then diff = #speed_list + diff end
    for _ = 1, diff do
        replicated_storage.RemoteFunction:InvokeServer("TicketsManager", "CycleTimeScale")
        task.wait(0.5)
    end
end

local function unlock_speed_tickets()
    if local_player.TimescaleTickets.Value >= 1 then
        if player_gui.ReactUniversalHotbar.Frame.timescale.Lock.Visible then
            replicated_storage.RemoteFunction:InvokeServer('TicketsManager', 'UnlockTimeScale')
        end
    end
end

-- // --- TOWER CORE --- //
local TDS = { placed_towers = {}, active_strat = true }
local upgrade_history = {}

function TDS:Mode(difficulty)
    if game_state ~= "LOBBY" then return end
    AddLog("Setting Mode: " .. difficulty, Color3.fromRGB(200, 200, 200))
    local args = difficulty == "Hardcore" and {mode = "hardcore", count = 1} or {difficulty = difficulty, mode = "survival", count = 1}
    pcall(function() remote_func:InvokeServer("Multiplayer", "v2:start", args) end)
end

function TDS:Loadout(...)
    if game_state ~= "LOBBY" then return end
    AddLog("Equipping Loadout...", ACCENT_COLOR)
    for _, tower in ipairs({...}) do
        pcall(function() remote_func:InvokeServer("Inventory", "Equip", "tower", tower) end)
        task.wait(0.5)
    end
end

function TDS:GameInfo(name, list)
    if game_state ~= "GAME" then return end
    task.wait(15); cast_modifier_vote(list); select_map_override(name)
end

function TDS:Place(t_name, px, py, pz)
    if game_state ~= "GAME" then return end
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
    AddLog("Placed #" .. #self.placed_towers .. " (" .. t_name .. ")", Color3.new(1,1,1))
    return #self.placed_towers
end

function TDS:Upgrade(idx, p_id)
    local t = self.placed_towers[idx]
    if t then
        AddLog("Upgrading #" .. idx, Color3.fromRGB(100, 180, 255))
        repeat
            local ok, res = pcall(function() return remote_func:InvokeServer("Troops", "Upgrade", "Set", {Troop = t, Path = p_id or 1}) end)
            task.wait(0.2)
        until ok and check_res_ok(res)
    end
end

function TDS:Ability(idx, name, ab_data, loop)
    local t = self.placed_towers[idx]
    if not t then return end
    AddLog("Ability: " .. name .. " on #" .. idx, Color3.fromRGB(200, 100, 255))
    
    local function fire()
        local data = type(ab_data) == "table" and table.clone(ab_data) or nil
        if data then
            if data.towerPosition then data.towerPosition = data.towerPosition[math.random(#data.towerPosition)] end
            if data.towerToClone then data.towerToClone = self.placed_towers[data.towerToClone] end
            if data.towerTarget then data.towerTarget = self.placed_towers[data.towerTarget] end
        end
        pcall(function() remote_func:InvokeServer("Troops", "Abilities", "Activate", {Troop = t, Name = name, Data = data}) end)
    end

    if loop then task.spawn(function() while t.Parent do fire(); task.wait(1) end end) else fire() end
end

function TDS:AutoChain(...)
    local list = {...}
    AddLog("AutoChain Enabled", ACCENT_COLOR)
    local active = true
    task.spawn(function()
        local i = 1
        while active do
            local tower = self.placed_towers[list[i]]
            if tower then pcall(function() remote_func:InvokeServer("Troops", "Abilities", "Activate", {Troop = tower, Name = "Call to Arms"}) end) end
            task.wait(local_player.TimescaleTickets.Value >= 1 and 5.5 or 10.5)
            i = (i % #list) + 1
        end
    end)
    return function() active = false end
end

function TDS:Sell(idx)
    local t = self.placed_towers[idx]
    if t then
        AddLog("Selling #" .. idx, Color3.fromRGB(255, 80, 80))
        pcall(function() remote_func:InvokeServer("Troops", "Sell", { Troop = t }) end)
        table.remove(self.placed_towers, idx)
    end
end

function TDS:VoteSkip() run_vote_skip() end
function TDS:TimeScale(v) set_game_timescale(v) end
function TDS:Ready() match_ready_up() end
function TDS:TeleportToLobby() send_to_lobby() end

-- // --- BACKGROUND LOOPS --- //
task.spawn(function()
    while true do
        if _G.AutoSkip then
            local skip_v = player_gui:FindFirstChild("ReactOverridesVote", true)
            if skip_v and skip_v:FindFirstChild("Frame") then run_vote_skip(); task.wait(5) end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while _G.AutoSnowballs do
        pcall(function()
            local folder = workspace:FindFirstChild("Pickups")
            local hrp = local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart")
            if folder and hrp then
                for _, item in ipairs(folder:GetChildren()) do
                    if item.Name == "SnowCharm" and math.abs(item.Position.Y) < 1000 then
                        local old = hrp.CFrame
                        hrp.CFrame = item.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.2); hrp.CFrame = old; task.wait(0.3)
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

task.spawn(function() while true do pcall(handle_post_match) task.wait(5) end end)

AddLog("Pick Strategy Fully Loaded", Color3.new(1,1,1))
return TDS
