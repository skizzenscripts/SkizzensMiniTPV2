local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local MAX_POSES = 5
local poseCount = 0

local positions = {}
local orbs = {}
local lines = {}

local clickingForPos = false
local currentClickIndex = nil
local clickButtons = {}

local clickTpActive = false
local orbAnimation = true

local function getHRP()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

-- ORB
local function createOrb(i, cframe)

    if orbs[i] then
        orbs[i]:Destroy()
        lines[i]:Destroy()
    end

    local orb = Instance.new("Part")
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(2,2,2)
    orb.Material = Enum.Material.Neon
    orb.Color = Color3.fromRGB(255,0,255)
    orb.Anchored = true
    orb.CanCollide = false
    orb.CFrame = cframe
    orb.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0,120,0,36)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = orb

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(30,30,30)
    bg.BorderSizePixel = 0
    bg.Parent = billboard
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,10)

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255,170,255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.5
    text.Parent = bg

    local beamPart = Instance.new("Part", workspace)
    beamPart.Transparency = 1
    beamPart.Anchored = true
    beamPart.CanCollide = false

    local att0 = Instance.new("Attachment", getHRP())
    local att1 = Instance.new("Attachment", orb)

    local beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.FaceCamera = true
    beam.Width0 = 0.18
    beam.Width1 = 0.18
    beam.LightEmission = 1
    beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180,0,255))
    }
    beam.Parent = beamPart

    lines[i] = beamPart

    local t = 0

    RunService.RenderStepped:Connect(function(dt)

        if not orb or not orb.Parent then return end

        local hrp = getHRP()
        local dist = (hrp.Position - orb.Position).Magnitude
        text.Text = "Pos #"..i.." | "..math.floor(dist)

        if orbAnimation then
            t += dt
            local y = math.sin(t*2)*0.45
            local rot = CFrame.Angles(0,t*1.2,0)
            orb.CFrame = cframe * CFrame.new(0,y,0) * rot
        end

    end)

    orbs[i] = orb
end

-- CLICK
local function onClick(input, gameProcessed)

    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not mouse.Target then return end

    local hitPos = mouse.Hit.Position

    if clickingForPos then

        clickingForPos = false
        local cf = CFrame.new(hitPos) * CFrame.new(0,3,0)

        positions[currentClickIndex] = cf
        createOrb(currentClickIndex, cf)

        clickButtons[currentClickIndex].Text = "Click"

    elseif clickTpActive then

        getHRP().CFrame = CFrame.new(hitPos) * CFrame.new(0,3,0)

    end
end

UserInputService.InputBegan:Connect(onClick)

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0,70,0,70)
logo.Position = UDim2.new(0,18,0,18)
logo.Text = "TP"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 28
logo.TextColor3 = Color3.fromRGB(255,170,255)
logo.BackgroundColor3 = Color3.fromRGB(18,18,18)
logo.Parent = gui
Instance.new("UICorner",logo).CornerRadius = UDim.new(0,14)

local logoGlow = Instance.new("UIStroke", logo)
logoGlow.Thickness = 4
logoGlow.Transparency = 0.5
logoGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
logoGlow.Color = Color3.fromRGB(255,0,255)

-- MAIN
local main = Instance.new("Frame")
main.Size = UDim2.new(0,330,0,360)
main.Position = UDim2.new(0.5,-165,0.5,-180)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Visible = false
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,16)

-- GLOW
local uiGlow = Instance.new("UIStroke", main)
uiGlow.Thickness = 6
uiGlow.Transparency = 0.3
uiGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiGlow.Color = Color3.fromRGB(200,0,255)

spawn(function()
    while main.Parent do
        TweenService:Create(
            uiGlow,
            TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true),
            {Transparency=0.1}
        ):Play()
        wait(2)
    end
end)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Skizzen's Mini Tp"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(255,170,255)
title.BackgroundTransparency = 1

-- MIN / CLOSE
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0,20,0,20)
minBtn.Position = UDim2.new(1,-50,0,6)
minBtn.Text = "_"
minBtn.BackgroundColor3 = Color3.fromRGB(45,0,70)
minBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minBtn)

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    logo.Visible = true
end)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0,20,0,20)
closeBtn.Position = UDim2.new(1,-25,0,6)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(45,0,70)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- POS FRAME
local posFrame = Instance.new("Frame", main)
posFrame.Position = UDim2.new(0,10,0,35)
posFrame.Size = UDim2.new(1,-20,0,230)
posFrame.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", posFrame)
layout.Padding = UDim.new(0,5)

-- POS BOX
local function createPositionBox(i)

    local box = Instance.new("Frame", posFrame)
    box.Size = UDim2.new(1,0,0,34)
    box.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", box)

    local label = Instance.new("TextLabel", box)
    label.Size = UDim2.new(0.32,0,1,0)
    label.Text = "Pos "..i
    label.TextColor3 = Color3.fromRGB(255,170,255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold

    local function makeBtn(txt,x)

        local b = Instance.new("TextButton", box)
        b.Size = UDim2.new(0,45,0,22)
        b.Position = UDim2.new(x,0,0.5,-11)
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.BackgroundColor3 = Color3.fromRGB(100,0,200)
        b.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", b)

        return b
    end

    local save = makeBtn("Save",0.36)
    local click = makeBtn("Click",0.56)
    local tp = makeBtn("TP",0.76)

    clickButtons[i] = click

    save.MouseButton1Click:Connect(function()
        local cf = getHRP().CFrame
        positions[i] = cf
        createOrb(i,cf)
    end)

    click.MouseButton1Click:Connect(function()
        clickingForPos = true
        currentClickIndex = i
        click.Text = "..."
    end)

    tp.MouseButton1Click:Connect(function()
        if positions[i] then
            getHRP().CFrame = positions[i]
        end
    end)

end

-- START WITH 1 POS
poseCount = 1
createPositionBox(1)

-- +
local addBtn = Instance.new("TextButton", posFrame)
addBtn.Size = UDim2.new(0,26,0,26)
addBtn.Text = "+"
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 15
addBtn.BackgroundColor3 = Color3.fromRGB(100,0,200)
addBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", addBtn)

addBtn.MouseButton1Click:Connect(function()

    if poseCount >= MAX_POSES then return end

    poseCount += 1
    createPositionBox(poseCount)

    if poseCount >= MAX_POSES then
        addBtn.Visible = false
    end

end)

-- BOTTOM
local bottomFrame = Instance.new("Frame", main)
bottomFrame.Size = UDim2.new(1,-20,0,36)
bottomFrame.Position = UDim2.new(0,10,1,-46)
bottomFrame.BackgroundTransparency = 1

local clickTpBtn = Instance.new("TextButton", bottomFrame)
clickTpBtn.Size = UDim2.new(0.48,0,1,0)
clickTpBtn.Text = "Click-TP Off"
clickTpBtn.BackgroundColor3 = Color3.fromRGB(100,0,200)
clickTpBtn.TextColor3 = Color3.new(1,1,1)
clickTpBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", clickTpBtn)

local animBtn = Instance.new("TextButton", bottomFrame)
animBtn.Size = UDim2.new(0.48,0,1,0)
animBtn.Position = UDim2.new(0.52,0,0,0)
animBtn.Text = "Orb Anim"
animBtn.BackgroundColor3 = Color3.fromRGB(100,0,200)
animBtn.TextColor3 = Color3.new(1,1,1)
animBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", animBtn)

clickTpBtn.MouseButton1Click:Connect(function()

    clickTpActive = not clickTpActive

    if clickTpActive then
        clickTpBtn.Text = "Click-TP On"
    else
        clickTpBtn.Text = "Click-TP Off"
    end

end)

animBtn.MouseButton1Click:Connect(function()
    orbAnimation = not orbAnimation
end)

logo.MouseButton1Click:Connect(function()
    logo.Visible = false
    main.Visible = true
end)
    gui:Destroy()
end)
