# ShowMe project knowledge

- Communicate with the user in German. Addon messages, comments, metadata, and documentation are in English, matching HideMe.
- Read ShowMe.lua, ShowMe.toc and README.md before editing.
- Standalone WoW Forever Beta addon; interface 16001 copied from the installed HideMe metadata. Version 0.2.4.
- Work only within ShowMe for ShowMe requests. Other addons are separate projects.
- No external dependencies or build step. Git repository uses main. GitHub publication is requested; intended repository: https://github.com/ekimmerst/showme. Check actual remote and publication state before relying on this URL.
- Slash command: /showme nameplate-quest-icon on|off; /showme help; /showme status. On enables the icon; default off. SavedVariablesPerCharacter: ShowMeDB.nameplateQuestIcon.
- /showme all on|off sets every implemented setting and refreshes plates immediately. Keep settingKeys in ShowMe.lua updated when adding settings.
- Own unprotected overlays use QuestNormal, size 20, anchored RIGHT to the health-bar LEFT at -6, 0. Prefer UnitFrame.HealthBarsContainer, then healthBar, then the plate.
- The same setting enables a separate progress frame six pixels right of the health-bar area or visible level badge. Read counters from leftText/rightText, deduplicate identical counters and stack different counters. Hide both overlays before evaluation and on removal/off/discovery. Text failures must not suppress the icon; missing/restricted counters hide progress. Discover nameplate1..40 with GetNamePlateForUnit as well as GetNamePlates to support frames without namePlateUnitToken.
- Track NAME_PLATE_UNIT_ADDED/REMOVED and discover existing plates at login/world entry and setting changes. Hide old markers when a plate is removed/recycled. Only refresh visible tracked plates while enabled, every 0.5 seconds.
- C_TooltipInfo.GetUnit with Enum.TooltipDataLineType.QuestObjective detects unfinished localized counters. C_QuestLog.UnitIsRelatedToActiveQuest gates explicitly unrelated mobs and provides a fallback for absent/restricted/non-counter tooltip data. A false relation can be overridden only by a readable unfinished tooltip objective plus a non-secret true UnitCanAttack("player", unit), supporting friendly/neutral attackable quest NPCs.
- Never branch on secret values. Guard all inspected tooltip/flag/relation values. Use pcall around API inspection and direct SetShown for secret relation booleans; hide if rejected. Do not infer relations from mob names.
- Preserve Blizzard nameplate visibility and scripts; do not modify other addons or enable nameplate CVars automatically.
- Version 0.2.1 passed the extended Lua 5.1 simulation in TEMP/showme-progress-test.py using TEMP/showme-lua-runtime. The original showme-state-test.py remains an older harness. Tests cover off/on without frame unit-token fields, left/right counters, updates/completion, multiple counters, badge placement, restricted fallback, recycling and font failure/recovery. Real rendering and engine secret-value behavior remain unverified.
- The user confirmed on October 11, 2026 that the corrected progress display and off/on behavior work in game in version 0.2.1. Detailed compatibility checks remain pending, especially restricted data, completion updates, combat overlays, custom plate layouts and interaction with ForeverQuestMark.
- Update version and README for functional releases; change interface only with client evidence.
- The user confirmed on October 11, 2026 that version 0.2.4 works in game for friendly attackable quest mobs. Extended Lua 5.1 regression tests passed, including the false-relation override and restricted/error attackability checks.

## Addon list artwork

- Version 0.2.2 adds an open-eye icon matching HideMe's golden frame, violet glow and hand-painted WoW style. No Lua behavior changes.
- Media/Icon.png is the original image generated with the built-in image_gen tool using HideMe's icon as a reference.
- Media/Icon.tga is the 256x256 uncompressed 32-bit BGRA texture with top-left origin. ShowMe.toc references Interface\AddOns\ShowMe\Media\Icon through IconTexture.
- Keep Media when installing. Native addon-list rendering requires in-game verification; restart the client after adding the texture if needed.
