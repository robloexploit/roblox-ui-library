-- =====================================================
-- Roblox UI Library (Single File, Modular)
-- Repo: robloexploit/roblox-ui-library
-- =====================================================

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")


local LocalPlayer = Players.LocalPlayer

-- =========================
-- UTILS
-- =========================
local function Tween(obj, time, props)
    TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

-- =========================
-- THEME
-- =========================
local Theme = {
    Background = Color3.fromRGB(18,18,18),
    Surface    = Color3.fromRGB(30,30,30),
    Accent     = Color3.fromRGB(0,170,255),
    Text       = Color3.fromRGB(235,235,235),
    SubText    = Color3.fromRGB(170,170,170)
}

function Theme:Set(custom)
    for k,v in pairs(custom) do
        if self[k] ~= nil then
            self[k] = v
        end
    end
end

-- =========================
-- COMPONENTS
-- =========================
local Components = {}

-- BUTTON
function Components.Button(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,42)
    btn.BackgroundColor3 = Theme.Accent
    btn.TextColor3 = Theme.Text
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = parent

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    btn.MouseEnter:Connect(function()
        Tween(btn, 0.15, {BackgroundColor3 = Theme.Accent:Lerp(Color3.new(1,1,1),0.1)})
    end)

    btn.MouseLeave:Connect(function()
        Tween(btn, 0.15, {BackgroundColor3 = Theme.Accent})
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- TOGGLE
function Components.Toggle(parent, text, default, callback)
    local state = default or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,42)
    btn.BackgroundColor3 = Theme.Surface
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = parent

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local function refresh()
        btn.Text = text .. (state and " : ON" or " : OFF")
        Tween(btn, 0.15, {
            BackgroundColor3 = state and Theme.Accent or Theme.Surface
        })
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if callback then callback(state) end
    end)

    refresh()
end

-- =========================
-- CORE : WINDOW
-- =========================
local Window = {}
Window.__index = Window
local function MakeDraggable(dragFrame, mainFrame)
    local dragging = false
    local dragStart
    local startPos

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Window.new(config)
    local self = setmetatable({}, Window)

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "RobloxUILibrary"
    self.Gui.ResetOnSpawn = false
    self.Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    self.Main = Instance.new("Frame")
    self.Main.Size = config.Size or UDim2.fromOffset(520,380)
    self.Main.BackgroundColor3 = Theme.Background
    self.Main.Parent = self.Gui
    self.Main.AnchorPoint = Vector2.new(0.5,0.5)
    self.Main.Position = UDim2.fromScale(0.5,0.5)
    self.Main.BorderSizePixel = 0

    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0,12)

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-20,0,40)
    title.Position = UDim2.new(0,10,0,0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "UI Library"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Left
    title.TextColor3 = Theme.Text
    title.Parent = self.Main

    -- Content
    self.Content = Instance.new("Frame")
    self.Content.Size = UDim2.new(1,-20,1,-50)
    self.Content.Position = UDim2.new(0,10,0,45)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Main

    return self
end

function Window:AddTab(name)
    local tab = Instance.new("Frame")
    tab.Size = UDim2.fromScale(1,1)
    tab.BackgroundTransparency = 1
    tab.Parent = self.Content

    local layout = Instance.new("UIListLayout", tab)
    layout.Padding = UDim.new(0,8)

    return {
        AddButton = function(_, text, cb)
            Components.Button(tab, text, cb)
        end,

        AddToggle = function(_, text, def, cb)
            Components.Toggle(tab, text, def, cb)
        end
    }
end

-- =========================
-- PUBLIC API
-- =========================
local Library = {}

function Library:CreateWindow(config)
    return Window.new(config or {})
end

function Library:SetTheme(theme)
    Theme:Set(theme)
end

return Library
