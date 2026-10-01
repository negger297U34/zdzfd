local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,

    Window = nil,
    WindowContainer = nil,

    --// Search \\--
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    PreviousTab = nil,
    Tabs = {},
    TabButtons = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    --// Notifications \\--
    Notifications = {},
    NotifySide = "Right",
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Context Menu \\--
    ContextMenus = {}, 

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = true,
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Pop Out \\--
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(380, 240),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(240, 140, 60),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Code),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
    Scales = {},
    ScalesOffset = {},

    --// Mouse \\--
    OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
    ShowCursorBinding = string.sub(tostring({}), 10),

    --// Image Manager \\--
    ImageManager = CustomImageManager,

    --// Misc \\--
    Notify = nil, Toggle = nil -- we love luau lsp
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(380, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(380, 240)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Vector2.new(380, 240)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(475, 285),
        IconSize = UDim2.fromOffset(30, 30),

        --// Artefact mobile \\--
        SpinningLogo = true, -- remplace l'icône par le logo Artefact qui tourne
        SpinFPS = 20,
        AccentGlow = true, -- halo accent autour de la fenêtre
        ShowClock = true, -- heure en bas à gauche
        ShowExecutor = true, -- nom de l'exécuteur en bas à droite

        AutoShow = true,
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,

        --// Window Snapping \\--
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,

        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,

        CornerRadius = 4,
        NotifySide = "Right",
        ShowCustomCursor = true,

        Font = Enum.Font.Code,
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = true,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false,
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom",
        TabButtonsStyle = {
            Gap = 0,
            Padding = 0,
            CornerRadius = 0,
            Indicator = false,
            IndicatorWidth = 2,
            IndicatorHeight = 20,
        },
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,
        KeepDisabledValuePosition = false,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Resizable = true,

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local TouchSlop = 10
local function OnTap(Button: GuiButton, Callback: (...any) -> ...any)
    local Touch = nil

    Button.InputBegan:Connect(function(Input: InputObject)
        if Input.UserInputType ~= Enum.UserInputType.Touch or Input.UserInputState ~= Enum.UserInputState.Begin then
            return
        end

        local State = {
            Input = Input,
            Start = Input.Position,
            Moved = false,
            Ended = false,
            EndedAt = 0,
            Canvas = {},
        }

        local Parent = Button.Parent
        while Parent do
            if Parent:IsA("ScrollingFrame") then
                State.Canvas[Parent] = Parent.CanvasPosition
            end
            Parent = Parent.Parent
        end

        Touch = State

        local Changed
        Changed = Input.Changed:Connect(function()
            if (Input.Position - State.Start).Magnitude > TouchSlop then
                State.Moved = true
            end

            local InputState = Input.UserInputState
            if InputState == Enum.UserInputState.End or InputState == Enum.UserInputState.Cancel then
                State.Ended = true
                State.EndedAt = os.clock()
                Changed:Disconnect()
            end
        end)
    end)

    return Button.MouseButton1Click:Connect(function(...)
        local State = Touch
        Touch = nil

        if State and (not State.Ended or os.clock() - State.EndedAt < 0.35) then
            local Scrolled = State.Moved or (State.Input.Position - State.Start).Magnitude > TouchSlop

            if not Scrolled then
                for Frame, Position in State.Canvas do
                    if (Frame.CanvasPosition - Position).Magnitude > 2 then
                        Scrolled = true
                        break
                    end
                end
            end

            if Scrolled then
                return
            end
        end

        Callback(...)
    end)
end

local function IsDragMove(Input: InputObject, DragInput: InputObject?)
    if not IsHoverInput(Input) then
        return false
    end

    return Input.UserInputType ~= Enum.UserInputType.Touch or DragInput == nil or Input == DragInput
end

local function IsInputEnded(Input: InputObject)
    return Input.UserInputState == Enum.UserInputState.End or Input.UserInputState == Enum.UserInputState.Cancel
end

local function GetInputLocation(Input: InputObject): Vector2
    if Input.UserInputType == Enum.UserInputType.Touch then
        return Vector2.new(Input.Position.X, Input.Position.Y)
    end

    return Vector2.new(Mouse.X, Mouse.Y)
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function IsSequentialArray(Table: { [any]: any })
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end

    return true
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

--// Fuzzy Search \\--
local function FuzzyScore(Text: string, Search: string): (boolean, number)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    --// Fast path: literal substring match (also the best possible score) \\--
    local ExactIdx = Text:find(Search, 1, true)
    if ExactIdx then
        local PrevChar = ExactIdx > 1 and Text:sub(ExactIdx - 1, ExactIdx - 1) or ""
        local AtBoundary = ExactIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

        return true, 1e5 - ExactIdx + (AtBoundary and 500 or 0) + (Search:len() * 5)
    end

    --// Fallback: fuzzy, in-order, non-consecutive character matching \\--
    local TextLen, SearchLen = Text:len(), Search:len()
    if SearchLen > TextLen then
        return false, 0
    end

    local SearchIdx = 1
    local Score = 0
    local RunLength = 0
    local LastMatchIdx = 0

    for TextIdx = 1, TextLen do
        if SearchIdx > SearchLen then
            break
        end

        if Text:sub(TextIdx, TextIdx) == Search:sub(SearchIdx, SearchIdx) then
            local PrevChar = TextIdx > 1 and Text:sub(TextIdx - 1, TextIdx - 1) or ""
            local AtBoundary = TextIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

            RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
            Score += 1 + (AtBoundary and 6 or 0) + math.min(RunLength - 1, 5) * 3

            LastMatchIdx = TextIdx
            SearchIdx += 1
        end
    end

    if SearchIdx <= SearchLen then
        return false, 0 --// Not every Search character was found, in order
    end

    Score -= (LastMatchIdx - SearchLen) * 0.05 --// Slightly favour tighter matches
    return true, Score
end

local function NormalizeSearch(Search: string): string
    return (Search:gsub("%s+", ""))
end

local function TryFuzzyMatch(Text: any, Search: string): (boolean, number)
    if typeof(Text) ~= "string" or Text == "" then
        return false, 0
    end

    return FuzzyScore(Text:lower(), Search)
end

local function FuzzyMatchScore(Text: any, Search: string): number
    if typeof(Text) ~= "string" or Text == "" then
        return 0
    end

    local Normalized = NormalizeSearch(Text:lower())
    local Matched, Score = FuzzyScore(Normalized, Search)
    if not Matched then
        return 0
    end

    if Normalized == Search then
        Score += 1000
    end

    return Score
end

local function MatchesSearch(ElementInfo, Search: string, ForceMatch: boolean?): boolean
    if not ElementInfo then
        return false
    end
    if ForceMatch then
        return true
    end

    if TryFuzzyMatch(ElementInfo.Text, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Tooltip, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.DisabledTooltip, Search) then
        return true
    end

    --// Optional: search inside Dropdown value lists, so e.g. searching a specific option name reveals the Dropdown that contains it \\--
    if typeof(ElementInfo.Values) == "table" then
        local Checked = 0
        for Key, Value in ElementInfo.Values do
            Checked += 1
            if Checked > 200 then
                break
            end

            if TryFuzzyMatch(Value, Search) or (typeof(Value) ~= "string" and TryFuzzyMatch(tostring(Value), Search)) then
                return true
            end
            if typeof(Key) == "string" and TryFuzzyMatch(Key, Search) then
                return true
            end
        end
    end

    return false
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

function Library:UpdateAddons(Parent)
    if not Parent or not Parent.Addons then
        return
    end

    for _, Addon in Parent.Addons do
        Addon:Update()
    end
end

local function CheckDepbox(Box, Search, ForceVisible: boolean?)
    local VisibleElements = 0
    local BestScore = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Base.Visible = false
            end
            if MatchesSearch(ElementInfo.SubButton, Search, ForceVisible) and ElementInfo.SubButton.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
            BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        local DepVisible, DepScore = CheckDepbox(Depbox, Search, ForceVisible)
        VisibleElements += DepVisible
        if DepScore > BestScore then
            BestScore = DepScore
        end
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements, BestScore
end
local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    Box:Resize()
    Box.Holder.Visible = true

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        RestoreDepbox(Depbox)
    end
end

--// Pop Out
function SyncPopOutVisibility(Box: any)
    if not Box.PopOutFloat then
        return
    end

    Box.PopOutFloat.Visible = Box.BoxHolder.Visible ~= false and Box.Visible ~= false
end

local function DimPopOutClone(Root: GuiObject)
    for _, Descendant in Root:QueryDescendants("TextLabel, TextButton, TextBox") do
        Descendant.TextTransparency = math.max(Descendant.TextTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("ImageLabel, ImageButton") do
        Descendant.ImageTransparency = math.max(Descendant.ImageTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("GuiButton") do
        Descendant.Active = false
        Descendant.AutoButtonColor = false
    end
end

local function IsScreenPointOutsideMain(Point: Vector2): boolean
    local MainFrame = Library.Window and Library.Window.MainFrame
    if not MainFrame or not Library.Toggled or not MainFrame.Visible then
        return true
    end

    return not Library:MouseIsOverFrame(MainFrame, Point)
end

local function GetTopFloatAt(Point: Vector2): GuiObject?
    local Best: GuiObject? = nil
    local BestOrder = -math.huge
    local Floats = Library.Floats

    for _, Surface in Library.DraggableElements do
        if not Surface or not Surface.Parent or not Surface.Visible then
            continue
        end
        if Floats and Surface.Parent ~= Floats then
            continue
        end
        if not Library:MouseIsOverFrame(Surface, Point) then
            continue
        end

        local SiblingIndex = tonumber(select(2, pcall(function() return Surface:GetSiblingIndex() end))) or 0
        local Order = Surface.ZIndex * 100000 + SiblingIndex
        if Order >= BestOrder then
            BestOrder = Order
            Best = Surface
        end
    end

    return Best
end

local function GetPopOutBodyMaxHeight(Box: any, Reserved: number): number
    local Float = Box.PopOutFloat
    local ScreenGui = Library.ScreenGui
    if not Float or not ScreenGui then
        return math.huge
    end

    local Gap = 12 * Library.DPIScale
    local MaxBottom = ScreenGui.AbsolutePosition.Y + ScreenGui.AbsoluteSize.Y - Gap
    local Available = math.min(MaxBottom - Float.AbsolutePosition.Y, ScreenGui.AbsoluteSize.Y * 0.9)
    local ScreenMax = math.max(0, Available / Library.DPIScale - Reserved)

    local CustomMax = Box.PopOutMaxHeight
    if typeof(CustomMax) == "number" then
        return math.min(ScreenMax, math.max(0, CustomMax))
    end

    return ScreenMax
end

--// Search
local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return false, 0
    end

    local HasVisible = false
    local BestScore = 0

    --// If the Tab itself matches Search (by name/description), don't filter out its contents -- pull everything in the Tab along with it \\--
    local TabMatches = TryFuzzyMatch(Tab.Name, Search) or TryFuzzyMatch(Tab.Description, Search)
    BestScore = math.max(BestScore, FuzzyMatchScore(Tab.Name, Search), FuzzyMatchScore(Tab.Description, Search))

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        --// Optional: matching the Groupbox's own name/description reveals every element inside it, without needing each one to match too
        local GroupboxMatches = TabMatches or (TryFuzzyMatch(Groupbox.Name, Search) or TryFuzzyMatch(Groupbox.Description, Search))
        BestScore = math.max(BestScore, FuzzyMatchScore(Groupbox.Name, Search), FuzzyMatchScore(Groupbox.Description, Search))

        local VisibleElements = 0
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                --// Check if any of the Buttons Name matches with Search
                local Visible = false
                if MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
                else
                    ElementInfo.Base.Visible = false
                end

                if MatchesSearch(ElementInfo.SubButton, Search, GroupboxMatches) and ElementInfo.SubButton.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
                else
                    ElementInfo.SubButton.Base.Visible = false
                end

                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text and MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            local DepVisible, DepScore = CheckDepbox(Depbox, Search, GroupboxMatches)
            VisibleElements += DepVisible
            if DepScore > BestScore then
                BestScore = DepScore
            end
        end

        --// Update Groupbox Size and Visibility if found any element
        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}
        local SubTabScores = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            --// Optional: matching a Tabbox sub-tab's own name reveals every element inside it, without needing each one to match too
            local SubTabMatches = TabMatches or TryFuzzyMatch(SubTab.Name, Search)
            local SubScore = FuzzyMatchScore(SubTab.Name, Search)
            BestScore = math.max(BestScore, SubScore)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    --// Check if any of the Buttons Name matches with Search
                    local Visible = false
                    if MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.Base.Visible = false
                    end

                    if MatchesSearch(ElementInfo.SubButton, Search, SubTabMatches) and ElementInfo.SubButton.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.SubButton.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end

                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text and MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                    local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                    SubScore = math.max(SubScore, ElementScore)
                    BestScore = math.max(BestScore, ElementScore)
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                local DepVisible, DepScore = CheckDepbox(Depbox, Search, SubTabMatches)
                VisibleElements[SubTab] += DepVisible
                SubScore = math.max(SubScore, DepScore)
                BestScore = math.max(BestScore, DepScore)
            end

            SubTabScores[SubTab] = SubScore
        end

        local BestSubTab = nil
        local BestSubScore = -1

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                local SubScore = SubTabScores[SubTab] or 0
                if SubScore > BestSubScore then
                    BestSubScore = SubScore
                    BestSubTab = SubTab
                end
            end
        end

        local ActiveSubTab = Tabbox.ActiveTab
        local ActiveSubVisible = ActiveSubTab and (VisibleElements[ActiveSubTab] or 0) > 0
        local ActiveSubScore = ActiveSubTab and (SubTabScores[ActiveSubTab] or -1) or -1

        if ActiveSubVisible and ActiveSubScore >= BestSubScore then
            ActiveSubTab:Resize()
        elseif BestSubTab then
            BestSubTab:Show()
        end

        --// Update Tabbox Visibility if any visible
        Tabbox.BoxHolder.Visible = VisibleTabs > 0
        SyncPopOutVisibility(Tabbox)
    end

    return HasVisible, BestScore
end
local function ResetTab(Tab)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            RestoreDepbox(Depbox)
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
        SyncPopOutVisibility(Tabbox)
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText

    local TabsToSearch = {}
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and not Tab.IsKeyTab then
            table.insert(TabsToSearch, Tab)
        end
    end

    for _, Tab in TabsToSearch do
        ResetTab(Tab)
    end

    local Search = NormalizeSearch(SearchText:lower())
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local BestTab = nil
    local BestScore = -1
    local ActiveScore = -1
    local ActiveHasVisible = false

    for _, Tab in TabsToSearch do
        local HasVisible, Score = ApplySearchToTab(Tab, Search)
        if not HasVisible then
            continue
        end

        if Tab == Library.ActiveTab then
            ActiveHasVisible = true
            ActiveScore = Score
        end
        if Score > BestScore then
            BestScore = Score
            BestTab = Tab
        end
    end

    if not Library.GlobalSearch then
        for _, Tab in TabsToSearch do
            if Tab ~= BestTab then
                ResetTab(Tab)
            end
        end
    end

    local StayOnActive = ActiveHasVisible and ActiveScore >= BestScore
    if StayOnActive and Library.ActiveTab then
        Library.ActiveTab:RefreshSides()
    elseif BestTab then
        local SearchMarker = SearchText
        task.defer(function()
            if Library.SearchText ~= SearchMarker then
                return
            end

            if Library.ActiveTab ~= BestTab then
                BestTab:Show()
            elseif Library.ActiveTab then
                Library.ActiveTab:RefreshSides()
            end
        end)
    end

    Library.LastSearchTab = nil
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale: number)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
            Option:RefreshPool()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon: string, IncludeAssetId: boolean)
    return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons = false
local Icons: IconModule | nil = nil

function Library:GetIcon(IconName: string)
    if not FetchIcons or not Icons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end

    return Icon
end

function Library:GetCustomIcon(IconName: string): any
    if not IconName then
        return nil
    end

    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    if IsCustomAssetIcon(IconName, true) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif IsValidCustomIcon(IconName) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    return nil
end

function Library:ApplyLucideIcon(ImageGui: any, Icon: any, Rotation: number?)
    if not ImageGui or not Icon then
        return
    end

    if not (ImageGui:IsA("ImageLabel") or ImageGui:IsA("ImageButton")) then
        return
    end

    ImageGui.Image = Icon.Url or ImageGui.Image
    ImageGui.ImageRectOffset = Icon.ImageRectOffset or ImageGui.ImageRectOffset 
    ImageGui.ImageRectSize = Icon.ImageRectSize or ImageGui.ImageRectSize
    ImageGui.Rotation = Rotation or ImageGui.Rotation
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(Gui: ScreenGui, Enabled: boolean)
    if not Gui then
        return
    end

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Gui, "OnTopOfCoreBlur", Enabled)
        elseif setscriptable then
            setscriptable(Gui, "OnTopOfCoreBlur", true)
            Gui.OnTopOfCoreBlur = Enabled
            setscriptable(Gui, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "Obsidian",
    DisplayOrder = 998,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    task.defer(function()
        if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
            return
        end

        Library:RemoveFromRegistry(Instance)
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Floats and Overlays
local Floats = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 10,
    Active = false,
    Parent = ScreenGui,
})

local Overlay = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
    Active = false,
    Parent = ScreenGui,
})

Library.Floats = Floats
Library.Overlay = Overlay

--// Cursor
local Cursor
local CursorCross
local InnerCross = {}
local CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(1, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })

    CursorCross = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        Parent = Cursor,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -2, 0, 1),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 1, 1, -2),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    CursorCustomImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 3,
        Visible = false,
        Parent = Cursor,
    })
end

local function RestoreMouseIcon()
    pcall(function() 
        RunService:UnbindFromRenderStep(Library.ShowCursorBinding)
        RunService.RenderStepped:Wait()
    end)

    UserInputService.MouseIconEnabled = Library.OriginalMouseIconEnabled
    if Cursor then Cursor.Visible = false end
end

--// Notification \\--
local NotificationArea
local NotifyOrder = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 200,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

--// Icons \\--
local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon, CloseIcon, MaximizeIcon
function Library:SetIconModule(module: IconModule)
    FetchIcons = true
    Icons = module

    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    MaximizeIcon = Library:GetIcon("maximize-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
    PopOutIcon = Library:GetIcon("square-arrow-down-left")
    CloseIcon = Library:GetIcon("x")
end

local OnlineFetchIcons, OnlineIcons = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua")
    ) :: () -> IconModule)()
end)
if OnlineFetchIcons and OnlineIcons then
    Library:SetIconModule(OnlineIcons)
end

--// Lib Functions \\--
Library.Cursor = {}

function Library.Cursor:ResetCross()
    for _, Inner in InnerCross do
        Library.Registry[Inner].BackgroundColor3 = "WhiteColor"
        Inner.BackgroundColor3 = Library.Scheme.WhiteColor
    end
end

function Library.Cursor:ResetIcon()
    CursorCross.Visible = true
    CursorCustomImage.Visible = false
    CursorCustomImage.ImageColor3 = Color3.new(1, 1, 1)
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
end

function Library.Cursor:ResetCursor()
    Library.Cursor:ResetCross()
    Library.Cursor:ResetIcon()
end

function Library.Cursor:ChangeCrossColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    for _, Inner in InnerCross do
        Inner.BackgroundColor3 = Color
        Library.Registry[Inner].BackgroundColor3 = nil
    end
end

function Library.Cursor:ChangeIcon(ImageId: string)
    if not ImageId or ImageId == "" then
        Library.Cursor:ResetIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCross.Visible = false
    CursorCustomImage.Visible = true
    Library:ApplyLucideIcon(CursorCustomImage, Icon)
end

function Library.Cursor:ChangeIconColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    CursorCustomImage.ImageColor3 = Color
end

function Library.Cursor:ChangeIconSize(Size: UDim2)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

--// DEPRECATED
function Library:ChangeCursorCrossColor(Color: Color3)
    warn("Obsidian:ChangeCursorCrossColor is deprecated, please use Obsidian.Cursor:ChangeCrossColor instead.")
    Library.Cursor:ChangeCrossColor(Color)
end

--// DEPRECATED
function Library:ResetCursorCross()
    warn("Obsidian:ResetCursorCross is deprecated, please use Obsidian.Cursor:ResetCross instead.")
    Library.Cursor:ResetCross()
end

--// DEPRECATED
function Library:ChangeCursorIcon(ImageId: string)
    warn("Obsidian:ChangeCursorIcon is deprecated, please use Obsidian.Cursor:ChangeIcon instead.")
    Library.Cursor:ChangeIcon(ImageId)
end

--// DEPRECATED
function Library:ChangeCursorIconColor(Color: Color3)
    warn("Obsidian:ChangeCursorIconColor is deprecated, please use Obsidian.Cursor:ChangeIconColor instead.")
    Library.Cursor:ChangeIconColor(Color)
end

--// DEPRECATED
function Library:ChangeCursorIconSize(Size: UDim2)
    warn("Obsidian:ChangeCursorIconSize is deprecated, please use Obsidian.Cursor:ChangeIconSize instead.")
    Library.Cursor:ChangeIconSize(Size)
end

--// DEPRECATED
function Library:ResetCursorIcon()
    warn("Obsidian:ResetCursorIcon is deprecated, please use Obsidian.Cursor:ResetIcon instead.")
    Library.Cursor:ResetIcon()
end

--// Colors \\--
function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Scale = Library.DPIScale
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size * Scale
    if Width then
        Params.Width = Width * Scale
    else
        Params.Width = workspace.CurrentCamera.ViewportSize.X - 32
    end

    local Bounds = TextService:GetTextBoundsAsync(Params)
    return math.ceil(Bounds.X / Scale), math.ceil(Bounds.Y / Scale)
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame: GuiObject, Frame: GuiObject)
    local GuiPos = Frame.AbsolutePosition
    local GuiSize = Frame.AbsoluteSize

    local FramePos = ParentFrame.AbsolutePosition
    local FrameSize = ParentFrame.AbsoluteSize

    return GuiPos.X >= FramePos.X
        and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
        and GuiPos.Y >= FramePos.Y
        and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError and Library.Notify then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function GetOverlappingDraggable(UI: GuiObject, TargetPos: Vector2?)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize

    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end

        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize

        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end

    return nil
end

function GetNonOverlappingPosition(UI: GuiObject, StartPos: UDim2?)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6

    local CurrentX = Start.X
    local CurrentY = Start.Y

    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end

    if Size.X == 0 then Size = Vector2.new(150, 40) end

    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end

        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end

        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding

            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end

            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end

    return UDim2.fromOffset(CurrentX, CurrentY)
end

function PositionDraggable(UI: GuiObject, StartPos: UDim2?)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

--// Window Snapping \\--
local function GetCoreGuiInset(): (Vector2, Vector2)
    local Success, TopLeft, BottomRight = pcall(function()
        return GuiService:GetGuiInset()
    end)

    if Success and TopLeft and BottomRight then
        return TopLeft, BottomRight
    end

    return Vector2.zero, Vector2.zero
end

local function GetSnapEdges(ElemSize: Vector2, ViewportSize: Vector2, Margin: number, AvoidCoreGui: boolean)
    local SafeMin, SafeMax = Vector2.zero, ViewportSize

    if AvoidCoreGui then
        local TopLeftInset, BottomRightInset = GetCoreGuiInset()
        SafeMin = TopLeftInset
        SafeMax = ViewportSize - BottomRightInset
    end

    local TargetsX = {
        LeftEdge = SafeMin.X + Margin,
        Center = SafeMin.X + (SafeMax.X - SafeMin.X - ElemSize.X) / 2,
        RightEdge = SafeMax.X - ElemSize.X - Margin,
    }
    local TargetsY = {
        TopEdge = SafeMin.Y + Margin,
        Center = SafeMin.Y + (SafeMax.Y - SafeMin.Y - ElemSize.Y) / 2,
        BottomEdge = SafeMax.Y - ElemSize.Y - Margin,
    }

    return TargetsX, TargetsY
end

local function GetClosestSnapTarget(Value: number, Targets: { [string]: number }, Distance: number): (number?, string?)
    local ClosestName, ClosestValue, ClosestDist = nil, nil, Distance

    for Name, Target in Targets do
        local Dist = math.abs(Value - Target)
        if Dist <= ClosestDist then
            ClosestDist = Dist
            ClosestName = Name
            ClosestValue = Target
        end
    end

    return ClosestValue, ClosestName
end

local function GetSnapGuideOffset(Name: string, SnappedValue: number, ElemDimension: number): number
    if Name == "RightEdge" or Name == "BottomEdge" then
        return SnappedValue + ElemDimension
    elseif Name == "Center" then
        return SnappedValue + ElemDimension / 2
    end

    return SnappedValue -- LeftEdge / TopEdge
end

local ScreenBound = {}
local ScreenKeep = 48

local function ClampToScreen(UI: GuiObject, AbsPos: Vector2): Vector2
    local Origin = ScreenGui.AbsolutePosition
    local Bounds = ScreenGui.AbsoluteSize
    local Size = UI.AbsoluteSize
    local KeepX = math.min(ScreenKeep, Size.X)
    local KeepY = math.min(ScreenKeep, Size.Y)
    local MinX = Origin.X + KeepX - Size.X

    return Vector2.new(
        math.clamp(AbsPos.X, MinX, math.max(MinX, Origin.X + Bounds.X - KeepX)),
        math.clamp(AbsPos.Y, Origin.Y, math.max(Origin.Y, Origin.Y + Bounds.Y - KeepY))
    )
end

Library:GiveSignal(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    task.defer(function()
        for UI in ScreenBound do
            if not UI.Parent then
                continue
            end

            local AbsPos = UI.AbsolutePosition
            local Clamped = ClampToScreen(UI, AbsPos)
            if Clamped ~= AbsPos then
                UI.Position += UDim2.fromOffset(Clamped.X - AbsPos.X, Clamped.Y - AbsPos.Y)
            end
        end
    end)
end))

function Library:MakeDraggable(
    UI: GuiObject,
    DragFrame: GuiObject,
    IgnoreToggled: boolean?,
    IsMainWindow: boolean?,
    SnapConfig: { Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean? }?
)
    local StartPos
    local StartAbs
    local DragInput
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    local SnapGuideX, SnapGuideY

    local function GetSnapGuides()
        if not SnapGuideX then
            SnapGuideX = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 2, 1, 0),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        if not SnapGuideY then
            SnapGuideY = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        return SnapGuideX, SnapGuideY
    end

    local function HideSnapGuides()
        if SnapGuideX then
            SnapGuideX.Visible = false
        end
        if SnapGuideY then
            SnapGuideY.Visible = false
        end
    end

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        StartPos = Input.Position
        StartAbs = UI.AbsolutePosition
        DragInput = Input
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if not IsInputEnded(Input) then
                return
            end

            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        -- le bouton resize est dans la top bar : on ne bouge pas la fenêtre pendant un resize
        if Dragging and IsDragMove(Input, DragInput) and not (IsMainWindow and Library.IsResizingWindow) then
            local Delta = Input.Position - StartPos
            local NewX = FramePos.X.Offset + Delta.X
            local NewY = FramePos.Y.Offset + Delta.Y

            if SnapConfig and SnapConfig.Enabled then
                local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local Distance = SnapConfig.Distance or 28
                local Margin = SnapConfig.Margin or 8

                local AbsX = FramePos.X.Scale * ViewportSize.X + NewX
                local AbsY = FramePos.Y.Scale * ViewportSize.Y + NewY

                local ElemSize = UI.AbsoluteSize
                local TargetsX, TargetsY = GetSnapEdges(ElemSize, ViewportSize, Margin, SnapConfig.AvoidCoreGui ~= false)
                local SnappedX, SnappedXName = GetClosestSnapTarget(AbsX, TargetsX, Distance)
                local SnappedY, SnappedYName = GetClosestSnapTarget(AbsY, TargetsY, Distance)

                if SnappedX then
                    NewX = SnappedX - FramePos.X.Scale * ViewportSize.X
                end
                if SnappedY then
                    NewY = SnappedY - FramePos.Y.Scale * ViewportSize.Y
                end

                local GuideX, GuideY = GetSnapGuides()
                GuideX.Visible = SnappedX ~= nil
                if SnappedX then
                    GuideX.Position = UDim2.fromOffset(GetSnapGuideOffset(SnappedXName, SnappedX, ElemSize.X), 0)
                end

                GuideY.Visible = SnappedY ~= nil
                if SnappedY then
                    GuideY.Position = UDim2.fromOffset(0, GetSnapGuideOffset(SnappedYName, SnappedY, ElemSize.Y))
                end
            end

            local Target = StartAbs + Vector2.new(NewX - FramePos.X.Offset, NewY - FramePos.Y.Offset)
            local Clamped = ClampToScreen(UI, Target)
            NewX += Clamped.X - Target.X
            NewY += Clamped.Y - Target.Y

            UI.Position = UDim2.new(FramePos.X.Scale, NewX, FramePos.Y.Scale, NewY)
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    ScreenBound[UI] = true

    UI.Destroying:Once(function()
        ScreenBound[UI] = nil

        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        if SnapGuideX then
            SnapGuideX:Destroy()
        end
        if SnapGuideY then
            SnapGuideY:Destroy()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local DragInput
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged
    local BoundsChanged

    local function GetScale()
        local Offset = UI.Size.X.Offset
        return Offset > 0 and UI.AbsoluteSize.X > 0 and UI.AbsoluteSize.X / Offset or 1
    end

    local function GetMaxSize(Scale: number)
        local Bounds = ScreenGui.AbsoluteSize
        return math.max(Library.MinSize.X, (Bounds.X - 16) / Scale), math.max(Library.MinSize.Y, (Bounds.Y - 16) / Scale)
    end

    BoundsChanged = ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local MaxX, MaxY = GetMaxSize(GetScale())
        local Size = UI.Size
        if Size.X.Offset <= MaxX and Size.Y.Offset <= MaxY then
            return
        end

        UI.Size = UDim2.new(Size.X.Scale, math.min(Size.X.Offset, MaxX), Size.Y.Scale, math.min(Size.Y.Offset, MaxY))
        if Callback then
            Library:SafeCallback(Callback)
        end
    end)

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        StartPos = Input.Position
        DragInput = Input
        FrameSize = UI.Size
        Dragging = true
        Library.IsResizingWindow = true

        Changed = Input.Changed:Connect(function()
            if not IsInputEnded(Input) then
                return
            end

            Dragging = false
            Library.IsResizingWindow = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            if Dragging then
                Library.IsResizingWindow = false
            end
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsDragMove(Input, DragInput) then
            local Scale = GetScale()
            local MaxX, MaxY = GetMaxSize(Scale)
            local Delta = (Input.Position - StartPos) / Scale
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, MaxX),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, MaxY)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)
    Library:GiveSignal(BoundsChanged)

    UI.Destroying:Once(function()
        if BoundsChanged and BoundsChanged.Connected then
            BoundsChanged:Disconnect()
        end

        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        LayoutOrder = Info.LayoutOrder or 0,
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

function Library:AddOutline(Frame: GuiObject)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1.5,
        ZIndex = 1,
        Parent = Frame,
    })
    return OutlineStroke, ShadowStroke
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Animations \\--
local TransparencyCache = {}
local ActiveTabTweens = setmetatable({}, { __mode = "k" })

function Library:PlayTabAnimation(Tab, Showing: boolean, OnComplete: (() -> ())?)
    if type(Tab) ~= "table" or not Tab.Container then
        if OnComplete then
            OnComplete()
        end

        return
    end

    local TabContainer = Tab.Container :: Frame
    local Existing = ActiveTabTweens[TabContainer]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabContainer] = nil
    end

    local BaseZIndex = TabContainer.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabContainer.Visible = Showing
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end

        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition
        local StartingPositions = {
            Left = UDim2.fromOffset(-Offset, 0),
            Right = UDim2.fromOffset(Offset, 0),
            Top = UDim2.fromOffset(0, -Offset),
            Bottom = UDim2.fromOffset(0, Offset),
        }

        if SwipeFrom == "auto" and Library.PreviousTab then
            local CurrentOrder = Tab.Button.LayoutOrder
            local PreviousOrder = Library.PreviousTab.Button.LayoutOrder
            if CurrentOrder and PreviousOrder then -- this may be unnecessary but oh well
                StartPosition = CurrentOrder > PreviousOrder and StartingPositions.Top or StartingPositions.Bottom -- bigger order means its under the current button
            else
                StartPosition = StartingPositions.Bottom
            end
        elseif SwipeFrom == "left" then
            StartPosition = StartingPositions.Left
        elseif SwipeFrom == "top" then
            StartPosition = StartingPositions.Top
        elseif SwipeFrom == "right" then
            StartPosition = StartingPositions.Right
        else -- bottom (Default)
            StartPosition = StartingPositions.Bottom
        end

        TabContainer.ZIndex = BaseZIndex + 1
        TabContainer.Position = StartPosition
        TabContainer.Visible = true

        local Tween = TweenService:Create(TabContainer, TweenInfo, {
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabContainer] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            if Connection then
                Connection:Disconnect()
            end

            if ActiveTabTweens[TabContainer] == Tween then
                ActiveTabTweens[TabContainer] = nil
            end

            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end

            TabContainer.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabContainer.Visible = false
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end
    end
end

--// Pop Out \\--
function Library:MakeBoxPopOut(Box: any, Options: {
    Enabled: boolean?,
    Header: GuiObject?,
    Children: (() -> { GuiObject })?,
    Before: (() -> ())?,
    After: (() -> ())?,
    MaxPopOutHeight: number?,
    PopOutWidth: number?,
})
    Box.PoppedOut = false
    Box.PopOutEnabled = Options.Enabled ~= false
    Box.PopOutFloat = nil
    Box.PopOutPlaceholder = nil
    Box.PopOutMaxHeight = if typeof(Options.MaxPopOutHeight) == "number" then Options.MaxPopOutHeight else nil
    Box.PopOutWidth = if typeof(Options.PopOutWidth) == "number" then Options.PopOutWidth else nil

    if not Box.PopOutEnabled then
        function Box:SetPoppedOut(_Value: boolean, _SetPoppedOut: UDim2) end
        function Box:TogglePoppedOut() end
        function Box:RefreshPopOutPlaceholder() end
        function Box:SetMaxPopOutHeight(_Height: number?) end
        function Box:SetPopOutWidth(_Width: number?) end
        return
    end

    local BoxHolder = Box.BoxHolder
    local Holder = Box.Holder
    local Header = Options.Header

    local Placeholder
    local PlaceholderHeader
    local Float
    local FloatScale

    local HandledChildren: { GuiObject } = {}
    local OriginalParents: { [GuiObject]: Instance? } = {}
    local OriginalLayoutOrders: { [GuiObject]: number } = {}

    local DragState: "Idle" | "Holding" | "Dragging" = "Idle"
    local DragInput: InputObject?
    local PressMouse: Vector2?

    local DragStartPos: UDim2?
    local DragChanged: RBXScriptConnection?
    local DragDidMove = false

    --// UI Handler
    local function GetPopOutWidth(): number
        if typeof(Box.PopOutWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutWidth + 0.5))
        end

        if typeof(Box.PopOutDockedWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutDockedWidth + 0.5))
        end

        local Width = Holder.AbsoluteSize.X / Library.DPIScale
        if Width < 50 then
            Width = 200
        end

        return math.max(50, math.floor(Width + 0.5))
    end

    local function ApplyPopOutWidth()
        if not (Box.PoppedOut and Float) then
            return
        end

        Float.Size = UDim2.fromOffset(GetPopOutWidth(), Float.Size.Y.Offset)
        if Box.Resize then
            Box:Resize()
        end
    end

    local function RaiseFloat()
        if not Float or not Floats then
            return
        end

        local MaxZ = Float.ZIndex
        for _, Child in Floats:GetChildren() do
            if Child:IsA("GuiObject") and Child ~= Float then
                MaxZ = math.max(MaxZ, Child.ZIndex)
            end
        end

        Float.ZIndex = MaxZ + 1
        if Float.Parent == Floats then
            Float.Parent = Overlay
        end
        Float.Parent = Floats
    end

    local function CreatePlaceholder()
        local Frame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = BoxHolder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Frame
        DimPopOutClone(PlaceholderHeader)

        if PopOutIcon then
            local PlaceholderDockIcon = New("ImageButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = "WhiteColor",
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                ZIndex = PlaceholderHeader.ZIndex + 1,
                Parent = Frame,
            })
            Library:ApplyLucideIcon(PlaceholderDockIcon, PopOutIcon)
            OnTap(PlaceholderDockIcon, function()
                Box:SetPoppedOut(false)
            end)
        end

        return Frame
    end

    function Box:RefreshPopOutPlaceholder()
        if not Box.PoppedOut or not Placeholder or not Header then
            return
        end

        if PlaceholderHeader then
            PlaceholderHeader:Destroy()
            PlaceholderHeader = nil
        end

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Placeholder
        DimPopOutClone(PlaceholderHeader)
    end

    function Box:SetPoppedOut(Value: boolean, FloatPosition: UDim2?)
        if not Box.PopOutEnabled or Box.Destroyed then
            return
        end

        Value = Value == true
        if Box.PoppedOut == Value then
            if Value and FloatPosition and Float then
                Float.Position = FloatPosition
            end
            return
        end

        if Value then
            if Options.Before then
                Options.Before()
            end

            local BoxChildren = if Options.Children then Options.Children() else { Holder }
            HandledChildren = {}

            table.clear(OriginalParents)
            table.clear(OriginalLayoutOrders)

            for _, Child in BoxChildren do
                if not Child or not Child.Parent then
                    continue
                end

                table.insert(HandledChildren, Child)
                OriginalParents[Child] = Child.Parent
                OriginalLayoutOrders[Child] = Child.LayoutOrder
            end

            if #HandledChildren == 0 then
                return
            end

            local DockedWidth = Holder.AbsoluteSize.X / Library.DPIScale
            if DockedWidth < 50 then
                DockedWidth = 200
            end
            Box.PopOutDockedWidth = math.max(50, math.floor(DockedWidth + 0.5))

            local Width = GetPopOutWidth()

            local AbsolutePosition = Holder.AbsolutePosition
            Placeholder = CreatePlaceholder()
            Box.PopOutPlaceholder = Placeholder

            Float = New("Frame", {
                Active = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = FloatPosition or UDim2.fromOffset(
                    AbsolutePosition.X / Library.DPIScale,
                    AbsolutePosition.Y / Library.DPIScale
                ),
                Size = UDim2.fromOffset(Width, 0),
                ZIndex = 1,
                Parent = Floats,
            })
            FloatScale = New("UIScale", {
                Parent = Float,
            })
            table.insert(Library.Scales, FloatScale)
            FloatScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[FloatScale]) or 0)

            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = Float,
            })

            for _, Child in HandledChildren do
                Child.Parent = Float
            end

            if not table.find(Library.DraggableElements, Float) then
                table.insert(Library.DraggableElements, Float)
            end

            Box.PopOutFloat = Float
            Box.PoppedOut = true
            SyncPopOutVisibility(Box)
            RaiseFloat()

            Float:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                Box:Resize()
            end)

            if Options.After then
                Options.After()
            end

            return
        end

        if Float then
            local DraggableIndex = table.find(Library.DraggableElements, Float)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end
        end

        if FloatScale then
            local ScaleIndex = table.find(Library.Scales, FloatScale)
            if ScaleIndex then
                table.remove(Library.Scales, ScaleIndex)
            end

            FloatScale = nil
        end

        for _, Child in HandledChildren do
            if not Child or not Child.Parent then
                continue
            end

            Child.Parent = OriginalParents[Child] or BoxHolder
            Child.LayoutOrder = OriginalLayoutOrders[Child] or 0
        end

        if Placeholder then
            Placeholder:Destroy()
            Placeholder = nil
        end
        
        PlaceholderHeader = nil

        if Float then
            Float:Destroy()
            Float = nil
        end

        Box.PopOutFloat = nil
        Box.PopOutPlaceholder = nil
        Box.PopOutDockedWidth = nil
        Box.PoppedOut = false

        table.clear(HandledChildren)
        table.clear(OriginalParents)
        table.clear(OriginalLayoutOrders)

        if Options.After then
            Options.After()
        end
    end

    function Box:TogglePoppedOut()
        Box:SetPoppedOut(not Box.PoppedOut)
    end

    function Box:SetMaxPopOutHeight(Height: number?)
        if Height ~= nil then
            assert(typeof(Height) == "number", "Height must be a number or nil")
            assert(Height >= 0, "Height must be higher than 0")
        end

        Box.PopOutMaxHeight = Height
        if Box.PoppedOut and Box.Resize then
            Box:Resize()
        end
    end

    function Box:SetPopOutWidth(Width: number?)
        if Width ~= nil then
            assert(typeof(Width) == "number", "Width must be a number or nil")
            assert(Width >= 0, "Width must be higher than 0")
        end

        Box.PopOutWidth = Width
        ApplyPopOutWidth()
    end

    --// Drag Handler
    local function StopDrag()
        if DragState == "Idle" then
            return
        end

        local WasDragging = DragState == "Dragging"
        local DidMove = DragDidMove
        DragState = "Idle"
        DragInput = nil
        PressMouse = nil
        DragStartPos = nil
        DragDidMove = false

        if DragChanged and DragChanged.Connected then
            DragChanged:Disconnect()
            DragChanged = nil
        end

        if not WasDragging or not Box.PoppedOut or not Float then
            return
        end

        local FloatCenter = Float.AbsolutePosition + (Float.AbsoluteSize * 0.5)
        local NearPlaceholder = false
        if Library.Toggled and Placeholder and Placeholder.Parent then
            local PlaceholderCenter = Placeholder.AbsolutePosition + (Placeholder.AbsoluteSize * 0.5)
            NearPlaceholder = (FloatCenter - PlaceholderCenter).Magnitude <= Library.PopOutSnapDistance
        end

        if NearPlaceholder or (DidMove and not IsScreenPointOutsideMain(FloatCenter)) then
            Box:SetPoppedOut(false)
        end
    end

    local function BeginDrag(Input: InputObject)
        if DragState ~= "Idle" or Box.Destroyed or not (ScreenGui and ScreenGui.Parent) then
            return
        end

        local Point = Vector2.new(Input.Position.X, Input.Position.Y)
        local Top = GetTopFloatAt(Point)
        if Box.PoppedOut then
            if not Float or Top ~= Float then
                return
            end
        elseif Top ~= nil and not Header:IsDescendantOf(Top) then
            return
        end

        DragState = "Holding"
        DragInput = Input
        PressMouse = Vector2.new(Input.Position.X, Input.Position.Y)
        DragStartPos = nil
        DragDidMove = false

        if Box.PoppedOut and Float then
            RaiseFloat()
        end

        DragChanged = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)

        task.delay(Library.PopOutHoldTime, function()
            if (DragState :: any) ~= "Holding" or DragInput ~= Input then
                return
            end

            DragState = "Dragging"
            if Box.PoppedOut and Float then
                RaiseFloat()
                DragStartPos = Float.Position
            end
        end)
    end

    local function UpdateDrag(Input: InputObject)
        if DragState ~= "Dragging" or not PressMouse then
            return
        end
        if not (ScreenGui and ScreenGui.Parent) then
            StopDrag()
            return
        end

        local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Delta = MousePosition - PressMouse

        if not Box.PoppedOut then
            if Delta.Magnitude < Library.PopOutDragThreshold then
                return
            end

            Box:SetPoppedOut(true)
            if not Float then
                return
            end

            RaiseFloat()
            DragStartPos = Float.Position
            DragDidMove = true
        elseif Delta.Magnitude >= Library.PopOutDragThreshold then
            DragDidMove = true
        end

        if Float and DragStartPos then
            Float.Position = UDim2.new(
                DragStartPos.X.Scale,
                DragStartPos.X.Offset + Delta.X,
                DragStartPos.Y.Scale,
                DragStartPos.Y.Offset + Delta.Y
            )
        end
    end

    local function BindDragSource(Gui: GuiObject)
        Library:GiveSignal(Gui.InputBegan:Connect(function(Input: InputObject)
            if IsClickInput(Input) then
                BeginDrag(Input)
            end
        end))
    end

    BindDragSource(Header)
    for _, Descendant in Header:QueryDescendants("GuiObject:not(ImageButton)") do
        BindDragSource(Descendant)
    end

    Library:GiveSignal(Header.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("GuiObject") and not Descendant:IsA("ImageButton") then
            BindDragSource(Descendant)
        end
    end))

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if IsHoverInput(Input) then
            UpdateDrag(Input)
        end
    end))
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end

    IconPosition = string.lower(IconPosition)
    assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:AddOutline(Label)
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(Text: string)
        Label.Text = Text
    end

    function DraggableLabel:SetIcon(NewIcon: string)
        Icon = NewIcon

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            IconImage = IconImage or New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 2,
                Parent = Label,
            })

            Library:ApplyLucideIcon(IconImage, CustomIcon)
        end

        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition: string)
        IconPosition = string.lower(NewPosition)
        assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)

        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end

    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end

    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        DraggableLabel.Destroyed = true

        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)

    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableButton)
            end

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableButton:SetText(Text: string)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        DraggableButton.Destroyed = true

        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, Library.IsMobile and 2 or 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, Library.IsMobile and 10 or 7),
        PaddingRight = UDim.new(0, Library.IsMobile and 10 or 7),
        PaddingTop = UDim.new(0, Library.IsMobile and 4 or 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    PositionDraggable(Holder, Holder.Position)

    return Holder, Container
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)

    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 1,
        Parent = Floats,
    })

    local IconImage = New("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 2,
        Parent = Button,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableImageButton)
            end

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableImageButton:SetIcon(NewIcon: string)
        Icon = NewIcon or Icon

        local CustomIcon = Library:GetCustomIcon(Icon)
        assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(IconImage, CustomIcon)
    end

    function DraggableImageButton:SetIconSize(NewSize: number)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    IgnoreCornerRadius: boolean?,
    SpecificCornersOnly: ("top" | "bottom" | "no_left" | "no_top_left")?, -- stupid way of doing this
    AnimationType: ("Dropdown" | "KeyPicker" | "none")?
)
    local Menu
    local HolderGui = Holder:FindFirstAncestorOfClass("ScreenGui")
    local ParentGui = Overlay
    if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
        ParentGui = HolderGui
    end

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    end
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })

    local Corner;
    if IgnoreCornerRadius ~= true then
        if SpecificCornersOnly == "top" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "bottom" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_top_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        else
            Corner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.Corners, Corner)
        end
    end

    local Table = {
        Connections = {},
        Destroyed = false,

        Active = false,
        ActiveCallback = ActiveCallback,

        Holder = Holder,
        Menu = Menu,
        Corner = Corner,

        List = nil,
        Signal = nil,

        Size = Size,
        AutoSizeY = List == 1,

        OpenCloseTween = nil,
        Animated = function()
            if not AnimationType or AnimationType == "none" then
                return false
            end

            if not (Library.Animations and Library.Animations[AnimationType] == true) then
                return false
            end

            return true, Library[string.format("%sTransitionInfo", AnimationType)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if List == 1 then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    local function UpdatePosition()
        local MenuOffset = typeof(Offset) == "function" and Offset() or Offset
        local X = math.floor(Holder.AbsolutePosition.X + MenuOffset[1])
        local Y = math.floor(Holder.AbsolutePosition.Y + MenuOffset[2])

        local Bounds = ParentGui.AbsoluteSize
        local MenuSize = Menu.AbsoluteSize
        local Margin = 4

        Menu.Position = UDim2.fromOffset(
            math.clamp(X, math.min(X, Margin), math.max(math.min(X, Margin), Bounds.X - MenuSize.X - Margin)),
            math.clamp(Y, math.min(Y, Margin), math.max(math.min(Y, Margin), Bounds.Y - MenuSize.Y - Margin))
        )
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        elseif CurrentMenu then
            CurrentMenu:Close()
        end

        CurrentMenu = Table
        Table.Active = true
        Menu.ZIndex = 1

        local TargetParent = if ParentGui == Overlay then Overlay else ParentGui
        Menu.Parent = nil
        Menu.Parent = TargetParent

        UpdatePosition()
        Table.SizeSignal = Menu:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePosition)

        local TargetSize = typeof(Table.Size) == "function" and Table.Size() or Table.Size

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            local OpenSize = TargetSize
            if Table.AutoSizeY then
                local FullHeight = Menu.AbsoluteSize.Y

                Menu.AutomaticSize = Enum.AutomaticSize.None
                OpenSize = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, FullHeight)
            end

            Menu.Size = UDim2.new(OpenSize.X.Scale, OpenSize.X.Offset, 0, 0)
            Menu.Visible = true

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = OpenSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Size = TargetSize
            Menu.Visible = true
        end

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            UpdatePosition()

            local HolderAllowed = Library:IsInsideFrame(Library.WindowContainer, Holder)
            if not HolderAllowed then
                for _, Surface in Library.DraggableElements do
                    if not (Surface and Library:IsInsideFrame(Surface, Holder)) then
                        continue
                    end

                    HolderAllowed = true
                    break
                end
            end

            if not HolderAllowed and Table.Active then
                Table:Close()
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end

        if Table.SizeSignal then
            Table.SizeSignal:Disconnect()
            Table.SizeSignal = nil
        end

        Table.Active = false
        CurrentMenu = nil

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            if Table.AutoSizeY then
                Menu.AutomaticSize = Enum.AutomaticSize.None
            end

            local CurrentSize = Menu.Size
            local CollapsedSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0)

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = CollapsedSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function(PlaybackState)
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    Menu.Visible = false
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Visible = false
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    function Table:Destroy()
        Table.Destroyed = true

        if Table.Connections then
            for _, Connection in Table.Connections do
                Connection:Disconnect()
            end
        end

        if CurrentMenu == Table then
            Table:Close()
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local MenuIndex = table.find(Library.ContextMenus, Table)
        if MenuIndex then
            table.remove(Library.ContextMenus, MenuIndex)
        end

        if Menu then
            Menu:Destroy()
        end
    end

    table.insert(Library.ContextMenus, Table)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 30,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)

local TooltipMeasureId = 0
local LastTooltipText = ""
local LastTooltipMaxWidth = 0

local function UpdateTooltipSize(Force: boolean?)
    if Library.Unloaded or not TooltipLabel.Visible then
        return
    end

    local MaxWidth = math.max(
        40,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    if
        not Force
        and TooltipLabel.Text == LastTooltipText
        and math.abs(MaxWidth - LastTooltipMaxWidth) < 1
        and TooltipLabel.Size.X.Offset > 0
    then
        return
    end

    TooltipMeasureId += 1
    local MeasureId = TooltipMeasureId
    local Text = TooltipLabel.Text

    local X, Y = Library:GetTextBounds(Text, TooltipLabel.FontFace, TooltipLabel.TextSize, MaxWidth)
    if MeasureId ~= TooltipMeasureId or TooltipLabel.Text ~= Text then
        return
    end

    LastTooltipText = Text
    LastTooltipMaxWidth = MaxWidth
    TooltipLabel.Size = UDim2.fromOffset(X + 8, Y + 4)
end

TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    UpdateTooltipSize(false)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local HolderGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
            TooltipLabel.Parent = HolderGui
        else
            TooltipLabel.Parent = ScreenGui
        end

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Position = UDim2.fromOffset(
            Mouse.X + (Library.ShowCustomCursor and 8 or 14),
            Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
        )
        TooltipLabel.Visible = true
        UpdateTooltipSize(true)

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            assert(Info.Mode == "Press", "KeyPicker on Buttons can only be applied with the 'Press' mode.")

            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},

            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            MenuVisible = Info.NoUI ~= true,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label" or ParentObj.Type == "Button" or ParentObj.Type == "SubButton", "KeyPicker with the mode 'Press' can be only applied on Labels and Buttons.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local LastDisplayText = nil
        local MaxPickerWidth = 85
        local SlidingLabel

        local SlideForwardTween
        local SlideBackTween
        local HandleForwardTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideBackTween then
                SlideBackTween:Play()
            end
        end

        local HandleBackTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideForwardTween then
                SlideForwardTween:Play()
            end
        end

        local SlideForwardConn, SlideBackConn
        local CancelSlidingTweens = function()
            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end

            if SlideBackTween then
                StopTween(SlideBackTween, true)
                SlideBackTween = nil
            end

            RunService.RenderStepped:Wait()
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            TextTransparency = 0.4,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true

            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                FontFace = Picker.FontFace,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })

            Library:AddToRegistry(SlidingLabel, {
                TextColor3 = "FontColor",
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        }); table.insert(Library.SpecificCorners, PickerCorner)

        local PickerHoverTween = nil

        local function ApplyPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)
            PickerHoverTween = nil

            Picker.TextTransparency = Transparency
            if SlidingLabel then
                SlidingLabel.TextTransparency = Transparency
            end
        end

        local function TweenPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)

            PickerHoverTween = TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = Transparency,
            })
            PickerHoverTween:Play()

            if SlidingLabel then
                TweenService:Create(SlidingLabel, Library.TweenInfo, {
                    TextTransparency = Transparency,
                }):Play()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseEnter:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseLeave:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0.4)
        end))

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Parent = ToggleLabel.Parent,
            })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 9),
                Parent = Holder,
            })

            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Fill,
                Parent = ToggleLabel,
            })

            ToggleLabel.Parent = Holder
            Picker.Parent = Holder

            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local RowHeight = Library.IsMobile and 32 or 16
            local CheckSize = Library.IsMobile and 20 or 14
            local LabelOffset = CheckSize + 8

            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, RowHeight),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = Library.IsMobile and 15 or 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(CheckSize, CheckSize),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })
            if CheckIcon then
                Library:ApplyLucideIcon(CheckImage, CheckIcon)
            end

            function KeybindsToggle:Display(State)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(LabelOffset, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            table.insert(KeyPicker.Connections, OnTap(Holder, function()
                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
                KeyPicker:Update()
            end))

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local ModeCorners = {}
        local TotalModeButtons = GetTableSize(Info.Modes)
        local MenuCornersOnly = if TotalModeButtons == 1 then "no_left" else "no_top_left"

        local MenuTable
        MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            PickerCorner.TopLeftRadius = Half
            PickerCorner.BottomLeftRadius = Half
            PickerCorner.TopRightRadius = Active and Zero or Half
            PickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = MenuTable and MenuTable.Corner
            if MenuCorner then
                if MenuCornersOnly == "no_left" then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.BottomLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                else
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end

            for _, Entry in ModeCorners do
                local Corner = Entry.Corner
                if Entry.Style == "single" then
                    Corner.TopLeftRadius = Zero
                    Corner.BottomLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomRightRadius = Half
                elseif Entry.Style == "first" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomLeftRadius = Zero
                    Corner.BottomRightRadius = Zero
                elseif Entry.Style == "last" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Zero
                    Corner.BottomLeftRadius = Half
                    Corner.BottomRightRadius = Half
                end
            end
        end, false, MenuCornersOnly, "KeyPicker")
        KeyPicker.Menu = MenuTable

        for Index, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            if Index == 1 and TotalModeButtons == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "single" })
            elseif Index == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "first" })
            elseif Index == TotalModeButtons then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "last" })
            end

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
                if KeyPicker.Update then
                    KeyPicker:Update()
                end
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            table.insert(KeyPicker.Connections, OnTap(Button, function()
                ModeButton:Select()
            end))

            table.insert(KeyPicker.Connections, Button.MouseEnter:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, Button.MouseLeave:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        local SetPickingState = function(State, SkipUpdate: boolean?)
            Picking = State
            Library.IsPicking = State

            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end

            if IsForButton then
                ToggleLabel.Visible = not Picking
                LastDisplayText = nil
                RunService.RenderStepped:Wait()
            end

            if SkipUpdate ~= true then
                (KeyPicker :: any):Update()
            end
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )

                local OffsetScale = X + 9
                local TextChanged = LastDisplayText ~= DisplayText
                local LabelWidth

                SlidingLabel.Text = DisplayText
                LastDisplayText = DisplayText

                if Picking then
                    Picker.Size = UDim2.new(1, 0, 1, 0)
                    RunService.RenderStepped:Wait()
                    LabelWidth = Picker.AbsoluteSize.X

                    if LabelWidth <= 0 then
                        LabelWidth = MaxPickerWidth
                    end
                else
                    LabelWidth = math.min(OffsetScale, MaxPickerWidth)
                    Picker.Size = UDim2.new(0, LabelWidth, 1, 0)
                end

                if OffsetScale > LabelWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)

                    local OverflowDistance = OffsetScale - LabelWidth - 4.5
                    if OverflowDistance > 0 then
                        if TextChanged or not SlideForwardTween then
                            SlidingLabel.Position = UDim2.fromOffset(4.5, 0)
                            CancelSlidingTweens()

                            local Duration = math.max(OverflowDistance / 25, 0.35)
                            local TweenInfo = TweenInfo.new(
                                Duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )

                            SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(-OverflowDistance, 0),
                            })

                            SlideBackTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(4.5, 0),
                            })

                            SlideForwardTween:Play()

                            if SlideForwardConn then
                                SlideForwardConn:Disconnect()
                            end

                            if SlideBackConn then
                                SlideBackConn:Disconnect()
                            end

                            SlideForwardConn = SlideForwardTween.Completed:Connect(HandleForwardTween)
                            SlideBackConn = SlideBackTween.Completed:Connect(HandleBackTween)
                        end
                    else
                        CancelSlidingTweens()

                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()

                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X / Library.DPIScale
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset((X + 9), (Y + 4))
            end
        end

        function KeyPicker:Update()
            local Disabled = ParentObj.Disabled == true

            if Disabled and Picking then
                SetPickingState(false, true)
            end

            KeyPicker:Display()

            Picker.Active = not Disabled
            ApplyPickerTextTransparency(Disabled and 0.8 or 0.4)

            if Disabled then
                if MenuTable.Active then
                    MenuTable:Close()
                end
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if Info.NoUI then
                return
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(KeyPicker.MenuVisible ~= false)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if Picking then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end

                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key] :: any) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if Picking or ParentObj.Disabled then
                return
            end

            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
            end

            if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            if ParentObj.Disabled then
                return
            end

            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    if KeyPicker.Value == "None" then
                        return nil
                    end

                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end

                    return SpecialKeys[KeyPicker.Value]
                end)
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()
        end

        function KeyPicker:SetMenuVisibility(Visible: boolean)
            assert(typeof(Visible) == "boolean", "Visible must be a boolean")

            KeyPicker.MenuVisible = Visible
            KeyPicker:Update()
        end

        table.insert(KeyPicker.Connections, OnTap(Picker, function()
            if Picking or Library.IsPicking or ParentObj.Disabled then
                return
            end

            SetPickingState(true)

            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 18)
            end

            -- Wait for any input --
            local ActiveModifiers = {}
            local CurrentInput = nil

            local IsValidInput = function(InputObj)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end

                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end

                return true
            end

            -- Wait for the first valid InputBegan --
            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end

                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            -- If it's a modifier key, we wait for either its release or another input --
            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Display the current state including the current modifier key --
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false

                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)

                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break -- Use modifier key as bind
                elseif NextInput then
                    -- Add another modifier or continue to normal key
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end

                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            MenuTable:Toggle()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                ParentObj.Disabled
                or KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if HoldingKey then
                if KeyPicker.Mode == "Toggle" then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Press" then
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Hold" then
                    InputChanged = Input.Changed:Connect(function()
                        if KeyPicker:GetState() then
                            return
                        end

                        KeyPicker:Update()
                        if InputChanged and InputChanged.Connected then
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end

                KeyPicker:Update()
            end
        end))

        KeyPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, KeyPicker)

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            KeyPicker.Destroyed = true

            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if IsForButton and SlideOverflow then
                if SlideForwardTween then
                    SlideForwardTween:Destroy()
                end

                if SlideBackTween then
                    SlideBackTween:Destroy()
                end
            end

            if Picker then
                Picker:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = KeyPicker

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Connections = {},
            Destroyed = false,

            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })

        local ColorPickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        }); table.insert(Library.SpecificCorners, ColorPickerCorner)

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        --// Color Menu \\--
        local MapSize = Library.IsMobile and 140 or 200
        local BarWidth = 16
        local MenuWidth = MapSize + BarWidth + 6 + 12
        if Info.Transparency then
            MenuWidth += BarWidth + 6
        end

        local ColorMenu
        local FooterCorner
        ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(MenuWidth, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1, function(Active: boolean)
                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                ColorPickerCorner.TopLeftRadius = Half
                ColorPickerCorner.TopRightRadius = Half
                ColorPickerCorner.BottomRightRadius = Active and Zero or Half
                ColorPickerCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = ColorMenu and ColorMenu.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end

                if FooterCorner then
                    FooterCorner.TopLeftRadius = Zero
                    FooterCorner.TopRightRadius = Zero
                    FooterCorner.BottomLeftRadius = Half
                    FooterCorner.BottomRightRadius = Half
                end
            end, false, "no_top_left")
        ColorMenu.List.Padding = UDim.new(0, 0)
        ColorPicker.ColorMenu = ColorMenu

        --// Content Holder \\--
        local ContentHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ContentHolder,
        })

        --// Footer \\--
        local FooterHeight = Library.IsMobile and 30 or 22

        local FooterBackground = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Size = UDim2.new(1, 0, 0, FooterHeight),
            Parent = ColorMenu.Menu,
        })
        FooterCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FooterBackground,
        })
        table.insert(Library.SpecificCorners, FooterCorner)
        Library:MakeLine(FooterBackground, {
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local FooterBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = FooterBackground,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, Info.Resizable and (FooterHeight + 4) or 6),
            Parent = FooterBar,
        })

        local FooterInfoLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = FooterBar,
        })

        local function RefreshFooterInfo()
            FooterInfoLabel.Text = string.format(
                "#%s • %d, %d, %d",
                ColorPicker.Value:ToHex(),
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255)
            )
        end
        RefreshFooterInfo()

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ContentHolder,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, MapSize),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(MapSize, MapSize),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(BarWidth, MapSize),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(BarWidth, MapSize),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        --// Resizing \\--
        local ResizeGrabber
        if Info.Resizable then
            local BaseMapSize = 200
            local BaseBarWidth = BarWidth
            local BasePadding = 6
            local MinMapSize = 140

            ColorPicker.MapWidth = MapSize
            ColorPicker.MapHeight = MapSize

            local function GetBarWidth(MapWidth)
                return math.clamp(math.floor((MapWidth / BaseMapSize) * BaseBarWidth + 0.5), 12, 24)
            end

            local function GetContentWidth(MapWidth)
                local CurrentBarWidth = GetBarWidth(MapWidth)
                local Width = MapWidth + CurrentBarWidth + BasePadding
                if Info.Transparency then
                    Width += (CurrentBarWidth + BasePadding)
                end

                return Width + 12
            end

            local FixedVerticalOverhead = 6 + 6 + 8 + 20 + 8 + 20 + FooterHeight
            if typeof(ColorPicker.Title) == "string" then
                FixedVerticalOverhead += 8 + 8
            end

            local function ClampToViewport(NewWidth, NewHeight)
                local Camera = workspace.CurrentCamera
                if not Camera then
                    return NewWidth, NewHeight
                end

                local ViewportSize = Camera.ViewportSize
                local ScreenMargin = 12

                local MaxWidth = ViewportSize.X - ColorMenu.Menu.AbsolutePosition.X - ScreenMargin
                local MaxHeight = ViewportSize.Y - ColorMenu.Menu.AbsolutePosition.Y - ScreenMargin - FixedVerticalOverhead

                while NewWidth > MinMapSize and GetContentWidth(NewWidth) > MaxWidth do
                    NewWidth -= 4
                end

                if NewHeight > MaxHeight then
                    NewHeight = math.max(MinMapSize, math.floor(MaxHeight))
                end

                return NewWidth, NewHeight
            end

            local function UpdateColorMenuSize(NewWidth, NewHeight)
                NewWidth = math.max(MinMapSize, math.floor(NewWidth + 0.5))
                NewHeight = math.max(MinMapSize, math.floor(NewHeight + 0.5))
                NewWidth, NewHeight = ClampToViewport(NewWidth, NewHeight)

                if NewWidth == ColorPicker.MapWidth and NewHeight == ColorPicker.MapHeight then
                    return
                end

                local CurrentBarWidth = GetBarWidth(NewWidth)
                local CursorSize = math.clamp(math.floor((math.min(NewWidth, NewHeight) / BaseMapSize) * 6 + 0.5), 4, 10)

                ColorHolder.Size = UDim2.new(1, 0, 0, NewHeight)
                SatVipMap.Size = UDim2.fromOffset(NewWidth, NewHeight)
                SatVibCursor.Size = UDim2.fromOffset(CursorSize, CursorSize)
                HueSelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)

                if TransparencySelector then
                    TransparencySelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)
                end

                ColorPicker.MapWidth = NewWidth
                ColorPicker.MapHeight = NewHeight
                ColorMenu:SetSize(UDim2.new(0, GetContentWidth(NewWidth), 0, 0))
            end

            ResizeGrabber = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = FooterBackground,
            })
            local ResizeGrabberIcon = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = ResizeGrabber,
            })
            if ResizeIcon then
                Library:ApplyLucideIcon(ResizeGrabberIcon, ResizeIcon)
            end

            table.insert(ColorPicker.Connections, ResizeGrabber.InputBegan:Connect(function(Input: InputObject)
                Library.CantDragForced = true
                local StartMouse = GetInputLocation(Input)
                local StartWidth = ColorPicker.MapWidth
                local StartHeight = ColorPicker.MapHeight

                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Delta = GetInputLocation(Input) - StartMouse
                    UpdateColorMenuSize(StartWidth + Delta.X, StartHeight + Delta.Y)

                    RunService.RenderStepped:Wait()
                end

                Library.CantDragForced = false
            end))
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local HueBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local RgbBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        --// Context Menu \\--
        local ContextMenu
        ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            ColorPickerCorner.TopLeftRadius = Half
            ColorPickerCorner.BottomLeftRadius = Half
            ColorPickerCorner.TopRightRadius = Active and Zero or Half
            ColorPickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = ContextMenu and ContextMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end
        end, false, "no_top_left")
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                table.insert(ColorPicker.Connections, OnTap(Button, function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end))

                table.insert(ColorPicker.Connections, Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 0.7,
                    }):Play()
                end))

                table.insert(ColorPicker.Connections, Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()
                end))
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            CreateButton("Paste color", function()
                if not Library.CopiedColor then
                    return
                end

                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)

                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// Copy/Paste Buttons \\--
        local ActionHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ActionHolder,
        })

        local CopyColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = CopyColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = CopyColorButton,
            })
        )

        local PasteColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = PasteColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = PasteColorButton,
            })
        )

        local CopyColorOriginalText = CopyColorButton.Text
        local PasteColorOriginalText = PasteColorButton.Text
        local CopyColorResetId = 0
        local PasteColorResetId = 0

        table.insert(ColorPicker.Connections, CopyColorButton.MouseEnter:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseLeave:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseEnter:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseLeave:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, OnTap(CopyColorButton, function()
            Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }

            CopyColorResetId += 1
            local ThisResetId = CopyColorResetId
            CopyColorButton.Text = "Copied color"

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= CopyColorResetId then
                    return
                end

                CopyColorButton.Text = CopyColorOriginalText
            end)
        end))

        table.insert(ColorPicker.Connections, OnTap(PasteColorButton, function()
            PasteColorResetId += 1
            local ThisResetId = PasteColorResetId

            if not Library.CopiedColor then
                PasteColorButton.Text = "Nothing to paste"
            else
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                PasteColorButton.Text = "Pasted color"
            end

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= PasteColorResetId then
                    return
                end

                PasteColorButton.Text = PasteColorOriginalText
            end)
        end))

        --// End \\--
        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")

            RefreshFooterInfo()
        end

        local function ApplyHolderVisual(Disabled: boolean)
            Holder.Active = not Disabled
            HolderStroke.Transparency = Disabled and 0.5 or 0
            Holder.BackgroundTransparency = Disabled and 0.5 or 0

            if Disabled then
                Holder.BackgroundColor3 = ColorPicker.Value:Lerp(Library.Scheme.BackgroundColor, 0.5)
                HolderTransparency.ImageTransparency = math.clamp((1 - ColorPicker.Transparency) + 0.5, 0, 1)
            else
                Holder.BackgroundColor3 = ColorPicker.Value
                HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
                HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)
            end
        end

        function ColorPicker:RunChanged()
            if ParentObj.Disabled then
                return
            end

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:Update()
            ColorPicker:Display()

            local Disabled = ParentObj.Disabled == true
            ApplyHolderVisual(Disabled)

            if Disabled then
                if ColorMenu.Active then
                    ColorMenu:Close()
                end

                if ContextMenu.Active then
                    ContextMenu:Close()
                end
            end

            ColorPicker:RunChanged()
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        table.insert(ColorPicker.Connections, OnTap(Holder, function()
            if ParentObj.Disabled then
                return
            end

            ColorMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, Holder.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ContextMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, SatVipMap.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(GetInputLocation(Input).X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(GetInputLocation(Input).Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(ColorPicker.Connections, HueSelector.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(GetInputLocation(Input).Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        if TransparencySelector then
            table.insert(ColorPicker.Connections, TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(GetInputLocation(Input).Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(ColorPicker.Connections, HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end))

        table.insert(ColorPicker.Connections, RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end))

        for _, BoxPair in {
            { HueBox, HueBoxStroke },
            { RgbBox, RgbBoxStroke }
        } do
            local TextBoxInstance, Stroke = BoxPair[1], BoxPair[2]

            table.insert(ColorPicker.Connections, TextBoxInstance.Focused:Connect(function()
                Library.Registry[Stroke].Color = "AccentColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(ColorPicker.Connections, TextBoxInstance.FocusLost:Connect(function()
                Library.Registry[Stroke].Color = "OutlineColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        ColorPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, ColorPicker)

        ColorPicker.Default = ColorPicker.Value

        function ColorPicker:Destroy()
            ColorPicker.Destroyed = true

            if ColorPicker.Connections then
                for _, Connection in ColorPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if ColorMenu then
                ColorMenu:Destroy()
            end

            if ResizeGrabber then
                ResizeGrabber:Destroy()
            end

            if ContextMenu then
                ContextMenu:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, ColorPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = ColorPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}
do
    local Funcs = {}

    function Funcs:AddDivider(...)
        if self.Destroyed then return nil end

        local Params = select(1, ...)
        local Text
        local MarginTop = 0
        local MarginBottom = 0

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Text,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local X, _ = Library:GetTextBounds(Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X / Library.DPIScale)
            local SizeX = X // 2 + 10

            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        local Divider = {
            Connections = {},
            Destroyed = false,

            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",

            Parent = Groupbox,
        }

        function Divider:SetVisible(Value)
            Holder.Visible = Value == true
            Groupbox:Resize()
        end

        function Divider:Destroy()
            Divider.Destroyed = true

            if Divider.Connections then
                for _, Connection in Divider.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Divider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
        end

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        if self.Destroyed then return nil end

        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Connections = {},
            Destroyed = false,

            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",

            Parent = Groupbox,
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Visible = Label.Visible,
            Parent = Container,
        })

        function Label:Display()
            if not Label.DoesWrap then
                return
            end

            local Width = TextLabel.AbsoluteSize.X / Library.DPIScale
            if Width <= 0 then return end

            local _, Y = Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, Width)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
        end

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            Label:Display()
            Groupbox:Resize()
        end

        if Label.DoesWrap then
            Label:Display()

            local Last = TextLabel.AbsoluteSize
            table.insert(Label.Connections, TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                Label:Display()
                Last = TextLabel.AbsoluteSize

                Groupbox:Resize()
            end))
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        function Label:Destroy()
            Label.Destroyed = true

            if Label.Connections then
                for _, Connection in Label.Connections do
                    Connection:Disconnect()
                end
            end

            if Label.Addons then
                for Index = #Label.Addons, 1, -1 do
                    local Addon = table.remove(Label.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if TextLabel then
                TextLabel:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Label)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Data.Idx then
                Labels[Data.Idx] = nil
            else
                local LblIdx = table.find(Labels, Label)

                if LblIdx then
                    table.remove(Labels, LblIdx)
                end
            end
        end

        return Label
    end

    function Funcs:AddButton(...)
        if self.Destroyed then return nil end

        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick
                Info.Icon = Params.Icon or Params.IconName

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false
                Info.Icon = nil

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,
            Icon = Info.Icon,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Locked = false,

            Base = nil,
            Stroke = nil,
            Content = nil,
            Label = nil,
            IconImage = nil,

            Tween = nil,
            Type = "Button",

            Parent = Groupbox,
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 9),
            Parent = Holder,
        })

        local function ApplyButtonIcon(Button, IconName)
            local Content = Button.Content
            if not Content then
                return
            end

            local ParsedIcon = Library:GetCustomIcon(IconName)
            if ParsedIcon then
                local ColorKey = Button.Risky and "RedColor" or (ParsedIcon.Custom and "WhiteColor" or "FontColor")

                if not Button.IconImage then
                    Button.IconImage = New("ImageLabel", {
                        BackgroundTransparency = 1,
                        ImageColor3 = ColorKey,
                        LayoutOrder = 0,
                        Size = UDim2.fromOffset(14, 14),
                        Parent = Content,
                    })
                else
                    Button.IconImage.ImageColor3 = Library.Scheme[ColorKey]
                    Library.Registry[Button.IconImage].ImageColor3 = ColorKey
                end

                Button.IconImage.ImageTransparency = Button.Disabled and 0.8 or 0.4
                Button.IconImage.Visible = true
                Library:ApplyLucideIcon(Button.IconImage, ParsedIcon)
            elseif Button.IconImage then
                Button.IconImage.Visible = false
            end
        end

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = "",
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            local Content = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(0, 16),
                Parent = Base,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = Content,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Content,
            })

            Button.Content = Content
            Button.Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.fromOffset(0, 16),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = Button.Disabled and 0.8 or 0.4,
                Parent = Content,
            })

            if Button.Risky then
                Button.Label.TextColor3 = Library.Scheme.RedColor
                Library.Registry[Button.Label].TextColor3 = "RedColor"
            end

            ApplyButtonIcon(Button, Button.Icon)

            return Base, Stroke
        end

        local function InitEvents(Button)
            table.insert(Button.Connections, Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenService:Create(Button.IconImage, Library.TweenInfo, {
                        ImageTransparency = 0,
                    }):Play()
                end
            end))
            table.insert(Button.Connections, Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenService:Create(Button.IconImage, Library.TweenInfo, {
                        ImageTransparency = 0.4,
                    }):Play()
                end
            end))

            table.insert(Button.Connections, OnTap(Button.Base, function()
                if Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    local IconWasVisible = false
                    if Button.IconImage then
                        IconWasVisible = Button.IconImage.Visible
                        Button.IconImage.Visible = false
                    end

                    Button.Label.Text = "Are you sure?"
                    Button.Label.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Label].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Label.Text = Button.Text
                    Button.Label.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Label].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Button.IconImage then
                        Button.IconImage.Visible = IconWasVisible
                    end

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait()
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end))
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Connections = {},
                Destroyed = false,

                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,
                Icon = Info.Icon,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,
                Locked = false,

                Base = nil,
                Stroke = nil,
                Content = nil,
                Label = nil,
                IconImage = nil,

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
                SubButton.Label.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                if SubButton.IconImage and SubButton.IconImage.Visible then
                    SubButton.IconImage.ImageTransparency = SubButton.Disabled and 0.8 or 0.4
                end

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
                Library:UpdateAddons(SubButton)
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Label.Text = Text
            end

            function SubButton:SetIcon(Icon: string?)
                SubButton.Icon = Icon
                ApplyButtonIcon(SubButton, Icon)
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            SubButton.AddKeyPicker = BaseAddons.__index.AddKeyPicker

            function SubButton:Destroy()
                SubButton.Destroyed = true

                if SubButton.Connections then
                    for _, Connection in SubButton.Connections do
                        Connection:Disconnect()
                    end
                end

                if SubButton.TooltipTable then
                    SubButton.TooltipTable:Destroy()
                end

                if SubButton.Tween then
                    SubButton.Tween:Destroy()
                end

                if SubButton.Base then
                    SubButton.Base:Destroy()
                end

                if Info.Idx then
                    Buttons[Info.Idx] = nil
                else
                    local BIdx = table.find(Buttons, SubButton)

                    if BIdx then
                        table.remove(Buttons, BIdx)
                    end
                end
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Button.Label.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            if Button.IconImage and Button.IconImage.Visible then
                Button.IconImage.ImageTransparency = Button.Disabled and 0.8 or 0.4
            end

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
            Library:UpdateAddons(Button)
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Label.Text = Text
        end

        function Button:SetIcon(Icon: string?)
            Button.Icon = Icon
            ApplyButtonIcon(Button, Icon)
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        Button.AddKeyPicker = BaseAddons.__index.AddKeyPicker

        function Button:Destroy()
            Button.Destroyed = true

            if Button.Connections then
                for _, Connection in Button.Connections do
                    Connection:Disconnect()
                end
            end

            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
            end

            if Button.Tween then
                Button.Tween:Destroy()
            end

            if Button.SubButton then
                Button.SubButton:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Button)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Info.Idx then
                Buttons[Info.Idx] = nil
            else
                local BIdx = table.find(Buttons, Button)

                if BIdx then
                    table.remove(Buttons, BIdx)
                end
            end
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Checkbox",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })
        if CheckIcon then
            Library:ApplyLucideIcon(CheckImage, CheckIcon)
        end

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(CheckImage, Library.TweenInfo, {
                ImageTransparency = Toggle.Value and 0 or 1,
            }):Play()

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, OnTap(Button, function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if self.Destroyed then return nil end

        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Switch",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, OnTap(Button, function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local BoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
            BoxStroke.Transparency = Input.Disabled and 0.5 or 0

            Box.BackgroundColor3 = Input.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Library.Registry[Box].BackgroundColor3 = Input.Disabled and "BackgroundColor" or "MainColor"
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:RunChanged()
            if Input.Disabled then
                return
            end

            Library:SafeCallback(Input.Callback, Input.Value)
            Library:SafeCallback(Input.Changed, Input.Value)
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            Input:RunChanged()
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            table.insert(Input.Connections, Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end))
        else
            table.insert(Input.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end

                Input:SetValue(Box.Text)
            end))
        end

        table.insert(Input.Connections, Box.Focused:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "AccentColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        table.insert(Input.Connections, Box.FocusLost:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "OutlineColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end

        Input:UpdateColors()
        Options[Idx] = Input

        function Input:Destroy()
            Input.Destroyed = true

            if Input.Connections then
                for _, Connection in Input.Connections do
                    Connection:Disconnect()
                end
            end

            if Input.TooltipTable then
                Input.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Input)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 15),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = "DarkColor",
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local InputTextBox
        local InputTextBoxStroke
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                TextSize = 14,
                ZIndex = Bar.ZIndex + 3,
                Visible = false,
                ClearTextOnFocus = false,
                Parent = Bar,
            })
            InputTextBoxStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = InputTextBox,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Bar,
            })
        )

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Fill,
            })
        )

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            if Info.AllowRightClickInput then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            if Slider.Disabled then
                return
            end

            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            local LastValidText = ""
            table.insert(Slider.Connections, InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local Text = InputTextBox.Text
                local AsNum = tonumber(Text)

                if #tostring(Text) > 0 and not AsNum and Text ~= "-" then
                    InputTextBox.Text = LastValidText
                else
                    if Slider.Rounding == 0 and Text:find("%.") then
                        InputTextBox.Text = LastValidText
                        return
                    end

                    local DecimalPos = Text:find("%.")
                    if DecimalPos and Slider.Rounding > 0 then
                        local Decimals = #Text - DecimalPos
                        if Decimals > Slider.Rounding then
                            InputTextBox.Text = LastValidText
                            return
                        end
                    end

                    LastValidText = Text

                    if AsNum then
                        if AsNum > Slider.Max then
                            InputTextBox.Text = tostring(Slider.Max)
                        elseif AsNum < Slider.Min then
                            InputTextBox.Text = tostring(Slider.Min)
                        end
                    end
                end
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local Num = tonumber(InputTextBox.Text)
                if not Num then
                    return
                end

                Num = Round(Num, Slider.Rounding)
                Slider:SetValue(Num)
            end))

            table.insert(Slider.Connections, InputTextBox.Focused:Connect(function()
                if Slider.Disabled then
                    return
                end

                Library.Registry[InputTextBoxStroke].Color = "AccentColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                if Slider.Disabled then
                    return
                end

                Library.Registry[InputTextBoxStroke].Color = "DarkColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.DarkColor,
                }):Play()
            end))
        end

        local LastTap = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            local ValidInput = IsClickInput(Input) or Input.UserInputType == Enum.UserInputType.MouseButton2
            if not ValidInput or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local IsRightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                local IsDoubleTap = false

                if Library.IsMobile and Input.UserInputType == Enum.UserInputType.Touch then
                    if tick() - LastTap < 0.3 then
                        IsDoubleTap = true
                    end

                    LastTap = tick()
                end

                if IsRightClick or IsDoubleTap then
                    InputTextBox.Text = tostring(Slider.Value)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(Input) then
                return
            end

            local IsTouch = Input.UserInputType == Enum.UserInputType.Touch
            local function ApplyInput()
                local Location = IsTouch and Input.Position.X or Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Slider:RunChanged()
                end
            end

            if IsTouch then
                local Start = Input.Position
                local Sliding = false

                while IsDragInput(Input) and not Slider.Destroyed do
                    local Delta = Input.Position - Start
                    local X, Y = math.abs(Delta.X), math.abs(Delta.Y)

                    if Y > TouchSlop and Y >= X then
                        return
                    end

                    if X > TouchSlop then
                        Sliding = true
                        break
                    end

                    RunService.RenderStepped:Wait()
                end

                if not Sliding then
                    if not Slider.Destroyed and (Input.Position - Start).Magnitude <= TouchSlop then
                        ApplyInput()
                    end

                    return
                end
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                ApplyInput()
                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    function Funcs:AddDropdown(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Dropdown)

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end

        local Dropdown = {
            Connections = {},
            Destroyed = false,

            Text = typeof(Info.Text) == "string" and Info.Text or nil,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,
            ValueImages = Info.ValueImages,

            Multi = Info.Multi,
            DragSelect = Info.Multi and not Library.IsMobile and Info.DragSelect == true,
            KeepDisabledValuePosition = Info.KeepDisabledValuePosition == true,

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            EnablePlayerImages = Info.EnablePlayerImages,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Dropdown",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
            Visible = Dropdown.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Dropdown.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not Info.Text,
            ZIndex = 3,
            Parent = Holder,
        })

        local DisplayContainer = New("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "",
            TextTransparency = 1,
            ZIndex = 2,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = DisplayContainer,
        })

        local DisplayStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = DisplayContainer,
        })

        local DropdownCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = DisplayContainer,
        }); table.insert(Library.SpecificCorners, DropdownCorner)

        local DisplayImage = New("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(-4, 3),
            Size = UDim2.fromOffset(16, 16),
            Image = "",
            ImageTransparency = 1,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local DisplayButton = New("TextButton", {
            Active = not Dropdown.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local ArrowImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Parent = DisplayContainer,
        })
        if ArrowIcon then
            Library:ApplyLucideIcon(ArrowImage, ArrowIcon)
        end

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = DisplayButton,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })

            table.insert(Dropdown.Connections, SearchBox.Focused:Connect(function()
                Library.Registry[DisplayStroke].Color = "AccentColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Dropdown.Connections, SearchBox.FocusLost:Connect(function()
                Library.Registry[DisplayStroke].Color = "OutlineColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        local GetValueImage = function(Value, RawValue)
            if not Value then
                return nil
            end

            local ValueImage = nil
            if Dropdown.SpecialType == "Player" and Dropdown.EnablePlayerImages == true then
                local PlayerValue = Value
                if typeof(PlayerValue) ~= "Instance" and RawValue ~= nil then
                    PlayerValue = RawValue
                end

                if typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") then
                    ValueImage = { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(PlayerValue.UserId)) }
                end
            end

            if Dropdown.ValueImages then
                local IconRef = Dropdown.ValueImages[Value]
                if IconRef == nil and RawValue ~= nil then
                    IconRef = Dropdown.ValueImages[RawValue]
                end

                if IconRef then
                    ValueImage = Library:GetCustomIcon(IconRef)
                end
            end

            return ValueImage
        end

        local MenuTable
        MenuTable = Library:AddContextMenu(
            DisplayContainer,
            function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), 0)
            end,
            function()
                return { 0.5, DisplayContainer.AbsoluteSize.Y + 1.5 }
            end,
            2,
            function(Active: boolean)
                DisplayButton.TextTransparency = (Active and SearchBox) and 1 or 0

                ArrowImage.ImageTransparency = Active and 0 or 0.5
                ArrowImage.Rotation = Active and 180 or 0

                if SearchBox then
                    SearchBox.Text = ""
                    SearchBox.Visible = Active
                end

                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                DropdownCorner.TopLeftRadius = Half
                DropdownCorner.TopRightRadius = Half
                DropdownCorner.BottomRightRadius = Active and Zero or Half
                DropdownCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = MenuTable and MenuTable.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Zero
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end,
            false,
            "bottom",
            "Dropdown"
        )
        Dropdown.Menu = MenuTable

        local ItemHeight = Library.IsMobile and 28 or 21
        local PoolSize = math.max(1, Info.MaxVisibleDropdownItems + 2)
        local Pool = {}
        local FilteredEntries = {}

        function Dropdown:RecalculateListSize(Count)
            local ItemCount = Count or #FilteredEntries
            local Y = math.clamp(ItemCount * ItemHeight, 0, Info.MaxVisibleDropdownItems * ItemHeight)

            MenuTable.Menu.CanvasSize = UDim2.fromOffset(0, ItemCount * ItemHeight)

            MenuTable:SetSize(function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), Y)
            end)
        end

        function Dropdown:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayImage.ImageTransparency = Dropdown.Disabled and 0.8 or 0
            ArrowImage.ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5
        end

        function Dropdown:Display()
            if Library.Unloaded then
                return
            end

            local Str = ""
            local ValueImage = nil
            local IsDictionary = not IsSequentialArray(Dropdown.Values)

            if Info.Multi then
                for Key, RawValue in Dropdown.Values do
                    local Value = IsDictionary and Key or RawValue

                    if Dropdown.Value[Value] then
                        if not ValueImage then
                            ValueImage = GetValueImage(Value, RawValue)
                        end

                        Str = Str
                            .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(RawValue)) or tostring(RawValue))
                            .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                local DisplayValue = Dropdown.Value
                if IsDictionary and Dropdown.Value ~= nil then
                    DisplayValue = Dropdown.Values[Dropdown.Value]
                end

                ValueImage = GetValueImage(Dropdown.Value, DisplayValue)
                Str = DisplayValue and tostring(DisplayValue) or ""

                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Str))
                end
            end

            if #Str > 25 then
                Str = Str:sub(1, 22) .. "..."
            end

            DisplayButton.Text = (Str == "" and "---" or Str)

            if ValueImage then
                Library:ApplyLucideIcon(DisplayImage, ValueImage)
                DisplayImage.ImageTransparency = 0
            else
                DisplayImage.Image = ""
                DisplayImage.ImageTransparency = 1
            end

            DisplayButton.Size = ValueImage and UDim2.new(1, -8, 0, 21) or UDim2.new(1, 0, 0, 21)
            DisplayButton.Position = ValueImage and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues(ReturnCount)
            local Table = {}

            if Info.Multi then
                for Value, _ in Dropdown.Value do
                    table.insert(Table, Value)
                end
            else
                if Dropdown.Value then
                    table.insert(Table, Dropdown.Value)
                end
            end

            return ReturnCount == true and GetTableSize(Table) or Table
        end

        local DragSelecting = false
        local DragStartIndex = nil
        local DragPrevMin = nil
        local DragPrevMax = nil
        local DragLastIndex = nil
        local DragInitialValues = {}
        local DragInputEndedConn = nil
        local DragInputChangedConn = nil

        local function RecomputeFilteredEntries()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local IsDictionary = not IsSequentialArray(Values)

            --// Fuzzy-match dropdown values the same way the sidebar search
            --// does, so e.g. "clr" can find "Clear Inventory" in a list \\--
            local SearchQuery = SearchBox and NormalizeSearch(SearchBox.Text:lower()) or ""
            local IsSearching = SearchQuery ~= ""

            local EnabledList, DisabledList = {}, {}
            local Pending = {}

            for Key, RawValue in Values do
                local Value = IsDictionary and Key or RawValue

                local FormattedValue = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

                local MatchScore = 0
                if IsSearching then
                    local Matched, Score = FuzzyScore(FormattedValue:lower(), SearchQuery)
                    if not Matched then
                        continue
                    end
                    MatchScore = Score
                end

                local IsDisabled = table.find(DisabledValues, Value) ~= nil
                    or (RawValue ~= nil and RawValue ~= Value and table.find(DisabledValues, RawValue) ~= nil)

                local Entry = {
                    Value = Value,
                    RawValue = RawValue,
                    FormattedValue = FormattedValue,
                    IsDisabled = IsDisabled,
                    ValueImage = GetValueImage(Value, RawValue),
                    SortKey = Key,
                    MatchScore = MatchScore,
                    Order = #Pending + 1,
                }

                table.insert(Pending, Entry)
            end

            if IsSearching then
                --// Best matches first; ties fall back to original order \\--
                table.sort(Pending, function(A, B)
                    if A.MatchScore ~= B.MatchScore then
                        return A.MatchScore > B.MatchScore
                    end
                    return A.Order < B.Order
                end)
            elseif not IsDictionary then
                table.sort(Pending, function(A, B)
                    return A.SortKey < B.SortKey
                end)
            end

            table.clear(FilteredEntries)

            if Dropdown.KeepDisabledValuePosition then
                for _, Entry in Pending do
                    table.insert(FilteredEntries, Entry)
                end
                return
            end

            for _, Entry in Pending do
                if Entry.IsDisabled then
                    table.insert(DisabledList, Entry)
                else
                    table.insert(EnabledList, Entry)
                end
            end

            for _, Entry in EnabledList do
                table.insert(FilteredEntries, Entry)
            end
            for _, Entry in DisabledList do
                table.insert(FilteredEntries, Entry)
            end
        end

        local function GetFirstVisibleIndex()
            local Total = #FilteredEntries
            if Total <= PoolSize then
                return 1
            end

            local MaxFirst = Total - PoolSize + 1
            local ScrollY = MenuTable.Menu.CanvasPosition.Y / Library.DPIScale
            local Index = math.floor(ScrollY / ItemHeight) + 1
            return math.clamp(Index, 1, MaxFirst)
        end

        function Dropdown:RefreshPool()
            local Total = #FilteredEntries
            local First = GetFirstVisibleIndex()

            for SlotIndex, Row in Pool do
                local DataIndex = First + SlotIndex - 1
                local Entry = FilteredEntries[DataIndex]

                Row.Entry = Entry
                Row.Index = Entry and DataIndex or nil

                if not Entry then
                    Row.Container.Visible = false
                    continue
                end

                Row.Container.Visible = true
                Row.Container.Position = UDim2.fromOffset(0, (DataIndex - 1) * ItemHeight)

                local IsLast = DataIndex == Total
                Row.Corner.BottomRightRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                Row.Corner.BottomLeftRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)

                Row.Button.Text = Entry.FormattedValue

                if Entry.ValueImage then
                    Row.Image.Visible = true
                    Library:ApplyLucideIcon(Row.Image, Entry.ValueImage)
                    Row.Button.Size = UDim2.new(1, -18, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(18, 0)
                else
                    Row.Image.Visible = false
                    Row.Button.Size = UDim2.new(1, 0, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(0, 0)
                end

                Row:UpdateButton()
            end
        end

        function Dropdown:RunChanged()
            if Dropdown.Disabled then
                return
            end

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        local function StopDragSelect()
            DragSelecting = false
            DragStartIndex = nil
            DragPrevMin = nil
            DragPrevMax = nil
            DragLastIndex = nil
            table.clear(DragInitialValues)

            if DragInputEndedConn then
                DragInputEndedConn:Disconnect()
                DragInputEndedConn = nil
            end

            if DragInputChangedConn then
                DragInputChangedConn:Disconnect()
                DragInputChangedConn = nil
            end
        end

        local DragActiveCount = 0

        local function ApplyDragIndex(Index, InRange)
            local Entry = FilteredEntries[Index]
            if not Entry or Entry.IsDisabled then
                return
            end

            local Try = DragInitialValues[Entry.Value]
            if InRange then
                Try = not Try
            end

            local WantActive = Try and true or false
            local IsActive = Dropdown.Value[Entry.Value] and true or false
            if WantActive == IsActive then
                return
            end

            if not WantActive and DragActiveCount == 1 and not Info.AllowNull then
                return
            end

            Dropdown.Value[Entry.Value] = WantActive and true or nil
            DragActiveCount += WantActive and 1 or -1
        end

        local function ApplyDragRange(From, To, InRange)
            for Index = From, To do
                ApplyDragIndex(Index, InRange)
            end
        end

        local function UpdateDrag(CurrentIndex)
            if CurrentIndex == nil or CurrentIndex == DragLastIndex then
                return
            end

            DragLastIndex = CurrentIndex

            local Min = math.min(DragStartIndex, CurrentIndex)
            local Max = math.max(DragStartIndex, CurrentIndex)
            DragActiveCount = Dropdown:GetActiveValues(true)

            if DragPrevMin == nil then
                ApplyDragRange(Min, Max, true)
            else
                if DragPrevMin < Min then
                    ApplyDragRange(DragPrevMin, Min - 1, false)
                end
                if DragPrevMax > Max then
                    ApplyDragRange(Max + 1, DragPrevMax, false)
                end
                if Min < DragPrevMin then
                    ApplyDragRange(Min, DragPrevMin - 1, true)
                end
                if Max > DragPrevMax then
                    ApplyDragRange(DragPrevMax + 1, Max, true)
                end
            end

            DragPrevMin = Min
            DragPrevMax = Max

            for _, OtherRow in Pool do
                OtherRow:UpdateButton()
            end
        end

        local function CreatePoolRow()
            local Row = {
                Entry = nil,
                Index = nil
            }

            local Container = New("Frame", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Visible = false,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Container,
            }); table.insert(Library.SpecificCorners, Corner)

            local Image = New("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "",
                ImageTransparency = 0.5,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(4, 3),
                Visible = false,
                Parent = Container,
            })

            local Button = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                Parent = Button,
            })

            Row.Container = Container
            Row.Corner = Corner
            Row.Image = Image
            Row.Button = Button

            function Row:UpdateButton()
                local Entry = Row.Entry
                if not Entry then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                Row.Selected = Selected and true or false

                Container.BackgroundTransparency = Selected and 0 or 1
                Button.TextTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5

                if Entry.ValueImage then
                    Image.ImageTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5
                end
            end

            table.insert(Dropdown.Connections, OnTap(Button, function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or DragSelecting then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                local Try = not Selected
                if not (Dropdown:GetActiveValues(true) == 1 and not Try and not Info.AllowNull) then
                    Selected = Try
                    if Info.Multi then
                        Dropdown.Value[Entry.Value] = Selected and true or nil
                    else
                        Dropdown.Value = Selected and Entry.Value or nil
                    end

                    for _, OtherRow in Pool do
                        OtherRow:UpdateButton()
                    end
                end

                Row:UpdateButton()
                Dropdown:Display()

                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end))

            table.insert(Dropdown.Connections, Button.MouseEnter:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 0.85,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.25,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.25,
                    }):Play()
                end
            end))

            table.insert(Dropdown.Connections, Button.MouseLeave:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.5,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.5,
                    }):Play()
                end
            end))

            table.insert(Dropdown.Connections, Button.InputBegan:Connect(function(StartInput)
                if not (Info.Multi and Dropdown.DragSelect and not Library.IsMobile) then
                    return
                end

                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if not IsMouseInput(StartInput) then
                    return
                end

                DragSelecting = true
                DragStartIndex = Row.Index
                table.clear(DragInitialValues)

                for _, FilteredEntry in FilteredEntries do
                    DragInitialValues[FilteredEntry.Value] = Dropdown.Value[FilteredEntry.Value]
                end

                UpdateDrag(Row.Index)

                if DragInputEndedConn then DragInputEndedConn:Disconnect() end
                if DragInputChangedConn then DragInputChangedConn:Disconnect() end

                DragInputChangedConn = Library:GiveSignal(UserInputService.InputChanged:Connect(function(ChangeInput)
                    if not IsMovementInput(ChangeInput) and ChangeInput ~= StartInput then
                        return
                    end

                    local Pos = ChangeInput.Position
                    for _, OtherRow in Pool do
                        if OtherRow.Entry and Library:MouseIsOverFrame(OtherRow.Button, Pos) then
                            UpdateDrag(OtherRow.Index)
                            break
                        end
                    end
                end))

                DragInputEndedConn = Library:GiveSignal(UserInputService.InputEnded:Connect(function(EndInput)
                    if EndInput ~= StartInput and not (IsMouseInput(EndInput) and EndInput.UserInputType == StartInput.UserInputType) then
                        return
                    end

                    Dropdown:Display()
                    Library:UpdateDependencyBoxes()
                    Dropdown:RunChanged()

                    StopDragSelect()
                end))

                table.insert(Dropdown.Connections, DragInputEndedConn)
                table.insert(Dropdown.Connections, DragInputChangedConn)
            end))

            return Row
        end

        function Dropdown:BuildDropdownList()
            StopDragSelect()

            RecomputeFilteredEntries()

            MenuTable.Menu.CanvasPosition = Vector2.new(0, 0)

            Dropdown:RefreshPool()
            Dropdown:RecalculateListSize(#FilteredEntries)
        end

        for _ = 1, PoolSize do
            table.insert(Pool, CreatePoolRow())
        end

        table.insert(Dropdown.Connections, MenuTable.Menu:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Dropdown:RefreshPool()
        end))

        local function ValueExists(Val)
            if IsSequentialArray(Dropdown.Values) then
                for _, Existing in Dropdown.Values do
                    if Existing == Val then
                        return true
                    end
                end

                return false
            end

            return Dropdown.Values[Val] ~= nil
        end

        function Dropdown:SetValue(Value)
            if Info.Multi then
                if typeof(Value) == "string" then
                    Value = if Value == "" then {} else { [Value] = true }
                end

                local Table = {}

                for Val, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and ValueExists(Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if ValueExists(Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Row in Pool do
                Row:UpdateButton()
            end

            if not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            Dropdown:RunChanged()
        end

        function Dropdown:SetValues(Values)
            Dropdown.Values = Values

            local Changed = false
            if Info.Multi then
                for Val in Dropdown.Value do
                    if not ValueExists(Val) then
                        Dropdown.Value[Val] = nil
                        Changed = true
                    end
                end

            elseif Dropdown.Value ~= nil and not ValueExists(Dropdown.Value) then
                Dropdown.Value = nil
                Changed = true
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()

            if Changed and not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if Changed then
                Dropdown:RunChanged()
            end
        end

        function Dropdown:AddValues(Values)
            if typeof(Values) ~= "table" and typeof(Values) ~= "string" then
                return
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            if IsDictionary then
                if typeof(Values) == "string" then
                    Dropdown.Values[Values] = Values

                elseif IsSequentialArray(Values) then
                    for _, Val in Values do
                        Dropdown.Values[Val] = Val
                    end

                else
                    for Key, Val in Values do
                        Dropdown.Values[Key] = Val
                    end
                end
            else
                if typeof(Values) == "table" then
                    for _, Val in Values do
                        table.insert(Dropdown.Values, Val)
                    end
                else
                    table.insert(Dropdown.Values, Values)
                end
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in DisabledValues do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            Dropdown.ValueImages = ValueImages
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            for key, val in ValueImages do
                Dropdown.ValueImages[key] = val
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            DisplayButton.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()

            Library:UpdateDependencyBoxes()
        end

        function Dropdown:SetVisible(Visible: boolean)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible
            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            Dropdown.Text = Text
            Holder.Size = UDim2.new(1, 0, 0, Text and 39 or 21)

            Label.Text = Text and Text or ""
            Label.Visible = not not Text
        end

        function Dropdown:SetDragSelect(Value: boolean)
            if not Info.Multi or Library.IsMobile then
                Value = false
            end

            Dropdown.DragSelect = Value == true
            Dropdown:BuildDropdownList()
        end

        local ToggleDropdown = function()
            if Dropdown.Disabled then
                return
            end

            MenuTable:Toggle()
        end

        table.insert(Dropdown.Connections, OnTap(DisplayContainer, ToggleDropdown))
        table.insert(Dropdown.Connections, OnTap(DisplayButton, ToggleDropdown))

        if SearchBox then
            table.insert(Dropdown.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList))
        end

        local Defaults = (function()
            local Resolved = {}
            local Default = Info.Default
            if Default == nil then
                return Resolved
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            local function ResolveOne(Candidate)
                if IsDictionary then
                    return Dropdown.Values[Candidate] ~= nil and Candidate or nil
                end

                for _, Existing in Dropdown.Values do
                    if Existing == Candidate then
                        return Existing
                    end
                end

                return nil
            end

            local DefaultType = typeof(Default)
            if DefaultType == "string" then
                local Value = ResolveOne(Default)
                if Value ~= nil then
                    table.insert(Resolved, Value)
                end

            elseif DefaultType == "table" then
                for _, Candidate in Default do
                    local Value = ResolveOne(Candidate)
                    if Value ~= nil then
                        table.insert(Resolved, Value)
                    end
                end

            elseif Dropdown.Values[Default] ~= nil then
                table.insert(Resolved, IsDictionary and Default or Dropdown.Values[Default])
            end

            return Resolved
        end)()

        for _, SelectValue in Defaults do
            if Info.Multi then
                Dropdown.Value[SelectValue] = true
            else
                Dropdown.Value = SelectValue
                break
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, DisplayContainer)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        table.insert(Groupbox.Elements, Dropdown)

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        function Dropdown:Destroy()
            Dropdown.Destroyed = true

            StopDragSelect()

            if Dropdown.Connections then
                for _, Connection in Dropdown.Connections do
                    Connection:Disconnect()
                end
            end

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable:Destroy()
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Dropdown)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Dropdown
    end

    function Funcs:AddViewport(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Connections = {},
            Destroyed = false,

            Object = ViewportObject :: PVInstance,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = (Viewport.Object :: PVInstance):GetPivot().Position

            Viewport.Camera.CFrame = CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        table.insert(Viewport.Connections, ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = false
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = true
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Touch and not Pinching) then
                Dragging = true
                LastMousePos = input.Position
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = (Viewport.Object :: PVInstance):GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end))

        table.insert(Viewport.Connections, UserInputService.TouchPinch:Connect(function(touchPositions, _, _, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        ;(Viewport.Object :: PVInstance).Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            ;(Viewport.Object :: PVInstance).Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        function Viewport:Destroy()
            Viewport.Destroyed = true

            if Viewport.Connections then
                for _, Connection in Viewport.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Viewport)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Connections = {},
            Destroyed = false,

            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ScaleType = Image.ScaleType,
            Parent = Box,
        }

        local Icon = Library:GetCustomIcon(Image.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            Library:ApplyLucideIcon(ImageLabel, Icon)
            Image.Image = Icon.Url
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        function Image:Destroy()
            Image.Destroyed = true

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Image)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Connections = {},
            Destroyed = false,

            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        function Video:Destroy()
            Video.Destroyed = true

            if Video.Connections then
                for _, Connection in Video.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Video)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Connections = {},
            Destroyed = false,

            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        function Passthrough:Destroy()
            Passthrough.Destroyed = true

            if Passthrough.Connections then
                for _, Connection in Passthrough.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Passthrough)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Passthrough
    end

    function Funcs:AddDependencyBox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {}
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        table.insert(Depbox.Connections, DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end))

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        table.insert(Depbox.Connections, DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end))

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        function Depbox:Destroy()
            Depbox.Destroyed = true

            if Depbox.Connections then
                for _, Connection in Depbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in Depbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in Depbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepboxContainer then
                DepboxContainer:Destroy()
            end

            local ElemIdx = table.find(Groupbox.DependencyBoxes, Depbox)
            if ElemIdx then
                table.remove(Groupbox.DependencyBoxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, Depbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
        end

        function DepGroupbox:Update(CancelSearch)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox :: any)

        function DepGroupbox:Destroy()
            DepGroupbox.Destroyed = true

            if DepGroupbox.Connections then
                for _, Connection in DepGroupbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in DepGroupbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in DepGroupbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepGroupboxContainer then
                DepGroupboxContainer:Destroy()
            end

            local ElemIdx = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if ElemIdx then
                table.remove(Tab.DependencyGroupboxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, DepGroupbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return DepGroupbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
end

function Library:SetBackgroundImage(Image: string | number)
    assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected string/number got " .. typeof(Image))

    Library.Scheme.BackgroundImage = Image
    if Library.Window then
        Library.Window:SetBackgroundImage(Image)
    end

    Library:UpdateColorsUsingRegistry()
end

function Library:UpdateNotificationPositions(Snap: boolean?)
    local IsLeft = Library.NotifySide:lower() == "left"
    local XScale = IsLeft and 0 or 1
    local RunningY = 0

    for _, FakeBackground in NotifyOrder do
        local Data = Library.Notifications[FakeBackground]
        if not (Data and FakeBackground.Parent) then continue end

        local Target = UDim2.new(XScale, 0, 0, RunningY)
        if Snap or not Data.PositionInitialized then
            FakeBackground.Position = Target
            Data.PositionInitialized = true

        elseif FakeBackground.Position ~= Target then
            TweenService:Create(FakeBackground, Library.NotifyTweenInfo, {
                Position = Target,
            }):Play()
        end

        RunningY = RunningY + FakeBackground.AbsoluteSize.Y / Library.DPIScale + 8
    end
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    local IsLeft = Side:lower() == "left"
    if IsLeft then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
    end

    for FakeBackground in Library.Notifications do
        if not (FakeBackground and FakeBackground.Parent) then continue end
        FakeBackground.AnchorPoint = if IsLeft then Vector2.new(0, 0) else Vector2.new(1, 0)
    end

    if Library.UpdateNotificationPositions then
        Library:UpdateNotificationPositions(true)
    end
end

function Library:Notify(...)
    local Data = {}
    local Info = select(1, ...)

    if typeof(Info) == "table" then
        Data.Title = tostring(Info.Title)
        Data.TitleColor = Info.TitleColor

        Data.Description = tostring(Info.Description)
        Data.DescriptionColor = Info.DescriptionColor

        Data.Time = Info.Time or 5
        Data.SoundId = Info.SoundId
        Data.Steps = Info.Steps
        Data.Persist = Info.Persist

        Data.Callback = typeof(Info.Callback) == "function" and Info.Callback or nil
        Data.Closable = Info.Closable == true

        Data.Icon = Info.Icon
        Data.BigIcon = Info.BigIcon
        Data.IconColor = Info.IconColor

        Data.Volume = tonumber(Info.Volume) or 3
    else
        Data.Description = tostring(Info)
        Data.Time = select(2, ...) or 5
        Data.SoundId = select(3, ...)
        Data.Volume = select(4, ...) or 3
    end
    Data.Destroyed = false

    local DeletedInstance = false
    local DeleteConnection = nil
    if typeof(Data.Time) == "Instance" then
        DeleteConnection = Data.Time.Destroying:Connect(function()
            DeletedInstance = true

            DeleteConnection:Disconnect()
            DeleteConnection = nil
        end)
    end

    local FakeBackground = New("Frame", {
        AnchorPoint = Library.NotifySide:lower() == "left" and Vector2.new(0, 0) or Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 0),
        Visible = false,
        Parent = NotificationArea,
    })

    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "MainColor",
        Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, 0) or UDim2.new(1, 8, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 5,
        Parent = FakeBackground,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local ContentHolder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = ContentHolder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = ContentHolder,
    })

    local CloseButton
    if Data.Closable then
        CloseButton = New("ImageButton", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Image = CloseIcon and CloseIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = CloseIcon and CloseIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = CloseIcon and CloseIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -8, 0, 8),
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 6,
            Parent = Holder,
        })

        CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseButton, Library.TweenInfo, {
                ImageTransparency = 0,
            }):Play()
        end)
        CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseButton, Library.TweenInfo, {
                ImageTransparency = 0.5,
            }):Play()
        end)
        OnTap(CloseButton, function()
            Data:Destroy("user")
        end)
    end

    local ContentContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentHolder,
    })

    if Data.BigIcon then
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ContentContainer,
        })
    end

    local BigIconLabel
    if Data.BigIcon then
        local ParsedIcon = Library:GetCustomIcon(Data.BigIcon)
        if ParsedIcon then
            BigIconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(24, 24),
                ImageColor3 = Data.IconColor or "AccentColor",
                Parent = ContentContainer,
            })
            Library:ApplyLucideIcon(BigIconLabel, ParsedIcon)
        end
    end

    local TextContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentContainer,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = TextContainer,
    })

    local TitleContainer
    if Data.Title then
        TitleContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0),
            Parent = TextContainer,
        })
    end

    local IconLabel
    if Data.Icon and TitleContainer then
        local ParsedIcon = Library:GetCustomIcon(Data.Icon)
        if ParsedIcon then
            IconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(15, 15),
                ImageColor3 = Data.IconColor or "FontColor",
                Parent = TitleContainer,
            })
            Library:ApplyLucideIcon(IconLabel, ParsedIcon)
        end
    end

    local Title
    local Desc
    local TitleX = 0
    local DescX = 0

    local TimerFill

    if Data.Title then
        Title = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (IconLabel and 21 or 0), 0.5, 0),
            Size = UDim2.fromScale(0, 0),
            Text = Data.Title,
            TextColor3 = Data.TitleColor or "FontColor",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Parent = TitleContainer,
        })
    end

    if Data.Description then
        Desc = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Text = Data.Description,
            TextColor3 = Data.DescriptionColor or "FontColor",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = TextContainer,
        })
    end

    function Data:Resize()
        local ExtraWidth = BigIconLabel and 32 or 0
        local IconWidth = IconLabel and 21 or 0
        local CloseWidth = Data.Closable and 20 or 0
        local MaxTextWidth = math.max(
            40,
            (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth - CloseWidth
        )

        if Title then
            local X, Y = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, MaxTextWidth - IconWidth)
            Title.Size = UDim2.fromOffset(X, Y)
            TitleX = X + IconWidth
            TitleContainer.Size = UDim2.fromOffset(TitleX, math.max(Y, IconLabel and 16 or 0))
        end

        if Desc then
            local X, Y = Library:GetTextBounds(Desc.Text, Desc.FontFace, Desc.TextSize, MaxTextWidth)
            Desc.Size = UDim2.fromOffset(X, Y)
            DescX = X
        end

        FakeBackground.Size = UDim2.fromOffset(math.max(TitleX, DescX) + 24 + ExtraWidth + CloseWidth, 0)

        if Library.Notifications[FakeBackground] then
            task.defer(function()
                if Data.Destroyed or not FakeBackground.Parent then
                    return
                end

                if FakeBackground.AbsoluteSize.Y <= 0 then
                    task.defer(function()
                        if Data.Destroyed or not FakeBackground.Parent then
                            return
                        end

                        Library:UpdateNotificationPositions(true)
                    end)
                    return
                end

                Library:UpdateNotificationPositions(true)
            end)
        end
    end

    function Data:ChangeTitle(Text)
        if Title then
            Data.Title = tostring(Text)
            Title.Text = Data.Title
            Data:Resize()
        end
    end

    function Data:ChangeDescription(Text)
        if Desc then
            Data.Description = tostring(Text)
            Desc.Text = Data.Description
            Data:Resize()
        end
    end

    function Data:ChangeStep(NewStep)
        if TimerFill and Data.Steps then
            NewStep = math.clamp(NewStep or 0, 0, Data.Steps)
            TimerFill.Size = UDim2.fromScale(NewStep / Data.Steps, 1)
        end
    end

    function Data:Destroy(Reason)
        if Data.Destroyed then
            return
        end

        Reason = Reason or "script"
        Data.Destroyed = true

        if Data.Callback then
            pcall(Data.Callback, Reason)
        end

        if typeof(Data.Time) == "Instance" then
            pcall(Data.Time.Destroy, Data.Time)
        end

        if DeleteConnection then
            DeleteConnection:Disconnect()
        end

        if FakeBackground then
            local Idx = table.find(NotifyOrder, FakeBackground)
            if Idx then
                table.remove(NotifyOrder, Idx)
            end
        end

        Library:UpdateNotificationPositions()

        TweenService
            :Create(Holder, Library.NotifyTweenInfo, {
                Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
            })
            :Play()

        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[FakeBackground] = nil
            FakeBackground:Destroy()
        end)
    end

    local TimerHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = (Data.Persist ~= true and typeof(Data.Time) ~= "Instance") or typeof(Data.Steps) == "number",
        Parent = ContentHolder,
    })
    local TimerBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = TimerHolder,
    })
    TimerFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = TimerBar,
    })

    if typeof(Data.Time) == "Instance" then
        TimerFill.Size = UDim2.fromScale(0, 1)
    end
    if Data.SoundId then
        local SoundId = Data.SoundId
        if typeof(SoundId) == "number" then
            SoundId = string.format("rbxassetid://%d", SoundId)
        end

        New("Sound", {
            SoundId = SoundId,
            Volume = tonumber(Data.Volume) or 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    Data.Holder = Holder

    table.insert(NotifyOrder, FakeBackground)
    Library.Notifications[FakeBackground] = Data

    Data:Resize()

    FakeBackground.Visible = true
    TweenService:Create(Holder, Library.NotifyTweenInfo, {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.defer(function()
        if not Data.Destroyed then
            Library:UpdateNotificationPositions(true)
        end
    end)

    task.delay(Library.NotifyTweenInfo.Time, function()
        if Data.Persist then
            return
        elseif typeof(Data.Time) == "Instance" then
            repeat
                task.wait()
            until DeletedInstance or Data.Destroyed
        else
            TweenService
                :Create(TimerFill, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromScale(0, 1),
                })
                :Play()
            task.wait(Data.Time)
        end

        Data:Destroy("timer")
    end)

    return Data
end

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Vector2.new(math.min(WindowInfo.MinContainerWidth, MaxX), Library.OriginalMinSize.Y)

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font :: any)
    end
    WindowInfo.CornerRadius = math.min(WindowInfo.CornerRadius, 20)

    local TabButtonsStyle = WindowInfo.TabButtonsStyle

    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64 + TabButtonsStyle.Padding * 2, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.CompactWidthActivation)
    WindowInfo.SnapDistance = math.max(0, WindowInfo.SnapDistance)
    WindowInfo.SnapMargin = math.max(0, WindowInfo.SnapMargin)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch

    Library.Animations = WindowInfo.Animations
    Library.TabTransitionInfo = TweenInfo.new(
        math.max(0, WindowInfo.TabTransitionTime or 0.22),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    Library.TabSwipeOffset = math.max(1, WindowInfo.TabSwipeOffset or 26)
    Library.TabSwipeFrom = WindowInfo.TabSwipeFrom or "right"

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local HasBackgroundImage = false
    local BottomBackground
    local BottomBackgroundCorner
    local FooterLabel
    local TopBar
    local WindowSnapConfig = {
        Enabled = WindowInfo.Snapping,
        Distance = WindowInfo.SnapDistance,
        Margin = WindowInfo.SnapMargin,
        AvoidCoreGui = WindowInfo.SnapAvoidCoreGui,
    }

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth

    do
        Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)
        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            Parent = MainFrame,
            ZIndex = 2
        })

        local BackgroundIcon = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        HasBackgroundImage = BackgroundIcon ~= nil
        BackgroundImage = New("ImageLabel", {
            Active = false,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Stretch,
            ZIndex = Overlay.ZIndex + 1,
            BackgroundTransparency = 1,
            ImageTransparency = 0.75,
            Visible = false,
            Parent = ScreenGui,
        })
        if BackgroundIcon then
            Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
        end

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BackgroundImage,
            })
        )

        --// Accent Glow \\--
        local AccentGlow
        if WindowInfo.AccentGlow then
            AccentGlow = New("ImageLabel", {
                Active = false,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = "rbxassetid://6015897843",
                ImageColor3 = "AccentColor",
                ImageTransparency = 0.45,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(49, 49, 450, 450),
                Visible = false,
                ZIndex = 0,
                Parent = ScreenGui,
            })
        end

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not (BackgroundImage and MainFrame) then
                return
            end

            if AccentGlow then
                AccentGlow.Visible = MainFrame.Visible
                if MainFrame.Visible then
                    local Pos, Size = MainFrame.AbsolutePosition, MainFrame.AbsoluteSize
                    AccentGlow.Position = UDim2.fromOffset(Pos.X + Size.X / 2, Pos.Y + Size.Y / 2)
                    AccentGlow.Size = UDim2.fromOffset(Size.X + 44, Size.Y + 44)
                end
            end

            local ShouldShow = HasBackgroundImage and MainFrame.Visible
            BackgroundImage.Visible = ShouldShow

            if not ShouldShow then
                return
            end

            BackgroundImage.Position = UDim2.fromOffset(
                MainFrame.AbsolutePosition.X,
                MainFrame.AbsolutePosition.Y
            )
            BackgroundImage.Size = UDim2.fromOffset(
                MainFrame.AbsoluteSize.X,
                MainFrame.AbsoluteSize.Y
            )
        end))

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true, WindowSnapConfig)

        --// Title \\--
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, InitialLeftWidth, 1, 0),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.SpinningLogo then
            WindowIcon = New("ImageLabel", {
                ImageColor3 = WindowInfo.SpinLogoColor or "WhiteColor",
                ScaleType = Enum.ScaleType.Fit,
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
            Library:AttachSpinningLogo(WindowIcon, MainFrame, WindowInfo.SpinFPS)
        elseif WindowInfo.Icon then
            local Icon = Library:GetCustomIcon(WindowInfo.Icon)
            WindowIcon = New("ImageLabel", {
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
            if Icon then
                Library:ApplyLucideIcon(WindowIcon, Icon)
            end
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        local X = Library:GetTextBounds(
            WindowInfo.Title,
            Library.Scheme.Font,
            20,
            (TitleHolder.AbsoluteSize.X / Library.DPIScale) - (WindowInfo.Icon and WindowInfo.IconSize.X.Offset + 6 or 0) - 12
        )
        WindowTitle = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, X, 1, 0),
            Text = WindowInfo.Title,
            TextSize = 20,
            Parent = TitleHolder,
        })

        --// Top Right Bar \\--
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -86, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 94 - 1, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(WindowInfo.DisableSearch and 1 or 0.5, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            PlaceholderText = "Search",
            Size = WindowInfo.SearchbarSize,
            TextScaled = true,
            Visible = not (WindowInfo.DisableSearch or false),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        local SearchBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        Library:GiveSignal(SearchBox.Focused:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "AccentColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        Library:GiveSignal(SearchBox.FocusLost:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "OutlineColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            local SearchIconImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
            Library:ApplyLucideIcon(SearchIconImage, SearchIcon)
        end

        --// Top Right Icons (move + resize) \\--
        if MoveIcon then
            local MoveIconImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                ImageColor3 = "AccentColor",
                Position = UDim2.new(1, -46, 0.5, 0),
                Size = UDim2.fromOffset(26, 26),
                Parent = TopBar,
            })
            Library:ApplyLucideIcon(MoveIconImage, MoveIcon)
        end

        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                Active = true,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -10, 0, 24),
                Size = UDim2.fromOffset(30, 30),
                Text = "",
                ZIndex = 5,
                Parent = MainFrame,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
            end)

            local WindowResizeIcon = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageColor3 = "AccentColor",
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(24, 24),
                ZIndex = 5,
                Parent = ResizeButton,
            })
            local TopResizeIcon = MaximizeIcon or ResizeIcon
            if TopResizeIcon then
                Library:ApplyLucideIcon(WindowResizeIcon, TopResizeIcon)
            end
        end

        --// Bottom Bar \\--
        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 3,
            Parent = MainFrame
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 3,
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 4,
            Parent = MainFrame,
        })
        BottomBackgroundCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
            BottomRightRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = BottomBackground,
        })

        --// Footer \\-
        FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = WindowInfo.Footer,
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = BottomBar,
        })

        if WindowInfo.ShowClock then
            local ClockLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(8, 0),
                Size = UDim2.new(0.3, 0, 1, 0),
                Text = os.date("%I:%M:%S %p"),
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4,
                Parent = BottomBar,
            })

            task.spawn(function()
                while not Library.Unloaded and ClockLabel.Parent do
                    ClockLabel.Text = os.date("%I:%M:%S %p")
                    task.wait(1)
                end
            end)
        end

        if WindowInfo.ShowExecutor then
            local ExecutorName = "Unknown"
            pcall(function()
                if identifyexecutor then
                    ExecutorName = (identifyexecutor())
                elseif getexecutorname then
                    ExecutorName = getexecutorname()
                end
            end)

            New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -8, 0, 0),
                Size = UDim2.new(0.3, 0, 1, 0),
                Text = tostring(ExecutorName),
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 4,
                Parent = BottomBar,
            })
        end

        --// Tabs \\--
        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 49),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            Size = UDim2.new(0, InitialLeftWidth, 1, -70),
            Parent = MainFrame,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, TabButtonsStyle.Gap),
            Parent = Tabs,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, TabButtonsStyle.Padding),
            PaddingLeft = UDim.new(0, TabButtonsStyle.Padding),
            PaddingRight = UDim.new(0, TabButtonsStyle.Padding),
            PaddingTop = UDim.new(0, TabButtonsStyle.Padding),
            Parent = Tabs,
        })

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            ClipsDescendants = true,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 49),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })

        Library.WindowContainer = Container
    end

    --// Window Table \\--
    local Window = {}
    local Fading = false

    local function SetUICorner(UICorner, Corner, HalfValue)
        local Current = UICorner[Corner]
        if Current.Offset == 0 and Current.Scale == 0 then
            return
        end

        UICorner[Corner] = HalfValue
    end

    function Window:ChangeTitle(title)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitle.Text = title
        WindowInfo.Title = title
    end

    function Window:SetBackgroundImage(Image: string)
        local ValidIcon = false

        if typeof(Image) == "string" then
            local BackgroundIcon = Library:GetCustomIcon(Image)

            if BackgroundIcon then
                ValidIcon = true

                Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
            elseif Image:match("http://") or Image:match("https://") then
                local RawFileName = Image:match("(.+)%..+$")
                local _, Domain = Image:match("^(https?://)([^/]+)");

                if RawFileName and Domain then
                    local Extention = string.sub(Image, #RawFileName + 1, #Image)
                    local FileNamePos = RawFileName:gsub("\\", "/"):find("/[^/]*$")
                    local FileName = FileNamePos and Image:sub(FileNamePos + 1) or nil

                    if FileName then
                        ValidIcon = true

                        local AssetName = Domain .. FileName
                        if #AssetName > 255 then
                            local NewLength = 255 - #Domain - #Extention
                            if NewLength < 0 then
                                AssetName = Domain .. Extention
                            else
                                AssetName = Domain .. string.sub(FileName:sub(1, #FileName - #Extention), 1, NewLength) .. Extention
                            end
                        end

                        if CustomImageManagerAssets[FileName] == nil then
                            CustomImageManager.AddAsset(FileName, 0, Image)
                        else
                            CustomImageManager.DownloadAsset(FileName, true)
                        end

                        BackgroundImage.Image = CustomImageManager.GetAsset(FileName)
                        BackgroundImage.ImageRectOffset = Vector2.zero
                        BackgroundImage.ImageRectSize = Vector2.zero
                    end
                end
            end
        end

        if not ValidIcon then
            BackgroundImage.Image = ""
            BackgroundImage.ImageRectOffset = Vector2.zero
            BackgroundImage.ImageRectSize = Vector2.zero
        end

        HasBackgroundImage = ValidIcon
        WindowInfo.BackgroundImage = Image
    end

    function Window:SetFooter(Footer: string)
        assert(typeof(Footer) == "string", "Expected string for footer got: " .. typeof(Footer))

        FooterLabel.Text = Footer
        WindowInfo.Footer = Footer
    end

    function Window:SetAlwaysOnTop(Enabled: boolean)
        WindowInfo.AlwaysOnTop = Enabled == true
        SetAlwaysOnTop(Library.ScreenGui, WindowInfo.AlwaysOnTop)
    end

    function Window:SetSnapping(Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean?)
        WindowInfo.Snapping = Enabled == true
        WindowSnapConfig.Enabled = WindowInfo.Snapping

        if Distance then
            WindowInfo.SnapDistance = math.max(0, Distance)
            WindowSnapConfig.Distance = WindowInfo.SnapDistance
        end

        if Margin then
            WindowInfo.SnapMargin = math.max(0, Margin)
            WindowSnapConfig.Margin = WindowInfo.SnapMargin
        end

        if AvoidCoreGui ~= nil then
            WindowInfo.SnapAvoidCoreGui = AvoidCoreGui == true
            WindowSnapConfig.AvoidCoreGui = WindowInfo.SnapAvoidCoreGui
        end
    end

    function Window:SetCornerRadius(Radius: number)
        assert(typeof(Radius) == "number", "Expected number for Radius got: " .. typeof(Radius))
        Radius = math.min(Radius, 20)

        local RadiusHalf = UDim.new(0, Radius / 2)
        local RadiusUDim = UDim.new(0, Radius)
        local HalfCurrent = Library.CornerRadius / 2

        for _, UICorner in Library.Corners do
            if math.abs(UICorner.CornerRadius.Offset - HalfCurrent) < 0.001 then
                UICorner.CornerRadius = RadiusHalf
            else
                UICorner.CornerRadius = RadiusUDim
            end
        end

        for _, UICorner in Library.SpecificCorners do
            SetUICorner(UICorner, "TopRightRadius", RadiusHalf)
            SetUICorner(UICorner, "TopLeftRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomRightRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomLeftRadius", RadiusHalf)
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        if BottomBackgroundCorner then
            BottomBackgroundCorner.BottomLeftRadius = RadiusUDim
            BottomBackgroundCorner.BottomRightRadius = RadiusUDim
        end

        for _, Menu in Library.ContextMenus do
            if Menu.Destroyed then
                continue
            end

            if typeof(Menu.ActiveCallback) ~= "function" then
                continue
            end

            if not Menu.Active then
                local HolderActive = false
                for _, Other in Library.ContextMenus do
                    if Other == Menu then 
                        continue
                    end
   
                    if Other.Active and Other.Holder == Menu.Holder then
                        HolderActive = true
                        break
                    end
                end

                if HolderActive then
                    continue
                end

                Menu.ActiveCallback(false)
                continue
            end

            Menu.ActiveCallback(true)
        end

        for _, Option in Options do
            if Option.Type == "Dropdown" and Option.RefreshPool then
                Option:RefreshPool()
            end
        end

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
        end
    end

    function Window:SetAnimations(Animations: { [string]: boolean }?, TabTransitionTime: number?, TabSwipeOffset: number?, TabSwipeFrom: ("left" | "right" | "top" | "bottom" | string)?)
        if typeof(Animations) == "table" then
            WindowInfo.Animations = Animations
            Library.Animations = Animations
        end

        if typeof(TabTransitionTime) == "number" then
            local TweenInfo = TweenInfo.new(
                math.max(0, TabTransitionTime or 0.22),
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            WindowInfo.TabTransitionInfo = TweenInfo
            Library.TabTransitionInfo = TweenInfo
        end

        if typeof(TabSwipeOffset) == "number" then
            TabSwipeOffset = math.max(1, TabSwipeOffset)

            WindowInfo.TabSwipeOffset = TabSwipeOffset
            Library.TabSwipeOffset = TabSwipeOffset
        end

        if typeof(TabSwipeFrom) == "string" then
            TabSwipeFrom = string.lower(TabSwipeFrom)

            WindowInfo.TabSwipeFrom = TabSwipeFrom
            Library.TabSwipeFrom = TabSwipeFrom
        end
    end

    local function ApplyCompact()
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact
        if not (WindowInfo.Icon or WindowInfo.SpinningLogo) then
            WindowIcon.Visible = IsCompact
        end

        for _, Button in Library.TabButtons do
            if not Button.Icon then
                continue
            end

            Button.Label.Visible = not IsCompact
            Button.Padding.PaddingBottom = UDim.new(0, IsCompact and 6 or 11)
            Button.Padding.PaddingLeft = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingRight = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingTop = UDim.new(0, IsCompact and 6 or 11)
            Button.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY
        end
    end

    function Window:IsSidebarCompacted()
        return IsCompact
    end

    function Window:SetCompact(State)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        Width = math.clamp(Width, 48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)

        DividerLine.Position = UDim2.fromOffset(Width, 0)

        TitleHolder.Size = UDim2.new(0, Width, 1, 0)
        RightWrapper.Size = UDim2.new(1, -Width - 94 - 1, 1, -16)
        Tabs.Size = UDim2.new(0, Width, 1, -70)
        Container.Size = UDim2.new(1, -Width - 1, 1, -70)

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        end
        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:ShowTabInfo(Name, Description)
        CurrentTabLabel.Text = Name
        CurrentTabDescription.Text = Description

        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(0.5, 1)
        end
        CurrentTabInfo.Visible = true
    end

    function Window:HideTabInfo()
        CurrentTabInfo.Visible = false
        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(1, 1)
        end
    end

    function Window:AddTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer
        local TabLeft
        local TabRight

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })
            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Connections = {},
            Destroyed = false,

            Window = Window,
            Button = TabButton,
            Container = TabContainer,
            Sides = {
                TabLeft,
                TabRight,
            },
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = "",
            },

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
        }

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(127, 0, 0),
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            Library:AddToRegistry(WarningBox, {
                BackgroundColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
                end
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)
            Library:AddToRegistry(WarningBoxOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
                end
            })
            Library:AddToRegistry(WarningBoxShadowOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
                end
            })

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })
            Library:AddToRegistry(WarningTitle, {
                TextColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
                end
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })
            Library:AddToRegistry(WarningStroke, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
                end
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Handlers \\--
        function Tab:UpdateWarningBox(Info)
            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Library.Registry[WarningBox].BackgroundColor3()
            WarningBoxShadowOutline.Color = Library.Registry[WarningBoxShadowOutline].Color()
            WarningBoxOutline.Color = Library.Registry[WarningBoxOutline].Color()
            WarningTitle.TextColor3 = Library.Registry[WarningTitle].TextColor3()
            WarningStroke.Color = Library.Registry[WarningStroke].Color()
        end

        function Tab:RefreshSides()
            local Offset = WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0
            for _, Side in Tab.Sides do
                Side.Position = UDim2.new(Side.Position.X.Scale, 0, 0, Offset)
                Side.Size = UDim2.new(0.5, -3, 1, -Offset)
            end
        end

        function Tab:Resize(ResizeWarningBox: boolean?)
            if ResizeWarningBox then
                local MaximumSize = math.floor((TabContainer.AbsoluteSize.Y / Library.DPIScale) / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X / Library.DPIScale
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        local function AddTabbox(self, Info)
            Info = Library:Validate(Info, Templates.Tabbox)
            local ParentObj = self
            local IsNested = ParentObj.Type == "Groupbox" or ParentObj.Type == "SubTab"

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = if IsNested then ParentObj.Container else (Info.Side == 1 and TabLeft or TabRight),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalTabs = 0
            local FirstTab
            local LastTab

            local Tabbox: any = {
                Type = "Tabbox",

                Connections = {},
                Destroyed = false,

                Visible = true,
                ActiveTab = nil,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {},

                ParentBox = if IsNested then ParentObj else nil,
            }

            function Tabbox:UpdateCorners()
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:Resize()
                if Tabbox.ActiveTab then
                    Tabbox.ActiveTab:Resize()
                end
            end

            function Tabbox:AddTab(Name, IconName)
                TotalTabs = TotalTabs + 1
                local TabIndex = TotalTabs

                LastTab = TabIndex
                if not FirstTab then
                    FirstTab = TabIndex
                end

                local IsNameEmpty = Name == nil or Trim(tostring(Name)) == ""
                local TabStoringIndex = IsNameEmpty and tostring(TabIndex) or Name

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                local ButtonCorner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
                    TopRightRadius = UDim.new(0, WindowInfo.CornerRadius),
                    BottomRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, 0),
                    Parent = Button,
                }); table.insert(Library.SpecificCorners, ButtonCorner)

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                local BoxIcon = Library:GetCustomIcon(IconName)
                if BoxIcon then
                    ButtonIcon = New("ImageLabel", {
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageTransparency = 0.5,
                        Size = IsNameEmpty and UDim2.fromOffset(16, 16) or UDim2.fromOffset(18, 18),
                        Parent = ButtonContent,
                    })
                    Library:ApplyLucideIcon(ButtonIcon, BoxIcon)
                end

                local ButtonLabel
                if not IsNameEmpty then
                    ButtonLabel = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(0, 16),
                        Text = Name,
                        TextSize = 15,
                        TextTransparency = 0.5,
                        Parent = ButtonContent,
                    })
                end

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    ScrollBarThickness = 0,
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = Container,
                })

                local Tab = {
                    Type = "SubTab",
                    Name = Name,

                    Connections = {},
                    Destroyed = false,

                    ButtonHolder = Button,
                    Container = Container,
                    ButtonCorner = ButtonCorner,

                    Tab = Tab,
                    Tabbox = Tabbox,

                    Elements = {},
                    DependencyBoxes = {},
                }

                function Tab:Show()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    Button.BackgroundTransparency = 1

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0
                    end

                    Line.Visible = false

                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                    Tabbox:RefreshPopOutPlaceholder()
                end

                function Tab:Hide()
                    Button.BackgroundTransparency = 0

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0.5
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0.5
                    end
                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    local ContentSize = (List.AbsoluteContentSize.Y / Library.DPIScale) + 14
                    if Tabbox.PoppedOut then
                        ContentSize = math.min(ContentSize, GetPopOutBodyMaxHeight(Tabbox, 35))
                    end

                    TabboxHolder.Size = UDim2.new(1, 0, 0, ContentSize + 35)
                    if IsNested then
                        ParentObj:Resize()
                    end
                end

                function Tab:UpdateCorners()
                    local Radius = WindowInfo.CornerRadius

                    ButtonCorner.TopLeftRadius = UDim.new(0, TabIndex == FirstTab and Radius or 0)
                    ButtonCorner.TopRightRadius = UDim.new(0, TabIndex == LastTab and Radius or 0)
                end

                function Tab:Destroy()
                    Tab.Destroyed = true

                    if Tab.Connections then
                        for _, Connection in Tab.Connections do
                            Connection:Disconnect()
                        end
                    end

                    for _, Element in Tab.Elements do
                        if Element.Destroy then
                            Element:Destroy()
                        end
                    end

                    for _, SubDepbox in Tab.DependencyBoxes do
                        if SubDepbox.Destroy then
                            SubDepbox:Destroy()
                        end
                    end

                    if Container then
                        Container:Destroy()
                    end

                    if Button then
                        Button:Destroy()
                    end
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                OnTap(Button, Tab.Show)

                Tab.AddTabbox = AddTabbox
                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[TabStoringIndex] = Tab
                Tabbox:UpdateCorners()

                return Tab, TabStoringIndex
            end

            Library:MakeBoxPopOut(Tabbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = TabboxButtons,
                Children = function()
                    return { TabboxHolder }
                end,

                After = function()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Resize()
                    end
                    if IsNested then
                        ParentObj:Resize()
                    end
                end,
            })

            function Tabbox:Destroy()
                if Tabbox.PoppedOut then
                    Tabbox:SetPoppedOut(false)
                end

                Tabbox.Destroyed = true

                if Tabbox.Connections then
                    for _, Connection in Tabbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Tab in Tabbox.Tabs do
                    if Tab.Destroy then
                        Tab:Destroy()
                    end
                end

                if TabboxHolder then
                    TabboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            if Info.Name then
                Tab.Tabboxes[Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end

            return Tabbox
        end

        Tab.AddTabbox = AddTabbox

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        function Tab:AddGroupbox(Info)
            Info = Library:Validate(Info, Templates.Groupbox)

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = (Info.Side == 1) and TabLeft or TabRight,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder

            local GroupboxTop
            local GroupboxLabel
            local GroupboxDescription

            local GroupboxContainer
            local GroupboxList

            local GroupboxCollapseArrow
            local GroupboxLine

            do
                GroupboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = GroupboxHolder,
                    })
                )
                New("UIListLayout", {
                    Parent = GroupboxHolder,
                })
                Library:AddOutline(GroupboxHolder)

                GroupboxTop = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxTop,
                })

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    local GroupboxHeaderIcon = New("ImageLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(22, 22),
                        Parent = GroupboxTop,
                    })
                    Library:ApplyLucideIcon(GroupboxHeaderIcon, BoxIcon)
                end

                local RightInset = if Info.DisableCollapsing ~= true then 22 else 0
                local TextsFrame = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(BoxIcon and 24 or 0, 0),
                    Size = UDim2.new(1, -RightInset - (BoxIcon and 24 or 0), 0, 0),
                    Parent = GroupboxTop,
                })
                New("UIListLayout", {
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 3),
                    Parent = TextsFrame,
                })

                GroupboxLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Name,
                    TextSize = 15,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 1),
                    Parent = GroupboxLabel,
                })

                GroupboxDescription = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Description or "",
                    TextSize = 14,
                    TextTransparency = 0.5,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = (Info.Description ~= nil),
                    Parent = TextsFrame,
                })

                GroupboxCollapseArrow = New("ImageButton", {
                    Visible = Info.DisableCollapsing ~= true,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    ImageColor3 = "WhiteColor",
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromOffset(22, 22),
                    Parent = GroupboxTop,
                })
                if ArrowIcon then
                    Library:ApplyLucideIcon(GroupboxCollapseArrow, ArrowIcon, 180)
                end

                GroupboxLine = Library:MakeLine(GroupboxHolder, {
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 1),
                })

                GroupboxContainer = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    LayoutOrder = 2,
                    ScrollBarThickness = 0,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = GroupboxContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = GroupboxContainer,
                })
            end

            local Groupbox: any = {
                Type = "Groupbox",

                Name = Info.Name,
                Description = Info.Description,

                Connections = {},
                Destroyed = false,

                Visible = true,
                Collapsed = false,

                BoxHolder = BoxHolder,
                Holder = GroupboxHolder,
                Container = GroupboxContainer,

                Tab = Tab,
                DependencyBoxes = {},
                Elements = {}
            }

            local ResizeTween
            local CollapseArrowTween

            function Groupbox:Resize()
                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                local TopSize = (GroupboxTop.AbsoluteSize.Y / Library.DPIScale)
                local ContainerSize = (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 14
                if Groupbox.PoppedOut then
                    ContainerSize = math.min(ContainerSize, GetPopOutBodyMaxHeight(Groupbox, TopSize + 1))
                end

                local TargetSize = UDim2.new(1, 0, 0, if Groupbox.Collapsed then TopSize else (TopSize + 1 + ContainerSize))
                GroupboxContainer.Size = UDim2.new(1, 0, 0, ContainerSize)
                GroupboxLine.Visible = not Groupbox.Collapsed

                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxHolder, TweenInfo, { Size = TargetSize })
                    ResizeTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if ResizeTween == Tween then
                            StopTween(ResizeTween, true)
                            ResizeTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxHolder.Size = TargetSize
                end
            end

            table.insert(Groupbox.Connections, GroupboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Groupbox.Visible == false or Groupbox.Destroyed then
                    return
                end

                Groupbox:Resize()
            end))

            function Groupbox:SetDescription(Description: string | nil)
                GroupboxDescription.Text = Description or ""
                GroupboxDescription.Visible = (Description ~= nil)

                Groupbox:Resize()
            end

            function Groupbox:SetCollapsed(Collapsed: boolean)
                if Info.DisableCollapsing == true then return end
                Groupbox.Collapsed = Collapsed

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                local TargetRotation = if Collapsed then 0 else 180

                GroupboxContainer.Visible = not Collapsed
                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxCollapseArrow, TweenInfo, { Rotation = TargetRotation })
                    CollapseArrowTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Connect(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if CollapseArrowTween == Tween then
                            StopTween(CollapseArrowTween, true)
                            CollapseArrowTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxCollapseArrow.Rotation = TargetRotation
                end

                Groupbox:Resize()
            end

            function Groupbox:ToggleCollapsed()
                if Info.DisableCollapsing == true then return end
                Groupbox:SetCollapsed(not Groupbox.Collapsed)
            end

            Library:MakeBoxPopOut(Groupbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = GroupboxTop,
                Children = function()
                    local Children = {}
                    for _, Child in BoxHolder:GetChildren() do
                        if Child:IsA("GuiObject") and Child ~= Groupbox.PopOutPlaceholder then
                            table.insert(Children, Child)
                        end
                    end
                    return Children
                end,

                Before = function()
                    GroupboxCollapseArrow.Visible = false
                end,
                After = function()
                    GroupboxCollapseArrow.Visible = Info.DisableCollapsing ~= true
                    Groupbox:Resize()
                end
            })

            function Groupbox:Destroy()
                if Groupbox.PoppedOut then
                    Groupbox:SetPoppedOut(false)
                end

                Groupbox.Destroyed = true

                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                if Groupbox.Connections then
                    for _, Connection in Groupbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Element in Groupbox.Elements do
                    if Element.Destroy then
                        Element:Destroy()
                    end
                end
                table.clear(Groupbox.Elements)

                for _, SubDepbox in Groupbox.DependencyBoxes do
                    if SubDepbox.Destroy then
                        SubDepbox:Destroy()
                    end
                end
                table.clear(Groupbox.DependencyBoxes)

                if GroupboxHolder then
                    GroupboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            function Groupbox:SetVisible(Visible: boolean)
                Groupbox.Visible = Visible
                BoxHolder.Visible = Visible
                SyncPopOutVisibility(Groupbox)

                if Visible == true and Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function Groupbox:Show()
                Groupbox:SetVisible(true)
            end

            function Groupbox:Hide()
                Groupbox:SetVisible(false)
            end

            if Info.DisableCollapsing ~= true then
                OnTap(GroupboxCollapseArrow, function()
                    Groupbox:ToggleCollapsed()
                end)
            end

            Groupbox.AddTabbox = AddTabbox
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()
            Tab.Groupboxes[Info.Name] = Groupbox

            if Info.Visible == false then
                Groupbox:Hide()
            end

            if Info.DisableCollapsing ~= true and Info.Collapsed == true then
                Groupbox:SetCollapsed(true)
            end

            return Groupbox
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Library:PlayTabAnimation(Tab, true)
            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        function Tab:Destroy()
            Tab.Destroyed = true

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            for _, Groupbox in Tab.Groupboxes do
                if Groupbox.Destroy then
                    Groupbox:Destroy()
                end
            end
            table.clear(Tab.Groupboxes)

            for _, Tabbox in Tab.Tabboxes do
                if Tabbox.Destroy then
                    Tabbox:Destroy()
                end
            end
            table.clear(Tab.Tabboxes)

            for _, DepGroupbox in Tab.DependencyGroupboxes do
                if DepGroupbox.Destroy then
                    DepGroupbox:Destroy()
                end
            end

            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        OnTap(TabButton, Tab.Show)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddKeyTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Description = Description,
            IsKeyTab = true,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Elements = {},

            Window = Window,
            Button = TabButton,
            Container = TabContainer
        }

        function Tab:AddKeyBox(Callback)
            assert(typeof(Callback) == "function", "Callback must be a function")

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })
            local BoxStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = Box,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Box,
                })
            )

            Box.Focused:Connect(function()
                Library.Registry[BoxStroke].Color = "AccentColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end)

            Box.FocusLost:Connect(function()
                Library.Registry[BoxStroke].Color = "OutlineColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end)

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                TextTransparency = 0.4,
                Parent = Holder,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.4,
                }):Play()
            end)

            OnTap(Button, function()
                Callback(Box.Text)
            end)
        end

        function Tab:Destroy()
            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        OnTap(TabButton, Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddDialog(Idx, Info)
        Info = Library:Validate(Info, Templates.Dialog)

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = MainFrame,
        })
        TweenService:Create(DialogOverlay, Library.TweenInfo, {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1,
            Parent = DialogOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = DialogFrame,
            })
        )
        Library:AddOutline(DialogFrame)

        local InnerContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            Parent = DialogFrame,
        })
        local DialogScale = New("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TweenService:Create(DialogScale, Library.TweenInfo, {
            Scale = 1
        }):Play()
        local _InnerPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = HeaderContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        if Info.Icon then
            local ParsedIcon = Library:GetCustomIcon(Info.Icon)
            if ParsedIcon then
                local IconImg = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(16, 16),
                    ImageColor3 = Info.TitleColor or "FontColor",
                    LayoutOrder = 1,
                    ZIndex = 2,
                    Parent = TitleRow,
                })
                Library:ApplyLucideIcon(IconImg, ParsedIcon)
            end
        end

        local TitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title,
            TextSize = 18,
            TextColor3 = Info.TitleColor or "FontColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = TitleRow,
        })

        local DescriptionLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description,
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Info.DescriptionColor or "FontColor",
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = HeaderContainer,
        })

        DialogContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        local _DialogContainerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DialogContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = DialogContainer,
        })

        local _Sep2 = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 2,
            Parent = InnerContainer,
        })

        ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Destroyed = false,
            Elements = {},
            Container = DialogContainer,
            OutsideClickDismiss = Info.OutsideClickDismiss,
        }

        function Dialog:Resize()
            local MaxWidth = (MainFrame.AbsoluteSize.X / Library.DPIScale) * 0.75
            local MinWidth = 400

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in FooterButtonsList do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

            local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in DialogContainer:GetChildren() do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end
            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons
        end

        function Dialog:SetTitle(Title)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            if Dialog.Destroyed then
                return
            end

            Dialog.Destroyed = true

            if Library.ActiveDialog == Dialog then
                Library.ActiveDialog = nil
            end

            for Index = #Dialog.Elements, 1, -1 do
                local Element = Dialog.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end
            table.clear(Dialog.Elements)

            local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
            TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            CloseTween:Play()

            task.delay(Library.TweenInfo.Time, function()
                DialogOverlay:Destroy()
            end)
            Library.Dialogues[Idx] = nil
        end

        OnTap(DialogOverlay, function()
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0

            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 2,
                Parent = ButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 2,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            local _BtnPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14,
                ZIndex = 2,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius),
                        Parent = ProgressBar
                    })
                )
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    IsActive = not Disabled
                    if Disabled then
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    else
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    end
                end
            }

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            OnTap(TextBtn, function()
                if not IsActive then return end
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end
                if Info.AutoDismiss then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()

                task.delay(WaitTime, function()
                    ButtonWrap:SetDisabled(false)
                    if ProgressBar then
                        TweenService:Create(ProgressBar, Library.TweenInfo, {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        for BIdx, BInfo in Info.FooterButtons do
            if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
            Dialog:AddFooterButton(BIdx, BInfo)
        end

        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog

        Dialog:Resize()

        Library.ActiveDialog = Dialog
        return Dialog
    end

    local GuiProperties = { "BackgroundTransparency" }
    local ImageProperties = { "BackgroundTransparency", "ImageTransparency" }
    local TextProperties = { "BackgroundTransparency", "TextTransparency" }
    local StrokeProperties = { "Transparency" }

    local function FadeInstance(Desc, Properties)
        local Cache = TransparencyCache[Desc]
        if not Cache then
            Cache = {}
            TransparencyCache[Desc] = Cache
        end

        for _, Prop in Properties do
            if not Library.Toggled then
                Cache[Prop] = Desc[Prop]
            end

            if Cache[Prop] ~= nil and Cache[Prop] ~= 1 then
                TweenService:Create(Desc, Library.WindowAnimationInfo, {
                    [Prop] = Library.Toggled and Cache[Prop] or 1,
                }):Play()
            end
        end
    end

    function Window:Toggle(Value: boolean?)
        if Fading then
            return
        end

        if Library.ActiveLoading then
            if Value == true then
                return
            end

            if not Library.Toggled then
                return
            end
        end

        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        if Library.Animations and Library.Animations.ToggleWindow == true then
            local FadeTime = Library.WindowAnimationInfo.Time
            Fading = true

            if Library.Toggled then
                MainFrame.Visible = true
            end

            if Library.Toggled then
                FadeInstance(MainFrame, { "BackgroundTransparency" })
                task.wait(FadeTime / 2)
            else
                task.delay(FadeTime / 2, FadeInstance, MainFrame, { "BackgroundTransparency" })
            end

            for _, Instance in MainFrame:GetDescendants() do
                if Instance == TopBar then
                    continue
                end

                if Instance:IsA("GuiObject") then
                    local ClassName = Instance.ClassName
                    if ClassName == "ImageLabel" or ClassName == "ImageButton" then
                        FadeInstance(Instance, ImageProperties)
                    elseif ClassName == "TextLabel" or ClassName == "TextBox" or ClassName == "TextButton" then
                        FadeInstance(Instance, TextProperties)
                    else
                        FadeInstance(Instance, GuiProperties)
                    end
                elseif Instance.ClassName == "UIStroke" then
                    FadeInstance(Instance, StrokeProperties)
                end
            end

            task.delay(FadeTime, function()
                MainFrame.Visible = Library.Toggled
                Fading = false
            end)
        else
            MainFrame.Visible = Library.Toggled
        end

        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled
        end

        if Library.Toggled and not Library.IsMobile then
            local ShowCursorBinding = Library.ShowCursorBinding
            Library.OriginalMouseIconEnabled = UserInputService.MouseIconEnabled

            pcall(function() RunService:UnbindFromRenderStep(ShowCursorBinding) end)
            RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
                UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
                Cursor.Visible = Library.ShowCustomCursor

                if Library.Unloaded == true or not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                    RestoreMouseIcon()
                end
            end)
        elseif not Library.Toggled then
            RestoreMouseIcon()
            TooltipLabel.Visible = false

            for _, Option in Library.Options do
                if Option.Type == "ColorPicker" then
                    Option.ColorMenu:Close()
                    Option.ContextMenu:Close()
                elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                    Option.Menu:Close()
                end
            end
        end
    end

    function Library:Toggle(Value: boolean?)
        return Window:Toggle(Value)
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed
        local GrabInput

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, Library.IsMobile and 16 or 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            if Changed and Changed.Connected then
                Changed:Disconnect()
            end

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true
            GrabInput = Input

            Changed = Input.Changed:Connect(function()
                if not IsInputEnded(Input) then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsDragMove(Input, GrabInput) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end

    Window:SetAlwaysOnTop(WindowInfo.AlwaysOnTop)
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow and not Library.ActiveLoading then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then
        local ToggleButton = Library:AddDraggableButton("Toggle", function()
            Library:Toggle()
        end, true, true)

        local LockButton = Library:AddDraggableButton("Lock", function(self)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end, true, true)

        if WindowInfo.MobileButtonsSide == "Right" then
            ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)
            ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)

            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
            LockButton.Button.Position = UDim2.new(1, -(ToggleButton.Button.Size.X.Offset + 12), 0, 6)
        else
            ToggleButton.Button.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Button.Position = UDim2.fromOffset(6, 6)

            LockButton.Button.AnchorPoint = Vector2.new(0, 0)
            LockButton.Button.Position = UDim2.fromOffset(ToggleButton.Button.Size.X.Offset + 12, 6)
        end

        if WindowInfo.ShowMobileButtons == false then
            ToggleButton.Button.Visible = false
            LockButton.Button.Visible = false
        end
    end

    --// Execution \\--
    Library:GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:UpdateSearch(SearchBox.Text)
    end))

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape then
            -- Releasing focus from a text input takes priority and never toggles the window --
            local FocusedBox = UserInputService:GetFocusedTextBox()
            if FocusedBox then
                FocusedBox:ReleaseFocus()
                return
            end

            -- Dismiss the topmost dialog before closing any open menu --
            if Library.ActiveDialog and Library.ActiveDialog.OutsideClickDismiss ~= false then
                Library.ActiveDialog:Dismiss()
                return
            end

            if CurrentMenu then
                CurrentMenu:Close()
                return
            end

            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
    end))

    Window.MainFrame = MainFrame
    Library.Window = Window

    return Window
end

function Library:CreateLoading(LoadingInfo)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        AlwaysOnTop = LoadingInfo.AlwaysOnTop,

        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui
    SetAlwaysOnTop(ScreenGui, LoadingInfo.AlwaysOnTop)

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        task.defer(function()
            if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
                return
            end

            Library:RemoveFromRegistry(Instance)
        end)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))

    local MainScale = New("UIScale", {
        Scale = Library.IsMobile and 0.8 or 1,
        Parent = MainFrame
    })
    table.insert(Library.Scales, MainScale)
    Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)

    Library:AddOutline(SideBar)

    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        local Icon = Library:GetCustomIcon(LoadingInfo.Icon)
        local _WindowIcon = New("ImageLabel", {
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
        if Icon then
            Library:ApplyLucideIcon(_WindowIcon, Icon)
        end
    else
        local _WindowIcon = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local TitleX = Library:GetTextBounds(
        LoadingInfo.Title,
        Library.Scheme.Font,
        20,
        (TitleHolder.AbsoluteSize.X / Library.DPIScale) - (LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0) - 12
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, TitleX, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoaderIcon = Library:GetCustomIcon(LoadingInfo.LoadingIcon)
    local LoadingIcon = New("ImageLabel", {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })
    if LoaderIcon then
        Library:ApplyLucideIcon(LoadingIcon, LoaderIcon)
    end

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = "DarkColor",
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},

        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,

        Resize = function(self)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight

        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight =
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        local IconData = Library:GetCustomIcon(Icon)
        assert(IconData, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(LoadingIcon, IconData)
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        LoadingIcon.ImageColor3 = Color
    end

    function Loading:SetCurrentStep(Step)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then
                button:Destroy()
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            OnTap(TextBtn, function()
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

function Library:Unload()
    Library.Unloaded = true

    --// Disconnect connections
    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)

        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    --// Run Unload Callbacks
    for _ = 1, #Library.UnloadSignals do
        local Callback = table.remove(Library.UnloadSignals, 1)

        if Callback then
            Library:SafeCallback(Callback)
        end
    end

    --// Destroy elements
    for Index = #Library.Tabs, 1, -1 do
        local Tab = table.remove(Library.Tabs, Index)

        if Tab and Tab.Destroy then
            Library:SafeCallback(Tab.Destroy, Tab)
        end
    end

    for Index = #Tooltips, 1, -1 do
        local Tooltip = table.remove(Tooltips, Index)

        if Tooltip and Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    --// Clear tables
    table.clear(Library.Registry)

    table.clear(Options)
    table.clear(Toggles)
    table.clear(Buttons)
    table.clear(Labels)
    table.clear(Tooltips)

    table.clear(Library.Tabs)
    table.clear(Library.TabButtons)

    table.clear(Library.Scales)
    table.clear(Library.ScalesOffset)

    table.clear(Library.Corners)
    table.clear(Library.SpecificCorners)
    table.clear(Library.ContextMenus)

    table.clear(Library.Notifications)
    table.clear(Library.Dialogues)
    table.clear(Library.DraggableElements)
    table.clear(Library.KeybindToggles)
    table.clear(Library.DependencyBoxes)

    table.clear(TransparencyCache)
    table.clear(ActiveTabTweens)

    Library.Toggle = function(...) end
    Library.ScreenGui = nil
    Library.Floats = nil
    Library.Overlay = nil
    Library.WindowContainer = nil
    Library.KeybindFrame = nil
    Library.KeybindContainer = nil

    getgenv().Library = nil
end


--// Artefact Spinning Logo \\--
Library.SpinFolder = "ArtefactObsidian/spin"

local function DecodeBase64(Data: string): string
    if crypt then
        if crypt.base64 and crypt.base64.decode then
            local Ok, Result = pcall(crypt.base64.decode, Data)
            if Ok and Result then
                return Result
            end
        end
        if crypt.base64decode then
            local Ok, Result = pcall(crypt.base64decode, Data)
            if Ok and Result then
                return Result
            end
        end
    end

    local Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local Map = {}
    for Index = 1, 64 do
        Map[Alphabet:byte(Index)] = Index - 1
    end

    local Out = table.create(math.floor(#Data / 4))
    for Index = 1, #Data, 4 do
        local A = Map[Data:byte(Index)] or 0
        local B = Map[Data:byte(Index + 1)] or 0
        local C = Map[Data:byte(Index + 2)] or 0
        local D = Map[Data:byte(Index + 3)] or 0
        local N = A * 262144 + B * 4096 + C * 64 + D
        Out[#Out + 1] = string.char(math.floor(N / 65536) % 256, math.floor(N / 256) % 256, N % 256)
    end

    local Result = table.concat(Out)
    local Pad = 0
    if Data:sub(-1, -1) == "=" then
        Pad += 1
    end
    if Data:sub(-2, -2) == "=" then
        Pad += 1
    end

    return Pad > 0 and Result:sub(1, #Result - Pad) or Result
end

function Library:PreloadSpinFrames(Count: number?)
    local Images = self._SpinImages
    if typeof(Images) ~= "table" then
        Images = {}
        self._SpinImages = Images
    end

    if not (writefile and getcustomasset) then
        return Images
    end

    pcall(function()
        local Root = self.SpinFolder:match("^(.-)/[^/]+$")
        if Root and not isfolder(Root) then
            makefolder(Root)
        end
        if not isfolder(self.SpinFolder) then
            makefolder(self.SpinFolder)
        end
    end)

    local Target = #self.SpinFrames
    if typeof(Count) == "number" then
        Target = math.min(Target, Count)
    end

    for Index = #Images + 1, Target do
        local Path = self.SpinFolder .. "/" .. tostring(Index) .. ".png"
        local Ok, Asset = pcall(function()
            if not (isfile and isfile(Path)) then
                writefile(Path, DecodeBase64(self.SpinFrames[Index]))
            end
            return getcustomasset(Path)
        end)

        if not (Ok and Asset and Asset ~= "") then
            break
        end
        Images[Index] = Asset

        if Count == nil and Index % 8 == 0 then
            task.wait()
        end
    end

    return Images
end

function Library:AttachSpinningLogo(Logo: ImageLabel, VisibilityRoot: GuiObject?, FPS: number?)
    FPS = math.max(1, FPS or 20)

    local First = Library:PreloadSpinFrames(1)
    if First[1] then
        Logo.Image = First[1]
    end

    task.spawn(function()
        local Images = Library:PreloadSpinFrames()
        if #Images < 2 then
            return
        end

        pcall(function()
            local Warm = {}
            for Index, Asset in Images do
                Warm[Index] = Asset
            end
            cloneref(game:GetService("ContentProvider")):PreloadAsync(Warm)
        end)

        local LastIndex = 0
        local Origin = os.clock()
        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not Logo.Parent or (VisibilityRoot and not VisibilityRoot.Visible) then
                return
            end

            local Index = (math.floor((os.clock() - Origin) * FPS) % #Images) + 1
            if Index ~= LastIndex then
                LastIndex = Index
                Logo.Image = Images[Index]
            end
        end))
    end)
end

Library.SpinFrames = {
	"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",
}

getgenv().Library = Library
return Library
