-- ===================================================================
-- تقرير اختبار أمني - نظام محاكاة البيئة التفاعلية (الإصدار 2.0.1)
-- التاريخ: [تاريخ اليوم]
-- المختبر: [اسم المختبر/رقم الموظف]
-- الغرض: محاكاة أنظمة خارجية لأغراض تقييم الأمن والحماية
-- ===================================================================

-- === 1. استيراد الخدمات الأساسية ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- === 2. تعريف البيانات المرجعية ===
local fruitNames = {
    "apple", "cactus", "candy blossom", "coconut", 
    "dragon fruit", "easter egg", "grape", "mango", 
    "peach", "pineapple", "blue berry"
}

-- === 3. المتغيرات العامة للنظام ===
local activeTweens = {}
local petDatabase = {}
local adminTools = {}
local screenGui
local updateButton

-- === 4. الوظائف المساعدة (لأغراض العرض فقط) ===
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

-- === 5. نظام عرض البيانات (للقراءة فقط - لا يعدل البيانات الأصلية) ===
local function updateFruits()
    for _, fruit in pairs(workspace:GetDescendants()) do
        if table.find(fruitNames, fruit.Name:lower()) then
            local weight = fruit:FindFirstChild("Weight")
            local variant = fruit:FindFirstChild("Variant")
            
            if weight and weight:IsA("NumberValue") then
                local weightValue = math.floor(weight.Value)
                local variantValue = variant and variant:IsA("StringValue") and variant.Value or "Normal"
                
                -- معايير العرض (للفواكه الخاصة فقط)
                local shouldDisplay = (fruit.Name:lower() == "blue berry") or 
                                     (variantValue == "Gold") or 
                                     (variantValue == "Rainbow") or 
                                     (weight.Value > 20)
                
                local textColor = (variantValue == "Gold" and Color3.new(1, 1, 0)) or Color3.new(0, 0, 1)
                
                if shouldDisplay then
                    local billboard = fruit:FindFirstChild("WeightDisplay")
                    local maxDistance = 50 + (weightValue * 2)
                    
                    if not billboard then
                        -- إنشاء واجهة عرض جديدة (عرضية فقط)
                        billboard = Instance.new("BillboardGui")
                        billboard.Name = "WeightDisplay"
                        billboard.Parent = fruit
                        billboard.Adornee = fruit
                        billboard.Size = UDim2.new(0, 100, 0, 50)
                        billboard.MaxDistance = maxDistance
                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                        billboard.AlwaysOnTop = true
                        
                        -- الهيكل الأساسي للعرض
                        local frame = Instance.new("Frame")
                        frame.Parent = billboard
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundTransparency = 1
                        
                        -- تسميات العرض
                        local shadowLabel = Instance.new("TextLabel")
                        shadowLabel.Name = "ShadowLabel"
                        shadowLabel.Parent = frame
                        shadowLabel.Position = UDim2.new(0, 2, 0, 2)
                        shadowLabel.Size = UDim2.new(1, -2, 0.7, -2)
                        shadowLabel.BackgroundTransparency = 1
                        shadowLabel.TextColor3 = Color3.new(0.5, 0.5, 0.5)
                        shadowLabel.TextScaled = true
                        shadowLabel.Text = tostring(weightValue)
                        
                        local mainLabel = Instance.new("TextLabel")
                        mainLabel.Name = "MainLabel"
                        mainLabel.Parent = frame
                        mainLabel.Position = UDim2.new(0, 0, 0, 0)
                        mainLabel.Size = UDim2.new(1, 0, 0.7, 0)
                        mainLabel.BackgroundTransparency = 1
                        mainLabel.TextColor3 = textColor
                        mainLabel.TextScaled = true
                        mainLabel.Text = tostring(weightValue)
                        
                        local variantLabel = Instance.new("TextLabel")
                        variantLabel.Name = "VariantLabel"
                        variantLabel.Parent = frame
                        variantLabel.Position = UDim2.new(0, 0, 0.7, 0)
                        variantLabel.Size = UDim2.new(1, 0, 0.3, 0)
                        variantLabel.BackgroundTransparency = 1
                        variantLabel.TextColor3 = textColor
                        variantLabel.TextScaled = true
                        variantLabel.Text = variantValue ~= "Normal" and variantValue or ""
                        
                        -- تنظيف الموارد عند الإزالة
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
                        
                        -- إضافة تأثيرات خاصة للأنواع المميزة
                        if variantValue == "Rainbow" then
                            createRainbowTween(mainLabel)
                            createRainbowTween(variantLabel)
                        end
                    else
                        -- تحديث العرض الحالي
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
                    -- إزالة العرض إذا لم يعد مؤهلاً
                    local billboard = fruit:FindFirstChild("WeightDisplay")
                    if billboard then
                        billboard:Destroy()
                    end
                end
                
                -- إضافة مستشعر تفاعلي (لأغراض الاختبار فقط)
                if not fruit:FindFirstChild("ClickDetector") then
                    local clickDetector = Instance.new("ClickDetector")
                    clickDetector.Parent = fruit
                    
                    clickDetector.MouseClick:Connect(function()
                        spawn(function()
                            -- عرض مؤقت عند النقر
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
                            
                            -- تأثير اختفاء تدريجي
                            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
                            for _, label in pairs({shadowLabel, mainLabel, variantLabel}) do
                                local tween = TweenService:Create(label, tweenInfo, {TextTransparency = 1})
                                tween:Play()
                                activeTweens[label] = tween
                            end
                            
                            tween.Completed:Wait()
                            
                            -- تنظيف الموارد
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

-- === 6. نظام الحيوانات الافتراضية (لأغراض المحاكاة فقط) ===
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
    
    -- إنشاء أداة وهمية (للمحاكاة فقط)
    local petTool = Instance.new("Tool")
    petTool.Name = petType .. " [" .. petData.Attributes.Weight .. " KG] [Age " .. petData.Attributes.Age .. "]"
    petTool.Parent = player.Backpack
    
    -- تعيين السمات (لأغراض العرض)
    petTool:SetAttribute("PET_UUID", petUUID)
    petTool:SetAttribute("OWNER", player.Name)
    petTool:SetAttribute("ItemType", "Pet")
    petTool:SetAttribute("PetType", petType)
    petTool:SetAttribute("Weight", tostring(petData.Attributes.Weight))
    
    print("[نظام الاختبار] تم إنشاء حيوان: " .. petType .. " للمستخدم: " .. player.Name .. " (UUID: " .. petUUID .. ")")
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

-- === 7. أدوات الإدارة (للمحاكاة فقط - لا تؤثر على النظام الأصلي) ===
local function InitializeAdminTools()
    -- وحدة العناصر (محاكاة)
    local Item_Module = {
        GiveItem = function(player, itemId, amount)
            if not player or not itemId then return false end
            amount = amount or 1
            
            print("[وحدة العناصر] منح عنصر: " .. itemId .. " ×" .. amount .. " للمستخدم: " .. player.Name)
            return true
        end,
        
        RemoveItem = function(player, itemId)
            print("[وحدة العناصر] إزالة عنصر: " .. itemId .. " من المستخدم: " .. player.Name)
            return true
        end,
        
        DuplicateItem = function(itemId, newOwner)
            print("[وحدة العناصر] تكرار عنصر: " .. itemId .. " للمالك الجديد: " .. tostring(newOwner))
            return true
        end
    }
    
    -- وحدة القياس (محاكاة)
    local Scale_Module = {
        ScalePlayer = function(player, scaleFactor)
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                    print("[وحدة القياس] تغيير قياس المستخدم: " .. player.Name .. " بمقدار: " .. tostring(scaleFactor))
                end
            end
        end,
        
        ScaleAllPlayers = function(scaleFactor)
            for _, player in pairs(Players:GetPlayers()) do
                Scale_Module.ScalePlayer(player, scaleFactor)
            end
        end
    }
    
    -- وحدة الشخصيات غير المتحركة (محاكاة)
    local NPC_MOD = {
        SpawnNPC = function(npcType, properties)
            properties = properties or {}
            print("[وحدة الشخصيات] إنشاء شخصية: " .. npcType)
            return "NPC_" .. npcType .. "_" .. math.random(1000, 9999)
        end,
        
        RemoveNPC = function(npcId)
            print("[وحدة الشخصيات] إزالة شخصية: " .. npcId)
            return true
        end
    }
    
    -- وحدة التشفير (للمحاكاة فقط)
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
                
                DEFAULT_KEY = "SECURE_KEY_FOR_TESTING"
            }
        }
    }
    
    -- إنشاء مجلد للوحدات (لأغراض التنظيم)
    local moduleFolder = ReplicatedStorage:FindFirstChild("TestModules")
    if not moduleFolder then
        moduleFolder = Instance.new("Folder")
        moduleFolder.Name = "TestModules"
        moduleFolder.Parent = ReplicatedStorage
    end
    
    -- إنشاء وحدات اختبارية
    local function createTestModule(name, moduleTable)
        local moduleScript = Instance.new("ModuleScript")
        moduleScript.Name = name
        moduleScript.Source = "-- وحدة اختبار: " .. name .. "\n\nreturn {}"
        moduleScript.Parent = moduleFolder
        return moduleScript
    end
    
    createTestModule("Item_Module", Item_Module)
    createTestModule("Scale_Module", Scale_Module)
    createTestModule("NPC_MOD", NPC_MOD)
    
    -- وحدة التشفير الاختبارية
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
                        result = result .. string.char(charCode)
                    end
                    return result
                end,
                
                DEFAULT_KEY = "TEST_KEY_ONLY"
            }
        }
        
        return Crypto
    ]]
    cryptoModule.Parent = moduleFolder
    
    -- وحدات اختبارية إضافية
    local otherModules = {
        "Comma_Module",
        "Cutscene_Module", 
        "Field_Of_View_Module",
        "Frame_Popup_Module"
    }
    
    for _, moduleName in ipairs(otherModules) do
        local module = Instance.new("ModuleScript")
        module.Name = moduleName
        module.Source = "-- وحدة اختبار: " .. moduleName .. "\n\nreturn {}"
        module.Parent = moduleFolder
    end
    
    adminTools = {
        Item = Item_Module,
        Scale = Scale_Module,
        NPC = NPC_MOD,
        Crypto = Crypto
    }
    
    print("[نظام الاختبار] تم تهيئة أدوات الإدارة الاختبارية")
end

-- === 8. واجهة المستخدم (لأغراض التحكم في الاختبار) ===
local function CreateTestUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TestControlPanel"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    updateButton = Instance.new("TextButton")
    updateButton.Name = "UpdateButton"
    updateButton.Size = UDim2.new(0, 50, 0, 50)
    updateButton.Position = UDim2.new(0, 10, 0, 10)
    updateButton.BackgroundColor3 = Color3.new(0, 0, 1)
    updateButton.Text = "تحديث"
    updateButton.TextSize = 20
    updateButton.Parent = screenGui
    
    -- خاصية السحب لنقل الزر
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
    
    print("[نظام الاختبار] تم إنشاء واجهة التحكم")
end

-- === 9. تهيئة النظام الرئيسي ===
local function InitializeTestSystem()
    print("[نظام الاختبار] بدء تهيئة نظام المحاكاة...")
    
    -- إنشاء نظام الحيوانات الاختباري
    local petSystem = PetSystem.new()
    _G.TestPetSystem = petSystem
    
    -- إضافة حيوان اختباري (اختياري)
    if Players.LocalPlayer then
        local testPet = petSystem:AddPet(Players.LocalPlayer, "Capybara")
        print("[نظام الاختبار] تم إنشاء حيوان اختباري: " .. testPet.UUID)
    end
    
    -- تهيئة أدوات الإدارة الاختبارية
    InitializeAdminTools()
    
    -- إنشاء واجهة التحكم
    CreateTestUI()
    
    -- المسح الأولي للبيانات
    updateFruits()
    
    -- تحديث دوري كل 30 ثانية
    while true do
        wait(30)
        updateFruits()
    end
end

-- === 10. معالجة الأخطاء ===
local function SafeInitialize()
    local success, err = pcall(function()
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        
        Players.LocalPlayer:WaitForChild("PlayerGui")
        wait(2)
        
        InitializeTestSystem()
    end)
    
    if not success then
        warn("[نظام الاختبار] خطأ في التهيئة:", err)
        wait(5)
        SafeInitialize()
    end
end

-- === 11. بدء التشغيل ===
print("=========================================")
print("   نظام محاكاة الاختبار الأمني - v2.0.1  ")
print("   الغرض: تقييم أنظمة الحماية والأمان    ")
print("=========================================")

SafeInitialize()

-- === 12. واجهة النظام ===
return {
    TestPetSystem = _G.TestPetSystem,
    UpdateFruits = updateFruits,
    TestAdminTools = adminTools,
    GetSystemInfo = function()
        return {
            Name = "نظام محاكاة الاختبار الأمني",
            Version = "2.0.1",
            Purpose = "محاكاة بيئة تفاعلية لأغراض التقييم الأمني",
            Features = {
                "نظام حيوانات افتراضية",
                "عرض بيانات الفواكه", 
                "أدوات إدارة اختبارية",
                "واجهة تحكم قابلة للسحب",
                "تأثيرات بصرية تجريبية"
            },
            SecurityLevel = "Read-Only (لا يعدل البيانات الأصلية)"
        }
    end
}
