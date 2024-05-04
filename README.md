# openresty + lua 配置文件自动生成
## 访问地址
[https://gitee.com/yl166490/autoconf](https://gitee.com/yl166490/autoconf)
## 关注内容
| 文件夹名 | 角色 |
| --- | --- |
| lua.script | 存放lua脚本 |
| site.enable | 存放nginx配置文件 |
| example | 模版存放 |

| 文件名 | 所属文件夹 | 角色 |
| --- | --- | --- |
| action_conf.lua | lua.script | lua脚本 |
| copy.lua | lua.script | lua脚本 |
| git.lua | lua.script | lua脚本 |
| test.conf | site.enable | nginx配置文件 |


## Lua脚本的配置
nginx.conf
```lua
#填入lua脚本路径
lua_package_path "/xxx/xx/?.lua;;";
```
```lua

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    lua_package_path "D:/openresty-1.25.3.1-win64/lua.script/?.lua;;";
    include       D:/openresty-1.25.3.1-win64/site.enable/*.conf;
    include       D:/openresty-1.25.3.1-win64/upstream/*.conf;
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}

```
test.conf
```lua
server {
    # 监听80端口
    listen 8099;

    location / {
        default_type text/plain;
        content_by_lua_file D:/openresty-1.25.3.1-win64/lua.script/action_conf.lua;
    }


    location /copy {
        default_type text/plain;
        content_by_lua_file D:/openresty-1.25.3.1-win64/lua.script/copy.lua;
    }

    location /git_push {
        default_type text/plain;
        content_by_lua_block {
        local git  = require("git")
        git:pullCommand()
        ngx.say(git:addCommand())
        ngx.say("git staging files:\n")
        ngx.say(git:diffCommand())
        ngx.say("\n")
        ngx.say("git commit result:\n")
        ngx.say(git:commitCommand())
        ngx.say("\n")
        git:pushCommand()
    }
    }
}
```
## 配置文件新增使用说明
> 配置文件的创建原理是读取url中的键值对信息

**参数解读**
操作例如**：**[http://127.0.0.1:8099/service_name=go_track/server_name=go.ttpai.cn/kube_name=k1/template_number=001/env_name=com](http://127.0.0.1:8099/action/newfile_name=test2.conf/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/kube_name=k1/template_number=001/env_name=com)

**键值对信息**：
必须输入

| key | value（例） | 角色 | 约束 |
| --- | --- | --- | --- |
| service_name | xxx_boss | 应用名 | 必须“xx_xxx”格式 |
| server_name | xx.ttpai.cn | 老域名 | 无 |
| env_name | xyz/top/fun | 环境 | 无 |


选择输入

| key | value（例） | 角色 | 约束 |
| --- | --- | --- | --- |
| listen_num | 8080 | nginx监控端口 | 数字 |
| kube_name | k1 | 转发的k8s集群名称 | 无 |
| proxy_pass_name | 192.179.22.22 | 自定义的转发后端 | 套接字 |
| ssl | false | 开启ssl转发 | 布尔型 |


**语法**
```lua
使用说明（默认证书为boss证书，证书需求，修改模版即可）

生成无ssl的conf
http://127.0.0.1:8099/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/kube_name=k1/template_number=001/env_name=com
生成有ssl的conf
http://127.0.0.1:8099/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/kube_name=k1/template_number=001/env_name=com/ssl=true
生成无ssl且转发至自定义后端的的conf
http://127.0.0.1:8099/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/template_number=001/env_name=top/proxy_pass_name=111.111.111.111
生成有ssl且转发至自定义后端的的conf
http://127.0.0.1:8099/service_name=go_track/server_name=go.ttpai.cn/listen_num=8888/template_number=001/env_name=top/proxy_pass_name=111.111.111.111/ssl=true
```

**图解**
配置文件生成目录  “site.enable”
![1714810787633.png](https://cdn.nlark.com/yuque/0/2024/png/39165256/1714810790501-378fce3d-76d3-41fd-a061-0604628572ab.png#averageHue=%231e1c1a&clientId=u20f75272-4788-4&from=paste&height=246&id=uf3e945ce&originHeight=369&originWidth=351&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=24727&status=done&style=none&taskId=ub5915371-8c3a-4ff8-ba70-2e12cdb4998&title=&width=234)
lua脚本存放目录  “lua.script”
![1714810897439.png](https://cdn.nlark.com/yuque/0/2024/png/39165256/1714810900194-4058dd67-b76f-4b08-a66c-f4706eb6b6db.png#averageHue=%231d1b1a&clientId=u20f75272-4788-4&from=paste&height=227&id=u3c8df726&originHeight=340&originWidth=379&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=17414&status=done&style=none&taskId=u92a348d6-7922-4d12-9491-7cb47b7222f&title=&width=252.6666717529297)
web端回显案例
![1714811071019.png](https://cdn.nlark.com/yuque/0/2024/png/39165256/1714811078446-d93ced80-b378-4465-8a73-83e5b1cba5fc.png#averageHue=%23fdfcfb&clientId=u20f75272-4788-4&from=paste&height=1010&id=u6cfcbfe0&originHeight=1515&originWidth=1593&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=207697&status=done&style=none&taskId=u3eb58407-1ae4-492d-a8b8-824f3831ac4&title=&width=1062)

**生成配置文件案例**
abo-track.ttpai.com.conf
```lua
server {

    listen 80;
    server_name abo.ttpai.cn;
    proxy_set_header Host   abo-track.ttpai.com;
    proxy_pass_request_headers on;

#    location / {
#        proxy_pass http://upstream_kubernetes_k1_ingress;
#    }

     if ($server_port != '443' ) {
        rewrite ^/(.*)$ https://$host/$1 permanent;
     }

}


server {
    #HTTPS的默认访问端口443。
    #如果未在此处配置HTTPS的默认访问端口，可能会造成Nginx无法启动。
    listen 443 ssl;

    #填写证书绑定的域名
    server_name abo.ttpai.cn;
    proxy_set_header Host   abo-track.ttpai.com;

    #填写证书文件绝对路径
    ssl_certificate D:/openresty-1.25.3.1-win64/cert/fullchain1.pem;
    #填写证书私钥文件绝对路径
    ssl_certificate_key D:/openresty-1.25.3.1-win64/cert/privkey1.pem;

    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout 5m;

    #自定义设置使用的TLS协议的类型以及加密套件（以下为配置示例，请您自行评估是否需要配置）
    #TLS协议版本越高，HTTPS通信的安全性越高，但是相较于低版本TLS协议，高版本TLS协议对浏览器的兼容性较差。
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;

    #表示优先使用服务端加密套件。默认开启
    ssl_prefer_server_ciphers on;

    #转发所有的请求头
    proxy_pass_request_headers on;

    location / {
        proxy_pass http://upstream_kubernetes_k1_ingress;
    }
}

```


## git操作
> git的提交消息是读取url中的键值对信息

**键值对信息**：

| key | value（例） | 角色 | 约束 |
| --- | --- | --- | --- |
| commit | first commit | git commit 提交信息 | 英文（目前不支持utf8） |

**语法**
```lua
http://127.0.0.1:8099/git_push/commit=first commit
```

**图解**
web回显
![1714811367583.png](https://cdn.nlark.com/yuque/0/2024/png/39165256/1714811372347-2d8b3e7d-55a1-4f3a-bc64-339c0dff2001.png#averageHue=%23fcfbfa&clientId=u20f75272-4788-4&from=paste&height=505&id=ua00479a0&originHeight=757&originWidth=733&originalType=binary&ratio=1.5&rotation=0&showTitle=false&size=55935&status=done&style=none&taskId=u23eb1c9d-36e7-4585-9c8c-3d62cf334e5&title=&width=488.6666666666667)

## 自定义部分
**新增配置文件**
自定义模版conf存放目录与配置文件生成目录，修改位置如下
```lua
lua.script > action_conf.lua
============================
-- 要复制的源目录和目标目录（修改自定义的路径即可）
local source_dir = "D:/openresty-1.25.3.1-win64/example"
local target_dir = "D:/openresty-1.25.3.1-win64/site.enable"
```


**git推送**
自定义git信息（如账号密码）
```lua
lua.script > git.lua
===========================
--如未配置免密，git需要配置账号密码在executeGitCommand函数参数中
--如：
-- 执行git pull
function git:pullCommand()
local Result = executeGitCommand("git pull origin master")
return Result
end
```



