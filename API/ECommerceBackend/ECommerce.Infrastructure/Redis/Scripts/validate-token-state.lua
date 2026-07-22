-- KEYS: block, blacklist-jti, revoked-session, security-version
-- ARGV: token-security-version
if redis.call('EXISTS', KEYS[1]) == 1 then return {0, 'ACCOUNT_REVOCATION_IN_PROGRESS'} end
local currentVersion = redis.call('GET', KEYS[4])
if not currentVersion then return {0, 'CACHE_MISS'} end
if tonumber(currentVersion) ~= tonumber(ARGV[1]) then return {0, 'SECURITY_VERSION_MISMATCH'} end
if redis.call('EXISTS', KEYS[2]) == 1 then return {0, 'JTI_BLACKLISTED'} end
if redis.call('EXISTS', KEYS[3]) == 1 then return {0, 'SESSION_REVOKED'} end
return {1, 'OK'}
