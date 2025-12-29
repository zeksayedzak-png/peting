-- =============================================================================
-- GROW A GARDEN PET SYSTEM - ORIGINAL STYLE
-- Compatible with: Delta + Roblox Mobile
-- =============================================================================

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- =============================================================================
-- ORIGINAL PET SYSTEM (FROM YOUR SCRIPT)
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
    
    self.Pets[petUUID] = petData
    
    if not self.PetUUIDs[player.UserId] then
        self.PetUUIDs[player.UserId] = {}
    end
    
    table.insert(self.PetUUIDs[player.UserId], petUUID)
    
    -- Create pet tool/model
    local petTool = Instance.new("Tool")
    petTool.Name = petType .. " [" .. petData.Attributes.Weight .. " KG] [Age " .. petData.Attributes.Age .. "]"
    petTool.Parent = player.Backpack
    
    -- Set attributes (EXACT SAME AS ORIGINAL)
    petTool:SetAttribute("PET_UUID", petUUID)
    petTool:SetAttribute("OWNER", player.Name)
    petTool:SetAttribute("ItemType", "Pet")
    petTool:SetAttribute("PetType", petType)
    petTool:SetAttribute("b", tostring(petData.Attributes.Weight))
    petTool:SetAttribute("d", false)
    petTool:SetAttribute("a", player.Name)
    
    print("Pet Created: " .. petType .. " for " .. player.Name .. " (UUID: " .. petUUID .. ")")
    return petData
end

-- =============================================================================
-- DRAGGABLE UI WITH 3 INPUTS (NAME, WEIGHT, AGE)
-- =============================================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetCreatorUI"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main Frame (Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 120, 215)
mainFrame.Parent = screenGui

-- Title Bar (Draggable)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 90, 180)
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🐉 PET CREATOR"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -27, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Input Frame
local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.Size = UDim2.new(1, -20, 1, -50)
inputFrame.Position = UDim2.new(0, 10, 0, 40)
inputFrame.BackgroundTransparency = 1
inputFrame.Parent = mainFrame

-- PET NAME INPUT
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "NameLabel"
nameLabel.Size = UDim2.new(1, 0, 0, 20)
nameLabel.Position = UDim2.new(0, 0, 0, 10)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Pet Name:"
nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
nameLabel.TextSize = 14
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = inputFrame

local nameBox = Instance.new("TextBox")
nameBox.Name = "NameBox"
nameBox.Size = UDim2.new(1, 0, 0, 35)
nameBox.Position = UDim2.new(0, 0, 0, 30)
nameBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.Text = "Dragon"
nameBox.PlaceholderText = "Enter pet name..."
nameBox.Parent = inputFrame

-- WEIGHT INPUT
local weightLabel = Instance.new("TextLabel")
weightLabel.Name = "WeightLabel"
weightLabel.Size = UDim2.new(0.48, 0, 0, 20)
weightLabel.Position = UDim2.new(0, 0, 0, 75)
weightLabel.BackgroundTransparency = 1
weightLabel.Text = "Weight (1-100):"
weightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
weightLabel.TextSize = 14
weightLabel.TextXAlignment = Enum.TextXAlignment.Left
weightLabel.Parent = inputFrame

local weightBox = Instance.new("TextBox")
weightBox.Name = "WeightBox"
weightBox.Size = UDim2.new(0.48, 0, 0, 35)
weightBox.Position = UDim2.new(0, 0, 0, 95)
weightBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
weightBox.TextColor3 = Color3.fromRGB(255, 255, 255)
weightBox.Text = "50"
weightBox.Parent = inputFrame

-- AGE INPUT
local ageLabel = Instance.new("TextLabel")
ageLabel.Name = "AgeLabel"
ageLabel.Size = UDim2.new(0.48, 0, 0, 20)
ageLabel.Position = UDim2.new(0.52, 0, 0, 75)
ageLabel.BackgroundTransparency = 1
ageLabel.Text = "Age (0-50):"
ageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ageLabel.TextSize = 14
ageLabel.TextXAlignment = Enum.TextXAlignment.Left
ageLabel.Parent = inputFrame

local ageBox = Instance.new("TextBox")
ageBox.Name = "AgeBox"
ageBox.Size = UDim2.new(0.48, 0, 0, 35)
ageBox.Position = UDim2.new(0.52, 0, 0, 95)
ageBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ageBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ageBox.Text = "3"
ageBox.Parent = inputFrame

-- CREATE BUTTON
local createButton = Instance.new("TextButton")
createButton.Name = "CreateButton"
createButton.Size = UDim2.new(1, 0, 0, 40)
createButton.Position = UDim2.new(0, 0, 1, -45)
createButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
createButton.Text = "➕ CREATE PET"
createButton.TextColor3 = Color3.fromRGB(255, 255, 255)
createButton.TextSize = 16
createButton.Parent = inputFrame

-- STATUS LABEL
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 140)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready to create pets..."
statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Parent = inputFrame

-- =============================================================================
-- DRAGGABLE FUNCTIONALITY
-- =============================================================================

local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = Vector2.new(0, 0)

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)
        mainFrame.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- =============================================================================
-- CREATE PET FUNCTION
-- =============================================================================

local petSystem = PetSystem.new()

createButton.MouseButton1Click:Connect(function()
    local petName = nameBox.Text
    local weight = tonumber(weightBox.Text)
    local age = tonumber(ageBox.Text)
    
    -- Validation
    if not petName or #petName < 2 then
        statusLabel.Text = "❌ Enter valid pet name"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    if not weight or weight < 1 or weight > 100 then
        statusLabel.Text = "❌ Weight must be 1-100"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    if not age or age < 0 or age > 50 then
        statusLabel.Text = "❌ Age must be 0-50"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- Create the pet
    local petData = petSystem:AddPet(localPlayer, petName, nil, weight, age)
    
    if petData then
        statusLabel.Text = "✅ Pet Created!\n" .. 
                          petName .. " [" .. weight .. "KG] [Age " .. age .. "]"
        statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        
        -- Clear inputs
        nameBox.Text = ""
        weightBox.Text = tostring(math.random(1, 100))
        ageBox.Text = tostring(math.random(0, 10))
    end
end)

-- =============================================================================
-- INITIALIZATION
-- =============================================================================

print("========================================")
print("PET SYSTEM LOADED - GROW A GARDEN")
print("Drag the title bar to move window")
print("Check backpack for created pets")
print("========================================")

-- Create a test pet automatically
wait(1)
petSystem:AddPet(localPlayer, "Test Dragon", nil, 50, 3)

return {
    PetSystem = petSystem,
    GetSystemInfo = function()
        return {
            Name = "Grow a Garden Pet System",
            Version = "1.0",
            Description = "Creates pets with custom name, weight, and age",
            Features = {
                "Draggable UI window",
                "Three input fields (Name, Weight, Age)",
                "Pets appear as tools in backpack",
                "100% original system replication",
                "Mobile compatible with Delta"
            }
        }
    end
}
