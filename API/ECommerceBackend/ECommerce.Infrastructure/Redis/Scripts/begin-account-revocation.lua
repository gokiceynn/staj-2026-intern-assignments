-- KEYS: account-block
-- ARGV: ttl-ms
redis.call('SET', KEYS[1], '1', 'PX', ARGV[1])
return 1
