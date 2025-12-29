-- 🐾 Pet System Mobile Edition - FIXED
-- التشغيل: loadstring(game:HttpGet("رابط_الباستبين"))()

-- ====================
-- 1. المكتبات الأساسية
-- ====================
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    Rayfield = {
        CreateWindow = function() 
            return {
                CreateTab = function() 
                    return {
                        CreateInput = function() end,
                        CreateSlider = function() end,
                        CreateButton = function() end,
                        CreateLabel = function() end,
                        CreateToggle = function() end
                    }
                end
            }
        end,
        Notify = function() print("Notification") end
    }
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- ====================
-- 2. النظام الأساسي
-- ====================
local PetSystem = {}
PetSystem.__index = PetSystem

function PetSystem.new()
    local self = setmetatable({}, PetSystem)
    self.Pets = {}
    self.PetUUIDs = {}
    self.PetModels = {}
    return self
end

function PetSystem:GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- ====================
-- 3. إنشاء حيوان (بدون AssetId مشكلة)
-- ====================
function PetSystem:CreateRealPet(player, petType, customWeight, customAge)
    -- توليد UUID
    local petUUID = self:GenerateUUID()
    
    -- بيانات الحيوان
    local petData = {
        Type = petType or "Capybara",
        UUID = petUUID,
        Owner = player.UserId,
        OwnerName = player.Name,
        Created = os.time(),
        Attributes = {
            Weight = customWeight or math.random(1, 100),
            Age = customAge or 0,
            Hunger = 100,
            Happiness = 100,
            Level = 1,
            Rarity = "Common",
            Value = math.random(100, 1000)
        }
    }
    
    -- تخزين البيانات
    self.Pets[petUUID] = petData
    
    if not self.PetUUIDs[player.UserId] then
        self.PetUUIDs[player.UserId] = {}
    end
    table.insert(self.PetUUIDs[player.UserId], petUUID)
    
    -- ====================
    -- 4. إنشاء نموذج بسيط (بدون AssetId)
    -- ====================
    local petModel = Instance.new("Model")
    petModel.Name = "Pet_" .. petUUID
    
    -- رأس الحيوان
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 2, 2)
    head.Shape = Enum.PartType.Ball
    head.BrickColor = BrickColor.new("Bright blue")
    head.Material = Enum.Material.Neon
    head.Parent = petModel
    
    -- جسم الحيوان
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(3, 2, 4)
    body.BrickColor = BrickColor.new("Bright blue")
    body.Parent = petModel
    
    -- Humanoid للحركة
    local humanoid = Instance.new("Humanoid")
    humanoid.WalkSpeed = 16
    humanoid.Parent = petModel
    
    -- PrimaryPart
    petModel.PrimaryPart = head
    
    -- تثبيت الجسم مع الرأس
    local weld = Instance.new("Weld")
    weld.Part0 = head
    weld.Part1 = body
    weld.C0 = CFrame.new(0, -1.5, 0)
    weld.Parent = head
    
    -- وضع النموذج في العالم
    petModel.Parent = workspace
    
    if player.Character and player.Character.PrimaryPart then
        petModel:SetPrimaryPartCFrame(
            player.Character.PrimaryPart.CFrame * CFrame.new(5, 0, 0)
        )
    end
    
    -- إضافة Attributes للنموذج
    petModel:SetAttribute("PetUUID", petUUID)
    petModel:SetAttribute("Owner", player.Name)
    petModel:SetAttribute("PetType", petType)
    petModel:SetAttribute("Weight", petData.Attributes.Weight)
    petModel:SetAttribute("Age", petData.Attributes.Age)
    
    -- ====================
    -- 5. الحركات البسيطة
    -- ====================
    spawn(function()
        while petModel and petModel.Parent do
            wait(1)
            -- حركة اهتزاز بسيطة
            head.CFrame = head.CFrame * CFrame.new(0, math.sin(tick())*0.1, 0)
        end
    end)
    
    -- ====================
    -- 6. نظام المتابعة البسيط
    -- ====================
    self.PetModels[petUUID] = petModel
    
    spawn(function()
        while petModel and petModel.Parent do
            wait(0.3)
            if player.Character and player.Character.PrimaryPart and humanoid then
                local targetPos = player.Character.PrimaryPart.Position
                local petPos = petModel.PrimaryPart.Position
                local distance = (targetPos - petPos).Magnitude
                
                if distance > 8 then
                    humanoid:MoveTo(targetPos + Vector3.new(3, 0, 3))
                end
            end
        end
    end)
    
    -- ====================
    -- 7. إنشاء Tool في الحقيبة
    -- ====================
    local petTool = Instance.new("Tool")
    petTool.Name = petType .. " [" .. petData.Attributes.Weight .. "KG] [Age:" .. petData.Attributes.Age .. "]"
    petTool.Parent = player.Backpack
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.BrickColor = BrickColor.new("Bright blue")
    handle.Parent = petTool
    
    petTool:SetAttribute("PET_UUID", petUUID)
    petTool:SetAttribute("PetType", petType)
    
    -- عند تفعيل الأداة
    petTool.Activated:Connect(function()
        if petModel and localPlayer.Character and localPlayer.Character.PrimaryPart then
            petModel:SetPrimaryPartCFrame(
                localPlayer.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -3)
            )
        end
    end)
    
    return petData
end

-- ====================
-- 8. واجهة المستخدم البسيطة
-- ====================
local Window = Rayfield:CreateWindow({
    Name = "🐾 نظام الحيوانات البسيط",
    LoadingTitle = "جاري التحميل...",
    ConfigurationSaving = { Enabled = false }
})

-- تبويب إنشاء الحيوان
local CreateTab = Window:CreateTab("إنشاء", nil)

local petName = "Capybara"
local petWeight = 50
local petAge = 0

CreateTab:CreateInput({
    Name = "اسم الحيوان",
    PlaceholderText = "أدخل الاسم",
    Callback = function(Text)
        petName = Text
    end
})

CreateTab:CreateSlider({
    Name = "الوزن",
    Range = {1, 200},
    Increment = 1,
    Suffix = "KG",
    CurrentValue = 50,
    Callback = function(Value)
        petWeight = Value
    end
})

CreateTab:CreateSlider({
    Name = "العمر",
    Range = {0, 100},
    Increment = 1,
    Suffix = "يوم",
    CurrentValue = 0,
    Callback = function(Value)
        petAge = Value
    end
})

CreateTab:CreateButton({
    Name = "🐾 إنشاء حيوان",
    Callback = function()
        if not localPlayer.Character then 
            print("❌ اللاعب ليس في العالم")
            return 
        end
        
        if not _G.PetSystem then
            _G.PetSystem = PetSystem.new()
        end
        
        local petData = _G.PetSystem:CreateRealPet(
            localPlayer, 
            petName, 
            petWeight, 
            petAge
        )
        
        print("✅ تم إنشاء حيوان:")
        print("   النوع:", petData.Type)
        print("   الوزن:", petData.Attributes.Weight)
        print("   العمر:", petData.Attributes.Age)
        print("   UUID:", petData.UUID)
        
        Rayfield:Notify({
            Title = "✅ تم الإنشاء",
            Content = petData.Type .. " - " .. petData.UUID,
            Duration = 5
        })
    end
})

-- تبويب إدارة
local ManageTab = Window:CreateTab("الإدارة", nil)

ManageTab:CreateButton({
    Name = "📋 عرض حيواناتي",
    Callback = function()
        local petSystem = _G.PetSystem
        if not petSystem then 
            print("❌ لا يوجد نظام حيوانات")
            return 
        end
        
        local pets = petSystem.PetUUIDs[localPlayer.UserId] or {}
        
        if #pets == 0 then
            print("📭 لا يوجد حيوانات")
        else
            print("===== حيواناتي =====")
            for _, uuid in pairs(pets) do
                local petData = petSystem.Pets[uuid]
                if petData then
                    print("🐾 " .. petData.Type)
                    print("   الوزن: " .. petData.Attributes.Weight .. "KG")
                    print("   العمر: " .. petData.Attributes.Age .. " يوم")
                    print("   UUID: " .. uuid)
                    print("-----------------")
                end
            end
        end
    end
})

-- تبويب الأوامر
local CmdTab = Window:CreateTab("أوامر", nil)

CmdTab:CreateButton({
    Name = "🔍 عرض _G.PetSystem",
    Callback = function()
        print("===== _G.PetSystem =====")
        if _G.PetSystem then
            for key, value in pairs(_G.PetSystem) do
                print(key, "=", type(value))
            end
        else
            print("❌ _G.PetSystem غير موجود")
        end
    end
})

CmdTab:CreateButton({
    Name = "🗑️ حذف كل الحيوانات",
    Callback = function()
        if _G.PetSystem then
            for uuid, model in pairs(_G.PetSystem.PetModels) do
                if model then
                    model:Destroy()
                end
            end
            _G.PetSystem.Pets = {}
            _G.PetSystem.PetUUIDs = {}
            _G.PetSystem.PetModels = {}
            print("✅ تم حذف كل الحيوانات")
        end
    end
})

-- ====================
-- 9. تعيين النظام في _G
-- ====================
_G.PetSystem = PetSystem.new()

print("=====================================")
print("✅ نظام الحيوانات المحمول جاهز!")
print("📱 تم تصميمه للعمل على الهاتف")
print("🔗 التشغيل: loadstring(game:HttpGet('...'))()")
print("=====================================")

-- إنشاء حيوان افتراضي تلقائي
wait(2)
if localPlayer.Character then
    local defaultPet = _G.PetSystem:CreateRealPet(localPlayer, "Capybara", 50, 0)
    print("🐾 تم إنشاء حيوان افتراضي:", defaultPet.UUID)
end
