local Vector3D = require("vector3d")
local Matrix4f = require("matrix4f")

local Camera = {
	new = function(position, rotation, fovDegrees, aspectRatio, nearPlane, farPlane)
		if not position then position = Vector3D.new() end
		if not rotation then rotation = Vector3D.new() end
		if not fovDegrees then fovDegrees = 90 end
		if not aspectRatio then aspectRatio = 1 end
		if not nearPlane then nearPlane = 0.1 end
		if not farPlane then farPlane = 1000 end

		local rotationMatrix = Matrix4f.Mul(Matrix4f.Mul(
			Matrix4f.MakeRotationX(rotation.X),
			Matrix4f.MakeRotationY(rotation.Y)),
			Matrix4f.MakeRotationZ(rotation.Z))

		local lookDirection = Matrix4f.MulVector3D(rotationMatrix, Vector3D.forward)
		local upDirection = Matrix4f.MulVector3D(rotationMatrix, Vector3D.up)
		local target = Vector3D.Add(position, lookDirection)

		local cameraMatrix = Matrix4f.PointAt(position, target, upDirection)
		local projectionMatrix = Matrix4f.MakeProjection(fovDegrees, aspectRatio, nearPlane, farPlane)

		return {
			Position = position,
			Rotation = rotation,
			FOVDegrees = fovDegrees,
			AspectRatio = aspectRatio,
			NearPlane = nearPlane,
			FarPlane = farPlane,
			-- Private members
			_RotationMatrix = rotationMatrix,
			_LookDirection = lookDirection,
			_UpDirection = upDirection,
			_Target = target,
			_CameraMatrix = cameraMatrix,
			_ViewMatrix = Matrix4f.QuickInverse(cameraMatrix),
			_ProjectionMatrix = projectionMatrix
		}
	end
}

Camera.Move = function(self, vMove)
	self.Position = Vector3D.Add(self.Position, vMove)
	self._Target = Vector3D.Add(self._Target, vMove)
	self._CameraMatrix = Matrix4f.PointAt(self.Position, self._Target, self._UpDirection)
	self._ViewMatrix = Matrix4f.QuickInverse(self._CameraMatrix)
end

Camera.Rotate = function(self, vRotation)
	self.Rotation = Vector3D.Add(self.Rotation, vRotation)
	self._RotationMatrix = Matrix4f.Mul(Matrix4f.Mul(
		Matrix4f.MakeRotationX(self.Rotation.X),
		Matrix4f.MakeRotationY(self.Rotation.Y)),
		Matrix4f.MakeRotationZ(self.Rotation.Z))
	self._LookDirection = Matrix4f.MulVector3D(self._RotationMatrix, Vector3D.forward)
	self._UpDirection = Matrix4f.MulVector3D(self._RotationMatrix, Vector3D.up)
	self._Target = Vector3D.Add(self.Position, self._LookDirection)
	self._CameraMatrix = Matrix4f.PointAt(self.Position, self._Target, self._UpDirection)
	self._ViewMatrix = Matrix4f.QuickInverse(self._CameraMatrix)
end

Camera.GetViewMatrix = function(self)
	return self._ViewMatrix
end

Camera.GetProjectionMatrix = function(self)
	return self._ProjectionMatrix
end

Camera.GetLookDirection = function(self)
	return self._LookDirection
end

return Camera