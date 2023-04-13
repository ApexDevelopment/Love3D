local Object = require "classic"
Logger = Object:extend()

Logger.LevelNames = {
	"INFO", -- Necessary Information
	"CRIT", -- Critical Error
	"WARN", -- Warning
	"DEBG", -- Debug Information
	"EXTR"  -- Extraneous Information (very verbose)
}

function Logger:new(logLevel)
	self.Log = {}
	self.MaximumLogLevel = logLevel
	self.X = 10
	self.Y = 10
end

function Logger:log(message, logLevel)
	if logLevel <= self.MaximumLogLevel then
		local formatted = "[" .. Logger.LevelNames[logLevel + 1] .. "] " .. message
		print(formatted)
		table.insert(self.Log, { Text = formatted, Level = logLevel })
	end

	if #self.Log > 36 then table.remove(self.Log, 1) end
end

function Logger:update(dt)

end

function Logger:draw()
	for i, v in ipairs(self.Log) do
		local r,g,b,a = love.graphics.getColor()

		if v.Level == 0 then love.graphics.setColor(1, 1, 1)
		elseif v.Level == 1 then love.graphics.setColor(0.8, 0, 0)
		elseif v.Level == 2 then love.graphics.setColor(0.5, 0.5, 0)
		elseif v.Level == 3 then love.graphics.setColor(0, 0.2, 0.5)
		else love.graphics.setColor(0.6, 0.6, 0.6) end

		love.graphics.print(v.Text, self.X, self.Y + (i - 1) * 16)
		love.graphics.setColor(r,g,b,a)
	end
end