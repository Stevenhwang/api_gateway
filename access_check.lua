local jwt = require "resty.jwt"
local conn = require "libs.redis_conn"
local split = require "libs.string_split"
local check_auth = require "libs.check_auth"
local cjson = require "cjson"

-- 获取请求request_method uri headers
local request_method = ngx.var.request_method
local uri = ngx.var.request_uri
local headers_tab = ngx.req.get_headers()

-- 请求白名单
local white = string.find(uri, "/api/mg/v1/login/")
if white == 1 then
    ngx.var.my_upstream = login_uri
-- 如果请求没有带token，直接拒绝
elseif headers_tab["Auth-Token"] == nil then
    ngx.status = 401
    ngx.say("No Token!")
    ngx.exit(401)
else
    -- 解析token
    local jwt_obj = jwt:verify(token_secret, headers_tab["Auth-Token"])
    -- 如果token解析非法，拒绝
    if jwt_obj["verified"] == false then
        ngx.status = 401
        ngx.say("reason: "..jwt_obj["reason"])
        ngx.exit(401)
    else
        -- 拿到token信息
        local user_info = jwt_obj["payload"]["data"]
        local conn = conn.conn()
        if conn == false then
            ngx.status = 500
            ngx.say("Failed to connect redis!")
            ngx.exit(500)
        end
        -- 根据uid去redis拿用户token
        local tmp_token, err = conn:get("uid_"..user_info["user_id"].."_auth_token")
        -- 如果拿不到token或者拿到的token跟header带的token不匹配，拒绝
        if not tmp_token or tmp_token == ngx.null or tmp_token ~= headers_tab["Auth-Token"] then
            ngx.status = 401
            ngx.say("Expired Token!")
            ngx.exit(401)
        end
        -- 解析请求的uri
        local uri_list = split.split(uri, "/")
        local req_end = "/"..uri_list[1].."/"..uri_list[2]
        -- 根据end_point去redis查询后端服务
        local tmp_bs, err = conn:hget("backend_service", req_end)
        if not tmp_bs or tmp_bs == ngx.null then
            ngx.status = 500
            ngx.say("No backend service!")
            ngx.exit(500)
        end
        local tmp_obj = cjson.decode(tmp_bs)
        -- 去掉请求uri中的end_point
        local real_end, pos = string.gsub(uri, req_end, "")
        local real_url = tmp_obj["url"]..real_end
        -- 去后端查询是否有路由权限，先把带?号的去掉，避免干扰
        local real_query_end = split.split(real_end, "?")
        local permit = check_auth.check(user_info["user_id"], real_query_end[1], request_method)
        if permit == false then
            ngx.status = 403
            ngx.say("Permission denied!")
            ngx.exit(403)
        else
            ngx.var.my_upstream = real_url
        end
    end
end