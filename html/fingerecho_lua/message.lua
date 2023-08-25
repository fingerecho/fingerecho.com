local template = require "resty.template"

-- 连接MySql，查询数据库,查询所有的留言，并展示在message.html模版中
local mysql = require "resty.mysql"
local db , err = mysql:new()


local ok , err , errno , sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "fingerecho" ,
        user = "root" ,
        password = "asdfASDF123!@#",
        max_packet_size = 1024*1024 }

local select_sql = "select email , message from message_board;"  
--ngx.say(select_sql)
res, err, errno, sqlstate = db:query(select_sql)
if not res then
   --ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
   ngx.redirect('/status?message=Query-Mysql-Failed'..err..errno..sqlstate)
   return
elseif #res ~= 0 then
   ngx.say("Messages > 0 ")
   --template.render("message.html", { messages = res })
   --for email,msgs in pairs(res) do
   	--	ngx.say(email..msgs)
   --end
elseif #res == 0 then
	ngx.say("no message")
end
