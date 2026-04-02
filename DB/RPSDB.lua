-- DB/RPSDB.lua
local DB = RPS.DB

local function getDefaults()
    return {
        wins   = 0,
        losses = 0,
        draws  = 0,
    }
end

function DB.init()
    if type(RPSCharDB) ~= "table" then
        RPSCharDB = getDefaults()
    else
        local defaults = getDefaults()
        for k, v in pairs(defaults) do
            if RPSCharDB[k] == nil then
                RPSCharDB[k] = v
            end
        end
    end
    DB.sv = RPSCharDB
end

function DB.recordResult(result)
    if result == "win" then
        DB.sv.wins = DB.sv.wins + 1
    elseif result == "loss" then
        DB.sv.losses = DB.sv.losses + 1
    elseif result == "draw" then
        DB.sv.draws = DB.sv.draws + 1
    end
end

function DB.getSummary()
    return DB.sv.wins, DB.sv.losses, DB.sv.draws
end
