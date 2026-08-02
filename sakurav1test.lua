if not game:IsLoaded() then game.Loaded:Wait() end
local P,T,R,U,TW,C,LP = game:GetService("Players"),game:GetService("Teams"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("TweenService"),workspace.CurrentCamera,game:GetService("Players").LocalPlayer

local Config = {ESPEnabled=true,TracersEnabled=true,HighlightsEnabled=true,AimLockEnabled=false,AimMode="Mobile (Burbuja)",AimPart="Head",AimSmoothness=0.85,AimFOV=130,ShowFOV=true,DiscordInvite="https://discord.gg/MfcZYtxuS",TeamFilter={}}
local ESP,IsAimingRightClick = {},false

local SG = Instance.new("ScreenGui")
SG.Name = "Sakura_Hub"
SG.ResetOnSpawn = false
SG.Parent = LP:WaitForChild("PlayerGui")

-- Splash Sakura
local SF = Instance.new("Frame")
SF.Size,SF.Position,SF.BackgroundColor3,SF.ZIndex,SF.Parent = UDim2.new(0,280,0,130),UDim2.new(0.5,-140,0.5,-65),Color3.fromRGB(22,12,18),100,SG
Instance.new("UICorner",SF).CornerRadius = UDim.new(0,14)
local SS = Instance.new("UIStroke",SF) SS.Color = Color3.fromRGB(255,140,180) SS.Thickness = 2

local ST = Instance.new("TextLabel")
ST.Size,ST.Position,ST.BackgroundTransparency,ST.Text,ST.TextColor3,ST.Font,ST.TextSize,ST.ZIndex,ST.Parent = UDim2.new(1,0,0,50),UDim2.new(0,0,0,20),1,"🌸 桜 SAKURA HUB 🌸",Color3.fromRGB(255,180,210),Enum.Font.GothamBold,16,101,SF

local SSB = Instance.new("TextLabel")
SSB.Size,SSB.Position,SSB.BackgroundTransparency,SSB.Text,SSB.TextColor3,SSB.Font,SSB.TextSize,SSB.ZIndex,SSB.Parent = UDim2.new(1,0,0,30),UDim2.new(0,0,0,70),1,"Iniciando...",Color3.fromRGB(255,210,230),Enum.Font.GothamMedium,11,101,SF

-- FOV Circle
local FOV = Instance.new("Frame")
FOV.AnchorPoint,FOV.Position,FOV.Size,FOV.BackgroundTransparency,FOV.Visible,FOV.Parent = Vector2.new(0.5,0.5),UDim2.new(0.5,0,0.5,0),UDim2.new(0,260,0,260),1,false,SG
Instance.new("UICorner",FOV).CornerRadius = UDim.new(1,0)
local FOVS = Instance.new("UIStroke",FOV) FOVS.Color,FOVS.Thickness = Color3.fromRGB(255,140,180),1.8

-- Main Frame
local MF = Instance.new("Frame")
MF.Size,MF.Position,MF.BackgroundColor3,MF.Active,MF.Visible,MF.Parent = UDim2.new(0,350,0,260),UDim2.new(0.5,-175,0.5,-130),Color3.fromRGB(22,12,18),true,false,SG
Instance.new("UICorner",MF).CornerRadius = UDim.new(0,14)
local MS = Instance.new("UIStroke",MF) MS.Color,MS.Thickness = Color3.fromRGB(255,140,180),1.8

-- Drag
local dragging,dragStart,startPos
MF.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging,dragStart,startPos = true,i.Position,MF.Position end end)
U.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart MF.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

-- TopBar
local TB = Instance.new("Frame")
TB.Size,TB.BackgroundColor3,TB.Parent = UDim2.new(1,0,0,38),Color3.fromRGB(35,18,28),MF
Instance.new("UICorner",TB).CornerRadius = UDim.new(0,14)

local TBT = Instance.new("TextLabel")
TBT.Size,TBT.Position,TBT.BackgroundTransparency,TBT.Text,TBT.TextColor3,TBT.Font,TBT.TextSize,TBT.TextXAlignment,TBT.Parent = UDim2.new(1,-90,1,0),UDim2.new(0,12,0,0),1,"🌸 SAKURA HUB",Color3.fromRGB(255,192,210),Enum.Font.GothamBold,12,Enum.TextXAlignment.Left,TB

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size,OpenBtn.Position,OpenBtn.BackgroundColor3,OpenBtn.Text,OpenBtn.TextColor3,OpenBtn.Font,OpenBtn.TextSize,OpenBtn.Visible,OpenBtn.Parent = UDim2.new(0,44,0,44),UDim2.new(0,12,0.5,-22),Color3.fromRGB(35,18,28),"🌸",Color3.fromRGB(255,160,190),Enum.Font.GothamBold,16,false,SG
Instance.new("UICorner",OpenBtn).CornerRadius = UDim.new(1,0)
local OS = Instance.new("UIStroke",OpenBtn) OS.Color,OS.Thickness = Color3.fromRGB(255,140,180),2

local MinBtn = Instance.new("TextButton")
MinBtn.Size,MinBtn.Position,MinBtn.BackgroundColor3,MinBtn.Text,MinBtn.TextColor3,MinBtn.Font,MinBtn.TextSize,MinBtn.Parent = UDim2.new(0,26,0,26),UDim2.new(1,-60,0.5,-13),Color3.fromRGB(50,28,40),"—",Color3.fromRGB(255,190,210),Enum.Font.GothamBold,11,TB
Instance.new("UICorner",MinBtn).CornerRadius = UDim.new(0,5)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size,CloseBtn.Position,CloseBtn.BackgroundColor3,CloseBtn.Text,CloseBtn.TextColor3,CloseBtn.Font,CloseBtn.TextSize,CloseBtn.Parent = UDim2.new(0,26,0,26),UDim2.new(1,-30,0.5,-13),Color3.fromRGB(255,110,150),"🌸",Color3.fromRGB(255,255,255),Enum.Font.GothamBold,11,TB
Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(0,5)

local function ToggleGUI(s) MF.Visible,OpenBtn.Visible = s,not s end
MinBtn.MouseButton1Click:Connect(function() ToggleGUI(false) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleGUI(false) end)
OpenBtn.MouseButton1Click:Connect(function() ToggleGUI(true) end)

-- Quick Bubble Aim
local QB = Instance.new("TextButton")
QB.Size,QB.Position,QB.BackgroundColor3,QB.Text,QB.TextColor3,QB.Font,QB.TextSize,QB.Visible,QB.Parent = UDim2.new(0,48,0,48),UDim2.new(0.85,0,0.3,0),Color3.fromRGB(35,18,28),"🎯\nOFF",Color3.fromRGB(255,150,180),Enum.Font.GothamBold,9,false,SG
Instance.new("UICorner",QB).CornerRadius = UDim.new(1,0)
local QS = Instance.new("UIStroke",QB) QS.Color,QS.Thickness = Color3.fromRGB(255,130,170),2

local bDrag,bStart,bPos
QB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then bDrag,bStart,bPos = true,i.Position,QB.Position end end)
U.InputChanged:Connect(function(i) if bDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - bStart QB.Position = UDim2.new(bPos.X.Scale,bPos.X.Offset+d.X,bPos.Y.Scale,bPos.Y.Offset+d.Y) end end)
U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then bDrag = false end end)

QB.MouseButton1Click:Connect(function()
Config.AimLockEnabled = not Config.AimLockEnabled
QB.Text = Config.AimLockEnabled and "🎯\nON" or "🎯\nOFF"
QB.BackgroundColor3 = Config.AimLockEnabled and Color3.fromRGB(255,110,150) or Color3.fromRGB(35,18,28)
end)

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size,TabBar.Position,TabBar.BackgroundTransparency,TabBar.Parent = UDim2.new(1,-20,0,26),UDim2.new(0,10,0,44),1,MF

local function CTab(txt,sz,pos)
local b = Instance.new("TextButton")
b.Size,b.Position,b.BackgroundColor3,b.TextColor3,b.Text,b.Font,b.TextSize,b.Parent = UDim2.new(sz,-2,1,0),pos,Color3.fromRGB(40,22,32),Color3.fromRGB(220,180,200),txt,Enum.Font.GothamSemibold,10,TabBar
Instance.new("UICorner",b).CornerRadius = UDim.new(0,5)
return b
end

local T1,T2,T3,T4 = CTab("ESP",0.25,UDim2.new(0,0,0,0)),CTab("Aim",0.25,UDim2.new(0.25,1,0,0)),CTab("Equipos",0.25,UDim2.new(0.5,2,0,0)),CTab("Créditos",0.25,UDim2.new(0.75,3,0,0))

local PC = Instance.new("Frame")
PC.Size,PC.Position,PC.BackgroundTransparency,PC.Parent = UDim2.new(1,-20,1,-80),UDim2.new(0,10,0,74),1,MF

local PESP,PAim,PTms,PCrd = Instance.new("Frame"),Instance.new("Frame"),Instance.new("ScrollingFrame"),Instance.new("Frame")
for _,p in ipairs({PESP,PAim,PTms,PCrd}) do p.Size,p.BackgroundTransparency,p.Visible,p.Parent = UDim2.new(1,0,1,0),1,false,PC end
PESP.Visible = true PTms.ScrollBarThickness = 3

local function STab(ap,ab)
for _,p in ipairs({PESP,PAim,PTms,PCrd}) do p.Visible = false end
for _,b in ipairs({T1,T2,T3,T4}) do b.BackgroundColor3 = Color3.fromRGB(40,22,32) end
ap.Visible = true ab.BackgroundColor3 = Color3.fromRGB(255,110,150)
end

T1.MouseButton1Click:Connect(function() STab(PESP,T1) end)
T2.MouseButton1Click:Connect(function() STab(PAim,T2) end)
T3.MouseButton1Click:Connect(function() STab(PTms,T3) end)
T4.MouseButton1Click:Connect(function() STab(PCrd,T4) end)
T1.BackgroundColor3 = Color3.fromRGB(255,110,150)

local function AddL(p) local l = Instance.new("UIListLayout") l.Padding,l.Parent = UDim.new(0,4),p end
AddL(PESP) AddL(PAim) AddL(PTms)

local function CToggle(parent,name,def,cb)
local f = Instance.new("Frame")
f.Size,f.BackgroundColor3,f.Parent = UDim2.new(1,0,0,30),Color3.fromRGB(40,22,32),parent
Instance.new("UICorner",f).CornerRadius = UDim.new(0,5)

local l = Instance.new("TextLabel")
l.Size,l.Position,l.BackgroundTransparency,l.Text,l.TextColor3,l.Font,l.TextSize,l.TextXAlignment,l.Parent = UDim2.new(0.65,0,1,0),UDim2.new(0,8,0,0),1,name,Color3.fromRGB(255,220,235),Enum.Font.GothamMedium,10,Enum.TextXAlignment.Left,f

local b = Instance.new("TextButton")
b.Size,b.Position,b.BackgroundColor3,b.Text,b.TextColor3,b.Font,b.TextSize,b.Parent = UDim2.new(0,44,0,18),UDim2.new(1,-50,0.5,-9),def and Color3.fromRGB(255,110,150) or Color3.fromRGB(60,35,48),def and "ON" or "OFF",Color3.fromRGB(255,255,255),Enum.Font.GothamBold,9,f
Instance.new("UICorner",b).CornerRadius = UDim.new(0,4)

local st = def
b.MouseButton1Click:Connect(function()
st = not st b.Text = st and "ON" or "OFF"
b.BackgroundColor3 = st and Color3.fromRGB(255,110,150) or Color3.fromRGB(60,35,48)
cb(st)
end)
end

CToggle(PESP,"Cuadros (Boxes)",Config.ESPEnabled,function(v) Config.ESPEnabled=v end)
CToggle(PESP,"Líneas (Tracers)",Config.TracersEnabled,function(v) Config.TracersEnabled=v end)
CToggle(PESP,"Resaltado (Chams)",Config.HighlightsEnabled,function(v) Config.HighlightsEnabled=v end)

CToggle(PAim,"Mostrar FOV",Config.ShowFOV,function(v) Config.ShowFOV=v FOV.Visible=v end)

-- Target Button
local TF = Instance.new("Frame")
TF.Size,TF.BackgroundColor3,TF.Parent = UDim2.new(1,0,0,30),Color3.fromRGB(40,22,32),PAim
Instance.new("UICorner",TF).CornerRadius = UDim.new(0,5)
local TFL = Instance.new("TextLabel") TFL.Size,TFL.Position,TFL.BackgroundTransparency,TFL.Text,TFL.TextColor3,TFL.Font,TFL.TextSize,TFL.TextXAlignment,TFL.Parent = UDim2.new(0.5,0,1,0),UDim2.new(0,8,0,0),1,"Apuntar a",Color3.fromRGB(255,220,235),Enum.Font.GothamMedium,10,Enum.TextXAlignment.Left,TF
local TGB = Instance.new("TextButton") TGB.Size,TGB.Position,TGB.BackgroundColor3,TGB.Text,TGB.TextColor3,TGB.Font,TGB.TextSize,TGB.Parent = UDim2.new(0,70,0,18),UDim2.new(1,-76,0.5,-9),Color3.fromRGB(255,110,150),"CABEZA",Color3.fromRGB(255,255,255),Enum.Font.GothamBold,9,TF
Instance.new("UICorner",TGB).CornerRadius = UDim.new(0,4)
TGB.MouseButton1Click:Connect(function()
Config.AimPart = Config.AimPart == "Head" and "HumanoidRootPart" or "Head"
TGB.Text = Config.AimPart == "Head" and "CABEZA" or "CUERPO"
end)

-- Mode Button
local MFm = Instance.new("Frame")
MFm.Size,MFm.BackgroundColor3,MFm.Parent = UDim2.new(1,0,0,30),Color3.fromRGB(40,22,32),PAim
Instance.new("UICorner",MFm).CornerRadius = UDim.new(0,5)
local MFL = Instance.new("TextLabel") MFL.Size,MFL.Position,MFL.BackgroundTransparency,MFL.Text,MFL.TextColor3,MFL.Font,MFL.TextSize,MFL.TextXAlignment,MFL.Parent = UDim2.new(0.5,0,1,0),UDim2.new(0,8,0,0),1,"Modo",Color3.fromRGB(255,220,235),Enum.Font.GothamMedium,10,Enum.TextXAlignment.Left,MFm
local MDB = Instance.new("TextButton") MDB.Size,MDB.Position,MDB.BackgroundColor3,MDB.Text,MDB.TextColor3,MDB.Font,MDB.TextSize,MDB.Parent = UDim2.new(0,95,0,18),UDim2.new(1,-101,0.5,-9),Color3.fromRGB(255,110,150),"BURBUJA (MÓVIL)",Color3.fromRGB(255,255,255),Enum.Font.GothamBold,8,MFm
Instance.new("UICorner",MDB).CornerRadius = UDim.new(0,4)
MDB.MouseButton1Click:Connect(function()
Config.AimMode = Config.AimMode == "Mobile (Burbuja)" and "PC (Click Derecho)" or "Mobile (Burbuja)"
MDB.Text = Config.AimMode == "Mobile (Burbuja)" and "BURBUJA (MÓVIL)" or "CLICK DER. (PC)"
end)

-- Teams
local function RefTeams()
for _,c in ipairs(PTms:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
local allT = T:GetTeams()
if #allT == 0 then local n=Instance.new("TextLabel") n.Size,n.BackgroundTransparency,n.Text,n.TextColor3,n.Parent = UDim2.new(1,0,0,30),1,"Sin equipos",Color3.fromRGB(200,160,180),PTms return end
for _,t in ipairs(allT) do
if Config.TeamFilter[t.Name] == nil then Config.TeamFilter[t.Name] = true end
CToggle(PTms,"Equipo: "..t.Name,Config.TeamFilter[t.Name],function(v) Config.TeamFilter[t.Name]=v end)
end
end
RefTeams() T.ChildAdded:Connect(RefTeams) T.ChildRemoved:Connect(RefTeams)

-- Credits
local CTX = Instance.new("TextLabel") CTX.Size,CTX.BackgroundTransparency,CTX.Text,CTX.TextColor3,CTX.Font,CTX.TextSize,CTX.Parent = UDim2.new(1,0,0,40),1,"🌸 SAKURA HUB v4.0\nCreado por: ColorOzz",Color3.fromRGB(255,200,220),Enum.Font.GothamMedium,10,PCrd
local DCB = Instance.new("TextButton") DCB.Size,DCB.Position,DCB.BackgroundColor3,DCB.Text,DCB.TextColor3,DCB.Font,DCB.TextSize,DCB.Parent = UDim2.new(1,0,0,32),UDim2.new(0,0,0,48),Color3.fromRGB(255,110,150),"Copiar Discord",Color3.fromRGB(255,255,255),Enum.Font.GothamBold,10,PCrd
Instance.new("UICorner",DCB).CornerRadius = UDim.new(0,6)
DCB.MouseButton1Click:Connect(function() if setclipboard then setclipboard(Config.DiscordInvite) DCB.Text = "¡Copiado!" task.wait(2) DCB.Text = "Copiar Discord" end end)

U.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Enum.KeyCode.K then ToggleGUI(not MF.Visible) end end)

-- ESP Engine
local function AddP(p)
if p == LP then return end
local box,line,txt = Drawing.new("Square"),Drawing.new("Line"),Drawing.new("Text")
box.Thickness,box.Filled,box.Transparency,box.Visible = 1.5,false,1,false
line.Thickness,line.Transparency,line.Visible = 1.2,0.8,false
txt.Color,txt.Size,txt.Center,txt.Outline,txt.Visible = Color3.fromRGB(255,255,255),11,true,true,false
local hl = Instance.new("Highlight") hl.FillTransparency,hl.OutlineTransparency,hl.Enabled = 0.6,0.2,false
ESP[p] = {Ch=p.Character,B=box,L=line,T=txt,H=hl}
if p.Character then hl.Adornee,hl.Parent = p.Character,p.Character end
p.CharacterAdded:Connect(function(c) ESP[p].Ch,hl.Adornee,hl.Parent = c,c,c end)
p.CharacterRemoving:Connect(function() ESP[p].Ch,hl.Adornee = nil,nil end)
end

local function RemP(p)
local d = ESP[p] if not d then return end
if d.B then d.B:Remove() end if d.L then d.L:Remove() end if d.T then d.T:Remove() end if d.H then d.H:Destroy() end
ESP[p] = nil
end

for _,p in ipairs(P:GetPlayers()) do AddP(p) end
P.PlayerAdded:Connect(AddP) P.PlayerRemoving:Connect(RemP)

local function GetClosest()
local cl,sd,vc = nil,Config.AimFOV,Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2)
for _,p in ipairs(P:GetPlayers()) do
if p ~= LP and p.Character and not (p.Team and Config.TeamFilter[p.Team.Name] == false) then
local part,hum = p.Character:FindFirstChild(Config.AimPart),p.Character:FindFirstChild("Humanoid")
if part and hum and hum.Health > 0 then
local pos,onS = C:WorldToViewportPoint(part.Position)
if onS then
local dist = (Vector2.new(pos.X,pos.Y)-vc).Magnitude
if dist < sd then sd,cl = dist,p end
end end end end
return cl
end

U.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "PC (Click Derecho)" then IsAimingRightClick = true end end)
U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "PC (Click Derecho)" then IsAimingRightClick = false end end)

-- Render Loop
R.RenderStepped:Connect(function()
if (Config.AimMode == "Mobile (Burbuja)" and Config.AimLockEnabled) or (Config.AimMode == "PC (Click Derecho)" and IsAimingRightClick) then
local t = GetClosest()
if t and t.Character and t.Character:FindFirstChild(Config.AimPart) then
C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position,t.Character[Config.AimPart].Position),Config.AimSmoothness)
end end

local lc = LP.Character local lr = lc and lc:FindFirstChild("HumanoidRootPart")
for p,d in pairs(ESP) do
local char,root,head = d.Ch,d.Ch and d.Ch:FindFirstChild("HumanoidRootPart"),d.Ch and d.Ch:FindFirstChild("Head")
if char and root and head and lr and not (p.Team and Config.TeamFilter[p.Team.Name] == false) then
local pos,onS = C:WorldToViewportPoint(root.Position)
if onS then
local col = p.TeamColor and p.TeamColor.Color or Color3.fromRGB(255,110,150)
local sc = 1 / (pos.Z * math.tan(math.rad(C.FieldOfView * 0.5)) * 2) * 1000
local w,h = math.floor(4.5 * sc),math.floor(6.5 * sc)
local x,y = math.floor(pos.X - w * 0.5),math.floor((pos.Y - h * 0.5) + (0.5 * sc))

if Config.ESPEnabled then
d.B.Color,d.B.Position,d.B.Size,d.B.Visible = col,Vector2.new(x,y),Vector2.new(w,h),true
local hp = C:WorldToViewportPoint(head.Position + Vector3.new(0,1.8,0))
d.T.Text = string.format("🌸 [%d m]",math.floor((lr.Position - root.Position).Magnitude))
d.T.Position,d.T.Visible = Vector2.new(hp.X,hp.Y - 14),true
else d.B.Visible,d.T.Visible = false,false end

if Config.TracersEnabled then
d.L.Color,d.L.From,d.L.To,d.L.Visible = col,Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y),Vector2.new(pos.X,pos.Y),true
else d.L.Visible = false end

if Config.HighlightsEnabled then d.H.FillColor,d.H.Enabled = col,true else d.H.Enabled = false end
else d.B.Visible,d.T.Visible,d.L.Visible,d.H.Enabled = false,false,false,false end
else d.B.Visible,d.T.Visible,d.L.Visible,d.H.Enabled = false,false,false,false end
end
end)

-- Transición instantánea y segura de Splash a GUI
TW:Create(SF,TweenInfo.new(0.6),{BackgroundTransparency=1}):Play()
TW:Create(SS,TweenInfo.new(0.6),{Transparency=1}):Play()
TW:Create(ST,TweenInfo.new(0.6),{TextTransparency=1}):Play()
local t = TW:Create(SSB,TweenInfo.new(0.6),{TextTransparency=1}) t:Play()
t.Completed:Connect(function()
SF:Destroy()
MF.Visible = true
QB.Visible = true
FOV.Visible = Config.ShowFOV
end)
