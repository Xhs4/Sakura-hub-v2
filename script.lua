-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Limpieza de instancias previas
if CoreGui:FindFirstChild("Sakura_Hub_UI") then CoreGui.Sakura_Hub_UI:Destroy() end
if LP:WaitForChild("PlayerGui"):FindFirstChild("Sakura_Hub_UI") then LP.PlayerGui.Sakura_Hub_UI:Destroy() end

-- Configuración Base
local Config = {
    ESPEnabled = true, TracersEnabled = true, HighlightsEnabled = true,
    AimLockEnabled = false, AimMode = "Mobile (Bubble)", AimPart = "Head",
    AimSmoothness = 0.85, AimFOV = 130, ShowFOV = true,
    DiscordInvite = "https://discord.gg/MfcZYtxuS", TeamFilter = {}
}
local ESP, IsAimingRightClick = {}, false

-- 1. ScreenGui Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Sakura_Hub_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- 2. SPLASH SCREEN
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 35}):Play()

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.Position = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 8, 16)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 100
MainFrame.Parent = ScreenGui

TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.15}):Play()

local CenterContainer = Instance.new("Frame")
CenterContainer.Name = "CenterContainer"
CenterContainer.Size = UDim2.new(0, 260, 0, 260)
CenterContainer.AnchorPoint = Vector2.new(0.5, 0.5)
CenterContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
CenterContainer.BackgroundTransparency = 1
CenterContainer.ZIndex = 101
CenterContainer.Parent = MainFrame

-- Contenedor de la Flor (Tamaño ajustado a 60x60)
local FlowerContainer = Instance.new("Frame")
FlowerContainer.Name = "FlowerContainer"
FlowerContainer.Size = UDim2.new(0, 60, 0, 60)
FlowerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
FlowerContainer.Position = UDim2.new(0.5, 0, 0.35, 0)
FlowerContainer.BackgroundTransparency = 1
FlowerContainer.ZIndex = 102
FlowerContainer.Parent = CenterContainer

-- Construcción de la Flor Sakura (5 Pétalos vectoriales)
local PetalGroup = Instance.new("Frame")
PetalGroup.Size = UDim2.new(1, 0, 1, 0)
PetalGroup.BackgroundTransparency = 1
PetalGroup.ZIndex = 103
PetalGroup.Parent = FlowerContainer

for i = 1, 5 do
    local angle = (i - 1) * (360 / 5)
    
    local PetalHolder = Instance.new("Frame")
    PetalHolder.Size = UDim2.new(1, 0, 1, 0)
    PetalHolder.BackgroundTransparency = 1
    PetalHolder.Rotation = angle
    PetalHolder.ZIndex = 103
    PetalHolder.Parent = PetalGroup

    local Petal = Instance.new("Frame")
    Petal.Size = UDim2.new(0, 26, 0, 34)
    Petal.AnchorPoint = Vector2.new(0.5, 1)
    Petal.Position = UDim2.new(0.5, 0, 0.5, 0)
    Petal.BackgroundColor3 = Color3.fromRGB(248, 198, 222)
    Petal.BackgroundTransparency = 0.1
    Petal.BorderSizePixel = 0
    Petal.ZIndex = 103
    Petal.Parent = PetalHolder

    local PetalCorner = Instance.new("UICorner", Petal)
    PetalCorner.CornerRadius = UDim.new(0.5, 0)
end

-- Centro de la flor
local FlowerCenter = Instance.new("Frame")
FlowerCenter.Size = UDim2.new(0, 16, 0, 16)
FlowerCenter.AnchorPoint = Vector2.new(0.5, 0.5)
FlowerCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
FlowerCenter.BackgroundColor3 = Color3.fromRGB(195, 80, 120)
FlowerCenter.BorderSizePixel = 0
FlowerCenter.ZIndex = 106
FlowerCenter.Parent = FlowerContainer
Instance.new("UICorner", FlowerCenter).CornerRadius = UDim.new(1, 0)

for i = 1, 10 do
    local stAngle = (i - 1) * (360 / 10)
    local StamenLine = Instance.new("Frame")
    StamenLine.Size = UDim2.new(0, 2, 0, 16)
    StamenLine.AnchorPoint = Vector2.new(0.5, 1)
    StamenLine.Position = UDim2.new(0.5, 0, 0.5, 0)
    StamenLine.BackgroundColor3 = Color3.fromRGB(195, 80, 120)
    StamenLine.BorderSizePixel = 0
    StamenLine.Rotation = stAngle
    StamenLine.ZIndex = 105
    StamenLine.Parent = FlowerContainer

    local Anther = Instance.new("Frame")
    Anther.Size = UDim2.new(0, 4, 0, 4)
    Anther.AnchorPoint = Vector2.new(0.5, 0.5)
    Anther.Position = UDim2.new(0.5, 0, 0, 0)
    Anther.BackgroundColor3 = Color3.fromRGB(195, 80, 120)
    Anther.BorderSizePixel = 0
    Anther.ZIndex = 105
    Anther.Parent = StamenLine
    Instance.new("UICorner", Anther).CornerRadius = UDim.new(1, 0)
end

-- Status Text Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 100, 0, 30)
StatusLabel.AnchorPoint = Vector2.new(0.5, 0.5)
StatusLabel.Position = UDim2.new(0.5, 0, 0.68, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Loading..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 220, 238)
StatusLabel.TextSize = 19
StatusLabel.Font = Enum.Font.FredokaOne
StatusLabel.TextTransparency = 0
StatusLabel.ZIndex = 102
StatusLabel.Parent = CenterContainer

local TextStroke = Instance.new("UIStroke", StatusLabel)
TextStroke.Color = Color3.fromRGB(80, 30, 55)
TextStroke.Thickness = 1.5
TextStroke.Transparency = 0.2

-- Barra de Progreso
local ProgressBarBackground = Instance.new("Frame")
ProgressBarBackground.Size = UDim2.new(1, 0, 0, 6)
ProgressBarBackground.AnchorPoint = Vector2.new(0.5, 0.5)
ProgressBarBackground.Position = UDim2.new(0.5, 0, 0.82, 0)
ProgressBarBackground.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
ProgressBarBackground.BackgroundTransparency = 0.5
ProgressBarBackground.BorderSizePixel = 0
ProgressBarBackground.ZIndex = 102
ProgressBarBackground.Parent = CenterContainer
Instance.new("UICorner", ProgressBarBackground).CornerRadius = UDim.new(1, 0)

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 140, 185)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.ZIndex = 103
ProgressBarFill.Parent = ProgressBarBackground
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1, 0)

-- Rotación de la Flor
task.spawn(function()
    while FlowerContainer and FlowerContainer.Parent do
        FlowerContainer.Rotation = (FlowerContainer.Rotation + 2) % 360
        task.wait(0.02)
    end
end)

-- 3. INTERFAZ PRINCIPAL
local FOV = Instance.new("Frame")
FOV.AnchorPoint, FOV.Position, FOV.Size, FOV.BackgroundTransparency, FOV.Visible, FOV.Parent = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), UDim2.new(0,260,0,260), 1, false, ScreenGui
Instance.new("UICorner", FOV).CornerRadius = UDim.new(1,0)
local FOVS = Instance.new("UIStroke", FOV) FOVS.Color, FOVS.Thickness = Color3.fromRGB(255,140,180), 1.8

local MF = Instance.new("Frame")
MF.Size, MF.Position, MF.BackgroundColor3, MF.Active, MF.Visible, MF.Parent = UDim2.new(0,350,0,260), UDim2.new(0.5,-175,0.5,-130), Color3.fromRGB(22,12,18), true, false, ScreenGui
Instance.new("UICorner", MF).CornerRadius = UDim.new(0,14)
local MS = Instance.new("UIStroke", MF) MS.Color, MS.Thickness = Color3.fromRGB(255,140,180), 1.8

-- Arrastre de Ventana
local dragging, dragStart, startPos
MF.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging, dragStart, startPos = true, i.Position, MF.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart MF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

-- TopBar
local TB = Instance.new("Frame") TB.Size, TB.BackgroundColor3, TB.Parent = UDim2.new(1,0,0,38), Color3.fromRGB(35,18,28), MF
Instance.new("UICorner", TB).CornerRadius = UDim.new(0,14)
local TBT = Instance.new("TextLabel") TBT.Size, TBT.Position, TBT.BackgroundTransparency, TBT.Text, TBT.TextColor3, TBT.Font, TBT.TextSize, TBT.TextXAlignment, TBT.Parent = UDim2.new(1,-90,1,0), UDim2.new(0,12,0,0), 1, "🌸 SAKURA HUB", Color3.fromRGB(255,192,210), Enum.Font.FredokaOne, 13, Enum.TextXAlignment.Left, TB

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size, OpenBtn.Position, OpenBtn.BackgroundColor3, OpenBtn.Text, OpenBtn.TextColor3, OpenBtn.Font, OpenBtn.TextSize, OpenBtn.Visible, OpenBtn.Parent = UDim2.new(0,44,0,44), UDim2.new(0,12,0.5,-22), Color3.fromRGB(35,18,28), "🌸", Color3.fromRGB(255,160,190), Enum.Font.GothamBold, 16, false, ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)
local OS = Instance.new("UIStroke", OpenBtn) OS.Color, OS.Thickness = Color3.fromRGB(255,140,180), 2

local MinBtn = Instance.new("TextButton") MinBtn.Size, MinBtn.Position, MinBtn.BackgroundColor3, MinBtn.Text, MinBtn.TextColor3, MinBtn.Font, MinBtn.TextSize, MinBtn.Parent = UDim2.new(0,26,0,26), UDim2.new(1,-60,0.5,-13), Color3.fromRGB(50,28,40), "—", Color3.fromRGB(255,190,210), Enum.Font.GothamBold, 11, TB
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,5)
local CloseBtn = Instance.new("TextButton") CloseBtn.Size, CloseBtn.Position, CloseBtn.BackgroundColor3, CloseBtn.Text, CloseBtn.TextColor3, CloseBtn.Font, CloseBtn.TextSize, CloseBtn.Parent = UDim2.new(0,26,0,26), UDim2.new(1,-30,0.5,-13), Color3.fromRGB(255,110,150), "🌸", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 11, TB
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)

local function ToggleGUI(s) MF.Visible, OpenBtn.Visible = s, not s end
MinBtn.MouseButton1Click:Connect(function() ToggleGUI(false) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleGUI(false) end)
OpenBtn.MouseButton1Click:Connect(function() ToggleGUI(true) end)

-- Botón Flotante AimLock
local QB = Instance.new("TextButton")
QB.Size, QB.Position, QB.BackgroundColor3, QB.Text, QB.TextColor3, QB.Font, QB.TextSize, QB.Visible, QB.Parent = UDim2.new(0,48,0,48), UDim2.new(0.85,0,0.3,0), Color3.fromRGB(35,18,28), "🎯\nOFF", Color3.fromRGB(255,150,180), Enum.Font.GothamBold, 9, false, ScreenGui
Instance.new("UICorner", QB).CornerRadius = UDim.new(1,0)
local QS = Instance.new("UIStroke", QB) QS.Color, QS.Thickness = Color3.fromRGB(255,130,170), 2

local bDrag, bStart, bPos
QB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then bDrag, bStart, bPos = true, i.Position, QB.Position end end)
UserInputService.InputChanged:Connect(function(i) if bDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - bStart QB.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset+d.X, bPos.Y.Scale, bPos.Y.Offset+d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then bDrag = false end end)

QB.MouseButton1Click:Connect(function()
    Config.AimLockEnabled = not Config.AimLockEnabled
    QB.Text = Config.AimLockEnabled and "🎯\nON" or "🎯\nOFF"
    QB.BackgroundColor3 = Config.AimLockEnabled and Color3.fromRGB(255,110,150) or Color3.fromRGB(35,18,28)
end)

-- Sistema de Pestañas
local TabBar = Instance.new("Frame") TabBar.Size, TabBar.Position, TabBar.BackgroundTransparency, TabBar.Parent = UDim2.new(1,-20,0,26), UDim2.new(0,10,0,44), 1, MF
local function CTab(txt, sz, pos)
    local b = Instance.new("TextButton")
    b.Size, b.Position, b.BackgroundColor3, b.TextColor3, b.Text, b.Font, b.TextSize, b.Parent = UDim2.new(sz,-2,1,0), pos, Color3.fromRGB(40,22,32), Color3.fromRGB(220,180,200), txt, Enum.Font.FredokaOne, 11, TabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    return b
end
local T1, T2, T3, T4 = CTab("ESP",0.25,UDim2.new(0,0,0,0)), CTab("AimLock",0.25,UDim2.new(0.25,1,0,0)), CTab("Teams",0.25,UDim2.new(0.5,2,0,0)), CTab("Credits",0.25,UDim2.new(0.75,3,0,0))

local PC = Instance.new("Frame") PC.Size, PC.Position, PC.BackgroundTransparency, PC.Parent = UDim2.new(1,-20,1,-80), UDim2.new(0,10,0,74), 1, MF
local PESP, PAim, PTms, PCrd = Instance.new("Frame"), Instance.new("Frame"), Instance.new("ScrollingFrame"), Instance.new("Frame")
for _, p in ipairs({PESP, PAim, PTms, PCrd}) do p.Size, p.BackgroundTransparency, p.Visible, p.Parent = UDim2.new(1,0,1,0), 1, false, PC end
PESP.Visible = true PTms.ScrollBarThickness = 3

local function STab(ap, ab)
    for _, p in ipairs({PESP, PAim, PTms, PCrd}) do p.Visible = false end
    for _, b in ipairs({T1, T2, T3, T4}) do b.BackgroundColor3 = Color3.fromRGB(40,22,32) end
    ap.Visible = true ab.BackgroundColor3 = Color3.fromRGB(255,110,150)
end
T1.MouseButton1Click:Connect(function() STab(PESP, T1) end)
T2.MouseButton1Click:Connect(function() STab(PAim, T2) end)
T3.MouseButton1Click:Connect(function() STab(PTms, T3) end)
T4.MouseButton1Click:Connect(function() STab(PCrd, T4) end)
T1.BackgroundColor3 = Color3.fromRGB(255,110,150)

local function AddL(p) local l = Instance.new("UIListLayout") l.Padding, l.Parent = UDim.new(0,4), p end
AddL(PESP) AddL(PAim) AddL(PTms)

local function CToggle(parent, name, def, cb)
    local f = Instance.new("Frame") f.Size, f.BackgroundColor3, f.Parent = UDim2.new(1,0,0,30), Color3.fromRGB(40,22,32), parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,5)
    local l = Instance.new("TextLabel") l.Size, l.Position, l.BackgroundTransparency, l.Text, l.TextColor3, l.Font, l.TextSize, l.TextXAlignment, l.Parent = UDim2.new(0.65,0,1,0), UDim2.new(0,8,0,0), 1, name, Color3.fromRGB(255,220,235), Enum.Font.GothamMedium, 10, Enum.TextXAlignment.Left, f
    local b = Instance.new("TextButton") b.Size, b.Position, b.BackgroundColor3, b.Text, b.TextColor3, b.Font, b.TextSize, b.Parent = UDim2.new(0,44,0,18), UDim2.new(1,-50,0.5,-9), def and Color3.fromRGB(255,110,150) or Color3.fromRGB(60,35,48), def and "ON" or "OFF", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 9, f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    local st = def
    b.MouseButton1Click:Connect(function()
        st = not st b.Text = st and "ON" or "OFF"
        b.BackgroundColor3 = st and Color3.fromRGB(255,110,150) or Color3.fromRGB(60,35,48)
        cb(st)
    end)
end

CToggle(PESP, "ESP Boxes", Config.ESPEnabled, function(v) Config.ESPEnabled = v end)
CToggle(PESP, "Tracers", Config.TracersEnabled, function(v) Config.TracersEnabled = v end)
CToggle(PESP, "Chams / Highlights", Config.HighlightsEnabled, function(v) Config.HighlightsEnabled = v end)
CToggle(PAim, "Show FOV Circle", Config.ShowFOV, function(v) Config.ShowFOV = v FOV.Visible = v end)

-- Opciones de AimLock
local TF = Instance.new("Frame") TF.Size, TF.BackgroundColor3, TF.Parent = UDim2.new(1,0,0,30), Color3.fromRGB(40,22,32), PAim
Instance.new("UICorner", TF).CornerRadius = UDim.new(0,5)
local TFL = Instance.new("TextLabel") TFL.Size, TFL.Position, TFL.BackgroundTransparency, TFL.Text, TFL.TextColor3, TFL.Font, TFL.TextSize, TFL.TextXAlignment, TFL.Parent = UDim2.new(0.5,0,1,0), UDim2.new(0,8,0,0), 1, "Target Part", Color3.fromRGB(255,220,235), Enum.Font.GothamMedium, 10, Enum.TextXAlignment.Left, TF
local TGB = Instance.new("TextButton") TGB.Size, TGB.Position, TGB.BackgroundColor3, TGB.Text, TGB.TextColor3, TGB.Font, TGB.TextSize, TGB.Parent = UDim2.new(0,70,0,18), UDim2.new(1,-76,0.5,-9), Color3.fromRGB(255,110,150), "HEAD", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 9, TF
Instance.new("UICorner", TGB).CornerRadius = UDim.new(0,4)
TGB.MouseButton1Click:Connect(function()
    Config.AimPart = Config.AimPart == "Head" and "HumanoidRootPart" or "Head"
    TGB.Text = Config.AimPart == "Head" and "HEAD" or "BODY"
end)

local MFm = Instance.new("Frame") MFm.Size, MFm.BackgroundColor3, MFm.Parent = UDim2.new(1,0,0,30), Color3.fromRGB(40,22,32), PAim
Instance.new("UICorner", MFm).CornerRadius = UDim.new(0,5)
local MFL = Instance.new("TextLabel") MFL.Size, MFL.Position, MFL.BackgroundTransparency, MFL.Text, MFL.TextColor3, MFL.Font, MFL.TextSize, MFL.TextXAlignment, MFL.Parent = UDim2.new(0.5,0,1,0), UDim2.new(0,8,0,0), 1, "Trigger Mode", Color3.fromRGB(255,220,235), Enum.Font.GothamMedium, 10, Enum.TextXAlignment.Left, MFm
local MDB = Instance.new("TextButton") MDB.Size, MDB.Position, MDB.BackgroundColor3, MDB.Text, MDB.TextColor3, MDB.Font, MDB.TextSize, MDB.Parent = UDim2.new(0,95,0,18), UDim2.new(1,-101,0.5,-9), Color3.fromRGB(255,110,150), "BUBBLE (MOBILE)", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 8, MFm
Instance.new("UICorner", MDB).CornerRadius = UDim.new(0,4)
MDB.MouseButton1Click:Connect(function()
    Config.AimMode = Config.AimMode == "Mobile (Bubble)" and "PC (Right Click)" or "Mobile (Bubble)"
    MDB.Text = Config.AimMode == "Mobile (Bubble)" and "BUBBLE (MOBILE)" or "RIGHT CLICK (PC)"
end)

-- Equipos
local function RefTeams()
    for _, c in ipairs(PTms:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local allT = Teams:GetTeams()
    if #allT == 0 then local n = Instance.new("TextLabel") n.Size, n.BackgroundTransparency, n.Text, n.TextColor3, n.Parent = UDim2.new(1,0,0,30), 1, "No teams available", Color3.fromRGB(200,160,180), PTms return end
    for _, t in ipairs(allT) do
        if Config.TeamFilter[t.Name] == nil then Config.TeamFilter[t.Name] = true end
        CToggle(PTms, "Team: "..t.Name, Config.TeamFilter[t.Name], function(v) Config.TeamFilter[t.Name] = v end)
    end
end
RefTeams() Teams.ChildAdded:Connect(RefTeams) Teams.ChildRemoved:Connect(RefTeams)

-- Créditos
local CTX = Instance.new("TextLabel") CTX.Size, CTX.BackgroundTransparency, CTX.Text, CTX.TextColor3, CTX.Font, CTX.TextSize, CTX.Parent = UDim2.new(1,0,0,40), 1, "🌸 SAKURA HUB v4.0\nCreated by: ColorOzz", Color3.fromRGB(255,200,220), Enum.Font.FredokaOne, 11, PCrd
local DCB = Instance.new("TextButton") DCB.Size, DCB.Position, DCB.BackgroundColor3, DCB.Text, DCB.TextColor3, DCB.Font, DCB.TextSize, DCB.Parent = UDim2.new(1,0,0,32), UDim2.new(0,0,0,48), Color3.fromRGB(255,110,150), "Copy Discord Invite", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 10, PCrd
Instance.new("UICorner", DCB).CornerRadius = UDim.new(0,6)
DCB.MouseButton1Click:Connect(function() if setclipboard then setclipboard(Config.DiscordInvite) DCB.Text = "Copied!" task.wait(2) DCB.Text = "Copy Discord Invite" end end)

UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.K then ToggleGUI(not MF.Visible) end end)

-- ESP Engine
local function AddP(p)
    if p == LP then return end
    local box, line, txt = Drawing.new("Square"), Drawing.new("Line"), Drawing.new("Text")
    box.Thickness, box.Filled, box.Transparency, box.Visible = 1.5, false, 1, false
    line.Thickness, line.Transparency, line.Visible = 1.2, 0.8, false
    txt.Color, txt.Size, txt.Center, txt.Outline, txt.Visible = Color3.fromRGB(255,255,255), 11, true, true, false
    local hl = Instance.new("Highlight") hl.FillTransparency, hl.OutlineTransparency, hl.Enabled = 0.6, 0.2, false
    ESP[p] = {Ch = p.Character, B = box, L = line, T = txt, H = hl}
    if p.Character then hl.Adornee, hl.Parent = p.Character, p.Character end
    p.CharacterAdded:Connect(function(c) ESP[p].Ch, hl.Adornee, hl.Parent = c, c, c end)
    p.CharacterRemoving:Connect(function()
