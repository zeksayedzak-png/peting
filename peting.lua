-- 🚀 Pet System TEST - Mobile Delta
-- loadstring(game:HttpGet("YOUR_LINK"))()

print("=== بدء نظام الحيوانات ===")

-- 1. إنشاء النظام الأساسي
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
    return "PET_" .. math.random(10000, 99999) .. "_" .. os.time()
end

-- 2. دالة الإنشاء المباشرة (بدون مشاكل)
function PetSystem:CreateSimplePet(player, petName, weight, age)
    -- UUID
    local petUUID = self:GenerateUUID()
    
    -- بيانات الحيوان
    local petData = {
        Type = petName,
        UUID = petUUID,
        Owner = player.Name,
        Weight = weight,
        Age = age,
        Created = os.date("%H:%M:%S")
    }
    
    -- تخزين
    self.Pets[petUUID] = petData
    
    if not self.PetUUIDs[player.Name] then
        self.PetUUIDs[player.Name] = {}
    end
    table.insert(self.PetUUIDs[player.Name], petUUID)
    
    -- 3. **طريقة العرض البديلة - BillboardGui**
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetDisplay_" .. petUUID
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = billboard
    
    -- نص كبير يظهر المعلومات
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "🐾 " .. petName .. "\n⚖️ " .. weight .. "KG\n🎂 " .. age .. " يوم"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    -- إرفاق باللاعب
    if player.Character and player.Character:FindFirstChild("Head") then
        billboard.Adornee = player.Character.Head
        billboard.Parent = player.Character.Head
        print("✅ تم إرفاق شاشة الحيوان للاعب")
    else
        billboard.Parent = player.PlayerGui
        print("⚠️ الشاشة في واجهة اللاعب فقط")
    end
    
    -- 4. إنشاء "أداة وهمية" في الحقيبة
    spawn(function()
        wait(1)
        local petTool = Instance.new("Tool")
        petTool.Name = petName .. " [" .. weight .. "KG]"
        petTool.Parent = player.Backpack
        
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.BrickColor = BrickColor.new("Bright blue")
        handle.Parent = petTool
        
        print("✅ تم إضافة أداة في الحقيبة: " .. petTool.Name)
    end)
    
    -- 5. حفظ النموذج
    self.PetModels[petUUID] = billboard
    
    print("====================================")
    print("✅ تم إنشاء حيوان بنجاح!")
    print("🔤 الاسم: " .. petName)
    print("⚖️ الوزن: " .. weight .. "KG")
    print("🎂 العمر: " .. age .. " يوم")
    print("🆔 UUID: " .. petUUID)
    print("👤 المالك: " .. player.Name)
    print("====================================")
    
    return petData
end

-- 6. **تشغيل فوري عند التحميل**
local player = game.Players.LocalPlayer

-- إنشاء النظام
_G.PetSystem = PetSystem.new()

-- إنشاء حيوان تلقائي بعد 3 ثواني
wait(3)

print("\n🎬 جاري إنشاء حيوان تجريبي...")

local testPet = _G.PetSystem:CreateSimplePet(
    player,
    "Capybara الذهبي",
    75,
    5
)

-- 7. **واجهة تحكم بسيطة في الكونسول**
print("\n🔧 **أوامر التحكم:**")
print("1. _G.PetSystem:CreateSimplePet(player, 'اسم', وزن, عمر)")
print("2. _G.PetSystem.Pets - لعرض كل الحيوانات")
print("3. _G.PetSystem.PetUUIDs - لعرض حيوانات كل لاعب")

-- 8. **عرض الحيوانات الموجودة بعد 5 ثواني**
wait(5)

print("\n📊 **الحيوانات الحالية في النظام:**")
for uuid, data in pairs(_G.PetSystem.Pets) do
    print("• " .. data.Type .. " (" .. data.Weight .. "KG) - " .. data.Owner)
end

-- 9. **زر إنشاء سريع في الشاشة**
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0, 20)
button.BackgroundColor3 = Color3.new(0, 0.5, 1)
button.Text = "➕ إنشاء حيوان سريع"
button.TextScaled = true
button.Parent = screenGui

button.MouseButton1Click:Connect(function()
    local newPet = _G.PetSystem:CreateSimplePet(
        player,
        "حيوان سريع #" .. math.random(1, 100),
        math.random(10, 100),
        math.random(0, 10)
    )
    
    -- إشعار
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(0.5, -150, 0.5, -30)
    notif.BackgroundColor3 = Color3.new(0, 0, 0)
    notif.BackgroundTransparency = 0.3
    notif.Text = "✅ تم إنشاء: " .. newPet.Type
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.TextScaled = true
    notif.Parent = screenGui
    
    game.Debris:AddItem(notif, 3)
end)

print("\n🎉 **النظام جاهز!**")
print("• يوجد زر أزرق في أعلى الشاشة")
print("• اضغط عليه لإنشاء حيوانات جديدة")
print("• كل البيانات في _G.PetSystem")
