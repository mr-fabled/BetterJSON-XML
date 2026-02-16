# BetterJSON-XML
Simple XML serializer/parser with null helper methods

Intended for simple table serialization in Roblox/Polytoria, such as Datastore storage.

---

## Features

Serializes Lua tables into XML format
Parse XML back into Lua tables
'null' helper methods
Supports:
  - Strings
  - Numbers
  - Booleans
  - Nested tables

---

## Usage

```lua
local BetterJSON = require(path)

local data = {
    Unit = "Troop",
    Stats = {
        Health = 100,
        Damage = 10 },
    Alive = true
}

local j = BetterJSON.new()
local xml = j:serializeXML(data)
print(xml)

local parsed = j:parseXML(xml)
print(parsed.Stats.Health)
```
