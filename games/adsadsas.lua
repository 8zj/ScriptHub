-- // --- PICK | AUTO STRATEGY FULL INTEGRATED --- //

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

-- // --- FULL SCRIPT LOGIC --- //

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

local send_request = request or http_request or httprequest or (GetDevice and GetDevice().request)
if not send_request then AddLog("Failure: No HTTP Function", Color3.new(1, 0, 0)) end

local replicated_storage = game:GetService("ReplicatedStorage")
local remote_func = replicated_storage:WaitForChild("RemoteFunction")
local remote_event = replicated_storage:WaitForChild("RemoteEvent")
local players_service = game:GetService("Players")
local local_player = players_service.LocalPlayer or players_service.PlayerAdded:Wait()
local player_gui = local_player:WaitForChild("PlayerGui")

local back_to_lobby_running, auto_snowballs_running, auto_skip_running = false, false, false

local ItemNames = {
    ["17447507910"] = "Timescale Ticket(s)", ["17438486690"] = "Range Flag(s)",
    ["17438486138"] = "Damage Flag(s)", ["17438487774"] = "Cooldown Flag(s)",
    ["17429537022"] = "Blizzard(s)", ["17448596749"] = "Napalm Strike(s)",
    ["18493073533"] = "Spin Ticket(s)", ["17429548305"] = "Supply Drop(s)",
    ["18443277308"] = "Low Grade Consumable Crate(s)", ["136180382135048"] = "Santa Radio(s)",
    ["18443277106"] = "Mid Grade Consumable Crate(s)", ["132155797622156"] = "Christmas Tree(s)",
    ["124065875200929"] = "Fruit Cake(s)", ["17429541513"] = "Barricade(s)",
}

local start_coins, current_total_coins, start_gems, current_total_gems = 0, 0, 0, 0
if game_state == "GAME" then
    pcall(function()
        repeat task.wait(1) until local_player:FindFirstChild("Coins")
        start_coins = local_player.Coins.Value; current_total_coins = start_coins
        start_gems = local_player.Gems.Value; current_total_gems = start_gems
    end)
end

local function check_res_ok(data)
    if data == true then return true end
    if type(data) == "table" and data.Success == true then return true end
    local success, is_model = pcall(function() return data and data:IsA("Model") end)
    if success and is_model then return true end
    return type(data) == "userdata"
end

local function get_all_rewards()
    local results = { Coins = 0, Gems = 0, XP = 0, Time = "00:00", Status = "UNKNOWN", Others = {} }
    local ui_root = player_gui:FindFirstChild("ReactGameNewRewards")
    local main_frame = ui_root and ui_root:FindFirstChild("Frame")
    local rewards_screen = main_frame and main_frame:FindFirstChild("gameOver") and main_frame.gameOver:FindFirstChild("RewardsScreen")
    
    if rewards_screen then
        local stats_list = rewards_screen:FindFirstChild("gameStats") and rewards_screen.gameStats:FindFirstChild("stats")
        if stats_list then
            for _, frame in ipairs(stats_list:GetChildren()) do
                local l1, l2 = frame:FindFirstChild("textLabel"), frame:FindFirstChild("textLabel2")
                if l1 and l2 and l1.Text:find("Time Completed:") then results.Time = l2.Text break end
            end
        end
        local top_banner = rewards_screen:FindFirstChild("RewardBanner")
        if top_banner and top_banner:FindFirstChild("textLabel") then
            local txt = top_banner.textLabel.Text:upper()
            results.Status = txt:find("TRIUMPH") and "WIN" or (txt:find("LOST") and "LOSS" or "UNKNOWN")
        end
        local section = rewards_screen:FindFirstChild("RewardsSection")
        if section then
            for _, item in ipairs(section:GetChildren()) do
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
                                table.insert(results.Others, {Amount = text:match("x%d+"), Name = ItemNames[icon_id] or "Item " .. icon_id})
                            end
                        end
                    end
                end
            end
        end
    end
    return results
end

local function send_to_lobby()
    AddLog("Teleporting to Lobby...", Color3.fromRGB(255, 100, 100))
    task.wait(1)
    pcall(function() game.ReplicatedStorage.Network.Teleport["RE:backToLobby"]:FireServer() end)
end

local function handle_post_match()
    local ui_root
    repeat task.wait(1)
        local root = player_gui:FindFirstChild("ReactGameNewRewards")
        ui_root = root and root:FindFirstChild("Frame") and root.Frame:FindFirstChild("gameOver")
    until ui_root
    
    AddLog("Match Finished. Processing Rewards...", ACCENT_COLOR)
    local match = get_all_rewards()
    current_total_coins += match.Coins; current_total_gems += match.Gems

    if _G.SendWebhook then
        local bonus_string = ""
        for _, res in ipairs(match.Others) do bonus_string = bonus_string .. "🎁 **" .. res.Amount .. " " .. res.Name .. "**\n" end
        if bonus_string == "" then bonus_string = "_None_" end

        local post_data = {
            username = "TDS AutoStrat",
            embeds = {{
                title = (match.Status == "WIN" and "🏆 TRIUMPH" or "💀 DEFEAT"),
                color = (match.Status == "WIN" and 0x2ecc71 or 0xe74c3c),
                description = "### Overview\n> Status: `" .. match.Status .. "`\n> Time: `" .. match.Time .. "`",
                fields = {
                    { name = "✨ Rewards", value = "```ansi\nCoins: " .. match.Coins .. "\nGems: " .. match.Gems .. "\nXP: " .. match.XP .. "```", inline = false },
                    { name = "🎁 Bonus Items", value = bonus_string, inline = true },
                    { name = "📊 Totals", value = "```py\nCoins: " .. current_total_coins .. "\nGems: " .. current_total_gems .. "```", inline = true }
                },
                footer = { text = "Logged for " .. local_player.Name },
                timestamp = DateTime.now():ToIsoDate()
            }}
        }
        pcall(function()
            send_request({ Url = _G.Webhook, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = game:GetService("HttpService"):JSONEncode(post_data) })
        end)
    end
    send_to_lobby()
end

-- // Tower Control Core
local TDS = { placed_towers = {}, active_strat = true }
local upgrade_history = {}

function TDS:Place(t_name, px, py, pz)
    if game_state ~= "GAME" then return false end
    AddLog("Placing " .. t_name .. "...", ACCENT_COLOR)
    local existing = {}
    for _, child in ipairs(workspace.Towers:GetChildren()) do existing[child] = true end
    
    repeat
        local ok, res = pcall(function()
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
    AddLog("Success: #" .. #self.placed_towers .. " " .. t_name, Color3.new(1,1,1))
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
        upgrade_history[idx] = (upgrade_history[idx] or 0) + 1
    end
end

function TDS:Sell(idx)
    local t = self.placed_towers[idx]
    if t then
        AddLog("Selling #" .. idx, Color3.fromRGB(255, 80, 80))
        repeat
            local ok, res = pcall(function() return remote_func:InvokeServer("Troops", "Sell", { Troop = t }) end)
            task.wait(0.2)
        until ok and check_res_ok(res)
        table.remove(self.placed_towers, idx)
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
    local speed_list = {0, 0.5, 1, 1.5, 2}
    -- Cycle logic as requested...
    task.spawn(function()
        for i=1, 4 do 
            remote_func:InvokeServer("TicketsManager", "CycleTimeScale") 
            task.wait(0.5) 
        end
    end)
end

-- // --- MAIN LOOPS --- //

task.spawn(function() -- Auto Skip Loop
    while true do
        if _G.AutoSkip then
            local skip_v = player_gui:FindFirstChild("ReactOverridesVote", true)
            if skip_v then TDS:VoteSkip() task.wait(5) end
        end
        task.wait(1)
    end
end)

task.spawn(function() -- Back to Lobby/Post Match
    while true do
        pcall(handle_post_match)
        task.wait(5)
    end
end)

AddLog("Pick Strategy Ready", Color3.new(1,1,1))
return TDS
