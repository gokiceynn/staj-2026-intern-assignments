-- KEYS: block, security-version, then blacklist/session keys
-- ARGV: version, security-ttl-ms, pair-count, then kind/ttl-ms pairs
redis.call('SET', KEYS[2], ARGV[1], 'PX', ARGV[2])
local pairCount = tonumber(ARGV[3])
for i = 1, pairCount do
  local keyIndex = i + 2
  local argIndex = 4 + ((i - 1) * 2)
  local kind = ARGV[argIndex]
  local ttl = tonumber(ARGV[argIndex + 1])
  if ttl > 0 then redis.call('SET', KEYS[keyIndex], kind, 'PX', ttl) end
end
redis.call('DEL', KEYS[1])
return 1
