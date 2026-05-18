local uci = require "luci.model.uci".cursor()
m = Map("ycustlogin", translate("校园网自动认证"), translate("银川科技学院 (YCUST) 校园网自动认证插件。断线自动检测并重连。"))
s = m:section(TypedSection, "ycustlogin", translate("基本设置"))
s.anonymous = true

e = s:option(Flag, "enable", translate("启用"))
e.rmempty = false

u = s:option(Value, "username", translate("认证账号"))
u.rmempty = false

p = s:option(Value, "password", translate("认证密码"))
p.password = true
p.rmempty = false

t = s:option(Value, "check_interval", translate("检测间隔 (秒)"))
t.default = "60"
t.datatype = "uinteger"
t.rmempty = false

return m

