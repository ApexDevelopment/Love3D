local Vector3D = {
	new = function(X, Y, Z, W)
		if not X then X = 0 end
		if not Y then Y = 0 end
		if not Z then Z = 0 end
		if not W then W = 1 end
		
		return { X = X, Y = Y, Z = Z, W = W }
	end
}

Vector3D.zero = Vector3D.new()
Vector3D.up = Vector3D.new(0, 1, 0)
Vector3D.forward = Vector3D.new(0, 0, 1)
Vector3D.right = Vector3D.new(1, 0, 0)
Vector3D.down = Vector3D.new(0, -1, 0)
Vector3D.backward = Vector3D.new(0, 0, -1)
Vector3D.left = Vector3D.new(-1, 0, 0)

Vector3D.Add = function(vec1, vec2)
	return Vector3D.new(vec1.X + vec2.X, vec1.Y + vec2.Y, vec1.Z + vec2.Z)
end

Vector3D.Sub = function(vec1, vec2)
	return Vector3D.new(vec1.X - vec2.X, vec1.Y - vec2.Y, vec1.Z - vec2.Z)
end

Vector3D.Mul = function(vec1, f)
	return Vector3D.new(vec1.X * f, vec1.Y * f, vec1.Z * f)
end

Vector3D.Div = function(vec1, f)
	return Vector3D.new(vec1.X / f, vec1.Y / f, vec1.Z / f)
end

Vector3D.Dot = function(vec1, vec2)
	return vec1.X * vec2.X + vec1.Y * vec2.Y + vec1.Z * vec2.Z
end

Vector3D.Cross = function(vec1, vec2)
	return Vector3D.new(vec1.Y * vec2.Z - vec1.Z * vec2.Y,
						vec1.Z * vec2.X - vec1.X * vec2.Z,
						vec1.X * vec2.Y - vec1.Y * vec2.X)
end

Vector3D.Length = function(vec1)
	return math.sqrt(Vector3D.Dot(vec1, vec1))
end

Vector3D.Normalize = function(vec1)
	local l = Vector3D.Length(vec1)
	return Vector3D.Div(vec1, l)
end

Vector3D.IntersectPlane = function(planeP, planeN, lineStart, lineEnd)
	planeN = Vector3D.Normalize(planeN)
	local planeD = -Vector3D.Dot(planeN, planeP)
	local ad = Vector3D.Dot(lineStart, planeN)
	local bd = Vector3D.Dot(lineEnd, planeN)
	local t = (-planeD - ad) / (bd - ad)
	local lineStartToEnd = Vector3D.Sub(lineEnd, lineStart)
	local lineToIntersect = Vector3D.Mul(lineStartToEnd, t)
	
	return Vector3D.Add(lineStart, lineToIntersect)
end

return Vector3D