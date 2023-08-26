local mysql = require "resty.mysql"

require "utils"

local db , err = mysql:new()

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
---require "redisconnect"
-- 用于验证身份
--[[
local get_res, err = red:get( kvargs.message )
if not get_res then
    ngx.redirect("/status?message=",err)
end--]]

local insert_sql = "insert into message_board (message) values('" ..kvargs.message.."');"  
    --ngx.say(insert_sql)
    res, err, errno, sqlstate = db:query(insert_sql)
    --print("#res is ",#res)
    if not res then  
       --ngx.say("insert error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate) 
       ngx.redirect('/status?message=Insert-Mysql-Failed'..err..errno..sqlstate)
       return
    else
        ngx.redirect('/status?message=Comment Success!')
    end