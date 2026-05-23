-- ==============================================================================
--                 LOW HIGH ADMIN - VITALÍCIO (SNIPER DUELS / PRISON / MMV)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- =============================================
--                 CONFIGURAÇÕES Globais
-- =============================================
_G.AimbotEnabled = false
_G.SilentAimEnabled = false
_G.AimbotType = "Aimbot Legit"
_G.SilentAimType = "Silent Legit"
_G.TeamCheck = false 
_G.WallCheck = false
_G.Smoothness = 1 
_G.MaxDistance = 3000 
_G.PredictionEnabled = true 
_G.BulletSpeed = 2500 
_G.BulletDrop = 0 
_G.ShowFOV = false
_G.FOV = 100
_G.CurrentPing = 0.1

-- Hitbox
_G.HitboxEnabled = false
_G.HitboxSize = 5 
_G.HitboxTeamCheck = false 
_G.HitboxColor = Color3.fromRGB(255, 0, 0) 

-- Magnet
_G.MagnetKill = false
_G.MagnetTeamCheck = false
_G.MagnetFOVEnabled = false
_G.MagnetFOV = 100
_G.MagnetMaxDistance = 500

-- Visuals (ESP)
_G.ESP_Box = false        
_G.ESP_BoxType = "Box Corner" 
_G.ESP_FillBox = false 
_G.ESP_HealthBar = false
_G.ESP_HealthType = "Top" 
_G.ESP_Tracers = false
_G.ESP_LineType = "Bottom" 
_G.ESP_Name = false      
_G.ESP_Distance = false 
_G.ESP_TeamCheck = false
_G.ESP_Skeleton = false 
_G.ESP_Thickness = 8 
_G.ESP_MaxDistance = 3000 

local ESP_Table = {}
local CachedTarget = nil
local CachedAimbotPos = nil
local CachedSilentPos = nil
local CachedSilentPart = nil
local ActiveSlider = nil 

-- =============================================
--                 LOW HIGH UI SYSTEM 
-- =============================================
local guiName = "LowHigh_Admin_UI"
pcall(function()
    if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(guiName) then
        LocalPlayer.PlayerGui[guiName]:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 

local success = pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = CoreGui
    elseif gethui then ScreenGui.Parent = gethui()
    else ScreenGui.Parent = CoreGui end
end)
if not success or not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Cores
local Theme = {
    Bg = Color3.fromRGB(15, 15, 15),           
    Sidebar = Color3.fromRGB(10, 10, 10),          
    Accent = Color3.fromRGB(255, 0, 0), 
    Text = Color3.fromRGB(220, 220, 220),      
    DarkText = Color3.fromRGB(150, 150, 150),  
    ToggleOff = Color3.fromRGB(25, 25, 25)     
}

-- Botão de Abrir/Fechar (Mobile)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45); OpenButton.Position = UDim2.new(0.05, 0, 0.05, 0); OpenButton.BackgroundColor3 = Theme.Bg; OpenButton.Text = "LH"; OpenButton.TextColor3 = Theme.Accent; OpenButton.Font = Enum.Font.GothamBold; OpenButton.Visible = false; OpenButton.Active = true; OpenButton.Draggable = true; OpenButton.Parent = ScreenGui; Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 8); local OpenStroke = Instance.new("UIStroke", OpenButton); OpenStroke.Color = Theme.Accent; OpenStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 350); MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175); MainFrame.BackgroundColor3 = Theme.Bg; MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Botão Invisível para Fechar
local CloseButton = Instance.new("TextButton", MainFrame)
CloseButton.Size = UDim2.new(0, 30, 0, 30); CloseButton.Position = UDim2.new(1, -30, 0, 0); CloseButton.BackgroundTransparency = 1; CloseButton.Text = "X"; CloseButton.TextColor3 = Theme.DarkText; CloseButton.Font = Enum.Font.GothamBold; CloseButton.TextSize = 14; CloseButton.ZIndex = 10
CloseButton.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenButton.Visible = false end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 60, 1, 0); Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
local SidebarFix = Instance.new("Frame", Sidebar)
SidebarFix.Size = UDim2.new(0, 8, 1, 0); SidebarFix.Position = UDim2.new(1, -8, 0, 0); SidebarFix.BackgroundColor3 = Theme.Sidebar; SidebarFix.BorderSizePixel = 0

-- LOGO DO LOW HIGH ADMIN
local MyLogo = Instance.new("ImageLabel", Sidebar)
MyLogo.Size = UDim2.new(0, 60, 0, 60) 
MyLogo.Position = UDim2.new(0.5, -30, 0, 8) 
MyLogo.Image = "rbxthumb://type=Asset&id=125256544092304&w=150&h=150" 
MyLogo.BackgroundTransparency = 1
MyLogo.ScaleType = Enum.ScaleType.Fit
Instance.new("UICorner", MyLogo).CornerRadius = UDim.new(1, 0) 

local TabsContainer = Instance.new("Frame", Sidebar)
TabsContainer.Size = UDim2.new(1, 0, 1, -75); TabsContainer.Position = UDim2.new(0, 0, 0, 75); TabsContainer.BackgroundTransparency = 1
local TabsLayout = Instance.new("UIListLayout", TabsContainer); TabsLayout.FillDirection = Enum.FillDirection.Vertical; TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabsLayout.Padding = UDim.new(0, 15)

-- Header Textos
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, -70, 0, 60); Header.Position = UDim2.new(0, 70, 0, 0); Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Position = UDim2.new(0, 10, 0, 12); Title.Size = UDim2.new(0, 200, 0, 20)
Title.Text = "Low High Admin"; Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Position = UDim2.new(0, 10, 0, 32); SubTitle.Size = UDim2.new(0, 200, 0, 15)
SubTitle.Text = "improve your aim in game"; SubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SubTitle.Font = Enum.Font.Gotham; SubTitle.TextSize = 11; SubTitle.TextXAlignment = Enum.TextXAlignment.Left; SubTitle.BackgroundTransparency = 1

local UserLabel = Instance.new("TextLabel", Header)
UserLabel.Position = UDim2.new(1, -165, 0, 12); UserLabel.Size = UDim2.new(0, 150, 0, 20)
UserLabel.Text = LocalPlayer.DisplayName; UserLabel.TextColor3 = Theme.Accent
UserLabel.Font = Enum.Font.GothamBold; UserLabel.TextSize = 14; UserLabel.TextXAlignment = Enum.TextXAlignment.Right; UserLabel.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", Header)
StatusLabel.Position = UDim2.new(1, -165, 0, 32); StatusLabel.Size = UDim2.new(0, 150, 0, 15)
StatusLabel.Text = "Vitalício"; StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Gotham; StatusLabel.TextSize = 11; StatusLabel.TextXAlignment = Enum.TextXAlignment.Right; StatusLabel.BackgroundTransparency = 1

-- Page Container
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -80, 1, -70); PageContainer.Position = UDim2.new(0, 70, 0, 60); PageContainer.BackgroundTransparency = 1

local Pages = {}; local TabButtons = {}

local function CreateTab(Name)
    local TabBtn = Instance.new("TextButton", TabsContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.BackgroundTransparency = 1; TabBtn.Text = Name; TabBtn.TextColor3 = Theme.DarkText; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 11
    local TabIndicator = Instance.new("Frame", TabBtn); TabIndicator.Size = UDim2.new(0, 3, 0.6, 0); TabIndicator.Position = UDim2.new(0, 0, 0.2, 0); TabIndicator.BackgroundColor3 = Theme.Accent; TabIndicator.BorderSizePixel = 0; TabIndicator.Visible = false

    local Page = Instance.new("Frame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false
    
    local LeftCol = Instance.new("ScrollingFrame", Page)
    LeftCol.Size = UDim2.new(0.48, 0, 1, 0); LeftCol.BackgroundTransparency = 1; LeftCol.ScrollBarThickness = 0
    local LeftLayout = Instance.new("UIListLayout", LeftCol); LeftLayout.Padding = UDim.new(0, 8)
    
    local RightCol = Instance.new("ScrollingFrame", Page)
    RightCol.Size = UDim2.new(0.48, 0, 1, 0); RightCol.Position = UDim2.new(0.52, 0, 0, 0); RightCol.BackgroundTransparency = 1; RightCol.ScrollBarThickness = 0
    local RightLayout = Instance.new("UIListLayout", RightCol); RightLayout.Padding = UDim.new(0, 8)

    LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() LeftCol.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 120) end)
    RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() RightCol.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 120) end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do b.TextColor3 = Theme.DarkText; b:FindFirstChildWhichIsA("Frame").Visible = false end
        Page.Visible = true; TabBtn.TextColor3 = Color3.new(1,1,1); TabIndicator.Visible = true
    end)

    table.insert(Pages, Page); table.insert(TabButtons, TabBtn)
    return LeftCol, RightCol
end

-- =============================================
-- ELEMENTOS COM MARGEM DE SEGURANÇA E NOVO DESIGN
-- =============================================
local function CreateSectionLabel(Parent, Text)
    local Lbl = Instance.new("TextLabel", Parent)
    Lbl.Size = UDim2.new(1, -15, 0, 25); Lbl.BackgroundTransparency = 1; Lbl.Text = Text; 
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255); 
    Lbl.Font = Enum.Font.GothamBold; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function CreateToggle(Parent, Name, Default, Callback)
    local Frame = Instance.new("Frame", Parent)
    Frame.Size = UDim2.new(1, -15, 0, 22); Frame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Name; Label.Size = UDim2.new(1, -35, 1, 0); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Theme.Text; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left

    local Checkbox = Instance.new("TextButton", Frame)
    Checkbox.Size = UDim2.new(0, 16, 0, 16); Checkbox.Position = UDim2.new(1, -20, 0.5, -8); Checkbox.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff; Checkbox.Text = ""; Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)
    local CheckStroke = Instance.new("UIStroke", Checkbox); CheckStroke.Color = Theme.Accent; CheckStroke.Thickness = 1; CheckStroke.Transparency = 0.5
    
    local CheckIcon = Instance.new("TextLabel", Checkbox)
    CheckIcon.Size = UDim2.new(1, 0, 1, 0); CheckIcon.BackgroundTransparency = 1; CheckIcon.Text = "✓"; CheckIcon.TextColor3 = Color3.new(1,1,1); CheckIcon.Font = Enum.Font.GothamBold; CheckIcon.TextSize = 12; CheckIcon.Visible = Default

    local State = Default
    Checkbox.MouseButton1Click:Connect(function()
        State = not State
        Checkbox.BackgroundColor3 = State and Theme.Accent or Theme.ToggleOff
        CheckIcon.Visible = State
        Callback(State)
    end)
end

local function CreateDropdown(Parent, Name, Options, DefaultIndex, Callback)
    local Frame = Instance.new("Frame", Parent)
    Frame.Size = UDim2.new(1, -15, 0, 40); Frame.BackgroundTransparency = 1; Frame.ClipsDescendants = true 

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Name; Label.Size = UDim2.new(1, 0, 0, 16); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Theme.Text; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left

    local MainBtn = Instance.new("TextButton", Frame)
    MainBtn.Size = UDim2.new(1, 0, 0, 20); MainBtn.Position = UDim2.new(0, 0, 0, 18); MainBtn.BackgroundColor3 = Theme.ToggleOff; MainBtn.Text = "  " .. Options[DefaultIndex]; MainBtn.TextColor3 = Theme.Text; MainBtn.Font = Enum.Font.Gotham; MainBtn.TextSize = 10; MainBtn.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)
    local DropStroke = Instance.new("UIStroke", MainBtn); DropStroke.Color = Theme.Accent; DropStroke.Thickness = 1; DropStroke.Transparency = 0.7

    local Arrow = Instance.new("TextLabel", MainBtn)
    Arrow.Size = UDim2.new(0, 20, 1, 0); Arrow.Position = UDim2.new(1, -25, 0, 0); Arrow.BackgroundTransparency = 1; Arrow.Text = "▼"; Arrow.TextColor3 = Theme.DarkText; Arrow.Font = Enum.Font.GothamBold; Arrow.TextSize = 9

    local DropContainer = Instance.new("Frame", Frame)
    DropContainer.Size = UDim2.new(1, 0, 0, #Options * 20); DropContainer.Position = UDim2.new(0, 0, 0, 40); DropContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", DropContainer).CornerRadius = UDim.new(0, 4)
    local DropLayout = Instance.new("UIListLayout", DropContainer)

    local IsOpen = false
    MainBtn.MouseButton1Click:Connect(function()
        IsOpen = not IsOpen
        Arrow.Text = IsOpen and "▲" or "▼"
        Frame.Size = IsOpen and UDim2.new(1, -15, 0, 40 + (#Options * 20) + 2) or UDim2.new(1, -15, 0, 40)
    end)

    for i, opt in pairs(Options) do
        local OptBtn = Instance.new("TextButton", DropContainer)
        OptBtn.Size = UDim2.new(1, 0, 0, 20); OptBtn.BackgroundTransparency = 1; OptBtn.Text = "  " .. opt; OptBtn.TextColor3 = (i == DefaultIndex) and Theme.Accent or Theme.Text; OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 10; OptBtn.TextXAlignment = Enum.TextXAlignment.Left

        OptBtn.MouseButton1Click:Connect(function()
            IsOpen = false; Arrow.Text = "▼"; Frame.Size = UDim2.new(1, -15, 0, 40)
            MainBtn.Text = "  " .. opt
            for _, btn in pairs(DropContainer:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Theme.Text end end
            OptBtn.TextColor3 = Theme.Accent
            Callback(opt)
        end)
    end
end

-- NOVO ESTILO DE SLIDER (BARRA GROSSA)
local function CreateSlider(Parent, Name, Min, Max, Default, Callback, Suffix)
    Suffix = Suffix or "" 
    local Frame = Instance.new("Frame", Parent)
    Frame.Size = UDim2.new(1, -15, 0, 38); Frame.BackgroundTransparency = 1 

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Name; Label.Size = UDim2.new(0.7, 0, 0, 15); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Theme.Text; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValInput = Instance.new("TextBox", Frame)
    ValInput.Text = tostring(Default) .. Suffix; ValInput.Size = UDim2.new(0.3, 0, 0, 15); ValInput.Position = UDim2.new(0.7, -5, 0, 0); ValInput.BackgroundTransparency = 1; ValInput.Font = Enum.Font.Gotham; ValInput.TextColor3 = Theme.DarkText; ValInput.TextSize = 11; ValInput.TextXAlignment = Enum.TextXAlignment.Right; ValInput.ClearTextOnFocus = false

    local SliderBg = Instance.new("Frame", Frame)
    SliderBg.Size = UDim2.new(1, 0, 0, 10); 
    SliderBg.Position = UDim2.new(0, 0, 0, 22); 
    SliderBg.BackgroundColor3 = Color3.fromRGB(8, 8, 8); 
    SliderBg.BorderSizePixel = 0; 
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 3) 

    local Fill = Instance.new("Frame", SliderBg)
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0); 
    Fill.BackgroundColor3 = Theme.Accent; 
    Fill.BorderSizePixel = 0; 
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

    local Trigger = Instance.new("TextButton", SliderBg)
    Trigger.Size = UDim2.new(1, 0, 1, 0); Trigger.Position = UDim2.new(0,0,0,0); Trigger.BackgroundTransparency = 1; Trigger.Text = ""

    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ActiveSlider = {Bg = SliderBg, Fill = Fill, Min = Min, Max = Max, ValLabel = ValInput, Callback = Callback, Suffix = Suffix}
        end
    end)

    ValInput.FocusLost:Connect(function()
        local inputVal = tonumber(string.match(ValInput.Text, "%-?%d+")) or tonumber(ValInput.Text)
        if inputVal then
            local clampedVal = math.clamp(inputVal, Min, Max)
            local pct = (clampedVal - Min) / (Max - Min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            ValInput.Text = tostring(clampedVal) .. Suffix
            Callback(clampedVal)
        else
            local currentPct = Fill.Size.X.Scale
            local currentVal = math.floor(Min + ((Max - Min) * currentPct))
            ValInput.Text = tostring(currentVal) .. Suffix
        end
    end)
end

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ActiveSlider = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if ActiveSlider then
        local Pct = math.clamp((Mouse.X - ActiveSlider.Bg.AbsolutePosition.X) / ActiveSlider.Bg.AbsoluteSize.X, 0, 1)
        local Val = math.floor(ActiveSlider.Min + ((ActiveSlider.Max - ActiveSlider.Min) * Pct))
        ActiveSlider.Fill.Size = UDim2.new(Pct, 0, 1, 0)
        ActiveSlider.ValLabel.Text = tostring(Val) .. ActiveSlider.Suffix
        ActiveSlider.Callback(Val)
    end
end)

-- === TABS DA UI ===
local L1, R1 = CreateTab("AIM")
local L2, R2 = CreateTab("ESP")
local L3, R3 = CreateTab("MISC")

-- Aba Combat
CreateSectionLabel(L1, "Combat")
CreateToggle(L1, "Enable Aimbot", false, function(v) _G.AimbotEnabled = v end)
CreateToggle(L1, "Enable Silent Aim", false, function(v) _G.SilentAimEnabled = v end)
CreateToggle(L1, "Aimbot Team Check", false, function(v) _G.TeamCheck = v end)
CreateToggle(L1, "Wall Check", false, function(v) _G.WallCheck = v end)
CreateSlider(L1, "Max Distance", 1, 3000, 3000, function(v) _G.MaxDistance = v end)
CreateSlider(L1, "Smoothness", 1, 100, 100, function(v) _G.Smoothness = v / 100 end)

-- Dropdowns de Tipo adicionados no Aimbot Settings
CreateSectionLabel(R1, "Aim Settings")
CreateDropdown(R1, "Type Aimbot", {"Aimbot Legit", "Aimbot Rage"}, 1, function(val) _G.AimbotType = val end)
CreateDropdown(R1, "Type Silent Aim", {"Silent Legit", "Silent Rage"}, 1, function(val) _G.SilentAimType = val end)
CreateToggle(R1, "Enable Prediction", true, function(v) _G.PredictionEnabled = v end)
CreateSlider(R1, "Bullet Speed", 100, 5000, 2500, function(v) _G.BulletSpeed = v end)
CreateSlider(R1, "Bullet Drop", 0, 100, 0, function(v) _G.BulletDrop = v / 10 end)
CreateToggle(R1, "Enable FOV", false, function(v) _G.ShowFOV = v end)
CreateSlider(R1, "FOV Radius", 0, 500, 100, function(v) _G.FOV = v end)

-- Aba Visuals 
CreateSectionLabel(L2, "Esp Elements")
CreateToggle(L2, "Esp Box", false, function(v) _G.ESP_Box = v end)
CreateToggle(L2, "Esp Fill Box", false, function(v) _G.ESP_FillBox = v end) 
CreateToggle(L2, "Esp Skeleton", false, function(v) _G.ESP_Skeleton = v end)
CreateToggle(L2, "Esp Vida", false, function(v) _G.ESP_HealthBar = v end)
CreateToggle(L2, "Esp Name", false, function(v) _G.ESP_Name = v end)
CreateToggle(L2, "Esp Distance", false, function(v) _G.ESP_Distance = v end) 
CreateToggle(L2, "Esp Line", false, function(v) _G.ESP_Tracers = v end)
CreateToggle(L2, "Esp Team Check", false, function(v) _G.ESP_TeamCheck = v end)
CreateSlider(L2, "Esp Max Distance", 1, 3000, 3000, function(v) _G.ESP_MaxDistance = v end)

CreateSectionLabel(R2, "Esp Settings")
CreateDropdown(R2, "Type Box", {"Box Corner", "Box Normal"}, 1, function(val) _G.ESP_BoxType = val end)
CreateDropdown(R2, "Type Line", {"Bottom", "Top"}, 1, function(val) _G.ESP_LineType = val end)
CreateDropdown(R2, "Type Health", {"Top", "Bottom", "Left", "Right"}, 1, function(val) _G.ESP_HealthType = val end)
CreateSlider(R2, "Esp Thickness", 1, 15, 8, function(v) _G.ESP_Thickness = v end, "%")

-- Aba Misc
CreateSectionLabel(L3, "Hitbox Expander")
CreateToggle(L3, "Enable Hitbox", false, function(v) _G.HitboxEnabled = v end)
CreateToggle(L3, "Hitbox Team Check", false, function(v) _G.HitboxTeamCheck = v end)
CreateSlider(L3, "Hitbox Size", 1, 1000, 5, function(v) _G.HitboxSize = v end)

CreateSectionLabel(R3, "Magnet")
CreateToggle(R3, "Enable Magnet Kill", false, function(v) _G.MagnetKill = v end)
CreateToggle(R3, "Magnet Team Check", false, function(v) _G.MagnetTeamCheck = v end)
CreateToggle(R3, "Enable Magnet FOV", false, function(v) _G.MagnetFOVEnabled = v end)
CreateSlider(R3, "Magnet FOV Radius", 0, 500, 100, function(v) _G.MagnetFOV = v end)
CreateSlider(R3, "Magnet Max Dist", 1, 3000, 500, function(v) _G.MagnetMaxDistance = v end)

TabButtons[1].TextColor3 = Color3.new(1,1,1); TabButtons[1]:FindFirstChildWhichIsA("Frame").Visible = true; Pages[1].Visible = true

-- =============================================
--                 LÓGICA MATEMÁTICA
-- =============================================

local function GetTargetPart(char, aimType)
    if aimType == "Aimbot Rage" or aimType == "Silent Rage" then
        return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function GetPredictedPosition(Target, aimType)
    local TargetPart = GetTargetPart(Target.Character, aimType)
    if not TargetPart then return Target.Character:GetPivot().Position end
    if not _G.PredictionEnabled then return TargetPart.Position end

    local Origin = Camera.CFrame.Position
    local TargetPos = TargetPart.Position
    local Velocity = TargetPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
    
    local Distance = (Origin - TargetPos).Magnitude
    local TimeToTarget = Distance / _G.BulletSpeed
    local TotalTime = TimeToTarget + _G.CurrentPing
    
    local CompensationForce = Vector3.new(0, (_G.BulletDrop * 196.2), 0)
    return TargetPos + (Velocity * TotalTime) + (0.5 * CompensationForce * (TotalTime ^ 2))
end

local function GetClosestPlayer()
    local Target, MaxDist = nil, _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local AimPart = GetTargetPart(v.Character, "Aimbot Legit") 
            local IsTeammate = (LocalPlayer.Team ~= nil and v.Team ~= nil and LocalPlayer.Team == v.Team)

            if not AimPart or (_G.TeamCheck and IsTeammate) then continue end
            local RealDist = (Camera.CFrame.Position - AimPart.Position).Magnitude
            if RealDist > _G.MaxDistance then continue end
            
            local SP, OnS = Camera:WorldToScreenPoint(AimPart.Position)
            if OnS then
                local Dist = (Vector2.new(SP.X, SP.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if Dist < MaxDist then
                    if _G.WallCheck then
                        local RayP = RaycastParams.new()
                        RayP.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                        RayP.FilterType = Enum.RaycastFilterType.Exclude
                        local Res = workspace:Raycast(Camera.CFrame.Position, AimPart.Position - Camera.CFrame.Position, RayP)
                        if Res and Res.Instance:IsDescendantOf(v.Character) then Target = v; MaxDist = Dist end
                    else
                        Target = v; MaxDist = Dist
                    end
                end
            end
        end
    end
    return Target
end

-- =============================================
--                 VISUALS & INICIAÇÃO DO ESP
-- =============================================
local FOVCircle = Drawing.new("Circle")
local MagnetFOV = Drawing.new("Circle")

local function CreateESPObj(player)
    local drawings = {corners = {}, skeleton = {}}
    drawings.boxFill = Drawing.new("Square"); drawings.boxFill.Filled = true; drawings.boxFill.Color = Color3.new(0,0,0); drawings.boxFill.Transparency = 0.35; pcall(function() drawings.boxFill.ZIndex = 0 end)
    drawings.boxNormal = Drawing.new("Square"); drawings.boxNormal.Filled = false; drawings.boxNormal.Color = Color3.new(1,1,1); pcall(function() drawings.boxNormal.ZIndex = 2 end)
    for i = 1, 8 do local l = Drawing.new("Line"); l.Color = Color3.new(1,1,1); pcall(function() l.ZIndex = 2 end); table.insert(drawings.corners, l) end
    for i = 1, 15 do local l = Drawing.new("Line"); l.Color = Color3.new(1,1,1); pcall(function() l.ZIndex = 2 end); table.insert(drawings.skeleton, l) end
    drawings.name = Drawing.new("Text"); drawings.name.Size = 16; drawings.name.Center = true; drawings.name.Outline = true; drawings.name.Color = Color3.new(1,1,1); pcall(function() drawings.name.ZIndex = 3 end)
    drawings.distance = Drawing.new("Text"); drawings.distance.Size = 14; drawings.distance.Center = true; drawings.distance.Outline = true; drawings.distance.Color = Color3.new(1,1,1); pcall(function() drawings.distance.ZIndex = 3 end)
    drawings.hpOutline = Drawing.new("Square"); drawings.hpOutline.Filled = true; drawings.hpOutline.Color = Color3.new(0,0,0); drawings.hpOutline.Transparency = 0.5; pcall(function() drawings.hpOutline.ZIndex = 1 end)
    drawings.hpBar = Drawing.new("Square"); drawings.hpBar.Filled = true; drawings.hpBar.Color = Color3.fromRGB(40, 255, 40); pcall(function() drawings.hpBar.ZIndex = 2 end)
    drawings.tracer = Drawing.new("Line"); drawings.tracer.Color = Color3.new(1,1,1); pcall(function() drawings.tracer.ZIndex = 1 end)
    ESP_Table[player] = drawings
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESPObj(player) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then CreateESPObj(player) end
end)
Players.PlayerRemoving:Connect(function(player)
    if ESP_Table[player] then
        for _, l in pairs(ESP_Table[player].corners) do l:Remove() end
        for _, l in pairs(ESP_Table[player].skeleton) do l:Remove() end
        ESP_Table[player].boxNormal:Remove()
        ESP_Table[player].boxFill:Remove()
        ESP_Table[player].name:Remove()
        ESP_Table[player].distance:Remove()
        ESP_Table[player].hpOutline:Remove()
        ESP_Table[player].hpBar:Remove()
        ESP_Table[player].tracer:Remove()
        ESP_Table[player] = nil
    end
end)

RunService:BindToRenderStep("EliteHubMain", Enum.RenderPriority.Camera.Value + 1, function()
    local success, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    _G.CurrentPing = success and (ping / 1000) or 0.1

    -- FOV
    FOVCircle.Visible = _G.ShowFOV; FOVCircle.Radius = _G.FOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.NumSides = 64
    MagnetFOV.Visible = _G.MagnetFOVEnabled; MagnetFOV.Radius = _G.MagnetFOV; MagnetFOV.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); MagnetFOV.Color = Theme.Accent; MagnetFOV.Thickness = 1; MagnetFOV.Filled = false; MagnetFOV.NumSides = 64

    -- ESP
    for player, drawings in pairs(ESP_Table) do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
            local EnemyRoot = char.HumanoidRootPart
            local VisualDist = (Camera.CFrame.Position - EnemyRoot.Position).Magnitude
            local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local RealDist = MyRoot and (MyRoot.Position - EnemyRoot.Position).Magnitude or VisualDist
            local IsTeammate = (LocalPlayer.Team ~= nil and player.Team ~= nil and LocalPlayer.Team == player.Team)

            if VisualDist > _G.ESP_MaxDistance or (_G.ESP_TeamCheck and IsTeammate) then
                for _, l in pairs(drawings.corners) do l.Visible = false end; for _, l in pairs(drawings.skeleton) do l.Visible = false end; drawings.boxNormal.Visible = false; drawings.name.Visible = false; drawings.distance.Visible = false; drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false; drawings.tracer.Visible = false; drawings.boxFill.Visible = false; continue
            end

            local TextScale = math.clamp(16 - (VisualDist / 100), 8, 16)
            local TopPos, TopVis = Camera:WorldToViewportPoint(EnemyRoot.Position + Vector3.new(0, 3, 0)); local BotPos, BotVis = Camera:WorldToViewportPoint(EnemyRoot.Position - Vector3.new(0, 3.5, 0))
            if TopVis and BotVis then
                local Height = math.abs(TopPos.Y - BotPos.Y); local Width = Height * 0.6; local TL = Vector2.new(TopPos.X - Width/2, TopPos.Y); TR = Vector2.new(TopPos.X + Width/2, TopPos.Y); local BL = Vector2.new(TopPos.X - Width/2, BotPos.Y); local BR = Vector2.new(TopPos.X + Width/2, BotPos.Y); local Sz = Height * 0.2
                if _G.ESP_FillBox then drawings.boxFill.Size = Vector2.new(Width, Height); drawings.boxFill.Position = TL; drawings.boxFill.Visible = true else drawings.boxFill.Visible = false end
                if _G.ESP_Box then 
                    if _G.ESP_BoxType == "Box Corner" then
                        drawings.boxNormal.Visible = false; local L = drawings.corners; L[1].From = TL; L[1].To = TL + Vector2.new(Sz, 0); L[2].From = TL; L[2].To = TL + Vector2.new(0, Sz); L[3].From = TR; L[3].To = TR + Vector2.new(-Sz, 0); L[4].From = TR; L[4].To = TR + Vector2.new(0, Sz); L[5].From = BL; L[5].To = BL + Vector2.new(Sz, 0); L[6].From = BL; L[6].To = BL + Vector2.new(0, -Sz); L[7].From = BR; L[7].To = BR + Vector2.new(-Sz, 0); L[8].From = BR; L[8].To = BR + Vector2.new(0, -Sz); for _, v in pairs(L) do v.Thickness = _G.ESP_Thickness; v.Visible = true end
                    else for _, l in pairs(drawings.corners) do l.Visible = false end; drawings.boxNormal.Size = Vector2.new(Width, Height); drawings.boxNormal.Position = TL; drawings.boxNormal.Thickness = _G.ESP_Thickness; drawings.boxNormal.Visible = true end
                else for _, l in pairs(drawings.corners) do l.Visible = false end; drawings.boxNormal.Visible = false end
                if _G.ESP_Name then drawings.name.Size = TextScale; drawings.name.Text = player.DisplayName; drawings.name.Position = Vector2.new(TopPos.X, TopPos.Y - (20 * (TextScale/16))); drawings.name.Visible = true else drawings.name.Visible = false end
                if _G.ESP_Distance then drawings.distance.Size = TextScale; drawings.distance.Text = math.floor(RealDist / 2.8) .. "m"; drawings.distance.Position = Vector2.new(TopPos.X, BotPos.Y + (5 * (TextScale/16))); drawings.distance.Visible = true else drawings.distance.Visible = false end
                if _G.ESP_HealthBar then 
                    local Pct = char.Humanoid.Health / char.Humanoid.MaxHealth
                    if _G.ESP_HealthType == "Left" then drawings.hpOutline.Size = Vector2.new(4, Height + 2); drawings.hpOutline.Position = TL + Vector2.new(-6, -1); drawings.hpBar.Size = Vector2.new(2, Height * Pct); drawings.hpBar.Position = TL + Vector2.new(-5, Height * (1 - Pct)) elseif _G.ESP_HealthType == "Right" then drawings.hpOutline.Size = Vector2.new(4, Height + 2); drawings.hpOutline.Position = TR + Vector2.new(2, -1); drawings.hpBar.Size = Vector2.new(2, Height * Pct); drawings.hpBar.Position = TR + Vector2.new(3, Height * (1 - Pct)) elseif _G.ESP_HealthType == "Top" then drawings.hpOutline.Size = Vector2.new(Width + 2, 4); drawings.hpOutline.Position = TL + Vector2.new(-1, -6); drawings.hpBar.Size = Vector2.new(Width * Pct, 2); drawings.hpBar.Position = TL + Vector2.new(0, -5) elseif _G.ESP_HealthType == "Bottom" then drawings.hpOutline.Size = Vector2.new(Width + 2, 4); drawings.hpOutline.Position = BL + Vector2.new(-1, 2); drawings.hpBar.Size = Vector2.new(Width * Pct, 2); drawings.hpBar.Position = BL + Vector2.new(0, 3) end
                    drawings.hpOutline.Visible = true; drawings.hpBar.Visible = true 
                else drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false end
                if _G.ESP_Tracers then if _G.ESP_LineType == "Top" then drawings.tracer.From = Vector2.new(Camera.ViewportSize.X/2, 0); drawings.tracer.To = Vector2.new(TopPos.X, TopPos.Y) else drawings.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); drawings.tracer.To = Vector2.new(TopPos.X, BotPos.Y) end; drawings.tracer.Thickness = _G.ESP_Thickness; drawings.tracer.Visible = true else drawings.tracer.Visible = false end
                
                -- Skeleton
                if _G.ESP_Skeleton then
                    local H = char:FindFirstChild("Head"); local T = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"); local LA = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm"); local RA = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm"); local LL = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg"); local RL = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
                    if H and T and LA and RA and LL and RL then
                        local pts = {H.Position, (T.CFrame * CFrame.new(0,1,0)).Position, (T.CFrame * CFrame.new(0,-1,0)).Position, (T.CFrame * CFrame.new(-1,0.5,0)).Position, (LA.CFrame * CFrame.new(0,-1,0)).Position, (T.CFrame * CFrame.new(1,0.5,0)).Position, (RA.CFrame * CFrame.new(0,-1,0)).Position, (T.CFrame * CFrame.new(-0.5,-1,0)).Position, (LL.CFrame * CFrame.new(0,-1,0)).Position, (T.CFrame * CFrame.new(0.5,-1,0)).Position, (RL.CFrame * CFrame.new(0,-1,0)).Position}
                        local sp = {}; for i=1, 11 do local p, v = Camera:WorldToViewportPoint(pts[i]); sp[i] = {Vector2.new(p.X, p.Y), v and p.Z > 0} end
                        local conns = {{1,2},{2,3},{2,4},{4,5},{2,6},{6,7},{3,8},{8,9},{3,10},{10,11}}
                        for i=1,10 do local l = drawings.skeleton[i]; local c = conns[i]; if sp[c[1]][2] and sp[c[2]][2] then l.From = sp[c[1]][1]; l.To = sp[c[2]][1]; l.Visible = true else l.Visible = false end end
                        for i=11, 15 do if drawings.skeleton[i] then drawings.skeleton[i].Visible = false end end
                    else for _, l in pairs(drawings.skeleton) do l.Visible = false end end
                else for _, l in pairs(drawings.skeleton) do l.Visible = false end end

            else 
                for _, l in pairs(drawings.corners) do l.Visible = false end; for _, l in pairs(drawings.skeleton) do l.Visible = false end; drawings.boxNormal.Visible = false; drawings.name.Visible = false; drawings.distance.Visible = false; drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false; drawings.tracer.Visible = false; drawings.boxFill.Visible = false 
            end
        else 
            for _, l in pairs(drawings.corners) do l.Visible = false end; for _, l in pairs(drawings.skeleton) do l.Visible = false end; drawings.boxNormal.Visible = false; drawings.name.Visible = false; drawings.distance.Visible = false; drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false; drawings.tracer.Visible = false; drawings.boxFill.Visible = false 
        end
    end

    -- Magnet Logic NO WALL CHECK
    if _G.MagnetKill and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local KP = Camera.CFrame * CFrame.new(0, 0, -12)
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                    local IsTeammate = (LocalPlayer.Team ~= nil and v.Team ~= nil and LocalPlayer.Team == v.Team)
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    local screenPos, onScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                    local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude

                    if (not _G.MagnetTeamCheck or not IsTeammate) and v.Character.Humanoid.Health > 0 and not v.Character.Humanoid.Sit then
                        if dist <= _G.MagnetMaxDistance and (not _G.MagnetFOVEnabled or fovDist <= _G.MagnetFOV) then
                            for _, part in pairs(v.Character:GetChildren()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                            v.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                            v.Character.HumanoidRootPart.CFrame = CFrame.new(KP.Position, Camera.CFrame.Position)
                        end
                    end
                end
            end
        end
    end

    -- Hitbox
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
            local HitboxPart = v.Character:FindFirstChild("UpperTorso") or v.Character:FindFirstChild("Torso")
            local Hum = v.Character.Humanoid
            local IsTeammate = (LocalPlayer.Team ~= nil and v.Team ~= nil and LocalPlayer.Team == v.Team)
            if HitboxPart and _G.HitboxEnabled and Hum.Health > 0 and (not _G.HitboxTeamCheck or not IsTeammate) then
                local NewSize = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                for _, child in pairs(HitboxPart:GetChildren()) do if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then child:Destroy() end end
                HitboxPart.Size = NewSize; HitboxPart.Massless = true; HitboxPart.CanCollide = false; HitboxPart.Transparency = 1 
                local Box = HitboxPart:FindFirstChild("EliteBox") or Instance.new("BoxHandleAdornment", HitboxPart)
                Box.Name = "EliteBox"; Box.Adornee = HitboxPart; Box.AlwaysOnTop = true; Box.Color3 = _G.HitboxColor; Box.Transparency = 0.75; Box.Size = HitboxPart.Size
            elseif HitboxPart then
                if HitboxPart:FindFirstChild("EliteBox") then HitboxPart.EliteBox:Destroy() end
                if HitboxPart.Size.X > 3 then HitboxPart.Size = Vector3.new(2, 2, 1); HitboxPart.Massless = false; HitboxPart.CanCollide = true; HitboxPart.Transparency = 0 end
            end
        end
    end

    -- CACHE DO AIMBOT (CALCULA SÓ 1 VEZ POR FRAME)
    if _G.AimbotEnabled or _G.SilentAimEnabled then
        CachedTarget = GetClosestPlayer()
        if CachedTarget and CachedTarget.Character then
            if _G.AimbotEnabled then
                CachedAimbotPos = GetPredictedPosition(CachedTarget, _G.AimbotType)
            end
            if _G.SilentAimEnabled then
                CachedSilentPos = GetPredictedPosition(CachedTarget, _G.SilentAimType)
                CachedSilentPart = GetTargetPart(CachedTarget.Character, _G.SilentAimType)
            end
        else
            CachedAimbotPos = nil
            CachedSilentPos = nil
            CachedSilentPart = nil
        end
    else
        CachedTarget = nil
        CachedAimbotPos = nil
        CachedSilentPos = nil
        CachedSilentPart = nil
    end

    if _G.AimbotEnabled and CachedTarget and CachedAimbotPos then
        local TargetCF = CFrame.new(Camera.CFrame.Position, CachedAimbotPos)
        if _G.Smoothness >= 1 then 
            Camera.CFrame = TargetCF 
        else 
            Camera.CFrame = Camera.CFrame:Lerp(TargetCF, _G.Smoothness) 
        end
    end
end)

-- =============================================
-- HOOKS DE SILENT AIM (Otimizados: Só leem o cache)
-- =============================================
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if _G.SilentAimEnabled and CachedTarget and CachedSilentPos and CachedSilentPart then
        if Method == "FireServer" or Method == "InvokeServer" then
            for i, arg in pairs(Args) do
                if typeof(arg) == "Vector3" then Args[i] = CachedSilentPos
                elseif typeof(arg) == "CFrame" then Args[i] = CFrame.new(Camera.CFrame.Position, CachedSilentPos)
                elseif typeof(arg) == "Instance" and arg:IsA("BasePart") then Args[i] = CachedSilentPart end
            end
            return OldNamecall(self, unpack(Args))
        end
        if Method == "Raycast" and self == workspace then
            Args[2] = (CachedSilentPos - Args[1]).Unit * Args[2].Magnitude
            return OldNamecall(self, unpack(Args))
        end
    end
    return OldNamecall(self, ...)
end)

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, Index)
    if self == Mouse and _G.SilentAimEnabled and CachedTarget and CachedSilentPos and CachedSilentPart then
        if Index == "Hit" then return CFrame.new(CachedSilentPos)
        elseif Index == "Target" then return CachedSilentPart end
    end
    return OldIndex(self, Index)
end)
