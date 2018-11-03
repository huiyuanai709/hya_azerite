local msg = '%s(%d Lv)(%d/%d) : +%d Power';

local Caches = {};

local locale = GetLocale();
if(locale == 'zhCN') then
    msg = '%s(%d 级)(%d/%d) : +%d 能量';
end

local C_AzeriteItem = C_AzeriteItem;
local C_Item = C_Item;
local find = _G.string.find;
local format = _G.string.format;

local currency = 'currency:1553';

local neckItem = '|Hitem:158075'

function filter(_, _, msg, ...)
    if(msg:find(currency)) then
        return true;
    end
    if(msg:find(neckItem)) then
        return true;
    end
    return;
end

function chooseEvent(_, event, ...)
    if(event == 'AZERITE_ITEM_EXPERIENCE_CHANGED') then
        return createMsg(_, self, ...);
    end
    return buildCaches();
end

function createMsg(_, self, azeriteItemLocation, old, new)
    local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation);
    local name = azeriteItem:GetItemName();
    local level = azeriteItem:GetCurrentItemLevel();
    local azeriteItemLink = azeriteItem:GetItemLink();
    local xp, totalLevelXp = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
    local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation);
    local gained = new - old;
    if(gained < 0) then
        gained = new + Caches[0] - old;
        Caches[0] = currentLevel;
    end
    azeriteItemLink = azeriteItemLink:gsub('|h%[(.-)]|h', '|h['..level..':'..name..']|h');
    local msg = string.format(msg, azeriteItemLink, currentLevel, xp, totalLevelXp, gained);
    addMsg(msg);
end

function buildCaches()
    if(Caches[0]) then
        return;
    end
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
    local _, totalLevelXp = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
    Caches[0] = totalLevelXp;
end

function addMsg(msg)
    local info = ChatTypeInfo["COMBAT_FACTION_CHANGE"];
    local chatfrm = getglobal("ChatFrame"..1);
    chatfrm:AddMessage(msg, info.r, info.g, info.b, info.id);
end

local frame = CreateFrame('Frame', 'hya_azerite');
frame:RegisterEvent('PLAYER_ENTERING_WORLD');
frame:RegisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED');
frame:SetScript('OnEvent', chooseEvent);
ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', filter);
