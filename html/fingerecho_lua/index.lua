
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
local data = ngx.req.get_body_data()
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
---ngx.say(res['password'])
-- 连接MySql，查询数据库是否存在该用户，若不存在则将 email telephone password 存入数据库
local mysql = require "resty.mysql"
local db , err = mysql:new()

if not db then
        --ngx.say("failed to instantiate mysql:",err)
        ngx.redirect('/status?message=instantiate-Mysql-Failed')
        return
end

db:set_timeout(1000)    --- 1 sec

local ok , err , errno , sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "fingerecho" ,
        user = "root" ,
        password = "asdfASDF123!@#",
        max_packet_size = 1024*1024 }

if not ok then
        --ngx.say("faild to connect:",err,":",errno," ",sqlstate)
        ngx.redirect('/status?message=connect-Mysql-Failed')
        return
end
--ngx.say("connect to mysql.")

-- 查询mysql
local select_sql = "select uno, telephone , email , password from user where email = \'"..kvargs['email'].."\';"  
--ngx.say(select_sql)
res, err, errno, sqlstate = db:query(select_sql)
if not res then
   --ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
   ngx.redirect('/status?message=Query-Mysql-Failed'..err..errno..sqlstate)
   return
elseif #res ~= 0 then
   --ngx.say("You have already been in db.")
   ngx.redirect('/status?message=You have already been in db.')
elseif #res == 0 then
    --ngx.say("You have already not been in db.")
    --ngx.redirect('/status?message=You have already been in db.')
    --插入mysql
    local insert_sql = "insert into user(email,telephone,password) values('" ..kvargs.email.."','"..kvargs.telephone.."','"..kvargs.password.."');"  
    --ngx.say(insert_sql)
    res, err, errno, sqlstate = db:query(insert_sql)
    --print("#res is ",#res)
    if not res then  
       --ngx.say("insert error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate) 
       ngx.redirect('/status?message=Insert-Mysql-Failed'..err..errno..sqlstate)
       return
    else
        ngx.redirect('/status?message=Sign Success!')
    end
    
end

--ngx.redirect("/",302)
