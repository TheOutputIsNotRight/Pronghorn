--!strict
--[[
╔═══════════════════════════════════════════════╗
║              Pronghorn Framework              ║
║  https://iron-stag-games.github.io/Pronghorn  ║
╚═══════════════════════════════════════════════╝
]]

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Dependencies
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local RunService = game:GetService("RunService")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper Variables
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local IS_STUDIO = RunService:IsStudio()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function abort(errorMessage: string)
	if IS_STUDIO then
		error(errorMessage, 0)
	else
		warn(errorMessage)
		task.defer(coroutine.close, coroutine.running())
		coroutine.yield()
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return function(remote: any, requiredParameterTypes: {string}, ...: any)
	local parameters = {...}

	for index = 1, math.max(#requiredParameterTypes, #parameters) do
		requiredParameterTypes[index] = requiredParameterTypes[index] or "nil"

		local parameter = parameters[index]
		local parameterType = typeof(parameter)
		local requiredParameterType = requiredParameterTypes[index]:gsub(" ", ""):gsub("?", "")

		if requiredParameterType == "..." then break end

		local requiredParameterTypeOptions = requiredParameterType:split("|")
		local pass = false

		if
			requiredParameterTypes[index]:find("?", 1, true) and parameter == nil
			or requiredParameterType == "any" and parameter ~= nil
		then
			pass = true
		else
			for _, parameterTypeOption in requiredParameterTypeOptions do
				if
					parameterType == parameterTypeOption
					or parameterType == "EnumItem" and "Enum." .. tostring(parameter.EnumType) == parameterTypeOption
					or parameterType == "Instance" and parameter:IsA(parameterTypeOption)
				then
					pass = true
				end
			end
		end

		if not pass then
			abort(`{remote.Parent.Name}.{remote.Name}: Parameter {index} expected type '{requiredParameterType:gsub("|", " | ")}', got '{parameterType}'`)
		end

		if parameterType == "number" and (parameter == math.huge or parameter == -math.huge or parameter ~= parameter) then
			abort(`{remote.Parent.Name}.{remote.Name}: Parameter {index} was inf or nan`)
		end
	end
end
