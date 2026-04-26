-- ==============================================================================
--                 ELITE HUB - SNIPER DUELS (PERFECT MOBILE EDITION)
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
_G.TeamCheck = false 
_G.WallCheck = false
_G.FOV = 100
_G.Smoothness = 1 -- 100% de Smoothness por padrão
_G.MaxDistance = 3000 -- Distância máxima 3D Aimbot

-- Sniper Prediction
_G.PredictionEnabled = true 
_G.BulletSpeed = 2500 
_G.BulletDrop = 0 

-- Hitbox
_G.HitboxEnabled = false
_G.HitboxSize = 5 
_G.HitboxTeamCheck = false 

-- Visuals
_G.ShowFOV = false
_G.ESP_Box = false        
_G.ESP_HealthBar = false
_G.ESP_Tracers = false
_G.ESP_Name = false      
_G.ESP_TeamCheck = false
_G.ESP_Skeleton = false 
_G.ESP_MaxDistance = 3000 -- Distância máxima 3D ESP

local ESP_Table = {}
local CachedTarget = nil
local CachedPredPos = nil

-- Variável Global para o Slider não crashar o mobile
local ActiveSlider = nil 

-- =============================================
--                 RAGE UI SYSTEM
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EliteHub_RageUI_Final"
ScreenGui.IgnoreGuiInset = true 
if syn and syn.protect_gui then ScreenGui.Parent = CoreGui elseif gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local Theme = {
    Bg = Color3.fromRGB(12, 12, 12),           
    TopBar = Color3.fromRGB(8, 8, 8),          
    Accent = Color3.fromRGB(230, 15, 15),      
    Text = Color3.fromRGB(220, 220, 220),      
    DarkText = Color3.fromRGB(150, 150, 150),  
    ToggleOff = Color3.fromRGB(20, 20, 20)     
}

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45); OpenButton.Position = UDim2.new(0.05, 0, 0.05, 0); OpenButton.BackgroundColor3 = Theme.Bg; OpenButton.Text = "EH"; OpenButton.TextColor3 = Theme.Accent; OpenButton.Font = Enum.Font.GothamBold; OpenButton.Visible = false; OpenButton.Active = true; OpenButton.Draggable = true; OpenButton.Parent = ScreenGui; Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 8); local OpenStroke = Instance.new("UIStroke", OpenButton); OpenStroke.Color = Theme.Accent; OpenStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350); MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175); MainFrame.BackgroundColor3 = Theme.Bg; MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Theme.TopBar; TopBar.Parent = MainFrame; Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)
local TopFix = Instance.new("Frame"); TopFix.Size = UDim2.new(1, 0, 0, 6); TopFix.Position = UDim2.new(0, 0, 1, -6); TopFix.BackgroundColor3 = Theme.TopBar; TopFix.BorderSizePixel = 0; TopFix.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 1, 0); CloseButton.Position = UDim2.new(1, -40, 0, 0); CloseButton.BackgroundTransparency = 1; CloseButton.Text = "X"; CloseButton.TextColor3 = Theme.DarkText; CloseButton.Font = Enum.Font.GothamBold; CloseButton.TextSize = 14; CloseButton.Parent = TopBar
CloseButton.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenButton.Visible = false end)

local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(0, 200, 1, 0); TabsContainer.Position = UDim2.new(0.5, -100, 0, 0); TabsContainer.BackgroundTransparency = 1; TabsContainer.Parent = TopBar
local TabsLayout = Instance.new("UIListLayout"); TabsLayout.Parent = TabsContainer; TabsLayout.FillDirection = Enum.FillDirection.Horizontal; TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center; TabsLayout.Padding = UDim.new(0, 15)

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -20, 1, -50); PageContainer.Position = UDim2.new(0, 10, 0, 45); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MainFrame

local Pages = {}; local TabButtons = {}

local function CreateTab(Name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 40, 0, 25); TabBtn.BackgroundTransparency = 1; TabBtn.Text = Name; TabBtn.TextColor3 = Theme.DarkText; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 12; TabBtn.Parent = TabsContainer
    local TabIndicator = Instance.new("Frame"); TabIndicator.Size = UDim2.new(1, 10, 1, 4); TabIndicator.Position = UDim2.new(0.5, 0, 0.5, 0); TabIndicator.AnchorPoint = Vector2.new(0.5, 0.5); TabIndicator.BackgroundColor3 = Theme.Accent; TabIndicator.ZIndex = 0; TabIndicator.Visible = false; TabIndicator.Parent = TabBtn; Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = PageContainer
    
    local LeftCol = Instance.new("ScrollingFrame")
    LeftCol.Size = UDim2.new(0.48, 0, 1, 0); LeftCol.BackgroundTransparency = 1; LeftCol.ScrollBarThickness = 0; LeftCol.Parent = Page
    local LeftLayout = Instance.new("UIListLayout"); LeftLayout.Parent = LeftCol; LeftLayout.Padding = UDim.new(0, 8)
    
    local RightCol = Instance.new("ScrollingFrame")
    RightCol.Size = UDim2.new(0.48, 0, 1, 0); RightCol.Position = UDim2.new(0.52, 0, 0, 0); RightCol.BackgroundTransparency = 1; RightCol.ScrollBarThickness = 0; RightCol.Parent = Page
    local RightLayout = Instance.new("UIListLayout"); RightLayout.Parent = RightCol; RightLayout.Padding = UDim.new(0, 8)

    LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() LeftCol.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 20) end)
    RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() RightCol.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 20) end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do b.TextColor3 = Theme.DarkText; b:FindFirstChildWhichIsA("Frame").Visible = false end
        Page.Visible = true; TabBtn.TextColor3 = Color3.new(1,1,1); TabIndicator.Visible = true
    end)

    table.insert(Pages, Page); table.insert(TabButtons, TabBtn)
    return LeftCol, RightCol
end

local function CreateSectionLabel(Parent, Text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 25); Lbl.BackgroundTransparency = 1; Lbl.Text = Text; Lbl.TextColor3 = Color3.new(1,1,1); Lbl.Font = Enum.Font.GothamBold; Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Parent
end

local function CreateToggle(Parent, Name, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 22); Frame.BackgroundTransparency = 1; Frame.Parent = Parent

    local Label = Instance.new("TextLabel")
    Label.Text = Name; Label.Size = UDim2.new(1, -30, 1, 0); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Theme.Text; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 16, 0, 16); Checkbox.Position = UDim2.new(1, -16, 0.5, -8); Checkbox.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff; Checkbox.Text = ""; Checkbox.Parent = Frame; Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)
    
    local CheckIcon = Instance.new("TextLabel")
    CheckIcon.Size = UDim2.new(1, 0, 1, 0); CheckIcon.BackgroundTransparency = 1; CheckIcon.Text = "✓"; CheckIcon.TextColor3 = Color3.new(1,1,1); CheckIcon.Font = Enum.Font.GothamBold; CheckIcon.TextSize = 12; CheckIcon.Visible = Default; CheckIcon.Parent = Checkbox

    local State = Default
    local function Fire()
        State = not State
        Checkbox.BackgroundColor3 = State and Theme.Accent or Theme.ToggleOff
        CheckIcon.Visible = State
        Callback(State)
    end
    Checkbox.MouseButton1Click:Connect(Fire)
end

-- =============================================
--      SLIDER SUPREMO (ARRASTE + TEXTBOX DE VALOR EXATO)
-- =============================================
local function CreateSlider(Parent, Name, Min, Max, Default, Callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35); Frame.BackgroundTransparency = 1; Frame.Parent = Parent

    local Label = Instance.new("TextLabel")
    Label.Text = Name; Label.Size = UDim2.new(0.7, 0, 0, 15); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Theme.Text; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame

    local ValInput = Instance.new("TextBox")
    ValInput.Text = tostring(Default); ValInput.Size = UDim2.new(0.3, 0, 0, 15); ValInput.Position = UDim2.new(0.7, 0, 0, 0); ValInput.BackgroundTransparency = 1; ValInput.Font = Enum.Font.Gotham; ValInput.TextColor3 = Theme.DarkText; ValInput.TextSize = 12; ValInput.TextXAlignment = Enum.TextXAlignment.Right; ValInput.ClearTextOnFocus = false; ValInput.Parent = Frame

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, 0, 0, 6); SliderBg.Position = UDim2.new(0, 0, 0, 22); SliderBg.BackgroundColor3 = Theme.ToggleOff; SliderBg.BorderSizePixel = 0; SliderBg.Parent = Frame; Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Fill.BorderSizePixel = 0; Fill.Parent = SliderBg; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1, 0, 1, 0); Trigger.BackgroundTransparency = 1; Trigger.Text = ""; Trigger.Parent = SliderBg

    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ActiveSlider = {Bg = SliderBg, Fill = Fill, Min = Min, Max = Max, ValLabel = ValInput, Callback = Callback}
        end
    end)

    ValInput.FocusLost:Connect(function()
        local inputVal = tonumber(ValInput.Text)
        if inputVal then
            local clampedVal = math.clamp(inputVal, Min, Max)
            local pct = (clampedVal - Min) / (Max - Min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            ValInput.Text = tostring(clampedVal)
            Callback(clampedVal)
        else
            local currentPct = Fill.Size.X.Scale
            local currentVal = math.floor(Min + ((Max - Min) * currentPct))
            ValInput.Text = tostring(currentVal)
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
        ActiveSlider.ValLabel.Text = tostring(Val)
        ActiveSlider.Callback(Val)
    end
end)


-- === TABS DA RAGE UI ===
local L1, R1 = CreateTab("AIM")
local L2, R2 = CreateTab("ESP")
local L3, R3 = CreateTab("MISC")

-- Aba Combat
CreateSectionLabel(L1, "Combat")
CreateToggle(L1, "Aimbot Rage", false, function(v) _G.AimbotEnabled = v end)
CreateToggle(L1, "Silent Aim", false, function(v) _G.SilentAimEnabled = v end)
CreateToggle(L1, "Aimbot Team Check", false, function(v) _G.TeamCheck = v end)
CreateToggle(L1, "Wall Check", false, function(v) _G.WallCheck = v end)
CreateSlider(L1, "Max Distance", 1, 3000, 3000, function(v) _G.MaxDistance = v end)
CreateSlider(L1, "Smoothness", 1, 100, 100, function(v) _G.Smoothness = v / 100 end)

CreateSectionLabel(R1, "Sniper Settings")
CreateToggle(R1, "Enable Prediction", true, function(v) _G.PredictionEnabled = v end)
CreateSlider(R1, "Bullet Speed", 100, 5000, 2500, function(v) _G.BulletSpeed = v end)
CreateSlider(R1, "Bullet Drop", 0, 100, 0, function(v) _G.BulletDrop = v / 10 end)

-- Aba Visuals
CreateSectionLabel(L2, "ESP Elements")
CreateToggle(L2, "Box", false, function(v) _G.ESP_Box = v end)
CreateToggle(L2, "Skeleton Stickman", false, function(v) _G.ESP_Skeleton = v end)
CreateToggle(L2, "HealthBar", false, function(v) _G.ESP_HealthBar = v end)
CreateToggle(L2, "Name", false, function(v) _G.ESP_Name = v end)
CreateToggle(L2, "Tracers", false, function(v) _G.ESP_Tracers = v end)
CreateToggle(L2, "ESP Team Check", false, function(v) _G.ESP_TeamCheck = v end)
CreateSlider(L2, "ESP Max Distance", 1, 3000, 3000, function(v) _G.ESP_MaxDistance = v end)

CreateSectionLabel(R2, "Environment")
CreateToggle(R2, "Enable FOV", false, function(v) _G.ShowFOV = v end)
CreateSlider(R2, "FOV Radius", 0, 500, 100, function(v) _G.FOV = v end)

-- Aba Misc
CreateSectionLabel(L3, "Hitbox Expander")
CreateToggle(L3, "Enable Hitbox", false, function(v) _G.HitboxEnabled = v end)
CreateToggle(L3, "Hitbox Team Check", false, function(v) _G.HitboxTeamCheck = v end)
CreateSlider(L3, "Hitbox Size", 1, 1000, 5, function(v) _G.HitboxSize = v end)

CreateSectionLabel(R3, "Magnet")
CreateToggle(R3, "Enable Magnet Kill", false, function(v) _G.MagnetKill = v end)
CreateToggle(R3, "Magnet Team Check", false, function(v) _G.MagnetTeamCheck = v end)

TabButtons[1].TextColor3 = Color3.new(1,1,1); TabButtons[1]:FindFirstChildWhichIsA("Frame").Visible = true; Pages[1].Visible = true

-- =============================================
--                 LÓGICA MATEMÁTICA GOD MODE
-- =============================================

local function GetAimbotPart(char)
    -- MIRA NO TRONCO/ROOTPART PARA ESTABILIDADE TOTAL
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function GetPing()
    local success, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    return success and (ping / 1000) or 0.1
end

local function GetPredictedPosition(Target)
    local TargetPart = GetAimbotPart(Target.Character)
    if not TargetPart then return Target.Character:GetPivot().Position end

    if not _G.PredictionEnabled then 
        return TargetPart.Position 
    end

    local Distance = (Camera.CFrame.Position - TargetPart.Position).Magnitude
    local TimeToTarget = Distance / _G.BulletSpeed
    local TotalTime = TimeToTarget + GetPing()
    
    local Velocity = TargetPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
    return TargetPart.Position + (Velocity * TotalTime)
end

local function GetClosestPlayer()
    local Target, MaxDist = nil, _G.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local AimPart = GetAimbotPart(v.Character)
            
            local IsTeammate = false
            if LocalPlayer.Team ~= nil and v.Team ~= nil then
                IsTeammate = (LocalPlayer.Team == v.Team)
            end

            if not AimPart or (_G.TeamCheck and IsTeammate) then continue end
            
            -- LÓGICA DE DISTÂNCIA MÁXIMA (3D) DO AIMBOT
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
--      SILENT AIM SUPREMO (HOOK TOTAL)
-- =============================================
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if _G.SilentAimEnabled and CachedTarget and CachedPredPos then
        if Method == "FireServer" or Method == "InvokeServer" then
            for i, arg in pairs(Args) do
                if typeof(arg) == "Vector3" then Args[i] = CachedPredPos
                elseif typeof(arg) == "CFrame" then Args[i] = CFrame.new(Camera.CFrame.Position, CachedPredPos)
                elseif typeof(arg) == "Instance" and arg:IsA("BasePart") then Args[i] = GetAimbotPart(CachedTarget.Character) end
            end
            return OldNamecall(self, unpack(Args))
        end
        if Method == "Raycast" and self == workspace then
            Args[2] = (CachedPredPos - Args[1]).Unit * Args[2].Magnitude
            return OldNamecall(self, unpack(Args))
        end
    end
    return OldNamecall(self, ...)
end)

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, Index)
    if self == Mouse and _G.SilentAimEnabled and CachedTarget and CachedPredPos then
        if Index == "Hit" then return CFrame.new(CachedPredPos)
        elseif Index == "Target" then return GetAimbotPart(CachedTarget.Character) end
    end
    return OldIndex(self, Index)
end)

-- =============================================
--                 VISUALS
-- =============================================
local function CreateESPObj(player)
    local drawings = {corners = {}, skeleton = {}}
    for i = 1, 8 do local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Color3.new(1,1,1); table.insert(drawings.corners, l) end
    for i = 1, 15 do local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Color3.new(1,1,1); table.insert(drawings.skeleton, l) end
    drawings.name = Drawing.new("Text"); drawings.name.Size = 16; drawings.name.Center = true; drawings.name.Outline = true; drawings.name.Color = Color3.new(1,1,1)
    drawings.hpOutline = Drawing.new("Square"); drawings.hpOutline.Filled = true; drawings.hpOutline.Color = Color3.new(0,0,0); drawings.hpOutline.Transparency = 0.5
    drawings.hpBar = Drawing.new("Square"); drawings.hpBar.Filled = true; drawings.hpBar.Color = Color3.fromRGB(40, 255, 40)
    drawings.tracer = Drawing.new("Line"); drawings.tracer.Thickness = 1; drawings.tracer.Color = Color3.new(1,1,1)
    ESP_Table[player] = drawings
end

local function UpdateESP()
    for player, drawings in pairs(ESP_Table) do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
            
            local Dist = (Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude
            local IsTeammate = (LocalPlayer.Team ~= nil and player.Team ~= nil and LocalPlayer.Team == player.Team)

            -- Esconde se estiver muito longe ou se for do seu time (e o ESP Team Check estiver ligado)
            if Dist > _G.ESP_MaxDistance or (_G.ESP_TeamCheck and IsTeammate) then
                for _, l in pairs(drawings.corners) do l.Visible = false end; for _, l in pairs(drawings.skeleton) do l.Visible = false end; drawings.name.Visible = false; drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false; drawings.tracer.Visible = false; continue
            end

            -- Stickman
            if _G.ESP_Skeleton then
                local H = char:FindFirstChild("Head"); local T = char:FindFirstChild("Torso"); local LA = char:FindFirstChild("Left Arm"); local RA = char:FindFirstChild("Right Arm"); local LL = char:FindFirstChild("Left Leg"); local RL = char:FindFirstChild("Right Leg")
                if H and T and LA and RA and LL and RL then
                    local pts = {H.Position, (T.CFrame * CFrame.new(0,1,0)).Position, (T.CFrame * CFrame.new(0,-1,0)).Position, (T.CFrame * CFrame.new(-1,0.5,0)).Position, (LA.CFrame * CFrame.new(0,-1,0)).Position, (T.CFrame * CFrame.new(1,0.5,0)).Position, (RA.CFrame * CFrame.new(0,-1,0)).Position, (T.CFrame * CFrame.new(-0.5,-1,0)).Position, (LL.CFrame * CFrame.new(0,-1,0)).Position, (T.CFrame * CFrame.new(0.5,-1,0)).Position, (RL.CFrame * CFrame.new(0,-1,0)).Position}
                    local sp = {}; for i=1, 11 do local p, v = Camera:WorldToViewportPoint(pts[i]); sp[i] = {Vector2.new(p.X, p.Y), v and p.Z > 0} end
                    local conns = {{1,2},{2,3},{2,4},{4,5},{2,6},{6,7},{3,8},{8,9},{3,10},{10,11}}
                    for i=1,10 do local l = drawings.skeleton[i]; local c = conns[i]; if sp[c[1]][2] and sp[c[2]][2] then l.From = sp[c[1]][1]; l.To = sp[c[2]][1]; l.Visible = true else l.Visible = false end end
                end
            else for _, l in pairs(drawings.skeleton) do l.Visible = false end end

            -- Box/Name/HP
            local HRP = char.HumanoidRootPart
            if HRP then
                local TopPos, TopVis = Camera:WorldToViewportPoint(HRP.Position + Vector3.new(0, 2.5, 0)); local BotPos, BotVis = Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 3, 0))
                if TopVis and BotVis then
                    local Height = math.abs(TopPos.Y - BotPos.Y); local Width = Height * 0.6; local TL = Vector2.new(TopPos.X - Width/2, TopPos.Y); local TR = Vector2.new(TopPos.X + Width/2, TopPos.Y); local BL = Vector2.new(TopPos.X - Width/2, BotPos.Y); local BR = Vector2.new(TopPos.X + Width/2, BotPos.Y); local Sz = Height * 0.2
                    if _G.ESP_Box then local L = drawings.corners; L[1].From = TL; L[1].To = TL + Vector2.new(Sz, 0); L[2].From = TL; L[2].To = TL + Vector2.new(0, Sz); L[3].From = TR; L[3].To = TR + Vector2.new(-Sz, 0); L[4].From = TR; L[4].To = TR + Vector2.new(0, Sz); L[5].From = BL; L[5].To = BL + Vector2.new(Sz, 0); L[6].From = BL; L[6].To = BL + Vector2.new(0, -Sz); L[7].From = BR; L[7].To = BR + Vector2.new(-Sz, 0); L[8].From = BR; L[8].To = BR + Vector2.new(0, -Sz); for _, v in pairs(L) do v.Visible = true end else for _, l in pairs(drawings.corners) do l.Visible = false end end
                    if _G.ESP_Name then drawings.name.Text = player.DisplayName; drawings.name.Position = Vector2.new(TopPos.X, TopPos.Y - 20); drawings.name.Visible = true else drawings.name.Visible = false end
                    if _G.ESP_HealthBar then local Pct = char.Humanoid.Health / char.Humanoid.MaxHealth; drawings.hpOutline.Size = Vector2.new(4, Height); drawings.hpOutline.Position = TL + Vector2.new(-6, 0); drawings.hpOutline.Visible = true; drawings.hpBar.Size = Vector2.new(2, Height * Pct); drawings.hpBar.Position = TL + Vector2.new(-5, Height * (1 - Pct)); drawings.hpBar.Visible = true else drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false end
                    if _G.ESP_Tracers then drawings.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); drawings.tracer.To = Vector2.new(TopPos.X, BotPos.Y); drawings.tracer.Visible = true else drawings.tracer.Visible = false end
                else for _, l in pairs(drawings.corners) do l.Visible = false end; drawings.name.Visible = false; drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false; drawings.tracer.Visible = false end
            end
        else for _, l in pairs(drawings.corners) do l.Visible = false end; for _, l in pairs(drawings.skeleton) do l.Visible = false end; drawings.name.Visible = false; drawings.hpOutline.Visible = false; drawings.hpBar.Visible = false; drawings.tracer.Visible = false end
    end
end

Players.PlayerAdded:Connect(CreateESPObj); Players.PlayerRemoving:Connect(function(p) if ESP_Table[p] then for _, v in pairs(ESP_Table[p]) do if type(v) == "table" then for _, d in pairs(v) do d:Remove() end else v:Remove() end end ESP_Table[p] = nil end end)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESPObj(p) end end

-- =============================================
--                 MAIN LOOP
-- =============================================
local FOVCircle = Drawing.new("Circle")

RunService:BindToRenderStep("EliteHubMain", Enum.RenderPriority.Camera.Value + 1, function()
    -- Círculo FOV Branco e Fino
    FOVCircle.Visible = _G.ShowFOV; FOVCircle.Radius = _G.FOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.NumSides = 64
    
    UpdateESP()

    CachedTarget = GetClosestPlayer()
    CachedPredPos = CachedTarget and GetPredictedPosition(CachedTarget) or nil

    if _G.MagnetKill and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local KP = Camera.CFrame * CFrame.new(0, 0, -12)
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                    
                    local IsTeammate = (LocalPlayer.Team ~= nil and v.Team ~= nil and LocalPlayer.Team == v.Team)
                    if (not _G.MagnetTeamCheck or not IsTeammate) and v.Character.Humanoid.Health > 0 and not v.Character.Humanoid.Sit then
                        v.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0); v.Character.HumanoidRootPart.CFrame = CFrame.new(KP.Position, Camera.CFrame.Position)
                    end
                end
            end
        end
    end

    -- HITBOX SAFE
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
                Box.Name = "EliteBox"; Box.Adornee = HitboxPart; Box.AlwaysOnTop = true; Box.Color3 = Theme.Accent; Box.Transparency = 0.5; Box.Size = HitboxPart.Size
            elseif HitboxPart then
                if HitboxPart:FindFirstChild("EliteBox") then HitboxPart.EliteBox:Destroy() end
                if HitboxPart.Size.X > 3 then 
                    HitboxPart.Size = Vector3.new(2, 2, 1); 
                    HitboxPart.Massless = false; 
                    HitboxPart.CanCollide = true; 
                    HitboxPart.Transparency = 0 
                end
            end
        end
    end

    -- PEQUENO PREDICT NA CÂMERA (0.135: GOD PREDICT PARA 100 DE SMOOTHNESS)
    if _G.AimbotEnabled and CachedTarget and CachedTarget.Character then
        local AimPart = GetAimbotPart(CachedTarget.Character)
        if AimPart then
            local CameraAimPos = AimPart.Position
            if _G.PredictionEnabled then
                local Velocity = AimPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
                CameraAimPos = AimPart.Position + (Velocity * 0.135) 
            end
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, CameraAimPos), _G.Smoothness)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input) if input.KeyCode == Enum.KeyCode.Insert then ToggleGUI() end end)
