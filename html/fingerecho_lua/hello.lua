-- str = "email=283285356%40qq.com&telephone=17520092105&password=fkc%3E%3E%3Escs%21"
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

a = 'email=283285356%40qq.com&telephone=17520092105&password=fkc%3E%3E%3Escs%21'
a = unescape(a)
test = Split(a, '&')

local res = {}
for i,j in pairs(test) do 
    m = Split(j,'=')
    res[m[1]] = m[2]
end
print(res['password'])
