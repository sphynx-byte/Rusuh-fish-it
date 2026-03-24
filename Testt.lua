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
-- Menggunakan CreateWindow untuk inisialisasi menu utama
local Window = WindUI:CreateWindow({
    Title = "Sphyn Hub",
    Icon = "rbxassetid://10734950309",
    Author = "Bintang Kresna",
    Folder = "SphynHubConfig"
})

-- Menambahkan Tab ke dalam Window
local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "rbxassetid://10723415903"
})

-- [[ SECTION: CONTROLS ]] --
-- Section diperlukan agar isi UI muncul di dalam Tab
local ControlSection = MainTab:AddSection("Kontrol Utama")

ControlSection:AddToggle({
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

ControlSection:AddToggle({
    Title = "STALKING (Ikuti Target)",
    Value = false,
    Callback = function(state)
        Stalk = state
    end
})

-- [[ SECTION: SETTINGS ]] --
local SettingsSection = MainTab:AddSection("Settings")

SettingsSection:AddSlider({
    Title = "Kecepatan Terbang",
    Min = 10,
    Max = 300,
    Default = 40,
    Callback = function(v)
        Speed = v
    end
})

-- [[ SECTION: PLAYER LIST ]] --
local ListSection = MainTab:AddSection("Pilih Pemain")

local PlayerDropdown = ListSection:AddDropdown({
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
local AltSection = MainTab:AddSection("Altitude Control")

AltSection:AddButton({
    Title = "Naik (+5)",
    Callback = function() 
        Alt = Alt + 5 
    end
})

AltSection:AddButton({
    Title = "Turun (-5)",
    Callback = function() 
        Alt = Alt - 5 
    end
})

-- [[ LOGIKA GERAK ASLI (RUN SERVICE) ]] --
-- Bagian ini 100% menggunakan logika dari fish it rusuh(old).lua
Run.Stepped:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = (hum and hum.SeatPart)
    
    if seat and Fly then
        seat.AssemblyLinearVelocity = Vector3.zero
        seat.AssemblyAngularVelocity = Vector3.zero
        
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
    Content = "Menu Berhasil Muncul!",
    Duration = 3
})

