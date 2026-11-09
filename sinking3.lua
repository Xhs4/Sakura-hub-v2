-- Servicios necesarios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

-- Limpiar interfaz previa si ya existe
if PlayerGui:FindFirstChild("NavalUltimateHub") then
    PlayerGui.NavalUltimateHub:Destroy()
end

-- ==========================================
-- 1. CREACIÓN DE LA INTERFAZ (ORGANIZADA & MÓVIL)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NavalUltimateHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Botón Flotante para Móvil (Abrir/Cerrar menú)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "⚓"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 22
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
ToggleBtn.Parent = ScreenGui

-- Ventana Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 420)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 120, 220)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Funcionalidad del botón flotante
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Barra Superior
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚓ NAVAL ELITE HUB - PRO"
Title.TextColor3 = Color3.fromRGB(230, 240, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==========================================
-- SISTEMA DE PESTAÑAS (SECCIONES ORGANIZADAS)
-- ==========================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local UIListTab = Instance.new("UIListLayout")
UIListTab.FillDirection = Enum.FillDirection.Horizontal
UIListTab.SortOrder = Enum.SortOrder.LayoutOrder
UIListTab.Padding = UDim.new(0, 8)
UIListTab.Parent = TabBar

local function createTabButton(name, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 190, 210)
    btn.TextSize = 12
    btn.LayoutOrder = layoutOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.Parent = TabBar
    return btn
end

local tabEconomy = createTabButton("📊 Economía & EXP", 1)
local tabIslands = createTabButton("🏝️ Islas & TP", 2)
local tabTasks = createTabButton("⚡ Misiones", 3)

-- Contenedores de Secciones (Páginas)
local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1, -20, 1, -100)
pagesContainer.Position = UDim2.new(0, 10, 0, 95)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = MainFrame

local function createPage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.CanvasSize = UDim2.new(0, 0, 1.3, 0)
    page.ScrollBarThickness = 5
    page.Visible = false
    page.Parent = pagesContainer
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = page
    return page
end

local page1 = createPage()
local page2 = createPage()
local page3 = createPage()
page1.Visible = true -- Mostrar la primera por defecto

tabEconomy.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
tabEconomy.TextColor3 = Color3.fromRGB(255, 255, 255)

local function switchTab(activePage, activeBtn)
    page1.Visible = false
    page2.Visible = false
    page3.Visible = false
    activePage.Visible = true
    
    tabEconomy.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    tabEconomy.TextColor3 = Color3.fromRGB(180, 190, 210)
    tabIslands.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    tabIslands.TextColor3 = Color3.fromRGB(180, 190, 210)
    tabTasks.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    tabTasks.TextColor3 = Color3.fromRGB(180, 190, 210)
    
    activeBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

tabEconomy.MouseButton1Click:Connect(function() switchTab(page1, tabEconomy) end)
tabIslands.MouseButton1Click:Connect(function() switchTab(page2, tabIslands) end)
tabTasks.MouseButton1Click:Connect(function() switchTab(page3, tabTasks) end)

-- ==========================================
-- 2. LÓGICA DE DETECCIÓN Y REMOTES (SERVIDOR)
-- ==========================================

-- Búsqueda exhaustiva de RemoteEvents para forzar guardado del servidor
local function getActiveRemotes()
    local remotes = {}
    local searchRoots = {ReplicatedStorage, Workspace}
    for _, root in ipairs(searchRoots) do
        for _, desc in ipairs(root:GetDescendants()) do
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                local name = string.lower(desc.Name)
                if string.find(name, "anchor") or string.find(name, "stat") or string.find(name, "exp") or string.find(name, "quest") or string.find(name, "task") or string.find(name, "reward") or string.find(name, "save") then
                    table.insert(remotes, desc)
                end
            end
        end
    end
    return remotes
end

-- Búsqueda de valores numéricos de anclas o nivel
local function findStatValue(keywords)
    local containers = {
        LocalPlayer:FindFirstChild("leaderstats"),
        LocalPlayer:FindFirstChild("Data"),
        LocalPlayer:FindFirstChild("Stats"),
        LocalPlayer:FindFirstChild("PlayerValues"),
        LocalPlayer
    }
    for _, c in ipairs(containers) do
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                local nameLower = string.lower(d.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(nameLower, kw) and (d:IsA("IntValue") or d:IsA("NumberValue")) then
                        return d
                    end
                end
            end
        end
    end
    return nil
end

-- ==========================================
-- 3. CONSTRUCCIÓN DE CONTENIDO POR SECCIÓN
-- ==========================================

-- === SECCIÓN 1: ECONOMÍA & EXP (Página 1) ===
local function createCard(parent, titleText, placeholder, btnText, btnColor)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 95)
    card.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 22)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = Color3.fromRGB(190, 200, 220)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = titleText
    label.Parent = card
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 0, 30)
    box.Position = UDim2.new(0, 12, 0, 32)
    box.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 13
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box.Parent = card
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 26)
    btn.Position = UDim2.new(0, 12, 0, 65)
    btn.BackgroundColor3 = btnColor
    btn.Font = Enum.Font.GothamBold
    btn.Text = btnText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = card
    
    return card, box, btn
end

local _, anchorsInput, btnAnchors = createCard(page1, "⚓ Anclas / Moneda (Anchors)", "Cantidad a sumar...", "Actualizar & Sincronizar Anclas", Color3.fromRGB(41, 128, 185))
anchorsInput.Parent.Parent = page1

local _, expInput, btnExp = createCard(page1, "⭐ Experiencia / Nivel Oficial", "Cantidad de EXP a sumar...", "Sincronizar Barra y Servidor", Color3.fromRGB(39, 174, 96))
expInput.Parent.Parent = page1

-- Acciones Economía y EXP
local anchorKeywords = {"anchor", "anchors", "cash", "money", "coin", "gold", "doubloon", "gem"}
local expKeywords = {"exp", "experience", "level", "lvl", "rank", "tier", "progress"}

btnAnchors.MouseButton1Click:Connect(function()
    local amt = tonumber(anchorsInput.Text)
    if not amt then return end
    
    local valObj = findStatValue(anchorKeywords)
    if valObj then valObj.Value = valObj.Value + amt end
    
    -- Forzar sincronización remota con el servidor
    for _, remote in ipairs(getActiveRemotes()) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer("AddAnchors", amt)
                remote:FireServer("AddMoney", amt)
                remote:FireServer(amt)
            end
        end)
    end
    
    btnAnchors.Text = "¡Anclas Guardadas en Servidor!"
    task.wait(1.5)
    btnAnchors.Text = "Actualizar & Sincronizar Anclas"
end)

btnExp.MouseButton1Click:Connect(function()
    local amt = tonumber(expInput.Text)
    if not amt then return end
    
    local valObj = findStatValue(expKeywords)
    if valObj then valObj.Value = valObj.Value + amt end
    
    for _, remote in ipairs(getActiveRemotes()) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer("AddExp", amt)
                remote:FireServer("AddExperience", amt)
                remote:FireServer("UpdateLevel", amt)
            end
        end)
    end
    
    btnExp.Text = "¡EXP Sincronizada con Barra Oficial!"
    task.wait(1.5)
    btnExp.Text = "Sincronizar Barra y Servidor"
end)


-- === SECCIÓN 2: ISLAS & TELETRANSPORTE (Página 2) ===
local tpCard = Instance.new("Frame")
tpCard.Size = UDim2.new(1, 0, 0, 110)
tpCard.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
tpCard.BorderSizePixel = 0
Instance.new("UICorner", tpCard).CornerRadius = UDim.new(0, 10)
tpCard.Parent = page2

local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1, -20, 0, 25)
tpLabel.Position = UDim2.new(0, 12, 0, 8)
tpLabel.BackgroundTransparency = 1
tpLabel.Font = Enum.Font.GothamSemibold
tpLabel.TextColor3 = Color3.fromRGB(190, 200, 220)
tpLabel.TextSize = 12
tpLabel.TextXAlignment = Enum.TextXAlignment.Left
tpLabel.Text = "🏝️ Selector de Puertos / Islas Navales"
tpLabel.Parent = tpCard

local islandBtn = Instance.new("TextButton")
islandBtn.Size = UDim2.new(1, -24, 0, 32)
islandBtn.Position = UDim2.new(0, 12, 0, 35)
islandBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
islandBtn.Font = Enum.Font.Gotham
islandBtn.Text = "Escanear Islas en el Mapa"
islandBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
islandBtn.TextSize = 12
Instance.new("UICorner", islandBtn).CornerRadius = UDim.new(0, 6)
islandBtn.Parent = tpCard

local tpActionBtn = Instance.new("TextButton")
tpActionBtn.Size = UDim2.new(1, -24, 0, 28)
tpActionBtn.Position = UDim2.new(0, 12, 0, 72)
tpActionBtn.BackgroundColor3 = Color3.fromRGB(211, 84, 0)
tpActionBtn.Font = Enum.Font.GothamBold
tpActionBtn.Text = "Teletransportar a Isla Seleccionada"
tpActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpActionBtn.TextSize = 12
Instance.new("UICorner", tpActionBtn).CornerRadius = UDim.new(0, 6)
tpActionBtn.Parent = tpCard

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
        char.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 12, 0)
        tpActionBtn.Text = "¡Teletransportado con Éxito!"
        task.wait(1.5)
        tpActionBtn.Text = "Teletransportar a Isla Seleccionada"
    else
        tpActionBtn.Text = "⚠️ Error en la posición de la isla"
    end
end)


-- === SECCIÓN 3: AUTO-COMPLETAR MISIONES / TAREAS (Página 3) ===
local taskCard = Instance.new("Frame")
taskCard.Size = UDim2.new(1, 0, 0, 110)
taskCard.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
taskCard.BorderSizePixel = 0
Instance.new("UICorner", taskCard).CornerRadius = UDim.new(0, 10)
taskCard.Parent = page3

local taskLabel = Instance.new("TextLabel")
taskLabel.Size = UDim2.new(1, -20, 0, 25)
taskLabel.Position = UDim2.new(0, 12, 0, 8)
taskLabel.BackgroundTransparency = 1
taskLabel.Font = Enum.Font.GothamSemibold
taskLabel.TextColor3 = Color3.fromRGB(190, 200, 220)
taskLabel.TextSize = 12
taskLabel.TextXAlignment = Enum.TextXAlignment.Left
taskLabel.Text = "⚡ Automatización de Misiones (Auto-Tasks)"
taskLabel.Parent = taskCard

local autoTaskToggle = false
local autoTaskBtn = Instance.new("TextButton")
autoTaskBtn.Size = UDim2.new(1, -24, 0, 32)
autoTaskBtn.Position = UDim2.new(0, 12, 0, 35)
autoTaskBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
autoTaskBtn.Font = Enum.Font.GothamBold
autoTaskBtn.Text = "Estado Auto-Tareas: [ OFF ]"
autoTaskBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoTaskBtn.TextSize = 12
Instance.new("UICorner", autoTaskBtn).CornerRadius = UDim.new(0, 6)
autoTaskBtn.Parent = taskCard

local claimRewardsBtn = Instance.new("TextButton")
claimRewardsBtn.Size = UDim2.new(1, -24, 0, 28)
claimRewardsBtn.Position = UDim2.new(0, 12, 0, 72)
claimRewardsBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
claimRewardsBtn.Font = Enum.Font.GothamBold
claimRewardsBtn.Text = "Reclamar Recompensas Pendientes"
claimRewardsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
claimRewardsBtn.TextSize = 12
Instance.new("UICorner", claimRewardsBtn).CornerRadius = UDim.new(0, 6)
claimRewardsBtn.Parent = taskCard

autoTaskBtn.MouseButton1Click:Connect(function()
    autoTaskToggle = not autoTaskToggle
    if autoTaskToggle then
        autoTaskBtn.Text = "Estado Auto-Tareas: [ ON 🟢 ]"
        autoTaskBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    else
        autoTaskBtn.Text = "Estado Auto-Tareas: [ OFF 🔴 ]"
        autoTaskBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
    end
end)

-- Bucle de ejecución para auto-completar misiones en segundo plano
task.spawn(function()
    while true do
        task.wait(1)
        if autoTaskToggle then
            for _, remote in ipairs(getActiveRemotes()) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer("CompleteQuest")
                        remote:FireServer("FinishTask")
                        remote:FireServer("ClaimQuest")
                        remote:FireServer("RedeemReward")
                    end
                end)
            end
        end
    end
end)

claimRewardsBtn.MouseButton1Click:Connect(function()
    for _, remote in ipairs(getActiveRemotes()) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer("ClaimReward")
                remote:FireServer("ClaimAll")
                remote:FireServer("CompleteQuest")
            end
        end)
    end
    claimRewardsBtn.Text = "¡Recompensas Forzadas con Éxito!"
    task.wait(1.5)
    claimRewardsBtn.Text = "Reclamar Recompensas Pendientes"
end)