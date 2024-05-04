-- 使用说明（默认证书为boss证书，证书需求，修改模版即可）

-- 生成无ssl的conf
-- http://127.0.0.1:8099/action/newfile_name=test2.conf/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/kube_name=k1/template_number=001/env_name=com
-- 生成有ssl的conf
-- http://127.0.0.1:8099/action/newfile_name=test2.conf/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/kube_name=k1/template_number=001/env_name=com/ssl=true
-- 生成无ssl且转发至自定义后端的的conf
-- http://127.0.0.1:8099/action/newfile_name=test2.conf/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/template_number=001/env_name=top/proxy_pass_name=111.111.111.111
-- 生成有ssl且转发至自定义后端的的conf
-- http://127.0.0.1:8099/action/newfile_name=test2.conf/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/template_number=001/env_name=top/proxy_pass_name=111.111.111.111/ssl=true

local action_conf ={}

-- 定义替换变量
local newname
local service=""
local server_name=""
local env_name=""
local new_server_name=""
local listen=""
local template_number=""
local ssl=false
local update_domain=false
local kube_name
local proxy_pass_name=""

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

-- 变量赋值
 template_number =args["template_number"]
 service = args["service_name"]
 server_name = args["server_name"]
 listen = args["listen_num"]
 env_name = args["env_name"]
 update_domain = false
 kube_name = args["kube_name"]
 proxy_pass_name = args["proxy_pass_name"]
 ssl = args["ssl"]


if  kube_name then
    update_domain = true
end

-- for key, value in pairs(args) do
--     ngx.say("Key: ", key, ", Value: ", value)
-- end
-- ngx.say("Value: ",args["server_name"])


-- 要复制的源目录和目标目录（修改自定义的路径即可）
local source_dir = "D:/openresty-1.25.3.1-win64/example"
local target_dir = "D:/openresty-1.25.3.1-win64/site.enable"
local key = "success"


-- 替换关键词
function replace_word(new_file,old_word,new_word)
    local r_file = io.open(new_file,"rb")
    local old_content = r_file:read("*a")
    r_file.close()

    local new_content = string.gsub(old_content,old_word,new_word)

    local w_file = io.open(new_file,"wb")

    w_file:write(new_content)
    w_file:close()
end

-- 构造新域名
function make_newhost(service_name,env_name)
    local newStr = string.gsub(service_name, "_", "-") .. ".ttpai." .. env_name
    return newStr
end


-- ssl配置
function ssl_action(content,key)
    if key == 1 then
    local replaced_text = content:gsub("\n##", "\n")
    return replaced_text
    end

    local replaced_text = content:gsub("\n#", "\n")
    return replaced_text
end


-- 生成新文件
function copy_files(source_dir, target_dir,ssl_key)
        local source_file = source_dir .. "/" .. template_number .. "---template.conf"
        newname = make_newhost(service,env_name) .. ".conf"
        local target_file = target_dir .. "/" .. newname
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
                if ssl then
                -- 进行文本替换
                f_target:write(ssl_action(content,1))
                else
                f_target:write(ssl_action(content,0))
                end

                f_source:close()
                f_target:close()
            end
        end

    -- 替换关键信息
    replace_word(target_file,"www",server_name)
    replace_word(target_file,"80",listen)


    -- 判断是否需要更换域名
    if update_domain then
        -- 生成ingress访问域名
        replace_word(target_file,"kubename",kube_name)
        new_server_name = make_newhost(service,env_name)
        replace_word(target_file,"xxx",new_server_name)
    else
        replace_word(target_file,"xxx","$host")
        replace_word(target_file,"upstream_kubernetes_kubename_ingress",proxy_pass_name)
    end


    -- 回显
    ngx.say("2. conf create ",key)
end


-- 验证配置文件是否有效
function vali_conf()
    local result = os.execute("D:/openresty-1.25.3.1-win64/nginx.exe  -t")
    if result then
    ngx.say("3. conf verify success")
    return true
    else
    ngx.say("3. conf verify fail")
    return false
    end
end

-- 执行配置nginx重载配置文件
function reload_conf()
   local result = os.execute("D:/openresty-1.25.3.1-win64/nginx.exe  -s reload")
   if result then
    ngx.say("4. conf relaod success")
    return true
    else
    ngx.say("4. conf relaod fail")
    return false
    end
end

-- 配置文件生成前git pull
function pull_git()
   local git  = require("git")
   local message = git:pullCommand()
   ngx.say("1. conf pull result is :",message)
end

-- 配置文件生成后show
function show_conf()
   local target_file = target_dir .. "/" .. newname
   local f_target = io.open(target_file, "rb")
   if not f_target then
       ngx.log(ngx.ERR, "Failed to open source file ", source_file)
       key = "fail"
   end
   local content = f_target:read("*all")
   ngx.say("5. conf is :\n")
   ngx.say("\n")
   ngx.say(content)
end

-- 执行操作
ngx.say("Please visit the URL below to complete the git commit: /git_push \n")
pull_git()
copy_files(source_dir, target_dir,ssl)
if vali_conf()then
   reload_conf()
   show_conf()
end
return action_conf