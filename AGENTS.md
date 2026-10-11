# ShowMe project knowledge

- Communicate with the user in German. Addon messages, comments, metadata, and documentation are in English, matching HideMe.
- Read ShowMe.lua, ShowMe.toc and README.md before editing.
- Standalone WoW Forever Beta addon; interface 16001 copied from the installed HideMe metadata. Version 0.1.0.
- Work only within ShowMe for ShowMe requests. Other addons are separate projects.
- No external dependencies or build step. Git repository uses main. GitHub publication is requested; intended repository: https://github.com/ekimmerst/showme. Check actual remote and publication state before relying on this URL.
- Slash command: /showme nameplate-quest-icon on|off; /showme help; /showme status. On enables the icon; default off. SavedVariablesPerCharacter: ShowMeDB.nameplateQuestIcon.
- Own unprotected overlays use QuestNormal, size 20, anchored RIGHT to the health-bar LEFT at -6, 0. Prefer UnitFrame.HealthBarsContainer, then healthBar, then the plate.
- Track NAME_PLATE_UNIT_ADDED/REMOVED and discover existing plates at login/world entry and setting changes. Hide old markers when a plate is removed/recycled. Only refresh visible tracked plates while enabled, every 0.5 seconds.
- C_TooltipInfo.GetUnit with Enum.TooltipDataLineType.QuestObjective detects unfinished localized counters. C_QuestLog.UnitIsRelatedToActiveQuest gates explicitly unrelated mobs and provides a fallback for absent/restricted/non-counter tooltip data.
- Never branch on secret values. Guard all inspected tooltip/flag/relation values. Use pcall around API inspection and direct SetShown for secret relation booleans; hide if rejected. Do not infer relations from mob names.
- Preserve Blizzard nameplate visibility and scripts; do not modify other addons or enable nameplate CVars automatically.
- Runtime tests remain unexecuted: prior temporary Lupa package cannot be imported, and network installation failed. A prepared harness is in the temporary folder as showme-state-test.py. Do not claim it passed.
- The user confirmed on October 11, 2026 that the addon works in game. Detailed compatibility checks remain pending, especially restricted data, completion updates, combat overlays, custom plate layouts and interaction with ForeverQuestMark.
- Update version and README for functional releases; change interface only with client evidence.
