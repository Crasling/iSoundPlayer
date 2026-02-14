local addonName, iSP = ...

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Trigger Category Data                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- This file organizes all triggers into categories for easy UI display and management
-- Each trigger has a `versions` field for TOC version-gating:
--   "all"              = available in every TOC version
--   {min = N}          = available when tocVersion >= N
--   {max = N}          = available when tocVersion <= N
--   {min = N, max = M} = available when N <= tocVersion <= M

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
            "PLAYER_XP_UPDATE",
            "PLAYER_MONEY",
            "PLAYER_CONTROL_LOST",
            "PLAYER_CONTROL_GAINED",
            "PLAYER_EQUIPMENT_CHANGED",
            "PLAYER_STARTED_MOVING",
            "PLAYER_STOPPED_MOVING",
        }
    },
    {
        id = "combat",
        name = "Combat Events",
        desc = "Combat state changes and spellcasting",
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
        triggers = {
            "PLAYER_REGEN_DISABLED",
            "PLAYER_REGEN_ENABLED",
            "PLAYER_TARGET_CHANGED",
            "UNIT_SPELLCAST_START",
            "UNIT_SPELLCAST_SUCCEEDED",
            "UNIT_SPELLCAST_INTERRUPTED",
            "UPDATE_SHAPESHIFT_FORM",
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
            "CRITERIA_COMPLETE",
            "QUEST_LOG_UPDATE",
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
            "CHAT_MSG_LOOT",
            "CHAT_MSG_MONEY",
            "START_LOOT_ROLL",
            "ENCOUNTER_LOOT_RECEIVED",
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
            "PARTY_INVITE_REQUEST",
            "PARTY_LEADER_CHANGED",
            "CHAT_MSG_WHISPER",
            "CHAT_MSG_GUILD",
            "CHAT_MSG_PARTY",
            "CHAT_MSG_RAID",
            "FRIENDLIST_UPDATE",
            "GUILD_MOTD",
            "PLAYER_GUILD_UPDATE",
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
            "INSTANCE_LOCK_WARNING",
            "CHALLENGE_MODE_COMPLETED",
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
    {
        id = "profession",
        name = "Profession & Crafting",
        desc = "Trade, crafting, and skill events",
        icon = "Interface\\Icons\\Trade_BlackSmithing",
        triggers = {
            "TRADE_SHOW",
            "TRADE_CLOSED",
            "TRADE_ACCEPT_UPDATE",
            "CHAT_MSG_SKILL",
        }
    },
    {
        id = "economy",
        name = "Economy & Mail",
        desc = "Mail, auction house, and gold events",
        icon = "Interface\\Icons\\INV_Letter_15",
        triggers = {
            "MAIL_SHOW",
            "MAIL_CLOSED",
            "MAIL_INBOX_UPDATE",
            "MAIL_SEND_SUCCESS",
            "UPDATE_PENDING_MAIL",
            "AUCTION_HOUSE_SHOW",
            "AUCTION_HOUSE_CLOSED",
        }
    },
    {
        id = "pet_mount",
        name = "Pet & Mount",
        desc = "Pet battle and collection events",
        icon = "Interface\\Icons\\INV_Box_PetCarrier_01",
        triggers = {
            "PET_BATTLE_OPENING_START",
            "PET_BATTLE_CLOSE",
        }
    },
    {
        id = "ui_system",
        name = "UI & System",
        desc = "Inventory, durability, and collection events",
        icon = "Interface\\Icons\\Trade_Engineering",
        triggers = {
            "UPDATE_INVENTORY_DURABILITY",
            "BAG_UPDATE",
            "CALENDAR_UPDATE_PENDING_INVITES",
            "TRANSMOG_COLLECTION_UPDATED",
        }
    },
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Trigger Metadata                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Full metadata for each trigger
-- versions: "all", {min=N}, {max=N}, {min=N, max=M}
-- cooldown: seconds before trigger can fire again (0 = no cooldown)
-- unitFilter: only fire when the unit arg matches (e.g. "player")

iSP.TriggerMeta = {

    -- ── Player Events ──────────────────────────────────────────────────────────

    PLAYER_LOGIN = {
        category = "player",
        name = "Player Login",
        desc = "When you log into the game",
        event = "PLAYER_LOGIN",
        icon = "Interface\\Icons\\Ability_Mount_RidingHorse",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_LEVEL_UP = {
        category = "player",
        name = "Level Up",
        desc = "When you gain a level",
        event = "PLAYER_LEVEL_UP",
        icon = "Interface\\Icons\\Spell_Holy_BorrowedTime",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_DEAD = {
        category = "player",
        name = "Player Death",
        desc = "When your character dies",
        event = "PLAYER_DEAD",
        icon = "Interface\\Icons\\Ability_Rogue_FeignDeath",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_ALIVE = {
        category = "player",
        name = "Player Alive",
        desc = "When you resurrect",
        event = "PLAYER_ALIVE",
        icon = "Interface\\Icons\\Spell_Holy_Resurrection",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_UNGHOST = {
        category = "player",
        name = "Release Spirit",
        desc = "When you release your spirit or return to body",
        event = "PLAYER_UNGHOST",
        icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_XP_UPDATE = {
        category = "player",
        name = "XP Gained",
        desc = "When you gain experience points",
        event = "PLAYER_XP_UPDATE",
        icon = "Interface\\Icons\\Spell_Holy_BorrowedTime",
        versions = "all",
        cooldown = 2,
    },
    PLAYER_MONEY = {
        category = "player",
        name = "Gold Changed",
        desc = "When you gain or spend gold",
        event = "PLAYER_MONEY",
        icon = "Interface\\Icons\\INV_Misc_Coin_01",
        versions = "all",
        cooldown = 2,
    },
    PLAYER_CONTROL_LOST = {
        category = "player",
        name = "Control Lost",
        desc = "When you lose control (fear, MC, taxi)",
        event = "PLAYER_CONTROL_LOST",
        icon = "Interface\\Icons\\Spell_Shadow_Possession",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_CONTROL_GAINED = {
        category = "player",
        name = "Control Regained",
        desc = "When you regain control",
        event = "PLAYER_CONTROL_GAINED",
        icon = "Interface\\Icons\\Spell_Holy_DispelMagic",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_EQUIPMENT_CHANGED = {
        category = "player",
        name = "Gear Changed",
        desc = "When you equip or unequip gear",
        event = "PLAYER_EQUIPMENT_CHANGED",
        icon = "Interface\\Icons\\INV_Chest_Chain",
        versions = "all",
        cooldown = 3,
    },
    PLAYER_STARTED_MOVING = {
        category = "player",
        name = "Started Moving",
        desc = "When you begin moving",
        event = "PLAYER_STARTED_MOVING",
        icon = "Interface\\Icons\\Ability_Rogue_Sprint",
        versions = "all",
        cooldown = 3,
    },
    PLAYER_STOPPED_MOVING = {
        category = "player",
        name = "Stopped Moving",
        desc = "When you stop moving",
        event = "PLAYER_STOPPED_MOVING",
        icon = "Interface\\Icons\\Spell_Holy_SealOfValor",
        versions = "all",
        cooldown = 3,
    },

    -- ── Combat Events ──────────────────────────────────────────────────────────

    PLAYER_REGEN_DISABLED = {
        category = "combat",
        name = "Enter Combat",
        desc = "When you enter combat",
        event = "PLAYER_REGEN_DISABLED",
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_REGEN_ENABLED = {
        category = "combat",
        name = "Exit Combat",
        desc = "When you exit combat",
        event = "PLAYER_REGEN_ENABLED",
        icon = "Interface\\Icons\\Spell_Nature_Tranquility",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_TARGET_CHANGED = {
        category = "combat",
        name = "Target Changed",
        desc = "When you change your target",
        event = "PLAYER_TARGET_CHANGED",
        icon = "Interface\\Icons\\Ability_Hunter_MarkedForDeath",
        versions = "all",
        cooldown = 0,
    },
    UNIT_SPELLCAST_START = {
        category = "combat",
        name = "Spell Casting",
        desc = "When you begin casting a spell",
        event = "UNIT_SPELLCAST_START",
        icon = "Interface\\Icons\\Spell_Nature_Starfall",
        versions = "all",
        cooldown = 2,
        unitFilter = "player",
    },
    UNIT_SPELLCAST_SUCCEEDED = {
        category = "combat",
        name = "Spell Cast Complete",
        desc = "When you finish casting a spell",
        event = "UNIT_SPELLCAST_SUCCEEDED",
        icon = "Interface\\Icons\\Spell_Nature_Lightning",
        versions = "all",
        cooldown = 2,
        unitFilter = "player",
    },
    UNIT_SPELLCAST_INTERRUPTED = {
        category = "combat",
        name = "Spell Interrupted",
        desc = "When your spell is interrupted",
        event = "UNIT_SPELLCAST_INTERRUPTED",
        icon = "Interface\\Icons\\Spell_Frost_IceShock",
        versions = "all",
        cooldown = 0,
        unitFilter = "player",
    },
    UPDATE_SHAPESHIFT_FORM = {
        category = "combat",
        name = "Form/Stance Change",
        desc = "When you change forms or stances",
        event = "UPDATE_SHAPESHIFT_FORM",
        icon = "Interface\\Icons\\Ability_Druid_CatForm",
        versions = "all",
        cooldown = 0,
    },

    -- ── Achievements & Quests ──────────────────────────────────────────────────

    ACHIEVEMENT_EARNED = {
        category = "rewards",
        name = "Achievement",
        desc = "When you earn an achievement",
        event = "ACHIEVEMENT_EARNED",
        icon = "Interface\\Icons\\Achievement_General",
        versions = "all",
        cooldown = 0,
    },
    QUEST_COMPLETE = {
        category = "rewards",
        name = "Quest Complete",
        desc = "When you complete a quest",
        event = "QUEST_COMPLETE",
        icon = "Interface\\Icons\\Achievement_Quests_Completed_08",
        versions = "all",
        cooldown = 0,
    },
    QUEST_ACCEPTED = {
        category = "rewards",
        name = "Quest Accepted",
        desc = "When you accept a new quest",
        event = "QUEST_ACCEPTED",
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        versions = "all",
        cooldown = 0,
    },
    QUEST_TURNED_IN = {
        category = "rewards",
        name = "Quest Turned In",
        desc = "When you turn in a completed quest",
        event = "QUEST_TURNED_IN",
        icon = "Interface\\Icons\\INV_Misc_SealOfTheDawn",
        versions = "all",
        cooldown = 0,
    },
    CRITERIA_COMPLETE = {
        category = "rewards",
        name = "Criteria Complete",
        desc = "When you complete an achievement criteria",
        event = "CRITERIA_COMPLETE",
        icon = "Interface\\Icons\\Achievement_General",
        versions = "all",
        cooldown = 0,
    },
    QUEST_LOG_UPDATE = {
        category = "rewards",
        name = "Quest Log Updated",
        desc = "When your quest log changes",
        event = "QUEST_LOG_UPDATE",
        icon = "Interface\\Icons\\INV_Misc_Book_09",
        versions = "all",
        cooldown = 5,
    },

    -- ── Loot & Items ───────────────────────────────────────────────────────────

    LOOT_READY = {
        category = "loot",
        name = "Loot Ready",
        desc = "When loot becomes available",
        event = "LOOT_READY",
        icon = "Interface\\Icons\\INV_Misc_Bag_10_Green",
        versions = {min = 50000},
        cooldown = 0,
    },
    LOOT_OPENED = {
        category = "loot",
        name = "Loot Window Opened",
        desc = "When you open a loot window",
        event = "LOOT_OPENED",
        icon = "Interface\\Icons\\INV_Misc_Bag_08",
        versions = "all",
        cooldown = 0,
    },
    LOOT_CLOSED = {
        category = "loot",
        name = "Loot Window Closed",
        desc = "When you close a loot window",
        event = "LOOT_CLOSED",
        icon = "Interface\\Icons\\INV_Misc_Bag_07_Green",
        versions = "all",
        cooldown = 0,
    },
    CHAT_MSG_LOOT = {
        category = "loot",
        name = "Loot Message",
        desc = "When a loot message appears in chat",
        event = "CHAT_MSG_LOOT",
        icon = "Interface\\Icons\\INV_Misc_Bag_17",
        versions = "all",
        cooldown = 0,
    },
    CHAT_MSG_MONEY = {
        category = "loot",
        name = "Money Looted",
        desc = "When money is looted",
        event = "CHAT_MSG_MONEY",
        icon = "Interface\\Icons\\INV_Misc_Coin_02",
        versions = "all",
        cooldown = 0,
    },
    START_LOOT_ROLL = {
        category = "loot",
        name = "Loot Roll Started",
        desc = "When a group loot roll begins",
        event = "START_LOOT_ROLL",
        icon = "Interface\\Icons\\INV_Misc_Dice_01",
        versions = "all",
        cooldown = 0,
    },
    ENCOUNTER_LOOT_RECEIVED = {
        category = "loot",
        name = "Boss Loot Received",
        desc = "When boss loot is received",
        event = "ENCOUNTER_LOOT_RECEIVED",
        icon = "Interface\\Icons\\INV_Misc_Bag_10_Blue",
        versions = {min = 120000},
        cooldown = 0,
    },

    -- ── Group & Social ─────────────────────────────────────────────────────────

    GROUP_JOINED = {
        category = "group",
        name = "Group Joined",
        desc = "When you join a party or raid",
        event = "GROUP_JOINED",
        icon = "Interface\\Icons\\Achievement_General_StayClassy",
        versions = "all",
        cooldown = 0,
    },
    GROUP_LEFT = {
        category = "group",
        name = "Group Left",
        desc = "When you leave a party or raid",
        event = "GROUP_LEFT",
        icon = "Interface\\Icons\\Spell_ChargeNegative",
        versions = "all",
        cooldown = 0,
    },
    GROUP_ROSTER_UPDATE = {
        category = "group",
        name = "Group Roster Update",
        desc = "When someone joins or leaves your group",
        event = "GROUP_ROSTER_UPDATE",
        icon = "Interface\\Icons\\INV_Misc_GroupNeedMore",
        versions = "all",
        cooldown = 5,
    },
    READY_CHECK = {
        category = "group",
        name = "Ready Check",
        desc = "When a ready check is initiated",
        event = "READY_CHECK",
        icon = "Interface\\Icons\\Ability_Hunter_MasterMarksman",
        versions = "all",
        cooldown = 0,
    },
    READY_CHECK_CONFIRM = {
        category = "group",
        name = "Ready Check Response",
        desc = "When someone responds to ready check",
        event = "READY_CHECK_CONFIRM",
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        versions = "all",
        cooldown = 0,
    },
    PARTY_INVITE_REQUEST = {
        category = "group",
        name = "Party Invite",
        desc = "When you receive a party invite",
        event = "PARTY_INVITE_REQUEST",
        icon = "Interface\\Icons\\INV_Letter_01",
        versions = "all",
        cooldown = 0,
    },
    PARTY_LEADER_CHANGED = {
        category = "group",
        name = "Leader Changed",
        desc = "When the party leader changes",
        event = "PARTY_LEADER_CHANGED",
        icon = "Interface\\Icons\\Achievement_General_StayClassy",
        versions = "all",
        cooldown = 0,
    },
    CHAT_MSG_WHISPER = {
        category = "group",
        name = "Whisper Received",
        desc = "When you receive a whisper",
        event = "CHAT_MSG_WHISPER",
        icon = "Interface\\Icons\\INV_Letter_04",
        versions = "all",
        cooldown = 0,
    },
    CHAT_MSG_GUILD = {
        category = "group",
        name = "Guild Chat",
        desc = "When a guild chat message is received",
        event = "CHAT_MSG_GUILD",
        icon = "Interface\\Icons\\INV_Tabard_A_01HonorHold",
        versions = "all",
        cooldown = 0,
    },
    CHAT_MSG_PARTY = {
        category = "group",
        name = "Party Chat",
        desc = "When a party chat message is received",
        event = "CHAT_MSG_PARTY",
        icon = "Interface\\Icons\\INV_Misc_GroupNeedMore",
        versions = "all",
        cooldown = 0,
    },
    CHAT_MSG_RAID = {
        category = "group",
        name = "Raid Chat",
        desc = "When a raid chat message is received",
        event = "CHAT_MSG_RAID",
        icon = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
        versions = "all",
        cooldown = 0,
    },
    FRIENDLIST_UPDATE = {
        category = "group",
        name = "Friend Online/Offline",
        desc = "When a friend comes online or goes offline",
        event = "FRIENDLIST_UPDATE",
        icon = "Interface\\Icons\\Ability_Warrior_RallyingCry",
        versions = "all",
        cooldown = 5,
    },
    GUILD_MOTD = {
        category = "group",
        name = "Guild MOTD",
        desc = "When the guild message of the day is displayed",
        event = "GUILD_MOTD",
        icon = "Interface\\Icons\\INV_Scroll_03",
        versions = "all",
        cooldown = 0,
    },
    PLAYER_GUILD_UPDATE = {
        category = "group",
        name = "Guild Update",
        desc = "When your guild status changes",
        event = "PLAYER_GUILD_UPDATE",
        icon = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend",
        versions = "all",
        cooldown = 0,
    },

    -- ── Dungeon & Raid ─────────────────────────────────────────────────────────

    PLAYER_ENTERING_WORLD = {
        category = "dungeon",
        name = "Entering World",
        desc = "When you enter the world or reload UI",
        event = "PLAYER_ENTERING_WORLD",
        icon = "Interface\\Icons\\Spell_Arcane_PortalDalaran",
        versions = "all",
        cooldown = 0,
    },
    ZONE_CHANGED_NEW_AREA = {
        category = "dungeon",
        name = "Zone Changed",
        desc = "When you enter a new zone",
        event = "ZONE_CHANGED_NEW_AREA",
        icon = "Interface\\Icons\\INV_Misc_Map_01",
        versions = "all",
        cooldown = 0,
    },
    ENCOUNTER_START = {
        category = "dungeon",
        name = "Boss Encounter Start",
        desc = "When a boss encounter begins",
        event = "ENCOUNTER_START",
        icon = "Interface\\Icons\\Spell_Fire_FelFlameStrike",
        versions = {min = 30000},
        cooldown = 0,
    },
    ENCOUNTER_END = {
        category = "dungeon",
        name = "Boss Encounter End",
        desc = "When a boss encounter ends",
        event = "ENCOUNTER_END",
        icon = "Interface\\Icons\\Ability_Warrior_VictoryRush",
        versions = {min = 30000},
        cooldown = 0,
    },
    BOSS_KILL = {
        category = "dungeon",
        name = "Boss Killed",
        desc = "When your group kills a boss",
        event = "BOSS_KILL",
        icon = "Interface\\Icons\\Achievement_Boss_Onyxia",
        versions = {min = 30000},
        cooldown = 0,
    },
    INSTANCE_LOCK_WARNING = {
        category = "dungeon",
        name = "Lockout Warning",
        desc = "When you receive an instance lockout warning",
        event = "INSTANCE_LOCK_WARNING",
        icon = "Interface\\Icons\\INV_Misc_Key_10",
        versions = {min = 30000},
        cooldown = 0,
    },
    CHALLENGE_MODE_COMPLETED = {
        category = "dungeon",
        name = "M+ Completed",
        desc = "When a Mythic+ dungeon is completed",
        event = "CHALLENGE_MODE_COMPLETED",
        icon = "Interface\\Icons\\Achievement_ChallengeMode_Gold",
        versions = {min = 120000},
        cooldown = 0,
    },

    -- ── PvP - Basic ────────────────────────────────────────────────────────────

    PVP_HONORABLE_KILL = {
        category = "pvp_basic",
        name = "Honorable Kill",
        desc = "When you get an honorable kill",
        event = nil,
        icon = "Interface\\Icons\\Achievement_BG_killingblow_berserker",
        versions = "all",
        cooldown = 0,
    },

    -- ── PvP - Multi-Kills ──────────────────────────────────────────────────────

    PVP_DOUBLE_KILL = {
        category = "pvp_multikill",
        name = "Double Kill",
        desc = "Kill 2 players within 10 seconds",
        event = nil,
        icon = "Interface\\Icons\\Ability_Warrior_DoubleEdge",
        versions = "all",
        cooldown = 0,
        threshold = 2,
    },
    PVP_TRIPLE_KILL = {
        category = "pvp_multikill",
        name = "Triple Kill",
        desc = "Kill 3 players within 10 seconds",
        event = nil,
        icon = "Interface\\Icons\\Ability_Rogue_ImprovedAmbush",
        versions = "all",
        cooldown = 0,
        threshold = 3,
    },
    PVP_MULTI_KILL = {
        category = "pvp_multikill",
        name = "Multi Kill",
        desc = "Kill 4+ players within 10 seconds",
        event = nil,
        icon = "Interface\\Icons\\Ability_Warrior_Cleave",
        versions = "all",
        cooldown = 0,
        threshold = 4,
    },

    -- ── PvP - Killing Sprees ───────────────────────────────────────────────────

    PVP_KILLING_SPREE = {
        category = "pvp_spree",
        name = "Killing Spree",
        desc = "Reach 5 kills without dying",
        event = nil,
        icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
        versions = "all",
        cooldown = 0,
        threshold = 5,
    },
    PVP_DOMINATING = {
        category = "pvp_spree",
        name = "Dominating",
        desc = "Reach 10 kills without dying",
        event = nil,
        icon = "Interface\\Icons\\Achievement_BG_ab_kill_at_mine",
        versions = "all",
        cooldown = 0,
        threshold = 10,
    },
    PVP_UNSTOPPABLE = {
        category = "pvp_spree",
        name = "Unstoppable",
        desc = "Reach 15 kills without dying",
        event = nil,
        icon = "Interface\\Icons\\Ability_Warrior_RallyingCry",
        versions = "all",
        cooldown = 0,
        threshold = 15,
    },
    PVP_GODLIKE = {
        category = "pvp_spree",
        name = "Godlike",
        desc = "Reach 20+ kills without dying",
        event = nil,
        icon = "Interface\\Icons\\Achievement_PVP_A_16",
        versions = "all",
        cooldown = 0,
        threshold = 20,
    },

    -- ── Profession & Crafting ──────────────────────────────────────────────────

    TRADE_SHOW = {
        category = "profession",
        name = "Trade Window Opened",
        desc = "When a trade window opens",
        event = "TRADE_SHOW",
        icon = "Interface\\Icons\\INV_Misc_Coin_01",
        versions = "all",
        cooldown = 0,
    },
    TRADE_CLOSED = {
        category = "profession",
        name = "Trade Window Closed",
        desc = "When a trade window closes",
        event = "TRADE_CLOSED",
        icon = "Interface\\Icons\\INV_Misc_Coin_01",
        versions = "all",
        cooldown = 0,
    },
    TRADE_ACCEPT_UPDATE = {
        category = "profession",
        name = "Trade Accepted",
        desc = "When a trade is accepted or declined",
        event = "TRADE_ACCEPT_UPDATE",
        icon = "Interface\\Icons\\INV_Misc_Coin_02",
        versions = "all",
        cooldown = 0,
    },
    CHAT_MSG_SKILL = {
        category = "profession",
        name = "Skill Up",
        desc = "When you gain a profession skill level",
        event = "CHAT_MSG_SKILL",
        icon = "Interface\\Icons\\Trade_BlackSmithing",
        versions = "all",
        cooldown = 0,
    },

    -- ── Economy & Mail ─────────────────────────────────────────────────────────

    MAIL_SHOW = {
        category = "economy",
        name = "Mailbox Opened",
        desc = "When you open a mailbox",
        event = "MAIL_SHOW",
        icon = "Interface\\Icons\\INV_Letter_15",
        versions = "all",
        cooldown = 0,
    },
    MAIL_CLOSED = {
        category = "economy",
        name = "Mailbox Closed",
        desc = "When you close a mailbox",
        event = "MAIL_CLOSED",
        icon = "Interface\\Icons\\INV_Letter_15",
        versions = "all",
        cooldown = 0,
    },
    MAIL_INBOX_UPDATE = {
        category = "economy",
        name = "New Mail",
        desc = "When your mailbox inbox updates",
        event = "MAIL_INBOX_UPDATE",
        icon = "Interface\\Icons\\INV_Letter_02",
        versions = "all",
        cooldown = 0,
    },
    MAIL_SEND_SUCCESS = {
        category = "economy",
        name = "Mail Sent",
        desc = "When a mail is sent successfully",
        event = "MAIL_SEND_SUCCESS",
        icon = "Interface\\Icons\\INV_Letter_03",
        versions = "all",
        cooldown = 0,
    },
    UPDATE_PENDING_MAIL = {
        category = "economy",
        name = "Mail Notification",
        desc = "When you have pending mail",
        event = "UPDATE_PENDING_MAIL",
        icon = "Interface\\Icons\\INV_Letter_01",
        versions = "all",
        cooldown = 0,
    },
    AUCTION_HOUSE_SHOW = {
        category = "economy",
        name = "Auction House Opened",
        desc = "When you open the Auction House",
        event = "AUCTION_HOUSE_SHOW",
        icon = "Interface\\Icons\\INV_Hammer_15",
        versions = "all",
        cooldown = 0,
    },
    AUCTION_HOUSE_CLOSED = {
        category = "economy",
        name = "Auction House Closed",
        desc = "When you close the Auction House",
        event = "AUCTION_HOUSE_CLOSED",
        icon = "Interface\\Icons\\INV_Hammer_15",
        versions = "all",
        cooldown = 0,
    },

    -- ── Pet & Mount ────────────────────────────────────────────────────────────

    PET_BATTLE_OPENING_START = {
        category = "pet_mount",
        name = "Pet Battle Start",
        desc = "When a pet battle begins",
        event = "PET_BATTLE_OPENING_START",
        icon = "Interface\\Icons\\INV_Box_PetCarrier_01",
        versions = {min = 50000},
        cooldown = 0,
    },
    PET_BATTLE_CLOSE = {
        category = "pet_mount",
        name = "Pet Battle End",
        desc = "When a pet battle ends",
        event = "PET_BATTLE_CLOSE",
        icon = "Interface\\Icons\\INV_Box_PetCarrier_01",
        versions = {min = 50000},
        cooldown = 0,
    },

    -- ── UI & System ────────────────────────────────────────────────────────────

    UPDATE_INVENTORY_DURABILITY = {
        category = "ui_system",
        name = "Durability Changed",
        desc = "When your gear durability changes",
        event = "UPDATE_INVENTORY_DURABILITY",
        icon = "Interface\\Icons\\Trade_Engineering",
        versions = "all",
        cooldown = 5,
    },
    BAG_UPDATE = {
        category = "ui_system",
        name = "Bag Contents Changed",
        desc = "When your bag contents change",
        event = "BAG_UPDATE",
        icon = "Interface\\Icons\\INV_Misc_Bag_08",
        versions = "all",
        cooldown = 5,
    },
    CALENDAR_UPDATE_PENDING_INVITES = {
        category = "ui_system",
        name = "Calendar Invite",
        desc = "When you receive a calendar invite",
        event = "CALENDAR_UPDATE_PENDING_INVITES",
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        versions = {min = 30000},
        cooldown = 0,
    },
    TRANSMOG_COLLECTION_UPDATED = {
        category = "ui_system",
        name = "Transmog Collected",
        desc = "When you collect a new transmog appearance",
        event = "TRANSMOG_COLLECTION_UPDATED",
        icon = "Interface\\Icons\\INV_Chest_Cloth_17",
        versions = {min = 120000},
        cooldown = 0,
    },
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Helper Functions                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Check if a trigger is available for the current game version
function iSP:IsTriggerAvailable(triggerID)
    local meta = self.TriggerMeta[triggerID]
    if not meta then return false end

    local ver = meta.versions
    if not ver or ver == "all" then return true end

    local toc = tonumber(self.GameTocVersion) or 0
    if type(ver) == "table" then
        if ver.min and toc < ver.min then return false end
        if ver.max and toc > ver.max then return false end
        return true
    end

    return true
end

-- Get all triggers in a category (unfiltered)
function iSP:GetTriggersInCategory(categoryID)
    for _, category in ipairs(self.TriggerCategories) do
        if category.id == categoryID then
            return category.triggers
        end
    end
    return {}
end

-- Get available triggers in a category (filtered by version)
function iSP:GetAvailableTriggersInCategory(categoryID)
    local all = self:GetTriggersInCategory(categoryID)
    local available = {}
    for _, triggerID in ipairs(all) do
        if self:IsTriggerAvailable(triggerID) then
            table.insert(available, triggerID)
        end
    end
    return available
end

-- Check if a category has any available triggers
function iSP:IsCategoryAvailable(categoryID)
    local triggers = self:GetAvailableTriggersInCategory(categoryID)
    return #triggers > 0
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
