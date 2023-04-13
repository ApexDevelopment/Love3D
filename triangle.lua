local Vector3D = require "vector3d"

local Triangle = {
	new = function(points, texcoords, normals)
		if not points then points = {} end
		if not texcoords then texcoords = {} end
		if not normals then normals = {} end

		return {
			Points = points,
			TexCoords = texcoords,
			Normals = normals,
			Color = {
				R = 1,
				G = 1,
				B = 1
			}
		}
	end
}

-- Returns signed shortest distance from point to plane, plane normal must be normalized
local dist = function(planeP, planeN, p)
	return planeN.X * p.X + planeN.Y * p.Y + planeN.Z * p.Z - Vector3D.Dot(planeN, planeP)
end

function Triangle.Normal(triangle)
	local line1 = Vector3D.Sub(triangle.Points[2], triangle.Points[1])
	local line2 = Vector3D.Sub(triangle.Points[3], triangle.Points[1])

	return Vector3D.Normalize(Vector3D.Cross(line1, line2))
end

function Triangle.ClipAgainstPlane(planeP, planeN, inTri)
	-- Make sure the plane normal is actually normal
	planeN = Vector3D.Normalize(planeN)
	
	-- Create two temporary storage arrays to classify points on either side of plane
	-- If distance sign is positive, the point lies "inside" of the plane
	local insidePoints, insideCount = {}, 0
	local outsidePoints, outsideCount = {}, 0
	
	-- Get signed distance of each point in triangle to plane
	local d1 = dist(planeP, planeN, inTri.Points[1])
	local d2 = dist(planeP, planeN, inTri.Points[2])
	local d3 = dist(planeP, planeN, inTri.Points[3])
	
	if d1 >= 0 then
		insideCount = insideCount + 1
		insidePoints[insideCount] = inTri.Points[1]
	else
		outsideCount = outsideCount + 1
		outsidePoints[outsideCount] = inTri.Points[1]
	end
	
	if d2 >= 0 then
		insideCount = insideCount + 1
		insidePoints[insideCount] = inTri.Points[2]
	else
		outsideCount = outsideCount + 1
		outsidePoints[outsideCount] = inTri.Points[2]
	end
	
	if d3 >= 0 then
		insideCount = insideCount + 1
		insidePoints[insideCount] = inTri.Points[3]
	else
		outsideCount = outsideCount + 1
		outsidePoints[outsideCount] = inTri.Points[3]
	end
	
	-- Now classify triangle points, and break the input triangle into
	-- smaller output triangles if required. There are four possible
	-- outcomes...
	
	if insideCount == 0 then
		-- All points lie on the outside of plane, so clip whole triangle
		-- It ceases to exist
		
		return 0 -- No returned triangles are valid
	end
	
	if insideCount == 3 then
		-- All points lie on the inside of plane, so do nothing
		-- and allow the triangle to simply pass through
		
		return 1, inTri -- Just the one returned original triangle is valid
	end
	
	if insideCount == 1 then
		-- Triangle should be clipped. As two points lie outside
		-- the plane, the triangle simply becomes a smaller triangle
		
		local outTri = Triangle.new({
			-- The inside point is valid, so keep that...
			insidePoints[1],
			-- But the two new points are at the locations where the
			-- original sides of the triangle (lines) intersect with the plane
			Vector3D.IntersectPlane(planeP, planeN, insidePoints[1], outsidePoints[1]),
			Vector3D.IntersectPlane(planeP, planeN, insidePoints[1], outsidePoints[2])
		})
		
		outTri.Color = inTri.Color
		
		return 1, outTri -- Return the newly formed single triangle
	end
	
	if insideCount == 2 then
		-- Triangle should be clipped. As two points lie inside the plane,
		-- the clipped triangle becomes a quad. Fortunately, we can
		-- represent a quad with two new triangles
		
		-- The first triangle consists of the two inside points and a new
		-- point determined by the location where one side of the triangle
		-- intersects with the plane
		local outTri1 = Triangle.new({
			insidePoints[1],
			insidePoints[2],
			Vector3D.IntersectPlane(planeP, planeN, insidePoints[1], outsidePoints[1])
		})
		
		-- The second triangle is composed of one of the inside points, a
		-- new point determined by the intersection of the other side of the
		-- triangle and the plane, and the newly created point above
		local outTri2 = Triangle.new({
			insidePoints[2],
			outTri1.Points[3],
			Vector3D.IntersectPlane(planeP, planeN, insidePoints[2], outsidePoints[1])
		})
		
		outTri1.Color = inTri.Color
		outTri2.Color = inTri.Color
		
		return 2, outTri1, outTri2 -- Return two newly formed triangles which form a quad
	end
end

return Triangle