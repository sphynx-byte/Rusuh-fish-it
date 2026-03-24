local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Run = game:GetService("RunService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera


-- STATE (SAMA PERSIS)

local Fly = false
local Stalk = false
local TargetPlayer = nil

local Speed = 40
local Alt = 20

local Up = false
local Down = false

local LastLook = Vector3.new(0,0,1)



-- UI

local Window = Rayfield:CreateWindow({
    Name = "Sphyn Hub",
    LoadingTitle = "Sphyn",
    LoadingSubtitle = "Original Logic",
    ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("Main",4483362458)
local PlayerTab = Window:CreateTab("Player",4483362458)



MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        Fly = v

        if Fly and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            local seat = LP.Character:FindFirstChildOfClass("Humanoid").SeatPart
            if seat then
                Alt = seat.Position.Y
            end
        end
    end
})


MainTab:CreateToggle({
    Name = "Stalk",
    CurrentValue = false,
    Callback = function(v)
        Stalk = v
    end
})


MainTab:CreateInput({
    Name = "Speed",
    PlaceholderText = "40",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        Speed = tonumber(v) or 40
    end
})



-- PLAYER LIST

local function getPlayers()

    local t = {}

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(t,p.Name)
        end
    end

    return t

end


PlayerTab:CreateDropdown({

    Name = "Target",

    Options = getPlayers(),

    Callback = function(v)

        TargetPlayer = Players:FindFirstChild(v)

    end

})



-- ALTITUDE BUTTONS (SAMA KAYAK SCRIPT KAMU)

local sg = Instance.new("ScreenGui",LP.PlayerGui)
sg.ResetOnSpawn = false

local function nav(txt,pos,color)

    local b = Instance.new("TextButton")

    b.Size = UDim2.new(0,55,0,55)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true

    Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke",b).Thickness = 2

    b.Parent = sg

    return b

end


local uBtn = nav("▲",UDim2.new(0.85,0,0.20,0),Color3.fromRGB(40,40,40))
local dBtn = nav("▼",UDim2.new(0.85,0,0.28,0),Color3.fromRGB(40,40,40))


uBtn.MouseButton1Down:Connect(function()
    Up = true
end)

uBtn.MouseButton1Up:Connect(function()
    Up = false
end)


dBtn.MouseButton1Down:Connect(function()
    Down = true
end)

dBtn.MouseButton1Up:Connect(function()
    Down = false
end)



-- =========================
-- LOGIC ASLI SCRIPT KAMU
-- =========================

Run.Stepped:Connect(function()

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart

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


        if Stalk
        and TargetPlayer
        and TargetPlayer.Character
        and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        then

            seat.Anchored = false

            local tRoot =
                TargetPlayer.Character.HumanoidRootPart

            seat.CFrame =
                CFrame.new(
                    tRoot.Position + Vector3.new(0,7,0)
                )
                * tRoot.CFrame.Rotation


        elseif moveDir.Magnitude > 0 or Up or Down then

            seat.Anchored = false

            if Up then
                Alt = Alt + (Speed/30)
            end

            if Down then
                Alt = Alt - (Speed/30)
            end

            local nextPos =
                seat.Position + (moveDir * Speed / 15)

            if moveDir.Magnitude > 0 then
                LastLook = moveDir
            end

            seat.CFrame =
                CFrame.new(
                    nextPos.X,
                    Alt,
                    nextPos.Z
                )
                *
                CFrame.lookAt(
                    Vector3.zero,
                    LastLook
                ).Rotation

        else

            seat.Anchored = true

            seat.CFrame =
                CFrame.new(
                    seat.Position.X,
                    Alt,
                    seat.Position.Z
                )
                *
                CFrame.lookAt(
                    Vector3.zero,
                    LastLook
                ).Rotation

        end

    elseif seat and not Fly then

        seat.Anchored = false

    end

end)

print("FINAL USING ORIGINAL LOGIC")
