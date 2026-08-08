local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if _G.CarunoHubUI and type(_G.CarunoHubUI.Destroy) == "function" then
	pcall(_G.CarunoHubUI.Destroy)
end

local oldGui = playerGui:FindFirstChild("CarunoHubUI")
if oldGui then
	oldGui:Destroy()
end

local COLORS = {
	Void        = Color3.fromRGB(2, 2, 3),
	Background  = Color3.fromRGB(6, 6, 7),
	Panel       = Color3.fromRGB(11, 11, 12),
	PanelLight  = Color3.fromRGB(16, 16, 18),
	PanelHover  = Color3.fromRGB(23, 23, 26),
	PanelActive = Color3.fromRGB(30, 30, 34),
	Stroke      = Color3.fromRGB(52, 52, 58),
	StrokeSoft  = Color3.fromRGB(29, 29, 33),
	Text        = Color3.fromRGB(247, 247, 249),
	Subtle      = Color3.fromRGB(170, 170, 178),
	Muted       = Color3.fromRGB(116, 116, 124),
	Faint       = Color3.fromRGB(72, 72, 80),
	Accent      = Color3.fromRGB(247, 247, 249),
	AccentDark  = Color3.fromRGB(148, 148, 156),
	Black       = Color3.fromRGB(4, 4, 5),
	Green       = Color3.fromRGB(88, 214, 134),
	Amber       = Color3.fromRGB(228, 178, 84),
	Red         = Color3.fromRGB(228, 88, 88),
}

local TWEEN_FAST   = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_NORMAL = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_SLOW   = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_POP    = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local connections = {}
local pages = {}
local navButtons = {}
local listeners = {}
local values = {
	altSpeed = 60,
	vehicleAltSpeed = 200,
	vehicleAltRisky = false,
	language = (type(_G.CarunoHubLanguage) == "string" and _G.CarunoHubLanguage) or "English",
}

local currentLanguage = values.language
local TEXT = {
	["Scripts"] = { Russian = "Скрипты", Spanish = "Scripts" },
	["Physics Ram"] = { Russian = "Физический таран", Spanish = "Ariete físico" },
	["Vehicle"] = { Russian = "Транспорт", Spanish = "Vehículo" },
	["Player"] = { Russian = "Персонаж", Spanish = "Jugador" },
	["Combat"] = { Russian = "Оружие", Spanish = "Combate" },
	["Robbery"] = { Russian = "Ограбления", Spanish = "Robos" },
	["Vehicle Anti-Collision"] = {
		Russian = "Антиколлизия транспорта",
		Spanish = "Anticolisión de vehículos",
	},
	["Remove Border Speed Limit"] = {
		Russian = "Без лимита на таможне",
		Spanish = "Sin límite en la frontera",
	},
	["Anti PIT"] = { Russian = "Защита от подрезания", Spanish = "Anti PIT" },
	["Alt Speed"] = { Russian = "Скорость на Alt", Spanish = "Velocidad con Alt" },
	["Vehicle Speed on Alt"] = {
		Russian = "Скорость транспорта на Alt",
		Spanish = "Velocidad del vehículo con Alt",
	},
	["Vehicle Alt Speed"] = {
		Russian = "Скорость транспорта на Alt",
		Spanish = "Velocidad del vehículo con Alt",
	},
	["Infinite Stamina"] = { Russian = "Бесконечная стамина", Spanish = "Resistencia infinita" },
	["No Recoil"] = { Russian = "Без отдачи", Spanish = "Sin retroceso" },
	["Auto Farm"] = { Russian = "Автофарм", Spanish = "Auto farm" },
	["Start"] = { Russian = "Запустить", Spanish = "Iniciar" },
	["Stop"] = { Russian = "Остановить", Spanish = "Detener" },
	["Run once"] = { Russian = "Запустить один раз", Spanish = "Ejecutar una vez" },
	["Confirm"] = { Russian = "Подтвердить", Spanish = "Confirmar" },
	["Executed"] = { Russian = "Запущено", Spanish = "Ejecutado" },
	["Failed"] = { Russian = "Ошибка", Spanish = "Error" },
	["Executor required"] = { Russian = "Нужен executor", Spanish = "Requiere executor" },
	["Settings"] = { Russian = "Настройки", Spanish = "Ajustes" },
	["Language"] = { Russian = "Язык", Spanish = "Idioma" },
	["Background"] = { Russian = "Фон", Spanish = "Fondo" },
	["Compact mode"] = { Russian = "Компактный режим", Spanish = "Modo compacto" },
	["Unload interface"] = { Russian = "Выгрузить интерфейс", Spanish = "Cerrar interfaz" },
	["Unload"] = { Russian = "Выгрузить", Spanish = "Cerrar" },
}

local function translate(key)
	local entry = TEXT[key]
	if not entry or currentLanguage == "English" then
		return key
	end
	return entry[currentLanguage] or key
end

local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
	return connection
end

local function tween(instance, properties, tweenInfo)
	local animation = TweenService:Create(instance, tweenInfo or TWEEN_FAST, properties)
	animation:Play()
	return animation
end

local function create(className, properties, children)
	local instance = Instance.new(className)

	for property, value in pairs(properties or {}) do
		instance[property] = value
	end

	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end

	return instance
end

local function corner(radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius),
	})
end

local function stroke(color, thickness, transparency)
	return create("UIStroke", {
		Color = color or COLORS.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	})
end

local UI = {}

function UI.gradient(rotation, colorSequence, transparencySequence)
	local instance = create("UIGradient", { Rotation = rotation or 0 })
	if colorSequence then
		instance.Color = colorSequence
	end
	if transparencySequence then
		instance.Transparency = transparencySequence
	end
	return instance
end

function UI.dot(parent, diameter, color)
	return create("Frame", {
		Name = "Dot",
		Size = UDim2.fromOffset(diameter, diameter),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = parent,
	}, {
		corner(math.ceil(diameter / 2)),
	})
end

function UI.label(parent, props)
	props.BackgroundTransparency = 1
	props.Parent = parent
	return create("TextLabel", props)
end

function UI.hover(button, enter, leave)
	connect(button.MouseEnter, enter)
	connect(button.MouseLeave, leave)
end

local function emit(name, value)
	values[name] = value

	if listeners[name] then
		for _, callback in ipairs(listeners[name]) do
			task.spawn(callback, value)
		end
	end
end

local VehicleUtil
do
	local ok, module = pcall(function()
		return require(
			ReplicatedStorage
				:WaitForChild("SharedModules", 10)
				:WaitForChild("VehicleUtil", 10)
		)
	end)
	if ok and type(module) == "table" then
		VehicleUtil = module
	end
end

local speedSaved = setmetatable({}, { __mode = "k" })
local altHeld = false

local STUDS_PER_MPH = 1.6

local vehicleSpeedWarned = false
local function warnVehicleSpeedOnce()
	if vehicleSpeedWarned then
		return
	end
	vehicleSpeedWarned = true
	warn("[CARUNOHUB] Vehicle Speed: vehicle model not resolved (VehicleUtil / Workspace.Vehicles)")
end

local RAM_SOURCE = [==[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Vehicles = Workspace:WaitForChild("Vehicles")
local VehicleUtil = require(ReplicatedStorage.SharedModules.VehicleUtil)
local RequestPitRemote = ReplicatedStorage
	:WaitForChild("__remotes")
	:WaitForChild("VehicleService")
	:WaitForChild("RequestPitManeuver")

local env = (getgenv and getgenv()) or _G
local ACTION_NAME = "__VehiclePhysRamV9"

for _, name in ipairs({
	"VehicleLaunchCleanup", "VehicleRamV7Cleanup",
	"VehiclePhysRamCleanup", "VehicleRamHammerCleanup",
	"VehiclePitRamCleanup"
}) do
	if type(env[name]) == "function" then
		pcall(env[name])
	end
end

local CONFIG = {
	MaxTargetDistance = 150,
	RamSpeed = 2000,
	MassMultiplier = 100000,
	SpinSpeed = 55,
	RepositionDistance = 16,
	RearGap = 2,
	PitInterval = 1.05,
	SimulationRadius = 5000,
	ReturnLift = 3.5,
	LiftFrames = 10,
	ExactFrames = 60,
	SettleFrames = 12,
}

local running = true
local attacking = false
local restoring = false
local ownVehicle, ownRoot
local targetVehicle, targetRoot
local savedState
local savedRootProps
local attackConnection
local pitTimer = 0
local attackSide = 1
local didInitialPlace = false

local function boostSimulation()
	pcall(function()
		if type(setsimulationradius) == "function" then
			setsimulationradius(CONFIG.SimulationRadius, CONFIG.SimulationRadius)
		elseif type(sethiddenproperty) == "function" then
			sethiddenproperty(Player, "SimulationRadius", CONFIG.SimulationRadius)
			sethiddenproperty(Player, "MaximumSimulationRadius", CONFIG.SimulationRadius)
		end
	end)
end

local function getDrivenVehicle()
	local character = Player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil, nil
	end
	local vehicle = VehicleUtil:GetHumanoidDrivenVehicle(humanoid)
	if not vehicle then
		return nil, nil
	end
	return vehicle, VehicleUtil:GetVehicleRoot(vehicle)
end

local function findNearestVehicle(sourceVehicle, sourceRoot)
	local bestVehicle, bestRoot
	local bestDistance = CONFIG.MaxTargetDistance
	for _, vehicle in ipairs(Vehicles:GetChildren()) do
		if vehicle:IsA("Model") and vehicle ~= sourceVehicle then
			local root = VehicleUtil:GetVehicleRoot(vehicle)
			if root then
				local distance = (root.Position - sourceRoot.Position).Magnitude
				if distance < bestDistance then
					bestDistance = distance
					bestVehicle = vehicle
					bestRoot = root
				end
			end
		end
	end
	return bestVehicle, bestRoot
end

local function isTargetOccupied(vehicle)
	local occupants = VehicleUtil:GetOccupantCharactersOfVehicle(vehicle)
	if type(occupants) == "table" then
		return next(occupants) ~= nil
	end
	return occupants ~= nil
end

local function createSavedState(vehicle, root)
	local pivot = vehicle:GetPivot()
	local state = { Vehicle = vehicle, Root = root, Pivot = pivot, Parts = {} }
	for _, object in ipairs(vehicle:GetDescendants()) do
		if object:IsA("BasePart") then
			state.Parts[object] = {
				LocalCFrame = pivot:ToObjectSpace(object.CFrame),
				CanCollide = object.CanCollide,
				CanTouch = object.CanTouch,
				CanQuery = object.CanQuery,
				Massless = object.Massless,
				CustomPhysicalProperties = object.CustomPhysicalProperties,
			}
		end
	end
	return state
end

local function zeroPart(part)
	part.AssemblyLinearVelocity = Vector3.zero
	part.AssemblyAngularVelocity = Vector3.zero
end

local function setCollision(state, enabled)
	for part, properties in pairs(state.Parts) do
		if part and part.Parent then
			pcall(function()
				if enabled then
					part.CanCollide = properties.CanCollide
					part.CanTouch = properties.CanTouch
					part.CanQuery = properties.CanQuery
					part.Massless = properties.Massless
					part.CustomPhysicalProperties = properties.CustomPhysicalProperties
				else
					part.CanCollide = false
					part.CanTouch = false
				end
			end)
		end
	end
end

local function placeSavedState(state, pivot)
	if not state.Vehicle or not state.Vehicle.Parent then
		return false
	end
	pcall(function()
		state.Vehicle:PivotTo(pivot)
	end)
	for part, properties in pairs(state.Parts) do
		if part and part.Parent then
			pcall(function()
				part.CFrame = pivot * properties.LocalCFrame
				zeroPart(part)
			end)
		end
	end
	return true
end

local function inflateMass(root)
	savedRootProps = root.CustomPhysicalProperties
	local current = root.CurrentPhysicalProperties
	local baseDensity = current and current.Density or 1
	pcall(function()
		root.Massless = false
		root.CustomPhysicalProperties = PhysicalProperties.new(
			baseDensity * CONFIG.MassMultiplier,
			0.3, 0, 100, 100
		)
	end)
end

local function restoreMass(root)
	if root and root.Parent then
		pcall(function()
			root.CustomPhysicalProperties = savedRootProps
		end)
	end
	savedRootProps = nil
end

local function sendPitRequest()
	if not ownVehicle or not targetVehicle or not RequestPitRemote then
		return
	end
	pcall(function()
		RequestPitRemote:FireServer(ownVehicle, targetVehicle)
	end)
end

local function computeApproachCFrame()
	local look = targetRoot.CFrame.LookVector
	local right = targetRoot.CFrame.RightVector
	local up = targetRoot.CFrame.UpVector
	local size = targetRoot.Size
	local contact = targetRoot.Position
		- look * (size.Z * 0.5 * 0.85)
		+ right * attackSide * (size.X * 0.5)
	local position = contact - look * (ownRoot.Size.Z * 0.5 + CONFIG.RearGap)
	return CFrame.lookAt(position, position + look, up)
end

local function updateRam(deltaTime)
	if not attacking then
		return
	end
	if not ownVehicle or not ownVehicle.Parent
		or not ownRoot or not ownRoot.Parent
		or not targetVehicle or not targetVehicle.Parent
		or not targetRoot or not targetRoot.Parent then
		return
	end

	if not didInitialPlace then
		pcall(function()
			ownVehicle:PivotTo(computeApproachCFrame())
		end)
		didInitialPlace = true
	end

	local distance = (ownRoot.Position - targetRoot.Position).Magnitude
	local reach = targetRoot.Size.Z * 0.5 + ownRoot.Size.Z * 0.5
	if distance > reach + CONFIG.RepositionDistance then
		pcall(function()
			ownVehicle:PivotTo(computeApproachCFrame())
		end)
	end

	local aim = targetRoot.Position
		- targetRoot.CFrame.LookVector * (targetRoot.Size.Z * 0.5 * 0.85)
		+ targetRoot.CFrame.RightVector * attackSide * (targetRoot.Size.X * 0.4)
	local direction = aim - ownRoot.Position
	direction = direction.Magnitude > 0.001 and direction.Unit or targetRoot.CFrame.LookVector

	pcall(function()
		ownRoot.AssemblyLinearVelocity =
			direction * CONFIG.RamSpeed + targetRoot.AssemblyLinearVelocity
		ownRoot.AssemblyAngularVelocity =
			targetRoot.CFrame.UpVector * attackSide * CONFIG.SpinSpeed
	end)

	pitTimer = pitTimer + deltaTime
	if pitTimer >= CONFIG.PitInterval then
		pitTimer = 0
		sendPitRequest()
		attackSide = -attackSide
	end
end

local function clearState()
	ownVehicle, ownRoot = nil, nil
	targetVehicle, targetRoot = nil, nil
	savedState = nil
	pitTimer = 0
	didInitialPlace = false
end

local function restoreVehicle()
	if restoring or not savedState then
		return
	end
	restoring = true
	restoreMass(ownRoot)

	local state = savedState
	local exactPivot = state.Pivot
	local liftedPivot =
		CFrame.new(exactPivot.Position + Vector3.new(0, CONFIG.ReturnLift, 0))
		* exactPivot.Rotation

	task.spawn(function()
		setCollision(state, false)
		for _ = 1, CONFIG.LiftFrames do
			if not placeSavedState(state, liftedPivot) then break end
			RunService.Heartbeat:Wait()
		end
		for _ = 1, CONFIG.ExactFrames do
			if not placeSavedState(state, exactPivot) then break end
			RunService.Heartbeat:Wait()
		end
		setCollision(state, true)
		for _ = 1, CONFIG.SettleFrames do
			if not placeSavedState(state, exactPivot) then break end
			RunService.Heartbeat:Wait()
		end
		restoring = false
		clearState()
	end)
end

local function stopAttack()
	if not attacking then
		return
	end
	attacking = false
	if attackConnection then
		attackConnection:Disconnect()
		attackConnection = nil
	end
	restoreVehicle()
end

local function startAttack()
	if attacking or restoring then
		return
	end
	boostSimulation()

	local vehicle, root = getDrivenVehicle()
	if not vehicle or not root then
		warn("[CARUNOHUB Ram] Sit in the driver seat first")
		return
	end

	local nearest, nearestRoot = findNearestVehicle(vehicle, root)
	if not nearest or not nearestRoot then
		warn("[CARUNOHUB Ram] No nearby vehicle")
		return
	end

	ownVehicle, ownRoot = vehicle, root
	targetVehicle, targetRoot = nearest, nearestRoot
	savedState = createSavedState(vehicle, root)
	didInitialPlace = false
	inflateMass(root)

	local relative = root.Position - nearestRoot.Position
	attackSide = relative:Dot(nearestRoot.CFrame.RightVector) < 0 and 1 or -1
	pitTimer = CONFIG.PitInterval
	attacking = true
	attackConnection = RunService.PreSimulation:Connect(updateRam)

	warn("[CARUNOHUB Ram] Target: " .. nearest.Name
		.. (isTargetOccupied(nearest) and " (occupied)" or " (empty)"))
end

local function handleAlt(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		startAttack()
	elseif inputState == Enum.UserInputState.End
		or inputState == Enum.UserInputState.Cancel then
		stopAttack()
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindActionAtPriority(
	ACTION_NAME, handleAlt, false, 9999,
	Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt
)

task.spawn(function()
	while running do
		boostSimulation()
		task.wait(0.2)
	end
end)

env.VehiclePhysRamCleanup = function()
	if not running then
		return
	end
	running = false
	ContextActionService:UnbindAction(ACTION_NAME)
	stopAttack()
	env.VehiclePhysRamCleanup = nil
end

boostSimulation()
]==]

local COLLISION_SOURCE = [==[local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local env = (getgenv and getgenv()) or _G

for _, name in ipairs({
	"VehicleGhostCleanup",
	"VehicleOnlyCollisionCleanup",
	"VehicleCollisionOnlyCleanup",
}) do
	if type(env[name]) == "function" then
		pcall(env[name])
	end
end

local player = Players.LocalPlayer
local running = true
local constraints = {}

local function destroyConstraint(constraint)
	constraints[constraint] = nil
	if constraint and constraint.Parent then
		constraint:Destroy()
	end
end

local function clearConstraints()
	for constraint in pairs(constraints) do
		pcall(destroyConstraint, constraint)
	end
	table.clear(constraints)
end

local function getVehiclesFolder()
	return Workspace:FindFirstChild("Vehicles")
end

local function getCurrentVehicle()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	local vehicles = getVehiclesFolder()
	if not seat or not seat:IsA("VehicleSeat") or not vehicles then
		return nil
	end

	local object = seat
	while object and object.Parent ~= vehicles do
		object = object.Parent
	end
	if object and object.Parent == vehicles and object:IsA("Model") then
		return object
	end
	return nil
end

local function addBaseParts(container, output)
	if not container then
		return
	end
	for _, object in ipairs(container:GetDescendants()) do
		if object:IsA("BasePart") then
			table.insert(output, object)
		end
	end
end

local function addWheelColliders(wheels, output)
	if not wheels then
		return
	end
	for _, wheel in ipairs(wheels:GetChildren()) do
		local collider = wheel:FindFirstChild("Collider")
		if collider and collider:IsA("BasePart") then
			table.insert(output, collider)
		end
	end
end

local function getVehicleColliders(vehicle)
	local result = {}
	local body = vehicle and vehicle:FindFirstChild("Body")
	if not body then
		return result
	end

	addBaseParts(body:FindFirstChild("Colliders"), result)
	addWheelColliders(vehicle:FindFirstChild("Wheels"), result)

	local trailer = body:FindFirstChild("Trailer")
	if trailer then
		addBaseParts(trailer:FindFirstChild("Colliders"), result)
		addWheelColliders(trailer:FindFirstChild("Wheels"), result)
	end
	return result
end

local function reconcile()
	local vehicles = getVehiclesFolder()
	local ownVehicle = getCurrentVehicle()
	if not vehicles or not ownVehicle then
		clearConstraints()
		return
	end

	local ownParts = getVehicleColliders(ownVehicle)
	local desired = {}
	for _, otherVehicle in ipairs(vehicles:GetChildren()) do
		if otherVehicle:IsA("Model") and otherVehicle ~= ownVehicle then
			local otherParts = getVehicleColliders(otherVehicle)
			for _, ownPart in ipairs(ownParts) do
				if ownPart.Parent then
					local partMap = desired[ownPart]
					if not partMap then
						partMap = {}
						desired[ownPart] = partMap
					end
					for _, otherPart in ipairs(otherParts) do
						if otherPart.Parent then
							partMap[otherPart] = true
						end
					end
				end
			end
		end
	end

	for constraint in pairs(constraints) do
		local part0 = constraint.Part0
		local part1 = constraint.Part1
		local partMap = part0 and desired[part0]
		if not partMap or not partMap[part1] then
			destroyConstraint(constraint)
		else
			partMap[part1] = nil
		end
	end

	for ownPart, partMap in pairs(desired) do
		for otherPart in pairs(partMap) do
			local constraint = Instance.new("NoCollisionConstraint")
			constraint.Name = "__VehicleCollisionOnly"
			constraint.Part0 = ownPart
			constraint.Part1 = otherPart
			constraint.Parent = ownPart
			constraints[constraint] = true
		end
	end
end

env.VehicleCollisionOnlyCleanup = function()
	if not running then
		return
	end
	running = false
	clearConstraints()
	env.VehicleCollisionOnlyCleanup = nil
end

task.spawn(function()
	while running do
		pcall(reconcile)
		task.wait(0.25)
	end
end)
]==]

local GATE_SOURCE = [==[local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local env = (getgenv and getgenv()) or _G

if type(env.GateBarrierCollisionCleanup) == "function" then
	pcall(env.GateBarrierCollisionCleanup)
end

local BARRIER_GROUP = "GateBarrier"
local GATE_TAG = "Gate"

local player = Players.LocalPlayer
local running = true
local constraints = {}

local function destroyConstraint(constraint)
	constraints[constraint] = nil
	if constraint and constraint.Parent then
		constraint:Destroy()
	end
end

local function clearConstraints()
	for constraint in pairs(constraints) do
		pcall(destroyConstraint, constraint)
	end
	table.clear(constraints)
end

local function isBarrierPart(part)
	if not part:IsA("BasePart") or not part.CanCollide then
		return false
	end
	local ok, group = pcall(function()
		return part.CollisionGroup
	end)
	return ok and group == BARRIER_GROUP
end

local function collectBarrierParts()
	local parts = {}

	for _, gate in ipairs(CollectionService:GetTagged(GATE_TAG)) do
		if gate:IsDescendantOf(Workspace) then
			if isBarrierPart(gate) then
				table.insert(parts, gate)
			end
			for _, descendant in ipairs(gate:GetDescendants()) do
				if isBarrierPart(descendant) then
					table.insert(parts, descendant)
				end
			end
		end
	end

	if #parts == 0 then
		for _, object in ipairs(Workspace:GetDescendants()) do
			if isBarrierPart(object) then
				table.insert(parts, object)
			end
		end
	end

	return parts
end

local function getVehiclesFolder()
	return Workspace:FindFirstChild("Vehicles")
end

local function getCurrentVehicle()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seat = humanoid and humanoid.SeatPart
	local vehicles = getVehiclesFolder()
	if not seat or not vehicles then
		return nil
	end

	local object = seat
	while object and object.Parent ~= vehicles do
		object = object.Parent
	end
	if object and object.Parent == vehicles and object:IsA("Model") then
		return object
	end
	return nil
end

local function addBaseParts(container, output)
	if not container then
		return
	end
	for _, object in ipairs(container:GetDescendants()) do
		if object:IsA("BasePart") then
			table.insert(output, object)
		end
	end
end

local function addWheelColliders(wheels, output)
	if not wheels then
		return
	end
	for _, wheel in ipairs(wheels:GetChildren()) do
		local collider = wheel:FindFirstChild("Collider")
		if collider and collider:IsA("BasePart") then
			table.insert(output, collider)
		end
	end
end

local function getMyParts()
	local parts = {}

	local vehicle = getCurrentVehicle()
	if vehicle then
		local body = vehicle:FindFirstChild("Body")
		if body then
			addBaseParts(body:FindFirstChild("Colliders"), parts)
			local trailer = body:FindFirstChild("Trailer")
			if trailer then
				addBaseParts(trailer:FindFirstChild("Colliders"), parts)
				addWheelColliders(trailer:FindFirstChild("Wheels"), parts)
			end
		end
		addWheelColliders(vehicle:FindFirstChild("Wheels"), parts)

		local root = vehicle.PrimaryPart or vehicle:FindFirstChild("Root")
		if root and root:IsA("BasePart") then
			table.insert(parts, root)
		end
	end

	local character = player.Character
	if character then
		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				table.insert(parts, object)
			end
		end
	end

	return parts
end

local function reconcile()
	local myParts = getMyParts()
	if #myParts == 0 then
		clearConstraints()
		return
	end

	local barrierParts = collectBarrierParts()
	if #barrierParts == 0 then
		clearConstraints()
		return
	end

	local desired = {}
	for _, myPart in ipairs(myParts) do
		if myPart.Parent then
			local partMap = desired[myPart]
			if not partMap then
				partMap = {}
				desired[myPart] = partMap
			end
			for _, barrierPart in ipairs(barrierParts) do
				if barrierPart.Parent then
					partMap[barrierPart] = true
				end
			end
		end
	end

	for constraint in pairs(constraints) do
		local part0 = constraint.Part0
		local part1 = constraint.Part1
		local partMap = part0 and desired[part0]
		if not partMap or not partMap[part1] then
			destroyConstraint(constraint)
		else
			partMap[part1] = nil
		end
	end

	for myPart, partMap in pairs(desired) do
		for barrierPart in pairs(partMap) do
			local constraint = Instance.new("NoCollisionConstraint")
			constraint.Name = "__GateBarrierPass"
			constraint.Part0 = myPart
			constraint.Part1 = barrierPart
			constraint.Parent = myPart
			constraints[constraint] = true
		end
	end
end

env.GateBarrierCollisionCleanup = function()
	if not running then
		return
	end
	running = false
	clearConstraints()
	env.GateBarrierCollisionCleanup = nil
end

task.spawn(function()
	while running do
		pcall(reconcile)
		task.wait(0.5)
	end
end)
]==]

local EXTERNAL_AUTO_FARM_SOURCE = [==[loadstring(game:HttpGet("https://pastebin.com/raw/BjUC6X2b"))()
]==]

local NO_RECOIL_SOURCE = [==[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local environment = (getgenv and getgenv()) or _G

if type(environment.CarunoNoRecoilCleanup) == "function" then
	pcall(environment.CarunoNoRecoilCleanup)
end

local gunConfig = require(
	ReplicatedStorage
		:WaitForChild("SharedModules")
		:WaitForChild("Configs")
		:WaitForChild("GunConfig")
)
local cameraController = require(
	ReplicatedStorage
		:WaitForChild("ClientModules")
		:WaitForChild("CameraController")
)

local running = true
local savedStats = {}
local originalImpulsePitch = cameraController.ImpulsePitch
local originalGetRecoilSpring = cameraController.GetRecoilSpring
local realRecoilSpring = cameraController:GetRecoilSpring()

local silentRecoilSpring = setmetatable({
	Impulse = function()
		return nil
	end,
}, {
	__index = realRecoilSpring,
	__newindex = function(_, key, value)
		realRecoilSpring[key] = value
	end,
})

local function clearRecoilSpring()
	pcall(function()
		realRecoilSpring.Position = 0
		realRecoilSpring.Velocity = 0
		realRecoilSpring.Target = 0
	end)
end

local function patchGunStats()
	for _, config in pairs(gunConfig) do
		local stats = type(config) == "table" and config.Stats
		if type(stats) == "table" then
			if not savedStats[stats] then
				savedStats[stats] = {
					HasFirstPerson = rawget(stats, "FirstPersonCameraRecoilFactor") ~= nil,
					HasThirdPerson = rawget(stats, "ThirdPersonCameraRecoilFactor") ~= nil,
					FirstPerson = stats.FirstPersonCameraRecoilFactor,
					ThirdPerson = stats.ThirdPersonCameraRecoilFactor,
				}
			end
			stats.FirstPersonCameraRecoilFactor = 0
			stats.ThirdPersonCameraRecoilFactor = 0
		end
	end
	clearRecoilSpring()
end

local patchedImpulsePitch = function()
	return nil
end
local patchedGetRecoilSpring = function()
	return silentRecoilSpring
end
cameraController.ImpulsePitch = patchedImpulsePitch
cameraController.GetRecoilSpring = patchedGetRecoilSpring

local function cleanup()
	if not running then
		return
	end
	running = false

	if cameraController.ImpulsePitch == patchedImpulsePitch then
		cameraController.ImpulsePitch = originalImpulsePitch
	end
	if cameraController.GetRecoilSpring == patchedGetRecoilSpring then
		cameraController.GetRecoilSpring = originalGetRecoilSpring
	end

	for stats, saved in pairs(savedStats) do
		pcall(function()
			if saved.HasFirstPerson then
				stats.FirstPersonCameraRecoilFactor = saved.FirstPerson
			else
				stats.FirstPersonCameraRecoilFactor = nil
			end
			if saved.HasThirdPerson then
				stats.ThirdPersonCameraRecoilFactor = saved.ThirdPerson
			else
				stats.ThirdPersonCameraRecoilFactor = nil
			end
		end)
	end
	table.clear(savedStats)
	clearRecoilSpring()

	if environment.CarunoNoRecoilCleanup == cleanup then
		environment.CarunoNoRecoilCleanup = nil
	end
end

environment.CarunoNoRecoilCleanup = cleanup
patchGunStats()

task.spawn(function()
	while running do
		patchGunStats()
		task.wait(0.15)
	end
end)
]==]

local function getFeatureEnvironment()
	if type(getgenv) == "function" then
		local success, environment = pcall(getgenv)
		if success and type(environment) == "table" then
			return environment
		end
	end
	return _G
end

local function runFeatureSource(source, chunkName)
	if type(loadstring) ~= "function" then
		return false, "Executor required"
	end

	local chunk, compileError = loadstring(source, chunkName)
	if not chunk then
		return false, compileError
	end

	local success, runtimeError = pcall(chunk)
	if not success then
		return false, runtimeError
	end
	return true
end

local function stopFeature(cleanupName)
	local environment = getFeatureEnvironment()
	local cleanup = environment[cleanupName]
	if type(cleanup) == "function" then
		local success, cleanupError = pcall(cleanup)
		if not success then
			return false, cleanupError
		end
	end
	return true
end

local borderSpeedLimitEnabled = false
local borderSpeedLimitConfig
local borderSpeedLimitOriginalRegion
local borderSpeedLimitPatchedRegion

local function startBorderSpeedLimitRemoval()
	if borderSpeedLimitEnabled then
		return true
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local configModule = ReplicatedStorage
		:WaitForChild("SharedModules")
		:WaitForChild("Configs")
		:WaitForChild("RegionSpeedLimits")

	local required, config = pcall(require, configModule)
	if not required or type(config) ~= "table" or type(config.Regions) ~= "table" then
		return false, required and "RegionSpeedLimits config was not found" or config
	end

	local originalRegion = config.Regions.BorderSpeedLimitRegion
	if type(originalRegion) ~= "table" then
		return false, "BorderSpeedLimitRegion was not found"
	end

	local patchedRegion = {}
	for key, value in pairs(originalRegion) do
		patchedRegion[key] = value
	end

	patchedRegion.MaxMPH = 10000000
	patchedRegion.BrakeTorqueMultiplier = 0
	patchedRegion.NotificationMessageFormat = ""
	patchedRegion.NotificationDuration = 0
	patchedRegion.NotificationMPHOffset = 0

	local changed, changeError = pcall(function()
		config.Regions.BorderSpeedLimitRegion = patchedRegion
	end)
	if not changed then
		return false, changeError
	end

	borderSpeedLimitConfig = config
	borderSpeedLimitOriginalRegion = originalRegion
	borderSpeedLimitPatchedRegion = patchedRegion
	borderSpeedLimitEnabled = true
	return true
end

local function stopBorderSpeedLimitRemoval()
	if borderSpeedLimitConfig
		and type(borderSpeedLimitConfig.Regions) == "table"
		and borderSpeedLimitConfig.Regions.BorderSpeedLimitRegion == borderSpeedLimitPatchedRegion then
		pcall(function()
			borderSpeedLimitConfig.Regions.BorderSpeedLimitRegion =
				borderSpeedLimitOriginalRegion
		end)
	end

	borderSpeedLimitConfig = nil
	borderSpeedLimitOriginalRegion = nil
	borderSpeedLimitPatchedRegion = nil
	borderSpeedLimitEnabled = false
	return true
end

local runtimeFeatures = {
	speedHack = false,
	vehicleSpeed = false,
	infiniteStamina = false,
}

local function getLocalCharacterAndHumanoid()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return character, humanoid
end

local function getDrivenVehicle()
	local _, humanoid = getLocalCharacterAndHumanoid()
	local seat = humanoid and humanoid.SeatPart
	local vehicles = Workspace:FindFirstChild("Vehicles")
	if not seat or not vehicles then
		return nil, nil
	end

	local object = seat
	while object and object.Parent ~= vehicles do
		object = object.Parent
	end
	if not object or object.Parent ~= vehicles or not object:IsA("Model") then
		return nil, nil
	end

	local root = object:FindFirstChild("Root")
	if not root or not root:IsA("BasePart") then
		root = object.PrimaryPart or seat.AssemblyRootPart
	end
	return object, root
end

local function disableSignalConnections(signal, registry, ignoredFunction)
	local resolved = getconnections
	if type(resolved) ~= "function" then
		local ok, value = pcall(function()
			return (getgenv and getgenv().getconnections) or _G.getconnections
		end)
		resolved = ok and value or nil
	end
	if type(resolved) ~= "function" then
		return 0, "getconnections unavailable"
	end

	local success, signalConnections = pcall(resolved, signal)
	if not success or type(signalConnections) ~= "table" then
		return 0, "Cannot inspect event connections"
	end

	local disabledCount = 0
	for _, connection in ipairs(signalConnections) do
		local callback
		pcall(function()
			callback = connection.Function
		end)
		if callback ~= ignoredFunction and not registry[connection] then
			local disabled = pcall(function()
				connection:Disable()
			end)
			if not disabled then
				disabled = pcall(function()
					connection.Enabled = false
				end)
			end
			if disabled then
				registry[connection] = true
				disabledCount = disabledCount + 1
			end
		end
	end
	return disabledCount
end

local function enableSignalConnections(registry)
	for connection in pairs(registry) do
		pcall(function()
			connection:Enable()
		end)
		pcall(function()
			connection.Enabled = true
		end)
		registry[connection] = nil
	end
end

-- ==========================================================================
-- Outgoing remote filter (client -> server)
-- ==========================================================================

local outgoingBlocked = {}
local outgoingHookInstalled = false
local outgoingOldNamecall

local function remoteSignature(instance)
	if typeof(instance) ~= "Instance" then
		return nil
	end
	local parent = instance.Parent
	if not parent then
		return instance.Name
	end
	return ("%s/%s"):format(parent.Name, instance.Name)
end

local function installOutgoingHook()
	if outgoingHookInstalled then
		return true
	end
	if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
		return false, "hookmetamethod/getnamecallmethod unavailable"
	end

	local ok = pcall(function()
		outgoingOldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
			local method = getnamecallmethod()
			if (method == "FireServer" or method == "InvokeServer")
				and typeof(self) == "Instance" then
				local signature = remoteSignature(self)
				if signature and outgoingBlocked[signature] then
					if method == "InvokeServer" then
						return nil
					end
					return
				end
			end
			return outgoingOldNamecall(self, ...)
		end)
	end)
	if not ok then
		return false, "namecall hook failed"
	end
	outgoingHookInstalled = true
	return true
end

local function blockOutgoingRemote(signature, enabled)
	if enabled == false then
		outgoingBlocked[signature] = nil
		return true
	end
	local ok, hookError = installOutgoingHook()
	if not ok then
		return false, hookError
	end
	outgoingBlocked[signature] = true
	return true
end

-- ==========================================================================
-- Anti PIT
-- ==========================================================================

local antiPitEnabled = false
local disabledPitConnections = {}
local antiPitHeartbeat
local antiPitRefreshThread
local pitImpulseHookInstalled = false
local pitOldNamecall

local ANTIPIT_CONFIG = {
	ClearServerAttribute = true,
	BlockImpulse = true,
	AngularDamping = 0.45,
	AngularThreshold = 1.5,
	RefreshInterval = 2,
}

local function getOwnVehicleAndRoot()
	local vehicle, root = getDrivenVehicle()
	if not vehicle then
		return nil, nil
	end
	if not root then
		local candidate = vehicle:FindFirstChild("Root")
		if candidate and candidate:IsA("BasePart") then
			root = candidate
		end
	end
	return vehicle, root
end

local function installPitImpulseHook()
	if pitImpulseHookInstalled then
		return true
	end
	if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
		return false, "hookmetamethod/getnamecallmethod unavailable"
	end

	local ok = pcall(function()
		pitOldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
			local method = getnamecallmethod()
			if antiPitEnabled
				and ANTIPIT_CONFIG.BlockImpulse
				and (method == "ApplyImpulseAtPosition" or method == "ApplyImpulse")
				and typeof(self) == "Instance"
				and self:IsA("BasePart") then
				local _, root = getOwnVehicleAndRoot()
				if self == root then
					return
				end
			end
			return pitOldNamecall(self, ...)
		end)
	end)
	if not ok then
		return false, "pit impulse hook failed"
	end
	pitImpulseHookInstalled = true
	return true
end

local function refreshAntiPitConnections()
	local remotes = ReplicatedStorage:FindFirstChild("__remotes")
	local vehicleService = remotes and remotes:FindFirstChild("VehicleService")
	local remote = vehicleService
		and vehicleService:FindFirstChild("VehiclePitManeuver")
	if not remote or not remote:IsA("RemoteEvent") then
		return 0, "VehiclePitManeuver remote not found"
	end
	return disableSignalConnections(remote.OnClientEvent, disabledPitConnections)
end

local function antiPitStep()
	local vehicle, root = getOwnVehicleAndRoot()
	if not vehicle then
		return
	end

	if ANTIPIT_CONFIG.ClearServerAttribute then
		local endsAt = vehicle:GetAttribute("PitManeuverEndsAt")
		if type(endsAt) == "number" and endsAt ~= 0 then
			pcall(function()
				vehicle:SetAttribute("PitManeuverEndsAt", 0)
			end)
		end
	end

	if root and ANTIPIT_CONFIG.AngularDamping < 1 then
		local angular = root.AssemblyAngularVelocity
		if math.abs(angular.Y) > ANTIPIT_CONFIG.AngularThreshold then
			root.AssemblyAngularVelocity = Vector3.new(
				angular.X,
				angular.Y * ANTIPIT_CONFIG.AngularDamping,
				angular.Z
			)
		end
	end
end

local function startAntiPit()
	antiPitEnabled = true

	installPitImpulseHook()
	local disabledCount, connectionError = refreshAntiPitConnections()

	if antiPitRefreshThread then
		pcall(task.cancel, antiPitRefreshThread)
		antiPitRefreshThread = nil
	end
	antiPitRefreshThread = task.spawn(function()
		while antiPitEnabled do
			task.wait(ANTIPIT_CONFIG.RefreshInterval)
			if not antiPitEnabled then
				break
			end
			refreshAntiPitConnections()
		end
	end)

	if antiPitHeartbeat then
		pcall(function()
			antiPitHeartbeat:Disconnect()
		end)
	end
	antiPitHeartbeat = RunService.Heartbeat:Connect(antiPitStep)

	if disabledCount == 0 and not pitImpulseHookInstalled then
		antiPitEnabled = false
		if antiPitHeartbeat then
			pcall(function()
				antiPitHeartbeat:Disconnect()
			end)
			antiPitHeartbeat = nil
		end
		return false, connectionError or "no PIT hooks could be installed"
	end

	return true
end

local function stopAntiPit()
	antiPitEnabled = false
	if antiPitHeartbeat then
		pcall(function()
			antiPitHeartbeat:Disconnect()
		end)
		antiPitHeartbeat = nil
	end
	if antiPitRefreshThread then
		pcall(task.cancel, antiPitRefreshThread)
		antiPitRefreshThread = nil
	end
	enableSignalConnections(disabledPitConnections)
	return true
end

local AC_CONFIG = {
	SOFT_ROLLBACK       = true,
	IGNORE_LIMIT        = 18,
	ROLLBACK_HARD_LIMIT = 120,
	DEATH_WINDOW        = 12,
	DEATH_LIMIT         = 3,
	ACK_MIN_DELAY       = 0.040,
	ACK_MAX_DELAY       = 0.110,
	AIR_GUARD           = 2.5,
	FALLBACK_PERIOD     = 3.0,
}

AC_CONFIG.startVehicleSpeed = function()
	runtimeFeatures.vehicleSpeed = true
	return true
end

AC_CONFIG.stopVehicleSpeed = function()
	runtimeFeatures.vehicleSpeed = false
	AC_CONFIG.restoreVehicles()
	return true
end

AC_CONFIG.resolveController = function()
	if AC_CONFIG.Controller then
		return AC_CONFIG.Controller
	end
	local ok, controller = pcall(function()
		return require(
			ReplicatedStorage
				:WaitForChild("ClientModules", 5)
				:WaitForChild("MovementController", 5)
		)
	end)
	if ok and type(controller) == "table"
		and type(controller.SetWalkSpeedModifier) == "function"
		and type(controller.GetWalkSpeed) == "function" then
		AC_CONFIG.Controller = controller
		return controller
	end
	return nil
end

AC_CONFIG.resolveGeometry = function()
	if AC_CONFIG.Geometry then
		return AC_CONFIG.Geometry
	end
	local ok, geometry = pcall(function()
		return require(
			ReplicatedStorage
				:WaitForChild("SharedModules", 5)
				:WaitForChild("AntiCheatGeometry", 5)
		)
	end)
	if ok and type(geometry) == "table" then
		AC_CONFIG.Geometry = geometry
	end
	return AC_CONFIG.Geometry
end

AC_CONFIG.updateAirborne = function(vehicle, deltaTime)
	local geometry = AC_CONFIG.resolveGeometry()
	if not vehicle or not geometry
		or type(geometry.IsVehicleGrounded) ~= "function" then
		AC_CONFIG.AirborneSince = nil
		return false
	end
	AC_CONFIG.GroundPoll = (AC_CONFIG.GroundPoll or 0) + deltaTime
	if AC_CONFIG.GroundPoll >= 0.15 then
		AC_CONFIG.GroundPoll = 0
		local ok, grounded = pcall(geometry.IsVehicleGrounded, vehicle)
		if ok and grounded then
			AC_CONFIG.AirborneSince = nil
		elseif ok and not AC_CONFIG.AirborneSince then
			AC_CONFIG.AirborneSince = os.clock()
		end
	end
	local since = AC_CONFIG.AirborneSince
	return since ~= nil and (os.clock() - since) >= AC_CONFIG.AIR_GUARD
end

AC_CONFIG.VehicleAttrs = setmetatable({}, { __mode = "k" })

AC_CONFIG.resolveVehicle = function(humanoid)
	if not humanoid then
		return nil
	end
	local ok, vehicle = pcall(function()
		return VehicleUtil:GetHumanoidDrivenVehicle(humanoid)
	end)
	if ok and vehicle then
		return vehicle
	end
	local seat = humanoid.SeatPart
	if not seat then
		return nil
	end
	local ok2, fallback = pcall(function()
		return VehicleUtil:GetVehicleModelFromPart(seat)
	end)
	if ok2 then
		return fallback
	end
	return nil
end

AC_CONFIG.boostVehicle = function(vehicle)
	if not vehicle then
		return false
	end
	local saved = AC_CONFIG.VehicleAttrs[vehicle]
	if not saved then
		saved = {
			Top = vehicle:GetAttribute("TopSpeedMultiplier"),
			Power = vehicle:GetAttribute("EnginePowerMultiplier"),
		}
		AC_CONFIG.VehicleAttrs[vehicle] = saved
	end
	local top = saved.Top
	if type(top) ~= "number" or top <= 0 then
		top = 1
	end
	local power = saved.Power
	if type(power) ~= "number" or power <= 0 then
		power = 1
	end

	local multiplier = math.clamp(values.vehicleAltSpeed / 100, 1, 6)
	local target = top * multiplier
	local current = vehicle:GetAttribute("TopSpeedMultiplier")
	if type(current) == "number" and math.abs(current - target) < 0.001 then
		return true
	end
	return (pcall(function()
		vehicle:SetAttribute("TopSpeedMultiplier", target)
		vehicle:SetAttribute("EnginePowerMultiplier", power * multiplier)
	end))
end

AC_CONFIG.restoreVehicles = function()
	for vehicle, saved in pairs(AC_CONFIG.VehicleAttrs) do
		if vehicle and vehicle.Parent then
			pcall(function()
				vehicle:SetAttribute("TopSpeedMultiplier", saved.Top)
				vehicle:SetAttribute("EnginePowerMultiplier", saved.Power)
			end)
		end
		AC_CONFIG.VehicleAttrs[vehicle] = nil
	end
end

AC_CONFIG.setSpeedModifier = function(delta)
	local controller = AC_CONFIG.resolveController()
	if not controller then
		return false
	end
	if delta and math.abs((AC_CONFIG.AppliedDelta or 0) - delta) < 0.01 then
		return true
	end
	AC_CONFIG.AppliedDelta = delta
	return (pcall(function()
		controller:SetWalkSpeedModifier("CarunoHub", delta)
	end))
end

local function restoreSpeed()
	AC_CONFIG.setSpeedModifier(nil)
	AC_CONFIG.AppliedDelta = nil
	AC_CONFIG.AirborneSince = nil
	AC_CONFIG.FootAirSince = nil
	AC_CONFIG.restoreVehicles()
	for humanoid, walkSpeed in pairs(speedSaved) do
		if humanoid and humanoid.Parent then
			pcall(function()
				humanoid.WalkSpeed = walkSpeed
			end)
		end
		speedSaved[humanoid] = nil
	end
end

local function startSpeedHack()
	runtimeFeatures.speedHack = true
	return true
end

local function stopSpeedHack()
	runtimeFeatures.speedHack = false
	restoreSpeed()
	return true
end

local movementController
local staminaGetter
local staminaUpvalueIndex
local staminaSetupValue

local function resolveStaminaUpvalue()
	if staminaGetter and staminaUpvalueIndex and staminaSetupValue then
		return true
	end

	local success, controller = pcall(function()
		return require(
			ReplicatedStorage
				:WaitForChild("ClientModules")
				:WaitForChild("MovementController")
		)
	end)
	if not success or type(controller) ~= "table"
		or type(controller.GetStamina) ~= "function" then
		return false
	end

	local debugLibrary = debug
	local getUpvalues = (debugLibrary and debugLibrary.getupvalues)
		or getupvalues
	local setupValue = (debugLibrary and debugLibrary.setupvalue)
		or setupvalue
	if type(getUpvalues) ~= "function" or type(setupValue) ~= "function" then
		return false
	end

	local gotUpvalues, upvalues = pcall(getUpvalues, controller.GetStamina)
	if not gotUpvalues or type(upvalues) ~= "table" then
		return false
	end

	local currentStamina = controller:GetStamina()
	if type(currentStamina) ~= "number" then
		return false
	end
	for index, value in pairs(upvalues) do
		if type(index) == "number"
			and type(value) == "number"
			and math.abs(value - currentStamina) < 0.001 then
			movementController = controller
			staminaGetter = controller.GetStamina
			staminaUpvalueIndex = index
			staminaSetupValue = setupValue
			return true
		end
	end
	return false
end

local function refillStamina()
	if not resolveStaminaUpvalue() then
		return false
	end
	return pcall(
		staminaSetupValue,
		staminaGetter,
		staminaUpvalueIndex,
		200
	)
end

local function startInfiniteStamina()
	if not refillStamina() then
		return false, "Executor required"
	end
	runtimeFeatures.infiniteStamina = true
	return true
end

local function stopInfiniteStamina()
	runtimeFeatures.infiniteStamina = false
	return true
end

connect(UserInputService.InputBegan, function(input)
	if input.KeyCode == Enum.KeyCode.LeftAlt
		or input.KeyCode == Enum.KeyCode.RightAlt then
		if UserInputService:GetFocusedTextBox() then
			return
		end
		altHeld = true
	end
end)

connect(UserInputService.InputEnded, function(input)
	if input.KeyCode == Enum.KeyCode.LeftAlt
		or input.KeyCode == Enum.KeyCode.RightAlt then
		altHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
		if not altHeld then
			restoreSpeed()
		end
	end
end)

local function getInstancePosition(instance)
	if not instance then
		return nil
	end
	if instance:IsA("BasePart") then
		return instance.Position
	end
	if instance:IsA("Model") then
		return instance:GetPivot().Position
	end
	local part = instance:FindFirstChildWhichIsA("BasePart", true)
	return part and part.Position or nil
end

connect(RunService.Heartbeat, function(deltaTime)
	if altHeld and (runtimeFeatures.speedHack or runtimeFeatures.vehicleSpeed) then
		local _, humanoid = getLocalCharacterAndHumanoid()
		if humanoid and not humanoid.SeatPart and runtimeFeatures.speedHack then

			local base = 16
			pcall(function()
				base = game.StarterPlayer.CharacterWalkSpeed
			end)

			if humanoid.FloorMaterial == Enum.Material.Air then
				AC_CONFIG.FootAirSince = AC_CONFIG.FootAirSince or os.clock()
			else
				AC_CONFIG.FootAirSince = nil
			end
			if AC_CONFIG.FootAirSince
				and os.clock() - AC_CONFIG.FootAirSince >= AC_CONFIG.AIR_GUARD then
				AC_CONFIG.setSpeedModifier(nil)
			else
				AC_CONFIG.setSpeedModifier(values.altSpeed - base)
			end
		elseif humanoid and runtimeFeatures.vehicleSpeed then

			local seat = humanoid.SeatPart
			local root = seat and (seat.AssemblyRootPart or seat)

			if root then
				local vehicle = AC_CONFIG.resolveVehicle(humanoid)
				if not vehicle then
					warnVehicleSpeedOnce()
				end

				if AC_CONFIG.updateAirborne(vehicle, deltaTime) then

					local velocity = root.AssemblyLinearVelocity
					root.AssemblyLinearVelocity = Vector3.new(
						velocity.X,
						math.min(velocity.Y, -40),
						velocity.Z
					)
				else
					AC_CONFIG.boostVehicle(vehicle)
				end
			end
		end
	end

	if runtimeFeatures.infiniteStamina then
		refillStamina()
	end
end)

AC_CONFIG.resolveVehicle = function(humanoid)
	if not humanoid then
		return nil
	end

	if VehicleUtil then
		local ok, vehicle = pcall(function()
			return VehicleUtil:GetHumanoidDrivenVehicle(humanoid)
		end)
		if ok and vehicle then
			return vehicle
		end

		local seat = humanoid.SeatPart
		if seat then
			local okPart, fallback = pcall(function()
				return VehicleUtil:GetVehicleModelFromPart(seat)
			end)
			if okPart and fallback then
				return fallback
			end
		end
	end

	local vehicle = getDrivenVehicle()
	return vehicle
end

local function getVehicleStockTopSpeedMph(vehicle)
	local gears = vehicle and vehicle:FindFirstChild("Gears")
	if not gears then
		return nil
	end

	local best = 0
	for _, gear in ipairs(gears:GetChildren()) do
		local maxSpeed = gear:GetAttribute("MaxSpeed")
		if type(maxSpeed) == "number" then
			best = math.max(best, math.abs(maxSpeed))
		end
	end

	if best <= 0 then
		return nil
	end
	return best
end

AC_CONFIG.SAFE_MULTIPLIER = 2

AC_CONFIG.getSafeMultiplier = function()
	local multiplier = math.clamp((values.vehicleAltSpeed or 200) / 100, 1, 6)
	if not values.vehicleAltRisky then
		multiplier = math.min(multiplier, AC_CONFIG.SAFE_MULTIPLIER)
	end
	return multiplier
end

local noGearsWarned = setmetatable({}, { __mode = "k" })

AC_CONFIG.boostVehicle = function(vehicle)
	if not vehicle or not vehicle.Parent then
		return false
	end

	local saved = AC_CONFIG.VehicleAttrs[vehicle]
	if not saved then
		saved = {
			Top = vehicle:GetAttribute("TopSpeedMultiplier"),
			Power = vehicle:GetAttribute("EnginePowerMultiplier"),
			StockMph = getVehicleStockTopSpeedMph(vehicle),
		}
		AC_CONFIG.VehicleAttrs[vehicle] = saved

		if not saved.StockMph and not noGearsWarned[vehicle] then
			noGearsWarned[vehicle] = true
			warn("[CARUNOHUB] " .. vehicle.Name .. ": no Gears folder, boost may do nothing")
		end
	end

	local top = saved.Top
	if type(top) ~= "number" or top <= 0 or top ~= top then
		top = 1
	end
	local power = saved.Power
	if type(power) ~= "number" or power <= 0 or power ~= power then
		power = 1
	end

	local multiplier = AC_CONFIG.getSafeMultiplier()
	local target = top * multiplier

	local current = vehicle:GetAttribute("TopSpeedMultiplier")
	if type(current) == "number" and math.abs(current - target) < 0.001 then
		return true
	end

	return (pcall(function()

		vehicle:SetAttribute("TopSpeedMultiplier", target)
		vehicle:SetAttribute("EnginePowerMultiplier", power * multiplier)
	end))
end

AC_CONFIG.describeBoost = function()
	local _, humanoid = getLocalCharacterAndHumanoid()
	local vehicle = humanoid and AC_CONFIG.resolveVehicle(humanoid)
	local stock = vehicle and getVehicleStockTopSpeedMph(vehicle)
	if not stock then
		return nil
	end
	local multiplier = AC_CONFIG.getSafeMultiplier()
	return string.format(
		"%s: %d mph -> %d mph (x%.2f)",
		vehicle.Name,
		math.floor(stock + 0.5),
		math.floor(stock * multiplier + 0.5),
		multiplier
	)
end

local function fetchLibrary(url)
	if type(game.HttpGet) ~= "function" and type(game.HttpGetAsync) ~= "function" then
		return nil, "Executor required"
	end
	if type(loadstring) ~= "function" then
		return nil, "Executor required"
	end

	local okSource, source = pcall(function()
		return game:HttpGet(url)
	end)
	if not okSource or type(source) ~= "string" or #source < 64 then
		return nil, "Failed to download " .. url
	end

	local chunk, compileError = loadstring(source)
	if not chunk then
		return nil, compileError
	end

	local okRun, library = pcall(chunk)
	if not okRun then
		return nil, library
	end
	return library
end

local Fluent, libraryError = fetchLibrary(
	"https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
)
if not Fluent then
	warn("[CARUNOHUB] Fluent UI failed to load: " .. tostring(libraryError))
	return
end

local api = {}
local Window, Tabs
local localized = {}

local function notify(title, content)
	pcall(function()
		Fluent:Notify({
			Title = "CARUNOHUB",
			Content = title,
			SubContent = content,
			Duration = 8,
		})
	end)
end

Window = Fluent:CreateWindow({
	Title = "CARUNOHUB v27",
	SubTitle = "San Diego Border RP | Right Shift",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightShift,
})

Tabs = {
	Vehicle = Window:AddTab({ Title = translate("Vehicle"), Icon = "car" }),
	Player = Window:AddTab({ Title = translate("Player"), Icon = "user" }),
	Settings = Window:AddTab({ Title = translate("Settings"), Icon = "settings" }),
}

function api.On(name, callback)
	assert(type(name) == "string", "event name must be a string")
	assert(type(callback) == "function", "callback must be a function")

	listeners[name] = listeners[name] or {}
	table.insert(listeners[name], callback)

	return function()
		local eventListeners = listeners[name]
		if not eventListeners then
			return
		end
		local index = table.find(eventListeners, callback)
		if index then
			table.remove(eventListeners, index)
		end
	end
end

function api.Get(name)
	return values[name]
end

function api.Show()
	pcall(function()
		Window:Minimize(false)
	end)
end

function api.Hide()
	pcall(function()
		Window:Minimize(true)
	end)
end

function api.Toggle()
	pcall(function()
		Window:Minimize()
	end)
end

function api.OpenPage(name)
	local order = { Vehicle = 1, Player = 2, Settings = 3 }
	local index = order[name]
	if index then
		pcall(function()
			Window:SelectTab(index)
		end)
	end
end

function api.Destroy()
	pcall(stopFeature, "VehiclePhysRamCleanup")
	pcall(stopFeature, "VehicleCollisionOnlyCleanup")
	pcall(stopFeature, "GateBarrierCollisionCleanup")
	pcall(stopFeature, "CarunoNoRecoilCleanup")
	pcall(stopBorderSpeedLimitRemoval)
	pcall(stopAntiPit)
	pcall(stopSpeedHack)
	pcall(stopInfiniteStamina)

	for _, connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(connections)
	table.clear(listeners)
	table.clear(localized)

	local removed = false
	if type(Fluent.Destroy) == "function" then
		removed = pcall(function()
			Fluent:Destroy()
		end)
	elseif type(Fluent.Unload) == "function" then
		removed = pcall(function()
			Fluent:Unload()
		end)
	end

	if not removed then
		pcall(function()
			local gui = Fluent.GUI or (Window and Window.Root)
			if typeof(gui) == "Instance" then
				gui:Destroy()
			end
		end)
	end

	if _G.CarunoHubUI == api then
		_G.CarunoHubUI = nil
	end
end

_G.CarunoHubUI = api

local buildFailures = {}

local function safeAdd(label, builder)
	local state = { done = false, ok = false, result = nil }

	task.spawn(function()
		local ok, result = pcall(builder)
		state.ok = ok
		state.result = result
		state.done = true
	end)

	local deadline = os.clock() + 3
	while not state.done and os.clock() < deadline do
		task.wait()
	end

	if not state.done then
		table.insert(buildFailures, label .. " (timed out)")
		warn("[CARUNOHUB] " .. label .. ": timed out while building")
		return nil
	end

	if not state.ok then
		table.insert(buildFailures, label .. ": " .. tostring(state.result))
		warn("[CARUNOHUB] " .. label .. ": " .. tostring(state.result))
		return nil
	end

	print("[CARUNOHUB] built: " .. label)
	return state.result
end

local function register(element, key)
	if element and type(key) == "string" then
		table.insert(localized, { element = element, key = key })
	end
	return element
end

local function relabel()
	if #localized == 0 then
		return false
	end
	for _, entry in ipairs(localized) do
		local element = entry.element
		local setter = element and (element.SetTitle or element.SetName)
		if type(setter) ~= "function" then
			return false
		end
		if not (pcall(setter, element, translate(entry.key))) then
			return false
		end
	end
	return true
end

local function addFeature(tab, key, featureName, startCallback, stopCallback)
	return safeAdd(featureName, function()
		local toggle
		local guard = false

		toggle = tab:AddToggle(key, {
			Title = translate(featureName),
			Description = "",
			Default = false,
			Callback = function(state)
				if guard then
					return
				end

				local success, featureError
				if state then
					success, featureError = startCallback()
				else
					success, featureError = stopCallback()
				end

				if success == false then
					notify(
						translate(featureName),
						featureError == "Executor required"
							and translate("Executor required")
							or tostring(featureError or translate("Failed"))
					)
					guard = true
					pcall(function()
						toggle:SetValue(false)
					end)
					guard = false
					emit("feature", { name = featureName, active = false })
					return
				end

				emit("feature", { name = featureName, active = state })
			end,
		})

		return register(toggle, featureName)
	end)
end

task.spawn(function()

	safeAdd("Language", function()
		local languageValues = { "Russian", "English", "Spanish" }
		local languageIndex = table.find(languageValues, currentLanguage) or 2

		return register(
			Tabs.Settings:AddDropdown("Language", {
				Title = translate("Language"),
				Description = "Applied instantly when possible; the choice is remembered",
				Values = languageValues,
				Multi = false,
				Default = languageIndex,
				Callback = function(language)
					if language == currentLanguage then
						return
					end
					currentLanguage = language
					values.language = language
					_G.CarunoHubLanguage = language
					emit("language", language)

					if relabel() then
						notify(translate("Language"), language)
					else
						notify(
							translate("Language"),
							language .. " saved: re-execute the script to relabel the menu"
						)
					end
				end,
			}),
			"Language"
		)
	end)

	safeAdd("Unload", function()
		return register(
			Tabs.Settings:AddButton({
				Title = translate("Unload"),
				Description = translate("Unload interface"),
				Callback = function()
					api.Destroy()
				end,
			}),
			"Unload"
		)
	end)

	safeAdd("Alt info", function()
		return Tabs.Settings:AddParagraph({
			Title = "Alt",
			Content = "Hold Left/Right Alt: on foot it applies Alt Speed, while driving it applies Vehicle Speed on Alt.",
		})
	end)

	addFeature(Tabs.Player, "NoRecoil", "No Recoil", function()
		return runFeatureSource(NO_RECOIL_SOURCE, "@CARUNOHUB/NoRecoil")
	end, function()
		return stopFeature("CarunoNoRecoilCleanup")
	end)

	addFeature(Tabs.Player, "AltSpeed", "Alt Speed", startSpeedHack, stopSpeedHack)

	addFeature(
		Tabs.Player,
		"InfiniteStamina",
		"Infinite Stamina",
		startInfiniteStamina,
		stopInfiniteStamina
	)

	safeAdd("Alt Speed value", function()
		return register(
			Tabs.Player:AddSlider("AltSpeedValue", {
				Title = translate("Alt Speed"),
				Description = "Walk speed while Alt is held (default game speed is 16)",
				Default = values.altSpeed,
				Min = 24,
				Max = 120,
				Rounding = 0,
				Callback = function(value)
					values.altSpeed = value
					emit("altSpeed", value)
				end,
			}),
			"Alt Speed"
		)
	end)

	addFeature(Tabs.Vehicle, "GateBarrier", "Border Gate Anti-Collision", function()
		return runFeatureSource(GATE_SOURCE, "@CARUNOHUB/GateBarrier")
	end, function()
		return stopFeature("GateBarrierCollisionCleanup")
	end)

	addFeature(Tabs.Vehicle, "PhysicsRam", "Physics Ram", function()
		return runFeatureSource(RAM_SOURCE, "@CARUNOHUB/PhysicsRam")
	end, function()
		return stopFeature("VehiclePhysRamCleanup")
	end)

	addFeature(Tabs.Vehicle, "AntiCollision", "Vehicle Anti-Collision", function()
		return runFeatureSource(COLLISION_SOURCE, "@CARUNOHUB/VehicleAntiCollision")
	end, function()
		return stopFeature("VehicleCollisionOnlyCleanup")
	end)

	addFeature(
		Tabs.Vehicle,
		"BorderSpeedLimit",
		"Remove Border Speed Limit",
		startBorderSpeedLimitRemoval,
		stopBorderSpeedLimitRemoval
	)

	addFeature(Tabs.Vehicle, "AntiPit", "Anti PIT", startAntiPit, stopAntiPit)

	addFeature(Tabs.Vehicle, "VehicleSpeedOnAlt", "Vehicle Speed on Alt", function()
		return AC_CONFIG.startVehicleSpeed()
	end, function()
		return AC_CONFIG.stopVehicleSpeed()
	end)

	safeAdd("Vehicle Alt Speed", function()
		return register(
			Tabs.Vehicle:AddSlider("VehicleAltSpeed", {
				Title = translate("Vehicle Alt Speed"),
				Description = "% of stock top speed (100 = off, 200 = AntiTp-safe cap)",
				Default = values.vehicleAltSpeed,
				Min = 100,
				Max = 400,
				Rounding = 0,
				Callback = function(value)
					values.vehicleAltSpeed = value
					emit("vehicleAltSpeed", value)
				end,
			}),
			"Vehicle Alt Speed"
		)
	end)

	safeAdd("Ignore AntiTp safe cap", function()
		return Tabs.Vehicle:AddToggle("VehicleAltRisky", {
			Title = "Ignore AntiTp safe cap",
			Description = "Server budget is maxSpeed * (step + ping) * 2 + 100 studs; above ~2x you get rolled back.",
			Default = false,
			Callback = function(state)
				values.vehicleAltRisky = state
				emit("vehicleAltRisky", state)
			end,
		})
	end)

	safeAdd("Show boost", function()
		return Tabs.Vehicle:AddButton({
			Title = "Show boost for current vehicle",
			Description = "Reads the Gears MaxSpeed attributes of the car you are driving",
			Callback = function()
				local ok, info = pcall(AC_CONFIG.describeBoost)
				notify("Vehicle boost", (ok and info) or "Sit in the driver seat first")
			end,
		})
	end)

	pcall(function()
		Window:SelectTab(1)
	end)

	if #buildFailures > 0 then

		notify("Build report", table.concat(buildFailures, " | "))
	else
		notify("CARUNOHUB v27", "Loaded. Menu: Right Shift, boost: hold Alt")
	end

	if not VehicleUtil then
		notify(
			translate("Vehicle Speed on Alt"),
			"VehicleUtil not found - falling back to Workspace.Vehicles lookup"
		)
	end
end)

return api
