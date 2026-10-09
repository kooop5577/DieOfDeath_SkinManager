--[[
    Die of Death - Pursuer Miso Skin Applicator
    Executes directly on the local player's character.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Function to apply the Miso Skin Visuals
local function applyMisoSkin(char)
	local humanoid = char:WaitForChild("Humanoid")
	
	-- 1. Locate the Miso Skin Asset in ReplicatedStorage
	-- Adjust this path if your game stores assets in a different folder
	local skinFolder = ReplicatedStorage:FindFirstChild("Assets") 
		and ReplicatedStorage.Assets:FindFirstChild("Skins")
		and ReplicatedStorage.Assets.Skins:FindFirstChild("Pursuer")
		and ReplicatedStorage.Assets.Skins.Pursuer:FindFirstChild("Miso")

	if not skinFolder then
		-- Fallback: Search directly inside ReplicatedStorage
		skinFolder = ReplicatedStorage:FindFirstChild("Miso") or ReplicatedStorage:FindFirstChild("Pursuer_Miso")
	end

	if skinFolder then
		-- 2. Clean up existing accessories/parts if necessary
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Accessory") and child.Name:find("Miso") then
				child:Destroy()
			end
		end

		-- 3. Clone and parent new skin elements/accessories to the character
		for _, item in ipairs(skinFolder:GetChildren()) do
			local clonedItem = item:Clone()
			
			if clonedItem:IsA("Accessory") then
				humanoid:AddAccessory(clonedItem)
			elseif clonedItem:IsA("BasePart") or clonedItem:IsA("Model") then
				clonedItem.Parent = char
			end
		end

		print("[Miso Skin] Successfully applied Miso skin to " .. player.Name)
	else
		warn("[Miso Skin] Miso skin assets could not be found in ReplicatedStorage!")
	end
end

-- Apply the skin to the current character
applyMisoSkin(character)

-- Automatically re-apply upon respawn
player.CharacterAdded:Connect(function(newChar)
	applyMisoSkin(newChar)
end)
