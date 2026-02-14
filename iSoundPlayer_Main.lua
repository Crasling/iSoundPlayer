-- ═════════════════════════════════════════════════════════════════════════════════
-- ██╗ ███████╗ ██████╗  ██╗   ██╗ ███╗   ██╗ ██████╗  ██████╗  ██╗      █████╗  ██╗   ██╗ ███████╗ ██████╗
-- ██║ ██╔════╝██╔═══██╗ ██║   ██║ ████╗  ██║ ██╔══██╗ ██╔══██╗ ██║     ██╔══██╗ ╚██╗ ██╔╝ ██╔════╝ ██╔══██╗
-- ██║ ███████╗██║   ██║ ██║   ██║ ██╔██╗ ██║ ██║  ██║ ██████╔╝ ██║     ███████║  ╚████╔╝  █████╗   ██████╔╝
-- ██║ ╚════██║██║   ██║ ██║   ██║ ██║╚██╗██║ ██║  ██║ ██╔═══╝  ██║     ██╔══██║   ╚██╔╝   ██╔══╝   ██╔══██╗
-- ██║ ███████║╚██████╔╝ ╚██████╔╝ ██║ ╚████║ ██████╔╝ ██║      ███████╗██║  ██║    ██║    ███████╗ ██║  ██║
-- ╚═╝ ╚══════╝ ╚═════╝   ╚═════╝  ╚═╝  ╚═══╝ ╚═════╝  ╚═╝      ╚══════╝╚═╝  ╚═╝    ╚═╝    ╚══════╝ ╚═╝  ╚═╝
-- ═════════════════════════════════════════════════════════════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Namespace                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local addonName, iSP = ...
local Title = select(2, C_AddOns.GetAddOnInfo(addonName)):gsub("%s*v?[%d%.]+$", "")
local Version = C_AddOns.GetAddOnMetadata(addonName, "Version")
local Author = C_AddOns.GetAddOnMetadata(addonName, "Author")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Localization                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local L = iSP.L or {}
local Colors = iSP.Colors or {}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Libraries                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local LDBroker = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Addon Metadata                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iSP.Title = Title
iSP.Version = Version
iSP.Author = Author
iSP.CurrentRealm = GetRealmName()
iSP.AddonPath = "Interface\\Addons\\iSoundPlayer\\"
iSP.SoundsPath = iSP.AddonPath .. "sounds\\"

-- Game version info
iSP.GameVersion, iSP.GameBuild, iSP.GameBuildDate, iSP.GameTocVersion = GetBuildInfo()
iSP.GameVersionName = ""

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Constants                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iSP.CONSTANTS = {
    -- Sound Limits
    MAX_SOUND_NAME_LENGTH = 100,
    MIN_SOUND_NAME_LENGTH = 3,

    -- Trigger Limits
    MAX_TRIGGERS = 50,

    -- Volume
    MIN_VOLUME = 0.0,
    MAX_VOLUME = 1.0,
    DEFAULT_VOLUME = 1.0,
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Runtime State                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iSP.State = {
    InCombat = false,
    CurrentlyPlaying = nil,
    LastPlayedTime = 0,

    -- PvP Kill Tracking
    PvP = {
        Kills = {},              -- Track kill timestamps for multi-kill detection
        KillStreak = 0,          -- Current killing spree count
        LastKillTime = 0,        -- Timestamp of last kill
        MultiKillWindow = 10,    -- Seconds window for multi-kill (Double, Triple, etc.)
        KillStreakWindow = 60,   -- Seconds window for killing spree to break
    },
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Default Settings                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iSP.SettingsDefault = {
    -- General
    Enabled = true,
    ShowNotifications = false,
    DebugMode = false,

    -- Minimap
    MinimapButton = {
        hide = false,
        minimapPos = -30
    },

    -- Sound
    SoundFiles = {},

    -- Triggers
    Triggers = {
        -- Player Events
        PLAYER_LOGIN = {
            enabled = false,
            sound = "",
            duration = 0,      -- 0 = play full sound, otherwise seconds
            startOffset = 0,   -- Start playback from X seconds
            loop = false,      -- Loop the sound
            loopCount = 1,     -- How many times to loop (if loop = true)
            fadeIn = false,    -- Fade in effect
            fadeOut = false,   -- Fade out effect
        },
        PLAYER_LEVEL_UP = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_DEAD = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_ALIVE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_UNGHOST = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Combat Events
        PLAYER_REGEN_DISABLED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_REGEN_ENABLED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_TARGET_CHANGED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Achievement & Quest Events
        ACHIEVEMENT_EARNED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        QUEST_COMPLETE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        QUEST_ACCEPTED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        QUEST_TURNED_IN = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Loot & Items
        LOOT_READY = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        LOOT_OPENED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        LOOT_CLOSED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Group & Social
        GROUP_JOINED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        GROUP_LEFT = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        GROUP_ROSTER_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        READY_CHECK = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        READY_CHECK_CONFIRM = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Dungeon & Raid
        PLAYER_ENTERING_WORLD = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        ZONE_CHANGED_NEW_AREA = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        ENCOUNTER_START = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        ENCOUNTER_END = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        BOSS_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- PvP Events
        PVP_HONORABLE_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_DOUBLE_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_TRIPLE_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_MULTI_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_KILLING_SPREE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_DOMINATING = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_UNSTOPPABLE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_GODLIKE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
    },
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Saved Variables                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
if not iSPSettings then
    iSPSettings = {}
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Game Version Detection                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local gameTocNumber = tonumber(iSP.GameTocVersion) or 0
if gameTocNumber >= 120000 then
    iSP.GameVersionName = "Retail WoW"
elseif gameTocNumber > 50000 and gameTocNumber < 59999 then
    iSP.GameVersionName = "Classic MoP"
elseif gameTocNumber > 40000 and gameTocNumber < 49999 then
    iSP.GameVersionName = "Classic Cata"
elseif gameTocNumber > 30000 and gameTocNumber < 39999 then
    iSP.GameVersionName = "Classic WotLK"
elseif gameTocNumber > 20000 and gameTocNumber < 29999 then
    iSP.GameVersionName = "Classic TBC"
elseif gameTocNumber > 10000 and gameTocNumber < 19999 then
    iSP.GameVersionName = "Classic Era"
else
    iSP.GameVersionName = "Unknown Version"
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Initialization Functions                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iSP:InitializeSettings()
    if not iSPSettings then
        iSPSettings = {}
    end

    -- Fill in missing settings with defaults
    for key, value in pairs(iSP.SettingsDefault) do
        if iSPSettings[key] == nil then
            if type(value) == "table" then
                iSPSettings[key] = CopyTable(value)
            else
                iSPSettings[key] = value
            end
        end
    end

    -- Ensure nested tables exist
    if not iSPSettings.MinimapButton then
        iSPSettings.MinimapButton = CopyTable(iSP.SettingsDefault.MinimapButton)
    end

    if not iSPSettings.Triggers then
        iSPSettings.Triggers = CopyTable(iSP.SettingsDefault.Triggers)
    end

    if not iSPSettings.SoundFiles then
        iSPSettings.SoundFiles = {}
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Debug Function                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- Debug message function with levels
-- Level 1 = ERROR (red)
-- Level 2 = WARNING (yellow)
-- Level 3 = INFO (white) - default
local function Debug(msg, level)
    if iSPSettings.DebugMode then
        level = level or 3 -- Default to INFO

        if level == 1 then
            print(L["DebugError"] .. msg)
        elseif level == 2 then
            print(L["DebugWarning"] .. msg)
        else
            print(L["DebugInfo"] .. msg)
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Sound Functions                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Active sound timers for managing playback
iSP.ActiveSounds = {}

-- Stop currently playing sound
function iSP:StopSound(soundID)
    if iSP.ActiveSounds[soundID] then
        -- Cancel all timers for this sound
        for _, timer in ipairs(iSP.ActiveSounds[soundID].timers or {}) do
            if timer then
                timer:Cancel()
            end
        end
        iSP.ActiveSounds[soundID] = nil

        if iSPSettings.DebugMode then
            print(L["PrintPrefix"] .. Colors.Red .. "Stopped sound: " .. soundID)
        end
    end
end

-- Stop all currently playing sounds
function iSP:StopAllSounds()
    for soundID, _ in pairs(iSP.ActiveSounds) do
        self:StopSound(soundID)
    end
end

-- Play a sound file by name with advanced options
-- options = {
--   duration = 0,      -- How long to play (0 = full sound)
--   startOffset = 0,   -- Start from X seconds into the file
--   loop = false,      -- Loop the sound
--   loopCount = 1,     -- How many times to loop
--   fadeIn = false,    -- Fade in (not supported by WoW API, placeholder)
--   fadeOut = false,   -- Fade out (not supported by WoW API, placeholder)
-- }
function iSP:PlaySound(fileName, options)
    if not fileName or fileName == "" then
        if iSPSettings.DebugMode then
            print(L["NoSoundSpecified"])
        end
        return false
    end

    if not iSPSettings.Enabled then
        if iSPSettings.DebugMode then
            print(L["AddonDisabled"])
        end
        return false
    end

    -- Default options
    options = options or {}
    local duration = options.duration or 0
    local startOffset = options.startOffset or 0
    local loop = options.loop or false
    local loopCount = options.loopCount or 1
    local fadeIn = options.fadeIn or false
    local fadeOut = options.fadeOut or false

    local soundPath = iSP.SoundsPath .. fileName
    local soundID = fileName .. "_" .. time()

    if iSPSettings.DebugMode then
        print(string.format(L["SoundPlaying"], soundPath))
        if duration > 0 then
            print(Colors.Gray .. "  Duration: " .. duration .. "s")
        end
        if startOffset > 0 then
            print(Colors.Gray .. "  Start Offset: " .. startOffset .. "s")
        end
        if loop then
            print(Colors.Gray .. "  Looping: " .. loopCount .. " times")
        end
    end

    -- NOTE: WoW's PlaySoundFile API doesn't support:
    -- - Start offset (can't seek into audio file)
    -- - Duration control (can't stop sound once started)
    -- - Fade in/out effects
    --
    -- We can simulate some of these with timers and workarounds:

    local function PlayWithOptions()
        -- Try to play the sound
        local success, errorMsg = pcall(PlaySoundFile, soundPath, "Master")

        if not success and iSPSettings.DebugMode then
            print(string.format(L["SoundFailed"], soundPath))
            return false
        elseif success and iSPSettings.ShowNotifications then
            print(string.format(L["SoundPlaying"], fileName))
        end

        -- Track active sound
        iSP.ActiveSounds[soundID] = {
            fileName = fileName,
            startTime = time(),
            timers = {},
        }

        -- If duration is set, we need to play another sound to "stop" it
        -- (WoW API limitation: can't actually stop a sound once started)
        if duration > 0 then
            local stopTimer = C_Timer.NewTimer(duration, function()
                -- Play silence or remove from active list
                self:StopSound(soundID)
            end)
            table.insert(iSP.ActiveSounds[soundID].timers, stopTimer)
        end

        -- Handle looping
        if loop and loopCount > 1 then
            local currentLoop = 1
            local loopTimer

            local function LoopSound()
                if currentLoop >= loopCount then
                    self:StopSound(soundID)
                    return
                end

                -- Calculate when to play next loop
                -- Since we can't detect sound length, use duration or a default
                local soundLength = duration > 0 and duration or 3 -- Default 3 seconds if no duration set

                currentLoop = currentLoop + 1
                PlaySoundFile(soundPath, "Master")

                if currentLoop < loopCount then
                    loopTimer = C_Timer.NewTimer(soundLength, LoopSound)
                    table.insert(iSP.ActiveSounds[soundID].timers, loopTimer)
                end
            end

            local soundLength = duration > 0 and duration or 3
            loopTimer = C_Timer.NewTimer(soundLength, LoopSound)
            table.insert(iSP.ActiveSounds[soundID].timers, loopTimer)
        end

        -- Update state
        iSP.State.CurrentlyPlaying = fileName
        iSP.State.LastPlayedTime = time()

        return success
    end

    -- If startOffset is set, delay the playback
    -- NOTE: This doesn't actually seek into the file, just delays when it starts
    if startOffset > 0 then
        if iSPSettings.DebugMode then
            print(L["DebugInfo"] .. "Start offset delays playback but doesn't seek into file")
        end
        C_Timer.After(startOffset, PlayWithOptions)
        return true
    else
        return PlayWithOptions()
    end
end

-- Test sound playback
function iSP:TestSound(fileName)
    print(string.format(L["SoundTesting"], fileName))
    return self:PlaySound(fileName)
end

-- Play sound for a trigger
function iSP:PlayTriggerSound(triggerID)
    if not iSPSettings.Triggers then return false end
    if not iSPSettings.Triggers[triggerID] then return false end

    local trigger = iSPSettings.Triggers[triggerID]
    if not trigger.enabled then
        if iSPSettings.DebugMode then
            print(string.format(L["TriggerDisabled"], triggerID))
        end
        return false
    end

    if not trigger.sound or trigger.sound == "" then
        if iSPSettings.DebugMode then
            print(string.format(L["NoSoundSpecified"]))
        end
        return false
    end

    if iSPSettings.DebugMode then
        print(string.format(L["TriggerActivated"], triggerID))
    end

    -- Build options from trigger settings
    local options = {
        duration = trigger.duration or 0,
        startOffset = trigger.startOffset or 0,
        loop = trigger.loop or false,
        loopCount = trigger.loopCount or 1,
        fadeIn = trigger.fadeIn or false,
        fadeOut = trigger.fadeOut or false,
    }

    return self:PlaySound(trigger.sound, options)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               PvP Kill Tracking                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Reset kill streak (after timeout or death)
function iSP:ResetKillStreak()
    self.State.PvP.KillStreak = 0
    self.State.PvP.Kills = {}
    if iSPSettings.DebugMode then
        print(L["DebugInfo"] .. "Kill streak reset")
    end
end

-- Process honorable kill
function iSP:OnHonorableKill()
    local now = time()
    local pvpState = self.State.PvP

    -- Check if kill streak should be reset (timeout)
    if (now - pvpState.LastKillTime) > pvpState.KillStreakWindow then
        self:ResetKillStreak()
    end

    -- Update kill tracking
    pvpState.LastKillTime = now
    pvpState.KillStreak = pvpState.KillStreak + 1
    table.insert(pvpState.Kills, now)

    if iSPSettings.DebugMode then
        print(L["DebugInfo"] .. "Honorable Kill! Streak: " .. pvpState.KillStreak)
    end

    -- Play honorable kill sound
    self:PlayTriggerSound("PVP_HONORABLE_KILL")

    -- Check for multi-kill (within 10 seconds)
    local recentKills = 0
    for i = #pvpState.Kills, 1, -1 do
        if (now - pvpState.Kills[i]) <= pvpState.MultiKillWindow then
            recentKills = recentKills + 1
        else
            break
        end
    end

    -- Play multi-kill sounds
    if recentKills >= 7 then
        self:PlayTriggerSound("PVP_GODLIKE")
    elseif recentKills >= 6 then
        self:PlayTriggerSound("PVP_UNSTOPPABLE")
    elseif recentKills >= 5 then
        self:PlayTriggerSound("PVP_DOMINATING")
    elseif recentKills >= 4 then
        self:PlayTriggerSound("PVP_MULTI_KILL")
    elseif recentKills >= 3 then
        self:PlayTriggerSound("PVP_TRIPLE_KILL")
    elseif recentKills == 2 then
        self:PlayTriggerSound("PVP_DOUBLE_KILL")
    end

    -- Play killing spree sounds (based on total streak)
    if pvpState.KillStreak == 5 then
        self:PlayTriggerSound("PVP_KILLING_SPREE")
    elseif pvpState.KillStreak == 10 then
        self:PlayTriggerSound("PVP_DOMINATING")
    elseif pvpState.KillStreak == 15 then
        self:PlayTriggerSound("PVP_UNSTOPPABLE")
    elseif pvpState.KillStreak >= 20 then
        self:PlayTriggerSound("PVP_GODLIKE")
    end

    -- Clean up old kills (keep only recent ones)
    while #pvpState.Kills > 0 and (now - pvpState.Kills[1]) > pvpState.MultiKillWindow do
        table.remove(pvpState.Kills, 1)
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Event Handlers                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Event frame
local eventFrame = CreateFrame("Frame")

-- Event handler
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            iSP:OnAddonLoaded()
        end
    elseif event == "PLAYER_LOGIN" then
        iSP:OnPlayerLogin()
    elseif event == "PLAYER_REGEN_DISABLED" then
        iSP.State.InCombat = true
        -- Auto-hide settings and setup guide on combat enter
        if iSP.SettingsFrame and iSP.SettingsFrame:IsShown() then
            iSP.SettingsFrame:Hide()
        end
        local setupGuide = _G["iSPSetupGuide"]
        if setupGuide and setupGuide:IsShown() then
            setupGuide:Hide()
        end
        iSP:PlayTriggerSound("PLAYER_REGEN_DISABLED")
    elseif event == "PLAYER_REGEN_ENABLED" then
        iSP.State.InCombat = false
        iSP:PlayTriggerSound("PLAYER_REGEN_ENABLED")
    elseif event == "PLAYER_LEVEL_UP" then
        iSP:PlayTriggerSound("PLAYER_LEVEL_UP")
    elseif event == "PLAYER_DEAD" then
        -- Reset kill streak on death
        iSP:ResetKillStreak()
        iSP:PlayTriggerSound("PLAYER_DEAD")
    elseif event == "PLAYER_ALIVE" then
        iSP:PlayTriggerSound("PLAYER_ALIVE")
    elseif event == "PLAYER_UNGHOST" then
        iSP:PlayTriggerSound("PLAYER_UNGHOST")
    elseif event == "PLAYER_TARGET_CHANGED" then
        iSP:PlayTriggerSound("PLAYER_TARGET_CHANGED")
    elseif event == "ACHIEVEMENT_EARNED" then
        iSP:PlayTriggerSound("ACHIEVEMENT_EARNED")
    elseif event == "QUEST_COMPLETE" then
        iSP:PlayTriggerSound("QUEST_COMPLETE")
    elseif event == "QUEST_ACCEPTED" then
        iSP:PlayTriggerSound("QUEST_ACCEPTED")
    elseif event == "QUEST_TURNED_IN" then
        iSP:PlayTriggerSound("QUEST_TURNED_IN")
    elseif event == "LOOT_READY" then
        iSP:PlayTriggerSound("LOOT_READY")
    elseif event == "LOOT_OPENED" then
        iSP:PlayTriggerSound("LOOT_OPENED")
    elseif event == "LOOT_CLOSED" then
        iSP:PlayTriggerSound("LOOT_CLOSED")
    elseif event == "GROUP_JOINED" then
        iSP:PlayTriggerSound("GROUP_JOINED")
    elseif event == "GROUP_LEFT" then
        iSP:PlayTriggerSound("GROUP_LEFT")
    elseif event == "GROUP_ROSTER_UPDATE" then
        iSP:PlayTriggerSound("GROUP_ROSTER_UPDATE")
    elseif event == "READY_CHECK" then
        iSP:PlayTriggerSound("READY_CHECK")
    elseif event == "READY_CHECK_CONFIRM" then
        iSP:PlayTriggerSound("READY_CHECK_CONFIRM")
    elseif event == "PLAYER_ENTERING_WORLD" then
        iSP:PlayTriggerSound("PLAYER_ENTERING_WORLD")
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        iSP:PlayTriggerSound("ZONE_CHANGED_NEW_AREA")
    elseif event == "ENCOUNTER_START" then
        iSP:PlayTriggerSound("ENCOUNTER_START")
    elseif event == "ENCOUNTER_END" then
        iSP:PlayTriggerSound("ENCOUNTER_END")
    elseif event == "BOSS_KILL" then
        iSP:PlayTriggerSound("BOSS_KILL")
    end
end

-- PvP kill tracking — version-split for Classic vs Retail
local _, _, _, tocVersion = GetBuildInfo()

if tocVersion and tocVersion < 100000 then
    -- ── Classic: use COMBAT_LOG_EVENT_UNFILTERED for precise kill detection ──
    local pvpKillFrame = CreateFrame("Frame")
    pvpKillFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    pvpKillFrame:SetScript("OnEvent", function()
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
              destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

        if subevent == "PARTY_KILL" then
            local playerGUID = UnitGUID("player")
            if sourceGUID == playerGUID and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
                if bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
                    iSP:OnHonorableKill()
                end
            end
        end
    end)
else
    -- ── Retail 12.0+: use PARTY_KILL event + achievement criteria workaround ──
    -- Blizzard blocks COMBAT_LOG_EVENT_UNFILTERED for addons in retail.
    -- PARTY_KILL event still fires but hides attacker GUID as <secret> in instances.
    -- Workaround: compare total killing blow count (achievement criteria 1487) before/after.
    -- Credit: ErnestasBaltinas/hksounds for the technique.

    local pvpKillFrame = CreateFrame("Frame")
    local baselineKillCount = 0

    -- Get player's total killing blows from achievement statistics
    local function GetTotalKillCount()
        local _, _, _, _, _, _, _, _, killCount = GetAchievementCriteriaInfoByID(1487, 0)
        return killCount or 0
    end

    -- Check if a GUID is hidden (secret) by Blizzard
    local function IsGUIDSecret(guid)
        return issecretvalue and issecretvalue(guid)
    end

    -- Check if the target is a player (not NPC)
    local function IsTargetPlayer(guid)
        if not guid then return false end
        if IsGUIDSecret(guid) then
            -- In instances, target GUID might also be secret — assume player in PvP context
            return true
        end
        return guid:find("^Player%-") ~= nil
    end

    -- Determine if WE got the killing blow
    local function WasKilledByPlayer(attackerGUID)
        if IsGUIDSecret(attackerGUID) then
            -- GUID is hidden (instanced PvP) — check if our kill count increased
            local currentKills = GetTotalKillCount()
            if currentKills > baselineKillCount then
                baselineKillCount = currentKills
                return true
            end
            return false
        end
        -- Open world: direct GUID comparison
        return attackerGUID == UnitGUID("player")
    end

    -- Initialize baseline on login
    pvpKillFrame:RegisterEvent("PLAYER_LOGIN")
    pvpKillFrame:RegisterEvent("PARTY_KILL")

    pvpKillFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            baselineKillCount = GetTotalKillCount()
            if iSPSettings and iSPSettings.DebugMode then
                print(L["DebugInfo"] .. "Retail PvP: Baseline kill count = " .. baselineKillCount)
            end
        elseif event == "PARTY_KILL" then
            local attackerGUID, targetGUID = ...
            if WasKilledByPlayer(attackerGUID) and IsTargetPlayer(targetGUID) then
                iSP:OnHonorableKill()
            end
        end
    end)
end

eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Register trigger events
function iSP:RegisterTriggerEvents()
    -- Player Events
    if iSPSettings.Triggers.PLAYER_LEVEL_UP and iSPSettings.Triggers.PLAYER_LEVEL_UP.enabled then
        eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    end
    if iSPSettings.Triggers.PLAYER_DEAD and iSPSettings.Triggers.PLAYER_DEAD.enabled then
        eventFrame:RegisterEvent("PLAYER_DEAD")
    end
    if iSPSettings.Triggers.PLAYER_ALIVE and iSPSettings.Triggers.PLAYER_ALIVE.enabled then
        eventFrame:RegisterEvent("PLAYER_ALIVE")
    end
    if iSPSettings.Triggers.PLAYER_UNGHOST and iSPSettings.Triggers.PLAYER_UNGHOST.enabled then
        eventFrame:RegisterEvent("PLAYER_UNGHOST")
    end

    -- Combat Events
    if iSPSettings.Triggers.PLAYER_TARGET_CHANGED and iSPSettings.Triggers.PLAYER_TARGET_CHANGED.enabled then
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    end

    -- Achievements & Quests
    if iSPSettings.Triggers.ACHIEVEMENT_EARNED and iSPSettings.Triggers.ACHIEVEMENT_EARNED.enabled then
        eventFrame:RegisterEvent("ACHIEVEMENT_EARNED")
    end
    if iSPSettings.Triggers.QUEST_COMPLETE and iSPSettings.Triggers.QUEST_COMPLETE.enabled then
        eventFrame:RegisterEvent("QUEST_COMPLETE")
    end
    if iSPSettings.Triggers.QUEST_ACCEPTED and iSPSettings.Triggers.QUEST_ACCEPTED.enabled then
        eventFrame:RegisterEvent("QUEST_ACCEPTED")
    end
    if iSPSettings.Triggers.QUEST_TURNED_IN and iSPSettings.Triggers.QUEST_TURNED_IN.enabled then
        eventFrame:RegisterEvent("QUEST_TURNED_IN")
    end

    -- Loot & Items
    if iSPSettings.Triggers.LOOT_READY and iSPSettings.Triggers.LOOT_READY.enabled then
        eventFrame:RegisterEvent("LOOT_READY")
    end
    if iSPSettings.Triggers.LOOT_OPENED and iSPSettings.Triggers.LOOT_OPENED.enabled then
        eventFrame:RegisterEvent("LOOT_OPENED")
    end
    if iSPSettings.Triggers.LOOT_CLOSED and iSPSettings.Triggers.LOOT_CLOSED.enabled then
        eventFrame:RegisterEvent("LOOT_CLOSED")
    end

    -- Group & Social
    if iSPSettings.Triggers.GROUP_JOINED and iSPSettings.Triggers.GROUP_JOINED.enabled then
        eventFrame:RegisterEvent("GROUP_JOINED")
    end
    if iSPSettings.Triggers.GROUP_LEFT and iSPSettings.Triggers.GROUP_LEFT.enabled then
        eventFrame:RegisterEvent("GROUP_LEFT")
    end
    if iSPSettings.Triggers.GROUP_ROSTER_UPDATE and iSPSettings.Triggers.GROUP_ROSTER_UPDATE.enabled then
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    end
    if iSPSettings.Triggers.READY_CHECK and iSPSettings.Triggers.READY_CHECK.enabled then
        eventFrame:RegisterEvent("READY_CHECK")
    end
    if iSPSettings.Triggers.READY_CHECK_CONFIRM and iSPSettings.Triggers.READY_CHECK_CONFIRM.enabled then
        eventFrame:RegisterEvent("READY_CHECK_CONFIRM")
    end

    -- Dungeon & Raid
    if iSPSettings.Triggers.PLAYER_ENTERING_WORLD and iSPSettings.Triggers.PLAYER_ENTERING_WORLD.enabled then
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
    if iSPSettings.Triggers.ZONE_CHANGED_NEW_AREA and iSPSettings.Triggers.ZONE_CHANGED_NEW_AREA.enabled then
        eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    end
    if iSPSettings.Triggers.ENCOUNTER_START and iSPSettings.Triggers.ENCOUNTER_START.enabled then
        eventFrame:RegisterEvent("ENCOUNTER_START")
    end
    if iSPSettings.Triggers.ENCOUNTER_END and iSPSettings.Triggers.ENCOUNTER_END.enabled then
        eventFrame:RegisterEvent("ENCOUNTER_END")
    end
    if iSPSettings.Triggers.BOSS_KILL and iSPSettings.Triggers.BOSS_KILL.enabled then
        eventFrame:RegisterEvent("BOSS_KILL")
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Addon Lifecycle Events                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iSP:OnAddonLoaded()
    -- Initialize settings
    self:InitializeSettings()

    -- Register trigger events
    self:RegisterTriggerEvents()

    -- Determine game version name based on TOC
    local gameName = "Unknown"
    local tocVersion = iSP.GameTocVersion or 0

    if tocVersion >= 120000 then
        gameName = "Retail WoW"
    elseif tocVersion >= 50000 and tocVersion < 60000 then
        gameName = "Classic MoP"
    elseif tocVersion >= 40000 and tocVersion < 50000 then
        gameName = "Classic Cata"
    elseif tocVersion >= 30000 and tocVersion < 40000 then
        gameName = "Classic Wrath"
    elseif tocVersion >= 20000 and tocVersion < 30000 then
        gameName = "Classic TBC"
    elseif tocVersion >= 11500 and tocVersion < 20000 then
        gameName = "Classic Era"
    end

    -- Delayed loaded message (like iNIF/iWR)
    C_Timer.After(2, function()
        print(L["PrintPrefix"] .. Colors.iSP .. "iSoundPlayer " .. Colors.Reset .. gameName .. Colors.Green .. " v" .. iSP.Version .. Colors.Reset .. " loaded!")
    end)
end

function iSP:OnPlayerLogin()
    -- Create options panel
    if self.CreateOptionsPanel then
        self:CreateOptionsPanel()
    end

    -- Create minimap button
    self:CreateMinimapButton()

    -- Check if we should show the setup guide
    self:CheckShowSetupGuideOnStartup()

    -- Play login sound
    self:PlayTriggerSound("PLAYER_LOGIN")
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Minimap Button                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iSP:CreateMinimapButton()
    if not LDBIcon then return end

    -- Create LibDataBroker data object
    local iSPLDB = LDBroker:NewDataObject("iSoundPlayer", {
        type = "data source",
        text = "iSoundPlayer",
        icon = iSP.AddonPath .. "Images\\Icons\\Logo_iSP.blp",
        OnClick = function(self, button)
            if button == "LeftButton" then
                -- Show setup guide if available, otherwise show settings
                if iSP.ShowSetupGuide then
                    iSP:ShowSetupGuide()
                else
                    iSP:SettingsToggle()
                end
            elseif button == "RightButton" then
                -- Right-click always opens settings
                iSP:SettingsToggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:SetText(Colors.iSP .. "iSoundPlayer" .. Colors.Green .. " v" .. iSP.Version, 1, 1, 1)
            tooltip:AddLine(" ", 1, 1, 1)
            tooltip:AddLine(L["MinimapTooltipLeftClick"], 1, 1, 1)
            tooltip:AddLine(L["MinimapTooltipRightClick"], 1, 1, 1)
            tooltip:AddLine(" ", 1, 1, 1)
            tooltip:AddLine(L["MinimapTooltipStatus"] .. (iSPSettings.Enabled and L["StatusEnabled"] or L["StatusDisabled"]), 1, 1, 1)

            -- Show registered sounds count
            local soundCount = iSPSettings.SoundFiles and #iSPSettings.SoundFiles or 0
            tooltip:AddLine(string.format(L["MinimapTooltipSounds"], soundCount), 1, 1, 1)

            -- Show enabled triggers count
            local enabledTriggers = 0
            if iSPSettings.Triggers then
                for _, trigger in pairs(iSPSettings.Triggers) do
                    if trigger.enabled then
                        enabledTriggers = enabledTriggers + 1
                    end
                end
            end
            tooltip:AddLine(string.format(L["MinimapTooltipTriggers"], enabledTriggers), 1, 1, 1)
            tooltip:Show()
        end,
    })

    -- Register with LibDBIcon
    LDBIcon:Register("iSoundPlayer", iSPLDB, iSPSettings.MinimapButton)

    -- Show/hide based on settings
    if iSPSettings.MinimapButton.hide then
        LDBIcon:Hide("iSoundPlayer")
    else
        LDBIcon:Show("iSoundPlayer")
    end
end

-- Toggle minimap button visibility
function iSP:ToggleMinimapButton()
    if not LDBIcon then return end

    iSPSettings.MinimapButton.hide = not iSPSettings.MinimapButton.hide

    if iSPSettings.MinimapButton.hide then
        LDBIcon:Hide("iSoundPlayer")
        print(L["PrintPrefix"] .. L["MinimapHidden"])
    else
        LDBIcon:Show("iSoundPlayer")
        print(L["PrintPrefix"] .. L["MinimapShown"])
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Helper Functions                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Create styled frame (used by options panel)
function iSP:CreateiSPStyleFrame(parent, width, height, point, name)
    local frame = CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    frame:SetSize(width, height)
    if point then
        frame:SetPoint(unpack(point))
    end
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    -- Add to UISpecialFrames for ESC functionality
    if name then
        if not tContains(UISpecialFrames, name) then
            tinsert(UISpecialFrames, name)
        end
    end
    return frame
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Slash Commands                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
SLASH_ISOUNDPLAYER1 = "/isp"
SLASH_ISOUNDPLAYER2 = "/isoundplayer"

SlashCmdList["ISOUNDPLAYER"] = function(msg)
    local cmd = string.lower(msg or "")

    if cmd == "settings" or cmd == "config" or cmd == "options" then
        iSP:SettingsToggle()
    elseif cmd == "enable" then
        iSPSettings.Enabled = true
        print(L["AddonEnabled"])
    elseif cmd == "disable" then
        iSPSettings.Enabled = false
        print(L["AddonDisabled"])
    else
        print(string.format(L["SlashHelp"], iSP.Version))
    end
end
