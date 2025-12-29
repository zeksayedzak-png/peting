-- =============================================================================
-- Pet System Simulation Script - Based on Original Code
-- For Educational and Security Testing Purposes Only
-- =============================================================================

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Constants
local fruitNames = {
    "apple", "cactus", "candy blossom", "coconut", 
    "dragon fruit", "easter egg", "grape", "mango", 
    "peach", "pineapple", "blue berry"
}

-- Global Variables
local activeTweens = {}
local petDatabase = {}
local adminTools = {}
local screenGui
local updateButton

-- Utility Functions
local function createRainbowTween(label)
    local colors = {
        Color3.new(1, 0, 0),
        Color3.new(1, 0.5, 0),
        Color3.new(1, 1, 0),
        Color3.new(0, 1, 0),
        Color3.new(0, 0, 1),
        Color3.new(0.5, 0, 1),
        Color3.new(1, 0, 1)
    }
    
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
    
    if activeTweens[label] then
        activeTweens[label]:Cancel()
        activeTweens[label] = nil
    end
    
    spawn(function()
        while true do
            for _, color in ipairs(colors) do
                local tween = TweenService:Create(label, tweenInfo, {TextColor3 = color})
                activeTweens[label] = tween
                tween:Play()
                tween.Completed:Wait()
            end
        end
    end)
end

-- Fruit Display System (EXACT COPY)
local function updateFruits()
    for _, fruit in pairs(workspace:GetDescendants()) do
        if table.find(fruitNames, fruit.Name:lower()) then
            local weight = fruit:FindFirstChild("Weight")
            local variant = fruit:FindFirstChild("Variant")
            
            if weight and weight:IsA("NumberValue") then
                local weightValue = math.floor(weight.Value)
                local variantValue = variant and variant:IsA("StringValue") and variant.Value or "Normal"
                
                local shouldDisplay = (fruit.Name:lower() == "blue berry") or 
                                     (variantValue == "Gold") or 
                                     (variantValue == "Rainbow") or 
                                     (weight.Value > 20)
                
                local textColor = (variantValue == "Gold" and Color3.new(1, 1, 0)) or Color3.new(0, 0, 1)
                
                if shouldDisplay then
                    local billboard = fruit:FindFirstChild("WeightDisplay")
                    local maxDistance = 50 + (weightValue * 2)
                    
                    if not billboard then
                        billboard = Instance.new("BillboardGui")
                        billboard.Name = "WeightDisplay"
                        billboard.Parent = fruit
                        billboard.Adornee = fruit
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        billboard.MaxDistance = maxDistance
                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                        billboard.AlwaysOnTop = true
                        
                        local frame = Instance.new("Frame")
                        frame.Parent = billboard
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundTransparency = 1
                        
                        -- Shadow Label
                        local shadowLabel = Instance.new("TextLabel")
                        shadowLabel.Name = "ShadowLabel"
                        shadowLabel.Parent = frame
                        shadowLabel.Position = UDim2.new(0, 2, 0, 2)
                        shadowLabel.Size = UDim2.new(1, -2, 0.7, -2)
                        shadowLabel.BackgroundTransparency = 1
                        shadowLabel.TextColor3 = Color3.new(0.5, 0.5, 0.5)
                        shadowLabel.TextScaled = true
                        shadowLabel.Text = tostring(weightValue)
                        
                        -- Main Label
                        local mainLabel = Instance.new("TextLabel")
                        mainLabel.Name = "MainLabel"
                        mainLabel.Parent = frame
                        mainLabel.Position = UDim2.new(0, 0, 0, 0)
                        mainLabel.Size = UDim2.new(1, 0, 0.7, 0)
                        mainLabel.BackgroundTransparency = 1
                        mainLabel.TextColor3 = textColor
                        mainLabel.TextScaled = true
                        mainLabel.Text = tostring(weightValue)
                        
                        -- Variant Label
                        local variantLabel = Instance.new("TextLabel")
                        variantLabel.Name = "VariantLabel"
                        variantLabel.Parent = frame
                        variantLabel.Position = UDim2.new(0, 0, 0.7, 0)
                        variantLabel.Size = UDim2.new(1, 0, 0.3, 0)
                        variantLabel.BackgroundTransparency = 1
                        variantLabel.TextColor3 = textColor
                        variantLabel.TextScaled = true
                        variantLabel.Text = variantValue ~= "Normal" and variantValue or ""
                        
                        billboard.Destroying:Connect(function()
                            if activeTweens[mainLabel] then
                                activeTweens[mainLabel]:Cancel()
                                activeTweens[mainLabel] = nil
                            end
                            if activeTweens[variantLabel] then
                                activeTweens[variantLabel]:Cancel()
                                activeTweens[variantLabel] = nil
                            end
                        end)
                        
                        if variantValue == "Rainbow" then
                            createRainbowTween(mainLabel)
                            createRainbowTween(variantLabel)
                        end
                    else
                        billboard.MaxDistance = maxDistance
                        local frame = billboard:FindFirstChild("Frame")
                        
                        if frame then
                            local shadowLabel = frame:FindFirstChild("ShadowLabel")
                            local mainLabel = frame:FindFirstChild("MainLabel")
                            local variantLabel = frame:FindFirstChild("VariantLabel")
                            
                            if shadowLabel and mainLabel and variantLabel then
                                shadowLabel.Text = tostring(weightValue)
                                mainLabel.Text = tostring(weightValue)
                                mainLabel.TextColor3 = textColor
                                variantLabel.Text = variantValue ~= "Normal" and variantValue or ""
                                variantLabel.TextColor3 = textColor
                                
                                if variantValue == "Rainbow" then
                                    createRainbowTween(mainLabel)
                                    createRainbowTween(variantLabel)
                                end
                            end
                        end
                    end
                else
                    local billboard = fruit:FindFirstChild("WeightDisplay")
                    if billboard then
                        billboard:Destroy()
                    end
                end
                
                -- Add Click Detector
                if not fruit:FindFirstChild("ClickDetector") then
                    local clickDetector = Instance.new("ClickDetector")
                    clickDetector.Parent = fruit
                    
                    clickDetector.MouseClick:Connect(function()
                        spawn(function()
                            local tempBillboard = Instance.new("BillboardGui")
                            tempBillboard.Name = "TempWeightDisplay"
                            tempBillboard.Parent = fruit
                            tempBillboard.Adornee = fruit
                            tempBillboard.Size = UDim2.new(0, 100, 0, 50)
                            tempBillboard.MaxDistance = 50 + (weightValue * 2)
                            tempBillboard.StudsOffset = Vector3.new(0, 3, 0)
                            tempBillboard.AlwaysOnTop = true
                            
                            local frame = Instance.new("Frame")
                            frame.Parent = tempBillboard
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundTransparency = 1
                            
                            local shadowLabel = Instance.new("TextLabel")
                            shadowLabel.Name = "ShadowLabel"
                            shadowLabel.Parent = frame
                            shadowLabel.Position = UDim2.new(0, 2, 0, 2)
                            shadowLabel.Size = UDim2.new(1, -2, 0.7, -2)
                            shadowLabel.BackgroundTransparency = 1
                            shadowLabel.TextColor3 = Color3.new(0.5, 0.5, 0.5)
                            shadowLabel.TextScaled = true
                            shadowLabel.Text = string.format("%.1f", weight.Value)
                            
                            local mainLabel = Instance.new("TextLabel")
                            mainLabel.Name = "MainLabel"
                            mainLabel.Parent = frame
                            mainLabel.Position = UDim2.new(0, 0, 0, 0)
                            mainLabel.Size = UDim2.new(1, 0, 0.7, 0)
                            mainLabel.BackgroundTransparency = 1
                            mainLabel.TextColor3 = textColor
                            mainLabel.TextScaled = true
                            mainLabel.Text = string.format("%.1f", weight.Value)
                            
                            local variantLabel = Instance.new("TextLabel")
                            variantLabel.Name = "VariantLabel"
                            variantLabel.Parent = frame
                            variantLabel.Position = UDim2.new(0, 0, 0.7, 0)
                            variantLabel.Size = UDim2.new(1, 0, 0.3, 0)
                            variantLabel.BackgroundTransparency = 1
                            variantLabel.TextColor3 = textColor
                            variantLabel.TextScaled = true
                            variantLabel.Text = variantValue
                            
                            if variantValue == "Rainbow" then
                                createRainbowTween(mainLabel)
                                createRainbowTween(variantLabel)
                            end
                            
                            wait(3)
                            
                            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
                            for _, label in pairs({shadowLabel, mainLabel, variantLabel}) do
                                local tween = TweenService:Create(label, tweenInfo, {TextTransparency = 1})
                                tween:Play()
                                activeTweens[label] = tween
                            end
                            
                            tween.Completed:Wait()
                            
                            for _, label in pairs({shadowLabel, mainLabel, variantLabel}) do
                                if activeTweens[label] then
                                    activeTweens[label]:Cancel()
                                    activeTweens[label] = nil
                                end
                            end
                            
                            tempBillboard:Destroy()
                        end)
                    end)
                end
            end
        end
    end
end

-- Pet System (EXACT COPY FROM ORIGINAL)
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

function PetSystem:AddPet(player, petType, customUUID)
    local petUUID = customUUID or self:GenerateUUID()
    
    local petData = {
        Type = petType,
        UUID = petUUID,
        Owner = player.UserId,
        OwnerName = player.Name,
        Created = os.time(),
        Attributes = {
            Weight = math.random(1, 100),
            Age = 0,
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
    
    -- Set attributes
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

-- Admin Tools/Modules (EXACT COPY)
local function InitializeAdminTools()
    -- Item Module
    local Item_Module = {
        GiveItem = function(player, itemId, amount)
            if not player or not itemId then return false end
            amount = amount or 1
            
            print("📦 Item Given: " .. itemId .. " ×" .. amount .. " to " .. player.Name)
            return true
        end,
        
        RemoveItem = function(player, itemId)
            print("🗑️ Item Removed: " .. itemId .. " from " .. player.Name)
            return true
        end,
        
        DuplicateItem = function(itemId, newOwner)
            print("🔄 Item Duplicated: " .. itemId .. " to new owner: " .. tostring(newOwner))
            return true
        end
    }
    
    -- Scale Module
    local Scale_Module = {
        ScalePlayer = function(player, scaleFactor)
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                    print("⚖️ Player Scaled: " .. player.Name .. " scale: " .. tostring(scaleFactor))
                end
            end
        end,
        
        ScaleAllPlayers = function(scaleFactor)
            for _, player in pairs(Players:GetPlayers()) do
                Scale_Module.ScalePlayer(player, scaleFactor)
            end
        end
    }
    
    -- NPC Module
    local NPC_MOD = {
        SpawnNPC = function(npcType, properties)
            properties = properties or {}
            print("🤖 NPC Spawned: " .. npcType)
            print("Properties: ", properties)
            
            return "NPC_" .. npcType .. "_" .. math.random(1000, 9999)
        end,
        
        RemoveNPC = function(npcId)
            print("🗑️ NPC Removed: " .. npcId)
            return true
        end
    }
    
    -- Crypto Module
    local Crypto = {
        AES = {
            Modes = {
                encrypt = function(data, key)
                    local result = ""
                    for i = 1, #data do
                        local charCode = string.byte(data, i) ~ (key or 42)
                        result = result .. string.char(charCode)
                    end
                    return result
                end,
                
                decrypt = function(data, key)
                    local result = ""
                    for i = 1, #data do
                        local charCode = string.byte(data, i) ~ (key or 42)
                        result = result .. string.char(charCode)
                    end
                    return result
                end,
                
                DEFAULT_KEY = "SECRET_KEY_123"
            }
        }
    }
    
    -- Store modules in ReplicatedStorage
    local moduleFolder = ReplicatedStorage:FindFirstChild("GameModules")
    if not moduleFolder then
        moduleFolder = Instance.new("Folder")
        moduleFolder.Name = "GameModules"
        moduleFolder.Parent = ReplicatedStorage
    end
    
    -- Create module scripts
    local function createModule(name, moduleTable)
        local moduleScript = Instance.new("ModuleScript")
        moduleScript.Name = name
        
        local sourceCode = "-- " .. name .. " Module\n\n"
        sourceCode = sourceCode .. "local module = {}\n\n"
        
        for funcName, func in pairs(moduleTable) do
            if type(func) == "function" then
                sourceCode = sourceCode .. "function module." .. funcName .. "(...)\n"
                sourceCode = sourceCode .. "    -- Function implementation\n"
                sourceCode = sourceCode .. "    return true\n"
                sourceCode = sourceCode .. "end\n\n"
            end
        end
        
        sourceCode = sourceCode .. "return module"
        moduleScript.Source = sourceCode
        moduleScript.Parent = moduleFolder
        
        return moduleScript
    end
    
    createModule("Item_Module", Item_Module)
    createModule("Scale_Module", Scale_Module)
    createModule("NPC_MOD", NPC_MOD)
    
    -- Special crypto module
    local cryptoModule = Instance.new("ModuleScript")
    cryptoModule.Name = "Crypto"
    cryptoModule.Source = [[
        local Crypto = {}
        
        Crypto.AES = {
            Modes = {
                encrypt = function(data, key)
                    local result = ""
                    for i = 1, #data do
                        local charCode = string.byte(data, i) ~ (key or 42)
                        result = result .. string.char(charCode)
                    end
                    return result
                end,
                
                decrypt = function(data, key)
                    local result = ""
                    for i = 1, #data do
                        local charCode = string.byte(data, i) ~ (key or 42)
                        result = result .. string.char(charChar)
                    end
                    return result
                end,
                
                _key = "DEFAULT_SECRET_KEY",
                DEFAULT_KEY = "CHANGE_THIS_IN_PRODUCTION"
            }
        }
        
        return Crypto
    ]]
    cryptoModule.Parent = moduleFolder
    
    -- Other admin modules
    local otherModules = {
        "Comma_Module",
        "Cutscene_Module", 
        "Field_Of_View_Module",
        "Frame_Popup_Module"
    }
    
    for _, moduleName in ipairs(otherModules) do
        local module = Instance.new("ModuleScript")
        module.Name = moduleName
        module.Source = "-- " .. moduleName .. "\n\nreturn {}"
        module.Parent = moduleFolder
    end
    
    adminTools = {
        Item = Item_Module,
        Scale = Scale_Module,
        NPC = NPC_MOD,
        Crypto = Crypto
    }
    
    print("🛠️ Admin Tools Initialized")
end

-- UI Creation (EXACT COPY)
local function CreateUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FruitDisplayUI"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    updateButton = Instance.new("TextButton")
    updateButton.Name = "UpdateButton"
    updateButton.Size = UDim2.new(0, 50, 0, 50)
    updateButton.Position = UDim2.new(0, 10, 0, 10)
    updateButton.BackgroundColor3 = Color3.new(0, 0, 1)
    updateButton.Text = "🔄"
    updateButton.TextSize = 20
    updateButton.Parent = screenGui
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    updateButton.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        startPos = updateButton.Position
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local delta = Vector2.new(mousePos.X - dragStart.X, mousePos.Y - dragStart.Y)
            updateButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    updateButton.MouseButton1Click:Connect(updateFruits)
    
    print("🎨 UI Created Successfully")
end

-- Main Initialization (EXACT COPY)
local function Initialize()
    print("🚀 Initializing System...")
    
    -- Create Pet System
    local petSystem = PetSystem.new()
    
    -- Store in global for access
    _G.PetSystem = petSystem
    
    -- Example: Add test pet for local player
    if Players.LocalPlayer then
        local testPet = petSystem:AddPet(Players.LocalPlayer, "Capybara")
        print("📝 Test Pet Created: " .. testPet.UUID)
    end
    
    -- Initialize Admin Tools
    InitializeAdminTools()
    
    -- Create UI
    CreateUI()
    
    -- Initial fruit scan
    updateFruits()
    
    -- Auto-update every 30 seconds
    while true do
        wait(30)
        updateFruits()
    end
end

-- Error handling
local function SafeInitialize()
    local success, err = pcall(function()
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        
        Players.LocalPlayer:WaitForChild("PlayerGui")
        wait(2) -- Additional delay for safety
        
        Initialize()
    end)
    
    if not success then
        warn("❌ Initialization Error:", err)
        
        -- Try again after delay
        wait(5)
        SafeInitialize()
    end
end

-- Start the system
print("=================================")
print("       Pet & Fruit System        ")
print("         Version 2.0.1           ")
print("=================================")

SafeInitialize()

-- Return the pet system for external access
return {
    PetSystem = _G.PetSystem,
    UpdateFruits = updateFruits,
    AdminTools = adminTools,
    GetScriptInfo = function()
        return {
            Name = "Pet & Fruit Display System",
            Version = "2.0.1",
            Author = "Original Script",
            Features = {
                "Pet System with UUID",
                "Fruit Weight Display", 
                "Admin Tools/Modules",
                "Draggable UI",
                "Rainbow Text Effects"
            }
        }
    end
}
