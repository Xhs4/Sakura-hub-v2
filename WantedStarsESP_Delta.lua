-- LocalScript / Executor (Delta compatible)
-- Owner ESP + Aim Assist + Wanted Stars Filter | Rayfield UI

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ┌──────────────────────────────────────┐
-- │  YOUR ROBLOX USER ID HERE            │
-- └──────────────────────────────────────┘
local OWNER_ID = 0 -- pon tu UserId si quieres que solo tú lo puedas usar

if OWNER_ID ~= 0 and LocalPlayer.UserId ~= OWNER_ID then return end

-- ─── Load Rayfield ────────────────────────────────────────────────────────────
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ─── Global Settings ─────────────────────────────────────────────────────────
local S = {
    -- ESP
    HighlightOn  = false,
    BoxOn        = true,
    TracerOn     = true,
    HealthBarOn  = true,
    NameOn       = true,
    DistanceOn   = true,
    TeamCheck    = false,
    OnlyStars    = true,          -- ← solo jugadores con estrellas
    EnemyColor   = Color3.fromRGB(255, 60,  60),
    TeamColor    = Color3.fromRGB(60,  200, 255),
    StarsColor   = Color3.fromRGB(255, 50,  50), -- color cuando tiene estrellas
    BoxThickness = 2,
    TracerOrigin = "Bottom",
    FillAlpha    = 0.6,
    MaxDist      = 0,

    -- Aim Assist
    AimAssistOn      = false,
    AimStrength      = 0.08,
    AimFOV           = 150,
    AimBone          = "Head",
    AimTeamCheck     = true,
    ShowFOVCircle    = true,
    FOVColor         = Color3.fromRGB(255, 255, 255),
}

-- ─── Color palettes ───────────────────────────────────────────────────────────
local ENEMY_PALETTE = {
    Red    = Color3.fromRGB(255, 60,  60),
    Orange = Color3.fromRGB(255, 140, 30),
    Yellow = Color3.fromRGB(255, 220, 50),
    Purple = Color3.fromRGB(180, 50,  255),
    White  = Color3.fromRGB(255, 255, 255),
}
local TEAM_PALETTE = {
    Blue  = Color3.fromRGB(60,  150, 255),
    Green = Color3.fromRGB(60,  255, 100),
    Cyan  = Color3.fromRGB(0,   255, 220),
    White = Color3.fromRGB(255, 255, 255),
}

-- ─── ScreenGui ───────────────────────────────────────────────────────────────
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name           = "OwnerESP"
ESPGui.ResetOnSpawn   = false
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ESPGui.IgnoreGuiInset = true
ESPGui.Parent         = PlayerGui

-- ─── Frame pool ──────────────────────────────────────────────────────────────
local pool    = {}
local poolIdx = 0

local function acquire(class)
    poolIdx += 1
    if pool[poolIdx] then
        pool[poolIdx].Visible = true
        return pool[poolIdx]
    end
    local o = Instance.new(class)
    o.Parent = ESPGui
    pool[poolIdx] = o
    return o
end

local function flushPool()
    for i = poolIdx + 1, #pool do
        pool[i].Visible = false
    end
    poolIdx = 0
end

-- ─── Draw primitives ─────────────────────────────────────────────────────────
local function drawRect(x, y, w, h, color, t)
    t = t or S.BoxThickness
    local function bar(px, py, pw, ph)
        local f = acquire("Frame")
        f.BackgroundColor3 = color
        f.BorderSizePixel  = 0
        f.Size     = UDim2.fromOffset(pw, ph)
        f.Position = UDim2.fromOffset(px, py)
    end
    bar(x - t/2,     y,         w + t, t)
    bar(x - t/2,     y + h,     w + t, t)
    bar(x,           y,         t,     h)
    bar(x + w,       y,         t,     h)
end

local function drawLine(a, b, color, thickness)
    local d   = b - a
    local len = d.Magnitude
    if len < 1 then return end
    local mid = (a + b) / 2
    local ln  = acquire("Frame")
    ln.AnchorPoint      = Vector2.new(0.5, 0.5)
    ln.BackgroundColor3 = color
    ln.BorderSizePixel  = 0
    ln.Size     = UDim2.fromOffset(len, thickness or S.BoxThickness)
    ln.Position = UDim2.fromOffset(mid.X, mid.Y)
    ln.Rotation = math.deg(math.atan2(d.Y, d.X))
end

local function drawText(x, y, text, color, size)
    local lbl = acquire("TextLabel")
    lbl.AnchorPoint            = Vector2.new(0.5, 0.5)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3             = color
    lbl.TextStrokeTransparency = 0.4
    lbl.TextStrokeColor3       = Color3.new(0, 0, 0)
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = size or 13
    lbl.Text                   = text
    lbl.Size                   = UDim2.fromOffset(200, 20)
    lbl.Position               = UDim2.fromOffset(x, y)
end

local function drawHealthBar(x, y, h, pct)
    local barH = math.max(1, h * pct)
    local bg   = acquire("Frame")
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.BorderSizePixel  = 0
    bg.Size     = UDim2.fromOffset(4, h)
    bg.Position = UDim2.fromOffset(x, y)
    local fill  = acquire("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(
        math.floor((1 - pct) * 255),
        math.floor(pct * 220),
        40
    )
    fill.BorderSizePixel = 0
    fill.Size     = UDim2.fromOffset(4, barH)
    fill.Position = UDim2.fromOffset(x, y + (h - barH))
end

local FOV_SEGMENTS = 40
local function drawCircle(cx, cy, radius, color)
    for i = 0, FOV_SEGMENTS - 1 do
        local a1 = (i     / FOV_SEGMENTS) * math.pi * 2
        local a2 = ((i+1) / FOV_SEGMENTS) * math.pi * 2
        local p1 = Vector2.new(cx + math.cos(a1) * radius, cy + math.sin(a1) * radius)
        local p2 = Vector2.new(cx + math.cos(a2) * radius, cy + math.sin(a2) * radius)
        drawLine(p1, p2, color, 1)
    end
end

-- ─── Highlight pool ──────────────────────────────────────────────────────────
local highlights = {}

local function ensureHL(player)
    if not highlights[player] then
        local hl = Instance.new("Highlight")
        hl.FillTransparency    = S.FillAlpha
        hl.OutlineTransparency = 0
        hl.Enabled = false
        hl.Parent  = workspace
        highlights[player] = hl
    end
    return highlights[player]
end

Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then highlights[p]:Destroy(); highlights[p] = nil end
end)

-- ─── DETECCIÓN DE ESTRELLAS (Wanted System) ──────────────────────────────────
local POSSIBLE_NAMES = {
    "Stars", "WantedStars", "WantedLevel", "Wanted", "BountyStars",
    "StarCount", "StarsValue", "WantedValue", "Notoriety",
    "stars", "wanted", "wantedlevel", "bounty", "WantedStarsValue"
}

local function getStars(player)
    if not player then return 0 end

    -- Attributes del Player
    for _, name in ipairs(POSSIBLE_NAMES) do
        local v = player:GetAttribute(name)
        if typeof(v) == "number" and v > 0 then return v end
    end

    -- Attributes del Character
    local char = player.Character
    if char then
        for _, name in ipairs(POSSIBLE_NAMES) do
            local v = char:GetAttribute(name)
            if typeof(v) == "number" and v > 0 then return v end
        end
    end

    -- IntValue / NumberValue directos
    for _, name in ipairs(POSSIBLE_NAMES) do
        local val = player:FindFirstChild(name)
        if val and (val:IsA("IntValue") or val:IsA("NumberValue")) and val.Value > 0 then
            return val.Value
        end
    end

    -- Folders comunes
    local folders = {"Stats", "Data", "Values", "PlayerData", "Info", "leaderstats", "CharacterData"}
    for _, fname in ipairs(folders) do
        local folder = player:FindFirstChild(fname)
        if folder then
            for _, name in ipairs(POSSIBLE_NAMES) do
                local val = folder:FindFirstChild(name, true)
                if val and (val:IsA("IntValue") or val:IsA("NumberValue")) and val.Value > 0 then
                    return val.Value
                end
            end
        end
    end

    -- Overhead / BillboardGui (estrellas visuales)
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            for _, gui in ipairs(head:GetChildren()) do
                if gui:IsA("BillboardGui") then
                    local starCount = 0
                    for _, child in ipairs(gui:GetDescendants()) do
                        if (child:IsA("ImageLabel") or child:IsA("ImageButton")) and child.Visible then
                            local img = string.lower(tostring(child.Image or ""))
                            if string.find(img, "star") or string.find(img, "wanted") then
                                starCount += 1
                            end
                        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
                            local txt = child.Text or ""
                            for _ in string.gmatch(txt, "★") do starCount += 1 end
                            local num = tonumber(txt)
                            if num and num > 0 and num <= 6 then return num end
                        end
                    end
                    if starCount > 0 then return starCount end
                end
            end
        end
    end

    return 0
end

-- ─── Utility ─────────────────────────────────────────────────────────────────
local whitelisted = {}

local function shouldSkip(p)
    if whitelisted[p] then return true end
    if S.TeamCheck and p.Team and p.Team == LocalPlayer.Team then return true end
    if S.OnlyStars and getStars(p) <= 0 then return true end
    return false
end

local function getOrigin2D()
    local vp = Camera.ViewportSize
    if S.TracerOrigin == "Center" then return Vector2.new(vp.X/2, vp.Y/2)
    elseif S.TracerOrigin == "Top"    then return Vector2.new(vp.X/2, 0)
    else                                   return Vector2.new(vp.X/2, vp.Y) end
end

local function getCharBox(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local cf = root.CFrame
    local sx, sy, sz = 1.1, 2.6, 0.6
    local pts = {
        cf*Vector3.new( sx, sy, sz), cf*Vector3.new(-sx, sy, sz),
        cf*Vector3.new( sx,-sy, sz), cf*Vector3.new(-sx,-sy, sz),
        cf*Vector3.new( sx, sy,-sz), cf*Vector3.new(-sx, sy,-sz),
        cf*Vector3.new( sx,-sy,-sz), cf*Vector3.new(-sx,-sy,-sz),
    }
    local mnX, mnY, mxX, mxY = math.huge, math.huge, -math.huge, -math.huge
    local hit = false
    for _, v in ipairs(pts) do
        local sp, on = Camera:WorldToViewportPoint(v)
        if sp.Z > 0 then
            hit = true
            mnX = math.min(mnX, sp.X); mnY = math.min(mnY, sp.Y)
            mxX = math.max(mxX, sp.X); mxY = math.max(mxY, sp.Y)
        end
    end
    if not hit then return nil end
    return mnX, mnY, mxX - mnX, mxY - mnY
end

-- ─── Aim Assist ──────────────────────────────────────────────────────────────
local function getAimTarget()
    local vp      = Camera.ViewportSize
    local center  = Vector2.new(vp.X / 2, vp.Y / 2)
    local bestDist = S.AimFOV
    local bestTarget = nil

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if S.AimTeamCheck and p.Team and p.Team == LocalPlayer.Team then continue end
        if whitelisted[p] then continue end
        if S.OnlyStars and getStars(p) <= 0 then continue end

        local char = p.Character
        if not char then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local bone = char:FindFirstChild(S.AimBone)
                  or char:FindFirstChild("HumanoidRootPart")
        if not bone then continue end

        local sp, onScreen = Camera:WorldToViewportPoint(bone.Position)
        if not onScreen or sp.Z <= 0 then continue end

        local screenPos = Vector2.new(sp.X, sp.Y)
        local dist2D    = (screenPos - center).Magnitude

        if dist2D < bestDist then
            bestDist   = dist2D
            bestTarget = bone
        end
    end

    return bestTarget
end

-- ─── Render loop ─────────────────────────────────────────────────────────────
local myRoot = nil
LocalPlayer.CharacterAdded:Connect(function(c)
    myRoot = c:WaitForChild("HumanoidRootPart")
end)
if LocalPlayer.Character then
    myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

RunService.RenderStepped:Connect(function()
    poolIdx = 0

    -- Aim Assist
    if S.AimAssistOn then
        local target = getAimTarget()
        if target then
            local targetCF  = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame   = Camera.CFrame:Lerp(targetCF, S.AimStrength)
        end
    end

    -- FOV Circle
    if S.ShowFOVCircle and S.AimAssistOn then
        local vp = Camera.ViewportSize
        drawCircle(vp.X/2, vp.Y/2, S.AimFOV, S.FOVColor)
    end

    -- Per-player ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local skip  = shouldSkip(player)
        local stars = getStars(player)
        local color = S.EnemyColor

        if stars > 0 then
            color = S.StarsColor
        elseif S.TeamCheck and player.Team == LocalPlayer.Team then
            color = S.TeamColor
        end

        -- Highlight
        local hl   = ensureHL(player)
        local char = player.Character
        if char then
            hl.Adornee          = char
            hl.FillColor        = color
            hl.OutlineColor     = color
            hl.FillTransparency = S.FillAlpha
            hl.Enabled          = S.HighlightOn and not skip
        else
            hl.Enabled = false
        end

        if not char or skip then continue end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
        if S.MaxDist > 0 and dist > S.MaxDist then continue end

        local rsp, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen or rsp.Z <= 0 then continue end
        local rootV2 = Vector2.new(rsp.X, rsp.Y)

        local bx, by, bw, bh = getCharBox(char)
        local hasBox = bx ~= nil

        if S.BoxOn and hasBox then
            drawRect(bx, by, bw, bh, color, S.BoxThickness)
        end

        if S.HealthBarOn and hasBox then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local pct = hum and math.clamp(hum.Health / hum.MaxHealth, 0, 1) or 0
            drawHealthBar(bx - 8, by, bh, pct)
        end

        if S.NameOn and hasBox then
            local nameText = player.DisplayName
            if stars > 0 then
                nameText = nameText .. " ★" .. stars
            end
            drawText(bx + bw/2, by - 16, nameText, color, 13)
        end

        if S.DistanceOn and hasBox then
            drawText(bx + bw/2, by + bh + 4,
                string.format("[%d studs]", math.floor(dist)),
                Color3.fromRGB(200, 200, 200), 11)
        end

        if S.TracerOn then
            drawLine(getOrigin2D(), rootV2, color, S.BoxThickness)
        end
    end

    flushPool()
end)

-- ─── Rayfield UI ─────────────────────────────────────────────────────────────
local Window = Rayfield:CreateWindow({
    Name            = "Owner ESP + Stars",
    LoadingTitle    = "ESP Panel",
    LoadingSubtitle = "Wanted Stars Filter",
    ConfigurationSaving = { Enabled = false },
    Discord         = { Enabled = false },
    KeySystem       = false,
})

-- ══ TAB 1 · Features ════════════════════════════════════════════════════════
local FeatTab = Window:CreateTab("Features", 4483362458)

FeatTab:CreateSection("Visuals")
FeatTab:CreateToggle({ Name = "Box ESP",        CurrentValue = true,  Flag = "BoxOn",
    Callback = function(v) S.BoxOn       = v end })
FeatTab:CreateToggle({ Name = "Highlight",      CurrentValue = false, Flag = "HLOn",
    Callback = function(v) S.HighlightOn = v end })
FeatTab:CreateToggle({ Name = "Tracers",        CurrentValue = true,  Flag = "TracOn",
    Callback = function(v) S.TracerOn    = v end })
FeatTab:CreateToggle({ Name = "Health Bar",     CurrentValue = true,  Flag = "HPOn",
    Callback = function(v) S.HealthBarOn = v end })
FeatTab:CreateToggle({ Name = "Name Tag",       CurrentValue = true,  Flag = "NameOn",
    Callback = function(v) S.NameOn      = v end })
FeatTab:CreateToggle({ Name = "Distance Label", CurrentValue = true,  Flag = "DistOn",
    Callback = function(v) S.DistanceOn  = v end })

FeatTab:CreateSection("Filtros")
FeatTab:CreateToggle({ Name = "Only Stars (Wanted)", CurrentValue = true, Flag = "OnlyStars",
    Callback = function(v) S.OnlyStars = v end })
FeatTab:CreateToggle({ Name = "Team Check (hide allies)", CurrentValue = false, Flag = "TmChk",
    Callback = function(v) S.TeamCheck = v end })

FeatTab:CreateSection("Performance")
FeatTab:CreateSlider({
    Name = "Max Render Distance (0 = unlimited)",
    Range = {0, 1000}, Increment = 50, CurrentValue = 0, Flag = "MaxDist",
    Callback = function(v) S.MaxDist = v end,
})

-- ══ TAB 2 · Aim Assist ══════════════════════════════════════════════════════
local AimTab = Window:CreateTab("Aim Assist", 4483362458)

AimTab:CreateSection("Toggle")
AimTab:CreateToggle({
    Name = "Enable Aim Assist",
    CurrentValue = false,
    Flag = "AimOn",
    Callback = function(v) S.AimAssistOn = v end,
})
AimTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Flag = "ShowFOV",
    Callback = function(v) S.ShowFOVCircle = v end,
})

AimTab:CreateSection("Strength")
AimTab:CreateSlider({
    Name = "Aim Strength",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = 8,
    Flag = "AimStr",
    Callback = function(v) S.AimStrength = v / 100 end,
})

AimTab:CreateSection("Field of View")
AimTab:CreateSlider({
    Name = "FOV Radius (pixels)",
    Range = {30, 400},
    Increment = 10,
    CurrentValue = 150,
    Flag = "AimFOV",
    Callback = function(v) S.AimFOV = v end,
})

AimTab:CreateSection("Target Bone")
AimTab:CreateDropdown({
    Name = "Aim At",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Flag = "AimBone",
    Callback = function(v) S.AimBone = v end,
})

AimTab:CreateSection("Safety")
AimTab:CreateToggle({
    Name = "Never Aim at Teammates",
    CurrentValue = true,
    Flag = "AimTeamChk",
    Callback = function(v) S.AimTeamCheck = v end,
})

-- ══ TAB 3 · Style ════════════════════════════════════════════════════════════
local StyleTab = Window:CreateTab("Style", 4483362458)

StyleTab:CreateSection("Box")
StyleTab:CreateSlider({
    Name = "Box Thickness", Range = {1, 5}, Increment = 1, CurrentValue = 2, Flag = "BoxThk",
    Callback = function(v) S.BoxThickness = v end,
})

StyleTab:CreateSection("Tracer")
StyleTab:CreateDropdown({
    Name = "Tracer Origin", Options = {"Bottom","Center","Top"},
    CurrentOption = "Bottom", Flag = "TrOrigin",
    Callback = function(v) S.TracerOrigin = v end,
})

StyleTab:CreateSection("Highlight")
StyleTab:CreateSlider({
    Name = "Fill Transparency (0=solid 10=hidden)",
    Range = {0,10}, Increment = 1, CurrentValue = 6, Flag = "FillAlpha",
    Callback = function(v) S.FillAlpha = v / 10 end,
})

-- ══ TAB 4 · Colors ════════════════════════════════════════════════════════════
local ColTab = Window:CreateTab("Colors", 4483362458)

ColTab:CreateSection("Enemy Color")
ColTab:CreateDropdown({
    Name = "Enemy Color", Flag = "EnemyCol",
    Options = {"Red","Orange","Yellow","Purple","White"}, CurrentOption = "Red",
    Callback = function(v) S.EnemyColor = ENEMY_PALETTE[v] or S.EnemyColor end,
})

ColTab:CreateSection("Team Color")
ColTab:CreateDropdown({
    Name = "Team Color", Flag = "TeamCol",
    Options = {"Blue","Green","Cyan","White"}, CurrentOption = "Blue",
    Callback = function(v) S.TeamColor = TEAM_PALETTE[v] or S.TeamColor end,
})

ColTab:CreateSection("FOV Circle Color")
ColTab:CreateDropdown({
    Name = "FOV Circle Color", Flag = "FOVCol",
    Options = {"White","Red","Green","Blue","Yellow"}, CurrentOption = "White",
    Callback = function(v)
        local map = {
            White  = Color3.fromRGB(255,255,255), Red  = Color3.fromRGB(255,60,60),
            Green  = Color3.fromRGB(60,255,100),  Blue = Color3.fromRGB(60,150,255),
            Yellow = Color3.fromRGB(255,220,50),
        }
        S.FOVColor = map[v] or S.FOVColor
    end,
})

-- ══ TAB 5 · Players ════════════════════════════════════════════════════════════
local PlrTab = Window:CreateTab("Players", 4483362458)

PlrTab:CreateSection("Whitelist (hide ESP + aim skip)")

local function nameList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return #t > 0 and t or {"(empty)"}
end

PlrTab:CreateDropdown({
    Name = "Select Player", Options = nameList(),
    CurrentOption = nameList()[1], Flag = "PlrSel",
    Callback = function() end,
})

PlrTab:CreateButton({ Name = "Whitelist Player", Callback = function()
    local f = Rayfield.Flags["PlrSel"]
    if not f then return end
    local p = Players:FindFirstChild(f.CurrentOption)
    if p then
        whitelisted[p] = true
        Rayfield:Notify({ Title = "Whitelisted", Content = f.CurrentOption .. " hidden from ESP & aim.", Duration = 3 })
    end
end})

PlrTab:CreateButton({ Name = "Remove from Whitelist", Callback = function()
    local f = Rayfield.Flags["PlrSel"]
    if not f then return end
    local p = Players:FindFirstChild(f.CurrentOption)
    if p then whitelisted[p] = nil end
    Rayfield:Notify({ Title = "Removed", Content = "Player restored to ESP & aim.", Duration = 3 })
end})

PlrTab:CreateSection("Bulk")
PlrTab:CreateButton({ Name = "Disable ALL ESP", Callback = function()
    S.BoxOn = false; S.HighlightOn = false
    S.TracerOn = false; S.HealthBarOn = false
    S.NameOn = false; S.DistanceOn = false
    for _, hl in pairs(highlights) do hl.Enabled = false end
    Rayfield:Notify({ Title = "ESP Off", Content = "All ESP features disabled.", Duration = 3 })
end})

print("✅ Owner ESP + Wanted Stars cargado (Delta)")
