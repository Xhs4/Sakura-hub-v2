local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LP, Camera = Players.LocalPlayer, workspace.CurrentCamera

-- Limpieza previa de interfaces antiguas
if CoreGui:FindFirstChild("SakuraMasterUI") then CoreGui.SakuraMasterUI:Destroy() end
if LP:WaitForChild("PlayerGui"):FindFirstChild("SakuraMasterUI") then LP.PlayerGui.SakuraMasterUI:Destroy() end

local Config = {
    ESPEnabled = true, TracersEnabled = true, HighlightsEnabled = true,
    AimLockEnabled = false, AimMode = "Mobile (Bubble)", AimPart = "Head",
    AimSmoothness = 0.35, AimFOV = 130, ShowFOV = true, WallCheck = true,
    DiscordInvite = "https://discord.gg/MfcZYtxuS", 
    KeyURL = "https://example.com/getkey",
    TeamFilter = {}
}

local ESP, IsAimingRightClick = {}, false
local KeyFileName = "Sakura_SavedKey.txt"
local IsAuthenticated = false -- Flag de seguridad

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- Guardado de Key Local
local function SaveKey(key)
    if writefile then pcall(function() writefile(KeyFileName, key) end) end
end

local function LoadSavedKey()
    if isfile and readfile and isfile(KeyFileName) then
        local success, result = pcall(function() return readfile(KeyFileName) end)
        if success and result then return result end
    end
    return nil
end

local function DeleteSavedKey()
    if isfile and delfile and isfile(KeyFileName) then
        pcall(function() delfile(KeyFileName) end)
    end
end

-- ScreenGui Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name, ScreenGui.ResetOnSpawn, ScreenGui.IgnoreGuiInset, ScreenGui.ZIndexBehavior = "SakuraMasterUI", false, true, Enum.ZIndexBehavior.Sibling
local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

local function MakeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

------------------------------------------------------------------------
-- 1. SPLASH SCREEN (PANTALLA DE CARGA CORREGIDA)
------------------------------------------------------------------------
local SplashBlur = Instance.new("BlurEffect") SplashBlur.Size, SplashBlur.Parent = 20, Lighting

local SplashFrame = Instance.new("Frame")
SplashFrame.Size, SplashFrame.Position, SplashFrame.BackgroundColor3, SplashFrame.BackgroundTransparency, SplashFrame.Parent = UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.fromRGB(12, 6, 10), 0.25, ScreenGui

local SplashCard = Instance.new("Frame")
SplashCard.Size, SplashCard.AnchorPoint, SplashCard.Position, SplashCard.BackgroundColor3, SplashCard.BackgroundTransparency, SplashCard.Parent = UDim2.new(0,280,0,160), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), Color3.fromRGB(25, 12, 20), 0.35, SplashFrame
Instance.new("UICorner", SplashCard).CornerRadius = UDim.new(0,18)
local SplashStroke = Instance.new("UIStroke", SplashCard) SplashStroke.Color, SplashStroke.Thickness = Color3.fromRGB(255, 140, 180), 1.5

local SplashIcon = Instance.new("TextLabel")
SplashIcon.Size, SplashIcon.Position, SplashIcon.BackgroundTransparency, SplashIcon.Text, SplashIcon.TextSize, SplashIcon.Parent = UDim2.new(1,0,0,50), UDim2.new(0,0,0,15), 1, "🌸", 40, SplashCard

local SplashTitle = Instance.new("TextLabel")
SplashTitle.Size, SplashTitle.Position, SplashTitle.BackgroundTransparency, SplashTitle.Text, SplashTitle.TextColor3, SplashTitle.Font, SplashTitle.TextSize, SplashTitle.Parent = UDim2.new(1,0,0,25), UDim2.new(0,0,0,65), 1, "SAKURA HUB", Color3.fromRGB(255, 192, 210), Enum.Font.FredokaOne, 18, SplashCard

local SplashBarBG = Instance.new("Frame")
SplashBarBG.Size, SplashBarBG.Position, SplashBarBG.BackgroundColor3, SplashBarBG.Parent = UDim2.new(0.8,0,0,6), UDim2.new(0.1,0,0,110), Color3.fromRGB(45, 20, 35), SplashCard
Instance.new("UICorner", SplashBarBG).CornerRadius = UDim.new(1,0)

local SplashBarFill = Instance.new("Frame")
SplashBarFill.Size, SplashBarFill.BackgroundColor3, SplashBarFill.Parent = UDim2.new(0,0,1,0), Color3.fromRGB(255, 110, 150), SplashBarBG
Instance.new("UICorner", SplashBarFill).CornerRadius = UDim.new(1,0)

local SplashSubText = Instance.new("TextLabel")
SplashSubText.Size, SplashSubText.Position, SplashSubText.BackgroundTransparency, SplashSubText.Text, SplashSubText.TextColor3, SplashSubText.Font, SplashSubText.TextSize, SplashSubText.Parent = UDim2.new(1,0,0,20), UDim2.new(0,0,0,125), 1, "Cargando componentes...", Color3.fromRGB(200, 150, 175), Enum.Font.GothamMedium, 10, SplashCard

------------------------------------------------------------------------
-- 2. PANEL DE KEY (ESTÉTICA SAKURA TRANSPARENTE)
------------------------------------------------------------------------
local LoginFrame = Instance.new("Frame")
LoginFrame.Name, LoginFrame.Size, LoginFrame.AnchorPoint, LoginFrame.Position, LoginFrame.BackgroundColor3, LoginFrame.BackgroundTransparency, LoginFrame.Visible, LoginFrame.Parent = "LoginFrame", UDim2.new(0,340,0,280), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), Color3.fromRGB(20, 10, 16), 0.35, false, ScreenGui
Instance.new("UICorner", LoginFrame).CornerRadius = UDim.new(0,18)
local LS = Instance.new("UIStroke", LoginFrame) LS.Color, LS.Thickness = Color3.fromRGB(255, 140, 180), 1.5
MakeDraggable(LoginFrame)

local LogoFrame = Instance.new("Frame")
LogoFrame.Size, LogoFrame.AnchorPoint, LogoFrame.Position, LogoFrame.BackgroundColor3, LogoFrame.BackgroundTransparency, LogoFrame.Parent = UDim2.new(0,50,0,50), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0,22), Color3.fromRGB(255, 110, 150), 0.2, LoginFrame
Instance.new("UICorner", LogoFrame).CornerRadius = UDim.new(1,0)

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Size, LogoIcon.BackgroundTransparency, LogoIcon.Text, LogoIcon.TextSize, LogoIcon.Parent = UDim2.new(1,0,1,0), 1, "🌸", 24, LogoFrame

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size, TitleLbl.Position, TitleLbl.BackgroundTransparency, TitleLbl.Text, TitleLbl.TextColor3, TitleLbl.Font, TitleLbl.TextSize, TitleLbl.Parent = UDim2.new(1,0,0,22), UDim2.new(0,0,0,52), 1, "Sakura Verification", Color3.fromRGB(255, 220, 235), Enum.Font.FredokaOne, 16, LoginFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size, StatusText.Position, StatusText.BackgroundTransparency, StatusText.Text, StatusText.TextColor3, StatusText.Font, StatusText.TextSize, StatusText.Parent = UDim2.new(1,0,0,20), UDim2.new(0,0,0,78), 1, "Ingresa tu Key para continuar", Color3.fromRGB(220, 170, 195), Enum.Font.GothamMedium, 11, LoginFrame

local KeyContainer = Instance.new("Frame")
KeyContainer.Size, KeyContainer.Position, KeyContainer.BackgroundColor3, KeyContainer.BackgroundTransparency, KeyContainer.Parent = UDim2.new(0.88,0,0,42), UDim2.new(0.06,0,0,108), Color3.fromRGB(35, 15, 28), 0.4, LoginFrame
Instance.new("UICorner", KeyContainer).CornerRadius = UDim.new(0,8)
local KeyStroke = Instance.new("UIStroke", KeyContainer) KeyStroke.Color, KeyStroke.Thickness = Color3.fromRGB(255, 140, 180), 1

local KeyBox = Instance.new("TextBox")
KeyBox.Size, KeyBox.Position, KeyBox.BackgroundTransparency, KeyBox.Text, KeyBox.PlaceholderText, KeyBox.TextColor3, KeyBox.PlaceholderColor3, KeyBox.Font, KeyBox.TextSize, KeyBox.ClearTextOnFocus, KeyBox.Parent = UDim2.new(1,-20,1,0), UDim2.new(0,10,0,0), 1, "", "Key aquí...", Color3.fromRGB(255, 230, 240), Color3.fromRGB(160, 110, 135), Enum.Font.Code, 11, false, KeyContainer

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size, GetKeyBtn.Position, GetKeyBtn.BackgroundColor3, GetKeyBtn.BackgroundTransparency, GetKeyBtn.Text, GetKeyBtn.TextColor3, GetKeyBtn.Font, GetKeyBtn.TextSize, GetKeyBtn.Parent = UDim2.new(0.42,0,0,38), UDim2.new(0.06,0,0,165), Color3.fromRGB(45, 20, 36), 0.3, "🔑 Get Key", Color3.fromRGB(255, 160, 190), Enum.Font.GothamBold, 11, LoginFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0,8)
local GKS = Instance.new("UIStroke", GetKeyBtn) GKS.Color, GKS.Thickness = Color3.fromRGB(255, 140, 180), 1

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size, CheckBtn.Position, CheckBtn.BackgroundColor3, CheckBtn.BackgroundTransparency, CheckBtn.Text, CheckBtn.TextColor3, CheckBtn.Font, CheckBtn.TextSize, CheckBtn.Parent = UDim2.new(0.44,0,0,38), UDim2.new(0.50,0,0,165), Color3.fromRGB(255, 110, 150), 0.2, "🛡️ Check Key", Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 11, LoginFrame
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0,8)

local FooterLbl = Instance.new("TextLabel")
FooterLbl.Size, FooterLbl.Position, FooterLbl.BackgroundTransparency, FooterLbl.Text, FooterLbl.TextColor3, FooterLbl.Font, FooterLbl.TextSize, FooterLbl.Parent = UDim2.new(1,0,0,20), UDim2.new(0,0,1,-24), 1, "where petals fall, magic follows", Color3.fromRGB(180, 130, 155), Enum.Font.GothamItalic, 10, LoginFrame

------------------------------------------------------------------------
-- 3. INTERFAZ PRINCIPAL DEL CHEAT (OCULTA HASTA VALIDACIÓN)
------------------------------------------------------------------------
local FOV = Instance.new("Frame")
FOV.AnchorPoint, FOV.Position, FOV.Size, FOV.BackgroundTransparency, FOV.Visible, FOV.Parent = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), UDim2.new(0,Config.AimFOV*2,0,Config.AimFOV*2), 1, false, ScreenGui
Instance.new("UICorner", FOV).CornerRadius = UDim.new(1,0)
local FOVS = Instance.new("UIStroke", FOV) FOVS.Color, FOVS.Thickness = Color3.fromRGB(255,140,180), 1.8

local MF = Instance.new("Frame")
MF.Size, MF.Position, MF.BackgroundColor3, MF.BackgroundTransparency, MF.Active, MF.Visible, MF.Parent = UDim2.new(0,350,0,260), UDim2.new(0.5,-175,0.5,-130), Color3.fromRGB(20, 10, 16), 0.25, true, false, ScreenGui
Instance.new("UICorner", MF).CornerRadius = UDim.new(0,14)
local MS = Instance.new("UIStroke", MF) MS.Color, MS.Thickness = Color3.fromRGB(255,140,180), 1.8
MakeDraggable(MF)

local TB = Instance.new("Frame") TB.Size, TB.BackgroundColor3, TB.BackgroundTransparency, TB.Parent = UDim2.new(1,0,0,38), Color3.fromRGB(35, 18, 28), 0.3, MF
Instance.new("UICorner", TB).CornerRadius = UDim.new(0,14)
local TBT = Instance.new("TextLabel") TBT.Size, TBT.Position, TBT.BackgroundTransparency, TBT.Text, TBT.TextColor3, TBT.Font, TBT.TextSize, TBT.TextXAlignment, TBT.Parent = UDim2.new(1,-90,1,0), UDim2.new(0,12,0,0), 1, "🌸 SAKURA HUB", Color3.fromRGB(255,192,210), Enum.Font.FredokaOne, 13, Enum.TextXAlignment.Left, TB

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size, OpenBtn.Position, OpenBtn.BackgroundColor3, OpenBtn.BackgroundTransparency, OpenBtn.Text, OpenBtn.TextColor3, OpenBtn.Font, OpenBtn.TextSize, OpenBtn.Visible, OpenBtn.Parent = UDim2.new(0,44,0,44), UDim2.new(0,12,0.5,-22), Color3.fromRGB(35, 18, 28), 0.3, "🌸", Color3.fromRGB(255,160,190), Enum.Font.GothamBold, 16, false, ScreenGui
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

local QB = Instance.new("TextButton")
QB.Size, QB.Position, QB.BackgroundColor3, QB.BackgroundTransparency, QB.Text, QB.TextColor3, QB.Font, QB.TextSize, QB.Visible, QB.Parent = UDim2.new(0,48,0,48), UDim2.new(0.85,0,0.3,0), Color3.fromRGB(35,18,28), 0.3, "🎯\nOFF", Color3.fromRGB(255,150,180), Enum.Font.GothamBold, 9, false, ScreenGui
Instance.new("UICorner", QB).CornerRadius = UDim.new(1,0)
local QS = Instance.new("UIStroke", QB) QS.Color, QS.Thickness = Color3.fromRGB(255,130,170), 2
MakeDraggable(QB)

QB.MouseButton1Click:Connect(function()
    Config.AimLockEnabled = not Config.AimLockEnabled
    QB.Text, QB.BackgroundColor3 = Config.AimLockEnabled and "🎯\nON" or "🎯\nOFF", Config.AimLockEnabled and Color3.fromRGB(255,110,150) or Color3.fromRGB(35,18,28)
end)

-- Pestañas
local TabBar = Instance.new("Frame") TabBar.Size, TabBar.Position, TabBar.BackgroundTransparency, TabBar.Parent = UDim2.new(1,-20,0,26), UDim2.new(0,10,0,44), 1, MF
local function CTab(txt, sz, pos)
    local b = Instance.new("TextButton")
    b.Size, b.Position, b.BackgroundColor3, b.TextColor3, b.Text, b.Font, b.TextSize, b.Parent = UDim2.new(sz,-2,1,0), pos, Color3.fromRGB(40,22,32), Color3.fromRGB(220,180,200), txt, Enum.Font.FredokaOne, 11, TabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    return b
end
local T1, T2, T3, T4 = CTab("ESP",0.25,UDim2.new(0,0,0,0)), CTab("Aimbot",0.25,UDim2.new(0.25,1,0,0)), CTab("Teams",0.25,UDim2.new(0.5,2,0,0)), CTab("Credits",0.25,UDim2.new(0.75,3,0,0))

local PC = Instance.new("Frame") PC.Size, PC.Position, PC.BackgroundTransparency, PC.Parent = UDim2.new(1,-20,1,-80), UDim2.new(0,10,0,74), 1, MF
local PESP, PAim, PTms, PCrd = Instance.new("Frame"), Instance.new("Frame"), Instance.new("ScrollingFrame"), Instance.new("Frame")
for _, p in ipairs({PESP, PAim, PTms, PCrd}) do p.Size, p.BackgroundTransparency, p.Visible, p.Parent = UDim2.new(1,0,1,0), 1, false, PC end
PESP.Visible, PTms.ScrollBarThickness = true, 3

local function STab(ap, ab)
    for _, p in ipairs({PESP, PAim, PTms, PCrd}) do p.Visible = false end
    for _, b in ipairs({T1, T2, T3, T4}) do b.BackgroundColor3 = Color3.fromRGB(40,22,32) end
    ap.Visible, ab.BackgroundColor3 = true, Color3.fromRGB(255,110,150)
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
        st = not st b.Text, b.BackgroundColor3 = st and "ON" or "OFF", st and Color3.fromRGB(255,110,150) or Color3.fromRGB(60,35,48)
        cb(st)
    end)
end

CToggle(PESP, "ESP Boxes", Config.ESPEnabled, function(v) Config.ESPEnabled = v end)
CToggle(PESP, "Tracers", Config.TracersEnabled, function(v) Config.TracersEnabled = v end)
CToggle(PESP, "Chams / Highlights", Config.HighlightsEnabled, function(v) Config.HighlightsEnabled = v end)
CToggle(PAim, "Show FOV Circle", Config.ShowFOV, function(v) Config.ShowFOV, FOV.Visible = v, v end)
CToggle(PAim, "Wall Check (Visible Only)", Config.WallCheck, function(v) Config.WallCheck = v end)

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

local CTX = Instance.new("TextLabel") CTX.Size, CTX.BackgroundTransparency, CTX.Text, CTX.TextColor3, CTX.Font, CTX.TextSize, CTX.Parent = UDim2.new(1,0,0,40), 1, "🌸 SAKURA HUB v5.0\nCreated by: ColorOzz", Color3.fromRGB(255,200,220), Enum.Font.FredokaOne, 11, PCrd
local DCB = Instance.new("TextButton") DCB.Size, DCB.Position, DCB.BackgroundColor3, DCB.Text, DCB.TextColor3, DCB.Font, DCB.TextSize, DCB.Parent = UDim2.new(1,0,0,32), UDim2.new(0,0,0,48), Color3.fromRGB(255,110,150), "Copy Discord Invite", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 10, PCrd
Instance.new("UICorner", DCB).CornerRadius = UDim.new(0,6)
DCB.MouseButton1Click:Connect(function() if setclipboard then setclipboard(Config.DiscordInvite) DCB.Text = "Copied!" task.wait(2) DCB.Text = "Copy Discord Invite" end end)

UserInputService.InputBegan:Connect(function(i, g)
    if IsAuthenticated and not g and i.KeyCode == Enum.KeyCode.K then
        ToggleGUI(not MF.Visible)
    end
end)

------------------------------------------------------------------------
-- 4. MOTOR PROTEGIDO (SOLO CORRE TRAS SER AUTENTICADO)
------------------------------------------------------------------------
local function AddP(p)
    if not IsAuthenticated or p == LP then return end
    local box, line, txt = Drawing.new("Square"), Drawing.new("Line"), Drawing.new("Text")
    box.Thickness, box.Filled, box.Transparency, box.Visible = 1.5, false, 1, false
    line.Thickness, line.Transparency, line.Visible = 1.2, 0.8, false
    txt.Color, txt.Size, txt.Center, txt.Outline, txt.Visible = Color3.fromRGB(255,255,255), 11, true, true, false
    local hl = Instance.new("Highlight") hl.FillTransparency, hl.OutlineTransparency, hl.Enabled = 0.6, 0.2, false
    ESP[p] = {Ch = p.Character, B = box, L = line, T = txt, H = hl}
    if p.Character then hl.Adornee, hl.Parent = p.Character, p.Character end
    p.CharacterAdded:Connect(function(c) ESP[p].Ch, hl.Adornee, hl.Parent = c, c, c end)
    p.CharacterRemoving:Connect(function() ESP[p].Ch, hl.Adornee = nil, nil end)
end

local function RemP(p)
    local d = ESP[p] if not d then return end
    if d.B then d.B:Remove() end if d.L then d.L:Remove() end if d.T then d.T:Remove() end if d.H then d.H:Destroy() end
    ESP[p] = nil
end

local function StartCheatEngine()
    for _, p in ipairs(Players:GetPlayers()) do AddP(p) end
    Players.PlayerAdded:Connect(AddP) Players.PlayerRemoving:Connect(RemP)
end

local function IsEnemy(p)
    if not p.Team or not LP.Team then return true end
    return LP.Team ~= p.Team
end

local function GetTargetPart(char)
    if not char then return nil end
    local part = char:FindFirstChild(Config.AimPart)
    if not part and Config.AimPart == "Head" then
        part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    elseif not part and Config.AimPart == "HumanoidRootPart" then
        part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("Head")
    end
    return part
end

local function IsTargetVisible(part)
    if not Config.WallCheck or not part then return true end
    local origin = Camera.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local filterList = {Camera, ScreenGui}
    if LP.Character then table.insert(filterList, LP.Character) end
    if part.Parent then table.insert(filterList, part.Parent) end
    
    raycastParams.FilterDescendantsInstances = filterList
    raycastParams.IgnoreWater = true

    local result = workspace:Raycast(origin, part.Position - origin, raycastParams)
    return result == nil
end

local function GetClosest()
    local cl, sd, vc = nil, Config.AimFOV, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and IsEnemy(p) and not (p.Team and Config.TeamFilter[p.Team.Name] == false) then
            local part = GetTargetPart(p.Character)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 and IsTargetVisible(part) then
                local pos, onS = Camera:WorldToViewportPoint(part.Position)
                if onS then
                    local dist = (Vector2.new(pos.X, pos.Y) - vc).Magnitude
                    if dist < sd then sd, cl = dist, p end
                end
            end
        end
    end
    return cl
end

UserInputService.InputBegan:Connect(function(i) if IsAuthenticated and i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "PC (Right Click)" then IsAimingRightClick = true end end)
UserInputService.InputEnded:Connect(function(i) if IsAuthenticated and i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "PC (Right Click)" then IsAimingRightClick = false end end)

RunService.RenderStepped:Connect(function()
    if not IsAuthenticated then return end

    if (Config.AimMode == "Mobile (Bubble)" and Config.AimLockEnabled) or (Config.AimMode == "PC (Right Click)" and IsAimingRightClick) then
        local t = GetClosest()
        if t and t.Character then
            local targetPart = GetTargetPart(t.Character)
            if targetPart then
                local currentCamPos = Camera.CFrame.Position
                local targetPos = targetPart.Position
                local targetCFrame = CFrame.new(currentCamPos, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.AimSmoothness)
            end
        end
    end

    local lc = LP.Character local lr = lc and lc:FindFirstChild("HumanoidRootPart")
    for p, d in pairs(ESP) do
        local char, root, head = d.Ch, d.Ch and d.Ch:FindFirstChild("HumanoidRootPart"), d.Ch and d.Ch:FindFirstChild("Head")
        if char and root and head and lr and IsEnemy(p) and not (p.Team and Config.TeamFilter[p.Team.Name] == false) then
            local pos, onS = Camera:WorldToViewportPoint(root.Position)
            if onS then
                local col = p.TeamColor and p.TeamColor.Color or Color3.fromRGB(255,110,150)
                local sc = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                local w, h = math.floor(4.5 * sc), math.floor(6.5 * sc)
                local x, y = math.floor(pos.X - w * 0.5), math.floor((pos.Y - h * 0.5) + (0.5 * sc))

                if Config.ESPEnabled then
                    d.B.Color, d.B.Position, d.B.Size, d.B.Visible = col, Vector2.new(x, y), Vector2.new(w, h), true
                    local hp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.8, 0))
                    
                    d.T.Text = string.format("🌸 [%d m]", math.floor((lr.Position - root.Position).Magnitude))
                    d.T.Position, d.T.Visible = Vector2.new(hp.X, hp.Y - 14), true
                else d.B.Visible, d.T.Visible = false, false end

                if Config.TracersEnabled then
                    d.L.Color, d.L.From, d.L.To, d.L.Visible = col, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y), Vector2.new(pos.X, pos.Y), true
                else d.L.Visible = false end

                if Config.HighlightsEnabled then d.H.FillColor, d.H.Enabled = col, true else d.H.Enabled = false end
            else d.B.Visible, d.T.Visible, d.L.Visible, d.H.Enabled = false, false, false, false end
        else d.B.Visible, d.T.Visible, d.L.Visible, d.H.Enabled = false, false, false, false end
    end
end)

------------------------------------------------------------------------
-- 5. LÓGICA DE UNLOCK Y VALIDACIÓN DE KEY
------------------------------------------------------------------------
local function UnlockScript()
    IsAuthenticated = true
    StartCheatEngine()
    
    TweenService:Create(SplashBlur, TweenInfo.new(0.4), {Size = 0}):Play()
    TweenService:Create(LoginFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    for _, v in ipairs(LoginFrame:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
            TweenService:Create(v, TweenInfo.new(0.4), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        elseif v:IsA("Frame") then
            TweenService:Create(v, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        end
    end
    task.wait(0.4)
    
    SplashBlur:Destroy()
    SplashFrame:Destroy()
    LoginFrame:Destroy()
    
    MF.Visible, QB.Visible, FOV.Visible = true, true, Config.ShowFOV
end

local function VerifyKey(enteredKey, isAutoLogin)
    if enteredKey == "" or not enteredKey then return end
    
    StatusText.Text = "🔄 Verificando..."
    StatusText.TextColor3 = Color3.fromRGB(255, 200, 120)
    CheckBtn.Text = "Checking..."
    
    task.wait(0.5)
    
    local isValid = false
    
    if httpRequest then
        pcall(function()
            local res = httpRequest({
                Url = Config.KeyURL .. "?key=" .. HttpService:UrlEncode(enteredKey),
                Method = "GET"
            })
            if res and res.StatusCode == 200 then
                isValid = res.Body:find("true") or res.Body:find("success")
            end
        end)
    end
    
    -- Fallback Key de prueba
    if not isValid and enteredKey == "b0be64a6-ad32-438e-aa36-0fe1384dd6d3" then
        isValid = true
    end

    if isValid then
        SaveKey(enteredKey)
        StatusText.Text = "✔ Acceso concedido"
        StatusText.TextColor3 = Color3.fromRGB(130, 225, 160)
        task.wait(0.4)
        UnlockScript()
    else
        DeleteSavedKey()
        if isAutoLogin then
            StatusText.Text = "⚠️ Key expirada, ingresa una nueva"
        else
            StatusText.Text = "❌ Key inválida"
        end
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 120)
        CheckBtn.Text = "🛡️ Check Key"
    end
end

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Config.KeyURL)
        GetKeyBtn.Text = "Copied!"
        task.wait(1.5)
        GetKeyBtn.Text = "🔑 Get Key"
    end
end)

CheckBtn.MouseButton1Click:Connect(function()
    VerifyKey(KeyBox.Text, false)
end)

------------------------------------------------------------------------
-- 6. FLUKO DE EJECUCIÓN (SPLASH -> LOGIN AUTOMÁTICO SÍN CONGELAMIENTO)
------------------------------------------------------------------------
task.spawn(function()
    -- Animación de la barra de carga
    SplashSubText.Text = "Cargando recursos..."
    local tween1 = TweenService:Create(SplashBarFill, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.6, 0, 1, 0)})
    tween1:Play()
    tween1.Completed:Wait()
    
    SplashSubText.Text = "Verificando achivos..."
    local tween2 = TweenService:Create(SplashBarFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    tween2:Play()
    tween2.Completed:Wait()
    
    task.wait(0.2)
    
    -- Transición limpia fuera de la pantalla de carga
    for _, v in ipairs(SplashCard:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("Frame") then
            TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            if v:IsA("TextLabel") then
                TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            end
        end
    end
    TweenService:Create(SplashCard, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    
    SplashCard:Destroy()
    LoginFrame.Visible = true
    
    -- Carga de Key guardada si existe
    local savedKey = LoadSavedKey()
    if savedKey and savedKey ~= "" then
        KeyBox.Text = savedKey
        VerifyKey(savedKey, true)
    end
end)