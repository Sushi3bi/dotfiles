-- Constants
MODIFIERS = { "ctrl", "cmd" } -- Modifiers used for app shortcuts

-- App configuration
APPS = {
    { shortcut = "1", name = "Ghostty" },
    { shortcut = "2", name = "Safari" },
    { shortcut = "3", name = "Reeder" },
    { shortcut = "4", name = "Google Chrome" },
    { shortcut = "5", name = "Finder" },
    { shortcut = "7", name = "Slack" },
    { shortcut = "8", name = "Outlook" },
    { shortcut = "9", name = "Zed" },
}

-- Toggle focus: if app is frontmost, hide it; otherwise launch/focus
local function toggleApp(name)
    local app = hs.application.get(name)
    if app and app:isFrontmost() then
        app:hide()
    else
        hs.application.launchOrFocus(name)
    end
end

-- Bind application shortcuts
for _, app in ipairs(APPS) do
    hs.hotkey.bind(MODIFIERS, app.shortcut, function()
        toggleApp(app.name)
    end)
end
