Rmc:GetStore("StoreName", playerInstance)

Basically create or get an existing store, for using the :Get and :Set methods On.

Store:Get(DefaultValue)

This method accepts a default value to be used if there isn’t data for the player previously.

Store:Set(Value)

This method accepts the value to update in the store.




# Code Examples 

local Rmc = require(script.Parent.RobloxMongoConnector)
local players = game.Players

players.PlayerAdded:Connect(function(plr)
	local coinStore = Rmc:GetStore("Coins", plr)
	print(coinStore:Get(50))
	
	wait(5)
	
	coinStore:Set(100)
	print(coinStore:Get(50))	
end)