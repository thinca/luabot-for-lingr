_G.string = require('string')
_G.table = require('table')
_G.math = require('math')
_G.os = { date = require('os').date }


local string = require('string')
local table = require('table')
local http = require("http")
local json = require("json")

local env = {}
function getevalenv(name)
  if not env[name] then
    env[name] = {}
  end
  local global = env[name]
  for k, v in pairs(_G) do
    global[k] = v
  end
  global._G = global
  return global
end
local function eval(body)
  local template = table.concat({
    'local _G = {}',
    'local require = nil',
  }, "\n") .. "\n"
  local f, err = loadstring(template .. "return " .. body)
  if not f then
    f, err = loadstring(template .. body)
  end
  if f then
    return tostring(f())
  end
  return err
end

http.createServer(function (req, res)
  if req.method == 'GET' then
    res:finish('LuaBot for Lingr')
    return
  end
  req:on('data', function (data)
    local result = ''
    for i, event in pairs(json.parse(data).events) do
      local mes = event.message
      local body = select(3, string.find(mes.text, '^!lua%s(.*)'))
      if body then
        print('---')
        print(os.date())
        print(mes.nickname)
        print(body)
        local success, r = pcall(eval, body)
        if success and r then
          result = result .. r
        end
      end
    end
    res:writeHead(200, {
      ["Content-Type"] = "text/plain",
      ["Content-Length"] = #result
    })
    res:finish(result)
  end)
end):listen(10000)

print("Server listening at http://localhost:10000/")
