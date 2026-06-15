local M = {}

local WidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary
local WidgetLayoutLibrary = UE.UWidgetLayoutLibrary
local KismetRenderingLibrary = UE.UKismetRenderingLibrary
local KismetSystemLibrary = UE.UKismetSystemLibrary
local GameplayStatics = UE.UGameplayStatics
local LinearColor = UE.FLinearColor
local Vector2D = UE.FVector2D

local MenuWidgetPath = "/Game/UI/Widgets/Menu/WBP_SekiroMainMenu.WBP_SekiroMainMenu_C"
local HUDWidgetPath = "/Game/UI/Widgets/HUD/WBP_SekiroHUD.WBP_SekiroHUD_C"

local MenuButtonNames = {
    "Btn_NewGame",
    "Btn_Login",
    "Btn_Settings",
    "Btn_Language",
    "Btn_Quit",
}

local MenuLabelNames = {
    "Txt_NewGame",
    "Txt_Login",
    "Txt_Settings",
    "Txt_Language",
    "Txt_Quit",
}

local MenuSelectionPositions = {
    Vector2D(546.0, 514.0),
    Vector2D(564.0, 549.0),
    Vector2D(560.0, 583.0),
    Vector2D(560.0, 618.0),
    Vector2D(561.0, 651.0),
}

local MenuSelectionSizes = {
    Vector2D(196.0, 28.0),
    Vector2D(160.0, 24.0),
    Vector2D(168.0, 24.0),
    Vector2D(170.0, 24.0),
    Vector2D(166.0, 24.0),
}

local MenuLabelLayouts = {
    {578.0, 515.0, 176.0, 30.0},
    {604.0, 550.0, 120.0, 24.0},
    {586.0, 585.0, 156.0, 24.0},
    {582.0, 619.0, 174.0, 24.0},
    {586.0, 653.0, 160.0, 24.0},
}

local MenuButtonLayouts = {
    {544.0, 512.0, 204.0, 32.0},
    {560.0, 547.0, 172.0, 28.0},
    {558.0, 582.0, 178.0, 28.0},
    {558.0, 616.0, 184.0, 28.0},
    {558.0, 650.0, 182.0, 28.0},
}

local TutorialMessages = {
    "in air near wall: Wall Jump",
    "deflect right before impact",
    "hold guard to steady posture",
}

local SelectedMenuColor = LinearColor(0.94, 0.76, 0.40, 1.0)
local NormalMenuColor = LinearColor(0.76, 0.76, 0.76, 0.95)
local MenuSelectionTint = LinearColor(0.93, 0.68, 0.27, 0.92)
local MenuViewportSize = Vector2D(1280.0, 720.0)

local function safe_remove_widget(widget)
    if widget then
        widget:RemoveFromParent()
    end
end

local function get_project_file(controller, name)
    if not controller.ProjectImageRoot then
        controller.ProjectImageRoot = KismetSystemLibrary.GetProjectDirectory() .. "png_output/"
    end
    return controller.ProjectImageRoot .. name
end

local function load_texture(controller, absolute_path)
    if not absolute_path or absolute_path == "" then
        return nil
    end

    controller.TextureCache = controller.TextureCache or {}
    local cached = controller.TextureCache[absolute_path]
    if cached then
        return cached
    end

    local texture = KismetRenderingLibrary.ImportFileAsTexture2D(controller, absolute_path)
    if texture then
        controller.TextureCache[absolute_path] = texture
    else
        print("Failed to import texture: " .. absolute_path)
    end
    return texture
end

local function set_image_from_file(controller, widget, absolute_path, match_size)
    if not widget then
        return
    end

    local texture = load_texture(controller, absolute_path)
    if texture then
        widget:SetBrushFromTexture(texture, match_size or false)
    end
end

local function set_image_from_candidates(controller, widget, file_names, match_size)
    if not widget then
        return
    end

    for _, file_name in ipairs(file_names) do
        local texture = load_texture(controller, get_project_file(controller, file_name))
        if texture then
            widget:SetBrushFromTexture(texture, match_size or false)
            return
        end
    end
end

local function get_widget(controller, widget_root, name)
    if not controller or not widget_root then
        return nil
    end
    return controller:FindNamedWidget(widget_root, name)
end

local function get_canvas_slot(widget)
    if not widget then
        return nil
    end
    return WidgetLayoutLibrary.SlotAsCanvasSlot(widget)
end

local function set_canvas_rect(widget, x, y, w, h)
    local slot = get_canvas_slot(widget)
    if not slot then
        return
    end
    slot:SetPosition(Vector2D(x, y))
    slot:SetSize(Vector2D(w, h))
end

local function command_line_contains(token)
    local command_line = KismetSystemLibrary.GetCommandLine()
    if not command_line or not token then
        return false
    end
    return string.find(string.lower(command_line), string.lower(token), 1, true) ~= nil
end

local function fit_widget_to_viewport(controller, widget)
    if not controller or not widget then
        return
    end

    if widget.SetPositionInViewport then
        widget:SetPositionInViewport(Vector2D(0.0, 0.0), false)
    end

    if widget.SetDesiredSizeInViewport then
        widget:SetDesiredSizeInViewport(MenuViewportSize)
    end
end

function M:ReceiveBeginPlay()
    self.TextureCache = {}
    self.SelectedIndex = 1
    self.Mode = "Menu"
    self.HealthRatios = {1.0, 0.72, 0.38, 0.12}
    self.HealthIndex = 3
    self.MoneyValue = 0
    self.EmblemValue = 0
    self.TutorialIndex = 1
    self.TutorialVisible = true

    if command_line_contains("SekiroPreviewMode=HUD") then
        self:ShowHUDDemo()
    elseif command_line_contains("SekiroPreviewMode=Menu") then
        self:ShowMainMenu()
    else
        self:ShowGameplayPreview()
    end

    if self.Overridden and self.Overridden.ReceiveBeginPlay then
        self.Overridden.ReceiveBeginPlay(self)
    end
end

function M:ReceiveEndPlay(reason)
    safe_remove_widget(self.MainMenuWidget)
    safe_remove_widget(self.HUDWidget)
    self.MainMenuWidget = nil
    self.HUDWidget = nil

    if self.Overridden and self.Overridden.ReceiveEndPlay then
        self.Overridden.ReceiveEndPlay(self, reason)
    end
end

function M:CreateWidgetOnce(class_path)
    local widget_class = UE.UClass.Load(class_path)
    if not widget_class then
        print("Failed to load widget class: " .. class_path)
        return nil
    end
    return WidgetBlueprintLibrary.Create(self, widget_class, self)
end

function M:EnsureMainMenuWidget()
    if self.MainMenuWidget then
        return
    end

    self.MainMenuWidget = self:CreateWidgetOnce(MenuWidgetPath)
    if not self.MainMenuWidget then
        return
    end

    self.MenuBackdrop = get_widget(self, self.MainMenuWidget, "Img_MenuBackdrop")
    self.MenuBackground = get_widget(self, self.MainMenuWidget, "Img_Background")
    self.MenuSelection = get_widget(self, self.MainMenuWidget, "Img_Selection")
    self.MenuOffline = get_widget(self, self.MainMenuWidget, "Txt_Offline")
    self.MenuVersion = get_widget(self, self.MainMenuWidget, "Txt_Version")
    self.MenuCopyright = get_widget(self, self.MainMenuWidget, "Txt_Copyright")
    self.MenuButtons = {}
    self.MenuLabels = {}

    for index, name in ipairs(MenuButtonNames) do
        local button = get_widget(self, self.MainMenuWidget, name)
        self.MenuButtons[index] = button

        if button then
            button.OnClicked:Add(self, function()
                self.SelectedIndex = index
                self:RefreshMenuSelection()
                self:HandleMenuConfirm()
            end)

            if button.OnHovered then
                button.OnHovered:Add(self, function()
                    self.SelectedIndex = index
                    self:RefreshMenuSelection()
                end)
            end
        end
    end

    for index, name in ipairs(MenuLabelNames) do
        self.MenuLabels[index] = get_widget(self, self.MainMenuWidget, name)
    end

    set_image_from_candidates(self, self.MenuBackdrop, {"Menu_BlackFill.png"}, false)
    set_image_from_candidates(self, self.MenuBackground, {"Menu_LogoFull.png", "Menu_TitleOverlay.png"}, false)
    set_image_from_file(self, self.MenuSelection, get_project_file(self, "Menu_SelectionGlow.png"), false)

    if self.MenuBackdrop then
        self.MenuBackdrop:SetRenderOpacity(1.0)
    end

    if self.MenuSelection then
        self.MenuSelection:SetColorAndOpacity(MenuSelectionTint)
    end
end

function M:ApplyMenuLayout()
    set_canvas_rect(self.MenuBackdrop, 0.0, 0.0, MenuViewportSize.X, MenuViewportSize.Y)
    set_canvas_rect(self.MenuBackground, 172.0, 118.0, 936.0, 435.0)
    set_canvas_rect(self.MenuSelection, 544.0, 512.0, 198.0, 28.0)

    for index, label in ipairs(self.MenuLabels or {}) do
        local layout = MenuLabelLayouts[index]
        if label and layout then
            set_canvas_rect(label, layout[1], layout[2], layout[3], layout[4])
        end
    end

    for index, button in ipairs(self.MenuButtons or {}) do
        local layout = MenuButtonLayouts[index]
        if button and layout then
            set_canvas_rect(button, layout[1], layout[2], layout[3], layout[4])
        end
    end

    set_canvas_rect(self.MenuOffline, 1116.0, 650.0, 100.0, 18.0)
    set_canvas_rect(self.MenuVersion, 1092.0, 675.0, 124.0, 18.0)
    set_canvas_rect(self.MenuCopyright, 286.0, 694.0, 720.0, 18.0)
end

function M:EnsureHUDWidget()
    if self.HUDWidget then
        return
    end

    self.HUDWidget = self:CreateWidgetOnce(HUDWidgetPath)
    if not self.HUDWidget then
        return
    end

    self.HUDBackground = get_widget(self, self.HUDWidget, "Img_Background")
    self.HUDVignette = get_widget(self, self.HUDWidget, "Img_DamageVignette")
    self.HUDTopLine = get_widget(self, self.HUDWidget, "Img_TopRightLine")
    self.HUDTutorialPanel = get_widget(self, self.HUDWidget, "Border_TutorialPanel")
    self.HUDTutorialButton = get_widget(self, self.HUDWidget, "Txt_TutorialButton")
    self.HUDTutorialText = get_widget(self, self.HUDWidget, "Txt_TutorialText")
    self.HUDHealthBar = get_widget(self, self.HUDWidget, "PB_Health")
    self.HUDMoneyText = get_widget(self, self.HUDWidget, "Txt_Money")
    self.HUDMoneyIcon = get_widget(self, self.HUDWidget, "Txt_MoneyIcon")
    self.HUDQuickItemPanel = get_widget(self, self.HUDWidget, "Border_QuickItemPanel")
    self.HUDEmblemCount = get_widget(self, self.HUDWidget, "Txt_EmblemCount")

    set_image_from_file(self, self.HUDBackground, get_project_file(self, "Ref_HUD.png"), false)
    set_image_from_file(self, self.HUDVignette, get_project_file(self, "HUD_DamageVignette.png"), false)
    set_image_from_file(self, self.HUDTopLine, get_project_file(self, "MENU_BG_Line1.png"), false)

    local hint_texture = load_texture(self, get_project_file(self, "MENU_BG_KeyGuide2.png"))
    if hint_texture and self.HUDTutorialPanel then
        self.HUDTutorialPanel:SetBrushFromTexture(hint_texture)
    end

    if self.HUDMoneyIcon then
        self.HUDMoneyIcon:SetText("o")
    end

    self:ApplyHUDDemoState()
end

function M:SetMenuInput()
    if self.MainMenuWidget and self.MainMenuWidget.SetIsFocusable then
        self.MainMenuWidget:SetIsFocusable(true)
    end
    WidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self, self.MainMenuWidget, UE.EMouseLockMode.DoNotLock, false, true)
    self.bShowMouseCursor = true
    self.bEnableClickEvents = true
    self.bEnableMouseOverEvents = true
    GameplayStatics.SetGamePaused(self, false)
end

function M:SetHUDInput()
    WidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self, self.HUDWidget, UE.EMouseLockMode.DoNotLock, false, true)
    self.bShowMouseCursor = false
    self.bEnableClickEvents = false
    self.bEnableMouseOverEvents = false
    GameplayStatics.SetGamePaused(self, false)
end

function M:SetGameplayInput()
    WidgetBlueprintLibrary.SetInputMode_GameOnly(self, false)
    if WidgetBlueprintLibrary.SetFocusToGameViewport then
        WidgetBlueprintLibrary.SetFocusToGameViewport()
    end
    self.bShowMouseCursor = false
    self.bEnableClickEvents = false
    self.bEnableMouseOverEvents = false
    GameplayStatics.SetGamePaused(self, false)
end

function M:ShowMainMenu()
    self:EnsureMainMenuWidget()
    if not self.MainMenuWidget then
        return
    end

    fit_widget_to_viewport(self, self.MainMenuWidget)
    self:ApplyMenuLayout()
    safe_remove_widget(self.HUDWidget)
    self.MainMenuWidget:AddToViewport(50)
    self.Mode = "Menu"
    self:RefreshMenuSelection()
    self:SetMenuInput()
end

function M:ShowHUDDemo()
    self:EnsureHUDWidget()
    if not self.HUDWidget then
        return
    end

    fit_widget_to_viewport(self, self.HUDWidget)
    safe_remove_widget(self.MainMenuWidget)
    self.HUDWidget:AddToViewport(10)
    self.Mode = "HUD"
    self:ApplyHUDDemoState()
    self:SetHUDInput()
end

function M:ShowGameplayPreview()
    safe_remove_widget(self.MainMenuWidget)
    safe_remove_widget(self.HUDWidget)
    self.Mode = "Gameplay"
    self:SetGameplayInput()
end

function M:RefreshMenuSelection()
    if not self.MenuSelection then
        return
    end

    local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(self.MenuSelection)
    if not slot then
        return
    end

    local position = MenuSelectionPositions[self.SelectedIndex]
    local size = MenuSelectionSizes[self.SelectedIndex]
    if position then
        slot:SetPosition(position)
    end
    if size then
        slot:SetSize(size)
    end

    for index, label in ipairs(self.MenuLabels or {}) do
        if label then
            if index == self.SelectedIndex then
                self:SetTextBlockLinearColor(label, SelectedMenuColor)
            else
                self:SetTextBlockLinearColor(label, NormalMenuColor)
            end
        end
    end
end

function M:HandleMenuConfirm()
    if self.SelectedIndex == 1 then
        self:ShowHUDDemo()
    elseif self.SelectedIndex == 3 then
        self.HealthIndex = 1
        self.MoneyValue = 0
        self.EmblemValue = 0
        self.TutorialIndex = 1
        self.TutorialVisible = true
        self:ShowHUDDemo()
    elseif self.SelectedIndex == 5 then
        UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, "quit")
    end
end

function M:ApplyHUDDemoState()
    if not self.HUDWidget then
        return
    end

    local health_ratio = self.HealthRatios[self.HealthIndex] or 1.0
    local damage_alpha = 0.03 + (1.0 - health_ratio) * 0.18

    if self.HUDHealthBar then
        self.HUDHealthBar:SetPercent(health_ratio)
    end

    if self.HUDVignette then
        self.HUDVignette:SetRenderOpacity(damage_alpha)
    end

    if self.HUDMoneyText then
        self.HUDMoneyText:SetText(tostring(self.MoneyValue))
    end

    if self.HUDEmblemCount then
        self.HUDEmblemCount:SetText(tostring(self.EmblemValue))
    end

    if self.HUDTutorialText then
        self.HUDTutorialText:SetText(TutorialMessages[self.TutorialIndex])
    end

    if self.HUDTutorialPanel then
        if self.TutorialVisible then
            self.HUDTutorialPanel:SetVisibility(UE.ESlateVisibility.Visible)
        else
            self.HUDTutorialPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
        end
    end
end

function M:MoveMenuSelection(delta)
    local next_index = self.SelectedIndex + delta
    if next_index < 1 then
        next_index = #MenuButtonNames
    elseif next_index > #MenuButtonNames then
        next_index = 1
    end

    self.SelectedIndex = next_index
    self:RefreshMenuSelection()
end

function M:Down_Pressed()
    if self.Mode == "Menu" then
        self:MoveMenuSelection(1)
    elseif self.Mode == "HUD" then
        self.HealthIndex = self.HealthIndex + 1
        if self.HealthIndex > #self.HealthRatios then
            self.HealthIndex = 1
        end
        self:ApplyHUDDemoState()
    end
end

function M:Up_Pressed()
    if self.Mode == "Menu" then
        self:MoveMenuSelection(-1)
    elseif self.Mode == "HUD" then
        self.HealthIndex = self.HealthIndex - 1
        if self.HealthIndex < 1 then
            self.HealthIndex = #self.HealthRatios
        end
        self:ApplyHUDDemoState()
    end
end

function M:W_Pressed()
    self:Up_Pressed()
end

function M:S_Pressed()
    self:Down_Pressed()
end

function M:Enter_Pressed()
    if self.Mode == "Menu" then
        self:HandleMenuConfirm()
    end
end

function M:SpaceBar_Pressed()
    if self.Mode == "Menu" then
        self:HandleMenuConfirm()
    end
end

function M:Escape_Pressed()
    if self.Mode == "HUD" then
        self:ShowMainMenu()
    end
end

function M:One_Pressed()
    if self.Mode == "HUD" then
        self.HealthIndex = self.HealthIndex + 1
        if self.HealthIndex > #self.HealthRatios then
            self.HealthIndex = 1
        end
        self:ApplyHUDDemoState()
    end
end

function M:Two_Pressed()
    if self.Mode == "HUD" then
        self.TutorialVisible = not self.TutorialVisible
        self.TutorialIndex = self.TutorialIndex + 1
        if self.TutorialIndex > #TutorialMessages then
            self.TutorialIndex = 1
        end
        self:ApplyHUDDemoState()
    end
end

function M:Three_Pressed()
    if self.Mode == "HUD" then
        self.MoneyValue = self.MoneyValue + 1
        self.EmblemValue = (self.EmblemValue + 1) % 10
        self:ApplyHUDDemoState()
    end
end

return M
