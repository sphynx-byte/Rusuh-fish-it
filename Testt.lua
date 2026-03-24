-- [ LOAD LIBRARY WIND UI ] --
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Run = game:GetService("RunService")

-- [[ STATE ASLI (OTAK KODE) ]] --
local Fly = false
local Stalk = false
local TargetPlayer = nil
local Speed = 40
local Alt = 20
local Up, Down = false, false 
local LastLook = Vector3.new(0,0,1)

-- [[ WINDOW SETUP ]] --
local Window = WindUI:CreateWindow({
    Title = "Sphyn Hub",
    Icon = "rbxassetid://10734950309",
    Author = "Bintang Kresna",
    Folder = "SphynHubConfig"
})

-- Menambahkan Tab (Sesuai dokumentasi: Window:Tab)
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "rbxassetid://10723415903"
})

-- [[ SECTION: CONTROLS ]] --
local ControlSection = MainTab:Section({
    Title = "Kontrol Utama"
})

ControlSection:Toggle({
    Title = "FLY (Terbang)",
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

ControlSection:Toggle({
    Title = "STALKING (Ikuti Target)",
    Value = false,
    Callback = function(state)
        Stalk = state
    end
})

-- [[ SECTION: SETTINGS ]] --
local SettingsSection = MainTab:Section({
    Title = "Pengaturan"
})

SettingsSection:Slider({
    Title = "Kecepatan Terbang",
    Min = 10,
    Max = 300,
    Default = 40,
    Callback = function(v)
        Speed = v
    end
})

-- [[ SECTION: TARGET ]] --
local ListSection = MainTab:Section({
    Title = "Daftar Pemain"
})

local PlayerDropdown = ListSection:Dropdown({
    Title = "Pilih Target",
    Multi = false,
    Options = {},
    Callback = function(selected)
        TargetPlayer = Players:FindFirstChild(selected)
    end
})

-- Fungsi Update List Pemain (Logika Asli)
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

-- [[ SECTION: ALTITUDE ]] --
local AltSection = MainTab:Section({
    Title = "Kontrol Ketinggian"
})

AltSection:Button({
    Title = "Naik (+10)",
    Callback = function() 
        Alt = Alt + 10 
    end
})

AltSection:Button({
    Title = "Turun (-10)",
    Callback = function() 
        Alt = Alt - 10 
    end
})

-- [[ LOGIKA GERAK ASLI (RUN SERVICE) ]] --
-- Menggunakan logika persis dari fish it rusuh(old).lua
Run.Stepped:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = (hum and hum.SeatPart)
    
    if seat and Fly then
        -- Anti-Drift
        seat.AssemblyLinearVelocity = Vector3.zero
        seat.AssemblyAngularVelocity = Vector3.zero
        
        -- Nonaktifkan Tabrakan
        for _, p in pairs(seat.Parent:GetDescendants()) do 
            if p:IsA("BasePart") then 
                p.CanCollide = false
                p.Velocity = Vector3.zero 
            end 
        end
        
        local moveDir = hum.MoveDirection
        
        if Stalk and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            seat.Anchored = false
            local tRoot = TargetPlayer.Character.HumanoidRootPart
            seat.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 7, 0)) * tRoot.CFrame.Rotation
        elseif moveDir.Magnitude > 0 or Up or Down then
            seat.Anchored = false
            -- Input dari button di UI sekarang langsung mengubah nilai Alt
            if Up then Alt = Alt + (Speed/30) end 
            if Down then Alt = Alt - (Speed/30) end
            
            local nextPos = seat.Position + (moveDir * Speed / 15)
            if moveDir.Magnitude > 0 then LastLook = moveDir end
            
            seat.CFrame = CFrame.new(nextPos.X, Alt, nextPos.Z) * CFrame.lookAt(Vector3.zero, LastLook).Rotation
        else
            seat.Anchored = true 
            seat.CFrame = CFrame.new(seat.Position.X, Alt, seat.Position.Z) * CFrame.lookAt(Vector3.zero, LastLook).Rotation
        end
    elseif seat and not Fly then 
        seat.Anchored = false 
    end
end)

WindUI:Notify({
    Title = "Sphyn Hub",
    Content = "Menu Berhasil Dimuat!",
    Duration = 3
})

