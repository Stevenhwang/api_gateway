local http = require "resty.http"
local _M = {}
_M._VERSION = '1.0'

-- 根据uid uri method去后端查询此用户是否具有路由权限
function _M.check(uid, uri, method)
    local httpc = http.new()
    local res, err = httpc:request_uri(check_auth_url.."?uid="..uid.."&uri="..uri.."&method="..method, {
      method = "GET",
      keepalive_timeout = 60,
      keepalive_pool = 10
    })
    return res.body
end

-- 网关日志上报
function _M.upload(data)
    local httpc = http.new()
    local res, err = httpc:request_uri(upload_log_url, {
        method = "POST",
        body = data,
        keepalive_timeout = 60,
        keepalive_pool = 10
      })
    return res.body
end
return _M
