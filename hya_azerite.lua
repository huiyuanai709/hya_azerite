local msg = '%s(%d Lv)(%d/%d) : +%d Power';

local Caches = {};

local C_AzeriteItem = C_AzeriteItem;
local C_Item = C_Item;
local find = _G.string.find;
local format = _G.string.format;

local locale = GetLocale();
if(locale == 'zhCN') then
    msg = '%s(%d 级)(%d/%d) : +%d 能量';
end

local currency = 'currency:1553';

function filter(_, _, msg, ...)
    if(msg:find(currency)) then
        return true;
    end
    local azeriteItemLink = getOrCreateCache();
    if(msg:find(azeriteItemLink or '', nil, true)) then
        return true;
    end

    return;
end

function getOrCreateCache()
    if(Caches['link']) then
        return Caches['link'];
    end
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
    local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation);
    local azeriteItemLink = azeriteItem:GetItemLink();
    Caches['link'] = azeriteItemLink;
    return azeriteItemLink;
end

function createMsg(_, _, azeriteItemLocation, old, new)
    local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation);
    local name = azeriteItem:GetItemName();
    local level = azeriteItem:GetCurrentItemLevel();
    local azeriteItemLink = getOrCreateCache();
    local xp, totalLevelXp = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
    local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation);
    azeriteItemLink = azeriteItemLink:gsub('|h%[(.-)]|h', '|h['..level..':'..name..']|h');
    local msg = string.format(msg, azeriteItemLink, currentLevel, xp, totalLevelXp, new - old);
    addMsg(msg);
end

function addMsg(msg)
    local info = ChatTypeInfo["COMBAT_FACTION_CHANGE"];
    local chatfrm = getglobal("ChatFrame"..1);
    chatfrm:AddMessage(msg, info.r, info.g, info.b, info.id);
end

local frame = CreateFrame('Frame');
frame:RegisterEvent('AZERITE_ITEM_EXPERIENCE_CHANGED');
frame:SetScript('OnEvent', createMsg);

ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', filter);