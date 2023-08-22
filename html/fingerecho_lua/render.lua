local template = require "resty.template"
-- 1. template.new
-- --local view = template.new "view.html"
-- --view.message = "Hello, World!"
-- --view:render()
--
-- -- 2. template.render
local kvargs = ngx.req.get_uri_args()
template.render("status.html", { message = kvargs.message })
--
-- -- 3.template.compile
-- --编译得到一个lua函数
--local func = template.compile("view.html")
--local world    = func{ message = "Hello, World!" }
-- --执行函数，得到渲染之后的内容
--local content = func(context)
--ngx.say(content, world)
