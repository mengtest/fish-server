local skynet_m = require "skynet_m"
local channel = require "channel"
local util = require "util"
local timer = require "timer"

local setmetatable = setmetatable

local session = tonumber(...)
local channel_i

local CMD = {}

CMD.routine = timer.call_routine

function CMD.start(gate, from)
    if channel_i then
        skynet_m.log(string.format("Restart agent %s.", util.udp_address(from)))
        CMD.stop()
    end
    channel_i = setmetatable({}, channel)
    channel_i:init(session, from, function(data)
        skynet_m.send_lua(gate, "send", from, data)
    end)
    return session
end

function CMD.process(data)
    if channel_i then
        channel_i:process(data)
    else
        skynet_m.log(string.format("Agent %d has stop.", session))
    end
end

function CMD.send(data)
    if channel_i then
        channel_i:send(data)
    else
        skynet_m.log(string.format("Agent %d has stop.", session))
    end
end

function CMD.stop(code)
    if channel_i then
        channel_i:kick(code)
    else
        skynet_m.log(string.format("Agent %d has stop.", session))
    end
    channel_i = nil
    timer.del_all()
end

function CMD.exit()
	skynet_m.exit()
end

skynet_m.start(function()
    skynet_m.dispatch_lua_queue(CMD)
end)