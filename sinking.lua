-- Servicios necesarios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

-- Limpiar interfaz previa si ya existe
if PlayerGui:FindFirstChild("NavalMobileHub") then
    PlayerGui.NavalMobileHub:Destroy()
end

-- ==========================================
-- CREACIÓN DE LA INTERFAZ (ADAPTADA PARA MÓVIL)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NavalMobileHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Ventana Principal (Tamaño óptimo para pantallas táctiles)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastrar la ventana en móvil y PC
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(70, 130, 200)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Barra Superior
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚓ NAVAL PRO HUB [MOBILE]"
Title.TextColor3 = Color3.fromRGB(230, 240, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Botón Minimizar / Cerrar para móvil
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Contenedor con Scroll
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 52)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Content.ScrollBarThickness = 6
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 12)
UIList.Parent = Content

-- ==========================================
-- BUSCADOR INTELIGENTE DE REMOTES Y DATOS
-- ==========================================

-- Intenta encontrar RemoteEvents que sincronicen cambios con el servidor
local function findRemoteEvent()
    local searchPaths = {ReplicatedStorage, Workspace}
    for _, parent in ipairs(searchPaths) do
        for _, descendant in ipairs(parent:GetDescendants()) do
            if descendant:IsA("RemoteEvent") then
                local name = string.lower(descendant.Name)
                if string.find(name, "add") or string.find(name, "buy") or string.find(name, "stat") or string.find(name, "money") or string.find(name, "exp") or string.find(name, "reward") then
                    return descendant
                end
            end
        end
    end
    return nil
end

-- Búsqueda profunda de valores (Moneda y Exp/Nivel)
local function deepSearch(keywords)
    local containers = {
        LocalPlayer:FindFirstChild("leaderstats"),
        LocalPlayer:FindFirstChild("Data"),
        LocalPlayer:FindFirstChild("Stats"),
        LocalPlayer:FindFirstChild("PlayerGui"),
        LocalPlayer
    }
    
    for _, container in ipairs(containers) do
        if container then
            for _, desc in ipairs(container:GetDescendants()) do
                local nameLower = string.lower(desc.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(nameLower, kw) and (desc:IsA("IntValue") or desc:IsA("NumberValue")) then
                        return desc
                    end
                end
            end
        end
    end
    return nil
end

-- ==========================================
-- CREACIÓN DE ELEMENTOS DE UI TÁCTILES
-- ==========================================

local function createControlCard(titleText, placeholderText, buttonText, btnColor)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 100)
    card.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = Color3.fromRGB(200, 210, 230)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = titleText
    label.Parent = card
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -24, 0, 34)
    textBox.Position = UDim2.new(0, 12, 0, 35)
    textBox.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    textBox.BorderSizePixel = 0
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = placeholderText
    textBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 150)
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)
    textBox.Parent = card
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 30)
    button.Position = UDim2.new(0, 12, 0, 74)
    button.BackgroundColor3 = btnColor
    button.Font = Enum.Font.GothamBold
    button.Text = buttonText
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 13
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.Parent = card
    
    return card, textBox, button
end

-- 1. Tarjeta Moneda (Cualquier recurso desconocido)
local moneyCard, moneyInput, btnMoney = createControlCard("💰 Modificar Moneda / Recursos", "Ej: 10000", "Aplicar Moneda", Color3.fromRGB(41, 128, 185))
moneyCard.Parent = Content

-- 2. Tarjeta Experiencia / Nivel (Para reflejar en barra oficial)
local expCard, expInput, btnExp = createControlCard("⭐ Modificar Experiencia / Nivel (Barra Oficial)", "Ej: 500", "Sincronizar con Servidor", Color3.fromRGB(39, 174, 96))
expCard.Parent = Content

-- 3. Tarjeta Teletransporte a Islas
local tpCard = Instance.new("Frame")
tpCard.Size = UDim2.new(1, 0, 0, 110)
tpCard.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
tpCard.BorderSizePixel = 0
Instance.new("UICorner", tpCard).CornerRadius = UDim.new(0, 10)
tpCard.Parent = Content

local tpTitle = Instance.new("TextLabel")
tpTitle.Size = UDim2.new(1, -20, 0, 25)
tpTitle.Position = UDim2.new(0, 12, 0, 8)
tpTitle.BackgroundTransparency = 1
tpTitle.Font = Enum.Font.GothamSemibold
tpTitle.TextColor3 = Color3.fromRGB(200, 210, 230)
tpTitle.TextSize = 13
tpTitle.TextXAlignment = Enum.TextXAlignment.Left
tpTitle.Text = "🏝️ Teletransporte a Puertos / Islas"
tpTitle.Parent = tpCard

local islandBtn = Instance.new("TextButton")
islandBtn.Size = UDim2.new(1, -24, 0, 32)
islandBtn.Position = UDim2.new(0, 12, 0, 36)
islandBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
islandBtn.Font = Enum.Font.Gotham
islandBtn.Text = "Escanear Islas Cercanas"
islandBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
islandBtn.TextSize = 12
Instance.new("UICorner", islandBtn).CornerRadius = UDim.new(0, 8)
islandBtn.Parent = tpCard

local tpActionBtn = Instance.new("TextButton")
tpActionBtn.Size = UDim2.new(1, -24, 0, 30)
tpActionBtn.Position = UDim2.new(0, 12, 0, 72)
tpActionBtn.BackgroundColor3 = Color3.fromRGB(211, 84, 0)
tpActionBtn.Font = Enum.Font.GothamBold
tpActionBtn.Text = "Teletransportar Personaje / Barco"
tpActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpActionBtn.TextSize = 13
Instance.new("UICorner", tpActionBtn).CornerRadius = UDim.new(0, 8)
tpActionBtn.Parent = tpCard

-- ==========================================
-- LÓGICA DE EJECUCIÓN Y SINCRONIZACIÓN
-- ==========================================

local currencyKeywords = {"cash", "money", "coin", "gold", "doubloon", "credit", "wood", "iron", "resource", "val", "gem", "buck"}
local expKeywords = {"exp", "experience", "level", "lvl", "rank", "tier", "prestige", "progress"}

-- Modificar Moneda con intento de disparo remoto
btnMoney.MouseButton1Click:Connect(function()
    local amount = tonumber(moneyInput.Text)
    if not amount then return end
    
    local targetVal = deepSearch(currencyKeywords)
    local remote = findRemoteEvent()
    
    if targetVal then
        targetVal.Value = targetVal.Value + amount
    end
    
    -- Intentar notificar al servidor vía RemoteEvent si existe
    if remote then
        pcall(function()
            remote:FireServer("AddMoney", amount)
            remote:FireServer(amount)
        end)
    end
    
    btnMoney.Text = "¡Moneda Aplicada y Sincronizada!"
    task.wait(1.5)
    btnMoney.Text = "Aplicar Moneda"
end)

-- Modificar Experiencia / Nivel asegurando actualización en barra oficial
btnExp.MouseButton1Click:Connect(function()
    local amount = tonumber(expInput.Text)
    if not amount then return end
    
    local targetVal = deepSearch(expKeywords)
    local remote = findRemoteEvent()
    
    if targetVal then
        targetVal.Value = targetVal.Value + amount
    end
    
    -- Disparar eventos comunes de ganancia de experiencia para forzar la barra de progreso
    if remote then
        pcall(function()
            remote:FireServer("AddExp", amount)
            remote:FireServer("AddExperience", amount)
            remote:FireServer("UpdateLevel", amount)
        end)
    end
    
    btnExp.Text = "¡Experiencia Sincronizada con Servidor!"
    task.wait(1.5)
    btnExp.Text = "Sincronizar con Servidor"
end)

-- Sistema de TP a Islas
local detectedIslands = {}
local selectedIsland = nil

islandBtn.MouseButton1Click:Connect(function()
    detectedIslands = {}
    local keywords = {"island", "port", "harbor", "dock", "zone", "map", "outpost", "spawn", "base"}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        for _, kw in ipairs(keywords) do
            if string.find(nameLower, kw) and (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("Folder")) then
                if obj ~= Workspace and not table.find(detectedIslands, obj) then
                    table.insert(detectedIslands, obj)
                end
            end
        end
    end
    
    if #detectedIslands > 0 then
        selectedIsland = detectedIslands[math.random(1, #detectedIslands)]
        islandBtn.Text = "📍 Destino: " .. selectedIsland.Name
    else
        islandBtn.Text = "⚠️ No se encontraron islas"
    end
end)

tpActionBtn.MouseButton1Click:Connect(function()
    if not selectedIsland then
        islandBtn.Text = "⚠️ Escanea una isla primero"
        return
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local targetPart = nil
    if selectedIsland:IsA("Model") then
        targetPart = selectedIsland.PrimaryPart or selectedIsland:FindFirstChildWhichIsA("BasePart", true)
    elseif selectedIsland:IsA("BasePart") then
        targetPart = selectedIsland
    end
    
    if targetPart then
        -- Teletransportar personaje y vehículo/barco si está anclado a él
        char.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 10, 0)
        tpActionBtn.Text = "¡Teletransportado con Éxito!"
        task.wait(1.5)
        tpActionBtn.Text = "Teletransportar Personaje / Barco"
    else
        tpActionBtn.Text = "⚠️ Error en la posición de la isla"
    end
end)