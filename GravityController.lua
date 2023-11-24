--[[
	GravityController made by:

	███████╗██╗░░██╗██████╗░██╗░░░░░██╗░░░██╗
	██╔════╝╚██╗██╔╝██╔══██╗██║░░░░░╚██╗░██╔╝
	█████╗░░░╚███╔╝░██████╔╝██║░░░░░░╚████╔╝░
	██╔══╝░░░██╔██╗░██╔═══╝░██║░░░░░░░╚██╔╝░░
	███████╗██╔╝╚██╗██║░░░░░███████╗░░░██║░░░
	╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚══════╝░░░╚═╝░░░   
	
	@Loiciboy123
	
	-+-+-+- USAGE -+-+-+-
	
	GravityController
	
	=================================
	
	@Initialize GravityController:
	local GravityControllers = require(script.Parent.Parent.GravityController)
	
	=================================
	
	@Create new world
	local world = GravityControllers.newWorld()
	
	=================================
	
	@Create new object in world
	
	PhysicsEngine.newObject(world, {
	elementType = "TextLabel",
	text = "Im anchored",
	position = UDim2.new(0.5, 0, 0, 0),
	size = Vector2.new(150, 75),
	velocity = Vector2.new(0, 0),
	anchored = true,
	parent = WorldParentUi,
	})

	=================================

	Made in 2 hours don't judge its just the basic logic of collisions and falling
	
]]

local GravityController = {}

GravityController.Settings = {
	Gravity = Vector2.new(0, 20),
	TerminalVelocity = 500,
	FrameTime = 1 / 60,
	BounceFactor = 0.8,
	DampingFactor = 0.98,
	RotationGravity = 0.02,
}

function GravityController.newWorld()
	return {
		objects = {},
	}
end

function GravityController.ScreenDimensions()
	local camera = game:GetService("Workspace").CurrentCamera
	return camera.ViewportSize.X, camera.ViewportSize.Y
end

function GravityController.isInVerticalBounds(obj, minY, maxY)
	return obj.element.Position.Y.Offset >= minY and obj.element.Position.Y.Offset <= maxY
end

function GravityController.isInHorizontalBounds(obj, minX, maxX)
	return obj.element.Position.X.Offset >= minX and obj.element.Position.X.Offset <= maxX
end

function GravityController.applyGravity(obj)
	obj.velocity = obj.velocity + GravityController.Settings.Gravity * GravityController.Settings.FrameTime
end

function GravityController.applyRotationGravity(obj)
	obj.angularVelocity = obj.angularVelocity + GravityController.Settings.RotationGravity * GravityController.Settings.FrameTime
end

function GravityController.calculateBottom(obj)
	return -GravityController.ScreenDimensions() + obj.size.Y
end

function GravityController.updateRotation(obj)
	obj.element.Rotation = obj.element.Rotation + obj.angularVelocity * GravityController.Settings.FrameTime
end

function GravityController.updatePosition(obj)
	obj.element.Position = UDim2.new(
		obj.element.Position.X.Scale,
		obj.element.Position.X.Offset + obj.velocity.X * GravityController.Settings.FrameTime,
		obj.element.Position.Y.Scale,
		obj.element.Position.Y.Offset + obj.velocity.Y * GravityController.Settings.FrameTime
	)
end

function GravityController.clampVerticalPosition(obj, minY, maxY)
	obj.element.Position = UDim2.new(
		obj.element.Position.X.Scale,
		obj.element.Position.X.Offset,
		obj.element.Position.Y.Scale,
		math.clamp(obj.element.Position.Y.Offset, minY, maxY)
	)
end

function GravityController.bounceOffWalls(obj, minX, maxX)
	if obj.element.Position.X.Offset <= minX or obj.element.Position.X.Offset >= maxX then
		obj.velocity = Vector2.new(-obj.velocity.X * GravityController.Settings.BounceFactor, obj.velocity.Y)
	end
end

function GravityController.applyBounce(obj, normal)
	local dampingFactor = GravityController.Settings.DampingFactor
	local bounceFactor = GravityController.Settings.BounceFactor

	obj.velocity = obj.velocity * dampingFactor
	obj.angularVelocity = 0

	obj.element.Position = UDim2.new(
		obj.element.Position.X.Scale,
		obj.element.Position.X.Offset,
		obj.element.Position.Y.Scale,
		obj.element.Position.Y.Offset - 1
	)

	if math.abs(obj.velocity.Y) < 5 then
		obj.velocity = Vector2.new(obj.velocity.X, 0)
	end
end

function GravityController.newObject(world, config)
	local obj = {
		element = Instance.new(config.elementType or "TextLabel"),
		velocity = config.velocity or Vector2.new(),
		angularVelocity = config.angularVelocity or 0,
		size = config.size or Vector2.new(100, 50),
		anchored = config.anchored or false
	}

	obj.element.Size = UDim2.new(0, obj.size.X, 0, obj.size.Y)
	obj.element.Position = config.position or UDim2.new(math.random(), 0, 0, -obj.size.Y)
	obj.element.Parent = config.parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Customize properties based on the element type
	if config.elementType == "TextLabel" then
		obj.element.Text = config.text or "TextLabel"
	elseif config.elementType == "ImageLabel" then
		obj.element.Image = config.image or ""
	end

	table.insert(world.objects, obj)

	return obj
end

function GravityController.updateWorld(world)
	for _, obj in ipairs(world.objects) do
		task.spawn(function()
			
			if obj.anchored then
				return
			end
			
			GravityController.applyGravity(obj)
			GravityController.applyRotationGravity(obj)
			GravityController.updatePosition(obj)

			local screenWidth, screenHeight = GravityController.ScreenDimensions()
			local minY, maxY = 0, screenHeight - obj.size.Y
			local minX, maxX = 0, screenWidth - obj.size.X

			GravityController.clampVerticalPosition(obj, minY, maxY)
			GravityController.bounceOffWalls(obj, minX, maxX)
			
			-- turned off WIP
			--GravityController.updateRotation(obj)

		end)
	end
end

return GravityController
