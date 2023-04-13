require "logger"
LogManager = Logger(4)
local ObjFile = "./objects/teapot.obj"

-- Basic structures
local Vector2D = require "vector2d"
local Vector3D = require "vector3d"
local Matrix4f = require "matrix4f"
local Triangle = require "triangle"
local Mesh     = require "mesh"
local Camera   = require "camera"

-- Rendering data
local WinWidth
local WinHeight
local HalfWinWidth
local HalfWinHeight
local camera

-- Scene data
local Objects
local PointLight

-- Player data
local vertSpeed
local horizSpeed
local lockMouse
local mouseSense = 0.3

local function triangleSort(a, b)
	local z1 = (a.Points[1].Z + a.Points[2].Z + a.Points[3].Z) / 3
	local z2 = (b.Points[1].Z + b.Points[2].Z + b.Points[3].Z) / 3
	return z1 > z2
end

function love.load()
	WinWidth = love.graphics.getWidth()
	WinHeight = love.graphics.getHeight()
	HalfWinWidth = WinWidth * 0.5
	HalfWinHeight = WinHeight * 0.5

	camera = Camera.new(Vector3D.new(), Vector3D.new(), 90, WinHeight / WinWidth, 0.1, 1000)
	
	Objects = {}
	table.insert(Objects, Mesh.LoadFromFile(ObjFile))
	PointLight = Vector3D.new(50, 0, 0)

	vertSpeed = 8
	horizSpeed = 8
	lockMouse = true
	love.mouse.setGrabbed(true)
	love.mouse.setVisible(false)
end

function love.update(dt)
	local vLookDir = Camera.GetLookDirection(camera)
	local vForward = Vector3D.Mul(vLookDir, horizSpeed * dt)
	local vRight = Vector3D.Mul(Vector3D.Normalize(Vector3D.Cross(vLookDir, Vector3D.up)), horizSpeed * dt)

	if love.keyboard.isDown("space") then
		Camera.Move(camera, Vector3D.Mul(Vector3D.up, vertSpeed * dt))
	elseif love.keyboard.isDown("lshift") then
		Camera.Move(camera, Vector3D.Mul(Vector3D.up, -vertSpeed * dt))
	end

	if love.keyboard.isDown("a") then
		Camera.Move(camera, Vector3D.Mul(vRight, -1))
	elseif love.keyboard.isDown("d") then
		Camera.Move(camera, vRight)
	end

	if love.keyboard.isDown("w") then
		Camera.Move(camera, vForward)
	elseif love.keyboard.isDown("s") then
		Camera.Move(camera, Vector3D.Mul(vForward, -1))
	end

	if love.keyboard.isDown("left") then
		Camera.Rotate(camera, Vector3D.new(0, -2 * dt, 0))
	elseif love.keyboard.isDown("right") then
		Camera.Rotate(camera, Vector3D.new(0, 2 * dt, 0))
	end

	local mx, my = love.mouse.getPosition()
	local diffX, diffY = 0, 0
	local flag = false

	if mx ~= HalfWinWidth then
		flag = true
		diffX = mx - HalfWinWidth
	end

	if my ~= HalfWinHeight then
		flag = true
		diffY = my - HalfWinHeight
	end

	if flag then
		love.mouse.setPosition(HalfWinWidth, HalfWinHeight)
		Camera.Rotate(camera, Vector3D.new(-diffY * mouseSense * dt, -diffX * mouseSense * dt, 0))
	end

	--[[
	if love.keyboard.isDown("up") then
		
	elseif love.keyboard.isDown("down") then
	
	end
	--]]
end

function love.draw()
	--[[local matRotZ, matRotX
	--fTheta = fTheta + 0.1
	matRotZ = Matrix4f.MakeRotationZ(fTheta * 0.5)
	matRotX = Matrix4f.MakeRotationX(fTheta)
	--]]
	
	local matTrans = Matrix4f.MakeTranslation(0, 0, 5)
	
	local matWorld = Matrix4f.MakeIdentity()
	--matWorld = Matrix4f.Mul(matRotZ, matRotX)   -- Rotate
	matWorld = Matrix4f.Mul(matWorld, matTrans) -- Translate

	-- Store triangles for rasterizing later
	local trianglesToRasterize = {}

	-- Draw triangles
	for meshIdx, mesh in ipairs(Objects) do
		for triIdx, tri in ipairs(mesh.Triangles) do
			local triProjected, triTransformed, triViewed
			
			-- World matrix transform
			triTransformed = Triangle.new({
				Matrix4f.MulVector3D(matWorld, tri.Points[1]),
				Matrix4f.MulVector3D(matWorld, tri.Points[2]),
				Matrix4f.MulVector3D(matWorld, tri.Points[3])
			})
			
			-- Get triangle normal
			local normal = Triangle.Normal(triTransformed)
			
			-- Get ray from triangle to camera
			local vCameraRay = Vector3D.Sub(triTransformed.Points[1], camera.Position)
			
			-- If ray is aligned with normal, then triangle is visible
			if Vector3D.Dot(normal, vCameraRay) < 0 then
				-- Illumination
				local light_direction = Vector3D.new(0, 1, -1)
				light_direction = Vector3D.Normalize(light_direction)
				
				-- How "aligned" are light direction and triangle surface normal?
				local dp = math.max(0.1, Vector3D.Dot(light_direction, normal))
				
				--[[
				-- Get ray from point light to triangle
				local vLightRay = Vector3D.Sub(PointLight, triTransformed.Points[1])
				vLightRay = Vector3D.Normalize(vLightRay)
				
				-- How "aligned" are the light ray and triangle surface normal?
				local dp = math.max(0.1, Vector3D.Dot(vLightRay, normal))
				--]]
				
				-- Set color
				triTransformed.Color = { R = dp, G = dp, B = dp * 0.91 }
				
				-- Convert world space to view space
				local matView = Camera.GetViewMatrix(camera)
				triViewed = Triangle.new({
					Matrix4f.MulVector3D(matView, triTransformed.Points[1]),
					Matrix4f.MulVector3D(matView, triTransformed.Points[2]),
					Matrix4f.MulVector3D(matView, triTransformed.Points[3])
				})
				
				triViewed.Color = triTransformed.Color
				
				-- Clip viewed triangle against near plane, this could form two
				-- additional triangles
				local nClippedTriangles = 0
				local clipped = {}
				nClippedTriangles, clipped[1], clipped[2] = Triangle.ClipAgainstPlane(Vector3D.new(0, 0, 0.1), Vector3D.forward, triViewed)
				
				-- We may end up with multiple triangles from the clip, so project as
				-- required
				local matProj = Camera.GetProjectionMatrix(camera)
				for n = 1, nClippedTriangles do
					-- Project triangles from 3D to 2D
					triProjected = Triangle.new({
						Matrix4f.MulVector3D(matProj, clipped[n].Points[1]),
						Matrix4f.MulVector3D(matProj, clipped[n].Points[2]),
						Matrix4f.MulVector3D(matProj, clipped[n].Points[3])
					})
					
					triProjected.Color = clipped[n].Color
					
					-- Scale into view
					triProjected.Points[1] = Vector3D.Div(triProjected.Points[1], triProjected.Points[1].W)
					triProjected.Points[2] = Vector3D.Div(triProjected.Points[2], triProjected.Points[2].W)
					triProjected.Points[3] = Vector3D.Div(triProjected.Points[3], triProjected.Points[3].W)
					
					-- Offset verts into visible normalized space
					local vOffsetView = Vector3D.new(1, 1, 0)
					triProjected.Points[1] = Vector3D.Add(triProjected.Points[1], vOffsetView)
					triProjected.Points[2] = Vector3D.Add(triProjected.Points[2], vOffsetView)
					triProjected.Points[3] = Vector3D.Add(triProjected.Points[3], vOffsetView)
					triProjected.Points[1].X = triProjected.Points[1].X * HalfWinWidth
					triProjected.Points[1].Y = triProjected.Points[1].Y * HalfWinHeight
					triProjected.Points[2].X = triProjected.Points[2].X * HalfWinWidth
					triProjected.Points[2].Y = triProjected.Points[2].Y * HalfWinHeight
					triProjected.Points[3].X = triProjected.Points[3].X * HalfWinWidth
					triProjected.Points[3].Y = triProjected.Points[3].Y * HalfWinHeight
					
					-- Store triangle for sorting
					table.insert(trianglesToRasterize, triProjected)
				end
			end
		end
		
		-- Sort triangles from back to front
		table.sort(trianglesToRasterize, triangleSort)
		
		-- Loop through all transformed, viewed, projected, and sorted triangles
		for _, triToRasterize in next, trianglesToRasterize do
			-- Clip triangles against all four screen edges, this could yield
			-- a bunch of triangles, so create a queue that we traverse to
			-- ensure we only test new triangles generated against planes
			local clipped = {}
			local listTriangles = {}
			
			-- Add initial triangle
			table.insert(listTriangles, triToRasterize)
			local nNewTriangles = 1
			
			for p = 1, 4 do
				local nTrisToAdd = 0
				
				while nNewTriangles > 0 do
					-- Take triangle from front of queue
					local test = listTriangles[#listTriangles]
					listTriangles[#listTriangles] = nil
					nNewTriangles = nNewTriangles - 1
					
					-- Clip it against a plane. We only need to test each
					-- subsequent plane against subsequent new triangles
					-- as all triangles after a plane clip are guaranteed
					-- to lie on the inside of the plane
						if p == 1 then nTrisToAdd, clipped[1], clipped[2] = Triangle.ClipAgainstPlane(Vector3D.new(),					 Vector3D.new(0, 1, 0),  test)
					elseif p == 2 then nTrisToAdd, clipped[1], clipped[2] = Triangle.ClipAgainstPlane(Vector3D.new(0, WinHeight - 1, 0), Vector3D.new(0, -1, 0), test)
					elseif p == 3 then nTrisToAdd, clipped[1], clipped[2] = Triangle.ClipAgainstPlane(Vector3D.new(),					 Vector3D.new(1, 0, 0),  test)
					elseif p == 4 then nTrisToAdd, clipped[1], clipped[2] = Triangle.ClipAgainstPlane(Vector3D.new(WinWidth - 1, 0, 0),	 Vector3D.new(-1, 0, 0), test)
					end
					
					-- Clipping may yield a variable number of triangles, so
					-- add these new ones to the back of the queue for subsequent
					-- clipping against next planes
					for w = 1, nTrisToAdd do
						table.insert(listTriangles, clipped[w])
					end
				end
				
				nNewTriangles = #listTriangles
			end
			
			-- Draw the transformed, viewed, clipped, projected, sorted, clipped triangles
			for _, t in next, listTriangles do
				local pts = t.Points
				love.graphics.setColor(t.Color.R, t.Color.G, t.Color.B, 1)
				love.graphics.polygon("fill", pts[1].X, pts[1].Y,
												pts[2].X, pts[2].Y,
												pts[3].X, pts[3].Y)
			end
		end
	end
	--]]
	LogManager:draw()
end

function love.quit()

end