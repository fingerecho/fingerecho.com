local template = require "resty.template"

local mysql = require "resty.mysql"

local redis = require "resty.redis"


mysql = require "resty.mysql"

-- 查询数据库是否存在该用户，若不存在则将 email telephone password 存入数据库

 db , err = mysql:new()

if not db then
        --ngx.say("failed to instantiate mysql:",err)
        ngx.redirect('/status?message=instantiate-Mysql-Failed')
        return
end

db:set_timeout(1000)    --- 1 sec

ok , err , errno , sqlstate = db:connect{
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


red = redis:new()

-- 设置连接超时时间（单位：毫秒）
red:set_timeout(1000)
 
-- 连接Redis服务器
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    --ngx.say("无法连接到Redis服务器: ", err)
    ngx.redirect('/status?message=无法连接到Redis服务器')
    return
end

local res,err = red:auth("asdfASDF123!@#")
if not res then
   ngx.redirect('/status?message=Redis授权失败')
   return nil
end

if not ok then
        --ngx.say("faild to connect:",err,":",errno," ",sqlstate)
        ngx.redirect('/status?message=connect-Mysql-Failed')
        return
end

local select_sql = "select email , message from message_board;"  
--ngx.say(select_sql)
res, err, errno, sqlstate = db:query(select_sql)
if not res then
   --ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
   ngx.redirect('/status?message=Query-Mysql-Failed'..err..errno..sqlstate)
   return
elseif #res ~= 0 then
   --ngx.say("Messages > 0 ")
   template.render("message.html", { messages = res })
   --for email,msgs in pairs(res) do
   	--	ngx.say(email..msgs)
   --end
elseif #res == 0 then
	ngx.redirect('/status?No message !!')
   -- ngx.say("no message")
end
