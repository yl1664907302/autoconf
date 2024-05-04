-- 如未配置免密，git需要配置账号密码在executeGitCommand中

local git ={}

-- 获取url的路径存入table
local uri = ngx.var.uri
local args = {}
for part in uri:gmatch("/([^/]+)") do
    local key, value = part:match("([^=]+)=([^/]+)")
    if key and value then
        args[key] = value
    else
        table.insert(args, part)
    end
end

-- 提取commit信息
local commit_message =  args["commit"]

-- 操作命令
function executeGitCommand(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

-- 执行git pull
function git:pullCommand()
local Result = executeGitCommand("git pull origin master")
return Result
end


-- 执行git add
function git:addCommand()
local Result = executeGitCommand("git add .")
return Result
end

-- 执行git add
function git:diffCommand()
local Result = executeGitCommand("git diff --cached --name-only")
return Result
end

-- 执行git commit
function git:commitCommand()
local Result = executeGitCommand("git commit -m" .. commit_message)
return Result
end

-- 示例操作：执行git push
function git:pushCommand()
local Result = executeGitCommand("git push origin master")
ngx.say("git push result: ok \n")
end

return git