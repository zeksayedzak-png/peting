-- =============================================================================
-- PET SYSTEM ONLY - FROM ORIGINAL SCRIPT
-- Works on Mobile with Delta + loadstring
-- Draggable Small UI in Center
-- =============================================================================

-- Load Roblox Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

localPlayer:WaitForChild("PlayerGui")
wait(1)

-- =============================================================================
-- EXACT PET SYSTEM FROM ORIGINAL SCRIPT (LINES 104-190)
-- =============================================================================

local PetSystem = {}
PetSystem.__index = PetSystem

function PetSystem.new()
    local self = setmetatable({}, PetSystem)
    self.Pets = {}
    self.PetUUIDs = {}
    self.PetAttributes = {}
    return self
end

function PetSystem:GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function PetSystem:AddPet(player, petType, customUUID, weight, age)
    local petUUID = customUUID or self:GenerateUUID()
    
    -- EXACT DATA STRUCTURE FROM ORIGINAL (Lines 128-146)
    local petData = {
        Type = petType,
        UUID = petUUID,
        Owner = player.UserId,
        OwnerName = player.Name,
        Created = os.time(),
        Attributes = {
            Weight = weight or math.random(1, 100),
            Age = age or 0,
            Hunger = 100,
            Happiness = 100,
            Level = 1,
            Rarity = "Common",
            Value = math.random(100, 1000)
        }
    }
    
    -- EXACT STORAGE FROM ORIGINAL (Lines 148-156)
    self.Pets[petUUID] = petData
    
    if not self.PetUUIDs[player.UserId] then
        self.PetUUIDs[player.UserId] = {}
    end
    
    table.insert(self.PetUUIDs[player.UserId], petUUID)
    
    -- EXACT TOOL CREATION FROM ORIGINAL (Lines 178-190)
    local petTool = Instance.new("Tool")
    petTool.Name = petType .. " [" .. petData.Attributes.Weight .. " KG] [Age " .. petData.Attributes.Age .. "]"
    petTool.Parent = player.Backpack
    
    -- EXACT ATTRIBUTES FROM ORIGINAL
    petTool:SetAttribute("PET_UUID", petUUID)
    petTool:SetAttribute("OWNER", player.Name)
    petTool:SetAttribute("ItemType", "Pet")
    petTool:SetAttribute("PetType", petType)
    petTool:SetAttribute("b", tostring(petData.Attributes.Weight))
    petTool:SetAttribute("d", false)
    petTool:SetAttribute("a", player.Name)
    
    print("✅ Pet Created: " .. petType .. " for " .. player.Name .. " (UUID: " .. petUUID .. ")")
    return petData
end

function PetSystem:GetPetByUUID(uuid)
    return self.Pets[uuid]
end

function PetSystem:GetPlayerPets(player)
    local userId = typeof(player) == "number" and player or player.UserId
    return self.PetUUIDs[userId] or {}
end

function PetSystem:UpdatePetAttribute(petUUID, attribute, value)
    local pet = self.Pets[petUUID]
    if pet and pet.Attributes[attribute] then
        pet.Attributes[attribute] = value
        return true
    end
    return false
end

-- =============================================================================
-- DRAGGABLE UI (Small Window in Center)
-- =============================================================================

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetCreatorMobile"
screenGui.Parent = localPlayer.PlayerGui

-- Main Frame (Small, Centered, Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 200)  -- Small size
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)  -- Center
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 120, 215)
mainFrame.Parent = screenGui

-- Title Bar (For Dragging)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 90, 180)
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🐉 Create Pet"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button (Small X)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -22, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 12
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Input Frame
local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.Size = UDim2.new(1, -10, 1, -35)
inputFrame.Position = UDim2.new(0, 5, 0, 30)
inputFrame.BackgroundTransparency = 1
inputFrame.Parent = mainFrame

-- Pet Name Input (EXACTLY like original needs)
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "NameLabel"
nameLabel.Size = UDim2.new(1, 0, 0, 20)
nameLabel.Position = UDim2.new(0, 0, 0, 5)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Pet Name:"
nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
nameLabel.TextSize = 12
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = inputFrame

local nameBox = Instance.new("TextBox")
nameBox.Name = "NameBox"
nameBox.Size = UDim2.new(1, 0, 0, 25)
nameBox.Position = UDim2.new(0, 0, 0, 25)
nameBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.Text = "Dragon"
nameBox.PlaceholderText = "Enter pet name..."
nameBox.Parent = inputFrame

-- Weight Input (For KG like original)
local weightLabel = Instance.new("TextLabel")
weightLabel.Name = "WeightLabel"
weightLabel.Size = UDim2.new(0.48, 0, 0, 20)
weightLabel.Position = UDim2.new(0, 0, 0, 60)
weightLabel.BackgroundTransparency = 1
weightLabel.Text = "Weight (KG):"
weightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
weightLabel.TextSize = 12
weightLabel.TextXAlignment = Enum.TextXAlignment.Left
weightLabel.Parent = inputFrame

local weightBox = Instance.new("TextBox")
weightBox.Name = "WeightBox"
weightBox.Size = UDim2.new(0.48, 0, 0, 25)
weightBox.Position = UDim2.new(0, 0, 0, 80)
weightBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
weightBox.TextColor3 = Color3.fromRGB(255, 255, 255)
weightBox.Text = "50"
weightBox.Parent = inputFrame

-- Age Input (Like original)
local ageLabel = Instance.new("TextLabel")
ageLabel.Name = "AgeLabel"
ageLabel.Size = UDim2.new(0.48, 0, 0, 20)
ageLabel.Position = UDim2.new(0.52, 0, 0, 60)
ageLabel.BackgroundTransparency = 1
ageLabel.Text = "Age:"
ageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ageLabel.TextSize = 12
ageLabel.TextXAlignment = Enum.TextXAlignment.Left
ageLabel.Parent = inputFrame

local ageBox = Instance.new("TextBox")
ageBox.Name = "AgeBox"
ageBox.Size = UDim2.new(0.48, 0, 0, 25)
ageBox.Position = UDim2.new(0.52, 0, 0, 80)
ageBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ageBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ageBox.Text = "3"
ageBox.Parent = inputFrame

-- Create Button (Main Action)
local createButton = Instance.new("TextButton")
createButton.Name = "CreateButton"
createButton.Size = UDim2.new(1, 0, 0, 35)
createButton.Position = UDim2.new(0, 0, 1, -40)
createButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
createButton.Text = "➕ CREATE PET"
createButton.TextColor3 = Color3.fromRGB(255, 255, 255)
createButton.TextSize = 14
createButton.Parent = inputFrame

-- Status Label (For feedback)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 115)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready..."
statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
statusLabel.TextSize = 11
statusLabel.TextWrapped = true
statusLabel.Parent = inputFrame

-- =============================================================================
-- DRAGGABLE FUNCTIONALITY (For Mobile)
-- =============================================================================

local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = Vector2.new(0, 0)

-- Start dragging when title bar is touched
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
    end
end)

-- Move frame while dragging
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = Vector2.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)
        mainFrame.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
    end
end)

-- Stop dragging
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- =============================================================================
-- INITIALIZE PET SYSTEM (EXACTLY like original)
-- =============================================================================

local petSystem = PetSystem.new()

-- Store in _G like original (Line 486)
_G.PetSystem = petSystem

-- =============================================================================
-- CREATE PET FUNCTION (Using original system)
-- =============================================================================

createButton.MouseButton1Click:Connect(function()
    local petName = nameBox.Text
    local weight = tonumber(weightBox.Text)
    local age = tonumber(ageBox.Text)
    
    -- Simple validation
    if not petName or #petName < 2 then
        statusLabel.Text = "❌ Enter pet name"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    if not weight or weight < 1 or weight > 1000 then
        statusLabel.Text = "❌ Weight: 1-1000"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    if not age or age < 0 or age > 100 then
        statusLabel.Text = "❌ Age: 0-100"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- CREATE PET USING ORIGINAL SYSTEM
    local petData = petSystem:AddPet(localPlayer, petName, nil, weight, age)
    
    if petData then
        statusLabel.Text = "✅ " .. petName .. " created!\nCheck your Backpack!"
        statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        
        -- Optional: Clear inputs
        nameBox.Text = ""
        weightBox.Text = tostring(math.random(20, 80))
        ageBox.Text = tostring(math.random(1, 10))
    else
        statusLabel.Text = "❌ Failed to create pet"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- =============================================================================
-- AUTO CREATE TEST PET (Like original Line 488-490)
-- =============================================================================

wait(2)
petSystem:AddPet(localPlayer, "Test Dragon", nil, 45, 2)
statusLabel.Text = "✅ Test pet added!\nTry creating your own..."

-- =============================================================================
-- FINAL MESSAGE (Like original print statements)
-- =============================================================================

print("========================================")
print("Pet System Loaded Successfully!")
print("Drag the blue bar to move window")
print("Check Backpack for created pets")
print("========================================")

-- Return system for external access (Like original Line 507-519)
return {
    PetSystem = _G.PetSystem,
    GetSystemInfo = function()
        return {
            Name = "Mobile Pet System",
            Version = "1.0",
            Description = "Creates pets with name, weight, and age",
            OriginalFeatures = {
                "UUID generation for each pet",
                "Pet data storage system",
                "Tool creation in Backpack",
                "Attributes system (like original)"
            }
        }
    end
}
