-- KEYS: active, cooldown, new-session
-- ARGV: ttl-ms, cooldown-ms, account-id, email-hash, otp-hash, max-attempts, protected-payload
local cooldownTtl = redis.call('PTTL', KEYS[2])
if cooldownTtl > 0 then return {0, cooldownTtl} end
local oldSession = redis.call('GET', KEYS[1])
if oldSession then redis.call('DEL', oldSession) end
redis.call('HSET', KEYS[3],
  'accountId', ARGV[3], 'emailHash', ARGV[4], 'otpHash', ARGV[5],
  'attempts', '0', 'maxAttempts', ARGV[6], 'payload', ARGV[7])
redis.call('PEXPIRE', KEYS[3], ARGV[1])
redis.call('SET', KEYS[1], KEYS[3], 'PX', ARGV[1])
redis.call('SET', KEYS[2], '1', 'PX', ARGV[2])
return {1, 0}
