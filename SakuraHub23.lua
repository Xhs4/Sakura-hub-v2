--[[ 
    🌸 SAKURA HUB v5.0 - FIXED & ROBUST EDITION
    Servicios Principales
]]
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP, Camera = Players.LocalPlayer, workspace.CurrentCamera

-- Limpieza absoluta de instancias previas para evitar lag
if CoreGui:FindFirstChild("Sakura_UI_Base") then CoreGui.Sakura_UI_Base:Destroy() end
if LP:WaitForChild("PlayerGui"):FindFirstChild("Sakura_UI_Base") then LP.PlayerGui.Sakura_UI_Base:Destroy() end

-- Configuración Base
local Config = {
    -- Sistema de Marcación (ESP)
    ESPEnabled = true,
    HighlightsEnabled = true, -- Chams (Resaltado de cuerpo)
    ShowWantedStars = true,   -- Mostrar ⭐
    ShowDistance = true,      -- Mostrar [Distancia]
    
    -- Filtros de Marcación (Exigencia del Usuario)
    TargetPolice = true,      -- Marcar Policías siempre
    TargetFugitives = true,   -- Marcar Civiles CON Estrellas

    -- AimLock
    AimLockEnabled = false,
    AimMode = "Mobile (Bubble)",
    AimPart = "Head",
    AimSmoothness = 0.85,
    AimFOV = 130,
    ShowFOV = true,
    WallCheck = true,

    -- Varios
    DiscordInvite = "https://discord.gg/MfcZYtxuS"
}

-- Tablas de almacenamiento dinámico
local ESP_Objects = {}
local IsAimingRightClick = false

-- Creación de la Base de la UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name, ScreenGui.ResetOnSpawn, ScreenGui.IgnoreGuiInset, ScreenGui.ZIndexBehavior = "Sakura_UI_Base", false, true, Enum.ZIndexBehavior.Sibling
local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end

--[[ =======================================================
    1. SISTEMA DE DETECCIÓN UNIVERSAL DE ESTRELLAS ⭐
======================================================= ]]

local function GetWantedLevel(p)
    if not p then return 0 end
    
    -- Función auxiliar para parsear valores de texto o números
    local function ParseWantedValue(val)
        if type(val) == "number" then return val end
        if type(val) == "string" then
            -- Intenta contar íconos ⭐ directamente
            local _, count = val:gsub("⭐", "")
            if count > 0 then return count end
            -- Intenta extraer números de textos como "Wanted: 5"
            return tonumber(val:match("%d+")) or 0
        end
        return 0
    end

    -- Escaneo de jerarquías comunes (leaderstats, Stats, Data)
    local function ScanForValue(folder)
        if not folder then return nil end
        for _, v in ipairs(folder:GetChildren()) do
            local name = v.Name:lower()
            if (name:find("wanted") or name:find("star") or name:find("bounty") or name:find("estrella") or name:find("fugit")) and v:IsA("ValueBase") then
                return ParseWantedValue(v.Value)
            end
        end
        return nil
    end

    local foundValue = ScanForValue(p:FindFirstChild("leaderstats")) 
        or ScanForValue(p:FindFirstChild("Stats")) 
        or ScanForValue(p:FindFirstChild("Data")) 
        or ScanForValue(p) -- Busca en el objeto Player directamente
    
    if foundValue and foundValue > 0 then return foundValue end

    -- Escaneo de Interfaz Overhead (BillboardGuis en la cabeza del Character)
    if p.Character then
        local head = p.Character:FindFirstChild("Head")
        if head then
            for _, desc in ipairs(head:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    local t = desc.Text
                    if t:find("⭐") or desc.Name:lower():find("star") or desc.Name:lower():find("wanted") then
                        local _, count = t:gsub("⭐", "")
                        if count > 0 then return count end
                        local num = t:match("%d+")
                        if num then return tonumber(num) or 0 end
                    end
                end
            end
        end
    end
    return 0
end

--[[ =======================================================
    2. LÓGICA DE FILTRADO DE MARCACIÓN (ARREGLADO)
======================================================= ]]

local function IsPolice(p)
    if not p or not p.Team then return false end
    local name = p.Team.Name:lower()
    -- Soporte para múltiples nombres de equipo policial
    return name:find("police") or name:find("cop") or name:find("guard") or name:find("policía") or name:find("policia") or name:find("swat") or name:find("sheriff") or name:find("militar") or name:find("army")
end

local function IsCivilian(p)
    if not p then return true end
    if not p.Team then return true end -- Si no tiene team, suele ser civil
    local name = p.Team.Name:lower()
    return name:find("civil") or name:find("citizen") or name:find("criminal") or name:find("prisoner") or name:find("rebel") or name:find("fugitive")
end

-- Determina si un jugador debe ser marcado basándose SOLO en la config del usuario
local function ShouldPlayerBeMarked(p)
    if p == LP then return false end -- Nunca marcarse a sí mismo
    
    local poly = IsPolice(p)
    local civ = IsCivilian(p)
    local stars = GetWantedLevel(p)

    -- Condición 1: Es policía Y el usuario quiere marcar policías
    if poly and Config.TargetPolice then
        return true
    end

    -- Condición 2: Es civil Y tiene estrellas Y el usuario quiere marcar fugitivos
    if civ and stars > 0 and Config.TargetFugitives then
        return true
    end

    return false
end

--[[ =======================================================
    3. MOTOR DE MARCACIÓN ROBUSTO (3D BillboardGuis)
======================================================= ]]

-- Crear componentes visuales para un jugador
local function CreatePlayerESP(p)
    if p == LP then return end
    
    -- Contenedor principal Overhead
    local bg = Instance.new("BillboardGui")
    bg.Name = "Sakura_Overhead_" .. p.Name
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3.5, 0) -- Ajuste de altura sobre la cabeza

    -- Etiqueta de Texto (Nombre, Distancia, ⭐)
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.Font = Enum.Font.FredokaOne -- Tipografía Sakura Hub
    txt.TextSize = 14
    txt.TextWrapped = false
    txt.Parent = bg

    -- Chams (Resaltado de cuerpo)
    local hl = Instance.new("Highlight")
    hl.Name = "Sakura_Chams_" .. p.Name
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0.1

    -- Guardar referencias
    ESP_Objects[p] = { Gui = bg, Label = txt, Highlight = hl }
end

-- Limpiar componentes
local function RemovePlayerESP(p)
    if ESP_Objects[p] then
        if ESP_Objects[p].Gui then ESP_Objects[p].Gui:Destroy() end
        if ESP_Objects[p].Highlight then ESP_Objects[p].Highlight:Destroy() end
        ESP_Objects[p] = nil
    end
end

-- Inicialización y eventos de conexión de jugadores
for _, p in ipairs(Players:GetPlayers()) do CreatePlayerESP(p) end
Players.PlayerAdded:Connect(CreatePlayerESP)
Players.PlayerRemoving:Connect(RemovePlayerESP)

--[[ =======================================================
    4. FOV, MAIN FRAME & AIMLOCK (Mantenido Funcional)
======================================================= ]]

-- Círculo FOV
local FOV = Instance.new("Frame")
FOV.AnchorPoint, FOV.Position, FOV.Size, FOV.BackgroundTransparency, FOV.Visible, FOV.Parent = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), UDim2.new(0,Config.AimFOV*2,0,Config.AimFOV*2), 1, false, ScreenGui
Instance.new("UICorner", FOV).CornerRadius = UDim.new(1,0)
local FOVS = Instance.new("UIStroke", FOV) FOVS.Color, FOVS.Thickness = Color3.fromRGB(255,140,180), 1.8

-- Ventana Principal
local MF = Instance.new("Frame")
MF.Size, MF.Position, MF.BackgroundColor3, MF.Active, MF.Visible, MF.Parent = UDim2.new(0,350,0,310), UDim2.new(0.5,-175,0.5,-155), Color3.fromRGB(22,12,18), true, false, ScreenGui
Instance.new("UICorner", MF).CornerRadius = UDim.new(0,14)
local MS = Instance.new("UIStroke", MF) MS.Color, MS.Thickness = Color3.fromRGB(255,140,180), 1.8

-- TopBar
local TB = Instance.new("Frame") TB.Size, TB.BackgroundColor3, TB.Parent = UDim2.new(1,0,0,38), Color3.fromRGB(35,18,28), MF
Instance.new("UICorner", TB).CornerRadius = UDim.new(0,14)
local TBT = Instance.new("TextLabel") TBT.Size, TBT.Position, TBT.BackgroundTransparency, TBT.Text, TBT.TextColor3, TBT.Font, TBT.TextSize, TBT.TextXAlignment, TBT.Parent = UDim2.new(1,-90,1,0), UDim2.new(0,12,0,0), 1, "🌸 SAKURA HUB", Color3.fromRGB(255,192,210), Enum.Font.FredokaOne, 13, Enum.TextXAlignment.Left, TB

-- Botón Cerrar/Minimizar
local MinBtn = Instance.new("TextButton") MinBtn.Size, MinBtn.Position, MinBtn.BackgroundColor3, MinBtn.Text, MinBtn.TextColor3, MinBtn.Font, MinBtn.TextSize, MinBtn.Parent = UDim2.new(0,26,0,26), UDim2.new(1,-60,0.5,-13), Color3.fromRGB(50,28,40), "—", Color3.fromRGB(255,190,210), Enum.Font.GothamBold, 11, TB
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,5)
local CloseBtn = Instance.new("TextButton") CloseBtn.Size, CloseBtn.Position, CloseBtn.BackgroundColor3, CloseBtn.Text, CloseBtn.TextColor3, CloseBtn.Font, CloseBtn.TextSize, CloseBtn.Parent = UDim2.new(0,26,0,26), UDim2.new(1,-30,0.5,-13), Color3.fromRGB(255,110,150), "🌸", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 11, TB
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)

local function ToggleHub(s) MF.Visible = s end
MinBtn.MouseButton1Click:Connect(function() ToggleHub(false) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleHub(false) end)

-- Botón Flotante para Abrir
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size, OpenBtn.Position, OpenBtn.BackgroundColor3, OpenBtn.Text, OpenBtn.TextColor3, OpenBtn.Font, OpenBtn.TextSize, OpenBtn.Visible, OpenBtn.Parent = UDim2.new(0,44,0,44), UDim2.new(0,12,0.5,-22), Color3.fromRGB(35,18,28), "🌸", Color3.fromRGB(255,160,190), Enum.Font.GothamBold, 16, true, ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)
OpenBtn.MouseButton1Click:Connect(function() ToggleHub(not MF.Visible) end)

-- Arrastre de Ventana y Botón Flotante
local function EnableDrag(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging, dragStart, startPos = true, i.Position, obj.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
EnableDrag(MF)
EnableDrag(OpenBtn)

-- Pestañas
local TabBar = Instance.new("Frame") TabBar.Size, TabBar.Position, TabBar.BackgroundTransparency, TabBar.Parent = UDim2.new(1,-20,0,26), UDim2.new(0,10,0,44), 1, MF
local function CTab(txt, sz, pos)
    local b = Instance.new("TextButton")
    b.Size, b.Position, b.BackgroundColor3, b.TextColor3, b.Text, b.Font, b.TextSize, b.Parent = UDim2.new(sz,-2,1,0), pos, Color3.fromRGB(40,22,32), Color3.fromRGB(220,180,200), txt, Enum.Font.FredokaOne, 11, TabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    return b
end
local T1, T2 = CTab("ESP",0.5,UDim2.new(0,0,0,0)), CTab("AimLock",0.5,UDim2.new(0.5,1,0,0))

local PC = Instance.new("Frame") PC.Size, PC.Position, PC.BackgroundTransparency, PC.Parent = UDim2.new(1,-20,1,-80), UDim2.new(0,10,0,74), 1, MF
local PESP, PAim = Instance.new("Frame"), Instance.new("Frame")
for _, p in ipairs({PESP, PAim}) do p.Size, p.BackgroundTransparency, p.Visible, p.Parent = UDim2.new(1,0,1,0), 1, false, PC end
PESP.Visible = true

local function STab(ap, ab)
    for _, p in ipairs({PESP, PAim}) do p.Visible = false end
    T1.BackgroundColor3, T2.BackgroundColor3 = Color3.fromRGB(40,22,32), Color3.fromRGB(40,22,32)
    ap.Visible, ab.BackgroundColor3 = true, Color3.fromRGB(255,110,150)
end
T1.MouseButton1Click:Connect(function() STab(PESP, T1) end)
T2.MouseButton1Click:Connect(function() STab(PAim, T2) end)
T1.BackgroundColor3 = Color3.fromRGB(255,110,150)

local function AddL(p) local l = Instance.new("UIListLayout") l.Padding, l.Parent = UDim.new(0,4), p end
AddL(PESP) AddL(PAim)

local function CToggle(parent, name, def, cb)
    local f = Instance.new("Frame") f.Size, f.BackgroundColor3, f.Parent = UDim2.new(1,0,0,28), Color3.fromRGB(40,22,32), parent
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

-- Menú ESP
CToggle(PESP, "Activar ESP", Config.ESPEnabled, function(v) Config.ESPEnabled = v end)
CToggle(PESP, "Resaltado (Chams)", Config.HighlightsEnabled, function(v) Config.HighlightsEnabled = v end)
CToggle(PESP, "Mostrar ⭐", Config.ShowWantedStars, function(v) Config.ShowWantedStars = v end)
CToggle(PESP, "Mostrar Distancia", Config.ShowDistance, function(v) Config.ShowDistance = v end)
CToggle(PESP, "Filtrar: Marcar Policías", Config.TargetPolice, function(v) Config.TargetPolice = v end)
CToggle(PESP, "Filtrar: Marcar Fugitivos", Config.TargetFugitives, function(v) Config.TargetFugitives = v end)

-- Menú AimLock
CToggle(PAim, "Activar AimLock", Config.AimLockEnabled, function(v) Config.AimLockEnabled = v end)
CToggle(PAim, "Mostrar Círculo FOV", Config.ShowFOV, function(v) Config.ShowFOV, FOV.Visible = v, v end)
CToggle(PAim, "Wall Check (Visible Solo)", Config.WallCheck, function(v) Config.WallCheck = v end)

-- Ajuste de Tamaño de FOV
local FOVF = Instance.new("Frame") FOVF.Size, FOVF.BackgroundColor3, FOVF.Parent = UDim2.new(1,0,0,28), Color3.fromRGB(40,22,32), PAim
Instance.new("UICorner", FOVF).CornerRadius = UDim.new(0,5)
local FOVL = Instance.new("TextLabel") FOVL.Size, FOVL.Position, FOVL.BackgroundTransparency, FOVL.Text, FOVL.TextColor3, FOVL.Font, FOVL.TextSize, FOVL.TextXAlignment, FOVL.Parent = UDim2.new(0.5,0,1,0), UDim2.new(0,8,0,0), 1, "FOV: "..Config.AimFOV, Color3.fromRGB(255,220,235), Enum.Font.GothamMedium, 10, Enum.TextXAlignment.Left, FOVF
local FOVBtnM = Instance.new("TextButton") FOVBtnM.Size, FOVBtnM.Position, FOVBtnM.BackgroundColor3, FOVBtnM.Text, FOVBtnM.TextColor3, FOVBtnM.Font, FOVBtnM.TextSize, FOVBtnM.Parent = UDim2.new(0,25,0,18), UDim2.new(1,-60,0.5,-9), Color3.fromRGB(255,110,150), "-", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 12, FOVF
Instance.new("UICorner", FOVBtnM).CornerRadius = UDim.new(0,4)
local FOVBtnP = Instance.new("TextButton") FOVBtnP.Size, FOVBtnP.Position, FOVBtnP.BackgroundColor3, FOVBtnP.Text, FOVBtnP.TextColor3, FOVBtnP.Font, FOVBtnP.TextSize, FOVBtnP.Parent = UDim2.new(0,25,0,18), UDim2.new(1,-30,0.5,-9), Color3.fromRGB(255,110,150), "+", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 12, FOVF
Instance.new("UICorner", FOVBtnP).CornerRadius = UDim.new(0,4)

FOVBtnM.MouseButton1Click:Connect(function() Config.AimFOV = math.clamp(Config.AimFOV - 10, 30, 300) FOVL.Text = "FOV: "..Config.AimFOV FOV.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2) end)
FOVBtnP.MouseButton1Click:Connect(function() Config.AimFOV = math.clamp(Config.AimFOV + 10, 30, 300) FOVL.Text = "FOV: "..Config.AimFOV FOV.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2) end)

local MFm = Instance.new("Frame") MFm.Size, MFm.BackgroundColor3, MFm.Parent = UDim2.new(1,0,0,28), Color3.fromRGB(40,22,32), PAim
Instance.new("UICorner", MFm).CornerRadius = UDim.new(0,5)
local MDB = Instance.new("TextButton") MDB.Size, MDB.Position, MDB.BackgroundColor3, MDB.Text, MDB.TextColor3, MDB.Font, MDB.TextSize, MDB.Parent = UDim2.new(0,95,0,18), UDim2.new(1,-101,0.5,-9), Color3.fromRGB(255,110,150), "BUBBLE (MOBILE)", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 8, MFm
MDB.MouseButton1Click:Connect(function() Config.AimMode = Config.AimMode == "Mobile (Bubble)" and "PC (Right Click)" or "Mobile (Bubble)" MDB.Text = Config.AimMode == "Mobile (Bubble)" and "BUBBLE (MOBILE)" or "RIGHT CLICK (PC)" end)

-- Lógica AimLock (Raycast & Closest)
UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "PC (Right Click)" then IsAimingRightClick = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "PC (Right Click)" then IsAimingRightClick = false end end)

local function IsTargetVisible(part, char)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, char, ScreenGui}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, part.Position - origin, params)
    return result == nil
end

local function GetClosestTarget()
    local cl, sd, vc = nil, Config.AimFOV, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and ShouldPlayerBeMarked(p) then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 and IsTargetVisible(root, p.Character) then
                local pos, onS = Camera:WorldToViewportPoint(root.Position)
                if onS then
                    local dist = (Vector2.new(pos.X, pos.Y) - vc).Magnitude
                    if dist < sd then sd, cl = dist, p end
                end
            end
        end
    end
    return cl
end

--[[ =======================================================
    5. BUCLE PRINCIPAL DE RENDERIZADO (FIXED)
======================================================= ]]

RunService.RenderStepped:Connect(function()
    -- Lógica AimLock
    if (Config.AimMode == "Mobile (Bubble)" and Config.AimLockEnabled) or (Config.AimMode == "PC (Right Click)" and IsAimingRightClick) then
        local t = GetClosestTarget()
        if t and t.Character and t.Character:FindFirstChild(Config.AimPart) then
            local targetPos = t.Character[Config.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Config.AimSmoothness)
        end
    end

    -- Lógica Marcación (ESP Robust)
    for p, d in pairs(ESP_Objects) do
        local char = p.Character
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if Config.ESPEnabled and head and hum and hum.Health > 0 and ShouldPlayerBeMarked(p) then
            -- Asegurar jerarquía del BillboardGui
            if d.Gui.Parent ~= head then
                d.Gui.Parent = head
            end
            d.Gui.Enabled = true

            -- Construcción del Texto Dinámico
            local stars = GetWantedLevel(p)
            local dist = math.floor((Camera.CFrame.Position - head.Position).Magnitude)
            
            -- Requisito de usuario: Formato exacto del texto
            local textBuffer = p.Name
            
            if Config.ShowDistance then
                textBuffer = textBuffer .. " [" .. dist .. "m]"
            end
            
            if Config.ShowWantedStars and stars > 0 then
                -- Requisito de usuario: Soportar múltiples estrellas ⭐⭐⭐
                local starString = string.rep("⭐", math.min(stars, 6)) -- Capado a 6 por estética
                textBuffer = textBuffer .. "\n" .. starString
            end

            d.Label.Text = textBuffer

            -- Color según estado (Fugitivo prevalece sobre equipo)
            local col = Color3.fromRGB(255, 255, 255) -- Blanco por defecto
            if stars > 0 then
                col = Color3.fromRGB(255, 200, 0) -- Dorado/Amarillo Fugitivo
            elseif IsPolice(p) then
                col = Color3.fromRGB(0, 160, 255) -- Azul Policía
            end
            d.Label.TextColor3 = col

            -- Chams / Highlights Robustos
            if Config.HighlightsEnabled then
                if d.Highlight.Parent ~= char then
                    d.Highlight.Parent = char
                end
                d.Highlight.Enabled = true
                d.Highlight.FillColor = col
                d.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            else
                d.Highlight.Enabled = false
            end
        else
            -- Apagar marcadores si no deben verse
            d.Gui.Enabled = false
            d.Highlight.Enabled = false
        end
    end
end)

-- Splash Screen (Basado en el que diste, arreglado)
local function DoSplash()
    local blur = Instance.new("BlurEffect") blur.Size, blur.Parent = 0, Lighting
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

    local MainFrame = Instance.new("Frame")
    MainFrame.Name, MainFrame.Size, MainFrame.Position, MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency, MainFrame.BorderSizePixel, MainFrame.Parent = "MainFrame", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.fromRGB(28,14,25), 1, 0, ScreenGui
    TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.25}):Play()

    local CenterContainer = Instance.new("Frame")
    CenterContainer.Name, CenterContainer.Size, CenterContainer.AnchorPoint, CenterContainer.Position, CenterContainer.BackgroundTransparency, CenterContainer.Parent = "CenterContainer", UDim2.new(0,260,0,100), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), 1, MainFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name, StatusLabel.Size, StatusLabel.AnchorPoint, StatusLabel.Position, StatusLabel.BackgroundTransparency, StatusLabel.Text, StatusLabel.TextColor3, StatusLabel.TextSize, StatusLabel.Font, StatusLabel.TextTransparency, StatusLabel.Parent = "StatusLabel", UDim2.new(1,0,0,30), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.3,0), 1, "", Color3.fromRGB(255,230,242), 18, Enum.Font.FredokaOne, 1, CenterContainer

    local ProgressBarBackground = Instance.new("Frame")
    ProgressBarBackground.Name, ProgressBarBackground.Size, ProgressBarBackground.AnchorPoint, ProgressBarBackground.Position, ProgressBarBackground.BackgroundColor3, ProgressBarBackground.BackgroundTransparency, ProgressBarBackground.BorderSizePixel, ProgressBarBackground.Parent = "ProgressBarBackground", UDim2.new(1,0,0,6), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.7,0), Color3.fromRGB(60,30,50), 1, 0, CenterContainer
    Instance.new("UICorner", ProgressBarBackground).CornerRadius = UDim.new(1,0)

    local ProgressBarFill = Instance.new("Frame")
    ProgressBarFill.Name, ProgressBarFill.Size, ProgressBarFill.BackgroundColor3, ProgressBarFill.BorderSizePixel, ProgressBarFill.Parent = "ProgressBarFill", UDim2.new(0,0,1,0), Color3.fromRGB(255,140,185), 0, ProgressBarBackground
    Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1,0)

    TweenService:Create(ProgressBarBackground, TweenInfo.new(0.6), {BackgroundTransparency = 0.5}):Play()

    local sequence = {
        {text = "Loading resources...", progress = 0.35, duration = 1.0},
        {text = "Connecting to server...", progress = 0.75, duration = 1.2},
        {text = "Ready!", progress = 1.0, duration = 0.8}
    }

    task.spawn(function()
        task.wait(0.2)
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
        task.wait(0.4)
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
        OpenBtn.Visible = true
    end)
end

-- Ejecutar Splash y luego mostrar el Hub (Oculto al inicio)
MF.Visible, OpenBtn.Visible, QB.Visible, FOV.Visible = false, false, false, false
DoSplash()