local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP, Camera = Players.LocalPlayer, workspace.CurrentCamera

if CoreGui:FindFirstChild("SakuraSplashScreenUI") then CoreGui.SakuraSplashScreenUI:Destroy() end
if LP:WaitForChild("PlayerGui"):FindFirstChild("SakuraSplashScreenUI") then LP.PlayerGui.SakuraSplashScreenUI:Destroy() end

local Config = {
    ESPEnabled = true, TracersEnabled = true, HighlightsEnabled = true,
    AimLockEnabled = false, AimMode = "Mobile (Bubble)", AimPart = "Head",
    AimSmoothness = 0.85, AimFOV = 130, ShowFOV = true, WallCheck = true,
    ShowWantedStars = true,
    DiscordInvite = "https://discord.gg/MfcZYtxuS", TeamFilter = {}
}
local ESP, IsAimingRightClick = {}, false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name, ScreenGui.ResetOnSpawn, ScreenGui.IgnoreGuiInset, ScreenGui.ZIndexBehavior = "SakuraSplashScreenUI", false, true, Enum.ZIndexBehavior.Sibling
local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

-- FOV & MainFrame
local FOV = Instance.new("Frame")
FOV.AnchorPoint, FOV.Position, FOV.Size, FOV.BackgroundTransparency, FOV.Visible, FOV.Parent = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), UDim2.new(0,260,0,260), 1, false, ScreenGui
Instance.new("UICorner", FOV).CornerRadius = UDim.new(1,0)
local FOVS = Instance.new("UIStroke", FOV) FOVS.Color, FOVS.Thickness = Color3.fromRGB(255,140,180), 1.8

local MF = Instance.new("Frame")
MF.Size, MF.Position, MF.BackgroundColor3, MF.Active, MF.Visible, MF.Parent = UDim2.new(0,350,0,260), UDim2.new(0.5,-175,0.5,-130), Color3.fromRGB(22,12,18), true, false, ScreenGui
Instance.new("UICorner", MF).CornerRadius = UDim.new(0,14)
local MS = Instance.new("UIStroke", MF) MS.Color, MS.Thickness = Color3.fromRGB(255,140,180), 1.8

-- Dragging
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

-- AimLock Floating Button
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
    QB.Text, QB.BackgroundColor3 = Config.AimLockEnabled and "🎯\nON" or "🎯\nOFF", Config.AimLockEnabled and Color3.fromRGB(255,110,150) or Color3.fromRGB(35,18,28)
end)

-- Tabs
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
CToggle(PESP, "Show Wanted Stars", Config.ShowWantedStars, function(v) Config.ShowWantedStars = v end)
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

local CTX = Instance.new("TextLabel") CTX.Size, CTX.BackgroundTransparency, CTX.Text, CTX.TextColor3, CTX.Font, CTX.TextSize, CTX.Parent = UDim2.new(1,0,0,40), 1, "🌸 SAKURA HUB v4.0\nCreated by: ColorOzz", Color3.fromRGB(255,200,220), Enum.Font.FredokaOne, 11, PCrd
local DCB = Instance.new("TextButton") DCB.Size, DCB.Position, DCB.BackgroundColor3, DCB.Text, DCB.TextColor3, DCB.Font, DCB.TextSize, DCB.Parent = UDim2.new(1,0,0,32), UDim2.new(0,0,0,48), Color3.fromRGB(255,110,150), "Copy Discord Invite", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 10, PCrd
Instance.new("UICorner", DCB).CornerRadius = UDim.new(0,6)
DCB.MouseButton1Click:Connect(function() if setclipboard then setclipboard(Config.DiscordInvite) DCB.Text = "Copied!" task.wait(2) DCB.Text = "Copy Discord Invite" end end)

UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.K then ToggleGUI(not MF.Visible) end end)

-- ESP & Aim Engine
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
    p.CharacterRemoving:Connect(function() ESP[p].Ch, hl.Adornee = nil, nil end)
end

local function RemP(p)
    local d = ESP[p] if not d then return end
    if d.B then d.B:Remove() end if d.L then d.L:Remove() end if d.T then d.T:Remove() end if d.H then d.H:Destroy() end
    ESP[p] = nil
end

for _, p in ipairs(Players:GetPlayers()) do AddP(p) end
Players.PlayerAdded:Connect(AddP) Players.PlayerRemoving:Connect(RemP)

local function GetWantedLevel(p)
    local s = p:FindFirstChild("leaderstats") or p:FindFirstChild("Stats") or p:FindFirstChild("Data")
    if s then
        local w = s:FindFirstChild("Wanted") or s:FindFirstChild("Stars") or s:FindFirstChild("Bounty") or s:FindFirstChild("WantedLevel")
        if w then return tonumber(w.Value) or 0 end
    end
    local wDirect = p:FindFirstChild("Wanted") or p:FindFirstChild("Stars")
    if wDirect then return tonumber(wDirect.Value) or 0 end
    return 0
end

local function IsEnemy(p)
    if not p.Team or not LP.Team then return true end
    local myTeam = LP.Team.Name:lower()
    local targetTeam = p.Team.Name:lower()
    
    if myTeam:find("police") or myTeam:find("cop") or myTeam:find("guard") or myTeam:find("policía") or myTeam:find("policia") then
        return targetTeam:find("civil") or targetTeam:find("citizen") or targetTeam:find("criminal")
    else
        return myTeam ~= targetTeam
    end
end

local function IsTargetVisible(part)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LP.Character, part.Parent}
    raycastParams.IgnoreWater = true

    local result = workspace:Raycast(origin, part.Position - origin, raycastParams)
    return result == nil
end

local function GetClosest()
    local cl, sd, vc = nil, Config.AimFOV, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and IsEnemy(p) and not (p.Team and Config.TeamFilter[p.Team.Name] == false) then
            local part, hum = p.Character:FindFirstChild(Config.AimPart), p.Character:FindFirstChild("Humanoid")
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

UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "PC (Right Click)" then IsAimingRightClick = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "PC (Right Click)" then IsAimingRightClick = false end end)

RunService.RenderStepped:Connect(function()
    if (Config.AimMode == "Mobile (Bubble)" and Config.AimLockEnabled) or (Config.AimMode == "PC (Right Click)" and IsAimingRightClick) then
        local t = GetClosest()
        if t and t.Character and t.Character:FindFirstChild(Config.AimPart) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Character[Config.AimPart].Position), Config.AimSmoothness)
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
                    
                    local strText = string.format("🌸 [%d m]", math.floor((lr.Position - root.Position).Magnitude))
                    if Config.ShowWantedStars then
                        local tName = p.Team and p.Team.Name:lower() or ""
                        if tName:find("civil") or tName:find("citizen") or tName:find("criminal") then
                            local stars = GetWantedLevel(p)
                            strText = strText .. string.format(" | ⭐ %d", stars)
                        end
                    end
                    
                    d.T.Text = strText
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

-- Splash Screen Minimalista (Solo Texto y Progress Bar)
local blur = Instance.new("BlurEffect") blur.Size, blur.Parent = 0, Lighting
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local MainFrame = Instance.new("Frame")
MainFrame.Name, MainFrame.Size, MainFrame.Position, MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency, MainFrame.BorderSizePixel, MainFrame.Parent = "MainFrame", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.fromRGB(28,14,25), 1, 0, ScreenGui
TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.25}):Play()

local CenterContainer = Instance.new("Frame")
CenterContainer.Name, CenterContainer.Size, CenterContainer.AnchorPoint, CenterContainer.Position, CenterContainer.BackgroundTransparency, CenterContainer.Parent = "CenterContainer", UDim2.new(0,260,0,100), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), 1, MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name, StatusLabel.Size, StatusLabel.AnchorPoint, StatusLabel.Position, StatusLabel.BackgroundTransparency, StatusLabel.Text, StatusLabel.TextColor3, StatusLabel.TextSize, StatusLabel.Font, StatusLabel.TextTransparency, StatusLabel.Parent = "StatusLabel", UDim2.new(1,0,0,30), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.3,0), 1, "", Color3.fromRGB(255,230,242), 18, Enum.Font.GothamBold, 1, CenterContainer

local ProgressBarBackground = Instance.new("Frame")
ProgressBarBackground.Name, ProgressBarBackground.Size, ProgressBarBackground.AnchorPoint, ProgressBarBackground.Position, ProgressBarBackground.BackgroundColor3, ProgressBarBackground.BackgroundTransparency, ProgressBarBackground.BorderSizePixel, ProgressBarBackground.Parent = "ProgressBarBackground", UDim2.new(1,0,0,6), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.7,0), Color3.fromRGB(60,30,50), 1, 0, CenterContainer
Instance.new("UICorner", ProgressBarBackground).CornerRadius = UDim.new(1,0)

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Name, ProgressBarFill.Size, ProgressBarFill.BackgroundColor3, ProgressBarFill.BorderSizePixel, ProgressBarFill.Parent = "ProgressBarFill", UDim2.new(0,0,1,0), Color3.fromRGB(255,140,185), 0, ProgressBarBackground
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1,0)

TweenService:Create(ProgressBarBackground, TweenInfo.new(0.6), {BackgroundTransparency = 0.5}):Play()

local sequence = {
    {text = "Loading resources...", progress = 0.35, duration = 1.2},
    {text = "Connecting to server...", progress = 0.75, duration = 1.4},
    {text = "Ready!", progress = 1.0, duration = 0.8}
}

task.spawn(function()
    task.wait(0.4)
    for _, step in ipairs(sequence) do
        StatusLabel.Text = step.text
        TweenService:Create(StatusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(ProgressBarFill, TweenInfo.new(step.duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(step.progress, 0, 1, 0)}):Play()
        task.wait(step.duration)
        if step.progress < 1 then
            local fadeOut = TweenService:Create(StatusLabel, TweenInfo.new(0.3), {TextTransparency = 1})
            fadeOut:Play() fadeOut.Completed:Wait()
        end
    end
    task.wait(0.6)
    local exitInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(blur, exitInfo, {Size = 0}):Play()
    TweenService:Create(MainFrame, exitInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(StatusLabel, exitInfo, {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBarBackground, exitInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressBarFill, exitInfo, {BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    
    blur:Destroy()
    MainFrame:Destroy()
    MF.Visible, QB.Visible, FOV.Visible = true, true, Config.ShowFOV
end)