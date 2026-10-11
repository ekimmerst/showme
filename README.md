# ShowMe

Small standalone chat-controlled addon for the WoW Forever Beta, matching HideMe's command style. Version 0.2.1; interface 16001, matching the installed HideMe addon.

## Installation

Keep the ShowMe folder in Interface/AddOns and enable ShowMe in the character selection AddOns menu. Restart the client if ShowMe was installed while the game was running. No other addons are required.

## Commands

- /showme nameplate-quest-icon on: show a yellow quest exclamation mark to the left of nameplates and objective progress (for example, 3/10) to the right for mobs related to unfinished active quest objectives, including kill and quest-item objectives.
- /showme nameplate-quest-icon off: remove ShowMe's icons and progress text.
- /showme status: display the saved on/off setting.
- /showme help, or /showme without arguments: display usage.

Commands are case-insensitive and ignore surrounding whitespace. Invalid commands leave the setting unchanged. Icons are disabled by default. Settings are saved per character in ShowMeDB and persist across /reload and restarts. Changes apply immediately, including during combat, because ShowMe controls only its own unprotected overlays.

Enemy nameplates must be visible (normally toggled with V). ShowMe does not enable nameplates automatically.

## Behavior and compatibility

The 20-pixel QuestNormal atlas icon sits six pixels left of the standard health-bar area. Blizzard's nameplates and their state remain unchanged. Players and dead mobs are excluded when their flags can be read. Structured tooltip objective counters are parsed without English-only keywords. Completed counters no longer display an icon. Quest updates refresh visible plates; a half-second refresh handles delayed tooltip data and layout changes. Removed and recycled nameplates clear their old markers.

Progress text uses a separate overlay six pixels right of the health-bar area, or the visible level badge, and reads localized counters from either tooltip text column. Multiple unfinished counters appear on separate lines; identical counters appear once. Completed counters disappear. Quest-item objectives show collected items rather than killed mobs. Progress updates together with the icon and is hidden when plates are reused. Missing or restricted counters leave the progress text hidden. Text creation or layout failures do not prevent the quest icon from appearing.

Discovery also resolves nameplate1 through nameplate40 directly through C_NamePlate.GetNamePlateForUnit, so switching off/on does not depend solely on namePlateUnitToken fields being present on plate frames.

C_QuestLog.UnitIsRelatedToActiveQuest provides the fallback when tooltip data is missing, lacks counters, or is restricted. Restricted booleans are passed directly to SetShown; if the client rejects that operation, the icon stays hidden. ShowMe does not guess quest mobs from names. In restricted situations, the relation API determines eligibility and objective-level completion may not be available.

Custom nameplate addons may require anchor adjustments. Other quest-icon addons, such as ForeverQuestMark, can display additional icons independently; disable their icon feature if duplicate marks are unwanted.

## Verification

Version 0.2.1 passed a Lua 5.1 simulation using a temporary Lupa runtime: defaults, commands, localized counters, completion, restricted-data fallbacks, polling, removal/recycling, world/combat events, missing plate tokens, repeated off/on, both tooltip columns, multiple counters, level-badge placement, and text-creation failure/recovery. The user confirmed on October 11, 2026 that the corrected progress display and off/on behavior work in game. Detailed compatibility checks remain pending; the mocks do not reproduce the client's rendering or secret-value enforcement.

In-game check: enable the feature near an unfinished quest mob, confirm a yellow exclamation mark on the left and a counter such as 3/10 on the right, kill another mob and check the counter updates, compare an unrelated mob, finish the objective, test off/on and /reload, enter combat, and move away until plates disappear and are reused. Also test multiple objectives, quest-item objectives and the active nameplate addons.
