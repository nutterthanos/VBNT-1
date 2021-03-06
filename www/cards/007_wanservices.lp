--pretranslated: do not change this file
 
-- Enable localization
gettext.textdomain('webui-core')

local format = string.format
local ngx = ngx
local proxy = require("datamodel")
local ui_helper = require("web.ui_helper")
local content_helper = require("web.content_helper")
local dynDns_attributes = {
	light = { id = "DynDNS_Status_Led" },
	span = { class = "span4",
	id = "DynDNS_Status"}
}

local dmz_attributes = {
	light = { id = "DMZ_Status_Led" },
	span = { class = "span4",
	id = "DMZ_Status"}
}

-- WAN services data
local wan_services_data = {
  dmz_enable = "rpc.network.firewall.dmz.enable",
  dmz_blocked = "rpc.network.firewall.dmz.blocked",
  upnp_rules = "sys.upnp.RedirectNumberOfEntries",
}
content_helper.getExactContent(wan_services_data)

local ddns_ipv4_path = "uci.ddns.service.@myddns_ipv4.enabled"
local ddns_ipv6_path = "uci.ddns.service.@myddns_ipv6.enabled"

local function get_ddns_enabled(path)
  local enabled
  local ddns_enable_table = proxy.get(path)

  if ddns_enable_table then
    for _, param in ipairs(ddns_enable_table) do
      enabled = param.value
    end
  end
  return enabled
end

local ddns_ipv4_enabled = get_ddns_enabled(ddns_ipv4_path)
local ddns_ipv6_enabled = get_ddns_enabled(ddns_ipv6_path)

local ddns_enabled = "0"
if ddns_ipv4_enabled == "1" or ddns_ipv6_enabled == "1" then
  ddns_enabled = "1"
elseif ddns_ipv4_enabled == nil and ddns_ipv6_enabled == nil then
  ddns_enabled = nil
end

local ddns_light_map = {
  ["0"] = "0",
  ["1"] = "1",
}

local ddns_enabled_map = {
  ["0"] = T"DynDNS disabled",
  ["1"] = T"DynDNS enabled",
  [""] = T"DynDNS disabled",
}

local state
local dmzstate
if wan_services_data["dmz_blocked"] == "1" then
  dmzstate = T"DMZ blocked"
  state = "0"
else
  if wan_services_data["dmz_enable"] == "1" then
    dmzstate = T"DMZ enabled"
    state = "1"
  else
    dmzstate = T"DMZ disabled"
    state = "0"
  end
end

local pf_path = proxy.get("rpc.network.firewall.portforward.")
local pf_data = content_helper.convertResultToObject("rpc.network.firewall.portforward.",pf_path)
local pf_rule_len = {}
for _,v in ipairs(pf_data) do
  if v.src == "wan" and v.dest == "lan" then
    pf_rule_len[#pf_rule_len+1] = 1
  end
end

local n_redir_rules = #pf_rule_len
local n_upnp_rules = tonumber(wan_services_data["upnp_rules"]) or 0
local modalPath = nil
local switchName = nil
local modal_link_port  = ""
local modal_link_upnp = ""
local session = ngx.ctx.session
if session:hasAccess("/modals/wanservices-modal.lp") then
  modalPath = "/modals/wanservices-modal.lp"
  modal_link_port = 'class="modal-link" id="PortForwarding_Id" data-toggle="modal" data-remote="modals/wanservices-modal.lp" data-id="wanservices-modal"'
  modal_link_upnp = 'class="modal-link" id="upnp_Id" data-toggle="modal" data-remote="modals/wanservices-modal.lp" data-id="wanservices-modal"'
elseif not session:isdefaultuser() then
  return
end
  ngx.print('\
\
<div class="span3">\
  <div class="smallcard">\
\
    ');  ngx.print( ui_helper.createCardHeader(T"WAN Services", modalPath, switchName, nil) ); ngx.print('\
\
    <div class="content">\
    ');  
        ngx.print(ui_helper.createSimpleLight(state, dmzstate, dmz_attributes))
        if ddns_enabled then
          ngx.print(ui_helper.createSimpleLight(ddns_light_map[format("%s", ddns_enabled)] or "0", ddns_enabled_map[format("%s", ddns_enabled)], dynDns_attributes))
        end
        ngx.print(
            '<p></p>',
            '<p class="subinfos">',
            format( N("<strong %s>%d port forwarding</strong> rule is defined",
                      "<strong %s>%d port forwarding</strong> rules are defined", n_redir_rules),
                      modal_link_port, n_redir_rules),
	    '<br/>',
            format( N("<strong %s>%d UPnP</strong> rule is active",
                      "<strong %s>%d UPnP</strong> rules are active", n_upnp_rules),
                      modal_link_upnp, n_upnp_rules),
            '</p>'
        )
      ngx.print('\
    </div>\
  </div>\
</div>\
'); 