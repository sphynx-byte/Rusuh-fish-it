local WindUI = loadstring(game:HttpGet(
"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

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
local Window = WindUI:CreateWindow({
    Title = "Sphyn Hub",
    Size = UDim2.fromOffset(450,350),
    Theme = "Dark"
})



local MainTab = Window:CreateTab({Title="Main"})
local PlayerTab = Window:CreateTab({Title="Player"})
local MoveTab = Window:CreateTab({Title="Move"})



-- =====================
-- TOGGLES
-- =====================

MainTab:Toggle({
    Title = "Fly",
    Default = false,
    Callback = function(v)
        Fly = v
    end
})

MainTab:Toggle({
    Title = "Stalk",
    Default = false,
    Callback = function(v)
        Stalk = v
    end
})


MainTab:Input({
    Title = "Speed",
    Placeholder = "40",
    Callback = function(v)
        Speed = tonumber(v) or 40
    end
})



-- =====================
-- UP DOWN
-- =====================

MoveTab:Button({
    Title = "UP",
    Callback = function()
        Up = true
        task.wait(.2)
        Up = false
    end
})

MoveTab:Button({
    Title = "DOWN",
    Callback = function()
        Down = true
        task.wait(.2)
        Down = false
    end
})



-- =====================
-- PLAYER LIST
-- =====================

local playerList = {}

local function updatePlayers()

    playerList = {}

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(playerList,p.Name)
        end
    end

end

updatePlayers()

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)



PlayerTab:Dropdown({

    Title = "Target",

    Values = playerList,

    Callback = function(v)

        TargetPlayer = Players:FindFirstChild(v)

    end

})



-- =====================
-- ANTI DRIFT + FLY
-- =====================

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

            local tRoot =
                TargetPlayer.Character.HumanoidRootPart

            seat.Anchored = false

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



print("SPHYN HUB WINDUI FULL LOADED")
