-- Speed up math
local sin = math.sin
local cos = math.cos
local tan = math.tan
local rad = math.rad

local Vector3D = require "vector3d"

local Matrix4f = {
	new = function()
		return {
			{ 0, 0, 0, 0 },
			{ 0, 0, 0, 0 },
			{ 0, 0, 0, 0 },
			{ 0, 0, 0, 0 }
		}
	end
}

Matrix4f.MakeIdentity = function()
	local matrix = Matrix4f.new()
	
	for i = 1, 4 do
		matrix[i][i] = 1
	end
	
	return matrix
end

Matrix4f.MakeRotationX = function(fAngleRad)
	local matrix = Matrix4f.new()
	matrix[1][1] = 1
	matrix[2][2] = cos(fAngleRad)
	matrix[2][3] = -sin(fAngleRad)
	matrix[3][2] = sin(fAngleRad)
	matrix[3][3] = cos(fAngleRad)
	matrix[4][4] = 1
	return matrix
	
	--[[
	1,  0,  0,  0
	0,  c, -s,  0
	0,  s,  c,  0
	0,  0,  0,  1
	--]]
end

Matrix4f.MakeRotationY = function(fAngleRad)
	local matrix = Matrix4f.new()
	matrix[1][1] = cos(fAngleRad)
	matrix[1][3] = sin(fAngleRad)
	matrix[3][1] = -sin(fAngleRad)
	matrix[2][2] = 1
	matrix[3][3] = cos(fAngleRad)
	matrix[4][4] = 1
	return matrix
	
	--[[
	 c, 0, s, 0
	 0, 1, 0, 0
	-s, 0, c, 0
	 0, 0, 0, 1
	--]]
end

Matrix4f.MakeRotationZ = function(fAngleRad)
	local matrix = Matrix4f.new()
	matrix[1][1] = cos(fAngleRad)
	matrix[1][2] = -sin(fAngleRad)
	matrix[2][1] = sin(fAngleRad)
	matrix[2][2] = cos(fAngleRad)
	matrix[3][3] = 1
	matrix[4][4] = 1
	return matrix
	
	--[[
	 c, -s, 0, 0
	 s,  c, 0, 0
	 0,  0, 1, 0
	 0,  0, 0, 1
	--]]
end

Matrix4f.MakeTranslation = function(x, y, z)
	local matrix = Matrix4f.new()
	matrix[1][1] = 1
	matrix[2][2] = 1
	matrix[3][3] = 1
	matrix[4][4] = 1
	matrix[4][1] = x
	matrix[4][2] = y
	matrix[4][3] = z
	return matrix
	
	--[[
	1, 0, 0, 0
	0, 1, 0, 0
	0, 0, 1, 0
	x, y, z, 1
	--]]
end

Matrix4f.MakeProjection = function(fFovDegrees, fAspectRatio, fNear, fFar)
	local fFovRad = rad(fFovDegrees)
	local f = 1 / tan(fFovRad / 2)
	local q = fFar / (fFar - fNear)
	local matrix = Matrix4f.new()
	matrix[1][1] = fAspectRatio * f
	matrix[2][2] = f
	matrix[3][3] = q
	matrix[4][3] = fNear * q
	matrix[3][4] = -1
	
	--[[
		af, 0, 0,       0
		0,  f, 0,       0
		0,  0, q,       1
		0,  0, znear*q, 0
	]]

	return matrix
end

Matrix4f.Mul = function(mat1, mat2)
	local matrix = Matrix4f.new()
	
	for c = 1, 4 do
		for r = 1, 4 do
			matrix[r][c] = mat1[r][1] * mat2[1][c] +
							mat1[r][2] * mat2[2][c] +
							mat1[r][3] * mat2[3][c] +
							mat1[r][4] * mat2[4][c]
		end
	end
	
	return matrix
end

Matrix4f.MulVector3D = function(m, i)
	local v = Vector3D.new()
	v.X = i.X * m[1][1] + i.Y * m[2][1] + i.Z * m[3][1] + i.W * m[4][1]
	v.Y = i.X * m[1][2] + i.Y * m[2][2] + i.Z * m[3][2] + i.W * m[4][2]
	v.Z = i.X * m[1][3] + i.Y * m[2][3] + i.Z * m[3][3] + i.W * m[4][3]
	v.W = i.X * m[1][4] + i.Y * m[2][4] + i.Z * m[3][4] + i.W * m[4][4]
	return v
end

Matrix4f.PointAt = function(pos, target, arbitraryUp)
	if not arbitraryUp then arbitraryUp = Vector3D.up end
	
	-- Calculate new forward, right, and up directions
	local forward = Vector3D.Normalize(Vector3D.Sub(target, pos))
	local right = Vector3D.Cross(arbitraryUp, forward)
	
	-- Calculate new up direction
	local a = Vector3D.Mul(forward, Vector3D.Dot(arbitraryUp, forward))
	local up = Vector3D.Normalize(Vector3D.Sub(arbitraryUp, a))
	
	-- Construct dimensioning and translation matrix
	local matrix = Matrix4f.new()
	matrix[1][1] = right.X		matrix[1][2] = right.Y 		matrix[1][3] = right.Z 		matrix[1][4] = 0
	matrix[2][1] = up.X			matrix[2][2] = up.Y			matrix[2][3] = up.Z			matrix[2][4] = 0
	matrix[3][1] = forward.X	matrix[3][2] = forward.Y 	matrix[3][3] = forward.Z	matrix[3][4] = 0
	matrix[4][1] = pos.X		matrix[4][2] = pos.Y		matrix[4][3] = pos.Z		matrix[4][4] = 1
	return matrix
end

-- Only for rotation/translation matrices
Matrix4f.QuickInverse = function(m)
	local matrix = Matrix4f.new()
	matrix[1][1] = m[1][1]	matrix[1][2] = m[2][1]	matrix[1][3] = m[3][1]	matrix[1][4] = 0
	matrix[2][1] = m[1][2]	matrix[2][2] = m[2][2]	matrix[2][3] = m[3][2]	matrix[2][4] = 0
	matrix[3][1] = m[1][3]	matrix[3][2] = m[2][3]	matrix[3][3] = m[3][3]	matrix[3][4] = 0
	
	matrix[4][1] = -(m[4][1] * matrix[1][1] + m[4][2] * matrix[2][1] + m[4][3] * matrix[3][1])
	matrix[4][2] = -(m[4][1] * matrix[1][2] + m[4][2] * matrix[2][2] + m[4][3] * matrix[3][2])
	matrix[4][3] = -(m[4][1] * matrix[1][3] + m[4][2] * matrix[2][3] + m[4][3] * matrix[3][3])
	matrix[4][4] = 1
	return matrix
end

return Matrix4f