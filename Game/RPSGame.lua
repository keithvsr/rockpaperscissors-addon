-- Game/RPSGame.lua
local addon  = RPS
local Game   = RPS.Game

local THROWS = { "Rock", "Paper", "Scissors" }

-- wins[a][b] = true means a beats b
local wins   = {
    Rock     = { Scissors = true },
    Paper    = { Rock = true },
    Scissors = { Paper = true },
}
addon.wins   = wins

-- session state
local state  = {
    phase    = "idle", -- idle | challenged | waiting | throwing
    opponent = nil,
    myThrow  = nil,
}
addon.state  = state



-- ── Game logic ───────────────────────────────────────────────────────────────

function Game.resolve(myThrow, theirThrow)
    if myThrow == theirThrow then
        return "draw"
    elseif wins[myThrow] and wins[myThrow][theirThrow] then
        return "win"
    else
        return "loss"
    end
end

function Game.reset()
    state.phase    = "idle"
    state.opponent = nil
    state.myThrow  = nil
end

function Game.printResult(result, myThrow, theirThrow, opponent)
    local resultText = {
        win  = "|cff00ff00You win!|r",
        loss = "|cffff0000You lose!|r",
        draw = "|cffffff00Draw!|r",
    }
    addon.chatPrint(string.format(
        "vs %s — You: %s | Them: %s — %s",
        opponent, myThrow, theirThrow, resultText[result]
    ))
end
