-- Net/RPSNet.lua
local addon     = RPS
local Net       = RPS.Net

local PREFIX    = "RPS"
local DELIMITER = ":"

-- message types
local MSG       = {
    CHALLENGE = "CHALLENGE",
    ACCEPT    = "ACCEPT",
    DECLINE   = "DECLINE",
    THROW     = "THROW",
    RESULT    = "RESULT",
}
addon.MSG       = MSG

local state     = addon.state

-- ── Messaging ────────────────────────────────────────────────────────────────

local function send(player, msgType, payload)
    local message = payload and (msgType .. DELIMITER .. payload) or msgType
    C_ChatInfo.SendAddonMessage(PREFIX, message, "WHISPER", player)
end

local function parse(raw)
    local msgType, payload = raw:match("^([^" .. DELIMITER .. "]+)" .. DELIMITER .. "?(.*)")
    return msgType, payload ~= "" and payload or nil
end

-- ── Outgoing actions ─────────────────────────────────────────────────────────

function addon.challenge(targetPlayer)
    if state.phase ~= "idle" then
        addon.chatPrint("You're already in a game.")
        return
    end
    state.phase    = "waiting"
    state.opponent = targetPlayer
    send(targetPlayer, MSG.CHALLENGE)
    addon.chatPrint("Challenge sent to " .. targetPlayer .. ".")
end

function addon.throw(choice)
    if state.phase ~= "throwing" then
        addon.chatPrint("No active game — challenge someone first with /rps challenge <name>.")
        return
    end
    choice = choice:gsub("^%l", string.upper) -- capitalise first letter
    if not addon.wins[choice] then
        addon.chatPrint("Invalid throw. Choose: Rock, Paper, or Scissors.")
        return
    end
    state.myThrow = choice
    state.phase   = "idle"
    send(state.opponent, MSG.THROW, choice)
    addon.chatPrint("Throw sent. Waiting for result...")
end

-- ── Incoming message handler ─────────────────────────────────────────────────
function Net.isRPSMessage(prefix)
    if prefix ~= PREFIX then return end
end

function Net.onAddonMessage(raw, _, sender)
    local Game = addon.Game
    local wins = addon.wins
    -- strip realm from sender if present (e.g. "Player-Realm" -> "Player")
    local senderName = sender:match("^([^%-]+)") or sender

    local msgType, payload = parse(raw)

    if msgType == MSG.CHALLENGE then
        if state.phase ~= "idle" then
            send(senderName, MSG.DECLINE)
            return
        end
        state.phase    = "challenged"
        state.opponent = senderName
        addon.chatPrint(senderName .. " challenges you to Rock Paper Scissors!")
        addon.chatPrint("Type /rps accept or /rps decline.")
    elseif msgType == MSG.ACCEPT then
        if state.phase ~= "waiting" or state.opponent ~= senderName then return end
        state.phase = "throwing"
        addon.chatPrint(senderName .. " accepted! Type /rps rock, /rps paper, or /rps scissors.")
    elseif msgType == MSG.DECLINE then
        if state.opponent ~= senderName then return end
        addon.chatPrint(senderName .. " declined your challenge.")
        Game.reset()
    elseif msgType == MSG.THROW then
        -- we receive their throw; we already sent ours
        -- the challenger resolves and sends RESULT to both
        local theirThrow = payload
        if not theirThrow or not wins[theirThrow] then return end

        local result = Game.resolve(state.myThrow, theirThrow)
        Game.printResult(result, state.myThrow, theirThrow, senderName)

        -- tell the opponent the outcome from their perspective
        local theirResult = result == "win" and "loss" or result == "loss" and "win" or "draw"
        send(senderName, MSG.RESULT, theirResult .. DELIMITER .. theirThrow .. DELIMITER .. state.myThrow)
        Game.reset()
    elseif msgType == MSG.RESULT then
        if not payload or not type(payload) == "string" then return end
        -- we're the one who threw second; challenger already resolved
        local result, theirThrow, myThrow = payload:match("([^:]+):([^:]+):([^:]+)")
        Game.printResult(result, myThrow, theirThrow, senderName)
        Game.reset()
    end
end

function Net.register()
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
end
