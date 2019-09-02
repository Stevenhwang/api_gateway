local redis = require "resty.redis"
local _M = {}
_M._VERSION = '1.0'

function _M.conn()
    local red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect(redis_config['host'], redis_config['port'])
    if not ok then
        return false
    end
    red:auth(redis_config['auth_pwd'])
    ok, err = red:select(redis_config['db'])
    if not ok then
        return false
    end
    return red
end

return _M
