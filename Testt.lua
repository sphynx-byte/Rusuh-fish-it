local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Run = game:GetService("RunService")

-- [[ STATE ]] --
local Fly = false
local Stalk = false
local TargetPlayer = nil
local Speed = 40
local Alt = 20
local Up, Down = false, false
local LastLook = Vector3.new(0,0,1)

-- [[ WINDOW SETUP ]] --
local Window = WindUI:CreateWindow({
    Title = "Sphyn Hub - Fish It",
    Icon = "ghost", 
    Author = "Bintang Kresna", --
    Folder = "SphynHubConfig"
})

local MainTab = Window:CreateTab("Main", "home")

-- [[ SECTION: MOVEMENT ]] --
MainTab:CreateSection("Flight Controls")

MainTab:CreateToggle({
    Title = "Flight Mode (Fly)",
    Value = false,
    Callback = function(state)
        Fly = state
        if Fly and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum.SeatPart then 
                Alt = hum.SeatPart.Position.Y 
            end
        end
    end
})

MainTab:CreateSlider({
    Title = "Fly Speed",
    Min = 10,
    Max = 300,
    Default = 40,
    Callback = function(value)
        Speed = value
    end
})

-- [[ SECTION: STALKING ]] --
MainTab:CreateSection("Targeting")

local PlayerDropdown = MainTab:CreateDropdown({
    Title = "Select Target",
    Multi = false,
    Options = {},
    Callback = function(selected)
        TargetPlayer = Players:FindFirstChild(selected)
    end
})

-- Update Dropdown Otomatis
local function RefreshPlayers()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(names, p.Name) end
    end
    PlayerDropdown:Refresh(names)
end
RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

MainTab:CreateToggle({
    Title = "Enable Stalking",
    Value = false,
    Callback = function(state)
        Stalk = state
    end
})

-- [[ SECTION: ALTITUDE ]] --
MainTab:CreateSection("Manual Altitude")

MainTab:CreateButton({
    Title = "Increase Altitude (+10)",
    Callback = function() Alt = Alt + 10 end
})

MainTab:CreateButton({
    Title = "Decrease Altitude (-10)",
    Callback = function() Alt = Alt - 10 end
})

-- [[ LOGIKA INTI FLY & STALK ]] --
Run.Stepped:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = (hum and hum.SeatPart)
    
    if seat and Fly then
        seat.AssemblyLinearVelocity = Vector3.zero
        seat.AssemblyAngularVelocity = Vector3.zero
        
        -- Nonaktifkan Tabrakan saat Terbang
        for _, p in pairs(seat.Parent:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
        
        local moveDir = hum.MoveDirection
        
        if Stalk and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            seat.Anchored = false
            local tRoot = TargetPlayer.Character.HumanoidRootPart
            -- Posisi di atas target
            seat.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 7, 0)) * tRoot.CFrame.Rotation
        elseif moveDir.Magnitude > 0 then
            seat.Anchored = false
            local nextPos = seat.Position + (moveDir * Speed / 15)
            LastLook = moveDir
            seat.CFrame = CFrame.new(nextPos.X, Alt, nextPos.Z) * CFrame.lookAt(Vector3.zero, LastLook).Rotation
        else
            -- Menahan posisi agar tidak jatuh (Anti-Drift)
            seat.Anchored = true 
            seat.CFrame = CFrame.new(seat.Position.X, Alt, seat.Position.Z) * CFrame.lookAt(Vector3.zero, LastLook).Rotation
        end
    elseif seat and not Fly then 
        seat.Anchored = false 
    end
end)

-- [[ WEBHOOK NOTIFICATION ]] --
-- Gunakan URL Webhook dari script lama Anda di sini
local WEBHOOK_URL = "https://discord.com/api/webhooks/1485503062532689991/QbEgmFTj_lN6qxQ7aIpoen8h5cLScPgHtqOhYJ5rvyCsIlC68LfiHDvCmEYA48YuiKay"

WindUI:Notify({
    Title = "Sphyn Hub",
    Content = "Script Ready for " .. LP.Name,
    Duration = 5
})

