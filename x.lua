local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData =
	require(
		ReplicatedStorage
		.Client
		.Modules
		.ClientGlobals
	).PlayerData

local skins =
	ReplicatedStorage:WaitForChild("Skins")

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local TYPE = "Knife"
-- "Knife"
-- "Gun"

local AMOUNT = 25
-- cantidad visual por skin

--------------------------------------------------

task.spawn(function()

	PlayerData:WaitForLoaded()

	local inv =
		PlayerData:TryIndex({
			"Inventory",
			TYPE
		})

	if not inv then
		return
	end

	local folder =
		TYPE=="Knife"
		and skins.Knives
		or skins.Guns

	local fake={}

	for guid,item in pairs(inv) do
		fake[guid]=item
	end

	for _,skin in ipairs(folder:GetChildren()) do

		for i=1,AMOUNT do

			local id=
				"TEST_"..
				skin.Name..
				"_"..
				i

			fake[id]={
				name=skin.Name
			}

		end

	end

	------------------------------------------------
	-- SOBREESCRIBE SOLO CLIENTE
	------------------------------------------------

	local old =
		PlayerData.TryIndex

	PlayerData.TryIndex =
		function(self,path)

			if
				path[1]=="Inventory"
				and
				path[2]==TYPE
			then
				return fake
			end

			return old(
				self,
				path
			)

		end

	print(
		"Visual inventory cargado"
	)

end)
