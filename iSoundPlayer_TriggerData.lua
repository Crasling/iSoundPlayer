local addonName, iSP = ...

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Trigger Category Data                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- This file organizes all triggers into categories for easy UI display and management

iSP.TriggerCategories = {
    {
        id = "player",
        name = "Player Events",
        desc = "Basic player character events",
        icon = "Interface\\Icons\\Achievement_Character_Human_Male",
        triggers = {
            "PLAYER_LOGIN",
            "PLAYER_LEVEL_UP",
            "PLAYER_DEAD",
            "PLAYER_ALIVE",
            "PLAYER_UNGHOST",
        }
    },
    {
        id = "combat",
        name = "Combat Events",
        desc = "Combat state changes",
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
        triggers = {
            "PLAYER_REGEN_DISABLED",
            "PLAYER_REGEN_ENABLED",
            "PLAYER_TARGET_CHANGED",
        }
    },
    {
        id = "rewards",
        name = "Achievements & Quests",
        desc = "Progression rewards and milestones",
        icon = "Interface\\Icons\\Achievement_Quests_Completed_08",
        triggers = {
            "ACHIEVEMENT_EARNED",
            "QUEST_COMPLETE",
            "QUEST_ACCEPTED",
            "QUEST_TURNED_IN",
        }
    },
    {
        id = "loot",
        name = "Loot & Items",
        desc = "Loot and inventory events",
        icon = "Interface\\Icons\\INV_Misc_Bag_10_Green",
        triggers = {
            "LOOT_READY",
            "LOOT_OPENED",
            "LOOT_CLOSED",
        }
    },
    {
        id = "group",
        name = "Group & Social",
        desc = "Party, raid and social events",
        icon = "Interface\\Icons\\Achievement_General_StayClassy",
        triggers = {
            "GROUP_JOINED",
            "GROUP_LEFT",
            "GROUP_ROSTER_UPDATE",
            "READY_CHECK",
            "READY_CHECK_CONFIRM",
        }
    },
    {
        id = "dungeon",
        name = "Dungeon & Raid",
        desc = "Instance and encounter events",
        icon = "Interface\\Icons\\Achievement_Boss_Onyxia",
        triggers = {
            "PLAYER_ENTERING_WORLD",
            "ZONE_CHANGED_NEW_AREA",
            "ENCOUNTER_START",
            "ENCOUNTER_END",
            "BOSS_KILL",
        }
    },
    {
        id = "pvp_basic",
        name = "PvP - Kills",
        desc = "Basic PvP kill tracking",
        icon = "Interface\\Icons\\Achievement_BG_killingblow_berserker",
        triggers = {
            "PVP_HONORABLE_KILL",
        }
    },
    {
        id = "pvp_multikill",
        name = "PvP - Multi-Kills",
        desc = "Multiple kills within 10 seconds",
        icon = "Interface\\Icons\\Achievement_Arena_2v2_7",
        triggers = {
            "PVP_DOUBLE_KILL",
            "PVP_TRIPLE_KILL",
            "PVP_MULTI_KILL",
        }
    },
    {
        id = "pvp_spree",
        name = "PvP - Killing Sprees",
        desc = "Consecutive kills without dying",
        icon = "Interface\\Icons\\Ability_Warrior_RallyingCry",
        triggers = {
            "PVP_KILLING_SPREE",
            "PVP_DOMINATING",
            "PVP_UNSTOPPABLE",
            "PVP_GODLIKE",
        }
    },
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Trigger Metadata                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Full metadata for each trigger
iSP.TriggerMeta = {
    -- Player Events
    PLAYER_LOGIN = {
        category = "player",
        name = "Player Login",
        desc = "When you log into the game",
        event = "PLAYER_LOGIN",
        icon = "Interface\\Icons\\Ability_Mount_RidingHorse",
    },
    PLAYER_LEVEL_UP = {
        category = "player",
        name = "Level Up",
        desc = "When you gain a level",
        event = "PLAYER_LEVEL_UP",
        icon = "Interface\\Icons\\Spell_Holy_BorrowedTime",
    },
    PLAYER_DEAD = {
        category = "player",
        name = "Player Death",
        desc = "When your character dies",
        event = "PLAYER_DEAD",
        icon = "Interface\\Icons\\Ability_Rogue_FeignDeath",
    },
    PLAYER_ALIVE = {
        category = "player",
        name = "Player Alive",
        desc = "When you resurrect",
        event = "PLAYER_ALIVE",
        icon = "Interface\\Icons\\Spell_Holy_Resurrection",
    },
    PLAYER_UNGHOST = {
        category = "player",
        name = "Release Spirit",
        desc = "When you release your spirit or return to body",
        event = "PLAYER_UNGHOST",
        icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
    },

    -- Combat Events
    PLAYER_REGEN_DISABLED = {
        category = "combat",
        name = "Enter Combat",
        desc = "When you enter combat",
        event = "PLAYER_REGEN_DISABLED",
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
    },
    PLAYER_REGEN_ENABLED = {
        category = "combat",
        name = "Exit Combat",
        desc = "When you exit combat",
        event = "PLAYER_REGEN_ENABLED",
        icon = "Interface\\Icons\\Spell_Nature_Tranquility",
    },
    PLAYER_TARGET_CHANGED = {
        category = "combat",
        name = "Target Changed",
        desc = "When you change your target",
        event = "PLAYER_TARGET_CHANGED",
        icon = "Interface\\Icons\\Ability_Hunter_MarkedForDeath",
    },

    -- Achievements & Quests
    ACHIEVEMENT_EARNED = {
        category = "rewards",
        name = "Achievement",
        desc = "When you earn an achievement",
        event = "ACHIEVEMENT_EARNED",
        icon = "Interface\\Icons\\Achievement_General",
    },
    QUEST_COMPLETE = {
        category = "rewards",
        name = "Quest Complete",
        desc = "When you complete a quest",
        event = "QUEST_COMPLETE",
        icon = "Interface\\Icons\\Achievement_Quests_Completed_08",
    },
    QUEST_ACCEPTED = {
        category = "rewards",
        name = "Quest Accepted",
        desc = "When you accept a new quest",
        event = "QUEST_ACCEPTED",
        icon = "Interface\\Icons\\INV_Misc_Note_01",
    },
    QUEST_TURNED_IN = {
        category = "rewards",
        name = "Quest Turned In",
        desc = "When you turn in a completed quest",
        event = "QUEST_TURNED_IN",
        icon = "Interface\\Icons\\INV_Misc_SealOfTheDawn",
    },

    -- Loot & Items
    LOOT_READY = {
        category = "loot",
        name = "Loot Ready",
        desc = "When loot becomes available",
        event = "LOOT_READY",
        icon = "Interface\\Icons\\INV_Misc_Bag_10_Green",
    },
    LOOT_OPENED = {
        category = "loot",
        name = "Loot Window Opened",
        desc = "When you open a loot window",
        event = "LOOT_OPENED",
        icon = "Interface\\Icons\\INV_Misc_Bag_08",
    },
    LOOT_CLOSED = {
        category = "loot",
        name = "Loot Window Closed",
        desc = "When you close a loot window",
        event = "LOOT_CLOSED",
        icon = "Interface\\Icons\\INV_Misc_Bag_07_Green",
    },

    -- Group & Social
    GROUP_JOINED = {
        category = "group",
        name = "Group Joined",
        desc = "When you join a party or raid",
        event = "GROUP_JOINED",
        icon = "Interface\\Icons\\Achievement_General_StayClassy",
    },
    GROUP_LEFT = {
        category = "group",
        name = "Group Left",
        desc = "When you leave a party or raid",
        event = "GROUP_LEFT",
        icon = "Interface\\Icons\\Spell_ChargeNegative",
    },
    GROUP_ROSTER_UPDATE = {
        category = "group",
        name = "Group Roster Update",
        desc = "When someone joins or leaves your group",
        event = "GROUP_ROSTER_UPDATE",
        icon = "Interface\\Icons\\INV_Misc_GroupNeedMore",
    },
    READY_CHECK = {
        category = "group",
        name = "Ready Check",
        desc = "When a ready check is initiated",
        event = "READY_CHECK",
        icon = "Interface\\Icons\\Ability_Hunter_MasterMarksman",
    },
    READY_CHECK_CONFIRM = {
        category = "group",
        name = "Ready Check Response",
        desc = "When someone responds to ready check",
        event = "READY_CHECK_CONFIRM",
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
    },

    -- Dungeon & Raid
    PLAYER_ENTERING_WORLD = {
        category = "dungeon",
        name = "Entering World",
        desc = "When you enter the world or reload UI",
        event = "PLAYER_ENTERING_WORLD",
        icon = "Interface\\Icons\\Spell_Arcane_PortalDalaran",
    },
    ZONE_CHANGED_NEW_AREA = {
        category = "dungeon",
        name = "Zone Changed",
        desc = "When you enter a new zone",
        event = "ZONE_CHANGED_NEW_AREA",
        icon = "Interface\\Icons\\INV_Misc_Map_01",
    },
    ENCOUNTER_START = {
        category = "dungeon",
        name = "Boss Encounter Start",
        desc = "When a boss encounter begins",
        event = "ENCOUNTER_START",
        icon = "Interface\\Icons\\Spell_Fire_FelFlameStrike",
    },
    ENCOUNTER_END = {
        category = "dungeon",
        name = "Boss Encounter End",
        desc = "When a boss encounter ends",
        event = "ENCOUNTER_END",
        icon = "Interface\\Icons\\Ability_Warrior_VictoryRush",
    },
    BOSS_KILL = {
        category = "dungeon",
        name = "Boss Killed",
        desc = "When your group kills a boss",
        event = "BOSS_KILL",
        icon = "Interface\\Icons\\Achievement_Boss_Onyxia",
    },

    -- PvP - Basic
    PVP_HONORABLE_KILL = {
        category = "pvp_basic",
        name = "Honorable Kill",
        desc = "When you get an honorable kill",
        event = nil,  -- Custom combat log parsing
        icon = "Interface\\Icons\\Achievement_BG_killingblow_berserker",
    },

    -- PvP - Multi-Kills
    PVP_DOUBLE_KILL = {
        category = "pvp_multikill",
        name = "Double Kill",
        desc = "Kill 2 players within 10 seconds",
        event = nil,
        icon = "Interface\\Icons\\Ability_Warrior_DoubleEdge",
        threshold = 2,
    },
    PVP_TRIPLE_KILL = {
        category = "pvp_multikill",
        name = "Triple Kill",
        desc = "Kill 3 players within 10 seconds",
        event = nil,
        icon = "Interface\\Icons\\Ability_Rogue_ImprovedAmbush",
        threshold = 3,
    },
    PVP_MULTI_KILL = {
        category = "pvp_multikill",
        name = "Multi Kill",
        desc = "Kill 4+ players within 10 seconds",
        event = nil,
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        threshold = 4,
    },

    -- PvP - Killing Sprees
    PVP_KILLING_SPREE = {
        category = "pvp_spree",
        name = "Killing Spree",
        desc = "Reach 5 kills without dying",
        event = nil,
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        threshold = 5,
    },
    PVP_DOMINATING = {
        category = "pvp_spree",
        name = "Dominating",
        desc = "Reach 10 kills without dying",
        event = nil,
        icon = "Interface\\Icons\\Achievement_BG_ab_kill_at_mine",
        threshold = 10,
    },
    PVP_UNSTOPPABLE = {
        category = "pvp_spree",
        name = "Unstoppable",
        desc = "Reach 15 kills without dying",
        event = nil,
        icon = "Interface\\Icons\\Ability_Warrior_RallyingCry",
        threshold = 15,
    },
    PVP_GODLIKE = {
        category = "pvp_spree",
        name = "Godlike",
        desc = "Reach 20+ kills without dying",
        event = nil,
        icon = "Interface\\Icons\\Achievement_PVP_A_16",
        threshold = 20,
    },
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Helper Functions                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Get all triggers in a category
function iSP:GetTriggersInCategory(categoryID)
    for _, category in ipairs(self.TriggerCategories) do
        if category.id == categoryID then
            return category.triggers
        end
    end
    return {}
end

-- Get category for a trigger
function iSP:GetTriggerCategory(triggerID)
    if self.TriggerMeta[triggerID] then
        return self.TriggerMeta[triggerID].category
    end
    return nil
end

-- Get trigger display name
function iSP:GetTriggerName(triggerID)
    if self.TriggerMeta[triggerID] then
        return self.TriggerMeta[triggerID].name
    end
    return triggerID
end

-- Get trigger description
function iSP:GetTriggerDesc(triggerID)
    if self.TriggerMeta[triggerID] then
        return self.TriggerMeta[triggerID].desc
    end
    return ""
end

-- Get all category IDs
function iSP:GetAllCategories()
    local categories = {}
    for _, cat in ipairs(self.TriggerCategories) do
        table.insert(categories, cat.id)
    end
    return categories
end
