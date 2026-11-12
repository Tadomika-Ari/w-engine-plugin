--!nonstrict
-- Reference [[panel]] entry - a settings-style panel of interactive controls.
--
-- Panels describe their UI declaratively, exactly like desktop widgets: build a
-- tree with the ui.* constructors and hand it to panel.render(). The host diffs
-- the tree against the previous one and updates retained native controls, so
-- rendering an unchanged tree is free.
--
--   panel.render(tree)              replace the panel's UI tree
--   panel.close()                   ask the host to close this panel
--   noctalia.getConfig(key)         settings (seeded from the manifest)
--   noctalia.openColorPicker(...)   open the native color picker asynchronously
--   button/toggle/slider/...        onClick / onChange accept a closure or the
--                                   name of a plugin global; values arrive as
--                                   string args
--
-- Layout notes:
--   * a Flex (column/row/scroll) centers its children on the cross axis by
--     default - pass align = "stretch" so controls fill the panel width.
--   * panel size is host-owned: declare width/height on the [[panel]] manifest
--     entry, so the surface is the same size on every open.
--
-- Stateful controls follow a controlled/uncontrolled split:
--   * toggle / slider / select are value-driven - pass the current value each
--     render; the callback reports the user's new value.
--   * input is uncontrolled - `value` seeds the field once; the host owns the
--     text buffer afterward, so re-rendering never clobbers what the user typed.
--     Observe edits via onChange (live) / onSubmit (Enter).

local closeButton = true

local commande = "ss -tlnp"
local tableau = { "test1", "test2" }
local render

local function getLocalhost()
	noctalia.runAsync(commande, function(result)
		if result.exitCode == 0 then
			tableau = string.split(result.stdout or "", "\n")
		else
			tableau = { "Erreur lors de l'exécution de ss" }
		end
		render()
	end)
end

render = function()
  	local headerContent = {
    	ui.label({ text = "LocalCheck", fontSize = 16, fontWeight = "bold", color = "on_surface", flexGrow = 1 })
  	}
  	if closeButton then
    	table.insert(headerContent, ui.button({ glyph = "close", onClick = "onCloseClicked" }))
  	end
  	-- The panel surface already insets its content (Style::panelPadding), so this
  	-- adds gaps between rows, not its own outer padding.
  	panel.render(ui.column({ flexGrow = 1, gap = 16 }, {
    	-- Header: title on the left, close button pinned to the top right if 
    	-- `shell.show_close_buttons` is true - matching the built-in panels (no divider rule).
    	ui.row({ align = "center", justify = "space_between", gap = 8 }, headerContent),

    	-- Body: a scrollable stack of settings.
    	ui.scroll({ flexGrow = 1, gap = 16 }, {
			ui.button({
				text = tableau[2]
		})
    	}),
  	}))
end

function onOpen(_context)
	getLocalhost()
  render()
end

function onCloseClicked()
  	panel.close()
end