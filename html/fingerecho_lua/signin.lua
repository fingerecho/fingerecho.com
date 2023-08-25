local mysql = require "resty.mysql"

require "utils"


---ngx.say(res['password'])
-- 查询数据库是否存在该用户，若不存在则将 email telephone password 存入数据库

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
