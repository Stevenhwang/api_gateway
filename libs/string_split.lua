local _M = {}
_M._VERSION = '1.0'

function _M.split(str, sep)
    local resultStrList = {}
    string.gsub(str,'[^'..sep..']+',function (w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

return _M
