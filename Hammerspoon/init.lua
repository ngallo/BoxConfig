-----------------------------------------------
-- Set up
-----------------------------------------------

local hyper = {"alt", "cmd"};
local grid = require "hs.grid";
local appFinder = require "hs.appFinder";
local logger = require "hs.logger";
local console = logger.new('init', 'debug');

grid.GRIDWIDTH  = 4
grid.GRIDHEIGHT = 2
grid.MARGINX    = 0
grid.MARGINY    = 0
grid.fullScreen  = {x=0, y=0, w=grid.GRIDWIDTH, h=grid.GRIDHEIGHT};
grid.leftHalf    = {x=0, y=0, h=2, w=2};
grid.rightHalf   = {x=2, y=0, h=2, w=2};
grid.topRight    = {x=2, y=0, h=1, w=2};
grid.bottomRight = {x=2, y=1, h=1, w=2};
grid.bottomLeft  = {x=0, y=1, h=1, w=2};
grid.topLeft     = {x=0, y=0, h=1, w=2};
grid.center      = {x=1, y=0, h=2, w=2};
hs.window.animationDuration = 0
local gridcache = {};

-----------------------------------------------
-- Reload config on write
-----------------------------------------------
function reload_config(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Hammerspoon\nConfig loaded")

------
-- Maximumise current window in next screen or toggle back to previous position
------
function toggleAltScreen()
    local win = hs.window.focusedWindow()
    local cPos = grid.get(win)
    local screens = hs.screen.allScreens()
    local winScreen = win:screen()
    local targetScreen = winScreen:next() or winScreen:previous();
    if cPos.h ~= grid.GRIDHEIGHT or cPos.w ~= grid.GRIDWIDTH then
        gridcache[win:id()] = grid.get(win);
        grid.set(win, {x = 0, y = 0, h = grid.GRIDHEIGHT, w = grid.GRIDWIDTH}, targetScreen);
    else
        local tPos = gridcache[win:id()] or cPos;
        grid.set(win, tPos, targetScreen);
    end
end

-- move current window to another screen
function moveCurrentScreen(direction)
    local win = hs.window.focusedWindow()
    if win then
        if direction == "left" then
            win:moveOneScreenWest();
        else
            win:moveOneScreenEast();
        end
    else
        hs.alert.show("No active window")
    end
end

-- move current window to grid positions
function moveCurrentGrid(pos)
    local win = hs.window.focusedWindow()
    if win then
        local screen = win:screen()
        grid.set(win, pos, screen)
    else
        hs.alert.show("No active window")
    end
end

-- change application focus. Wrapped in a function so can be used in bindingyy
function focus(app)
    return function()
        hs.application.launchOrFocus(app);
    end
end

-- change application screen. Wrapped in a function so can be used in bindingyy
function moveScreen(g)
    return function()
        moveCurrentScreen(g)
    end
end

-- change application grid location. Wrapped in a function so can be used in bindingyy
function moveGrid(g)
    return function()
        moveCurrentGrid(g);
    end
end

function setupModal()
    local modalKey = hs.hotkey.modal.new({"cmd", "shift"}, "j")
    modalKey.entered = function()
        local msg = [[   Mode
            T    Terminal
            V    MacVim
            B    Chrome
            E    Mail
        ]]
        hs.alert.show(msg)
    end
    modalKey.exited = function()  hs.alert.show('Exited modal')  end
    modalKey:bind({}, 'escape', function() modalKey:exit() end)
    return modalKey;
end

-- return a function that wull call f and then exit the mode
function exitModeWith(mode, f)
    return function()
        mode:exit();
        f();
    end
end

-- bind key to combo+key and to mode-key
function binder(key, combo, mode, f)
    if combo then
        hs.hotkey.bind(combo, key, f)
    end
    if mode then
        mode:bind({}, key, exitModeWith(mode, f));
    end
end

local modalKey = setupModal();


binder('e', hyper, modalKey, focus('Mail'));
binder('t', hyper, modalKey, focus('terminal'));
binder('v', nil,   modalKey, focus('MacVim'));
binder('v', hyper, modalKey, focus('MacVim'));
binder('w', hyper, modalKey, focus('Wunderlist'));
binder('s', hyper, modalKey, focus('Simplenote'));
binder('c', hyper, modalKey, focus('Pocket'));
binder('g', hyper, modalKey, focus('Telegram'));
binder('b', hyper, modalKey, focus('Google Chrome'));
binder('[', hyper, modalKey, moveGrid(grid.leftHalf));
binder(']', hyper, modalKey, moveGrid(grid.rightHalf));
binder('f', hyper, modalKey, moveGrid(grid.fullScreen));
binder('p', hyper, modalKey, moveGrid(grid.topRight));
binder('l', hyper, modalKey, moveGrid(grid.bottomRight));
binder('o', hyper, modalKey, moveGrid(grid.topLeft));
binder('k', hyper, modalKey, moveGrid(grid.bottomLeft));
binder('g', hyper, modalKey, moveGrid(grid.center));
binder("m", hyper, modalKey, toggleAltScreen);
binder('h', hyper, modalKey, hs.hints.windowHints);
binder('left', hyper, modalKey, moveScreen("left"));
binder('right', hyper, modalKey, moveScreen("right"));

function terminalWindowEvent(element, event)
end

-- install a hook to merge terminal windows
function terminalMergeHook(application)
    local terminalWatcher = application:newWatcher(function(element, event)
        console.d("Terminal: Element:" .. element:title() .. "\nEvent: " .. event);
        if(element:isStandard() == false) then
            return; -- dont hook prefs window or inspectors
        end
        if( application:isFrontmost() == false) then
            application:activate();
        end
        local windows = application:allWindows();
        for i,w in pairs(windows) do
            if(w:id() ~= element:id()) then
                w:becomeMain();
                break;
            end
        end
        application:selectMenuItem({"Window", "Merge All Windows"});
    end);
    local events = hs.uielement.watcher;
    terminalWatcher:start({events.windowCreated});
end

function appWatchEvent(name, event, application)
    --console.d("ApplicationEvent: " .. name .."(" .. event .. ")");
    if (event == hs.application.watcher.launched) then
        if (appName == "Terminal") then
            -- disabled for now
            --terminalMergeHook(application);
        end
    end
end

-- hook ui events in current or new terminal windows
function initWatcher()
    console:d("Initialising application watcher");
    local appWatcher = hs.application.watcher.new(appWatchEvent);
    appWatcher:start();
    local running = appFinder.appFromName("Terminal");
    if(running) then
        terminalMergeHook(running)
    end
    return appWatcher;
end

--appWatcher = initWatcher();

-- -- Manual grid function
-- function lefthalf()
--     if hs.window.focusedWindow() then
--         local win = hs.window.focusedWindow()
--         local f = win:frame()
--         local screen = win:screen()
--         local max = screen:frame()
--         f.x = max.x
--         f.y = max.y
--         f.w = max.w / 2
--         f.h = max.h
--         win:setFrame(f)
--     else
--         hs.alert.show("No active window")
--     end
-- end

