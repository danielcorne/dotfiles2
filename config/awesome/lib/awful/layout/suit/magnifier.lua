---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release debian/3.4.13-1
---------------------------------------------------------------------------

-- Grab environment we need
local ipairs = ipairs
local math = math
local tag = require("awful.tag")
local capi =
{
    client = client,
    screen = screen
}
local client = require("awful.client")

--- Magnifier layout module for awful
module("awful.layout.suit.magnifier")

function arrange(p)
    -- Fullscreen?
    local area = p.workarea
    local cls = p.clients
    local focus = capi.client.focus
    local mwfact = tag.getmwfact(tag.selected(p.screen))
    local fidx

    -- Check that the focused window is on the right screen
    if focus and focus.screen ~= p.screen then focus = nil end

    if not focus and #cls > 0 then
        focus = cls[1]
        fidx = 1
    end

    -- If focused window is not tiled, take the first one which is tiled.
    if client.floating.get(focus) then
        focus = cls[1]
        fidx = 1
    end

    -- Abort if no clients are present
    if not focus then return end

    local geometry = {}
    if #cls > 1 then
        geometry.width = area.width * math.sqrt(mwfact)
        geometry.height = area.height * math.sqrt(mwfact)
        geometry.x = area.x + (area.width - geometry.width) / 2
        geometry.y = area.y + (area.height - geometry.height) /2
    else
        geometry.x = area.x
        geometry.y = area.y
        geometry.width = area.width
        geometry.height = area.height
    end
    focus:geometry(geometry)
    focus:raise()

    if #cls > 1 then
        geometry.x = area.x
        geometry.y = area.y
        geometry.height = area.height / (#cls - 1)
        geometry.width = area.width

        -- We don't know what the focus window index. Try to find it.
        if not fidx then
            for k, c in ipairs(cls) do
                if c == focus then
                    fidx = k
                    break
                end
            end
        end

        -- First move clients that are before focused client.
        for k = fidx + 1, #cls do
            cls[k]:geometry(geometry)
            geometry.y = geometry.y + geometry.height
        end

        -- Then move clients that are after focused client.
        -- So the next focused window will be the one at the top of the screen.
        for k = 1, fidx - 1 do
            cls[k]:geometry(geometry)
            geometry.y = geometry.y + geometry.height
        end
    end
end

name = "magnifier"
