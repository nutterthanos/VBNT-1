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
  radio_5G_enabled = "rpc.wireless.radio.@radio_5G.admin_state",
  ssid_5G = "rpc.wireless.ssid.@wl1.ssid",
  ap_5G_broadcast = "rpc.wireless.ap.@ap2.public",
}

local mapValid = {
  radio_5G_enabled = vB,
  ap_5G_broadcast = vB,
  ssid_5G = gVSLIR(1,32),
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
      ');  ngx.print("<legend>" .. T"Step 5 of 8" .. "</legend>"); ngx.print('\
      ');  ngx.print( "<h4>" .. T"WiFi Setup (5GHz)" .. "</h4>"); ngx.print('\
      ');  
        local html = {}
        local info_attr = {
            alert = {
                class = "alert-info"
            },
         }
        html[#html+1] = ui_helper.createAlertBlock(T"Your modem already has a unique WiFi network set up by default. You can change the broadcast name here if desired, or turn off WiFi completely. You can also hide your WiFi network name from other devices by turning off SSID broadcast.", info_attr)
        html[#html+1] = ui_helper.createMessages(message_helper.popMessages())
        html[#html+1] = ui_helper.createSwitch(T"Wireless 5GHz (WiFi):", "radio_5G_enabled", content["radio_5G_enabled"], nil, helpmsg["radio_5G_enabled"])
        html[#html+1] = ui_helper.createSwitch(T"SSID Broadcast:", "ap_5G_broadcast", content["ap_5G_broadcast"], nil, helpmsg["ap_5G_broadcast"])
        html[#html+1] = ui_helper.createInputText(T"SSID Broadcast Name (Max 32 characters):", "ssid_5G", content["ssid_5G"], nil, helpmsg["ssid_5G"])
        ngx.print(html)
        ngx.print('\
    </fieldset>\
</div>\
<div class=\'wizard-confirm\'>\
    <fieldset>\
      ');  
        local html = {}
        html[#html+1] = ui_helper.createLabel(T"Wireless 5GHz (WiFi): ", bool2on[format("%s",content["radio_5G_enabled"])])
        html[#html+1] = ui_helper.createLabel(T"SSID Broadcast: ", bool2enable[format("%s",content["ap_5G_broadcast"])])
        html[#html+1] = ui_helper.createLabel(T"SSID Broadcast Name: ", content["ssid_5G"])
        ngx.print(html)
        ngx.print('\
    </fieldset>\
</div>\
'); 