-- WARNING! THIS SCRIPT IS CURRENTLY INCOMPLETE! IF YOU SEE THIS RIGHT NOW THEN THE SCRIPT IS NOT FINISHED AND WILL NOT WORK PROPERLY.

-- FF01's Rejoin Tool Dupe
-- Original idea I got this script from was made by emptyforce's slave AI
-- Moreover I'd rather just remake it than look for it

-- I don't believe in gatekeeping, so this will be public source code.
-- Who even cares if their code is being used, at least it's helping someone

-- DO NOT USE THIS IN AUTOEXEC, THE SCRIPT WILL AUTOMATICALLY RE-RUN ITSELF.
-- PS: This must be called with loadstring.

local IncomingData = ...
assert(typeof(IncomingData) ~= "table", "Loadstring argument must be a table!")
assert(IncomingData["Key"], "Loadstring argument must have a Key value in the table!")
assert(typeof(IncomingData["Key"]) ~= "string", "Key argument in loadstring argument must be a string!")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Owner = Players.LocalPlayer
local Character
local Humanoid

local Secret = IncomingData["Key"] -- this can be anything this is just gonna get hashed, it verifies that the table is my scripts' before just magically erroring from the game moving you with its own custom data for some random shit
local HashedKey = crypt.hash(Secret, "sha256")

local IncomingAmount = IncomingData["DupeAmount"]
local CurrentStats = {
    DupeAmount = tonumber(IncomingAmount) or 5,
    ToolStorePos = Vector3.new(9e6, 9e9, 9e6),
    Index = 0, -- DO NOT MODIFY THIS
    [HashedKey] = true, -- DO NOT MODIFY THIS
}

local QueueOnTeleport = queueonteleport or queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or function() end

local function RegisterHumanoid()
    repeat task.wait() until Owner.Character
    Character = Owner.Character
    Humanoid = Owner.Character and Owner.Character:FindFirstChildOfClass("Humanoid")
end

local function EquipTool(Tool)
    if not Humanoid then return end
    if Tool and Tool:IsA("BackpackItem") and Tool:FindFirstChild("Handle") then
        Humanoid:EquipTool(Tool)
    end
end

local function SaveStats(Stats)
    -- I know setting JoinData is insecure and the server can see it, but what game is gonna detect my variables?
    -- JoinData in legitimate uses though can be really helpful for some games
    local Options = Instance.new("TeleportOptions")
    Options:SetTeleportData(Stats)
    Options.ServerInstanceId = game.JobId

    return Options
end

local function RetrieveStats(Stats)
    -- This function will only call when the user is rejoined and the script runs again.
    local Data = TeleportService:GetLocalPlayerTeleportData()

    if Data and Data[HashedKey] then
        CurrentStats = Data
    end
end

local function EquipTools(WhatIsABool)
    for _, Tool in Owner.Backpack:GetChildren() do
        if Tool:IsA("BackpackItem") then
            Tool.Parent = WhatIsABool and Character or Owner.Backpack
        end
    end
end

local function DropTools()
    for _, Tool in Owner.Backpack:GetChildren() do
        if Tool:IsA("BackpackItem") then
            Tool.Parent = workspace
        end
    end
end

local function Dupe()
    -- The main dupe function.
    RetrieveStats()
    RegisterHumanoid()
    local GrandmaLifeSupport = Instance.new("Part")
    GrandmaLifeSupport.Position = CurrentStats.ToolStorePos + Vector3.new(0, -1, 0)
    GrandmaLifeSupport.Size = Vector3.new(2048, 1, 2048)
    GrandmaLifeSupport.Anchored = true
    GrandmaLifeSupport.Transparency = 1
    GrandmaLifeSupport.Parent = workspace
    for _, Tool in workspace:GetDescendants() do
        if Tool:IsA("BackpackItem") and Tool.Handle then
            EquipTool(Tool)
        end
    end
    if CurrentStats.Index == CurrentStats.DupeAmount then return end
    Character:PivotTo(CurrentStats.ToolStorePos)
    EquipTools(true)
    task.wait(.25)
    DropTools()
    local IncomingDataTableLength = 0
    for _ in IncomingData do -- This simply retrieves the length of the table, since it uses indexes that aren't numbers.
        IncomingDataTableLength += 1
    end
    local OutArgTable = "{" -- This compiles the table provided initially via LoadString to another string to re-call itself with the same data when you get rejoined.
    for Index, Value in IncomingData do
        OutArgTable = OutArgTable .. "[" .. tostring(Index) .. "] = " .. tostring(Value) .. (Index == IncomingDataTableLength and "}" or ", ")
    end
    CurrentStats.Index += 1 -- Counts up the index before rejoining
    QueueOnTeleport(`loadstring("http://raw.githubusercontent.com/f-f-0-1/roblox/scripts/RejoinDupe.lua")({OutArgTable})`)
    task.wait(0.5)
    local Stats = SaveStats()
    TeleportService:TeleportAsync(game.PlaceId, Owner, Stats)
end

Dupe()
