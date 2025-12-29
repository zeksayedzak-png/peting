-- 🐾 Pet System Mobile Edition
-- التشغيل: loadstring(game:HttpGet("رابط_الباستبين"))()

-- ====================
-- 1. المكتبات الأساسية
-- ====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
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
-- 3. إنشاء حيوان حقيقي
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
    -- 4. إنشاء النموذج 3D
    -- ====================
    local success, petModel = pcall(function()
        return game:GetObjects("rbxassetid://137696262122157")[1]
    end)
    
    if not success then
        warn("❌ فشل تحميل نموذج الحيوان")
        return petData
    end
    
    petModel.Name = "Pet_" .. petUUID
    petModel.Parent = workspace
    
    -- وضع بجانب اللاعب
    if player.Character and player.Character.PrimaryPart then
        petModel:SetPrimaryPartCFrame(
            player.Character.PrimaryPart.CFrame * CFrame.new(3, 0, 0)
        )
    end
    
    -- إضافة Attributes للنموذج
    petModel:SetAttribute("PetUUID", petUUID)
    petModel:SetAttribute("Owner", player.Name)
    petModel:SetAttribute("PetType", petType)
    petModel:SetAttribute("Weight", petData.Attributes.Weight)
    petModel:SetAttribute("Age", petData.Attributes.Age)
    
    -- ====================
    -- 5. إضافة الحركات
    -- ====================
    local humanoid = petModel:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://79220061824163"
        
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local animationTrack = animator:LoadAnimation(animation)
            animationTrack:Play()
        end
    end
    
    -- ====================
    -- 6. نظام المتابعة
    -- ====================
    self.PetModels[petUUID] = petModel
    
    -- تتبع اللاعب
    spawn(function()
        while petModel and petModel.Parent do
            wait(0.5)
            if player.Character and player.Character.PrimaryPart then
                local targetPos = player.Character.PrimaryPart.Position
                local petPos = petModel.PrimaryPart.Position
                
                -- حساب المسافة
                local distance = (targetPos - petPos).Magnitude
                
                if distance > 10 then
                    -- إذا كان بعيداً، ينتقل فوراً
                    petModel:SetPrimaryPartCFrame(
                        CFrame.new(targetPos + Vector3.new(3, 0, 0))
                    )
                elseif distance > 5 then
                    -- إذا كان قريباً، يمشي تجاهه
                    petModel.PrimaryPart.CFrame = CFrame.lookAt(
                        petPos,
                        targetPos
                    )
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
    
    petTool:SetAttribute("PET_UUID", petUUID)
    petTool:SetAttribute("PetType", petType)
    
    -- عند تفعيل الأداة
    petTool.Activated:Connect(function()
        if petModel then
            petModel:SetPrimaryPartCFrame(
                localPlayer.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -2)
            )
        end
    end)
    
    return petData
end

-- ====================
-- 8. واجهة المستخدم
-- ====================
local Window = Rayfield:CreateWindow({
    Name = "🐾 نظام الحيوانات الأليفة",
    LoadingTitle = "جاري تحميل النظام...",
    LoadingSubtitle = "Mobile Edition",
    ConfigurationSaving = { Enabled = false }
})

-- تبويب إنشاء الحيوان
local CreateTab = Window:CreateTab("إنشاء حيوان", nil)

local petName = "Capybara"
local petWeight = 50
local petAge = 0

CreateTab:CreateInput({
    Name = "اسم الحيوان",
    PlaceholderText = "Capybara",
    Callback = function(Text)
        petName = Text
    end
})

CreateTab:CreateSlider({
    Name = "الوزن (KG)",
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
    Suffix = "أيام",
    CurrentValue = 0,
    Callback = function(Value)
        petAge = Value
    end
})

CreateTab:CreateButton({
    Name = "🐾 إنشاء حيوان جديد",
    Callback = function()
        if not localPlayer.Character then return end
        
        local petSystem = _G.PetSystem or PetSystem.new()
        _G.PetSystem = petSystem
        
        local petData = petSystem:CreateRealPet(
            localPlayer, 
            petName, 
            petWeight, 
            petAge
        )
        
        Rayfield:Notify({
            Title = "✅ تم إنشاء الحيوان",
            Content = "UUID: " .. petData.UUID,
            Duration = 5
        })
    end
})

-- تبويب إدارة الحيوانات
local ManageTab = Window:CreateTab("حيواناتي", nil)

ManageTab:CreateButton({
    Name = "🔄 تحديث القائمة",
    Callback = function()
        local petSystem = _G.PetSystem
        if not petSystem then return end
        
        local pets = petSystem:GetPlayerPets(localPlayer)
        
        for _, uuid in pairs(pets) do
            local petData = petSystem.Pets[uuid]
            if petData then
                ManageTab:CreateLabel(
                    "🐾 " .. petData.Type .. 
                    " | الوزن: " .. petData.Attributes.Weight .. "KG" ..
                    " | العمر: " .. petData.Attributes.Age .. " يوم"
                )
            end
        end
    end
})

-- تبويب الأوامر
local CommandsTab = Window:CreateTab("أوامر", nil)

CommandsTab:CreateButton({
    Name = "📊 عرض كل الحيوانات في _G",
    Callback = function()
        local petSystem = _G.PetSystem
        if not petSystem then return end
        
        print("===== كل الحيوانات في النظام =====")
        for uuid, data in pairs(petSystem.Pets) do
            print("UUID:", uuid)
            print("النوع:", data.Type)
            print("المالك:", data.OwnerName)
            print("الوزن:", data.Attributes.Weight)
            print("العمر:", data.Attributes.Age)
            print("------------------------")
        end
    end
})

-- ====================
-- 9. النظام التلقائي
-- ====================
local autoSystem = Window:CreateTab("النظام التلقائي", nil)

local autoFollow = true
autoSystem:CreateToggle({
    Name = "👣 المتابعة التلقائية",
    CurrentValue = true,
    Callback = function(Value)
        autoFollow = Value
    end
})

-- تحديث سنوي تلقائي
spawn(function()
    while true do
        wait(60) -- كل دقيقة (يمكن تغييره لـ 86400 ليكون يومي)
        
        local petSystem = _G.PetSystem
        if petSystem then
            for uuid, petData in pairs(petSystem.Pets) do
                if petData.Owner == localPlayer.UserId then
                    petData.Attributes.Age = petData.Attributes.Age + 1
                    
                    -- تحديث النموذج
                    local model = petSystem.PetModels[uuid]
                    if model then
                        model:SetAttribute("Age", petData.Attributes.Age)
                    end
                end
            end
        end
    end
end)

-- ====================
-- 10. التنبيهات
-- ====================
Rayfield:Notify({
    Title = "🐾 نظام الحيوانات جاهز",
    Content = "يمكنك الآن إنشاء حيواناتك الأليفة!",
    Duration = 6
})

-- ====================
-- 11. تعيين النظام في _G
-- ====================
_G.PetSystem = PetSystem.new()

print("✅ نظام الحيوانات المحمول جاهز للاستخدام!")
print("📱 تم تصميمه للعمل على الهاتف")
print("🔗 التشغيل: loadstring(game:HttpGet('رابط_السكريبت'))()")
