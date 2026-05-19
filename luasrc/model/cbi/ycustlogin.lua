local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

m = Map("ycustlogin", translate("校园网自动认证"), translate("银川科技学院 (YCUST) 校园网自动认证插件。断线自动检测并重连。"))
s = m:section(TypedSection, "ycustlogin", translate("基本设置"))
s.anonymous = true

-- 获取在线设备状态
local raw_html = ""
local res = sys.exec('curl -s -m 3 --interface phy0-sta0 "http://10.10.10.3/drcom/chkstatus?callback=dr1002" 2>/dev/null')

if res and res ~= "" then
    local olno_match = string.match(res, '"olno":(%d+)')
    local olip_match = string.match(res, '"olip":"(.-)"')
    local lip_match = string.match(res, '"lip":"(.-)"')
    local olmac_match = string.match(res, '"olmac":"(.-)"')
    
    if olno_match then
        local total = (olip_match and olip_match ~= "0.0.0.0") and 2 or 1
        local olip_text = (olip_match and olip_match ~= "0.0.0.0") and olip_match or "无"
        local lip_text = lip_match or "未知"
        
        -- 格式化 MAC 地址 (从 3802e30134d6 变成 38:02:e3:01:34:d6)
        local mac_text = "未知"
        if olmac_match and string.len(olmac_match) == 12 then
            mac_text = string.upper(string.sub(olmac_match,1,2)..":"..string.sub(olmac_match,3,4)..":"..string.sub(olmac_match,5,6)..":"..string.sub(olmac_match,7,8)..":"..string.sub(olmac_match,9,10)..":"..string.sub(olmac_match,11,12))
        elseif olmac_match then
            mac_text = olmac_match
        end
        
        raw_html = string.format([[
            <div style="background-color: #ffffff; border: 1px solid #e0e4e8; border-radius: 6px; padding: 20px; margin-bottom: 20px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                <div style="display: flex; justify-content: space-between; border-bottom: 1px solid #f0f2f5; padding-bottom: 12px; margin-bottom: 15px;">
                    <div style="font-size: 16px; font-weight: 600; color: #2c3e50;">
                        <span style="display: inline-block; width: 8px; height: 8px; background-color: #1ab394; border-radius: 50%%; margin-right: 6px;"></span>
                        账号状态：正常在线
                    </div>
                    <div style="font-size: 14px; color: #666;">
                        在线设备数：<span style="font-weight: bold; color: #f8ac59;">%d / 2</span>
                    </div>
                </div>
                
                <div style="display: flex; flex-direction: column; gap: 10px;">
                    <div style="display: flex; align-items: center; background-color: #f8f9fa; padding: 10px 15px; border-radius: 4px;">
                        <div style="flex: 1;">
                            <div style="font-size: 12px; color: #888; margin-bottom: 2px;">本机 (路由器)</div>
                            <div style="font-size: 14px; color: #333;">IP: <strong>%s</strong> <span style="margin: 0 8px; color: #ccc;">|</span> MAC: <strong>%s</strong></div>
                        </div>
                        <div style="color: #1ab394; font-size: 12px; font-weight: bold; padding: 2px 8px; border: 1px solid #1ab394; border-radius: 12px;">当前设备</div>
                    </div>
                    
                    <div style="display: flex; align-items: center; background-color: #fff3f3; padding: 10px 15px; border-radius: 4px; border: 1px dashed #f9cdcd;">
                        <div style="flex: 1;">
                            <div style="font-size: 12px; color: #888; margin-bottom: 2px;">其他在线终端</div>
                            <div style="font-size: 14px; color: #ed5565;">IP: <strong>%s</strong></div>
                        </div>
                        <div style="color: #ed5565; font-size: 12px; font-weight: bold;">占用中</div>
                    </div>
                </div>
            </div>
        ]], total, lip_text, mac_text, olip_text)
        
    elseif string.match(res, '"result":0') then
        raw_html = [[
            <div style="background-color: #ffffff; border: 1px solid #e0e4e8; border-radius: 6px; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                <div style="font-size: 16px; font-weight: 600; color: #ed5565;">
                    <span style="display: inline-block; width: 8px; height: 8px; background-color: #ed5565; border-radius: 50%; margin-right: 6px;"></span>
                    账号未登录或已掉线
                </div>
                <div style="margin-top: 8px; color: #666; font-size: 13px;">插件将在下一个检测周期尝试自动恢复...</div>
            </div>
        ]]
    else
        raw_html = [[
            <div style="background-color: #ffffff; border: 1px solid #e0e4e8; border-radius: 6px; padding: 20px; margin-bottom: 20px;">
                <div style="font-size: 16px; font-weight: 600; color: #f8ac59;">
                    <span style="display: inline-block; width: 8px; height: 8px; background-color: #f8ac59; border-radius: 50%; margin-right: 6px;"></span>
                    数据解析异常
                </div>
            </div>
        ]]
    end
else
    raw_html = [[
        <div style="background-color: #ffffff; border: 1px solid #e0e4e8; border-radius: 6px; padding: 20px; margin-bottom: 20px;">
            <div style="font-size: 16px; font-weight: 600; color: #999;">
                <span style="display: inline-block; width: 8px; height: 8px; background-color: #999; border-radius: 50%; margin-right: 6px;"></span>
                无法连接到校园网接口 (phy0-sta0)
            </div>
        </div>
    ]]
end

st = s:option(DummyValue, "_dashboard", "")
st.rawhtml = true
st.value = raw_html

e = s:option(Flag, "enable", translate("启用自动认证"))
e.rmempty = false

u = s:option(Value, "username", translate("认证账号"))
u.rmempty = false

p = s:option(Value, "password", translate("认证密码"))
p.password = true
p.rmempty = false

t = s:option(Value, "check_interval", translate("检测间隔 (秒)"))
t.default = "30"
t.datatype = "uinteger"
t.rmempty = false

btn = s:option(Button, "_force", translate("强制重新登录"), translate("点击后将立即注销当前连接，并重新发送认证请求。"))
btn.inputtitle = translate("立即执行")
btn.inputstyle = "apply"
function btn.write(self, section)
    sys.call("curl -s -m 3 --interface phy0-sta0 'http://10.10.10.3/drcom/logout?callback=dr1004' >/dev/null 2>&1")
    sys.call("sleep 1")
    local user = uci:get("ycustlogin", "main", "username")
    local pass = uci:get("ycustlogin", "main", "password")
    if user and pass then
        local url = string.format("http://10.10.10.3/drcom/login?callback=dr1004&DDDDD=%s&upass=%s&0MKKey=123456&R1=0&R2=&R3=0&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn&jsVersion=4.1.3&v=4359&lang=zh", user, pass)
        sys.call("curl -s -m 5 --interface phy0-sta0 '" .. url .. "' >/dev/null 2>&1")
    end
end

return m



