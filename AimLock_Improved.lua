--// AIM LOCK SYSTEM
--// Compatible with Weapon First-Person + Normal Third-Person

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local LOCK_ON_RANGE = 150
local FOV_RADIUS = 150
local SMOOTHNESS = 0.35
local THIRD_PERSON_OFFSET = Vector3.new(0, 1.5, 7)

local REQUIRE_LINE_OF_SIGHT = true
local IGNORE_TEAMMATES = true

local isLockOnActive = false
local currentTarget = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimLockGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local lockButton = Instance.new("TextButton")
lockButton.Name = "LockToggle"
lockButton.Size = UDim2.new(0, 120, 0, 40)
lockButton.Position = UDim2.new(1, -130, 1, -60)
lockButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
lockButton.TextColor3 = Color3.new(1, 1, 1)
lockButton.Font = Enum.Font.SourceSansBold
lockButton.Text = "Aim Lock: OFF"
lockButton.TextSize = 18
lockButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = lockButton

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function getCharacter()
	return LocalPlayer.Character
end

local function getHumanoid(character)
	if not character then return nil end
	return character:FindFirstChildOfClass("Humanoid")
end

local function getRoot(character)
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

local function getHead(character)
	if not character then return nil end
	return character:FindFirstChild("Head")
end

local function isFirstPerson()
	local character = getCharacter()
	local head = getHead(character)

	if not head then return false end

	return (Camera.CFrame.Position - head.Position).Magnitude < 1.5
end

local function getScreenDistance(part)
	if not part then return math.huge end

	local screenPosition, visible =
		Camera:WorldToViewportPoint(part.Position)

	if not visible or screenPosition.Z <= 0 then
		return math.huge
	end

	local center = Vector2.new(
		Camera.ViewportSize.X / 2,
		Camera.ViewportSize.Y / 2
	)

	local targetPosition = Vector2.new(
		screenPosition.X,
		screenPosition.Y
	)

	return (targetPosition - center).Magnitude
end

local function isInsideFOV(part)
	return getScreenDistance(part) <= FOV_RADIUS
end

local function isValidTeam(player)
	if not IGNORE_TEAMMATES then
		return true
	end

	if not LocalPlayer.Team or not player.Team then
		return true
	end

	return LocalPlayer.Team ~= player.Team
end

local function isVisible(targetCharacter)
	if not REQUIRE_LINE_OF_SIGHT then
		return true
	end

	local character = getCharacter()
	local targetHead = getHead(targetCharacter)

	if not character or not targetHead then
		return false
	end

	raycastParams.FilterDescendantsInstances = {
		character,
		targetCharacter
	}

	local origin = Camera.CFrame.Position
	local direction = targetHead.Position - origin

	local result = workspace:Raycast(
		origin,
		direction,
		raycastParams
	)

	return result == nil
end

local function isValidTarget(player)
	if not player or player == LocalPlayer then
		return false
	end

	if not isValidTeam(player) then
		return false
	end

	local character = player.Character
	if not character then return false end

	local humanoid = getHumanoid(character)
	local head = getHead(character)

	if not humanoid or not head then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	local localCharacter = getCharacter()
	local localHead = getHead(localCharacter)

	if not localHead then
		return false
	end

	local distance =
		(head.Position - localHead.Position).Magnitude

	if distance > LOCK_ON_RANGE then
		return false
	end

	if not isInsideFOV(head) then
		return false
	end

	if not isVisible(character) then
		return false
	end

	return true
end

local function getTargetScore(player)
	local character = player.Character
	if not character then return math.huge end

	local head = getHead(character)
	local localCharacter = getCharacter()
	local localHead = getHead(localCharacter)

	if not head or not localHead then
		return math.huge
	end

	local screenDistance = getScreenDistance(head)

	if screenDistance == math.huge then
		return math.huge
	end

	local worldDistance =
		(head.Position - localHead.Position).Magnitude

	return screenDistance + (worldDistance * 0.05)
end

local function getClosestTarget()
	local bestTarget = nil
	local bestScore = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if isValidTarget(player) then
			local score = getTargetScore(player)

			if score < bestScore then
				bestScore = score
				bestTarget = player.Character
			end
		end
	end

	return bestTarget
end

local function rotateCharacter(character, targetPosition, smooth)
	local root = getRoot(character)
	if not root then return end

	local flatTarget = Vector3.new(
		targetPosition.X,
		root.Position.Y,
		targetPosition.Z
	)

	if (flatTarget - root.Position).Magnitude < 0.01 then
		return
	end

	local targetCFrame =
		CFrame.lookAt(root.Position, flatTarget)

	if smooth then
		root.CFrame = root.CFrame:Lerp(
			targetCFrame,
			SMOOTHNESS
		)
	else
		root.CFrame = targetCFrame
	end
end

local function disableLockOn()
	isLockOnActive = false
	currentTarget = nil

	lockButton.Text = "Aim Lock: OFF"
	lockButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

	local character = getCharacter()
	local humanoid = getHumanoid(character)

	if humanoid then
		humanoid.AutoRotate = true
	end

	Camera.CameraType = Enum.CameraType.Custom
	UserInputService.MouseBehavior =
		Enum.MouseBehavior.Default
end

local function enableLockOn()
	local target = getClosestTarget()

	if not target then
		return
	end

	isLockOnActive = true
	currentTarget = target

	lockButton.Text = "Aim Lock: ON"
	lockButton.BackgroundColor3 =
		Color3.fromRGB(30, 144, 255)
end

lockButton.MouseButton1Click:Connect(function()
	if isLockOnActive then
		disableLockOn()
	else
		enableLockOn()
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	currentTarget = nil

	if isLockOnActive then
		disableLockOn()
	end
end)

RunService:BindToRenderStep(
	"AimLockExecution",
	Enum.RenderPriority.Last.Value,
	function()
		if not isLockOnActive then
			return
		end

		local character = getCharacter()

		if not character then
			disableLockOn()
			return
		end

		local humanoid = getHumanoid(character)
		local root = getRoot(character)
		local head = getHead(character)

		if not humanoid or not root or not head then
			disableLockOn()
			return
		end

		if humanoid.Health <= 0 then
			disableLockOn()
			return
		end

		local targetPlayer = currentTarget
			and Players:GetPlayerFromCharacter(currentTarget)

		if not targetPlayer or not isValidTarget(targetPlayer) then
			currentTarget = getClosestTarget()

			if not currentTarget then
				disableLockOn()
				return
			end

			targetPlayer =
				Players:GetPlayerFromCharacter(currentTarget)

			if not targetPlayer then
				disableLockOn()
				return
			end
		end

		local targetHead = getHead(currentTarget)

		if not targetHead then
			disableLockOn()
			return
		end

		local targetPosition = targetHead.Position

		if isFirstPerson() then
			humanoid.AutoRotate = false

			-- The weapon system keeps control of the first-person
			-- camera. We preserve its current position and only
			-- adjust its orientation toward the target.
			UserInputService.MouseBehavior =
				Enum.MouseBehavior.LockCenter

			local currentCameraCFrame = Camera.CFrame
			local cameraPosition =
				currentCameraCFrame.Position

			local desiredCameraCFrame =
				CFrame.lookAt(
					cameraPosition,
					targetPosition,
					currentCameraCFrame.UpVector
				)

			Camera.CFrame = desiredCameraCFrame

			rotateCharacter(
				character,
				targetPosition,
				false
			)
		else
			humanoid.AutoRotate = false

			Camera.CameraType =
				Enum.CameraType.Scriptable

			rotateCharacter(
				character,
				targetPosition,
				true
			)

			local baseCFrame =
				CFrame.lookAt(
					head.Position,
					targetPosition
				)

			local newCameraPosition =
				(
					baseCFrame
					* CFrame.new(THIRD_PERSON_OFFSET)
				).Position

			local targetCameraCFrame =
				CFrame.lookAt(
					newCameraPosition,
					targetPosition
				)

			Camera.CFrame =
				Camera.CFrame:Lerp(
					targetCameraCFrame,
					SMOOTHNESS
				)
		end
	end
)

disableLockOn()
