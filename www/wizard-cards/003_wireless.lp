--pretranslated: do not change this file
 
-- Enable localization
gettext.textdomain('webui-wizard')

local ui_helper = require("web.ui_helper")
local message_helper = require("web.uimessage_helper")
local wizard_helper = require("wizard")
local post_helper = require("web.post_helper")
local gVSLIR = post_helper.getValidateStringLengthInRange
local vB = post_helper.validateBoolean
local format = string.format

local mapParams = {
  radio_enabled = "rpc.wireless.radio.@radio_2G.admin_state",
  ssid = "rpc.wireless.ssid.@wl0.ssid",
  ap_broadcast = "rpc.wireless.ap.@ap0.public",
}

local mapValid = {
  radio_enabled = vB,
  ap_broadcast = vB,
  ssid = gVSLIR(1,32),
}

local content, helpmsg = wizard_helper.handleQuery(mapParams, mapValid)

local bool2on = {
  ["1"] = "On",
  ["0"] = "Off"
}

local bool2enable = {
  ["1"] = "Enabled",
  ["0"] = "Disabled"
}
  ngx.print('\
<div class=\'wizard-card\'>\
    <fieldset>\
      ');  ngx.print("<legend></legend>"); ngx.print('\
      ');  ngx.print( "<h4>" .. T"WiFi Setup (2.4GHz)" .. "</h4>"); ngx.print('\
      ');  
        local html = {}
        local info_attr = {
            alert = {
                class = "alert-info"
            },
         }
        html[#html+1] = ui_helper.createAlertBlock(T"Your modem already has a unique WiFi network set up by default. You can change the broadcast name here if desired, or turn off WiFi completely. You can also hide your WiFi network name from other devices by turning off SSID broadcast.", info_attr)
        html[#html+1] = ui_helper.createMessages(message_helper.popMessages())
        html[#html+1] = ui_helper.createSwitch(T"Wireless 2.4GHz (WiFi):", "radio_enabled", content["radio_enabled"], nil, helpmsg["radio_enabled"])
        html[#html+1] = ui_helper.createSwitch(T"SSID Broadcast:", "ap_broadcast", content["ap_broadcast"], nil, helpmsg["ap_broadcast"])
        html[#html+1] = ui_helper.createInputText(T"SSID Broadcast Name (Max 32 characters):", "ssid", content["ssid"], nil, helpmsg["ssid"])
        ngx.print(html)
        ngx.print('\
    </fieldset>\
</div>\
<div class=\'wizard-confirm\'>\
    <fieldset>\
      ');  
        local html = {}
        html[#html+1] = ui_helper.createLabel(T"Wireless 2.4GHz (WiFi): ", bool2on[format("%s",content["radio_enabled"])])
        html[#html+1] = ui_helper.createLabel(T"SSID Broadcast: ", bool2enable[format("%s",content["ap_broadcast"])])
        html[#html+1] = ui_helper.createLabel(T"SSID Broadcast Name: ", content["ssid"])
        ngx.print(html)
        ngx.print('\
    </fieldset>\
</div>\
'); 