-- 如未配置免密，git需要配置账号密码在executeGitCommand中

local git ={}
local current_time = os.time()
local formatted_time = os.date("%Y-%m-%d %H:%M:%S", current_time)

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
local commit_message = "lua提交创建配置文件 - " .. formatted_time
local Result = executeGitCommand("git commit -m '".. commit_message .."'")
return Result
end

-- 示例操作：执行git push
function git:pushCommand()
local Result = executeGitCommand("git push origin master")
return Result
end

return git