-- UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

-- STATE

local Fly = false
local Stalk = false
local TargetPlayer = nil

local Speed = 40
local Alt = 20

local Up = false
local Down = false

local LastLook = Vector3.new(0,0,1)



-- WINDOW

local Window = Rayfield:CreateWindow({

    Name = "Sphyn Hub",

    LoadingTitle = "Sphyn Hub",

    LoadingSubtitle = "Loaded",

    ConfigurationSaving = {Enabled = false}

})


local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)



-- MAIN

MainTab:CreateToggle({

    Name = "Fly",

    CurrentValue = false,

    Callback = function(v)

        Fly = v

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



-- ALTITUDE BUTTONS

local sg = Instance.new("ScreenGui")
sg.Name = "AltitudeButtons"
sg.ResetOnSpawn = false
sg.Parent = LP:WaitForChild("PlayerGui")


local function makeBtn(text,pos)

    local b = Instance.new("TextButton")

    b.Size = UDim2.new(0,60,0,60)
    b.Position = pos
    b.Text = text

    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true

    Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)

    b.Parent = sg

    return b

end


local upBtn = makeBtn("▲",UDim2.new(0.9,0,0.2,0))
local downBtn = makeBtn("▼",UDim2.new(0.9,0,0.32,0))


upBtn.MouseButton1Down:Connect(function()
    Up = true
end)

upBtn.MouseButton1Up:Connect(function()
    Up = false
end)


downBtn.MouseButton1Down:Connect(function()
    Down = true
end)

downBtn.MouseButton1Up:Connect(function()
    Down = false
end)



-- FLY LOGIC FULL

RunService.Stepped:Connect(function()

    local char = LP.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local seat = hum.SeatPart
    if not seat then return end


    if Fly then

        seat.AssemblyLinearVelocity = Vector3.zero
        seat.AssemblyAngularVelocity = Vector3.zero


        for _,p in pairs(seat.Parent:GetDescendants()) do

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


        elseif moveDir.Magnitude > 0
        or Up
        or Down then

            seat.Anchored = false


            if Up then
                Alt = Alt + (Speed/30)
            end

            if Down then
                Alt = Alt - (Speed/30)
            end


            local nextPos =
                seat.Position
                + (moveDir * Speed / 15)


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

    else

        seat.Anchored = false

    end

end)

print("SPHYN HUB FULL FINAL LOADED")
