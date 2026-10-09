--[[
    Die of Death - Pursuer Miso Skin Manager System
    Designed for Roblox Studio & In-Game Testing
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 1. Setup Remotes (Automatically creates if missing)
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local equipSkinRemote = remotesFolder:FindFirstChild("EquipSkin")
if not equipSkinRemote then
	equipSkinRemote = Instance.new("RemoteEvent")
	equipSkinRemote.Name = "EquipSkin"
	equipSkinRemote.Parent = remotesFolder
end

local unlockSkinRemote = remotesFolder:FindFirstChild("UnlockSkin")
if not unlockSkinRemote then
	unlockSkinRemote = Instance.new("RemoteEvent")
	unlockSkinRemote.Name = "UnlockSkin"
	unlockSkinRemote.Parent = remotesFolder
end


-- 2. Server-Side Logic (Executes on Server Context)
if RunService:IsServer() then
	local playerData = {}

	-- Initialize player inventory
	local function onPlayerAdded(player)
		playerData[player.UserId] = {
			Skins = {
				Pursuer = {
					Default = true,
					Miso = false
				}
			},
			EquippedSkins = {
				Pursuer = "Default"
			}
		}

		-- Chat Command for testing: Type "/grantmiso"
		player.Chatted:Connect(function(message)
			if message:lower() == "/grantmiso" then
				local pData = playerData[player.UserId]
				if pData and pData.Skins.Pursuer then
					pData.Skins.Pursuer.Miso = true
					print("[SkinManager] Unlocked Miso skin for: " .. player.Name)
					unlockSkinRemote:FireClient(player, "Pursuer", "Miso", true)
				end
			end
		end)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		playerData[player.UserId] = nil
	end)

	-- Handle Equip Requests
	equipSkinRemote.OnServerEvent:Connect(function(player, characterClass, skinName)
		local pData = playerData[player.UserId]
		if not pData then return end

		local hasSkin = pData.Skins[characterClass] and pData.Skins[characterClass][skinName]
		if hasSkin then
			pData.EquippedSkins[characterClass] = skinName
			print("[SkinManager] " .. player.Name .. " equipped skin: " .. skinName .. " for " .. characterClass)
		else
			warn("[SkinManager] " .. player.Name .. " attempted to equip locked skin: " .. skinName)
		end
	end)

	print("[SkinManager] Server System Loaded Successfully!")
end


-- 3. Client-Side Helper Functions (Executes on Client Context)
if RunService:IsClient() then
	local LocalPlayer = Players.LocalPlayer

	_G.EquipMisoSkin = function()
		equipSkinRemote:FireServer("Pursuer", "Miso")
		print("[SkinManager Client] Fired EquipSkin for Pursuer Miso")
	end

	print("[SkinManager] Client Loaded! Call `_G.EquipMisoSkin()` in Command Bar or LocalScript to equip.")
end
