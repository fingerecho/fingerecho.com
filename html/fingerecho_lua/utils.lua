function unescape (s)
    s = string.gsub(s, "+", " ")
    s = string.gsub(s, "%%(%x%x)", function (h)
        return string.char(tonumber(h, 16))
       end)
    return s
end

function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end
--[[
ngx.req.get_body_data() 读请求体，会偶尔出现读取不到直接返回 nil 的情况。

如果请求体尚未被读取，请先调用 ngx.req.read_body (或打开 lua_need_request_body 选项强制本模块读取请求体，此方法不推荐）。

如果请求体已经被存入临时文件，请使用 ngx.req.get_body_file 函数代替。 
 --]]

 function getFile(file_name)
    local f = assert(io.open(file_name, 'r'))
    local string = f:read("*all")
    f:close()
    return string
end

ngx.req.read_body()
data = ngx.req.get_body_data()
if nil == data then
    local file_name = ngx.req.get_body_file()
    --ngx.say(">> temp file: ", file_name)
    ngx.redirect('/status?message=getFile failed')
    if file_name then
        data = getFile(file_name)
    end
end

--ngx.say("hello ", data)

--data = 'email=283285356%40qq.com&telephone=17520092105&password=fkc%3E%3E%3Escs%21'
data = unescape(data)
test = Split(data, '&')

local kvargs = {}
for i,j in pairs(test) do 
    m = Split(j,'=')
    kvargs[m[1]] = m[2]
end