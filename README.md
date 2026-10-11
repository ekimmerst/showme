# ShowMe

Small standalone chat-controlled addon for the WoW Forever Beta, matching HideMe's command style. Version 0.1.0; interface 16001, matching the installed HideMe addon.

## Installation

Keep the ShowMe folder in Interface/AddOns and enable ShowMe in the character selection AddOns menu. Restart the client if ShowMe was installed while the game was running. No other addons are required.

## Commands

- /showme nameplate-quest-icon on: show a yellow quest exclamation mark to the left of nameplates for mobs related to unfinished active quest objectives, including kill and quest-item objectives.
- /showme nameplate-quest-icon off: remove ShowMe's icons.
- /showme status: display the saved on/off setting.
- /showme help, or /showme without arguments: display usage.

Commands are case-insensitive and ignore surrounding whitespace. Invalid commands leave the setting unchanged. Icons are disabled by default. Settings are saved per character in ShowMeDB and persist across /reload and restarts. Changes apply immediately, including during combat, because ShowMe controls only its own unprotected overlays.

Enemy nameplates must be visible (normally toggled with V). ShowMe does not enable nameplates automatically.

## Behavior and compatibility

The 20-pixel QuestNormal atlas icon sits six pixels left of the standard health-bar area. Blizzard's nameplates and their state remain unchanged. Players and dead mobs are excluded when their flags can be read. Structured tooltip objective counters are parsed without English-only keywords. Completed counters no longer display an icon. Quest updates refresh visible plates; a half-second refresh handles delayed tooltip data and layout changes. Removed and recycled nameplates clear their old markers.

C_QuestLog.UnitIsRelatedToActiveQuest provides the fallback when tooltip data is missing, lacks counters, or is restricted. Restricted booleans are passed directly to SetShown; if the client rejects that operation, the icon stays hidden. ShowMe does not guess quest mobs from names. In restricted situations, the relation API determines eligibility and objective-level completion may not be available.

Custom nameplate addons may require anchor adjustments. Other quest-icon addons, such as ForeverQuestMark, can display additional icons independently; disable their icon feature if duplicate marks are unwanted.

## Verification

The code and installed ForeverQuestMark implementation were inspected for API and nameplate-layout compatibility. An automated Lua 5.1 simulation script was prepared, but could not run: the previous temporary Lupa runtime is unavailable and installing it was blocked by network access. No automated runtime tests are claimed as passed. The user confirmed on October 11, 2026 that the addon works in game.

In-game check: enable the feature near an unfinished quest mob, confirm a yellow exclamation mark on the left, compare an unrelated mob, finish the objective, test off/on and /reload, enter combat, and move away until plates disappear and are reused. Also test quest-item objectives and the active nameplate addons.
