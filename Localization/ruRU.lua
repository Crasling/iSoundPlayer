local addonName, addon = ...

-- Only load Russian localization on Russian clients
if GetLocale() ~= "ruRU" then return end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local Colors = {
    -- Addon Brand Color
    iSP = "|cffff9716",

    -- Standard Colors
    White = "|cFFFFFFFF",
    Black = "|cFF000000",
    Red = "|cFFFF0000",
    Green = "|cFF00FF00",
    Blue = "|cFF0000FF",
    Yellow = "|cFFFFFF00",
    Cyan = "|cFF00FFFF",
    Magenta = "|cFFFF00FF",
    Orange = "|cFFFFA500",
    Gray = "|cFF808080",
    DarkGray = "|cFF404040",

    -- WoW Class Colors
    Classes = {
        WARRIOR = "|cFFC79C6E",
        PALADIN = "|cFFF58CBA",
        HUNTER = "|cFFABD473",
        ROGUE = "|cFFFFF569",
        PRIEST = "|cFFFFFFFF",
        SHAMAN = "|cFF0070DE",
        MAGE = "|cFF40C7EB",
        WARLOCK = "|cFF8788EE",
        DRUID = "|cFFFF7D0A",
        DEATHKNIGHT = "|cFFC41F3B",
        MONK = "|cFF00FF98",
        DEMONHUNTER = "|cFFA330C9",
        EVOKER = "|cFF33937F"
    },

    -- Reset Color
    Reset = "|r"
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Localization Table Setup                             │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local L = {}
addon.L = L
addon.Colors = Colors

-- Fallback: Return key if translation missing
setmetatable(L, {__index = function(t, k)
    return k
end})

-- Helper function for consistent message formatting
local function Msg(message)
    return Colors.iSP .. "[iSP]: " .. message
end
-- Translator ZamestoTV
-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Debug Messages                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["PrintPrefix"]   = Colors.iSP .. "[iSP]: "
L["DebugPrefix"]   = Colors.iSP .. "[iSP]: "
L["DebugInfo"]     = Colors.iSP .. "[iSP]: " .. Colors.White .. "ИНФО: " .. Colors.Reset .. Colors.iSP
L["DebugWarning"]  = Colors.iSP .. "[iSP]: " .. Colors.Yellow .. "ВНИМАНИЕ: " .. Colors.Reset .. Colors.iSP
L["DebugError"]    = Colors.iSP .. "[iSP]: " .. Colors.Red .. "ОШИБКА: " .. Colors.Reset .. Colors.iSP

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 General Messages                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["AddonLoaded"]   = Msg(Colors.iSP .. "iSoundPlayer" .. Colors.Green .. " v%s" .. Colors.Reset .. " загружен!")
L["AddonEnabled"]  = Msg("Аддон включён")
L["AddonDisabled"] = Msg("Аддон отключён")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Sound Messages                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SoundPlaying"]      = Msg("Воспроизведение звука: " .. Colors.Yellow .. "%s" .. Colors.Reset)
L["SoundTesting"]      = Msg("Тест звука: " .. Colors.Yellow .. "%s" .. Colors.Reset)
L["SoundFailed"]       = Msg(Colors.Red .. "Не удалось воспроизвести звук: %s" .. Colors.Reset)
L["SoundAdded"]        = Msg(Colors.Green .. "Звук добавлен: %s" .. Colors.Reset)
L["SoundAlreadyExists"] = Msg(Colors.Yellow .. "Звук уже в списке!" .. Colors.Reset)
L["SoundRemoved"]      = Msg(Colors.Red .. "Звук удалён: %s" .. Colors.Reset)
L["NoSoundSpecified"]  = Msg(Colors.Red .. "Не указан файл звука!" .. Colors.Reset)
L["EnterFilenameFirst"] = Msg(Colors.Red .. "Сначала введите имя файла!" .. Colors.Reset)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Trigger Messages                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["TriggerActivated"] = Msg("Триггер активирован: " .. Colors.Yellow .. "%s" .. Colors.Reset)
L["TriggerDisabled"]  = Msg("Триггер " .. Colors.Yellow .. "%s" .. Colors.Reset .. " отключён")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Options Panel - Tabs                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["Tab1General"] = "Общие"
L["Tab2Sounds"]  = "Звуки"
L["Tab3Triggers"] = "Триггеры"
L["Tab4About"]   = "О проекте"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Options Panel - General Tab                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["GeneralSettings"]   = Colors.iSP .. "Общие настройки"
L["EnableAddon"]       = "Включить iSoundPlayer"
L["DescEnableAddon"]   = "Включить или отключить весь аддон"
L["ShowNotifications"] = "Показывать уведомления"
L["DescShowNotifications"] = "Выводить сообщения в чат при воспроизведении звуков"
L["MinimapSettings"]   = Colors.iSP .. "Кнопка у миникарты"
L["ShowMinimapButton"] = "Показывать кнопку у миникарты"
L["DescShowMinimapButton"] = "Показывать или скрывать кнопку у миникарты"
L["ResetSettings"]     = Colors.iSP .. "Сброс настроек"
L["ResetToDefaults"]   = "Сбросить на стандартные"
L["ResetConfirm"]      = "Сбросить все настройки на значения по умолчанию?"
L["SettingsResetSuccess"] = Msg(Colors.Green .. "Настройки сброшены на стандартные!" .. Colors.Reset)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Options Panel - Sounds Tab                          │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SoundFiles"]      = Colors.iSP .. "Файлы звуков"
L["SoundFilesInfo"]  = Colors.Gray .. "Поместите ваши MP3 или OGG-файлы в папку 'sounds' внутри директории аддона.\n\nПуть: " .. Colors.White .. "Interface\\AddOns\\iSoundPlayer\\sounds\\\n\n" .. Colors.Red .. "ВАЖНО: " .. Colors.Gray .. "После добавления новых файлов необходимо выполнить /reload!" .. Colors.Reset
L["AddSoundFile"]    = Colors.iSP .. "Добавить звук"
L["FilenameLabel"]   = "Имя файла (например, mysound.mp3):"
L["AddSound"]        = "Добавить звук"
L["TestSound"]       = "Протестировать"
L["RegisteredSounds"] = Colors.iSP .. "Зарегистрированные звуки"
L["NoSoundsRegistered"] = Colors.Gray .. "Пока нет зарегистрированных звуков." .. Colors.Reset
L["RemoveSound"]     = "Удалить"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Options Panel - Triggers Tab                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["Triggers"]        = Colors.iSP .. "Триггеры"
L["TriggersInfo"]    = Colors.Gray .. "Настройте, когда должны воспроизводиться звуки. Свяжите игровые события со своими звуками. Клик по заголовку категории сворачивает/разворачивает её." .. Colors.Reset
L["SearchTriggers"]  = Colors.Gray .. "Поиск триггеров..." .. Colors.Reset
L["SearchSounds"]    = Colors.Gray .. "Поиск звуков..." .. Colors.Reset
L["AvailableTriggers"] = Colors.iSP .. "Доступные триггеры"
L["EnableTrigger"]   = "Включить"
L["SelectSound"]     = "Выберите звук..."
L["NoSound"]         = "Без звука"

-- Trigger Names
L["TriggerPlayerLogin"]      = "Вход в игру"
L["TriggerPlayerLevelUp"]    = "Повышение уровня"
L["TriggerPlayerDead"]       = "Смерть персонажа"
L["TriggerEnterCombat"]      = "Вход в бой"
L["TriggerExitCombat"]       = "Выход из боя"
L["TriggerAchievement"]      = "Получение достижения"
L["TriggerQuestComplete"]    = "Завершение задания"

-- PvP Trigger Names
L["TriggerPvPHonorableKill"] = "Почётное убийство"
L["TriggerPvPDoubleKill"]    = "Двойное убийство"
L["TriggerPvPTripleKill"]    = "Тройное убийство"
L["TriggerPvPMultiKill"]     = "Мульти-убийство"
L["TriggerPvPKillingSpree"]  = "Серия убийств"
L["TriggerPvPDominating"]    = "Доминирование"
L["TriggerPvPUnstoppable"]   = "Неудержимый"
L["TriggerPvPGodlike"]       = "Богоподобный"

-- Trigger Descriptions
L["DescTriggerPlayerLogin"]     = "При входе в игру"
L["DescTriggerPlayerLevelUp"]   = "При повышении уровня"
L["DescTriggerPlayerDead"]      = "При смерти персонажа"
L["DescTriggerEnterCombat"]     = "При входе в бой"
L["DescTriggerExitCombat"]      = "При выходе из боя"
L["DescTriggerAchievement"]     = "При получении достижения"
L["DescTriggerQuestComplete"]   = "При завершении задания"

-- PvP Trigger Descriptions
L["DescTriggerPvPHonorableKill"] = "При почётном убийстве"
L["DescTriggerPvPDoubleKill"]    = "При убийстве 2 игроков за 10 секунд"
L["DescTriggerPvPTripleKill"]    = "При убийстве 3 игроков за 10 секунд"
L["DescTriggerPvPMultiKill"]     = "При убийстве 4+ игроков за 10 секунд"
L["DescTriggerPvPKillingSpree"]  = "При 5 убийствах без смерти"
L["DescTriggerPvPDominating"]    = "При 10 убийствах без смерти"
L["DescTriggerPvPUnstoppable"]   = "При 15 убийствах без смерти"
L["DescTriggerPvPGodlike"]       = "При 20+ убийствах без смерти"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Options Panel - About Tab                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["About"]           = Colors.iSP .. "О проекте"
L["CreatedBy"]       = "Автор: "
L["AboutInfo"]       = Colors.iSP .. "iSoundPlayer " .. Colors.Reset .. "— это аддон, позволяющий воспроизводить собственные MP3-файлы при определённых событиях в World of Warcraft."
L["AboutInfoEarlyDev"] = Colors.iSP .. "iSP " .. Colors.Reset .. "находится на ранней стадии разработки. Присоединяйтесь к Discord за помощью, вопросами и предложениями."
L["Discord"]         = Colors.iSP .. "Discord"
L["DiscordDesc"]     = "Скопируйте ссылку, чтобы присоединиться к нашему Discord-серверу (поддержка и обновления)."
L["DiscordLink"]     = "https://discord.gg/8nnt25aw8B"
L["Developer"]       = Colors.iSP .. "Разработчик"
L["EnableDebugMode"] = "Включить режим отладки"
L["DescDebugMode"]   = Colors.Gray .. "Включает подробные отладочные сообщения в чат." .. Colors.Reset

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Advanced Sound Options                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["AdvancedOptions"] = Colors.iSP .. "Расширенные настройки"
L["Duration"]        = "Длительность (сек)"
L["DescDuration"]    = Colors.Gray .. "Сколько секунд воспроизводить звук. 0 = полностью" .. Colors.Reset
L["StartOffset"]     = "Задержка перед стартом (сек)"
L["DescStartOffset"] = Colors.Gray .. "Задержка перед воспроизведением. Примечание: нельзя перематывать файл" .. Colors.Reset
L["Loop"]            = "Зациклить звук"
L["DescLoop"]        = Colors.Gray .. "Повторять воспроизведение звука" .. Colors.Reset
L["LoopCount"]       = "Количество повторов"
L["DescLoopCount"]   = Colors.Gray .. "Сколько раз повторить (1 = один раз, 2 = два раза и т.д.)" .. Colors.Reset
L["FadeIn"]          = "Плавное нарастание"
L["DescFadeIn"]      = Colors.Gray .. "Плавное увеличение громкости (не поддерживается API WoW)" .. Colors.Reset
L["FadeOut"]         = "Плавное затухание"
L["DescFadeOut"]     = Colors.Gray .. "Плавное уменьшение громкости (не поддерживается API WoW)" .. Colors.Reset
L["StopSound"]       = "Остановить звук"
L["StopAllSounds"]   = "Остановить все звуки"
L["AllSoundsStopped"] = Msg(Colors.Yellow .. "Все звуки остановлены." .. Colors.Reset)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Popup Dialogs                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["Yes"]     = "Да"
L["No"]      = "Нет"
L["Confirm"] = "Подтвердить"
L["Cancel"]  = "Отмена"
L["InCombat"] = Msg("Нельзя использовать в бою.")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Options Panel - Sidebar                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SidebarHeaderiSP"]      = Colors.iSP .. "iSoundPlayer|r"
L["SidebarHeaderOtherAddons"] = Colors.iSP .. "Другие аддоны|r"
L["TabINIF"]               = "Настройки iNIF"
L["TabINIFPromo"]          = "iNeedIfYouNeed"
L["TabIWR"]                = "Настройки iWR"
L["TabIWRPromo"]           = "iWillRemember"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Options Panel - Interface                             │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["InterfaceSettings"]   = Colors.iSP .. "Интерфейс"
L["SettingsHeader"]      = Colors.iSP .. "Настройки"
L["GeneralInfo"]         = Colors.Gray .. "iSoundPlayer позволяет воспроизводить свои MP3-файлы при определённых событиях." .. Colors.Reset
L["SoundFilesInfoShort"] = Colors.Gray .. "Поместите MP3/OGG-файлы сюда:|r\n" .. Colors.White .. "Interface\\AddOns\\iSoundPlayer\\sounds\\|r\n\n" .. Colors.iSP .. "Примеры звуков:|r " .. Colors.Gray .. "Найдите понравившиеся в папке iSoundPlayer\\_Samples, скопируйте в sounds и зарегистрируйте по имени файла. Перед назначением протестируйте!|r\n\n" .. Colors.iSP .. "ВАЖНО:|r " .. Colors.Gray .. "После добавления файлов выполните /reload" .. Colors.Reset
L["FilenameInputLabel"]  = Colors.White .. "Имя файла:|r " .. Colors.Gray .. "(например, mysound или mysound.mp3)" .. Colors.Reset
L["TestBtn"]             = "Тест"
L["SoundLabel"]          = "Звук:"
L["None"]                = "Нет"
L["NoSoundsWarning"]     = "Звуки не зарегистрированы! Сначала добавьте их во вкладке «Звуки»."
L["NoSoundSelected"]     = "Для этого триггера не выбран звук!"
L["TriggerDataError"]    = Colors.Red .. "Данные триггеров не загружены!" .. Colors.Reset
L["Enabled"]             = "Включено"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Options Panel - Other Addons                          │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["INIFSettingsHeader"] = Colors.iSP .. "Настройки iNeedIfYouNeed"
L["INIFInstalledDesc"]  = Colors.iSP .. "iNeedIfYouNeed" .. Colors.Reset .. " установлен! Вы можете открыть его настройки отсюда.\n\n" .. Colors.Gray .. "Внимание: эти настройки управляются самим аддоном iNIF." .. Colors.Reset
L["INIFOpenSettings"]   = "Открыть настройки iNIF"
L["INIFNotFound"]       = "Настройки iNIF не найдены!"
L["INIFPromoHeader"]    = Colors.iSP .. "iNeedIfYouNeed"
L["INIFPromoDesc"]      = Colors.iSP .. "iNeedIfYouNeed" .. Colors.Reset .. " — умный аддон для лута. Автоматически роллит Need, если кто-то в группе нуждается, иначе Greed. Никогда не упустите случайный BoE, который все должны были гридить.\n\n" .. Colors.Reset .. "Простой чекбокс на фрейме лута — поставьте галочку и нажмите Greed."
L["INIFPromoLink"]      = "Доступен в CurseForge App и на curseforge.com/wow/addons/ineedifyouneed"
L["IWRSettingsHeader"]  = Colors.iSP .. "Настройки iWillRemember"
L["IWRInstalledDesc"]   = Colors.iSP .. "iWillRemember" .. Colors.Reset .. " установлен! Настройки доступны отсюда.\n\n" .. Colors.Gray .. "Внимание: эти настройки управляются самим аддоном iWR." .. Colors.Reset
L["IWROpenSettings"]    = "Открыть настройки iWR"
L["IWRNotFound"]        = "Настройки iWR не найдены!"
L["IWRPromoHeader"]     = Colors.iSP .. "iWillRemember"
L["IWRPromoDesc"]       = Colors.iSP .. "iWillRemember" .. Colors.Reset .. " помогает вести заметки об игроках и делиться ими с друзьями.\n\n" .. Colors.Reset .. "Записывайте, кого стоит избегать, а кому можно доверять, и делитесь заметками с гильдией."
L["IWRPromoLink"]       = "Доступен в CurseForge App и на curseforge.com/wow/addons/iwillremember"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Minimap Tooltip                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["MinimapTooltipLeftClick"]  = Colors.Yellow .. "ЛКМ: " .. Colors.Orange .. "Руководство по настройке"
L["MinimapTooltipRightClick"] = Colors.Yellow .. "ПКМ: " .. Colors.Orange .. "Открыть настройки"
L["MinimapTooltipShiftClick"] = Colors.Yellow .. "Shift+ЛКМ: " .. Colors.Orange .. "Остановить все звуки"
L["MinimapTooltipStatus"]     = Colors.Yellow .. "Статус: " .. Colors.Reset
L["StatusEnabled"]            = Colors.Green .. "Включён" .. Colors.Reset
L["StatusDisabled"]           = Colors.Red .. "Отключён" .. Colors.Reset
L["MinimapTooltipSounds"]     = Colors.Yellow .. "Звуки: " .. Colors.Orange .. "%d зарегистрировано"
L["MinimapTooltipTriggers"]   = Colors.Yellow .. "Триггеры: " .. Colors.Orange .. "%d включено"
L["MinimapHidden"]            = "Кнопка у миникарты скрыта"
L["MinimapShown"]             = "Кнопка у миникарты показана"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Setup Guide                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SetupGuideHeader"]      = Colors.iSP .. "Руководство по настройке iSoundPlayer|r"
L["SetupGuideWelcome"]     = Colors.iSP .. "Добро пожаловать в iSoundPlayer!|r\n\n" .. Colors.White .. "Этот аддон позволяет воспроизводить свои MP3/OGG-файлы при различных событиях в игре.|r"
L["SetupGuideStep1Header"] = Colors.iSP .. "Шаг 1: Добавьте свои звуки|r"
L["SetupGuideStep1Text"]   = Colors.White .. "1. Перейдите в папку вашего WoW:|r\n" .. Colors.Gray .. "   Interface\\AddOns\\iSoundPlayer\\sounds\\|r\n\n" .. Colors.White .. "2. Поместите туда ваши MP3 или OGG-файлы|r\n\n" .. Colors.White .. "3. В чате введите |r" .. Colors.iSP .. "/reload|r " .. Colors.White .. "(перезапуск игры не нужен)|r\n\n" .. Colors.iSP .. "Примеры звуков:|r " .. Colors.Gray .. "В папке iSoundPlayer\\_Samples лежат готовые сэмплы — скопируйте понравившиеся в sounds и зарегистрируйте их по имени файла. Перед назначением обязательно протестируйте!|r"
L["SetupGuideStep2Header"] = Colors.iSP .. "Шаг 2: Зарегистрируйте звуки|r"
L["SetupGuideStep2Text"]   = Colors.White .. "1. Откройте настройки командой |r" .. Colors.Yellow .. "/isp|r " .. Colors.White .. "или кликом по иконке у миникарты|r\n\n" .. Colors.White .. "2. Перейдите во вкладку |r" .. Colors.iSP .. "Звуки|r\n\n" .. Colors.White .. "3. Введите имя файла и выберите его из списка|r\n\n" .. Colors.White .. "4. Нажмите |r" .. Colors.Green .. "Добавить звук|r\n\n" .. Colors.White .. "5. Нажмите |r" .. Colors.Yellow .. "Протестировать|r " .. Colors.White .. "для проверки|r"
L["SetupGuideStep3Header"] = Colors.iSP .. "Шаг 3: Настройте триггеры|r"
L["SetupGuideStep3Text"]   = Colors.White .. "1. Перейдите во вкладку |r" .. Colors.iSP .. "Триггеры|r\n\n" .. Colors.White .. "2. Выберите нужную категорию (игрок, бой, PvP и др.)|r\n\n" .. Colors.White .. "3. Включите триггер и назначьте ему зарегистрированный звук|r\n\n" .. Colors.White .. "4. Настройте параметры воспроизведения (зацикливание, задержка и т.д.)|r"
L["SetupGuideQuickTipsHeader"] = Colors.iSP .. "Быстрые советы|r"
L["SetupGuideQuickTipsText"]   = Colors.iSP .. "•|r " .. Colors.White .. "Команда |r" .. Colors.Yellow .. "/isp|r " .. Colors.White .. "— открыть настройки|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "ЛКМ по иконке у миникарты — это руководство|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "ПКМ по иконке — настройки|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "Shift+ЛКМ по иконке — остановить все звуки|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "После добавления файлов всегда делайте |r" .. Colors.Yellow .. "/reload|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "Вкладка «Общие» — включить/отключить аддон|r"
L["SetupGuideDontShow"]    = Colors.Gray .. "Не показывать при запуске|r"
L["SetupGuideOpenSettings"] = Colors.iSP .. "Открыть настройки|r"
L["SetupGuideClose"]       = Colors.Red .. "Закрыть|r"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Slash Commands                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SlashHelp"] = Colors.iSP .. "iSoundPlayer " .. Colors.White .. "v%s\n" ..
                Colors.Yellow .. "Команды:\n" ..
                Colors.Green .. "  /isp settings" .. Colors.White .. " — открыть настройки\n" ..
                Colors.Green .. "  /isp enable" .. Colors.White .. " — включить аддон\n" ..
                Colors.Green .. "  /isp disable" .. Colors.White .. " — отключить аддон"