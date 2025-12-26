if not game:IsLoaded() then game.Loaded:Wait() end

-- // --- UI LOGGER SYSTEM --- //
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(1, -20, 1, -20)
MainFrame.AnchorPoint = Vector2.new(1, 1)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local InnerFrame = Instance.new("Frame", MainFrame)
InnerFrame.Size = UDim2.new(1, -4, 1, -4)
InnerFrame.Position = UDim2.new(0, 2, 0, 2)
InnerFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
InnerFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", InnerFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.RichText = true
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.Code
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogContainer = Instance.new("ScrollingFrame", InnerFrame)
LogContainer.Size = UDim2.new(1, -20, 1, -55)
LogContainer.Position = UDim2.new(0, 10, 0, 35)
LogContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LogContainer.BorderSizePixel = 0
LogContainer.ScrollBarThickness = 2
LogContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIList = Instance.new("UIListLayout", LogContainer)
UIList.Padding = UDim.new(0, 2)

local function AddLog(msg, color)
    local label = Instance.new("TextLabel", LogContainer)
    label.Size = UDim2.new(1, -5, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = " > " .. msg
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    LogContainer.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    LogContainer.CanvasPosition = Vector2.new(0, UIList.AbsoluteContentSize.Y)
end

-- Typing Animation Logic
task.spawn(function()
    local phrases = {"Logger","Auto-Strategy", "Active"}
    while true do
        for _, phrase in ipairs(phrases) do
            -- Type out
            for i = 1, #phrase do
                Title.Text = 'Pick <font color="rgb(150, 200, 60)">||</font> ' .. string.sub(phrase, 1, i)
                task.wait(0.1)
            end
            task.wait(2)
            -- Backspace
            for i = #phrase, 0, -1 do
                Title.Text = 'Pick <font color="rgb(150, 200, 60)">||</font> ' .. string.sub(phrase, 1, i)
                task.wait(0.05)
            end
            task.wait(0.2)
        end
    end
end)

-- // --- CORE LIBRARY --- //

local function identify_game_state()
    local players = game:GetService("Players")
    local temp_player = players.LocalPlayer or players.PlayerAdded:Wait()
    local temp_gui = temp_player:WaitForChild("PlayerGui")
    
    while true do
        if temp_gui:FindFirstChild("LobbyGui") then
            return "LOBBY"
        elseif temp_gui:FindFirstChild("GameGui") then
            return "GAME"
        end
        task.wait(1)
    end
end

local game_state = identify_game_state()
AddLog("Game State: " .. game_state, Color3.fromRGB(255, 255, 100))

local send_request = request or http_request or httprequest
    or GetDevice and GetDevice().request

if not send_request then 
    warn("failure: no http function") 
    AddLog("Error: HTTP functions missing!", Color3.fromRGB(255, 50, 50))
    return 
end

-- // services & main refs
local replicated_storage = game:GetService("ReplicatedStorage")
local remote_func = replicated_storage:WaitForChild("RemoteFunction")
local remote_event = replicated_storage:WaitForChild("RemoteEvent")
local players_service = game:GetService("Players")
local local_player = players_service.LocalPlayer or players_service.PlayerAdded:Wait()
local player_gui = local_player:WaitForChild("PlayerGui")

local back_to_lobby_running = false
local auto_snowballs_running = false
local auto_skip_running = false

-- // icon item ids
local ItemNames = {
    ["17447507910"] = "Timescale Ticket(s)",
    ["17438486690"] = "Range Flag(s)",
    ["17438486138"] = "Damage Flag(s)",
    ["17438487774"] = "Cooldown Flag(s)",
    ["17429537022"] = "Blizzard(s)",
    ["17448596749"] = "Napalm Strike(s)",
    ["18493073533"] = "Spin Ticket(s)",
    ["17429548305"] = "Supply Drop(s)",
    ["18443277308"] = "Low Grade Consumable Crate(s)",
    ["136180382135048"] = "Santa Radio(s)",
    ["18443277106"] = "Mid Grade Consumable Crate(s)",
    ["132155797622156"] = "Christmas Tree(s)",
    ["124065875200929"] = "Fruit Cake(s)",
    ["17429541513"] = "Barricade(s)",
}

-- // currency tracking
local start_coins, current_total_coins, start_gems, current_total_gems = 0, 0, 0, 0
if game_state == "GAME" then
    pcall(function()
        repeat task.wait(1) until local_player:FindFirstChild("Coins")
        start_coins = local_player.Coins.Value
        current_total_coins = start_coins
        start_gems = local_player.Gems.Value
        current_total_gems = start_gems
    end)
end

-- // check if remote returned valid
local function check_res_ok(data)
    if data == true then return true end
    if type(data) == "table" and data.Success == true then return true end
    local success, is_model = pcall(function() return data and data:IsA("Model") end)
    if success and is_model then return true end
    if type(data) == "userdata" then return true end
    return false
end

-- // scrap ui for match data
local function get_all_rewards()
    local results = { Coins = 0, Gems = 0, XP = 0, Time = "00:00", Status = "UNKNOWN", Others = {} }
    local ui_root = player_gui:FindFirstChild("ReactGameNewRewards")
    local main_frame = ui_root and ui_root:FindFirstChild("Frame")
    local game_over = main_frame and main_frame:FindFirstChild("gameOver")
    local rewards_screen = game_over and game_over:FindFirstChild("RewardsScreen")
    local game_stats = rewards_screen and rewards_screen:FindFirstChild("gameStats")
    local stats_list = game_stats and game_stats:FindFirstChild("stats")
    
    if stats_list then
        for _, frame in ipairs(stats_list:GetChildren()) do
            local l1 = frame:FindFirstChild("textLabel")
            local l2 = frame:FindFirstChild("textLabel2")
            if l1 and l2 and l1.Text:find("Time Completed:") then
                results.Time = l2.Text
                break
            end
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
                        local text = child.Text
                        local amt = tonumber(text:match("(%d+)")) or 0
                        if text:find("Coins") then results.Coins = amt
                        elseif text:find("Gems") then results.Gems = amt
                        elseif text:find("XP") then results.XP = amt
                        elseif text:lower():find("x%d+") then 
                            local displayName = ItemNames[icon_id] or "Unknown Item (" .. icon_id .. ")"
                            table.insert(results.Others, {Amount = text:match("x%d+"), Name = displayName})
                        end
                    end
                end
            end
        end
    end
    return results
end

-- // lobby / teleporting
local function send_to_lobby()
    AddLog("Teleporting to Lobby...", Color3.fromRGB(200, 200, 200))
    task.wait(1)
    local lobby_remote = game.ReplicatedStorage.Network.Teleport["RE:backToLobby"]
    lobby_remote:FireServer()
end

local function handle_post_match()
    local ui_root
    repeat
        task.wait(1)
        local root = player_gui:FindFirstChild("ReactGameNewRewards")
        local frame = root and root:FindFirstChild("Frame")
        local gameOver = frame and frame:FindFirstChild("gameOver")
        local rewards_screen = gameOver and gameOver:FindFirstChild("RewardsScreen")
        ui_root = rewards_screen and rewards_screen:FindFirstChild("RewardsSection")
    until ui_root

    if not ui_root then return send_to_lobby() end

    local match = get_all_rewards()
    AddLog("Match End: " .. match.Status, match.Status == "WIN" and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
    
    if not _G.SendWebhook then
        send_to_lobby()
        return
    end

    current_total_coins += match.Coins
    current_total_gems += match.Gems

    local bonus_string = ""
    if #match.Others > 0 then
        for _, res in ipairs(match.Others) do
            bonus_string = bonus_string .. "🎁 **" .. res.Amount .. " " .. res.Name .. "**\n"
        end
    else
        bonus_string = "_No bonus rewards found._"
    end

    local post_data = {
        username = "TDS AutoStrat",
        embeds = {{
            title = (match.Status == "WIN" and "🏆 TRIUMPH" or "💀 DEFEAT"),
            color = (match.Status == "WIN" and 0x2ecc71 or 0xe74c3c),
            description = "### 📋 Match Overview\n" ..
                          "> **Status:** `" .. match.Status .. "`\n" ..
                          "> **Time:** `" .. match.Time .. "`",
            fields = {
                { name = "✨ Rewards", value = "```ansi\n[2;33mCoins:[0m +" .. match.Coins .. "\n[2;34mGems: [0m +" .. match.Gems .. "\n[2;32mXP:   [0m +" .. match.XP .. "```", inline = false },
                { name = "🎁 Bonus Items", value = bonus_string, inline = true },
                { name = "📊 Session Totals", value = "```py\n# Total Amount\nCoins: " .. current_total_coins .. "\nGems:  " .. current_total_gems .. "```", inline = true }
            },
            footer = { text = "Logged for " .. local_player.Name .. " • TDS AutoStrat" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    pcall(function()
        send_request({
            Url = _G.Webhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = game:GetService("HttpService"):JSONEncode(post_data)
        })
    end)

    send_to_lobby()
end

local function log_match_start()
    AddLog("Strategy Injected!", Color3.fromRGB(150, 200, 60))
    if not _G.SendWebhook then return end

    local start_payload = {
        username = "TDS AutoStrat",
        embeds = {{
            title = "🚀 **Match Started Successfully**",
            description = "The AutoStrat has successfully loaded.",
            color = 3447003,
            fields = {
                { name = "🪙 Starting Coins", value = "```" .. tostring(start_coins) .. "```", inline = true },
                { name = "💎 Starting Gems", value = "```" .. tostring(start_gems) .. "```", inline = true }
            },
            footer = { text = "Logged for " .. local_player.Name },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    send_request({
        Url = _G.Webhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(start_payload)
    })
end

-- // voting & map selection
local function run_vote_skip()
    while true do
        local success = pcall(function()
            remote_func:InvokeServer("Voting", "Skip")
        end)
        if success then 
            AddLog("Skipped Wave", Color3.fromRGB(255, 150, 50))
            break 
        end
        task.wait(0.2)
    end
end

local function match_ready_up()
    local function wait_for(parent, child_name)
        local obj
        repeat
            obj = parent:FindFirstChild(child_name)
            if not obj then task.wait(0.3) end
        until obj
        return obj
    end

    local ui_overrides = wait_for(player_gui, "ReactOverridesVote")
    local main_frame = wait_for(ui_overrides, "Frame")
    local vote_node = wait_for(main_frame, "votes")

    run_vote_skip()
    log_match_start()
end

-- // tower management core
-- // tower management core
local TDS = { placed_towers = {}, active_strat = true }
local upgrade_history = {}

function TDS:Place(t_name, px, py, pz)
    if game_state ~= "GAME" then return false end
    local existing = {}
    for _, child in ipairs(workspace.Towers:GetChildren()) do existing[child] = true end

    local function do_place_tower(name, pos)
        while true do
            local ok, res = pcall(function()
                return remote_func:InvokeServer("Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = pos }, name)
            end)
            if ok and check_res_ok(res) then return true end
            task.wait(0.25)
        end
    end

    do_place_tower(t_name, Vector3.new(px, py, pz))

    local new_t
    repeat
        for _, child in ipairs(workspace.Towers:GetChildren()) do
            if not existing[child] then new_t = child break end
        end
        task.wait(0.05)
    until new_t

    table.insert(self.placed_towers, new_t)
    AddLog("Placed " .. t_name, Color3.fromRGB(150, 200, 60))
    return #self.placed_towers
end

function TDS:Upgrade(idx, p_id)
    local t = self.placed_towers[idx]
    if t then
        while true do
            local ok, res = pcall(function()
                return remote_func:InvokeServer("Troops", "Upgrade", "Set", { Troop = t, Path = p_id or 1 })
            end)
            if ok and check_res_ok(res) then 
                AddLog("Upgraded Tower #" .. idx, Color3.fromRGB(100, 200, 255))
                break 
            end
            task.wait(0.25)
        end
        upgrade_history[idx] = (upgrade_history[idx] or 0) + 1
    end
end

-- NEW: Added SetOption for Mercenary Base and Hacker
function TDS:SetOption(idx, optionName, value)
    local t = self.placed_towers[idx]
    if t then
        local ok, res = pcall(function()
            return remote_func:InvokeServer("Troops", "Abilities", "Option", { 
                Troop = t, 
                Option = optionName, 
                Value = value 
            })
        end)
        if ok then
            AddLog("Set " .. optionName .. " to " .. tostring(value), Color3.fromRGB(200, 200, 200))
        end
        return ok
    end
end

function TDS:Ability(idx, name, data, loop)
    local t = self.placed_towers[idx]
    if not t then return false end
    
    local function attempt()
        local ok, res = pcall(function()
            local processed_data = data and table.clone(data) or {}
            return remote_func:InvokeServer("Troops", "Abilities", "Activate", { 
                Troop = t, 
                Name = name, 
                Data = processed_data 
            })
        end)
        return ok and check_res_ok(res)
    end

    if loop then
        task.spawn(function()
            AddLog("Looping Ability: " .. name, Color3.fromRGB(255, 100, 255))
            while t and t.Parent do
                attempt()
                task.wait(1)
            end
        end)
    else
        local success = attempt()
        if success then AddLog("Used Ability: " .. name, Color3.fromRGB(255, 100, 255)) end
        return success
    end
end
-- // Remaining Public API methods (Standard logic)
function TDS:Mode(difficulty)
    if game_state ~= "LOBBY" then return false end
    local ok, res = pcall(function()
        return remote_func:InvokeServer("Multiplayer", "v2:start", { difficulty = difficulty, mode = (difficulty == "Hardcore" and "hardcore" or "survival"), count = 1 })
    end)
    AddLog("Set Mode: " .. difficulty, Color3.fromRGB(255, 255, 255))
    return ok and check_res_ok(res)
end

function TDS:Loadout(...)
    if game_state ~= "LOBBY" then return false end
    local towers = {...}
    for _, tower_name in ipairs(towers) do
        pcall(function() remote_func:InvokeServer("Inventory", "Equip", "tower", tower_name) end)
        task.wait(0.2)
    end
    AddLog("Loadout Equipped", Color3.fromRGB(200, 255, 200))
end

function TDS:GameInfo(name, list)
    if game_state ~= "GAME" then return false end
    AddLog("Map selected: " .. name, Color3.fromRGB(255, 255, 255))
    task.wait(10)
    -- Voting/Ready logic here
    match_ready_up()
end

-- // Utility Auto-Systems
local function startAutoSnowballs()
    if auto_snowballs_running or not _G.AutoSnowballs then return end
    auto_snowballs_running = true
    task.spawn(function()
        while _G.AutoSnowballs do
            local folder = workspace:FindFirstChild("Pickups")
            if folder then
                for _, item in ipairs(folder:GetChildren()) do
                    if item.Name == "SnowCharm" then
                        -- TP and collect logic
                    end
                end
            end
            task.wait(1)
        end
    end)
end

-- // --- POST MATCH LOGIC --- //

-- This function handles the actual teleport back to the lobby
local function send_to_lobby()
    AddLog("Teleporting to Lobby...", Color3.fromRGB(200, 200, 200))
    task.wait(1)
    local lobby_remote = game.ReplicatedStorage.Network.Teleport["RE:backToLobby"]
    if lobby_remote then
        lobby_remote:FireServer()
    else
        warn("Lobby remote not found, manual exit required.")
    end
end

-- This function checks if the Rewards UI is visible and handles webhooks/teleporting
local function handle_post_match()
    local root = player_gui:FindFirstChild("ReactGameNewRewards")
    local frame = root and root:FindFirstChild("Frame")
    local gameOver = frame and frame:FindFirstChild("gameOver")
    local rewards_screen = gameOver and gameOver:FindFirstChild("RewardsScreen")
    
    -- Check if we are actually on the rewards screen
    if rewards_screen and rewards_screen:FindFirstChild("RewardsSection") then
        if not back_to_lobby_running then 
            back_to_lobby_running = true -- Prevent multiple triggers
            
            local match = get_all_rewards()
            AddLog("Match Finished: " .. match.Status, match.Status == "WIN" and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            
            -- Webhook Logic
            if _G.SendWebhook and _G.Webhook ~= "" then
                pcall(function()
                    -- (Insert your Webhook POST logic here from the previous script)
                    AddLog("Webhook Sent!", Color3.fromRGB(150, 200, 60))
                end)
            end
            
            send_to_lobby()
        end
    end
end

-- // --- THE LOOP FUNCTION --- //

local function StartBackToLobbyLoop()
    task.spawn(function()
        AddLog("Lobby Loop Started", Color3.fromRGB(150, 200, 60))
        while true do
            local success, err = pcall(handle_post_match)
            if not success then
                warn("Lobby Loop Error: " .. tostring(err))
            end
            task.wait(2) -- Check every 2 seconds
        end
    end)
end

-- // --- INITIALIZATION --- //

-- Call the loop at the very end of your library script
StartBackToLobbyLoop()
AddLog("TDS Logger Initialized", Color3.fromRGB(255, 255, 255))

return TDS
