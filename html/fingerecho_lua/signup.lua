local mysql = require "resty.mysql"
-- 引入必要的Lua库
local redis = require "resty.redis"

require "utils"

-- 查询Redis 是否存在相应的email,password,若存在，则登录成功
-- 创建Redis实例
local red = redis:new()

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

local get_res, err = red:get( kvargs.email )
if get_res then
    ngx.redirect("/status?message=Your session has been saved in the redis.")
end

-- 连接MySql，查询数据库是否存在该用户(用户password比对),如果存在则在redis设置一个key,否则登录失败 
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
local select_sql = "select uno, email , password from user where email = \'"..kvargs['email'].."\' and password = \'"..kvargs['password'].."\';;"  
--ngx.say(select_sql)
res, err, errno, sqlstate = db:query(select_sql)

if not res then
   --ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
   ngx.redirect('/status?message=Query-Mysql-Failed'..err..errno..sqlstate)
   return
elseif #res == 0 then
   ngx.redirect('/status?message=Sign up failed')
   return
elseif #res > 1 then
   ngx.redirect('/status?message=System Error')
   return

elseif #res == 1 then 
        -- 向Redis中设置一个键值对
        local set_res, err = red:set( kvargs.email, kvargs.password )
        if not set_res then
            ngx.say("set key-value failed: ", err)
            --ngx.redirect('/status?message=Set Key value failed')
            return
        end
         
        -- 从Redis中获取一个键的值
        --[[local get_res, err = red:get("mykey")
        if not get_res then
            ngx.say("获取键的值失败: ", err)
            return
        end
         
        -- 输出获取到的值
        ngx.say("获取到的值为: ", get_res)
        --]] 
        -- 关闭Redis连接（重要！）
end
local close_res, err = red:close()
if not close_res then
    --ngx.say("关闭Redis连接失败: ", err)
    ngx.redirect('/status?message=关闭Redis连接失败')
    return
end