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
local clickTpActive = false
local orbAnimation = true

local function getHRP()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

-- Создание орба с линией и Billboard
local function createOrb(i, cframe)
    if orbs[i] then
        orbs[i]:Destroy()
        lines[i]:Destroy()
        orbs[i] = nil
        lines[i] = nil
    end

    local orb = Instance.new("Part")
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(2,2,2)
    orb.Material = Enum.Material.Neon
    orb.Color = Color3.fromRGB(255, 0, 255)
    orb.Anchored = true
    orb.CanCollide = false
    orb.CFrame = cframe
    orb.Parent = workspace

    -- BillboardGui над орбом
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0,140,0,40)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = orb

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(30,30,30)
    bg.BorderSizePixel = 0
    bg.Parent = billboard
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,12)

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255,170,255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.5
    text.Parent = bg

    -- Линия до игрока
    local line = Instance.new("Beam")
    local att0 = Instance.new("Attachment", getHRP())
    local att1 = Instance.new("Attachment", orb)
    line.Attachment0 = att0
    line.Attachment1 = att1
    line.FaceCamera = true
    line.Width0 = 0.15
    line.Width1 = 0.15
    line.Color = ColorSequence.new(Color3.fromRGB(255,0,255))
    local beamPart = Instance.new("Part", workspace)
    beamPart.Transparency = 1
    line.Parent = beamPart
    lines[i] = beamPart

    -- Анимация
    local angle = 0
    RunService.RenderStepped:Connect(function()
        if orb and orb.Parent then
            local hrp = getHRP()
            local dist = (hrp.Position - orb.Position).Magnitude
            text.Text = "Pos #"..i.."\n"..math.floor(dist).." studs"

            if orbAnimation then
                angle += math.rad(2)
                orb.CFrame = cframe * CFrame.new(0, math.sin(angle)*0.5, 0)
            end
        end
    end)

    orbs[i] = orb
end

-- Клик по миру
local function onClick(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not mouse.Target then return end

    local hitPos = mouse.Hit.Position

    if clickingForPos then
        clickingForPos = false
        local cf = CFrame.new(hitPos) * CFrame.new(0,3,0)
        positions[poseCount] = cf
        createOrb(poseCount, cf)
        clickPosBtn.Text = "Click-Pos"

    elseif clickTpActive then
        getHRP().CFrame = CFrame.new(hitPos) * CFrame.new(0,3,0)
    end
end

UserInputService.InputBegan:Connect(onClick)

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0,75,0,75)
logo.Position = UDim2.new(0,18,0,18)
logo.Text = "TP"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 30
logo.TextColor3 = Color3.fromRGB(255,170,255)
logo.BackgroundColor3 = Color3.fromRGB(18,18,18)
logo.Parent = gui
Instance.new("UICorner",logo).CornerRadius = UDim.new(0,16)
local logoGlow = Instance.new("UIStroke", logo)
logoGlow.Thickness = 4
logoGlow.Transparency = 0.5
logoGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
logoGlow.Color = Color3.fromRGB(255,0,255)

-- Главное окно
local main = Instance.new("Frame")
main.Size = UDim2.new(0,340,0,450)
main.Position = UDim2.new(0.5,-170,0.5,-225)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Visible = false
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,16)

local uiGlow = Instance.new("UIStroke", main)
uiGlow.Thickness = 6
uiGlow.Transparency = 0.3
uiGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiGlow.Color = Color3.fromRGB(200,0,255)

spawn(function()
    while main.Parent do
        TweenService:Create(uiGlow, TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true), {Transparency=0.1}):Play()
        wait(2)
    end
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,0,0,30)
titleLabel.Position = UDim2.new(0,0,0,0)
titleLabel.Text = "Skizzen's Mini Tp"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(255,170,255)
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = main

local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,10,0,50)
content.Size = UDim2.new(1,-20,1,-60)
content.BackgroundTransparency = 1

local tpFrame = Instance.new("Frame",content)
tpFrame.Size = UDim2.new(1,0,1,0)
tpFrame.BackgroundTransparency = 1
local tpLayout = Instance.new("UIListLayout", tpFrame)
tpLayout.Padding = UDim.new(0,6)

-- Создание позиции
local function createPositionBox(i)
    local box = Instance.new("Frame", tpFrame)
    box.Size = UDim2.new(1,0,0,40)
    box.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

    local label = Instance.new("TextLabel", box)
    label.Size = UDim2.new(0.38,0,1,0)
    label.Text = "Pos "..i
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255,170,255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0.03,0,0,0)

    local function makeBtn(txt,xPos,color)
        local b = Instance.new("TextButton", box)
        b.Size = UDim2.new(0,60,0,28)
        b.Position = UDim2.new(xPos,0,0.5,-14)
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.BackgroundColor3 = color or Color3.fromRGB(80,0,150)
        b.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        return b
    end

    local save = makeBtn("Save",0.42)
    clickPosBtn = makeBtn("Click-Pos",0.62,Color3.fromRGB(80,0,150))
    local tp = makeBtn("TP",0.82)

    save.MouseButton1Click:Connect(function()
        local cf = getHRP().CFrame
        positions[i] = cf
        createOrb(i,cf)
    end)

    clickPosBtn.MouseButton1Click:Connect(function()
        if not clickingForPos then
            clickingForPos = true
            clickPosBtn.Text = "Clicking..."
        end
    end)

    tp.MouseButton1Click:Connect(function()
        if positions[i] then
            getHRP().CFrame = positions[i]
        end
    end)
end

poseCount = 1
createPositionBox(poseCount)

local addBtn = Instance.new("TextButton", tpFrame)
addBtn.Size = UDim2.new(0,28,0,28)
addBtn.Text = "+"
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 16
addBtn.BackgroundColor3 = Color3.fromRGB(80,0,150)
addBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(1,0)
addBtn.Position = UDim2.new(0,10,1,-38)
addBtn.MouseButton1Click:Connect(function()
    if poseCount >= MAX_POSES then return end
    poseCount += 1
    createPositionBox(poseCount)
    if poseCount >= MAX_POSES then
        addBtn.Visible = false
    end
end)

-- Click-TP toggle
clickTpBtn = Instance.new("TextButton", tpFrame)
clickTpBtn.Size = UDim2.new(0,140,0,32)
clickTpBtn.Position = UDim2.new(0.5,-70,1,-45)
clickTpBtn.Text = "Click-TP ⚡ Off"
clickTpBtn.Font = Enum.Font.GothamBold
clickTpBtn.TextSize = 14
clickTpBtn.BackgroundColor3 = Color3.fromRGB(80,0,150)
clickTpBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", clickTpBtn).CornerRadius = UDim.new(0,8)

clickTpBtn.MouseButton1Click:Connect(function()
    clickTpActive = not clickTpActive
    if clickTpActive then
        clickTpBtn.Text = "Click-TP ⚡ On"
    else
        clickTpBtn.Text = "Click-TP ⚡ Off"
    end
end)

-- Toggle анимации орбов (только кнопка, без текста)
local animBtn = Instance.new("TextButton", tpFrame)
animBtn.Size = UDim2.new(0,140,0,32)
animBtn.Position = UDim2.new(0.5,-70,1,-85)
animBtn.Text = "Toggle Orb Anim"
animBtn.Font = Enum.Font.GothamBold
animBtn.TextSize = 14
animBtn.BackgroundColor3 = Color3.fromRGB(80,0,150)
animBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", animBtn).CornerRadius = UDim.new(0,8)
animBtn.MouseButton1Click:Connect(function()
    orbAnimation = not orbAnimation
end)

-- Управление окном
logo.MouseButton1Click:Connect(function()
    logo.Visible = false
    main.Visible = true
end)

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0,22,0,22)
minBtn.Position = UDim2.new(1,-55,0,8)
minBtn.Text = "_"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.BackgroundColor3 = Color3.fromRGB(45,0,70)
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1,0)
minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    logo.Visible = true
end)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0,22,0,22)
closeBtn.Position = UDim2.new(1,-28,0,8)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BackgroundColor3 = Color3.fromRGB(45,0,70)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
