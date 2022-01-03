--[[ Services, Variables & other modules. ]]--
local HttpService = game:GetService("HttpService")
local Utility = require(script.Utility)
local Data = script.Data

local rmc = {}
rmc.__index = rmc

--[[ Configuration ]] --
local Server = "https://pt-ca-mtl01.pyrohost.cloud:10227"
local Username = "admin"
local Password = "aP@55word"

--[[ Internal Functions ]]--
function rmc:GetData(combinedKey, default)
	local response
	local data
	local AuthorizationBase64String = Utility.BaseEncode(Username..":"..Password)
	
	pcall(function ()
		response = HttpService:GetAsync(Server.."/get-data/"..combinedKey, true, {["Authorization"] =  "Basic "..AuthorizationBase64String})
		data = HttpService:JSONDecode(response)
	end)
	
	if not data then return default end
	
	if data.Data ~= nil then
		return data.Data
	else
		return default
	end
end

function rmc:SaveData(combinedKey)	
	local response
	local data
	
	local saveData = HttpService:JSONDecode(Data:FindFirstChild(combinedKey).Value)
	local sendData = HttpService:JSONEncode({
		SaveData = saveData.Data,
		DataType = typeof(saveData.Data)
	})
	
	local AuthorizationBase64String = Utility.BaseEncode(Username..":"..Password)
	
	pcall(function ()
		response = HttpService:PostAsync(Server.."/save-data/"..combinedKey, sendData, Enum.HttpContentType.ApplicationJson, false, {["Authorization"] =  "Basic "..AuthorizationBase64String})
	end)
	
	return true
end

--[[ Public Functions ]]--
function rmc:CreateConnection(key, player)
	local newConnection = {}
	setmetatable(newConnection, rmc)
	
	newConnection["Key"] = key
	newConnection["Player"] = player.UserId
	newConnection["CombinedKey"] = key.."-"..player.UserId
	
	return newConnection
end

function rmc:GetStore(key, player)
	if not key or not player then return end
	
	if not Data:FindFirstChild(key.."-"..player.UserId) then
		local store = self:CreateConnection(key, player)
		
		game:BindToClose(function()
			store:Save(store.CombinedKey)
		end)
		
		game.Players.PlayerRemoving:Connect(function(plr)
			if plr.UserId == player.UserId then
				store:Save(store.CombinedKey)
			end
		end)
		
		return store
	else
		local store = self:CreateConnection(key, player)
		local Data = HttpService:JSONDecode(Data:FindFirstChild(key.."-"..player.UserId).Value)
		store.Data = Data.Data
		
		return store
	end
end

function rmc:Get(default)	
	if not default then return end
	
	if self.Data then
		if not Data:FindFirstChild(self.CombinedKey) then
			local DataValue = Instance.new("StringValue", Data)
			DataValue.Name = self.CombinedKey
			DataValue.Value = HttpService:JSONEncode({
				Data = self.Data
			})		
		end
		
		local returnData = HttpService:JSONDecode(Data:FindFirstChild(self.CombinedKey).Value).Data 
		return returnData
	else
		self.Data = self:GetData(self.CombinedKey, default)
		
		if not Data:FindFirstChild(self.CombinedKey) then
			local DataValue = Instance.new("StringValue", Data)
			DataValue.Name = self.CombinedKey
			DataValue.Value = HttpService:JSONEncode({
				Data = self.Data
			})				
		end		
		
		local returnData = HttpService:JSONDecode(Data:FindFirstChild(self.CombinedKey).Value).Data 
		return returnData
	end
end

function rmc:Set(data)
	if not data then return end
	
	self.Data = data
	Data:FindFirstChild(self.CombinedKey).Value = HttpService:JSONEncode({
		Data = data
	})
	return data
end

function rmc:Save(CombinedKey)
	if self:SaveData(CombinedKey) then
		print("Successfully saved data for - ", CombinedKey)
	else
		warn("Error While saving Data for - ", CombinedKey)
	end
end

return rmc
