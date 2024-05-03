local git ={}


-- 执行git pull
function git:pullCommand()
local pullResult = executeGitCommand("git pull origin master")
end


-- 执行git add
function git:addCommand()
local addResult = executeGitCommand("git add .")
end

-- 执行git commit
function git:commitCommand()
local commitResult = executeGitCommand("git commit -m 'lua提交创建配置文件'")
end

-- 示例操作：执行git push
function git:pushCommand()
local pushResult = executeGitCommand("git push origin master")
end

return git