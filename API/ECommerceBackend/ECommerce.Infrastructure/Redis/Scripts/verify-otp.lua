-- KEYS: session
-- ARGV: supplied-hmac
if redis.call('EXISTS', KEYS[1]) == 0 then return {-2, 0, '', ''} end
local attempts = tonumber(redis.call('HGET', KEYS[1], 'attempts') or '0')
local maximum = tonumber(redis.call('HGET', KEYS[1], 'maxAttempts') or '0')
if attempts >= maximum then redis.call('DEL', KEYS[1]); return {-1, 0, '', ''} end
local expected = redis.call('HGET', KEYS[1], 'otpHash')
if expected ~= ARGV[1] then
  attempts = redis.call('HINCRBY', KEYS[1], 'attempts', 1)
  if attempts >= maximum then redis.call('DEL', KEYS[1]); return {-1, 0, '', ''} end
  return {0, maximum - attempts, '', ''}
end
local accountId = redis.call('HGET', KEYS[1], 'accountId') or ''
local payload = redis.call('HGET', KEYS[1], 'payload') or ''
redis.call('DEL', KEYS[1])
return {1, maximum - attempts, accountId, payload}
