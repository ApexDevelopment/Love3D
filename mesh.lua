local io = require "io"
local Vector3D = require "vector3d"
local Vector2D = require "vector2d"
local Triangle = require "triangle"

local Mesh = {
	new = function(triangles)
		if not triangles then triangles = {} end

		return { Triangles = triangles }
	end
}

-- CAN ONLY PROCESS TRIANGLES
Mesh.LoadFromFile = function(filePath)
	-- Local cache of verts
	local tris = {}
	local verts = {}
	local texcoords = {}
	local normals = {}

	for line in io.lines(filePath) do
		local command, rest = line:match("^(%S*) (.*)")

		if command == "v" then
			local x, y, z = rest:match("^(%S*) (%S*) (%S*)")
			local v = Vector3D.new(tonumber(x), tonumber(y), tonumber(z))
			table.insert(verts, v)
		elseif command == "vt" then
			local u, v = rest:match("^(%S*) (%S*)")
			table.insert(texcoords, Vector2D.new(tonumber(u), tonumber(v)))
		elseif command == "vn" then
			local x, y, z = rest:match("^(%S*) (%S*) (%S*)")
			table.insert(normals, Vector3D.new(tonumber(x), tonumber(y), tonumber(z)))
		elseif command == "f" then
			local coord1, coord2, coord3 = rest:match("^(%S*) (%S*) (.*)")

			local pt1, tx1, n1 = coord1:match("^(%S*)/?(%S*)/?(%S*)")
			local pt2, tx2, n2 = coord2:match("^(%S*)/?(%S*)/?(%S*)")
			local pt3, tx3, n3 = coord3:match("^(%S*)/?(%S*)/?(%S*)")

			local triVerts = {
				verts[tonumber(pt1)],
				verts[tonumber(pt2)],
				verts[tonumber(pt3)]
			}

			local triTexCoords = nil
			if tx1 and tx2 and tx3 then
				triTexCoords = {
					texcoords[tonumber(tx1)],
					texcoords[tonumber(tx2)],
					texcoords[tonumber(tx3)]
				}
			end

			local triNormals = nil
			if n1 and n2 and n3 then
				triNormals = {
					normals[tonumber(n1)],
					normals[tonumber(n2)],
					normals[tonumber(n3)]
				}
			end

			table.insert(tris, Triangle.new(triVerts, triTexCoords, triNormals))
		end
	end

	return Mesh.new(tris)
end

return Mesh