local android = require("android")
local Device = require("device")
local InputContainer = require("ui/widget/container/inputcontainer")
local DictQuickLookup = require("ui/widget/dictquicklookup")
local _ = require("gettext")

local AskGPT = InputContainer:new {
  name = "askeinkbro",
  is_doc_only = true,
}

local doExternalDictLookup = function (self, text, method, callback)
  external.when_back_callback = callback
  local _, app, action = external:checkMethod("dict", method)
  if action then
      android.dictLookup(text, app, action)
  end
end

function AskGPT:init()
  self.ui.highlight:addToHighlightDialog("askeinkbro", function(this)
    return {
      text = _("Query EinkBro"),
      enabled = yes,
      callback = function()
        android.dictLookup(this.selected_text.text, "info.plateaukao.einkbro", "text")
        this:onClose()
      end,
    }
  end)
  Device.doExternalDictLookup = doExternalDictLookup
  local originalTweakButtonsFunc = DictQuickLookup.tweak_buttons_func
  DictQuickLookup.tweak_buttons_func = function(obj, buttons)
    if originalTweakButtonsFunc then originalTweakButtonsFunc(obj, buttons) end
    local isButtonInserted = false
    for _, button in ipairs(buttons) do
        if button.text == "Query Eudic" then
            isButtonInserted = true
            break
        end
    end
    if not isButtonInserted and not obj.is_wiki then
      table.insert(buttons, {
          {
              text = "Query Eudic",
              enabled = true,
              callback = function()
                android.dictLookup(obj.word, "com.eusoft.eudic", "text")
                obj:onClose()
              end,
          }
      })
    end
  end
end

return AskGPT
