local copy ={}

-- 要复制的源目录和目标目录
local source_dir = "D:/openresty-1.25.3.1-win64/example"
local target_dir = "D:/openresty-1.25.3.1-win64/site.enable"
local key = "success"
-- 替换变量
local newname
local server_name
local listen
local template_name


local function copy_files(source_dir, target_dir)
    -- 使用 shell 命令获取源目录下的所有文件列表
    local cmd = 'ls -p "' .. source_dir .. '" | grep -v /'
    -- io.popen 函数是 Lua 提供的一个函数，用于执行操作系统的命令，并返回一个文件对象来读取该命令的输出
    local files = io.popen(cmd):read("*a")
    for file in string.gmatch(files, "[^\r\n]+") do
        local source_file = source_dir .. "/" .. file
        local target_file = target_dir .. "/" .. file
        local f_source = io.open(source_file, "rb")
        if not f_source then
            ngx.log(ngx.ERR, "Failed to open source file ", source_file)
            key = "fail"
        else
            local f_target = io.open(target_file, "wb")
            if not f_target then
                ngx.log(ngx.ERR, "Failed to open target file ", target_file)
                f_source:close()
                key = "fail"
            else
                local content = f_source:read("*all")
                f_target:write(content)
                f_source:close()
                f_target:close()
            end
        end
    end

    ngx.say("file copy ",key)

end

-- 执行复制操作
copy_files(source_dir, target_dir)

return copy