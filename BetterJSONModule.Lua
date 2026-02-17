local BetterJSON = {}
BetterJSON.__index = BetterJSON

function BetterJSON.new()
    local self = setmetatable({}, BetterJSON)
    return self
end
function BetterJSON.isNull(xmlStr)
    --[[
    ^ = start of string
    %s* = removes pre whitespace
    (.-) = capture minimal content
    %s* = removes post whitespace
    $ = end of string ]]
    local str = xmlStr:match("^%s*(.-)%s*$")
    return str == "null"
end
function BetterJSON.null()
    return "null"
end

--[[
Serialize a Lua table into XML format.

@param table table -- table to serialize
@param divName string -- optional root/div name
@return string -- XML formatted string ]]
function BetterJSON:serializeXML(table, divName)
    local divName = divName or "root"
    
    local function writeXML(tbl, tagName)
        local start = "<" .. tagName .. ">"
        for key, val in pairs(tbl) do
            local strKey = tostring(key)
            if type(val) == "table" then
                start = start .. writeXML(val, strKey)
            elseif type(val) == "string" then
                start = start .. "<" .. strKey .. ">" .. val .. "</" .. strKey .. ">"
            elseif type(val) == "number" or type(val) == "boolean" then
                start = start .. "<" .. strKey .. ">" .. tostring(val) .. "</" .. strKey .. ">"
            elseif val == nil then
                start = start .. "<" .. strKey .. ">" .. BetterJSON.null() .. "</" .. strKey .. ">"
            end
        end
        start = start .. "</" .. tagName .. ">"
        return start
    end

    return writeXML(table, divName)
end

--[[ Parses an XML string into a Lua table.

@param xmlStr string -- <openingTag>/ncontent/n</closingTag>
@return table -- Lua table ]]
function BetterJSON:parseXML(xmlStr)
    -- shared cursor
    local pos = 1

    -- parse a tag and its contents
    local function parseNode()
        --[[
        s = startIndex
        e = endIndex
        tag = captured tagName
        (%w+) = capture tagName ]]
        local s, e, tag = xmlStr:find("<(%w+)>", pos)
        if not s then return nil end
        -- move cursor right
        pos = e + 1

        -- if exists, store children
        local t = {}
        while pos <= #xmlStr do
            --[[ variables to track relative position
            (%w+) = capture one or more of alphanumeric characters ]]
            local nextTagStart, nextTagEnd, childTag = xmlStr:find("<(%w+)>", pos)
            local closeTagStart, closeTagEnd = xmlStr:find("</"..tag..">", pos)
            if not nextTagStart or nextTagStart > closeTagStart then
                -- in between tags
                local content = xmlStr:sub(pos, closeTagStart - 1):match("^%s*(.-)%s*$")
                pos = closeTagEnd + 1
                if content == "true" then
                    return true
                elseif content == "false" then
                    return false
                elseif content == "null" then
                    return nil
                elseif tonumber(content) then
                    return tonumber(content)
                elseif content ~= "" then
                    return content
                else
                    return t
                end
            else
                pos = nextTagStart
                t[childTag] = parseNode()
            end
        end
    end
    return parseNode()
end

return BetterJSON
