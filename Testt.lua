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
local Up, Down = false, false -- Digunakan oleh logika gerakan asli
local LastLook = Vector3.new(0,0,1)

-- [[ WINDOW SETUP ]] --
local Window = WindUI:CreateWindow({
    Title = "Sphyn Hub",
    Icon = "fish",
    Author = "Bintang Kresna",
    Folder = "SphynHubConfig"
})

-- Membuat Tab Utama
local MainTab = Window:CreateTab("Main", "home")

-- [[ SECTION: CONTROLS ]] --
local ControlSection = MainTab:CreateSection("Kontrol Utama")

ControlSection:AddToggle({
    Title = "FLY (Terbang)",
    Value = false,
    Callback = function(state)
        Fly = state
        -- Inisialisasi Ketinggian saat Fly ON (Logika Asli)
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
local SettingsSection = MainTab:CreateSection("Pengaturan")

SettingsSection:AddSlider({
    Title = "Kecepatan Terbang",
    Min = 10,
    Max = 300,
    Default = 40,
    Callback = function(v)
        Speed = v
    end
})

-- [[ SECTION: TARGET ]] --
local TargetSection = MainTab:CreateSection("Pilih Pemain")

local PlayerDropdown = TargetSection:AddDropdown({
    Title = "Pilih Target Stalk",
    Multi = false,
    Options = {},
    Callback = function(selected)
        TargetPlayer = Players:FindFirstChild(selected)
    end
})

-- Fungsi Update List Pemain (Asli)
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
local AltSection = MainTab:CreateSection("Kontrol Ketinggian")

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
        -- Anti-Drift: Reset Velocity
        seat.AssemblyLinearVelocity = Vector3.zero
        seat.AssemblyAngularVelocity = Vector3.zero
        
        -- Nonaktifkan Tabrakan Kendaraan
        for _, p in pairs(seat.Parent:GetDescendants()) do 
            if p:IsA("BasePart") then 
                p.CanCollide = false
                p.Velocity = Vector3.zero 
            end 
        end
        
        local moveDir = hum.MoveDirection
        
        -- Logika STALK
        if Stalk and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            seat.Anchored = false
            local tRoot = TargetPlayer.Character.HumanoidRootPart
            seat.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 7, 0)) * tRoot.CFrame.Rotation
        
        -- Logika BERGERAK
        elseif moveDir.Magnitude > 0 or Up or Down then
            seat.Anchored = false
            -- Handling input manual altitude (jika variabel Up/Down aktif)
            if Up then Alt = Alt + (Speed/30) end 
            if Down then Alt = Alt - (Speed/30) end
            
            local nextPos = seat.Position + (moveDir * Speed / 15)
            if moveDir.Magnitude > 0 then LastLook = moveDir end
            
            seat.CFrame = CFrame.new(nextPos.X, Alt, nextPos.Z) * CFrame.lookAt(Vector3.zero, LastLook).Rotation
        
        -- Logika DIAM (Anchored agar tidak jatuh)
        else
            seat.Anchored = true 
            seat.CFrame = CFrame.new(seat.Position.X, Alt, seat.Position.Z) * CFrame.lookAt(Vector3.zero, LastLook).Rotation
        end
    elseif seat and not Fly then 
        seat.Anchored = false 
    end
end)

-- Notifikasi Berhasil
WindUI:Notify({
    Title = "Sphyn Hub",
    Content = "Script dimuat tanpa Webhook!",
    Duration = 5
})

print("SPHYN HUB: Berhasil dimuat (Tanpa Webhook).")

