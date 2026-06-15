# Sekiro UI Design Spec

Date: 2026-05-06
Project: `SekiroDemo`
Status: Draft for review

## 1. Goal

Create two UMG-based interfaces inspired by the provided Sekiro reference images:

- A title menu screen based on reference image 1
- An in-game HUD based on reference image 2

The delivery must be structured so the UI can move beyond a static mockup and become a reusable foundation for later gameplay integration.

The implementation target is:

- UMG for visual layout and asset composition
- `UmgMcp` as the preferred workflow for UMG asset authoring and iteration
- `UnLua` for UI behavior, event handling, preview flow, and data-driven updates

## 2. Scope

In scope:

- Build one title menu widget
- Build one HUD widget
- Build a preview flow that can switch between menu and HUD
- Bind both widgets to `UnLua`
- Expose clear Lua interfaces for later game-side integration
- Reuse the prepared PNG assets under `png_output`

Out of scope for this phase:

- Final gameplay wiring to a real combat or save/load system
- Full settings page implementation
- Production-grade animation polish matching the shipped Sekiro game
- Complex material-driven UI effects unless they are required for basic visual readability

## 3. Recommended Architecture

Recommended approach:

- Use `Widget Blueprint` assets for all visual structure and styling
- Use `UnLua` only for state, input, button events, preview control, and data updates
- Keep the title menu and HUD as separate top-level widgets
- Create a dedicated preview controller so the UI can be exercised without coupling it to final gameplay flow

Why this approach:

- It matches the strengths of `UmgMcp`
- It keeps UMG assets readable and editable in the editor
- It keeps Lua focused on behavior rather than pixel layout
- It provides a stable path to later connect real player, HUD, and menu logic

Rejected alternatives:

- A single root widget containing both menu and HUD inside a `WidgetSwitcher`
- A Lua-heavy dynamic widget construction approach with minimal UMG authoring

These alternatives are less suitable for a reference-driven UI recreation and would make later maintenance harder.

## 4. Asset and Folder Layout

Suggested project layout:

- `Content/UI/Textures/Sekiro/`
- `Content/UI/Textures/Sekiro/Menu/`
- `Content/UI/Textures/Sekiro/HUD/`
- `Content/UI/Textures/Sekiro/Shared/`
- `Content/UI/Widgets/Menu/`
- `Content/UI/Widgets/HUD/`
- `Content/UI/Blueprints/`
- `Content/Maps/`
- `Content/Script/UI/`

Planned assets:

- `Content/UI/Widgets/Menu/WBP_SekiroMainMenu`
- `Content/UI/Widgets/Menu/WBP_SekiroMenuButton`
- `Content/UI/Widgets/HUD/WBP_SekiroHUD`
- `Content/UI/Widgets/HUD/WBP_SekiroTutorialHint`
- `Content/UI/Widgets/HUD/WBP_SekiroResourceItem`
- `Content/UI/Blueprints/BP_SekiroUIPreviewController`
- `Content/UI/Blueprints/BP_SekiroUIPreviewGameMode` if a dedicated GameMode is needed
- `Content/Maps/L_UI_Preview`

Planned Lua files:

- `Content/Script/UI/WBP_SekiroMainMenu.lua`
- `Content/Script/UI/WBP_SekiroHUD.lua`
- `Content/Script/UI/BP_SekiroUIPreviewController.lua`

## 5. Main Menu Widget Design

Top-level widget:

- `WBP_SekiroMainMenu`

Planned structure:

- Root `Canvas Panel`
- Background black layer
- Large logo image layer
- Faded brushstroke or calligraphy background layer
- Centered vertical menu list
- Separate selection highlight image
- Bottom copyright text
- Bottom-right online/version status

Planned menu items:

- `NEW GAME`
- `LOG IN`
- `SETTINGS`
- `LANGUAGE`
- `QUIT GAME`

Planned reusable component:

- `WBP_SekiroMenuButton`

Responsibilities of the reusable button:

- Display menu text
- Support selected and unselected states
- Support hover feedback
- Keep visual logic out of the main menu root widget

Widget variable naming should stay Lua-friendly, for example:

- `Btn_NewGame`
- `Btn_Login`
- `Btn_Settings`
- `Btn_Language`
- `Btn_Quit`
- `Img_Selection`
- `Txt_Version`

## 6. HUD Widget Design

Top-level widget:

- `WBP_SekiroHUD`

Planned structure:

- Root `Canvas Panel`
- Full-screen vignette or damage overlay
- Top-left tutorial hint block
- Top-right slim resource bar area
- Right-side currency display
- Bottom-left thin health or stamina-style bar
- Bottom-right quick slot placeholder

Planned reusable components:

- `WBP_SekiroTutorialHint`
- `WBP_SekiroResourceItem`

Example named regions:

- `Panel_TutorialHint`
- `Img_DamageVignette`
- `Txt_Money`
- `Panel_TopRightResource`
- `Panel_QuickItem`
- `Bar_Health`

The HUD should be built so each visible block can be updated independently from Lua.

## 7. UnLua Binding Strategy

Each Widget Blueprint should bind directly to its own Lua module using the standard `UnLua` widget pattern.

Behavior split:

- `WBP_SekiroMainMenu.lua`
  - Initializes menu state
  - Handles button delegates
  - Handles keyboard navigation
  - Emits high-level events such as new game, settings, and quit

- `WBP_SekiroHUD.lua`
  - Initializes display state
  - Accepts data updates from the preview controller
  - Updates tutorial text, money, health ratio, and vignette intensity

- `BP_SekiroUIPreviewController.lua`
  - Creates widgets on `BeginPlay`
  - Controls UI switching between menu and HUD
  - Owns preview-only input and demo data
  - Acts as the first integration point for future game-side systems

Recommended Lua lifecycle hooks:

- `Construct`
- helper functions for UI updates
- explicit event handlers per button or input action

## 8. Preview Flow

Preview map:

- `L_UI_Preview`

Preview behavior:

- Start in title menu state
- Mouse cursor visible
- Input mode set for menu interaction
- Selecting `NEW GAME` transitions into HUD preview mode
- HUD preview mode allows demo values to change without real gameplay systems
- `Esc` or another clear preview input returns to title menu

This keeps the first delivery focused on UI structure and UI behavior while leaving gameplay integration for a later step.

## 9. Planned Lua Interface Surface

Menu-side functions:

- `SetSelectedIndex(Index)`
- `RefreshSelection()`
- `HandleMoveUp()`
- `HandleMoveDown()`
- `HandleConfirm()`
- `OnNewGame()`
- `OnSettings()`
- `OnLanguage()`
- `OnQuitGame()`

HUD-side functions:

- `SetHealthRatio(Value)`
- `SetMoney(Value)`
- `SetSpiritEmblem(Value)` or an equivalent resource update function
- `ShowTutorial(Text)`
- `HideTutorial()`
- `SetDamageVignetteAlpha(Value)`
- `SetQuickItemVisible(bVisible)`

Preview-controller functions:

- `ShowMainMenu()`
- `ShowHUDDemo()`
- `ApplyDemoState()`
- `CycleHUDDemoState()`

Data ownership rule:

- Widgets render state
- Preview controller owns demo state
- Future gameplay systems can replace the demo state source without rewriting the widgets

## 10. Visual Reconstruction Strategy

The target is strong visual similarity, not a one-to-one material or post-process recreation.

Main menu priorities:

- Overall composition
- Central logo readability
- Menu spacing and hierarchy
- Warm selected-state accent
- Bottom-right status and bottom copyright placement

HUD priorities:

- Dark, moody screen framing
- Readable edge vignette
- Independent overlay blocks
- Numeric values kept as text instead of baked into textures

Asset usage rules:

- Import reusable images from `png_output` into project content
- Prefer separate texture placement over baking text into a single flat background
- Preserve source aspect ratios whenever practical
- Use the PNGs as composable UI pieces, not only as full-screen images

Animation policy for phase 1:

- Subtle menu selection movement or fade
- Simple HUD show or hide transitions
- No heavy animation graph or sequencer requirement unless needed for readability

## 11. Input and Interaction

Menu:

- Mouse hover and click supported
- Keyboard up and down supported
- Confirm action supported

HUD preview:

- Preview-only inputs can adjust values such as health, money, or tutorial visibility
- `Esc` returns to menu

The preview input scheme exists only to validate the UI and Lua integration and can later be replaced by a real input layer.

## 12. Acceptance Criteria

The phase is accepted when all of the following are true:

- Opening `L_UI_Preview` shows the title menu automatically
- The title menu can be operated with mouse and keyboard
- Choosing `NEW GAME` switches into HUD preview mode
- The HUD can display changing demo values from Lua
- The HUD can return to the title menu
- Major layout elements remain stable at `1920x1080`
- Naming between UMG assets, Blueprint bindings, and Lua modules is consistent

## 13. Test Plan

Planned validation:

- Preview each widget alone in the editor to confirm layout and texture references
- Run the complete preview flow inside `L_UI_Preview`
- Quick resolution sanity check at full HD and at least one smaller editor window size

## 14. Risks and Mitigations

Risk:

- The installed `UnLua` package currently sits under `Plugins/UnLua/Plugins/UnLua`, which is less typical than a flat plugin placement

Mitigation:

- Verify editor recognition and binding flow before authoring all runtime connections

Risk:

- Reference fonts may not exist in the current project

Mitigation:

- Prioritize composition and atmosphere first
- Leave fonts as a replaceable asset choice if the exact style is unavailable

Risk:

- Some images in `png_output` may be source sheets rather than final UI-ready pieces

Mitigation:

- Reuse partial regions or composite multiple textures instead of forcing one texture to represent the whole layout

Risk:

- `UmgMcp` may not be active in the current editor session

Mitigation:

- Fall back to standard Unreal widget authoring if needed without changing the architecture

## 15. Assumptions

- `UnLua` is now installed and intended for use
- The current phase should deliver a strong previewable UI framework rather than final game integration
- The user wants both the title menu and HUD in this phase, with the menu implemented first

