local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

-- STATE

local Fly = false
local Stalk = false

local TargetPlayer = nil

local Speed = 50
local Height = 6

local BV



-- UI

local Window = Rayfield:CreateWindow({
    Name = "Sphyn Hub",
    LoadingTitle = "Sphyn",
    LoadingSubtitle = "TP Version",
    ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("Main",4483362458)
local PlayerTab = Window:CreateTab("Player",4483362458)



-- FLY

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)

        Fly = v

        local char = LP.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        if v then

            BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(1e9,1e9,1e9)
            BV.Velocity = Vector3.zero
            BV.Parent = root

        else

            if BV then
                BV:Destroy()
                BV = nil
            end

        end

    end
})



-- STALK TP

MainTab:CreateToggle({
    Name = "Stalk TP",
    CurrentValue = false,
    Callback = function(v)
        Stalk = v
    end
})



-- SPEED

MainTab:CreateSlider({
    Name = "Speed",
    Range = {10,150},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        Speed = v
    end
})



-- HEIGHT

MainTab:CreateSlider({
    Name = "Height",
    Range = {2,20},
    Increment = 1,
    CurrentValue = 6,
    Callback = function(v)
        Height = v
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



-- LOOP

RunService.RenderStepped:Connect(function()

    local char = LP.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not root then return end
    if not hum then return end


    -- STALK TP

    if Stalk
    and TargetPlayer
    and TargetPlayer.Character
    and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    then

        local tRoot =
            TargetPlayer.Character.HumanoidRootPart

        root.CFrame =
            CFrame.new(
                tRoot.Position + Vector3.new(0,Height,0)
            )

        return

    end


    -- FLY

    if Fly and BV then

        local move = hum.MoveDirection

        BV.Velocity =
            Vector3.new(
                move.X * Speed,
                move.Y * Speed,
                move.Z * Speed
            )

    end

end)
