local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ===== ESTADO DEL PERSONAJE =====
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	Humanoid = newChar:WaitForChild("Humanoid")
	RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ===== CONFIG AIMBOT =====
local AimbotEnabled = false
local MaxDistance = 250
local AimPart = "Head"
local FovRadius = 0
local Smoothness = 20 -- Velocidad de enganche rápida para evitar latencia en el arma

-- ===== CONFIG ESP =====
local EspEnabled = false
local EspObjects = {}

-- ===== CORES TEMA =====
local C = {
	bg = Color3.fromRGB(8, 12, 8),
	bg2 = Color3.fromRGB(12, 20, 12),
	bg3 = Color3.fromRGB(18, 30, 18),
	green = Color3.fromRGB(0, 255, 100),
	greenD = Color3.fromRGB(0, 180, 60),
	greenD2 = Color3.fromRGB(0, 100, 30),
	greenG = Color3.fromRGB(0, 255, 120),
	text = Color3.fromRGB(180, 255, 180),
	textD = Color3.fromRGB(60, 120, 60),
	red = Color3.fromRGB(255, 40, 40),
}

-- ===== TWEEN =====
local function tw(obj, props, dur, ease)
	local ti = TweenInfo.new(dur or 0.3, ease or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, ti, props)
	t:Play()
	return t
end

-- ===== MOBILE DETECT =====
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local dw = isMobile and 220 or 190
local dh = isMobile and 270 or 240

-- ================= GUI PRINCIPAL =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, dw, 0, dh)
Frame.Position = UDim2.new(0.5, -dw/2, 0.5, -dh/2)
Frame.BackgroundColor3 = C.bg
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Active = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)

local FrameStroke = Instance.new("UIStroke", Frame)
FrameStroke.Thickness = 1.5
FrameStroke.Color = C.green
FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- ===== TOP BAR =====
local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = C.bg2
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

local Div = Instance.new("Frame", TopBar)
Div.Size = UDim2.new(1, -20, 0, 1)
Div.Position = UDim2.new(0, 10, 1, -1)
Div.BackgroundColor3 = C.greenD2
Div.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "0101101"
Title.Font = Enum.Font.Code
Title.TextSize = isMobile and 14 or 13
Title.TextColor3 = C.green
Title.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
	while true do
		task.wait(0.15)
		local str = ""
		for i = 1, 12 do
			str = str .. math.random(0, 1)
		end
		Title.Text = "> " .. str
	end
end)

-- ===== BOTÓN MINIMIZAR =====
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -32, 0, 5)
MinBtn.Text = "X"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = C.green
MinBtn.BackgroundColor3 = C.bg3
MinBtn.BackgroundTransparency = 0.3
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

-- ===== BOLA MINIMIZADA =====
local Ball = Instance.new("TextButton", ScreenGui)
Ball.Size = UDim2.new(0, 50, 0, 50)
Ball.Position = Frame.Position
Ball.BackgroundColor3 = C.bg2
Ball.BorderSizePixel = 0
Ball.Visible = false
Ball.Text = ""
Ball.AutoButtonColor = false
Ball.ZIndex = 999
Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)

local BallStroke = Instance.new("UIStroke", Ball)
BallStroke.Thickness = 2
BallStroke.Color = C.green
BallStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local BallLabel = Instance.new("TextLabel", Ball)
BallLabel.Size = UDim2.new(1, 0, 1, 0)
BallLabel.BackgroundTransparency = 1
BallLabel.Text = "Z"
BallLabel.Font = Enum.Font.GothamBold
BallLabel.TextSize = 24
BallLabel.TextColor3 = C.green
BallLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ================= CONTEÚDO =================
local Content = Instance.new("Frame", Frame)
Content.Size = UDim2.new(1, -12, 1, -44)
Content.Position = UDim2.new(0, 6, 0, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ===== HELPER BOTÓN =====
local function makeBtn(text, color, order, fn)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, isMobile and 38 or 32)
	b.BackgroundColor3 = color
	b.BackgroundTransparency = 0.15
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.Text = ""
	b.LayoutOrder = order or 1
	b.Parent = Content
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	
	local st = Instance.new("UIStroke", b)
	st.Thickness = 1
	st.Color = C.green
	st.Transparency = 0.5
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	
	local l = Instance.new("TextLabel", b)
	l.Size = UDim2.new(1, 0, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.Code
	l.TextSize = isMobile and 13 or 12
	l.TextColor3 = C.text
	l.TextXAlignment = Enum.TextXAlignment.Center
	
	b.MouseButton1Click:Connect(function()
		if fn then fn(b, l) end
	end)
	
	return b, l
end

-- ===== HELPER SLIDER =====
local function makeSlider(label, init, mn, mx, order, fn)
	local con = Instance.new("Frame", Content)
	con.Size = UDim2.new(1, -4, 0, isMobile and 46 or 38)
	con.BackgroundColor3 = C.bg3
	con.BackgroundTransparency = 0.2
	con.BorderSizePixel = 0
	con.LayoutOrder = order or 1
	Instance.new("UICorner", con).CornerRadius = UDim.new(0, 10)
	
	local sst = Instance.new("UIStroke", con)
	sst.Thickness = 1
	sst.Color = C.green
	sst.Transparency = 0.6
	sst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	
	local sl = Instance.new("TextLabel", con)
	sl.Size = UDim2.new(1, -16, 0, 16)
	sl.Position = UDim2.new(0, 8, 0, 3)
	sl.BackgroundTransparency = 1
	sl.Text = label .. ": " .. init
	sl.Font = Enum.Font.Code
	sl.TextSize = isMobile and 11 or 10
	sl.TextColor3 = C.textD
	sl.TextXAlignment = Enum.TextXAlignment.Left
	
	local sbg = Instance.new("Frame", con)
	sbg.Size = UDim2.new(1, -16, 0, 6)
	sbg.Position = UDim2.new(0, 8, 0, isMobile and 28 or 22)
	sbg.BackgroundColor3 = C.bg
	sbg.BorderSizePixel = 0
	Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
	
	local sf = Instance.new("Frame", sbg)
	local fa = (mx - mn) > 0 and (init - mn) / (mx - mn) or 0
	sf.Size = UDim2.new(fa, 0, 1, 0)
	sf.BackgroundColor3 = C.green
	sf.BorderSizePixel = 0
	Instance.new("UICorner", sf).CornerRadius = UDim.new(1, 0)
	
	local knob = Instance.new("Frame", con)
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(fa, -7, 0, isMobile and 24 or 18)
	knob.BackgroundColor3 = C.greenG
	knob.BorderSizePixel = 0
	knob.ZIndex = 5
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	
	local ik = Instance.new("Frame", knob)
	ik.Size = UDim2.new(0, 6, 0, 6)
	ik.Position = UDim2.new(0.5, -3, 0.5, -3)
	ik.BackgroundColor3 = C.bg
	ik.BorderSizePixel = 0
	Instance.new("UICorner", ik).CornerRadius = UDim.new(1, 0)
	
	local val = init
	local sliderDragging = false
	
	local function upd(inputX)
		local ap = sbg.AbsolutePosition.X
		local as = sbg.AbsoluteSize.X
		if as <= 0 then return end
		local r = math.clamp((inputX - ap) / as, 0, 1)
		val = math.floor(r * (mx - mn) + mn)
		val = math.clamp(val, mn, mx)
		sf.Size = UDim2.new(r, 0, 1, 0)
		sl.Text = label .. ": " .. val
		knob.Position = UDim2.new(r, -7, 0, isMobile and 24 or 18)
		if fn then fn(val) end
	end
	
	con.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = true
			upd(inp.Position.X)
		end
	end)
	
	knob.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = true
		end
	end)
	
	UserInputService.InputChanged:Connect(function(inp)
		if sliderDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			upd(inp.Position.X)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(inp)
		if sliderDragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
			sliderDragging = false
		end
	end)
	
	return con
end

-- ===== BOTONES DE CONFIGURACIÓN =====
makeBtn("[ AIMBOT ]  OFF", C.red, 1, function(b, l)
	AimbotEnabled = not AimbotEnabled
	l.Text = "[ AIMBOT ]  " .. (AimbotEnabled and "ON" or "OFF")
	local cor = AimbotEnabled and C.greenD or C.red
	tw(b, {BackgroundColor3 = cor}, 0.3)
end)

makeBtn("[ TARGET ]  Head", C.greenD2, 2, function(b, l)
	if AimPart == "Head" then
		AimPart = "HumanoidRootPart"
		l.Text = "[ TARGET ]  Torso"
	else
		AimPart = "Head"
		l.Text = "[ TARGET ]  Head"
	end
end)

makeSlider("FOV", 0, 0, 100, 3, function(v)
	FovRadius = math.min(v, 100)
end)

makeBtn("[ ESP ]  OFF", C.red, 4, function(b, l)
	EspEnabled = not EspEnabled
	l.Text = "[ ESP ]  " .. (EspEnabled and "ON" or "OFF")
	local cor = EspEnabled and C.greenD or C.red
	tw(b, {BackgroundColor3 = cor}, 0.3)
	
	for _, obj in pairs(EspObjects) do
		if obj.box then obj.box.Visible = EspEnabled end
		if obj.line then obj.line.Visible = EspEnabled end
	end
end)

-- ===== CRÉDITO =====
local Credit = Instance.new("TextLabel", Frame)
Credit.Size = UDim2.new(1, 0, 0, 26)
Credit.Position = UDim2.new(0, 0, 1, -26)
Credit.BackgroundColor3 = C.bg2
Credit.BackgroundTransparency = 0.5
Credit.BorderSizePixel = 0
Credit.Text = "Zelan"
Credit.Font = Enum.Font.Code
Credit.TextSize = 11
Credit.TextColor3 = C.textD
Credit.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", Credit).CornerRadius = UDim.new(0, 16)

-- ===== DRAG SYSTEM =====
local dragging = false
local dragObj = nil
local dragOffset = Vector2.new(0, 0)
local dragStartPos = UDim2.new(0, 0, 0, 0)

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragObj = Frame
		dragOffset = input.Position
		dragStartPos = Frame.Position
	end
end)

Ball.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragObj = Ball
		dragOffset = input.Position
		dragStartPos = Ball.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and dragObj and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragOffset
		dragObj.Position = UDim2.new(
			dragStartPos.X.Scale,
			dragStartPos.X.Offset + delta.X,
			dragStartPos.Y.Scale,
			dragStartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
		dragObj = nil
	end
end)

-- ===== MINIMIZAR =====
local minimized = false

local function minimize()
	minimized = true
	Frame.Visible = false
	Ball.Position = Frame.Position
	Ball.Size = UDim2.new(0, 50, 0, 50)
	Ball.Visible = true
	MinBtn.Text = "X"
end

local function restore()
	minimized = false
	Ball.Visible = false
	Frame.Position = Ball.Position
	Frame.Visible = true
	MinBtn.Text = "X"
end

MinBtn.MouseButton1Click:Connect(function()
	if not minimized then minimize() else restore() end
end)

Ball.MouseButton1Click:Connect(function()
	if minimized then restore() end
end)

-- ================= FOV CIRCLE =================
local FovGui = Instance.new("ScreenGui")
FovGui.Name = "FovCircleGUI"
FovGui.ResetOnSpawn = false
FovGui.Parent = game.CoreGui
FovGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FovGui.IgnoreGuiInset = true

local FovFrame = Instance.new("Frame")
FovFrame.Size = UDim2.new(0, 0, 0, 0)
FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.BackgroundTransparency = 1
FovFrame.BorderSizePixel = 0
FovFrame.Parent = FovGui
FovFrame.Visible = false

local FovStroke = Instance.new("UIStroke", FovFrame)
FovStroke.Thickness = 2
FovStroke.Color = C.green
FovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local FovCorner = Instance.new("UICorner", FovFrame)
FovCorner.CornerRadius = UDim.new(1, 0)

-- ================= ESP =================
local function createEsp(plr)
	if plr == LocalPlayer then return end

	local box = Drawing.new("Square")
	box.Thickness = 1.5
	box.Filled = false
	box.Visible = false

	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Visible = false

	EspObjects[plr] = {box = box, line = line}
end

Players.PlayerAdded:Connect(createEsp)
Players.PlayerRemoving:Connect(function(plr)
	if EspObjects[plr] then
		if EspObjects[plr].box then EspObjects[plr].box:Remove() end
		if EspObjects[plr].line then EspObjects[plr].line:Remove() end
		EspObjects[plr] = nil
	end
end)

for _, p in pairs(Players:GetPlayers()) do
	createEsp(p)
end

local function getEspPart(char)
	if not char then return nil end
	if AimPart == "Head" then
		return char:FindFirstChild("Head")
	else
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
	end
end

-- ================= LÓGICA DE TARGET =================
local function isAlive(char)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0
end

local function visible(pos)
	if not Character then return false end
	local origin = Camera.CFrame.Position
	local dir = (pos - origin).Unit * (pos - origin).Magnitude
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {Character}
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(origin, dir, params)
	if not result then return true end
	return (result.Position - pos).Magnitude < 3
end

local CurrentTarget = nil

local function getBestTarget()
	local best, bestDot = nil, -1
	local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local part = plr.Character:FindFirstChild(AimPart) or plr.Character:FindFirstChild("Head")
			if part and isAlive(plr.Character) then
				local dist = (part.Position - Camera.CFrame.Position).Magnitude
				if dist <= MaxDistance and visible(part.Position) then
					local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local screenVec = Vector2.new(screenPos.X, screenPos.Y)
						local distFromCenter = (screenVec - screenCenter).Magnitude

						if distFromCenter <= math.min(FovRadius, 100) then
							local dir = (part.Position - Camera.CFrame.Position).Unit
							local dot = Camera.CFrame.LookVector:Dot(dir)
							if dot > bestDot then
								bestDot = dot
								best = part
							end
						end
					end
				end
			end
		end
	end
	return best
end

-- ================= RENDER LOOP (BLOQUEO DE CÁMARA ANTI-BUG) =================
RunService.RenderStepped:Connect(function(dt)
	-- Actualizar FOV UI
	if EspEnabled and FovRadius > 0 then
		local size = FovRadius * 2
		FovFrame.Size = UDim2.new(0, size, 0, size)
		FovFrame.Visible = true
	else
		FovFrame.Visible = false
	end

	-- Actualizar ESP
	if EspEnabled then
		for plr, obj in pairs(EspObjects) do
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local espPart = getEspPart(char)

			if espPart and hum and hum.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(espPart.Position)
				
				if onScreen then
					local boxSize = 10
					obj.box.Size = Vector2.new(boxSize, boxSize)
					obj.box.Position = Vector2.new(pos.X - boxSize/2, pos.Y - boxSize/2)
					obj.box.Color = C.green
					obj.box.Visible = true

					obj.line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
					obj.line.To = Vector2.new(pos.X, pos.Y)
					obj.line.Color = C.green
					obj.line.Visible = true
				else
					obj.box.Visible = false
					obj.line.Visible = false
				end
			else
				obj.box.Visible = false
				obj.line.Visible = false
			end
		end
	else
		for _, obj in pairs(EspObjects) do
			if obj.box then obj.box.Visible = false end
			if obj.line then obj.line.Visible = false end
		end
	end

	-- Bloqueo y Control de Aimbot (Evita que la cámara y el arma se desincronicen)
	if AimbotEnabled then
		CurrentTarget = getBestTarget()
		if CurrentTarget and Character then
			local head = Character:FindFirstChild("Head")
			if head then
                -- Mantenemos el origen de la cámara anclado a la cabeza del personaje 
                -- para que el sistema de armas en primera persona no sufra saltos raros.
				local camPos = Camera.CFrame.Position
                -- Forzamos la orientación exacta de la cámara viendo al objetivo sin romper la matriz
				local lockedCFrame = CFrame.new(camPos, CurrentTarget.Position)
				Camera.CFrame = Camera.CFrame:Lerp(lockedCFrame, math.clamp(dt * Smoothness, 0, 1))
			end
		end
	else
		CurrentTarget = nil
	end
end)

-- ================= PHYSICS LOOP (ROTACIÓN SÍNCRONA DEL CUERPO) =================
RunService.Stepped:Connect(function()
	if AimbotEnabled and CurrentTarget and RootPart and Character and Character:Parent() then
		local targetPos = CurrentTarget.Position
		local rootPos = RootPart.Position
		
		-- Alineamos el cuerpo completo (HumanoidRootPart) al mismo eje horizontal del objetivo.
		-- Esto evita que el personaje quede mirando a la culata de la izquierda mientras disparas hacia adelante.
		local dir = (targetPos - rootPos)
		local yaw = math.atan2(-dir.X, -dir.Z)
		RootPart.CFrame = CFrame.new(rootPos) * CFrame.Angles(0, yaw, 0)
	end
end)