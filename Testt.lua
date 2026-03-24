local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success then
    warn("Rayfield gagal load")
    return
end


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

local Fly = false
local Stalk = false
local TargetPlayer = nil

local Speed = 40
local Alt = 20

local Up = false
local Down = false

local LastLook = Vector3.new(0,0,1)



local Window = Rayfield:CreateWindow({
    Name = "Sphyn Hub",
    LoadingTitle = "Sphyn Hub",
    LoadingSubtitle = "Loading UI",
    ConfigurationSaving = {
        Enabled = false
    }
})


local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local MoveTab = Window:CreateTab("Move", 4483362458)



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



MoveTab:CreateButton({
    Name = "UP",
    Callback = function()
        Up = true
        task.wait(.2)
        Up = false
    end
})


MoveTab:CreateButton({
    Name = "DOWN",
    Callback = function()
        Down = true
        task.wait(.2)
        Down = false
    end
})



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


        local moveDir = hum.MoveDirection


        if Stalk
        and TargetPlayer
        and TargetPlayer.Character
        and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        then

            local tRoot =
                TargetPlayer.Character.HumanoidRootPart

            seat.CFrame =
                CFrame.new(
                    tRoot.Position + Vector3.new(0,7,0)
                )
                * tRoot.CFrame.Rotation

        elseif moveDir.Magnitude > 0 then

            local nextPos =
                seat.Position
                + (moveDir * Speed / 15)

            seat.CFrame =
                CFrame.new(
                    nextPos.X,
                    Alt,
                    nextPos.Z
                )

        end

    end

end)
