--pretranslated: do not change this file
 
-- The card is shown, even if the modal is not accessible
gettext.textdomain('webui-core')

local modal = '/modals/assistance-modal.lp'

local format = string.format
local ngx = ngx

local session = ngx.ctx.session
local admin = session:hasAccess(modal)

local ui_helper = require 'web.ui_helper'

local assistance = require 'web.assistance'
local assistant = assistance.getAssistant('remote')

if assistant then
    local content
    local state
    if assistant:enabled() then
        state = "1"
        local light = ui_helper.createSimpleLight(state, T"Enabled")
        if admin then
            local url = assistant:URL()
            if url then
                local password = assistant:password()
                if password == "" then
                     password = "********"
                end
                content = {
                    light,'<br/>',
                    T"URL:",format(' <strong id="port">%s</strong>', url),'<br/>',
                    T"Username:",format(' <strong id="username">%s</strong>', assistant:username()),"<br/>",
                    T"Password:", format(' <strong id="password">%s</strong>', password),
                }
            else
                content = {
                    light, '<br/>',
                    T"There is no connection to the Internet."
                }
            end
        else
            content = {light}
        end
    else
        state = "0"
        content = {
            ui_helper.createSimpleLight(state, T"Disabled")
        }
    end
  ngx.print('\
<div class="span3">\
  <div class="smallcard">\
    ');  if admin then
        ngx.print(ui_helper.createCardHeader(T"Assistance", modal, 'ra_enabled', state, {input = {id = "assistance_card_enable"}}))
    else
        ngx.print(ui_helper.createCardHeader(T"Assistance"))
    end   ngx.print('\
    <div class="content">\
        ');  ngx.print( content ); ngx.print('\
    </div>\
  </div>\
</div>\
');  end   ngx.print('\
'); 