--[[

NO, IT WILL TAKE FOREVER TO TRANSLATE EVERYTHING.
IT IS USED FOR SKILL DESCRIPTIONS FOR NOW.
--then i'll do it --[TW]Rain_bob

]]

translate.AddLanguage("en", "English")

LANG.Defense = "Defense"
LANG.Gunnery = "Gunnery"
LANG.Medical = "Medical"
LANG.Surgeon = "Surgeon"
LANG.Vitality = "Vitality"
LANG.Knowledge = "Knowledge"
LANG.BetterEngine = "Better Engine"
LANG.BetterWeapon = "Better Weapon"

LANG.Gunnery_d="+1% damage dealt with firearms"
LANG.Gunnery_ed="+3% damage dealt with firearms\nAbove Gunnery Level 15: +2.5% damage dealt with non-firearms per point"

LANG.Defense_d="+0.8% damage resistance from enemy bullets"
LANG.Defense_ed="+2.5% damage resistance from enemy bullets\nAbove Level 15: +2% damage resistance all sources but guns"

LANG.Medical_d="+2% effectiveness to medkits"
LANG.Medical_ed="+5% effectiveness to medkits"

LANG.Surgeon_d="+2% max ammo to medkits / +2% increased medkit recharge speed"
LANG.Surgeon_ed="+10% max ammo to medkits / +10% increased medkit recharge speed"

LANG.Vitality_d="+1 health"
LANG.Vitality_ed="+5 health"

LANG.Knowledge_d="+3% xp gain"
LANG.Knowledge_ed="+5% xp gain"

LANG.BetterEngine_d="+4 horsepower to vehicle you spawned."
LANG.BetterEngine_ed="+8 horsepower to vehicle you spawned.\n-4% boost delay\n+0.05% Max Speed"

LANG.BetterWeapon_d = "+1% weapon fire rate"
LANG.BetterWeapon_ed = "+2% weapon fire rate"

LANG.hpboost_1="Health Boost"
LANG.hpboost_1_d="Increases health by 15"
LANG.hpboost_1_ed="Increases health by 85"

LANG.dmgboost_1="Damage Boost"
LANG.dmgboost_1_d="+6% damage dealt"
LANG.dmgboost_1_ed="+47% damage dealt"

LANG.damageresistanceboost_1="Damage Resistance Boost"
LANG.damageresistanceboost_1_d="+7% boost to damage resistance"
LANG.damageresistanceboost_1_ed="+57% boost to damage resistance"

LANG.antipoison_1="Anti-Poison"
LANG.antipoison_1_d="Reduces damage taken from poison headcrabs by half (reduces up to 25 damage)"
LANG.antipoison_2_ed="Reduces damage taken from poison headcrabs by half (reduces up to 100 damage)"

LANG.critical_damage_1="Critical Damage I"
LANG.critical_damage_1_d="7% chance to deal 1.2x damage"
LANG.critical_damage_1_ed="12% chance to deal 2.2x damage"

LANG.better_knowledge_1="Better Knowledge"
LANG.better_knowledge_1_d="+40% xp gain from NPC kills"
LANG.better_knowledge_1_ed="2.35x xp gain from NPC kills if difficulty is above 650%.\n+10% boost to bonus xp on map completion, Knowledge skill +2% xp gain per point."

LANG.vampiric_killer_1="Vampiric Killer"
LANG.vampiric_killer_1_d="You gain +2 HP upon killing an NPC."
LANG.vampiric_killer_1_ed="You gain +4% health upon killing an NPC. Recovers max of 50 HP."

LANG.critical_damage_2="Critical Damage II"
LANG.critical_damage_2_d="Doesn't do anything."
LANG.critical_damage_2_ed="Improves Critical Damage I perk, chance 12% -> 19% and damage 2.2x -> 2.5x.\nAlso grants a 6% chance to inflict super critical hit, granting 4x damage!."

LANG.NoSpam = "Don't spam %s."

LANG.AllowedVehSpawn="Vehicle spawning is allowed! Press F3 (Spare 1) to spawn it."
LANG.SpawnVehicle = "Spawn Vehicle"
LANG.NoSpaceForSpawnVeh="Insufficient space for spawning in a vehicle!"
LANG.SpawnVehPlayerNear="There are players around you! Find an open space to spawn your vehicle."
LANG.SpawnVehNotAllowed="You may not spawn a vehicle at this time."
LANG.RemoveVehNotAllowed="You may not remove your vehicle at this time."

LANG.AllPlayersDied="All players have died!"
LANG.DiedBy="Died by #%s"

LANG.hl2="Half-Life 2"
LANG.hl2_ep1="Half-Life 2: Episode One"
LANG.hl2_ep2="Half-Life 2: Episode Two"

LANG.CompletedCampaign="Congratulations - you have completed %s."
LANG.AwardedXP="You were awarded %d XP"
LANG.LostXP="Lost %d XP."

LANG.NotAdmin="You're not admin!"
LANG.NotDead="You're not dead!"
LANG.CantRespawnWhileChangingMap="Map is currenlty being changed, you can't respawn at this time!"

LANG.ImportantNPCKilledByYou="You killed an important NPC actor!"
LANG.ImportantNPCKilledByOther="%s killed an important NPC actor!"
LANG.ImportantNPCDied="Important NPC actor has died!"

LANG.LVLMaxed="Level is maxed. You must prestige to go further."
LANG.LVLIncreased="Level increased: %i --> %i"

LANG.PrestigeMaxed="Prestige is maxed. Eternity to go even further."
LANG.PrestigeIncreased="Prestige increased! (%i --> %i)"
LANG.PrestigeFirstTime="%s prestiged for the first time!"

LANG.EternityIncreased="Eternity increased! (%i --> %i)"
LANG.EternitiesMaxed="You have reached maximum amount of Eternities. You must Celestialize to go even further beyond."

LANG.PetsLocked="You don't have unlocked Pets yet!"

LANG.scoreboard_singleplayer="1 Player"
LANG.scoreboard_players="%d Players"

LANG.alive="Alive"
LANG.completedmap="Completed Map"
LANG.dead="Dead"

LANG.ObjectiveTimeLeft=function(timeleftsec,timeleftmin,timeleft)
    return timeleftsec <= 0 and "Objective: Complete the map within "..timeleftmin.." minutes! (Time left: "..math.floor(timeleft - CurTime()).."s)" or "Objective: Complete the map within "..timeleftmin.." minutes and "..timeleftsec.." seconds! (Time left: "..math.floor(timeleft - CurTime()).."s)"
end

LANG.Difficulty="Difficulty: %s%%"
LANG.DifficultyTotal="%s%% total"

LANG.Health="Health: %s/%s (%d%%)"
LANG.Armor="Armor: %s/%s (%d%%)"

LANG.NextMapIn="Next Map in %s"
LANG.SwitchingMap="Switching Maps!"

LANG.RestartMapIn="Restarting Map in %s"
LANG.Restarting="Restarting Map!"

LANG.XPGained="%s XP gained"
LANG.TotalXPGained="(%s XP gained total)"

LANG.Help="Help"
LANG.HelpText="-= ABOUT THIS GAMEMODE =-\nWelcome to Half-Life 2 Campaign EX!\nThis gamemode is based on Half-Life 2 Campaign made by Jai 'Choccy' Fox,\nwith new stuff like Leveling, Skills and more!\n\n-= KEYBOARD SHORTCUTS =-\n[F1] (Show Help) - Opens this menu.\n[F2] (Show Team) - Toggles the navigation marker on your HUD.\n[F3] (Spare 1) - Spawns a vehicle if allowed.\n[F4] (Spare 2) - Removes a vehicle if you have one.\n\n-= OTHER NOTES =-\nOnce you're dead you cannot respawn until the next map.\nDifficulty increases along with XP gain."
LANG.HelpEXModeOn="EX Mode is enabled! Expect Map objectives, NPC variants and chaos here!"
LANG.HelpEXModeOff="EX Mode is disabled!"
LANG.HelpEndlessOn="\nEndless Mode is enabled. Difficulty cap is increased drastically. Progression eventually becomes exponential."
LANG.HelpEndlessOff="\nEndless Mode is disabled. Difficulty is limited, Skills and Perks have limited functionality."

LANG.AMode="Admin Mode"

LANG.AModeOn="enabled"
LANG.AModeOff="disabled"

LANG.UnspentSP="Unspent skill points: %s"
LANG.SpendDesiredSP="Right click to spend a desired amount of SP on a skill"
LANG.SpendAllSP="Click while holding SHIFT to spend all SP on desired skill"
LANG.YourSkills="Your Skills"
LANG.SkillIncrease="Increase %s"

LANG.Options="Options"
LANG.Option_DisableTinnitus="Disable Tinnitus/Earringing"
LANG.Option_DisableTinnitusToolTip="Disables annoying tinnitus sound on taking damage by explosion"

LANG.XP="XP: %s / %s (%s%%)"
LANG.Level="Level: %s"
LANG.SPs="Skill Points: %s"

LANG.NonEndlessDesc="\n\nIn Non-Endless Mode:\n"
LANG.EndlessDesc="\n\nIn Endless Mode:\n"

LANG.Prestige="Prestige: %s"
LANG.PrestigePerkDesc="Prestige Perks to give you more advantage"
LANG.PrestigeTxt="Prestige"
LANG.PrestigePoints="Prestige Points: %s"
LANG.PrestigeNotEnough="Not enough prestige"
LANG.Eternities="Eternities: %s"
LANG.Eternity="Eternity"
LANG.EternityPerkDesc="Eternity Perks. They are far more powerful."
LANG.CelestialityPoints="Celestiality Points: %s"
LANG.Celestiality="Celestiality"
LANG.CelestialityPerkDesc="Celestiality Perks"
LANG.PointsCost="Points Cost: %s"
LANG.PrestigeCost="Prestige need: %s"

LANG.prestige_text1="Prestige will reset all your levels, XP and skills, but you will gain +25% boost to xp gain (every prestige) and a perk point.\nPrestigin will also unlock new perks after time."
LANG.prestige_text2="You must reach Level %s and reach max XP for the next level in order to prestige."
LANG.prestige_text3="Prestiging for the first time will permanently increase skill points gain to 2 per level and will increase skills max level to 35."

LANG.eternity_text1="Eternity to reset your levels, XP, skills, prestiges and prestige perks, but you gain a +175% boost to xp gain (every eternity) and\nEternity point. Eternity perks are more powerful than regular perks."
LANG.eternity_text2="Must reach max xp needed for next level, level %s at %s prestiges in order to Eternity"

LANG.Inf="Infinity"

LANG.Unlock="Unlock"

LANG.Playermodels="Playermodels"
LANG.Refreshstats="Refresh Stats"
LANG.Skills="Skills"
LANG.Perks="Perks"

LANG.FP_text1="Ah a fellow player."
LANG.FP_text2="Congratulations on Prestiging."
LANG.FP_text3="You seem to start understanding the mechanics of this gamemode."
LANG.FP_text4="%s? That's a nice name."
LANG.FP_text5="Our name is..."
LANG.FP_notimetolose="Gordon! We got no time to lose! We must keep on going!"
LANG.FP_perksunlock="Perks unlocked."
LANG.FP_bonuslvl="Each level up awards you with 2 skill points and skills max level increased to 35."

LANG.UP_NEEDSP="You need Skill Points to upgrade this skill!"
LANG.UP_MAXED="You have reached the max amount of points for this skill!"
LANG.UP_INCREASED="Increased %s by %i point!"
LANG.UP_UNLOCKPERK="Perk Unlocked: %s"
LANG.UP_NOTENOUGH="Not enough %s"
LANG.UP_NOTENOUGHPOINTS="Not enough %s Points!"

LANG.NV_DAMAGEDBYAGV="YOU ARE BEING DAMAGED BY ANTLION GUARD VARIANT,\nGET AWAY FROM IT!!"

LANG.medkit_purpose="Heal people with your primary attack."
LANG.medkit_instructions="Effectiveness is increased by 2% per Medical skill point, max efficiency 120%. Remember, healing other players will give you 1/4 of health you heal!"

LANG.fm_fool="You Fool!"
LANG.fm_timedout="Timed Out!"

LANG.CP="%s has activated checkpoint!"
LANG.MINICP="%s has activated mini-checkpoint!"

LANG.AFK="You AFK too long!"

LANG.Dead_Chat="*DEAD* "
LANG.TEAM_Chat="(TEAM) "
LANG.Console="Console"