local WindUI = loadstring(game:HttpGet(
"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer


local Fly = false
local Stalk = false
local TargetPlayer = nil
local Speed = 40
local Alt = 20


-- WINDOW
local Window = WindUI:CreateWindow({
    Title = "Sphyn Hub",
    Icon = "rbxassetid://7733960981",
    Author = "Sphyn",
    Folder = "SphynHub"
})


-- TAB (FORMAT BENAR)
local MainTab = Window:Tab("Main")
local PlayerTab = Window:Tab("Player")


-- TOGGLE
MainTab:Toggle("Fly", false, function(v)
    Fly = v
end)


MainTab:Toggle("Stalk", false, function(v)
    Stalk = v
end)


MainTab:Input("Speed", "40", function(v)
    Speed = tonumber(v) or 40
end)



-- PLAYER LIST

local function getPlayers()

    local t = {}

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(t, p.Name)
        end
    end

    return t

end


PlayerTab:Dropdown("Target", getPlayers(), function(v)

    TargetPlayer = Players:FindFirstChild(v)

end)



-- FLY

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

        end

    end

end)
