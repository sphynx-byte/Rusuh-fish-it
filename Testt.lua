local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesess/WindUI/main/Main.lua"))()
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Run = game:GetService("RunService")

-- [[ STATE ASLI ]] --
local Fly = false
local Stalk = false
local TargetPlayer = nil
local Speed = 40
local Alt = 20
local Up, Down = false, false
local LastLook = Vector3.new(0,0,1)

-- [[ WEBHOOK LOGGER ASLI ]] --
local WEBHOOK = "https://discord.com/api/webhooks/1485503062532689991/QbEgmFTj_lN6qxQ7aIpoen8h5cLScPgHtqOhYJ5rvyCsIlC68LfiHDvCmEYA48YuiKay"
local startTime = os.time()
local joinTimeFormatted = os.date("%H:%M:%S")
local messageId

local function formatTime(sec)
    return string.format("%02d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
end

local function getGameName()
    local success, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
    return success and info.Name or "Unknown"
end

local function buildPayload(status, leaveTime)
    local profileUrl = "https://www.roblox.com/users/" .. LP.UserId .. "/profile"
    local gameName = getGameName()
    local jobId = game.JobId
    local serverUrl = "https://www.roblox.com/games/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. jobId

    return {
        username = "Player Logger",
        embeds = {{
            title = "Roblox Player Activity - Sphyn Hub Rusuh",
            url = profileUrl,
            color = status == "JOIN" and 0x00FF00 or status == "LEAVE" and 0xFF0000 or 0x00AAFF,
            fields = {
                {name = "Username", value = "[" .. LP.Name .. "](" .. profileUrl .. ")", inline = true},
                {name = "UserId", value = "```" .. LP.UserId .. "```", inline = true},
                {name = "Status", value = "```" .. status .. "```", inline = true},
                {name = "Game", value = "```" .. gameName .. "```", inline = false},
                {name = "Place ID", value = "```" .. game.PlaceId .. "```", inline = true},
                {name = "JobId", value = "```" .. jobId .. "```", inline = true},
                {name = "Server URL", value = serverUrl, inline = false},
                {name = "Account Age", value = "```" .. LP.AccountAge .. " days```", inline = true},    
                {name = "Join Time", value = "```" .. joinTimeFormatted .. "```", inline = true},
                {name = "Leave Time", value = "```" .. (leaveTime or "-") .. "```", inline = true},
                {name = "Uptime", value = "```" .. formatTime(os.time() - startTime) .. "```", inline = false}
            },
            footer = {text = "Sphyn Hub Logger"},
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
end

local function sendWebhook(status, leaveTime)
    local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not request then return end
    local success, res = pcall(function()
        return request({
            Url = WEBHOOK .. "?wait=true",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(buildPayload(status, leaveTime))
        })
    end)
    if success and res and res.Body then
        local data = HttpService:JSONDecode(res.Body)
        messageId = data.id
    end
end

local function editWebhook()
    local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not messageId or not request then return end
    pcall(function()
        request({
            Url = WEBHOOK .. "/messages/" .. messageId,
            Method = "PATCH",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(buildPayload("ONLINE"))
        })
    end)
end

-- [[ WIND UI SETUP ]] --
local Window = WindUI:CreateWindow({
    Title = "Sphyn Hub - Fish It",
    Icon = "fish",
    Author = "Bintang Kresna",
    Folder = "SphynHubConfig"
})

local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateSection("CONTROLS")

MainTab:CreateToggle({
    Title = "FLY",
    Value = false,
    Callback = function(state)
        Fly = state
        if Fly and LP.Character and LP.Character.Humanoid.SeatPart then 
            Alt = LP.Character.Humanoid.SeatPart.Position.Y 
        end
    end
})

MainTab:CreateToggle({
    Title = "STALKING",
    Value = false,
    Callback = function(state)
        Stalk = state
    end
})

MainTab:CreateSection("SETTINGS")

MainTab:CreateSlider({
    Title = "Speed",
    Min = 0,
    Max = 200,
    Default = 40,
    Callback = function(value)
        Speed = value
    end
})

MainTab:CreateSection("PLAYER LIST")

local PlayerDropdown = MainTab:CreateDropdown({
    Title = "Select Target",
    Multi = false,
    Options = {},
    Callback = function(selected)
        TargetPlayer = Players:FindFirstChild(selected)
    end
})

local function UpdateList()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(names, p.Name) end
    end
    PlayerDropdown:Refresh(names)
end
UpdateList()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)

MainTab:CreateSection("ALTITUDE")
MainTab:CreateButton({ Title = "UP (▲)", Callback = function() Alt = Alt + 5 end })
MainTab:CreateButton({ Title = "DOWN (▼)", Callback = function() Alt = Alt - 5 end })

-- [[ LOGIKA GERAK ASLI (TIDAK DIUBAH) ]] --
Run.Stepped:Connect(function()
    local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local seat = (hum and hum.SeatPart)
    if seat and Fly then
        seat.AssemblyLinearVelocity = Vector3.zero; seat.AssemblyAngularVelocity = Vector3.zero
        for _, p in pairs(seat.Parent:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false; p.Velocity = Vector3.zero end end
        local moveDir = hum.MoveDirection
        if Stalk and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            seat.Anchored = false; local tRoot = TargetPlayer.Character.HumanoidRootPart
            seat.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 7, 0)) * tRoot.CFrame.Rotation
        elseif moveDir.Magnitude > 0 or Up or Down then
            seat.Anchored = false
            if Up then Alt = Alt + (Speed/30) end if Down then Alt = Alt - (Speed/30) end
            local nextPos = seat.Position + (moveDir * Speed / 15)
            if moveDir.Magnitude > 0 then LastLook = moveDir end
            seat.CFrame = CFrame.new(nextPos.X, Alt, nextPos.Z) * CFrame.lookAt(Vector3.zero, LastLook).Rotation
        else
            seat.Anchored = true 
            seat.CFrame = CFrame.new(seat.Position.X, Alt, seat.Position.Z) * CFrame.lookAt(Vector3.zero, LastLook).Rotation
        end
    elseif seat and not Fly then seat.Anchored = false end
end)

-- [[ INISIALISASI LOGGER ]] --
task.spawn(function()
    sendWebhook("JOIN")
    local interval = 60
    while task.wait(interval) do
        if not messageId then break end
        editWebhook()
    end
end)

game:BindToClose(function()
    local leaveTimeFormatted = os.date("%H:%M:%S")
    sendWebhook("LEAVE", leaveTimeFormatted)
end)

WindUI:Notify({ Title = "Sphyn Hub", Content = "Loaded Successfully", Duration = 3 })
