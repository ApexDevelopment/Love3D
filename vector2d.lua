local Vector2D = {
	new = function(X, Y, W)
		if not X then X = 0 end
		if not Y then Y = 0 end
		if not W then W = 1 end

		return { X = X, Y = Y, W = W }
	end
}

Vector2D.Add = function(vec1, vec2)
	return Vector2D.new(vec1.X + vec2.X, vec1.Y + vec2.Y)
end

Vector2D.Sub = function(vec1, vec2)
	return Vector2D.new(vec1.X - vec2.X, vec1.Y - vec2.Y)
end

Vector2D.Mul = function(vec1, k)
	return Vector2D.new(vec1.X * k, vec1.Y * k)
end

Vector2D.Div = function(vec1, k)
	return Vector2D.new(vec1.X / k, vec1.Y / k)
end

Vector2D.Dot = function(vec1, vec2)
	return vec1.X * vec2.X + vec1.Y * vec2.Y
end

Vector2D.Length = function(vec1)
	return math.sqrt(Vector2D.Dot(vec1, vec1))
end

Vector2D.Normalize = function(vec1)
	local l = Vector2D.Length(vec1)
	return Vector2D.Div(vec1, l)
end

return Vector2D