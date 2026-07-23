-- KEYS: counter
-- ARGV: permit-limit, window-ms, now-unix-seconds
local count = redis.call('INCR', KEYS[1])
if count == 1 then redis.call('PEXPIRE', KEYS[1], ARGV[2]) end
local ttl = redis.call('PTTL', KEYS[1])
local allowed = count <= tonumber(ARGV[1]) and 1 or 0
local remaining = math.max(0, tonumber(ARGV[1]) - count)
local retry = allowed == 1 and 0 or math.ceil(ttl / 1000)
local reset = tonumber(ARGV[3]) + math.ceil(ttl / 1000)
return {allowed, remaining, retry, reset}
