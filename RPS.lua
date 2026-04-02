-- RPS.lua
local addon = RPS

local state = addon.state

-- ── Slash commands ───────────────────────────────────────────────────────────

local function setupSlash()
    SLASH_RPS1 = "/rps"
    SlashCmdList.RPS = function(msg)
        local cmd, arg = msg:match("^(%S+)%s*(.*)")
        if not cmd then
            addon.chatPrint("Usage: /rps challenge <player> | accept | decline | rock | paper | scissors")
            return
        end
        cmd = cmd:lower()

        if cmd == "challenge" and arg ~= "" then
            addon.challenge(arg)
        elseif cmd == "accept" then
            if state.phase ~= "challenged" then
                addon.chatPrint("No pending challenge.")
                return
            end
            state.phase = "throwing"
            RPS.Net.send(state.opponent, RPS.MSG.ACCEPT)
            addon.chatPrint("Challenge accepted! Type /rps rock, /rps paper, or /rps scissors.")
        elseif cmd == "decline" then
            if state.phase ~= "challenged" then
                addon.chatPrint("No pending challenge.")
                return
            end
            RPS.Net.send(state.opponent, RPS.MSG.DECLINE)
            RPS.Game.reset()
            addon.chatPrint("Challenge declined.")
        elseif cmd == "rock" or cmd == "paper" or cmd == "scissors" then
            addon.throw(cmd)
        else
            addon.chatPrint("Unknown command. Try /rps for help.")
        end
    end
end

-- ── Initialisation ───────────────────────────────────────────────────────────

function addon.chatPrint(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffC69B3A[RPS]|r " .. msg)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "RPS" then
            eventFrame:UnregisterEvent("ADDON_LOADED")
            RPS.Net.register()
            setupSlash()
            addon.chatPrint("Loaded. Challenge someone with /rps challenge <player>.")
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, distribution, sender = ...
        if not RPS.Net.isRPSMessage(prefix) then return end
        RPS.Net.onAddonMessage(message, distribution, sender)
    end
end)
