local ui = {}

ui.title = {}

ui.context_menu = {}
ui.context_x = 0
ui.context_y = 0
ui.context_w = 0
ui.context_h = 0

ui.title_active = false
ui.title_x = 0
ui.title_y = 0
ui.title_w = 0
ui.title_h = 0

ui.popup = {}
ui.popup_x = 0
ui.popup_y = 0
ui.popup_w = 0
ui.popup_h = 0
ui.popup_x_offset = 0

ui.keyboard_test = ""
ui.keyboard_last = ""
ui.keyboard_timer = 0
ui.keyboard_timer_hit = false

ui.input_cursor = 0
ui.input_cursor_visible = false

ui.active_textbox = ""
ui.textbox_selection_origin = ""
ui.textbox_rename_layer = -1
ui.rename_click = false

ui.allow_keyboard_input = false

ui.popup_sel_a = 0
ui.popup_sel_b = 0
ui.popup_enter = false

ui.palette_mode = "RGB"
ui.palette_slider = 0
ui.palette = {}
ui.palette_textbox = 0
ui.palette_text_entry = 0
ui.palette_text_original = 0
ui.palette_changed = false

ui.layer = {}
ui.layer_trash = {}
ui.lyr_count = 1
ui.lyr_scroll_percent = 0
ui.lyr_scroll = false
ui.lyr_dir = ""
ui.lyr_spd = 1
ui.lyr_timer = 0
ui.lyr_clicked = 0
ui.lyr_click_y = 0
ui.lyr_button_active = -1

ui.preview_active = false
ui.preview_x = 100
ui.preview_y = 100
ui.preview_w = 308
ui.preview_h = 308
ui.preview_w_min = 308
ui.preview_h_min = 308
ui.preview_w_max = 500
ui.preview_h_max = 500
ui.preview_w_init_pos = 0
ui.preview_h_init_pos = 0
ui.preview_dragging = false
ui.preview_drag_corner = -1
ui.preview_bg_color = {179/255, 192/255, 209/255, 1}
ui.preview_window_x = 0
ui.preview_window_y = 0
ui.preview_zoom = 1
ui.preview_action = ""
ui.preview_palette_enabled = false
ui.preview_artboard_enabled = false
ui.preview_textbox = ""
ui.preview_textbox_locked = true
ui.preview_textbox_orig = ""
ui.preview_textbox_mode = "px"
ui.preview_button_active = -1
ui.preview_flip_h = false
ui.preview_flip_v = false

ui.toolbar = {}
ui.toolbar_clicked = -1
ui.toolbar_undo = nil
ui.toolbar_redo = nil
ui.toolbar_artboard = nil
ui.toolbar_polygon = nil
ui.toolbar_ellipse = nil
ui.toolbar_polyline = nil
ui.toolbar_preview = nil
ui.toolbar_grid = nil
ui.toolbar_pick = nil
ui.toolbar_zoom = nil
ui.toolbar_select = nil

ui.primary_panel = {}
ui.primary_textbox = -1
ui.primary_text_orig = ""
ui.primary_clicked = -1

ui.secondary_panel = {}
ui.secondary_textbox = -1
ui.secondary_text_orig = ""
ui.secondary_clicked = -1
ui.zoom_textbox_mode = "px"

ui.mouse_x = -1
ui.mouse_y = -1
ui.mouse_x_previous = -1
ui.mouse_y_previous = -1
ui.mouse_lock_x = -1
ui.mouse_lock_y = -1

ui.cm_color_area = -1

ui.tooltip_active = -1
ui.tooltip_text = ""
ui.tooltip_timer = 0
ui.tooltip_x = 0
ui.tooltip_y = 0
ui.tooltip_disable = false
TIP_TOOLBAR_SHAPE = 0
TIP_TOOLBAR_SELECT = 1
TIP_TOOLBAR_GRID = 2
TIP_TOOLBAR_ZOOM = 3
TIP_TOOLBAR_PICK = 4
TIP_TOOLBAR_PREVIEW = 5
TIP_TOOLBAR_POLYGON = 6
TIP_TOOLBAR_ELLIPSE = 7
TIP_TOOLBAR_FREEDRAW = 8
TIP_TOOLBAR_UNDO = 9
TIP_TOOLBAR_REDO = 10
TIP_ADD_LAYER = 11
TIP_DELETE_LAYER = 12
TIP_GRID_SNAP = 13
TIP_ZOOM_IN = 14
TIP_ZOOM_OUT = 15
TIP_ZOOM_RESET = 16
TIP_ZOOM_FIT = 17
TIP_FREEDRAW_ORDER = 18
TIP_PREV_ZOOM_IN = 19
TIP_PREV_ZOOM_OUT = 20
TIP_PREV_ZOOM_RESET = 21
TIP_PREV_ZOOM_FIT = 22
TIP_PREV_FREEDRAW = 23
TIP_PREV_BG = 24
TIP_CLONE_LAYER = 25
TIP_GRID_PP = 26
TIP_TOOLBAR_POLYLINE = 27
TIP_PREV_HFLIP = 28
TIP_PREV_VFLIP = 29
TIP_POLYLINE_CONVERT = 30
TIP_POLYLINE_MODE = 31

function ui.init()
	-- Add palette sliders
	ui.addPS("R")
	ui.addPS("G")
	ui.addPS("B")
	ui.addPS("H")
	ui.addPS("S")
	ui.addPS("L")

	-- Add title bar items
	ui.addTitle("File",     ".file")
	ui.addTitle("Edit",     ".edit")
	ui.addTitle("Image",   ".image")
	ui.addTitle("Layer",   ".layer")
	ui.addTitle("Select",  ".select")
	ui.addTitle("Help",     ".help")
	
	-- Add toolbar items
	ui.toolbar_shape = ui.addTool(TIP_TOOLBAR_SHAPE,         icon_cursorw,  ".main")
	ui.toolbar_select = ui.addTool(TIP_TOOLBAR_SELECT,       icon_select,  ".select")
	ui.toolbar_grid = ui.addTool(TIP_TOOLBAR_GRID,           icon_grid,     ".grid")
	ui.toolbar_zoom = ui.addTool(TIP_TOOLBAR_ZOOM,           icon_zoom,     ".zoom")
	ui.toolbar_pick = ui.addTool(TIP_TOOLBAR_PICK,           icon_pick,     ".pick")
	ui.toolbar_preview = ui.addTool(TIP_TOOLBAR_PREVIEW,     icon_look,     ".prev")
	ui.addToolBreak()
	ui.toolbar_polygon  = ui.addTool(TIP_TOOLBAR_POLYGON,    icon_triangle, ".tri")
	ui.toolbar_ellipse  = ui.addTool(TIP_TOOLBAR_ELLIPSE,    icon_circle,   ".circ")
	ui.toolbar_artboard = ui.addTool(TIP_TOOLBAR_FREEDRAW,   icon_draw,     ".artb")
	ui.toolbar_polyline = ui.addTool(TIP_TOOLBAR_POLYLINE,   icon_polyline, ".line")
	ui.addToolBreak()
	ui.toolbar_undo = ui.addTool(TIP_TOOLBAR_UNDO,           icon_undo,     ".undo")
	ui.toolbar_redo = ui.addTool(TIP_TOOLBAR_REDO,           icon_redo,     ".redo")
end

function ui.loadCM(x, y, ref)

	ui.context_menu = {}
	local can_select_all = false
	local can_select_all_verts = shape_grabber == false and (vertex_selection_mode == false)
	local can_select_all_shapes = shape_grabber
	can_select_all = (can_select_all_verts or can_select_all_shapes) and not select_grabber and not zoom_grabber and not color_grabber and (polygon.data[tm.polygon_loc] ~= nil) and (artboard.active == false)
	
	if empty_document then
	
		if tm.data[1] ~= nil and document_w ~= 0 then
			empty_document = false
		end
	
	end
	
	local can_save = not empty_document and fs_enable_save
	
	local can_paste_color = false
	can_paste_color = (palette.copy ~= nil) and ui.cm_color_area ~= -1
	
	if ref == ".file" then
	
		ui.addCM("New",          true, "f.new", ctrl_id .. "+N")
		ui.addCMBreak()
		ui.addCM("Save",        can_save, "f.save", ctrl_id .. "+S")
		ui.addCM("Save As...",  can_save, "f.as")
		ui.addCMBreak()
		ui.addCM("Export .svg for nice club", can_save, "f.svg")
		ui.addCM("Export .png", can_save, "f.png")
		ui.addCMBreak()
		ui.addCM("Exit",        true, "f.exit")
		ui.generateCM(x, y)
	
	elseif ref == ".edit" then
	
		ui.addCM("Undo", ui.toolbar[ui.toolbar_undo].active, "e.undo", ctrl_id .. "+Z")
		ui.addCM("Redo", ui.toolbar[ui.toolbar_redo].active, "e.redo", ctrl_id .. "+Y or Shift+" .. ctrl_id .. "+Z")
		ui.addCMBreak()
		ui.addCM("Copy palette color",  ui.cm_color_area ~= -1, "e.pcopy", ctrl_id .. "+C")
		ui.addCM("Paste palette color", can_paste_color, "e.ppaste", ctrl_id .. "+V")
		ui.generateCM(x, y)
		
	elseif ref == ".image" then
	
		ui.addCM("Document setup...", document_w ~= 0, "i.setup")
		ui.addCMBreak()
		ui.addCM("Center camera", document_w ~= 0, "i.center", ctrl_id .. "+G")
		ui.addCM("Clear canvas", document_w ~= 0 and artboard.active, "i.clear", ctrl_id .. "+R")
		ui.generateCM(x, y)
		
	elseif ref == ".layer" then
	
		ui.addCM("New layer", document_w ~= 0, "l.new", ctrl_id .. "+K")
		ui.addCM("Duplicate layer", polygon.data[tm.polygon_loc] ~= nil, "l.clone", ctrl_id .. "+J")
		ui.addCM("Delete layer", (#ui.layer > 1), "l.delete", ctrl_id .. "+Delete")
		ui.addCMBreak()
		ui.addCM("Rename layer...", document_w ~= 0, "l.rename", "F2")
		ui.generateCM(x, y)
		
	elseif ref == ".select" then
	
		ui.addCM("Select All", can_select_all, "s.all", ctrl_id .. "+A")
		ui.addCM("Deselect", vertex_selection_mode or shape_selection_mode, "s.de", ctrl_id .. "+D")
		ui.generateCM(x, y)
		
	elseif ref == ".help" then
	
		ui.addCM("About Sodalite...", true, "h.about")
		ui.generateCM(x, y)
		
	end

end

function ui.loadPopup(ref)

	if ui.popup[1] ~= nil and ui.popup[1][1].kind == ref then
		-- Don't make duplicate popup
	else
		
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")

		ui.popup = {}
		
		if ref == "f.new" or ref == "i.setup" or ref == "f.as" then
			storeMovedVertices()
			vertex_selection_mode = false
			vertex_selection = {}
			storeMovedShapes()
			shape_selection_mode = false
			shape_selection = {}
			multi_shape_selection = false
		
			local start_w, start_h, start_name = 512, 512, "Untitled"
			if ref == "i.setup" then
				ui.addPopup("Document setup", "i.setup", "col")
				start_w = document_w
				start_h = document_h
				start_name = document_name
			elseif ref == "f.as" then
				ui.addPopup("Save As", "f.as", "col")
				start_w = document_w
				start_h = document_h
				start_name = document_name
			else
				ui.addPopup("New document", "f.new", "col")
				if document_w ~= 0 then
					start_w = document_w
					start_h = document_h
				end
			end
			ui.addPopup("Name:", "text", "col")
			ui.addPopup(start_name, "textbox", "row")
			ui.addPopup("Width:", "text", "col")
			ui.addPopup(start_w, "number", "row")
			ui.addPopup("Height:", "text", "col")
			ui.addPopup(start_h, "number", "row")
			ui.addPopup("OK", "ok", "col")
			ui.addPopup("Cancel", "cancel", "row")
			ui.generatePopup()
			
		elseif ref == "f.overwrite" then
		
			storeMovedVertices()
			vertex_selection_mode = false
			vertex_selection = {}
			storeMovedShapes()
			shape_selection_mode = false
			shape_selection = {}
			multi_shape_selection = false
			
			ui.addPopup("Confirm Save", "f.overwrite", "col")
			ui.addPopup(overwrite_name .. " already exists. Do you want to overwrite it?", "text", "col")
			ui.addPopup("Overwrite", "overwrite", "col")
			ui.addPopup("Rename", "rename", "row")
			ui.addPopup("Cancel", "cancel", "row")
			ui.generatePopup()

		elseif ref == "f.convert" then
		
			ui.addPopup("Converting...", "f.convert", "col")    
			ui.addPopup("", "text", "col")
			ui.generatePopup()
		
		elseif ref == "save.disabled" then
		
			ui.addPopup("DOCUMENT SAVING DISABLED!", "save.disabled", "col")    
			ui.addPopup("Document saving has been disabled for this session as Sodalite", "text", "col")
			ui.addPopup("lacks the necessary permissions on this device to save documents.", "text", "col")
			ui.addPopup("If you are experiencing this error, please go to the", "text", "col")
			ui.addPopup("troubleshooting section of https://illteteka.itch.io/sodalite", "text", "col")
			ui.addPopup("or contact nick.novelline@gmail.com with information", "text", "col")
			ui.addPopup("about your OS and computer setup.", "text", "col")
			ui.addPopup("Continue without saving", "continue", "col")
			ui.addPopup("Exit", "exit", "row")
			ui.generatePopup()
		
		elseif ref == "h.about" then
			storeMovedVertices()
			vertex_selection_mode = false
			vertex_selection = {}
			storeMovedShapes()
			shape_selection_mode = false
			shape_selection = {}
			multi_shape_selection = false
		
			ui.addPopup("About Sodalite", "h.about", "col")
			ui.addPopup("Sodalite v0.2 beta (build 2+) [nice club edition]", "text", "col")
			ui.addPopup("https://illteteka.itch.io/", "text", "col")
			ui.addPopup("Sample artwork courtesy of Sunny Faucher and Chris Bradshaw", "text", "col")
			ui.addPopup("Sodalite © 2020-2022 Nick Gilmartin. All Rights Reserved.", "text", "col")
			ui.addPopup("OK", "ok", "col")
			ui.generatePopup()
			
		elseif ref == "f.save" then
			local test_save = export.test(OVERWRITE_LOL)
			if test_save and can_overwrite == false then
				ui.loadPopup("f.overwrite")
			else
				export.saveLOL()
				export.saveArtboard()
				can_overwrite = true
			end
			
		elseif ref == "f.svg" then
		
			local test_save = export.test(OVERWRITE_SVG)
			if test_save and can_overwrite == false then
				ui.loadPopup("f.overwrite")
			else
				export.saveSVG()
				can_overwrite = true
			end
			
		elseif ref == "f.png" then
		
			local test_save = export.test(OVERWRITE_PNG)
			if test_save and can_overwrite == false then
				ui.loadPopup("f.overwrite")
			else
				export.savePNG()
				can_overwrite = true
			end
			
		elseif ref == "e.pcopy" then
		
			if ui.cm_color_area == 2 then

				local new_col = {ui.preview_bg_color[1], ui.preview_bg_color[2], ui.preview_bg_color[3], ui.preview_bg_color[4]}
				palette.copy = new_col

			else

				local new_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
				palette.copy = new_col

			end
		
		elseif ref == "e.ppaste" then
		
			if ui.cm_color_area == 2 then

				local new_col = {palette.copy[1], palette.copy[2], palette.copy[3], palette.copy[4]}
				ui.preview_bg_color = new_col

			else

				palette.colors[palette.slot + 1] = palette.copy
				palette.active = palette.colors[palette.slot + 1]
				palette.updateAccentColor()
				palette.updateFromBoxes()
				
				local copy_again = palette.colors[palette.slot + 1]
				local new_col = {copy_again[1], copy_again[2], copy_again[3], copy_again[4]}
				palette.copy = new_col

			end
		
		elseif ref == "s.all" then
			if shape_grabber then
				editorSelectAllShapes()
			else
				editorSelectAll()
			end
			
		elseif ref == "s.de" then
			vertex_selection_mode = false
			vertex_selection = {}
			
			shape_selection_mode = false
			shape_selection = {}
			multi_shape_selection = false
			
		elseif ref == "i.center" then
			resetCamera()
		elseif ref == "i.clear" then
			artboard.clear()
		elseif ref == "e.undo" then
			if artboard.active == false then
				editorUndo()
			else
				artboard.undo()
			end
		elseif ref == "e.redo" then
			if artboard.active == false then
				editorRedo()
			else
				artboard.redo()
			end
		elseif ref == "f.exit" then
		
			if document_w ~= 0 and fs_enable_save then
				is_trying_to_quit = true
				safe_to_quit = false
				overwrite_type = OVERWRITE_LOL
				storeMovedVertices()
				vertex_selection_mode = false
				vertex_selection = {}
				storeMovedShapes()
				shape_selection_mode = false
				shape_selection = {}
				multi_shape_selection = false
			
				ui.addPopup("Save?", "f.exit", "col")
				ui.addPopup("Do you want to save changes to " .. document_name .. ".soda?", "text", "col")
				ui.addPopup("Save", "save", "col")
				ui.addPopup("Discard", "discard", "row")
				ui.addPopup("Cancel", "cancel", "row")
				ui.generatePopup()
			else
				safe_to_quit = true
				love.event.quit()
			end
		
		elseif ref == "l.new" then
		
			ui.layerAddButton()
		
		elseif ref == "l.clone" then
		
			storeMovedVertices()
			vertex_selection_mode = false
			vertex_selection = {}

			storeMovedShapes()
			shape_selection_mode = false
			shape_selection = {}
			multi_shape_selection = false

			ui.layerCloneButton(true, false)

			ui.lyr_scroll_percent = 0
		
		elseif ref == "l.delete" then
		
			ui.layerDeleteButton()
		
		elseif ref == "l.rename" then
		
			ui.layerRenameButton()
		
		end
	
	end

end

function ui.addTitle(name, ref)

	local item = {}
	item.name = name
	item.ref = ref
	
	table.insert(ui.title, item)

end

-- Toolbar
function ui.addTool(name, icon, ref)

	local item = {}
	item.tooltip = name
	item.icon = icon
	item.ref = ref
	item.active = true
	
	table.insert(ui.toolbar, item)
	return #ui.toolbar
	
end

-- Toolbar break
function ui.addToolBreak()

	local item = {}
	item._break = true
	table.insert(ui.toolbar, item)

end

-- Context menu
function ui.addCM(name, active, ref, keys)

	local item = {}
	item.name = name
	item.ref = ref
	item.active = active
	item.key_combo = keys or ""
	
	table.insert(ui.context_menu, item)

end

-- Palette slider
function ui.addPS(name)

	local item = {}
	item.name = name
	item.value = "0"
	
	table.insert(ui.palette, item)

end

function ui.addPanel(panel, id, name, textbox, default, min_entry, max_entry)

	local item = {}
	if textbox then
		item.name = name
		item.value = default
		item.low = min_entry
		item.high = max_entry
		item.active = false
	else
		item.icon = name
		item.active = default
	end
	
	item.is_textbox = textbox
	item.id = id
	
	table.insert(panel, item)

end

function ui.panelPolygon()

	ui.primary_textbox = -1
	ui.keyboard_last = ""
	ui.keyboard_test = ""
	ui.textbox_selection_origin = "toolbox"
	ui.popupLoseFocus()
	
	ui.primary_panel = nil
	ui.primary_panel = {}

end

function ui.panelEllipse()

	ui.primary_textbox = -1
	ui.keyboard_last = ""
	ui.keyboard_test = ""
	ui.textbox_selection_origin = "toolbox"
	ui.popupLoseFocus()

	ui.primary_panel = nil
	ui.primary_panel = {}
	ui.primary_panel.name = "Ellipse:"
	
	local load_seg, load_ang = 0, 0
	if polygon.data[1] ~= nil and polygon.data[tm.polygon_loc] ~= nil and polygon.data[tm.polygon_loc].kind == "ellipse" then
		local myshape = polygon.data[tm.polygon_loc]
		load_seg = myshape.segments
		load_ang = myshape._angle
	else
		load_seg = polygon.segments
		load_ang = polygon._angle
	end
	
	ui.addPanel(ui.primary_panel, 'ellipse.seg', 'Segments', true, load_seg, 3, 128)
	ui.addPanel(ui.primary_panel, 'ellipse.ang', 'Rotation', true, load_ang, 0, 359)

end

function ui.panelPolyline()

	ui.primary_textbox = -1
	ui.keyboard_last = ""
	ui.keyboard_test = ""
	ui.textbox_selection_origin = "toolbox"
	ui.popupLoseFocus()

	ui.primary_panel = nil
	ui.primary_panel = {}
	ui.primary_panel.name = "Polyline:"
	
	ui.addPanel(ui.primary_panel, 'polyline.size', 'Line thickness', true, polygon.thickness, polygon.min_thickness, polygon.max_thickness)
	
	local find_ruler_icon = icon_paint
	if polygon.ruler then
		find_ruler_icon = icon_ruler
	end
	
	ui.addPanel(ui.primary_panel, 'polyline.convert', icon_line_to_triangle, false, true)
	ui.addPanel(ui.primary_panel, 'polyline.ruler', find_ruler_icon, false, true)

end

function ui.panelArtboard()

	ui.primary_textbox = -1
	ui.keyboard_last = ""
	ui.keyboard_test = ""
	ui.textbox_selection_origin = "toolbox"
	ui.popupLoseFocus()

	ui.primary_panel = nil
	ui.primary_panel = {}
	ui.primary_panel.name = "Free draw:"
	
	ui.addPanel(ui.primary_panel, 'art.brush',       'Brush size', true, artboard.brush_size, 1, math.max(document_w, document_h))
	ui.addPanel(ui.primary_panel, 'art.opacity', 'Canvas opacity', true, artboard.opacity * 100, 0, 100)
	
	local find_art_icon = icon_art_above
	if artboard.draw_top == false then
		find_art_icon = icon_art_below
	end
	
	ui.addPanel(ui.primary_panel, 'art.position', find_art_icon, false, true)

end

function ui.panelReset()

	ui.toolbar[ui.toolbar_grid].active = true
	ui.toolbar[ui.toolbar_zoom].active = true
	ui.secondary_textbox = -1
	ui.keyboard_last = ""
	ui.keyboard_test = ""
	ui.textbox_selection_origin = "toolbox2"
	ui.popupLoseFocus()

	ui.secondary_panel = nil
	ui.secondary_panel = {}

end

function ui.setTooltip(tool)

	if tool ~= ui.tooltip_active then
		ui.tooltip_timer = 0
		ui.tooltip_text = ui.getTooltip(tool)
		ui.tooltip_active = tool
		ui.tooltip_x = love.mouse.getX()
		ui.tooltip_y = love.mouse.getY()
	end
	
	ui.tooltip_disable = false

end

function ui.getTooltip(x)
	if x == TIP_TOOLBAR_SHAPE then
		return "Shape Selection Tool (6)"
	elseif x == TIP_TOOLBAR_SELECT then
		return "Box Selection Tool (4)"
	elseif x == TIP_TOOLBAR_GRID then
		return "Grid Tool (3)"
	elseif x == TIP_TOOLBAR_ZOOM then
		return "Zoom Tool (2)"
	elseif x == TIP_TOOLBAR_PICK then
		return "Color Grabber (1)"
	elseif x == TIP_TOOLBAR_PREVIEW then
		return "Preview Window (5)"
	elseif x == TIP_TOOLBAR_POLYGON then
		return "Polygon Tool (7)"
	elseif x == TIP_TOOLBAR_ELLIPSE then
		return "Ellipse Tool (8)"
	elseif x == TIP_TOOLBAR_FREEDRAW then
		return "Free draw (9)"
	elseif x == TIP_TOOLBAR_UNDO then
		return "Undo"
	elseif x == TIP_TOOLBAR_REDO then
		return "Redo"
	elseif x == TIP_ADD_LAYER then
		return "Add a new layer"
	elseif x == TIP_DELETE_LAYER then
		return "Delete the current layer"
	elseif x == TIP_CLONE_LAYER then
		return "Duplicate the current layer"
	elseif x == TIP_GRID_SNAP then
		return "Toggle grid snapping"
	elseif x == TIP_ZOOM_IN then
		return "Zoom In"
	elseif x == TIP_ZOOM_OUT then
		return "Zoom Out"
	elseif x == TIP_ZOOM_RESET then
		return "Reset camera zoom and position"
	elseif x == TIP_ZOOM_FIT then
		return "Fit the document to the program window"
	elseif x == TIP_FREEDRAW_ORDER then
		if artboard.draw_top then
			return "Swap the position of the drawing canvas, canvas is currently below the document"
		else
			return "Swap the position of the drawing canvas, canvas is currently above the document"
		end
	elseif x == TIP_PREV_ZOOM_IN then
		return "Zoom In"
	elseif x == TIP_PREV_ZOOM_OUT then
		return "Zoom Out"
	elseif x == TIP_PREV_ZOOM_RESET then
		return "Reset camera zoom and position"
	elseif x == TIP_PREV_ZOOM_FIT then
		return "Fit the document to the preview window"
	elseif x == TIP_PREV_FREEDRAW then
		return "Toggle the visibility of the drawing canvas"
	elseif x == TIP_PREV_BG then
		return "Preview window background color, paste a palette color here to change colors"
	elseif x == TIP_GRID_PP then
		return "Toggle the forced 1x1 pixel grid"
	elseif x == TIP_TOOLBAR_POLYLINE then
		return "Polyline Tool (-)"
	elseif x == TIP_PREV_HFLIP then
		return "Flip the preview horizontally"
	elseif x == TIP_PREV_VFLIP then
		return "Flip the preview vertically"
	elseif x == TIP_POLYLINE_CONVERT then
		return "Convert all lines on the active layer into polygons"
	elseif x == TIP_POLYLINE_MODE then
		if polygon.ruler then
			return "Polyline ruler, toggle control method to polyline paint"
		else
			return "Polyline paint, toggle control method to polyline ruler"
		end
	end
end

function ui.panelGrid()

	ui.secondary_textbox = -1
	ui.keyboard_last = ""
	ui.keyboard_test = ""
	ui.textbox_selection_origin = "toolbox2"
	ui.popupLoseFocus()

	ui.secondary_panel = nil
	ui.secondary_panel = {}
	ui.secondary_panel.name = "Grid:"

	ui.addPanel(ui.secondary_panel, 'grid.width',   'Width', true, grid_w, 2, math.max(document_w, document_h))
	ui.addPanel(ui.secondary_panel, 'grid.height', 'Height', true, grid_h, 2, math.max(document_w, document_h))
	ui.addPanel(ui.secondary_panel, 'grid.x',    'X Offset', true, grid_x, 0, math.max(document_w, document_h))
	ui.addPanel(ui.secondary_panel, 'grid.y',    'Y Offset', true, grid_y, 0, math.max(document_w, document_h))
	ui.addPanel(ui.secondary_panel, 'grid.snap', icon_magnet, false, not grid_snap)
	ui.addPanel(ui.secondary_panel, 'grid.pp',   icon_pixel,  false, not pixel_perfect)

end

function ui.panelZoom()

	ui.secondary_textbox = -1
	ui.keyboard_last = ""
	ui.keyboard_test = ""
	ui.textbox_selection_origin = "toolbox2"
	ui.popupLoseFocus()

	ui.secondary_panel = nil
	ui.secondary_panel = {}
	ui.secondary_panel.name = "Zoom:"

	ui.addPanel(ui.secondary_panel, 'zoom.type',  "px", true, 512, 1, 1000)
	ui.addPanel(ui.secondary_panel, 'zoom.in',    icon_zoom_in, false, true)
	ui.addPanel(ui.secondary_panel, 'zoom.out',   icon_zoom_out, false, true)
	ui.addPanel(ui.secondary_panel, 'zoom.reset', icon_reset, false, true)
	ui.addPanel(ui.secondary_panel, 'zoom.fit',   icon_fit, false, true)

end

function ui.addPopup(name, kind, loc)

	local col, row
	
	if (loc == "col") then
	
		-- Always adds a new column
		col = #ui.popup + 1
		
		if (ui.popup[col] == nil) then
			ui.popup[col] = {}
		end
		
	elseif (loc == "row") then
	
		col = #ui.popup
		
		-- Add the first column if no columns exist
		if (ui.popup[col] == nil) then
			ui.popup[col + 1] = {}
			col = col + 1
		end
		
	end
	
	row = #ui.popup[col] + 1
	
	if (ui.popup[col][row] == nil) then
		ui.popup[col][row] = {}
	end
	
	ui.popup[col][row].name = name
	ui.popup[col][row].kind = kind

end

function ui.shapeSelectButton()
	if document_w ~= 0 then
		ui.active_textbox = ""
		box_selection_x = 0
		box_selection_y = 0
		if ui.toolbar[ui.toolbar_shape].active then
			vertex_selection_mode = false
			vertex_selection = {}
			zoom_grabber = false
			ui.toolbar[ui.toolbar_zoom].active = true
			local keep_grid = ui.toolbar[ui.toolbar_grid].active == false
			ui.panelReset()
			if keep_grid then
				ui.toolbar[ui.toolbar_grid].active = false
			end
			shape_grabber = true
			ui.toolbar[ui.toolbar_shape].active = false
		else
			storeMovedShapes()
			shape_selection_mode = false
			shape_selection = {}
			multi_shape_selection = false
			local open_grid = ui.toolbar[ui.toolbar_grid].active == false
			ui.panelReset()
			zoom_grabber = false
			ui.toolbar[ui.toolbar_zoom].active = true
			shape_grabber = false
			love.mouse.setCursor()
			ui.toolbar[ui.toolbar_shape].active = true
			if open_grid then
				ui.panelGrid()
				ui.toolbar[ui.toolbar_grid].active = false
			end
		end
	end
end

function ui.selectionButton(button_mode, set_selection)
	if document_w ~= 0 then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
	
		box_selection_x = 0
		box_selection_y = 0
		ui.active_textbox = ""
		
		local start_selection = false
		
		start_selection = button_mode and ui.toolbar[ui.toolbar_select].active
		if not start_selection and not button_mode then start_selection = set_selection end
		
		if start_selection then
			if zoom_grabber then
				love.mouse.setCursor()
			end
			
			if shape_grabber then
				love.mouse.setCursor(cursor_shape)
			end
			
			zoom_grabber = false
			ui.toolbar[ui.toolbar_zoom].active = true
			local keep_grid = ui.toolbar[ui.toolbar_grid].active == false
			ui.panelReset()
			if keep_grid then
				ui.toolbar[ui.toolbar_grid].active = false
			end
			select_grabber = true
			ui.toolbar[ui.toolbar_select].active = false
		else -- start selection
			local open_grid = ui.toolbar[ui.toolbar_grid].active == false
			ui.panelReset()
			select_grabber = false
			ui.toolbar[ui.toolbar_select].active = true
			if open_grid then
				ui.panelGrid()
				ui.toolbar[ui.toolbar_grid].active = false
			end
		end
		
	end
end

function ui.gridButton()

	if document_w ~= 0 then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
	
		ui.active_textbox = ""
		if ui.toolbar[ui.toolbar_grid].active then
			love.mouse.setCursor()
			zoom_grabber = false
			ui.toolbar[ui.toolbar_zoom].active = true
			select_grabber = false
			ui.toolbar[ui.toolbar_select].active = true
			ui.panelGrid()
			ui.toolbar[ui.toolbar_grid].active = false
		else
			zoom_grabber = false
			ui.toolbar[ui.toolbar_zoom].active = true
			select_grabber = false
			ui.toolbar[ui.toolbar_select].active = true
			ui.panelReset()
			ui.toolbar[ui.toolbar_grid].active = true
		end
	end

end

function ui.zoomButton()

	if document_w ~= 0 then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
	
		ui.active_textbox = ""
		if ui.toolbar[ui.toolbar_zoom].active then
			select_grabber = false
			ui.toolbar[ui.toolbar_select].active = true
			zoom_grabber = true
			ui.panelZoom()
			ui.toolbar[ui.toolbar_zoom].active = false
		else
			love.mouse.setCursor()
			local open_grid = ui.toolbar[ui.toolbar_grid].active == false
			zoom_grabber = false
			ui.panelReset()
			ui.toolbar[ui.toolbar_zoom].active = true
			if open_grid then
				ui.panelGrid()
				ui.toolbar[ui.toolbar_grid].active = false
			end
		end
	end

end

function ui.pickColorButton()

	if document_w ~= 0 then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
	
		ui.active_textbox = ""
		select_grabber = false
		ui.toolbar[ui.toolbar_select].active = true
		color_grabber = true
		love.mouse.setCursor(cursor_pick)
		ui.toolbar[ui.toolbar_pick].active = false
	end

end

function ui.previewButton()

	if document_w ~= 0 then
		ui.active_textbox = ""
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
		ui.preview_active = not ui.preview_active
	end

end

function ui.triangleButton()

	if ui.toolbar[ui.toolbar_polygon].active then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
	
		ui.active_textbox = ""
		artboard.active = false
		polygon.kind = "polygon"
		polygon.line = false
		ui.panelPolygon()
	end

end

function ui.ellipseButton()

	if ui.toolbar[ui.toolbar_ellipse].active then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
	
		ui.active_textbox = ""
		artboard.active = false
		polygon.kind = "ellipse"
		polygon.line = false
		ui.panelEllipse()
	end

end

function ui.polylineButton()

	if ui.toolbar[ui.toolbar_polyline].active then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
	
		ui.active_textbox = ""
		artboard.active = false
		polygon.kind = "polygon"
		polygon.line = true
		ui.panelPolyline()
	end

end

function ui.artboardButton()

	if ui.toolbar[ui.toolbar_artboard].active then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
	
		ui.active_textbox = ""
		artboard.active = true
		polygon.line = false
		ui.panelArtboard()
	end

end

function ui.layerAddButton()

	storeMovedVertices()
	vertex_selection_mode = false
	vertex_selection = {}
	
	storeMovedShapes()
	shape_selection_mode = false
	shape_selection = {}
	multi_shape_selection = false

	local old_layer = tm.polygon_loc
	tm.polygon_loc = #ui.layer + #ui.layer_trash + 1

	tm.store(TM_PICK_LAYER, old_layer, tm.polygon_loc, true, false)
	tm.step()

	ui.addLayer()
	palette.updateAccentColor()
				
end

function ui.layerDeleteButton()

	storeMovedVertices()
	vertex_selection_mode = false
	vertex_selection = {}
	
	storeMovedShapes()
	shape_selection_mode = false
	shape_selection = {}
	multi_shape_selection = false
	
	local find_layer = 0
	for i = 1, #ui.layer do
		if ui.layer[i].count == tm.polygon_loc then
			find_layer = i
		end
	end
	
	if find_layer ~= 0 then
		ui.deleteLayer(find_layer)
		tm.store(TM_PICK_LAYER, find_layer, tm.polygon_loc, false, true)
		tm.step()
		tm.polygon_loc = ui.layer[#ui.layer].count
		palette.updateAccentColor()
		ui.lyr_scroll_percent = 0
	end

end

function ui.layerRenameButton()

	ui.popupLoseFocus("rename")
	
	ui.textbox_selection_origin = "rename"
	
	local i = 1
	local this_layer = 1
	for i = 1, #ui.layer do
		if ui.layer[i].count == tm.polygon_loc then
			this_layer = i
		end
	end
	
	ui.textbox_rename_layer = this_layer
	ui.primary_text_orig = ui.layer[this_layer].name
	ui.rename_click = true

end

function ui.layerCloneButton(use_tm, cache_line_state)

	local old_layer = tm.polygon_loc
	
	if not cache_line_state then
	
	tm.polygon_loc = #ui.layer + #ui.layer_trash + 1

	if use_tm then
		tm.store(TM_CLONE_LAYER, old_layer, tm.polygon_loc)
		tm.step()
	end

	ui.addLayer()
	
	else
		polygon.polyline_cache = nil
		polygon.polyline_cache = {}
	end

	local clone_index = ui.layer[#ui.layer].count
	local tbl_clone = {}
	local old_copy = polygon.data[old_layer]
	
	if not cache_line_state then
	tbl_clone.kind = old_copy.kind
	tbl_clone.color = {}
	table.insert(tbl_clone.color, old_copy.color[1])
	table.insert(tbl_clone.color, old_copy.color[2])
	table.insert(tbl_clone.color, old_copy.color[3])
	table.insert(tbl_clone.color, old_copy.color[4])
	end

	tbl_clone.cache = {}
	tbl_clone.raw = {}

	if not cache_line_state then
	if tbl_clone.kind == "ellipse" then

		tbl_clone.segments = old_copy.segments
		tbl_clone._angle = old_copy._angle

	end
	end

	local clc = 1
	while clc <= #old_copy.cache do
		local old_cache = old_copy.cache[clc]
		local cache_tbl = {}
		table.insert(cache_tbl, old_cache[1])
		table.insert(cache_tbl, old_cache[2])
		table.insert(tbl_clone.cache, cache_tbl)
		clc = clc + 1
	end

	local clc = 1
	while clc <= #old_copy.raw do
		local old_raw = old_copy.raw[clc]
		local raw_tbl = {}
		
		if old_raw.x ~= nil then
			raw_tbl.x = old_raw.x
		end
		
		if old_raw.y ~= nil then
			raw_tbl.y = old_raw.y
		end
		
		if old_raw.va ~= nil then
			raw_tbl.va = old_raw.va
		end
		
		if old_raw.vb ~= nil then
			raw_tbl.vb = old_raw.vb
		end
		
		if old_raw.l ~= nil then
			raw_tbl.l = old_raw.l
		end
		
		table.insert(tbl_clone.raw, raw_tbl)
		clc = clc + 1
	end

	if not cache_line_state then
	table.insert(polygon.data, tm.polygon_loc, tbl_clone)

	palette.updateAccentColor()
	else
	table.insert(polygon.polyline_cache, tbl_clone)
	end

end

function ui.addCMBreak()

	local item = {}
	item._break = true
	table.insert(ui.context_menu, item)

end

function ui.generateCM(x, y)

	local i
	local h, w = 0, 0
	for i = 1, #ui.context_menu do
	
		-- If entry in the menu
		if ui.context_menu[i]._break == nil then
			w = math.max(w, font:getWidth(ui.context_menu[i].name))
			h = h + 22
		else -- If entry is a break
			h = h + 11
		end
	
	end
	
	ui.context_x = x
	ui.context_y = y
	ui.context_w = w + 110
	ui.context_h = h + 15

end

function ui.generatePopup()

	local i
	local w = 0
	local h = 28 * (#ui.popup + 1)
	for i = 2, #ui.popup do
	
		local temp_w = 0
		local j
		for j = 1, #ui.popup[i] do
		
			if ui.popup[i][j].kind == "text" then
				temp_w = temp_w + font:getWidth(ui.popup[i][j].name) + 6
			elseif ui.popup[i][j].kind == "textbox" then
				temp_w = temp_w + 251
			elseif ui.popup[i][j].kind == "number" then
				temp_w = temp_w + 46
			end
		
		end
		
		if temp_w > w then
			w = temp_w
		end
	
	end
	
	if ui.popup[1][1].kind == "save.disabled" then
		ui.popup_w = w + 40
		h = h - 35
	else
		ui.popup_w = w + 120
	end
	ui.popup_h = h
	
	ui.popup_x_offset = -(((ui.popup_w/2) + (w/2)) / 4)
	
	-- Center the popup to the screen
	ui.resizeWindow()

end

function ui.popupLoseFocus(kind)
	
	if ui.textbox_selection_origin == "popup" then
		if ui.popup_sel_a ~= 0 then 
		
		-- Reset value to previous value if textbox is empty
		local name = ui.popup[ui.popup_sel_a][ui.popup_sel_b]
		
		if name.name == "" then
			name.name = ui.active_textbox
		end
		
		-- Don't let width or height be less than 8 when making a new document
		if kind == "f.new" then
			if name.kind == "number" then
				if tonumber(name.name) < 8 then
					name.name = "8"
				elseif tonumber(name.name) > 16384 then
					name.name = "16384"
				else
					name.name = tostring(tonumber(name.name))
				end
			end
		end
		
		end
		
		ui.popup_sel_a = 0
		ui.popup_sel_b = 0
		ui.textbox_selection_origin = ""
		ui.active_textbox = ""
	
	elseif ui.textbox_selection_origin == "preview" then
	
		if ui.preview_textbox ~= "." then
				
			local larger_window_bound = math.max(document_w, document_h)
			if ui.preview_textbox_mode == "px" then
				if ui.preview_zoom < 0.05 then
					ui.preview_textbox = ui.preview_textbox_orig
					ui.preview_zoom = tonumber(ui.preview_textbox) / larger_window_bound
				end
			else
				ui.preview_zoom = math.max(ui.preview_zoom, 0.05)
			end
			ui.preview_zoom = math.min(ui.preview_zoom, math.min(99999/larger_window_bound, 999.99))
		
		end
	
		ui.textbox_selection_origin = ""
		ui.preview_textbox_locked = true
		ui.active_textbox = ""
	
	elseif ui.textbox_selection_origin == "toolbar" then
	
		local tbox = ui.primary_panel[ui.primary_textbox]
	
		if tbox.value == "" then
			tbox.value = ui.primary_text_orig
		end
		
		if tonumber(tbox.value) < tbox.low then
			tbox.value = tbox.low
		end
		
		if tonumber(tbox.value) > tbox.high then
			tbox.value = tbox.high
		end
		
		if tbox.id == "ellipse.seg" or tbox.id == "ellipse.ang" then
			
			if polygon.data[1] ~= nil and polygon.data[tm.polygon_loc] ~= nil and polygon.data[tm.polygon_loc].kind == "ellipse" then
				local myshape = polygon.data[tm.polygon_loc]
				
				if tbox.id == "ellipse.seg" then
					local old_seg = ui.primary_text_orig
					myshape.segments = tonumber(tbox.value)
					tm.store(TM_ELLIPSE_SEG, old_seg, myshape.segments)
					tm.step()
					polygon.segments = tonumber(tbox.value)
				elseif tbox.id == "ellipse.ang" then
					local old_ang = ui.primary_text_orig
					myshape._angle = tonumber(tbox.value)
					tm.store(TM_ELLIPSE_ANGLE, old_ang, myshape._angle)
					tm.step()
					polygon._angle = tonumber(tbox.value)
				end
				
			else
			
				if tbox.id == "ellipse.seg" then
					polygon.segments = tonumber(tbox.value)
				elseif tbox.id == "ellipse.ang" then
					polygon._angle = tonumber(tbox.value)
				end
			
			end
			
		end
		
		if tbox.id == "art.brush" or tbox.id == "art.opacity" then
		
			if tbox.id == "art.brush" then
				artboard.brush_size = tonumber(tbox.value)
			end
			
			if tbox.id == "art.opacity" then
				artboard.opacity = tonumber(tbox.value)/100
			end
		
		end
		
		if tbox.id == "polyline.size" then
			polygon.thickness = tonumber(tbox.value)
		end
		
		ui.textbox_selection_origin = ""
		ui.primary_textbox = -1
		ui.active_textbox = ""
	
	elseif ui.textbox_selection_origin == "toolbar2" then
	
		local tbox = ui.secondary_panel[ui.secondary_textbox]
	
		if tbox.value ~= "." then
		
			if tbox.value == "" then
				tbox.value = ui.secondary_text_orig
			end
			
			if tbox.id == "zoom.type" then
			
				local tbox_to_camera = tonumber(tbox.value)
				local larger_window_bound = math.max(document_w, document_h)
				local new_zoom = camera_zoom
				
				if ui.zoom_textbox_mode == "px" then
					tbox_to_camera = tbox_to_camera / larger_window_bound
					if tbox_to_camera < 0.05 then
						tbox.value = ui.secondary_text_orig
						new_zoom = tonumber(tbox.value) / larger_window_bound
						tbox_to_camera = new_zoom
					end
				else
					tbox_to_camera = tbox_to_camera / 100
					new_zoom = math.max(tbox_to_camera, 0.05)
					tbox_to_camera = new_zoom
				end
				new_zoom = math.min(tbox_to_camera, math.min(99999/larger_window_bound, 999.99))
				
				updateCamera(screen_width, screen_height, camera_zoom, new_zoom)
			
			else
			
				if tonumber(tbox.value) < tbox.low then
					tbox.value = tbox.low
				end
				
				if tonumber(tbox.value) > tbox.high then
					tbox.value = tbox.high
				end
			
			end
			
			if tbox.id == "grid.width" or tbox.id == "grid.height" or tbox.id == "grid.x" or tbox.id == "grid.y" then
			
				if tbox.id == "grid.width" then
					grid_w = tonumber(tbox.value)
				end
				
				if tbox.id == "grid.height" then
					grid_h = tonumber(tbox.value)
				end
				
				if tbox.id == "grid.x" then
					grid_x = tonumber(tbox.value)
				end
				
				if tbox.id == "grid.y" then
					grid_y = tonumber(tbox.value)
				end
				
			end
		
		else
			tbox.value = ui.secondary_text_orig
		end
		
		ui.textbox_selection_origin = ""
		ui.secondary_textbox = -1
		ui.active_textbox = ""
		
	elseif ui.textbox_selection_origin == "rename" then
	
		if ui.textbox_rename_layer ~= -1 then
				
			local this_item = ui.layer[ui.textbox_rename_layer]
			if this_item.name ~= ui.primary_text_orig then
				tm.store(TM_LAYER_RENAME, ui.textbox_rename_layer, ui.primary_text_orig, this_item.name)
				tm.step()
			end
		
		end
	
		ui.primary_text_orig = ""
		ui.textbox_selection_origin = ""
		ui.active_textbox = ""
		ui.textbox_rename_layer = -1
	
	elseif ui.textbox_selection_origin == "palette" then

		if ui.palette_changed then
			if palette.activeIsEditable and polygon.data[tm.polygon_loc] ~= nil then
				tm.store(TM_CHANGE_COLOR, palette.startingColor, palette.active)
				tm.step()
						
				local copy_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
				polygon.data[tm.polygon_loc].color = copy_col
				palette.updateAccentColor()
			end
		end
		
		ui.palette_changed = false
	
		ui.palette_textbox = 0
		ui.textbox_selection_origin = ""
		ui.active_textbox = ""
		
	end
	
end

function ui.keyboardHit(key)
	if ui.textbox_selection_origin == "popup" then
	
		local this_menu = ui.popup[ui.popup_sel_a][ui.popup_sel_b]
		if string.len(key) == 1 then
		
			if ui.popup[1][1].kind == "f.new" or ui.popup[1][1].kind == "i.setup" or ui.popup[1][1].kind == "f.as" then
			
				if this_menu.kind == "number" then
					if tonumber(key) ~= nil and string.len(this_menu.name) < 5 then
						this_menu.name = this_menu.name .. key
					end
				elseif font:getWidth(this_menu.name .. key) <= 240 then
					this_menu.name = this_menu.name .. key
				end
				
			end
			
		else
			if (key == "backspace") then
				this_menu.name = string.sub(this_menu.name, 0, string.len(this_menu.name) - 1)
			elseif (key == "return") then
				ui.popupLoseFocus(ui.popup[1][1].kind)
				ui.keyboard_last = ""
				ui.keyboard_test = ""
				ui.popup_enter = true
			end
		end
	
	elseif ui.textbox_selection_origin == "preview" then
		
		if string.len(key) == 1 then
			
			if ui.preview_textbox_locked == false then
			
				local allowed_keys = (tonumber(key) ~= nil) or ((key == ".") and (string.find(ui.preview_textbox,"%.") == nil))
				if allowed_keys and string.len(ui.preview_textbox) < 5 then
					ui.preview_textbox = ui.preview_textbox .. key
					
					if ui.preview_textbox ~= "." then
						if ui.preview_textbox_mode == "px" then
							local larger_window_bound = math.max(document_w, document_h)
							ui.preview_zoom = tonumber(ui.preview_textbox) / larger_window_bound
						else
							ui.preview_textbox = math.floor(ui.preview_textbox)
							ui.preview_zoom = ui.preview_textbox / 100
						end
					end
					
				end
				
			end
			
		else
			if (key == "backspace") then
				ui.preview_textbox = string.sub(ui.preview_textbox, 0, string.len(ui.preview_textbox) - 1)
			elseif (key == "return") then
				ui.textbox_selection_origin = "preview"
				ui.popupLoseFocus("preview")
				ui.keyboard_last = ""
				ui.keyboard_test = ""
			end
		end
	
	elseif ui.textbox_selection_origin == "toolbar" then
	
		local tbox = ui.primary_panel[ui.primary_textbox]
	
		if string.len(key) == 1 then
			
			if ui.primary_textbox ~= -1 then
			
				local textbox_input_max = 5
				if tbox.id == "art.opacity" then
					textbox_input_max = 3
				end
			
				local allowed_keys = (tonumber(key) ~= nil)
				if allowed_keys and string.len(tbox.value) < textbox_input_max then
					tbox.value = tbox.value .. key					
				end
				
			end
			
		else
			if (key == "backspace") then
				tbox.value = string.sub(tbox.value, 0, string.len(tbox.value) - 1)
			elseif (key == "return") then
				ui.textbox_selection_origin = "toolbar"
				ui.popupLoseFocus("toolbar")
				ui.keyboard_last = ""
				ui.keyboard_test = ""
			end
		end
	
	elseif ui.textbox_selection_origin == "toolbar2" then
	
		local tbox = ui.secondary_panel[ui.secondary_textbox]
	
		if string.len(key) == 1 then
			
			if ui.secondary_textbox ~= -1 then
			
				local allowed_keys = (tonumber(key) ~= nil)
				
				if ui.secondary_panel[ui.secondary_textbox].id == "zoom.type" and ui.zoom_textbox_mode == "px" then
					allowed_keys = (tonumber(key) ~= nil) or ((key == ".") and (string.find(ui.secondary_panel[ui.secondary_textbox].value,"%.") == nil))
				end
				
				if allowed_keys and string.len(tbox.value) < 5 then
					tbox.value = tbox.value .. key					
				end
				
			end
			
		else
			if (key == "backspace") then
				tbox.value = string.sub(tbox.value, 0, string.len(tbox.value) - 1)
			elseif (key == "return") then
				ui.textbox_selection_origin = "toolbar2"
				ui.popupLoseFocus("toolbar2")
				ui.keyboard_last = ""
				ui.keyboard_test = ""
			end
		end
	
	elseif ui.textbox_selection_origin == "rename" then
	
		local this_menu = ui.layer[ui.textbox_rename_layer]
	
		if string.len(key) == 1 then
		
			if font:getWidth(this_menu.name .. key) <= 105 then
				this_menu.name = this_menu.name .. key
			end
			
		else
			if (key == "backspace") then
				this_menu.name = string.sub(this_menu.name, 0, string.len(this_menu.name) - 1)
			elseif (key == "return") then
				ui.popupLoseFocus("rename")
				ui.keyboard_last = ""
				ui.keyboard_test = ""
				ui.popup_enter = true
			end
		end
	
	elseif ui.textbox_selection_origin == "palette" then
	
		local o_col = ui.palette_text_original
		local defer_enter = false
		local col_changed = false
		
		if string.len(key) == 1 then
		
			if tonumber(key) ~= nil and string.len(ui.palette_text_entry) <= 3 then
				ui.palette_text_entry = ui.palette_text_entry .. key
				ui.palette_changed = true
				col_changed = true
				if tonumber(ui.palette_text_entry) > 255 then
					ui.palette_text_entry = 255
				end
			end
			
		else
			if (key == "backspace") then
				ui.palette_text_entry = string.sub(ui.palette_text_entry, 0, string.len(ui.palette_text_entry) - 1)
				ui.palette_changed = true
				col_changed = true
			elseif (key == "return") then
				defer_enter = true
			end
		end
		
		if string.len(tostring(ui.palette_text_entry)) == 0 then
			ui.palette[ui.palette_textbox].value = tonumber(ui.palette_text_original)
			ui.palette_changed = false
			col_changed = true
		else
			ui.palette[ui.palette_textbox].value = tonumber(ui.palette_text_entry)
		end
		
		if col_changed then
			if ui.palette_textbox < 4 then
				palette.updateFromRGB()
			else
				palette.updateFromHSL()
			end
		end
		
		if defer_enter then
		
			ui.popupLoseFocus("palette")
			ui.keyboard_last = ""
			ui.keyboard_test = ""
			ui.popup_enter = true
		
		end
		
	end
	
end

function ui.keyboardRepeat(dt)
	local hit, pause, pause2, repeater
	hit = 6
	pause = 35
	pause2 = pause + 2
	repeater = 2

	ui.keyboard_timer = ui.keyboard_timer + (1 * dt * 60)
	
	if (not ui.keyboard_timer_hit) and (ui.keyboard_timer > hit) then
		ui.keyboardHit(ui.keyboard_last)
		ui.keyboard_timer_hit = true
	end
	
	if ((ui.keyboard_timer > pause) and (ui.keyboard_timer < pause2)) or (ui.keyboard_timer > pause2 + repeater) then
		ui.keyboardHit(ui.keyboard_last)
		ui.keyboard_timer = pause2
	end
end

function ui.addLayer()

	local layer = {}
	layer.visible = true
	
	if ui.layer[1] == nil then
		layer.count = 1
	else
		layer.count = #ui.layer + #ui.layer_trash + 1
	end
	
	layer.name = "Layer " .. layer.count
	
	table.insert(ui.layer, layer)

end

function ui.importLayer(v, n)

	local layer = {}
	layer.visible = v
	
	if ui.layer[1] == nil then
		layer.count = 1
	else
		layer.count = #ui.layer + 1
	end
	
	layer.name = n
	
	table.insert(ui.layer, layer)

end

function ui.moveLayer(old, new)

	local lyr_copy = ui.layer[old]
	table.remove(ui.layer, old)
	table.insert(ui.layer, new, lyr_copy)

end

function ui.deleteLayer(old)

	local lyr_copy = ui.layer[old]
	lyr_copy.visible = true
	table.insert(ui.layer_trash, lyr_copy)
	table.remove(ui.layer, old)

end

function ui.swapLayer(new, use_my)

	storeMovedVertices()
	vertex_selection_mode = false
	vertex_selection = {}

	storeMovedShapes()
	shape_selection_mode = false
	shape_selection = {}
	multi_shape_selection = false

	ui.lyr_clicked = new
	ui.lyr_click_y = love.mouse.getY()
	
	if not use_my then
		ui.lyr_clicked = 0
		ui.lyr_click_y = 0
	end

	local old_layer = tm.polygon_loc
	tm.polygon_loc = ui.layer[new].count
	palette.updateAccentColor()

	local _tm_copy, skip_tm

	if (tm.data[tm.location - 1] ~= nil) then
		_tm_copy = tm.data[tm.location - 1][1]
		skip_tm = false
	else
		skip_tm = true
	end

	-- To reduce undo/redo ram usage, change previous swap to new layer instead of making another swap
	if (not skip_tm) and (_tm_copy.action == TM_PICK_LAYER) and (_tm_copy.created_layer == false) and (_tm_copy.trash_layer == false) then
		_tm_copy.new = tm.polygon_loc
	else
		if old_layer ~= tm.polygon_loc then -- If we swap to the current active layer, don't register the swap
			tm.store(TM_PICK_LAYER, old_layer, tm.polygon_loc, false, false)
			tm.step()
		end
	end	
	
end

function ui.resizeWindow()

	ui.popup_x = math.floor((screen_width / 2) - (ui.popup_w / 2))
	ui.popup_y = math.floor((screen_height / 2) - (ui.popup_h / 2))
	
	-- the preview window is set to be 90% of the screen width and screen height
	local new_h_max = math.floor((screen_height - 56) * 0.9)
	local new_w_max = math.floor((screen_width - 208 - 64) * 0.9)
	
	if ui.preview_h_max ~= new_h_max or ui.preview_w_max ~= new_w_max then
		ui.preview_h_max = new_h_max
		ui.preview_w_max = new_w_max
		
		lock_w_max, lock_w_min, lock_h_max, lock_h_min = ui.preview_w_max, ui.preview_w_min, ui.preview_h_max, ui.preview_h_min
		
		if ui.preview_w < ui.preview_w_min then ui.preview_w = ui.preview_w_min ui.mouse_lock_x = lock_w_min end
		if ui.preview_h < ui.preview_h_min then ui.preview_h = ui.preview_h_min ui.mouse_lock_y = lock_h_min end
		if ui.preview_w > ui.preview_w_max then ui.preview_w = ui.preview_w_max ui.mouse_lock_x = lock_w_max end
		if ui.preview_h > ui.preview_h_max then ui.preview_h = ui.preview_h_max ui.mouse_lock_y = lock_h_max end
	end
	
	if ui.preview_x < 65 then ui.preview_x = 65 ui.mouse_lock_x = math.floor(ui.preview_w/2) end
	if ui.preview_x > screen_width - ui.preview_w - 209 then ui.preview_x = screen_width - ui.preview_w - 209 ui.mouse_lock_x = math.floor(ui.preview_w/2) end
	if ui.preview_y < 55 then ui.preview_y = 55 ui.mouse_lock_y = 12 end
	if ui.preview_y > screen_height - 25 then ui.preview_y = screen_height - 25 end
	
	local lock_w_max, lock_w_min, lock_h_max, lock_h_min = 0,0,0,0
	
	local drag = ui.preview_drag_corner
	if drag == 1 or drag == 2 or drag == 8 then --NW, N, W
		
		if drag == 1 or drag == 2 then
		
			local orig_y, orig_h = ui.preview_y, ui.preview_h
		
			if ui.preview_h < ui.preview_h_min then
			
				ui.preview_y = math.min(ui.preview_y, ui.preview_h_init_pos - ui.preview_h_min)
				ui.preview_h = math.max(ui.preview_h, ui.preview_h_min)
				
				if (orig_y ~= ui.preview_y) or (orig_h ~= ui.preview_h) then ui.mouse_lock_y = 0 end
			
			end
			
			if ui.preview_h > ui.preview_h_max then
			
				ui.preview_y = math.max(ui.preview_y, ui.preview_h_init_pos - ui.preview_h_max)
				ui.preview_h = math.min(ui.preview_h, ui.preview_h_max)
				
				if (orig_y ~= ui.preview_y) or (orig_h ~= ui.preview_h) then ui.mouse_lock_y = 0 end
			
			end
		
		end
		
		if drag == 1 or drag == 8 then
		
			local orig_x, orig_w = ui.preview_x, ui.preview_w
		
			if ui.preview_w < ui.preview_w_min then
			
				ui.preview_x = math.min(ui.preview_x, ui.preview_w_init_pos - ui.preview_w_min)
				ui.preview_w = math.max(ui.preview_w, ui.preview_w_min)
				
				if (orig_x ~= ui.preview_x) or (orig_w ~= ui.preview_w) then ui.mouse_lock_x = 0 end
			
			end
			
			if ui.preview_w > ui.preview_w_max then
			
				ui.preview_x = math.max(ui.preview_x, ui.preview_w_init_pos - ui.preview_w_max)
				ui.preview_w = math.min(ui.preview_w, ui.preview_w_max)
				
				if (orig_x ~= ui.preview_x) or (orig_w ~= ui.preview_w) then ui.mouse_lock_x = 0 end
			
			end
		
		end
		
	elseif drag == 3 then --NE
		
		local orig_y, orig_h = ui.preview_y, ui.preview_h
	
		if ui.preview_h < ui.preview_h_min then
		
			ui.preview_y = math.min(ui.preview_y, ui.preview_h_init_pos - ui.preview_h_min)
			ui.preview_h = math.max(ui.preview_h, ui.preview_h_min)
			
			if (orig_y ~= ui.preview_y) or (orig_h ~= ui.preview_h) then ui.mouse_lock_y = 0 end
		
		end
		
		if ui.preview_h > ui.preview_h_max then
		
			ui.preview_y = math.max(ui.preview_y, ui.preview_h_init_pos - ui.preview_h_max)
			ui.preview_h = math.min(ui.preview_h, ui.preview_h_max)
			
			if (orig_y ~= ui.preview_y) or (orig_h ~= ui.preview_h) then ui.mouse_lock_y = 0 end
		
		end
		
		if ui.preview_w < ui.preview_w_min then ui.preview_w = ui.preview_w_min ui.mouse_lock_x = ui.preview_w_min end
		if ui.preview_w > ui.preview_w_max then ui.preview_w = ui.preview_w_max ui.mouse_lock_x = ui.preview_w_max end
		
	elseif drag == 4 or drag == 5 or drag == 6 then -- E, SE, S
		lock_w_max, lock_w_min, lock_h_max, lock_h_min = ui.preview_w_max, ui.preview_w_min, ui.preview_h_max, ui.preview_h_min
		
		if ui.preview_w < ui.preview_w_min then ui.preview_w = ui.preview_w_min ui.mouse_lock_x = lock_w_min end
		if ui.preview_h < ui.preview_h_min then ui.preview_h = ui.preview_h_min ui.mouse_lock_y = lock_h_min end
		if ui.preview_w > ui.preview_w_max then ui.preview_w = ui.preview_w_max ui.mouse_lock_x = lock_w_max end
		if ui.preview_h > ui.preview_h_max then ui.preview_h = ui.preview_h_max ui.mouse_lock_y = lock_h_max end
		
	elseif drag == 7 then --SW
		
		if ui.preview_h < ui.preview_h_min then ui.preview_h = ui.preview_h_min ui.mouse_lock_y = ui.preview_h_min end
		if ui.preview_h > ui.preview_h_max then ui.preview_h = ui.preview_h_max ui.mouse_lock_y = ui.preview_h_max end
		
		local orig_x, orig_w = ui.preview_x, ui.preview_w
		
		if ui.preview_w < ui.preview_w_min then
		
			ui.preview_x = math.min(ui.preview_x, ui.preview_w_init_pos - ui.preview_w_min)
			ui.preview_w = math.max(ui.preview_w, ui.preview_w_min)
			
			if (orig_x ~= ui.preview_x) or (orig_w ~= ui.preview_w) then ui.mouse_lock_x = 0 end
		
		end
		
		if ui.preview_w > ui.preview_w_max then
		
			ui.preview_x = math.max(ui.preview_x, ui.preview_w_init_pos - ui.preview_w_max)
			ui.preview_w = math.min(ui.preview_w, ui.preview_w_max)
			
			if (orig_x ~= ui.preview_x) or (orig_w ~= ui.preview_w) then ui.mouse_lock_x = 0 end
		
		end
		
	end

end

function ui.update(dt)

	ui.mouse_x_previous, ui.mouse_y_previous = ui.mouse_x, ui.mouse_y
	ui.mouse_x, ui.mouse_y = love.mouse.getX(), love.mouse.getY()
	local mx, my = ui.mouse_x, ui.mouse_y
	local ui_active = false
	local has_interaction = (mouse_switch == _PRESS or ui.context_menu[1] ~= nil)
	
	local col_title_bar = false
	local col_cont_menu = false
	
	if ui.tooltip_active ~= -1 then
		ui.tooltip_timer = math.min(ui.tooltip_timer + (60 * dt), 60)
		if ui.tooltip_timer < 51 then
			ui.tooltip_x = love.mouse.getX()
			ui.tooltip_y = love.mouse.getY()
		end
		
		if mouse_switch == _PRESS or rmb_switch == _PRESS then
			ui.tooltip_active = -1
		end
	end
	
	ui.tooltip_disable = true
	
	if ui.context_menu[1] == nil and f2_key ~= PRESS and mouse_switch == _PRESS and ui.textbox_selection_origin == "rename" and ui.rename_click == false then
		ui.popupLoseFocus("rename")
		ui_active = true
	end
	
	if ui.context_menu[1] == nil and mouse_switch == _PRESS and ui.textbox_selection_origin == "palette" then
		ui.popupLoseFocus("palette")
		ui_active = true
	end
	
	local disabled_prompt = (ui.popup[1] ~= nil and ui.popup[1][1].kind == "save.disabled")
	
	-- Check collision on title bar
	if my < 24 and not disabled_prompt then
	
		local i
		local title_len = 12
		local hit_item = false
		for i = 1, #ui.title do
			
			local title_size = font:getWidth(ui.title[i].name)
			
			-- If mouse is on top of menu item
			if mx >= title_len - 4 and mx <= title_len + title_size + 3 then
			
				-- If menu item was interacted with
				if has_interaction then
					-- Close context menu if its already open
					if mouse_switch == _PRESS and ui.context_menu[1] ~= nil then
						ui.context_menu = {}
					else -- Otherwise, open the context menu
						ui.loadCM(title_len - 6, 24, ui.title[i].ref)
						col_title_bar = true
						ui.preview_palette_enabled = false
					end
				end
			
				-- Highlight portion of menu where the mouse is
				ui.title_active = true
				ui.title_x = title_len - 6
				ui.title_y = 2
				ui.title_w = title_size + 12
				ui.title_h = 21
				hit_item = true
			end
			
			title_len = title_len + title_size + 15
		end
		
		-- Remove menu selection if not touching a button on the menu
		if ui.context_menu[1] == nil and not hit_item then
			ui.title_active = false
		end
		
		ui_active = true
	
	elseif ui.context_menu[1] == nil then
		-- Remove menu selection when not highlighting the menu
		ui.title_active = false
	end
	-- End check collision on title bar
	
	-- Check collision on context menu
	if ui.context_menu[1] ~= nil and not ui.preview_dragging then
		
		local mx_on_menu, my_on_menu
		local exit_cm = false
		
		mx_on_menu = (mx >= ui.context_x) and (mx <= ui.context_x + ui.context_w)
		my_on_menu = (my >= ui.context_y) and (my <= ui.context_y + ui.context_h)
		
		-- If context menu was interacted with
		if mx_on_menu and my_on_menu then
		
			if mouse_switch == _PRESS then
				local i
				local h = 0
				for i = 1, #ui.context_menu do
				
					-- If entry in the menu
					if ui.context_menu[i]._break == nil then
					
						local low = ui.context_y + h + 8
						local upp = low + 20
						
						if my >= low and my <= upp then
							if ui.context_menu[i].active then
								ui.loadPopup(ui.context_menu[i].ref)
								col_cont_menu = true
								ui.preview_palette_enabled = false
							end
							exit_cm = ui.context_menu[i].active
						end
						
						h = h + 22
					else -- If entry is a break
						h = h + 11
					end
				end
			end
		
			ui_active = true
		end
		
		if exit_cm then
			ui.context_menu = {}
			ui.title_active = false
		end
	
	end
	
	if mouse_switch == _PRESS and col_cont_menu == false and col_title_bar == false then
		ui.context_menu = {}
		ui.title_active = false
	end
	
	if mouse_switch == _PRESS and ui_active == false then
	
		local color_area = -1
		if mx >= screen_width - 201 and mx <= screen_width - 10 and my >= 208 and my <= 208 + 95 then
			color_area = 1
		end
		
		local px, py, pw, ph = ui.preview_x, ui.preview_y, ui.preview_w, ui.preview_h
		local ix, iy = px + 36 + 49, py + ph - 50 + 24
		-- Background color
		if (mx >= px + pw - 26) and (mx <= px + pw - 3) and (my >= iy) and (my <= iy + 23) then
			color_area = 2
		end
		
		ui.cm_color_area = color_area
	
	end
	
	ui.allow_keyboard_input = (ui.textbox_selection_origin ~= "")
	
	-- Add keyboard input if interacting with a textbox
	if ui.allow_keyboard_input then
		-- Update cursor flashing
		ui.input_cursor = ui.input_cursor + (60 * dt)

		if ui.input_cursor > 37 then
			ui.input_cursor = 0
			ui.input_cursor_visible = not ui.input_cursor_visible
		end
	
		ui.keyboardRepeat(dt)
	end
	
	-- Copy and paste for palette
	if input.ctrlCombo(c_key) then
		local new_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
		palette.copy = new_col
	end
	
	if input.ctrlCombo(v_key) and palette.canPaste and palette.copy ~= nil and ui.preview_palette_enabled then
		palette.colors[palette.slot + 1] = palette.copy
		palette.active = palette.colors[palette.slot + 1]
		palette.updateAccentColor()
		palette.updateFromBoxes()
		
		local copy_again = palette.colors[palette.slot + 1]
		local new_col = {copy_again[1], copy_again[2], copy_again[3], copy_again[4]}
		palette.copy = new_col
	end
	
	-- Check collision of palette
	local psize = 16
	local palw = (13 * psize)
	local palx, paly = screen_width - palw, 53
	local palh = 300
	local mx_on_menu, my_on_menu
	mx_on_menu = (mx >= palx) and (mx <= palx + palw)
	my_on_menu = (my >= paly) and (my <= paly + palh)
	if ui.palette_textbox == 0 and mouse_switch == _PRESS and mx_on_menu and my_on_menu then
		
		if my >= 69 and my <= 69 + 18 then -- RGB/HSL buttons
			
			if mx >= palx - 4 + 8 and mx <= palx - 4 + 25 + 10 + 8 then
				ui.palette_mode = "RGB"
				palette.canPaste = false
			elseif mx >= palx + 36 + 8 and mx <= palx + 36 + 24 + 10 + 8 then
				ui.palette_mode = "HSL"
				palette.canPaste = false
			end
			
		elseif my > 208 and my < 208 + (psize * palette.h) then -- Color picker
			local raw_x = mx - palx - 8
			local raw_y = my - 208
			local sel_x, sel_y
			sel_x = math.floor(raw_x / 16)
			if sel_x > -1 and sel_x < 12 then
				ui.preview_palette_enabled = true
				sel_y = math.floor(raw_y / 16)
				local final_col = (sel_y * palette.w) + sel_x
				palette.slot = final_col
				
				if palette.active == palette.colors[final_col + 1] then
				
					if artboard.active == false then
				
						palette.activeIsEditable = true
						
						if polygon.data[tm.polygon_loc] ~= nil then
							tm.store(TM_CHANGE_COLOR, polygon.data[tm.polygon_loc].color, palette.active)
							tm.step()
							
							palette.startingColor = polygon.data[tm.polygon_loc].color
							
							local copy_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
							polygon.data[tm.polygon_loc].color = copy_col
							palette.updateAccentColor()
						end
						
					else
						-- Stop dynamic polygon palette changing when in the artboard
						palette.activeIsEditable = false
					end
					
				else
					palette.active = palette.colors[final_col + 1]
					palette.updateFromBoxes()
					palette.updateAccentColor()
					palette.activeIsEditable = false
				end
				
				palette.canPaste = true
			end
		end
		
		-- Scroll bar
		local ix, iy = screen_width - 50, 79
		if mx >= ix - 147 and mx <= ix - 147 + 122 then
			local i
			for i = 1, 3 do
				local ypos = iy + 25 + (28 * (i - 1)) - 1
				if my >= ypos and my <= ypos + 21 then
					local hsl = 0
					if ui.palette_mode == "HSL" then hsl = 3 end
					ui.palette_slider = i + hsl
					palette.canPaste = false
					
					if palette.activeIsEditable and polygon.data[tm.polygon_loc] ~= nil then
						palette.startingColor = polygon.data[tm.polygon_loc].color
					end
					
				end
			end
		end
		
		-- Textboxes
		local tb = 1
		local h = 0
		while tb <= 3 do
			if (mx >= ix - 5) and (mx <= ix + 41 + h - 1) and (my >= iy + 25 + h - 1) and (my <= iy + 45 + h - 1) then
				
				local using_hsv = 0
				if ui.palette_mode == "HSL" then
					using_hsv = 3
				end
				
				local old_cc = palette.active
				if polygon.data[tm.polygon_loc] ~= nil then
					local old_cc = polygon.data[tm.polygon_loc].color
				end
				
				local copy_cc = {}
				copy_cc[1], copy_cc[2], copy_cc[3], copy_cc[4] = old_cc[1], old_cc[2], old_cc[3], old_cc[4]
				palette.startingColor = copy_cc
				
				ui.palette_textbox = tb + using_hsv
				ui.palette_text_entry = ui.palette[tb + using_hsv].value
				ui.palette_text_original = ui.palette_text_entry
				
				ui.popupLoseFocus("palette")
				ui.textbox_selection_origin = "palette"
				
				if ui.primary_textbox ~= -1 then
					ui.textbox_selection_origin = "toolbar"
					ui.popupLoseFocus("toolbar")
				end
				
				if ui.secondary_textbox ~= -1 then
					ui.textbox_selection_origin = "toolbar2"
					ui.popupLoseFocus("toolbar2")
				end
				
				tb = 4
			end
			tb = tb + 1
			h = h + 28
		end
		
		ui_active = true
	end
	
	if mouse_switch == _ON and ui.palette_slider ~= 0 then
		local ix = screen_width - 50
		ui.palette[ui.palette_slider].value = math.floor(lume.clamp(mx - ix + 147, 0, 122)/122 * 255)
		if ui.palette_slider < 4 then
			palette.updateFromRGB()
		else
			palette.updateFromHSL()
		end
		
		if palette.activeIsEditable and polygon.data[tm.polygon_loc] ~= nil then
			polygon.data[tm.polygon_loc].color = palette.active
			palette.updateAccentColor()
		end
		
	elseif mouse_switch == _RELEASE and ui.palette_slider ~= 0 then
		if palette.activeIsEditable and polygon.data[tm.polygon_loc] ~= nil then
			tm.store(TM_CHANGE_COLOR, palette.startingColor, palette.active)
			tm.step()
					
			local copy_col = {palette.active[1], palette.active[2], palette.active[3], palette.active[4]}
			polygon.data[tm.polygon_loc].color = copy_col
			palette.updateAccentColor()
		end
	
		ui.palette_slider = 0
	end
	
	-- Check collision on layer menu
	local layx, layy = screen_width - 208, 352
	local layw = 208 - 2 - 16
	local layh = screen_height - 403 - 48
	
	-- tooltips for add/delete
	if (mx >= layx + 4) and (mx <= layx + 4 + 24) and (my >= layy + 13) and (my <= layy + 13 + 24) then
		ui.setTooltip(TIP_ADD_LAYER)
	end
	
	if (mx >= layx + 4 + 24 + 4) and (mx <= layx + 4 + 24 + 24 + 4) and (my >= layy + 13) and (my <= layy + 13 + 24) then
		ui.setTooltip(TIP_CLONE_LAYER)
	end
	
	if (mx >= layx + 4 + 24 + 4 + 24 + 4) and (mx <= layx + 4 + 24 + 24 + 4 + 24) and (my >= layy + 13) and (my <= layy + 13 + 24) then
		ui.setTooltip(TIP_DELETE_LAYER)
	end
	
	if (mouse_switch == _PRESS) and (mx >= screen_width - 208) and (my >= layy) then
	
		ui.preview_palette_enabled = false
		-- Scroll bar
		if (mx >= screen_width - 16) and (my >= layy + 41 + 14) and (my <= 14 + screen_height - 34 - 48) then
			ui.lyr_scroll = true
		end
		
		-- Top scroll button
		if (mx >= screen_width - 16) and (mx <= screen_width - 1) and (my >= layy + 41) and (my <= layy + 41 + 14) then
			ui.lyr_dir = "up"
			ui.lyr_spd = 1
			ui.scrollButton()
		end
		
		-- Bottom scroll button
		if (mx >= screen_width - 16) and (mx <= screen_width - 1) and (my >= screen_height - 24 - 48) and (my <= screen_height - 10 - 48) then
			ui.lyr_dir = "down"
			ui.lyr_spd = 1
			ui.scrollButton()
		end
		
		if (document_w ~= 0) then
			
			-- Add layer button
			if (mx >= layx + 4) and (mx <= layx + 4 + 24) and (my >= layy + 13) and (my <= layy + 13 + 24) then
				
				ui.layerAddButton()
				
				ui.lyr_scroll_percent = 0
				ui.lyr_button_active = 1
			end
			
			-- Clone layer button
			if (mx >= layx + 4 + 24 + 4) and (mx <= layx + 4 + 24 + 24 + 4) and (my >= layy + 13) and (my <= layy + 13 + 24) then
				
				if polygon.data[tm.polygon_loc] ~= nil then
				
					storeMovedVertices()
					vertex_selection_mode = false
					vertex_selection = {}
					
					storeMovedShapes()
					shape_selection_mode = false
					shape_selection = {}
					multi_shape_selection = false
					
					ui.layerCloneButton(true, false)
					
					ui.lyr_scroll_percent = 0
					
				end
				
				ui.lyr_button_active = 3
				
			end
			
			-- Delete layer button
			if (mx >= layx + 4 + 24 + 4 + 24 + 4) and (mx <= layx + 4 + 24 + 24 + 4 + 24) and (my >= layy + 13) and (my <= layy + 13 + 24) then
				
				if (#ui.layer > 1) then
					ui.layerDeleteButton()
				end
				
				ui.lyr_button_active = 2
				
			end
			
			-- Check if layer was clicked on
			if (mx >= layx + 32) and (mx <= layx + layw) and (my >= layy + 40) and (my <= layy + 40 + layh) then
			
				local moffset = my - 392
			
				local layer_amt = #ui.layer
				local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
				local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
				
				local layer_hit = layer_amt - math.floor((moffset + scroll_offset) / 25)
				
				-- Layer was clicked on, switch layers
				if ui.layer[layer_hit] ~= nil then
					ui.swapLayer(layer_hit, true)
				end
				
			end
			
			-- Check if layer hide button was clicked on
			if (mx >= layx + 1) and (mx <= layx + 31) and (my >= layy + 40) and (my <= layy + 40 + layh) then
			
				local moffset = my - 392
			
				local layer_amt = #ui.layer
				local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
				local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
				
				local layer_hit = layer_amt - math.floor((moffset + scroll_offset) / 25)
				
				-- Layer was clicked on, switch layers
				if ui.layer[layer_hit] ~= nil then
					ui.layer[layer_hit].visible = not ui.layer[layer_hit].visible
				end
				
			end
			
		end
		
		ui_active = true
			
	end
	
	if double_click_timer_rename ~= 0 then

		double_click_timer_rename = double_click_timer_rename + (60 * dt)
	
		if double_click_timer_rename > 30 then
			double_click_timer_rename = 0
		end
	
	end

	-- Check if layer name was clicked on, rename layer
	if mouse_switch == _PRESS and (mx >= layx + 77) and (mx <= layx + layw) and (my >= layy + 40) and (my <= layy + 40 + layh) then
	
		local moffset = my - 392
	
		local layer_amt = #ui.layer
		local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
		local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
		
		local layer_hit = layer_amt - math.floor((moffset + scroll_offset) / 25)
		
		if layer_amt > 0 and ui.layer[layer_hit] ~= nil then
			ui.popupLoseFocus("rename")
			
			if double_click_timer_rename > 0 and double_click_timer_rename < 14 then
		
				ui.textbox_selection_origin = "rename"
				ui.textbox_rename_layer = layer_hit
				ui.primary_text_orig = ui.layer[layer_hit].name
				ui.rename_click = true
				
				double_click_timer_rename = 0
			else
				double_click_timer_rename = 0
			end
		
			double_click_timer_rename = double_click_timer_rename + (60 * dt)
			
			ui_active = true
		end
		
	else
		ui.rename_click = false
	end
	
	if (mouse_switch == _ON) and ui.lyr_clicked ~= 0 then
	
		local layer_element_size = math.max((25 * #ui.layer), 0)
		
		if layer_element_size > layh then
		
			-- Scroll layer window when placing a layer outside of bounds
			local scrolling = false
			
			if (my <= 392) then
				ui.lyr_dir = "up"
				ui.lyr_spd = 3
				scrolling = true
			end
			
			if (my >= screen_height - 10 - 48) then
				ui.lyr_dir = "down"
				ui.lyr_spd = 3
				scrolling = true
			end
			
			if not scrolling then
				ui.lyr_dir = ""
				ui.lyr_timer = 0
			end
		
		end
	
	end
	
	if (mouse_switch == _RELEASE) and ui.lyr_button_active ~= -1 then
		ui.lyr_button_active = -1
	end
	
	if (ui.lyr_scroll) then
		ui.lyr_scroll_percent = lume.clamp(my - 4 - layy - 40 - 16, 0, layh - 32)/(layh - 32)
		ui_active = true
	end
	
	if (mx >= layx + 1) and (mx <= layx + layw + 16) and (my >= layy + 40) and (my <= layy + 40 + layh) and mouse_wheel_y ~= 0 then
		local layer_element_size = math.max((25 * #ui.layer), 0)
		ui.lyr_scroll_percent = ui.lyr_scroll_percent - (mouse_wheel_y/layer_element_size * 60 * (layer_element_size/13) * dt)
		ui.lyr_scroll_percent = lume.clamp(ui.lyr_scroll_percent, 0, 1)
		mouse_wheel_y = 0
	end
	
	if (ui.lyr_scroll) and ((mouse_switch == _OFF) or (mouse_switch == _RELEASE)) then
		ui.lyr_scroll = false
	end
	
	-- Rearrage layers
	if (ui.lyr_clicked ~= 0) and ((mouse_switch == _OFF) or (mouse_switch == _RELEASE)) then
		
		local layer_amt = #ui.layer
		local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
			
		if (layer_element_size == 0 and not ui.lyr_scroll) then
			ui.lyr_scroll_percent = 0
		end
		
		local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
	
		local moffset = my - 392
		local y_test = (moffset + scroll_offset)
		local layer_top = math.floor((moffset + scroll_offset) / 25) * 25
		local layer_num = layer_amt - math.floor((moffset + scroll_offset) / 25)
		
		-- Make it so we can't swap with layers that are not visible on screen (above the layer window)
		if (my >= 392-6) and (my <= screen_height - 52) then
	
			-- If layer move is within bounds
			if (layer_num >= 0 and layer_num <= layer_amt) then
				
				-- And within 8 pixels of the layer being moved to
				if (math.abs(y_test - layer_top) < 8) or (math.abs(y_test - layer_top + 24) < 8) then
					
					-- Swap layers
					local swap_pos = layer_num + 1
					if layer_num >= ui.lyr_clicked then
						swap_pos = layer_num
					end
					
					if (ui.lyr_clicked ~= swap_pos) then
						if ui.textbox_selection_origin == "rename" then
							ui.popupLoseFocus("rename")
						end
					
						ui.moveLayer(ui.lyr_clicked, swap_pos)
						tm.store(TM_MOVE_LAYER, ui.lyr_clicked, swap_pos)
						tm.step()
					end
					
				end
				
			elseif (layer_num >= 0) and (y_test >= -6) then -- Trying to move 6 pixels above top layer
			
				-- Swap to top position
				if (ui.lyr_clicked ~= layer_num - 1) then
					if ui.textbox_selection_origin == "rename" then
						ui.popupLoseFocus("rename")
					end
				
					ui.moveLayer(ui.lyr_clicked, layer_num - 1)
					tm.store(TM_MOVE_LAYER, ui.lyr_clicked, layer_num - 1)
					tm.step()
				end
			
			end
		
		end
	
		ui.lyr_clicked = 0
		ui.lyr_click_y = 0
	end
	
	-- Timer for scroll buttons
	if (ui.lyr_dir ~= "") and ((mouse_switch ~= _OFF) and (mouse_switch ~= _RELEASE)) then
		ui.lyr_timer = ui.lyr_timer + (60 * dt)
		
		if ui.lyr_timer > 26 then
			ui.scrollButton()
			ui.lyr_timer = ui.lyr_timer - (5 * ui.lyr_spd)
		end
		
	else
		ui.lyr_dir = ""
		ui.lyr_timer = 0
	end
	
	-- Check toolbar disabled buttons
	if artboard.active == false then
		local tloc, tcur, tlen = tm.location, tm.cursor, tm.length
		ui.toolbar[ui.toolbar_undo].active = (tloc > tcur) and (tcur ~= 0)
		ui.toolbar[ui.toolbar_redo].active = (tloc < tlen)
	else
		-- TODO: Fix once the artboard is more finished, see artboard.undo()
		ui.toolbar[ui.toolbar_undo].active = true
		ui.toolbar[ui.toolbar_redo].active = true
	end
	
	ui.toolbar[ui.toolbar_preview].active = not ui.preview_active
	
	if document_w == 0 then
		ui.toolbar[ui.toolbar_polygon].active = false
		ui.toolbar[ui.toolbar_ellipse].active = false
		ui.toolbar[ui.toolbar_artboard].active = false
		ui.toolbar[ui.toolbar_polyline].active = false
		ui.toolbar[ui.toolbar_grid].active = false
		ui.toolbar[ui.toolbar_pick].active = false
		ui.toolbar[ui.toolbar_preview].active = false
		ui.toolbar[ui.toolbar_zoom].active = false
		ui.toolbar[ui.toolbar_select].active = false
		ui.toolbar[ui.toolbar_shape].active = false
	else
	
		if artboard.active == false then
			if polygon.kind == "polygon" and polygon.line == false then
				ui.toolbar[ui.toolbar_polygon].active = false
				ui.toolbar[ui.toolbar_ellipse].active = true
				ui.toolbar[ui.toolbar_artboard].active = true
				ui.toolbar[ui.toolbar_polyline].active = true
			elseif polygon.kind == "ellipse" then
				ui.toolbar[ui.toolbar_polygon].active = true
				ui.toolbar[ui.toolbar_ellipse].active = false
				ui.toolbar[ui.toolbar_artboard].active = true
				ui.toolbar[ui.toolbar_polyline].active = true
			else
				ui.toolbar[ui.toolbar_polygon].active = true
				ui.toolbar[ui.toolbar_ellipse].active = true
				ui.toolbar[ui.toolbar_artboard].active = true
				ui.toolbar[ui.toolbar_polyline].active = false
			end
		else
			ui.toolbar[ui.toolbar_polygon].active = true
			ui.toolbar[ui.toolbar_ellipse].active = true
			ui.toolbar[ui.toolbar_artboard].active = false
			ui.toolbar[ui.toolbar_polyline].active = true
		end
	end
	
	-- Check toolbar collision
	if ((mx >= 8) and (mx < 56) and (my >= 54)) and (not ui_active) then
		
		local add_one_because_top_is_even = 0
		ui.preview_palette_enabled = false
		local yy = my - 61
		
		local first_offset  = (yy >= 24 * 3)
		local second_offset = (yy >= (24 * 5) + 12)
		
		local first_break = (first_offset and yy < (24 * 3) + 12)
		local second_break = (second_offset and yy < (24 * 5) + 24)
		
		-- If not clicking between the line breaks
		if not (first_break or second_break) then
		
			local y_offset = 0
			
			-- Add an offset to offset the distance of the line breaks
			if second_offset then
				y_offset = 24
				add_one_because_top_is_even = 2
			elseif first_offset then
				y_offset = 12
				add_one_because_top_is_even = 1
			end
			
			local aa = math.floor((mx - 8)/24)
			local bb = math.floor((my - 61 - y_offset)/24)
			
			local key = ((bb * 2) + aa + 1) + add_one_because_top_is_even
			
			-- Don't crash if clicking a toolbar icon out of bounds
			local check_success = true
			if key < 1 or key > #ui.toolbar then
				key = 1
				check_success = false
			end
			
			if check_success and ui.toolbar[key].tooltip ~= nil then
				ui.setTooltip(ui.toolbar[key].tooltip)
			end
			
			if (mouse_switch == _PRESS) then
				local tool = ui.toolbar[key]
				local ignore_tool_active = (tool.ref == ".grid") or (tool.ref == ".pick") or (tool.ref == ".zoom") or (tool.ref == ".select") or (tool.ref == ".main")
				if (tool.ref ~= nil) and (tool.ref == ".prev") and document_w ~= 0 then
					tool.active = true
				end
				
				if (tool.active or ignore_tool_active) and (tool.ref ~= nil) and (check_success) and (ui.popup[1] == nil) and (ui.context_menu[1] == nil) then
				
					ui.toolbar_clicked = key
				
					-- Toolbar actions go here
					if tool.ref == ".main" then
						
						ui.shapeSelectButton()
						
					elseif tool.ref == ".select" then
						
						ui.selectionButton(true, true)
						
					elseif tool.ref == ".grid" then
					
						ui.gridButton()
						
					elseif tool.ref == ".zoom" then
						
						ui.zoomButton()
						
					elseif tool.ref == ".pick" then
					
						ui.pickColorButton()
						
					elseif tool.ref == ".prev" then
						
						ui.previewButton()
						
					elseif tool.ref == ".tri" then
						
						ui.triangleButton()
						
					elseif tool.ref == ".circ" then
						
						ui.ellipseButton()
						
					elseif tool.ref == ".artb" then
						
						ui.artboardButton()
						
					elseif tool.ref == ".line" then
						
						ui.polylineButton()
						
					elseif tool.ref == ".undo" then
						
						if artboard.active == false then
							editorUndo()
						else
							artboard.undo()
						end
						
					elseif tool.ref == ".redo" then
						
						if artboard.active == false then
							editorRedo()
						else
							artboard.redo()
						end
						
					end
					
				end
			
			end
			
		end
		
		ui_active = true
	end
	
	-- Make it so you can't place verts behind the toolbar
	if (mouse_switch == _PRESS) and (mx <= 64) then
		ui_active = true
	end
	
	if (mouse_switch == _RELEASE) and (ui.toolbar_clicked ~= -1) then
		ui.toolbar_clicked = -1
	end
	
	-- Update textboxes in toolbar panels
	if ui.primary_panel[1] ~= nil then
	
		if ui.primary_textbox == -1 then -- Update textboxes when inactive
	
			if ui.primary_panel[1].id == 'ellipse.seg' then
				local load_seg, load_ang = 0, 0
				if polygon.data[1] ~= nil and polygon.data[tm.polygon_loc] ~= nil and polygon.data[tm.polygon_loc].kind == "ellipse" then
					local myshape = polygon.data[tm.polygon_loc]
					load_seg = myshape.segments
					load_ang = myshape._angle
				else
					load_seg = polygon.segments
					load_ang = polygon._angle
				end
			
				ui.primary_panel[1].value = load_seg
				ui.primary_panel[2].value = load_ang
			end
			
			if ui.primary_panel[1].id == 'art.brush' then
				ui.primary_panel[1].value = artboard.brush_size
				ui.primary_panel[2].value = artboard.opacity * 100
			end
			
			if ui.primary_panel[1].id == 'polyline.size' then
				ui.primary_panel[1].value = polygon.thickness
			end
		
		else -- Preview shape while making changes
		
			if polygon.data[tm.polygon_loc] ~= nil and ui.primary_panel[1].id == 'ellipse.seg' then
				local myshape = polygon.data[tm.polygon_loc]
				local load_seg, load_ang = myshape.segments, myshape._angle
				
				-- Update with arrow keys
				if tonumber(ui.primary_panel[ui.primary_textbox].value) ~= nil and ((hz_dir ~= 0) or (vt_dir ~= 0)) then
					local this_t = ui.primary_panel[ui.primary_textbox]
					this_t.value = this_t.value + (hz_key * hz_dir) + (vt_key * vt_dir)
					
					if this_t.id == 'ellipse.ang' and this_t.value >= 360 then
						this_t.value = this_t.value - 360
					end
					
					if this_t.id == 'ellipse.ang' and this_t.value < 0 then
						this_t.value = this_t.value + 360
					end
					
					this_t.value = math.min(this_t.value, this_t.high)
					this_t.value = math.max(this_t.value, this_t.low)
				end
				
				if tonumber(ui.primary_panel[1].value) ~= nil then
					load_seg = ui.primary_panel[1].value
					load_seg = math.min(load_seg, ui.primary_panel[1].high)
					load_seg = math.max(load_seg, ui.primary_panel[1].low)
				end
				
				if tonumber(ui.primary_panel[2].value) ~= nil then
					load_ang = ui.primary_panel[2].value
					load_ang = math.min(load_ang, ui.primary_panel[2].high)
					load_ang = math.max(load_ang, ui.primary_panel[2].low)
				end
				
				myshape.segments = load_seg
				myshape._angle = load_ang
			end
			
			if ui.primary_panel[1].id == 'art.brush' then
				local load_brush, load_opac = artboard.brush_size, artboard.opacity * 100
				
				-- Update with arrow keys
				if tonumber(ui.primary_panel[ui.primary_textbox].value) ~= nil and ((hz_dir ~= 0) or (vt_dir ~= 0)) then
					local this_t = ui.primary_panel[ui.primary_textbox]
					this_t.value = this_t.value + (hz_key * hz_dir) + (vt_key * vt_dir)
					
					this_t.value = math.min(this_t.value, this_t.high)
					this_t.value = math.max(this_t.value, this_t.low)
				end
				
				if tonumber(ui.primary_panel[1].value) ~= nil then
					load_brush = ui.primary_panel[1].value
					load_brush = math.min(load_brush, ui.primary_panel[1].high)
					load_brush = math.max(load_brush, ui.primary_panel[1].low)
				end
				
				if tonumber(ui.primary_panel[2].value) ~= nil then
					load_opac = ui.primary_panel[2].value
					load_opac = math.min(load_opac, ui.primary_panel[2].high)
					load_opac = math.max(load_opac, ui.primary_panel[2].low)
				end
				
				artboard.brush_size = load_brush
				artboard.opacity = load_opac / 100
			end
			
			if ui.primary_panel[1].id == 'polyline.size' then
			
				local load_size = polygon.thickness
				
				-- Update with arrow keys
				if tonumber(ui.primary_panel[ui.primary_textbox].value) ~= nil and ((hz_dir ~= 0) or (vt_dir ~= 0)) then
					local this_t = ui.primary_panel[ui.primary_textbox]
					this_t.value = this_t.value + (hz_key * hz_dir) + (vt_key * vt_dir)
					
					this_t.value = math.min(this_t.value, this_t.high)
					this_t.value = math.max(this_t.value, this_t.low)
				end
				
				if tonumber(ui.primary_panel[1].value) ~= nil then
					load_size = ui.primary_panel[1].value
					load_size = math.min(load_size, ui.primary_panel[1].high)
					load_size = math.max(load_size, ui.primary_panel[1].low)
				end
			
			end
		
		end
		
	end
	
	if ui.secondary_panel[1] ~= nil then
	
		if ui.secondary_textbox == -1 then -- Update textboxes when inactive
		
			if ui.secondary_panel[1].id == 'grid.width' then
				ui.secondary_panel[1].value = grid_w
				ui.secondary_panel[2].value = grid_h
				ui.secondary_panel[3].value = grid_x
				ui.secondary_panel[4].value = grid_y
			end
			
			if ui.secondary_panel[1].id == 'zoom.type' then
				if ui.zoom_textbox_mode == "px" then
					local larger_window_bound = math.max(document_w, document_h)
					local txt_num = larger_window_bound * camera_zoom
					local txt_num_string = "" .. txt_num
					if string.len(txt_num_string) > 5 then
						txt_num = math.floor(txt_num)
					end
					ui.secondary_panel[1].value = txt_num
				elseif ui.zoom_textbox_mode == "%" then
					ui.secondary_panel[1].value = math.floor(camera_zoom * 100)
				end
			end
		
		else
		
			if ui.secondary_panel[1].id == 'grid.width' then
			
				local load_w, load_h, load_x, load_y = grid_w, grid_h, grid_x, grid_y
				
				-- Update with arrow keys
				if tonumber(ui.secondary_panel[ui.secondary_textbox].value) ~= nil and ((hz_dir ~= 0) or (vt_dir ~= 0)) then
					local this_t = ui.secondary_panel[ui.secondary_textbox]
					this_t.value = this_t.value + (hz_key * hz_dir) + (vt_key * vt_dir)
					
					this_t.value = math.min(this_t.value, this_t.high)
					this_t.value = math.max(this_t.value, this_t.low)
				end
				
				if tonumber(ui.secondary_panel[1].value) ~= nil then
					load_w = ui.secondary_panel[1].value
					load_w = math.min(load_w, ui.secondary_panel[1].high)
					load_w = math.max(load_w, ui.secondary_panel[1].low)
				end
				
				if tonumber(ui.secondary_panel[2].value) ~= nil then
					load_h = ui.secondary_panel[2].value
					load_h = math.min(load_h, ui.secondary_panel[2].high)
					load_h = math.max(load_h, ui.secondary_panel[2].low)
				end
				
				if tonumber(ui.secondary_panel[3].value) ~= nil then
					load_x = ui.secondary_panel[3].value
					load_x = math.min(load_x, ui.secondary_panel[3].high)
					load_x = math.max(load_x, ui.secondary_panel[3].low)
				end
				
				if tonumber(ui.secondary_panel[4].value) ~= nil then
					load_y = ui.secondary_panel[4].value
					load_y = math.min(load_y, ui.secondary_panel[4].high)
					load_y = math.max(load_y, ui.secondary_panel[4].low)
				end
				
				grid_w, grid_h, grid_x, grid_y = load_w, load_h, load_x, load_y
			
			end
			
			if ui.secondary_panel[1].id == 'zoom.type' then
			
				local larger_window_bound = math.max(document_w, document_h)
				local load_zoom = camera_zoom
				local zoom_changed = false
				local this_t = ui.secondary_panel[ui.secondary_textbox]
				
				-- Update with arrow keys
				if tonumber(ui.secondary_panel[ui.secondary_textbox].value) ~= nil and ((hz_dir ~= 0) or (vt_dir ~= 0)) then
					
					this_t.value = this_t.value + (hz_key * hz_dir) + (vt_key * vt_dir)
					
					local tbox_to_camera = tonumber(this_t.value)
					if ui.zoom_textbox_mode == "px" then
						tbox_to_camera = tbox_to_camera / larger_window_bound
					else
						tbox_to_camera = tbox_to_camera / 100
					end
					
					tbox_to_camera = math.min(tbox_to_camera, math.min(99999/larger_window_bound, 999.99))
					tbox_to_camera = math.max(tbox_to_camera, 0.05)
					updateCamera(screen_width, screen_height, camera_zoom, tbox_to_camera)
					
					if ui.zoom_textbox_mode == "px" then
						this_t.value = tbox_to_camera * larger_window_bound
						if string.len(this_t.value) > 5 then
							this_t.value = math.floor(this_t.value)
						end
					else
						this_t.value = math.floor(tbox_to_camera * 100)
					end
					
					zoom_changed = true
					
				end
				
				-- Update zoom preview based on typed input
				if not zoom_changed then
				
					if this_t.value ~= "" and this_t.value ~= "." then
						local tbox_to_camera = tonumber(this_t.value)
						local new_zoom = camera_zoom
						local zoom_valid = true
						
						if ui.zoom_textbox_mode == "px" then
							tbox_to_camera = tbox_to_camera / larger_window_bound
							if tbox_to_camera < 0.05 then
								zoom_valid = false
								new_zoom = tonumber(this_t.value) / larger_window_bound
								tbox_to_camera = new_zoom
							end
						else
							tbox_to_camera = tbox_to_camera / 100
							new_zoom = math.max(tbox_to_camera, 0.05)
							if new_zoom ~= tbox_to_camera then
								zoom_valid = false
							end
							tbox_to_camera = new_zoom
						end
						new_zoom = math.min(tbox_to_camera, math.min(99999/larger_window_bound, 999.99))
						if new_zoom ~= tbox_to_camera then
							zoom_valid = false
						end
						
						if zoom_valid then
							updateCamera(screen_width, screen_height, camera_zoom, new_zoom)
						end
					end
				
				end
			
			end
		
		end
		
	end
	
	-- Interaction for toolbar panels
	local panel_x = 70 + 4
	
	if ui.primary_panel[1] ~= nil then
		
		panel_x = panel_x + font:getWidth(ui.primary_panel.name) + 12
		
		local hit_tbox = -1
		local hit_button = -1
		
		local i = 1
		for i = 1, #ui.primary_panel do
		
			local this_item = ui.primary_panel[i]
			if this_item.is_textbox then
			
				-- Title of element
				panel_x = panel_x + font:getWidth(this_item.name) + 12
				
				-- Textbox of element

				local ix, iy = panel_x, 3
				
				if (mouse_switch == _PRESS) then
					if (mx >= ix - 5) and (mx <= ix + 41) and (my >= iy + 25) and (my <= iy + 45) then
						
						if ui.secondary_textbox ~= -1 then
							ui.textbox_selection_origin = "toolbar2"
							ui.popupLoseFocus("toolbar2")
						end
						
						if ui.primary_textbox ~= -1 then
							ui.textbox_selection_origin = "toolbar"
							ui.popupLoseFocus("toolbar")
						end
						
						if ui_active == false then
							ui.primary_textbox = i
							ui.primary_text_orig = ui.primary_panel[i].value
							
							ui.active_textbox = "toolbar"
							ui.textbox_selection_origin = "toolbar"
							
							hit_tbox = i
						end
					end
				end
				
				panel_x = panel_x + 46 + 6
			
			else
			
				if (mx >= panel_x) and (mx <= panel_x + 23) and (my >= 27) and (my <= 27 + 23) then
				
					if ui.primary_panel[i].id == "art.position" then
						ui.setTooltip(TIP_FREEDRAW_ORDER)
					end
					
					if ui.primary_panel[i].id == "polyline.convert" then
						ui.setTooltip(TIP_POLYLINE_CONVERT)
					end
					
					if ui.primary_panel[i].id == "polyline.ruler" then
						ui.setTooltip(TIP_POLYLINE_MODE)
					end
				
				end
			
				if (mouse_switch == _PRESS and ui_active == false and (mx >= panel_x) and (mx <= panel_x + 23) and (my >= 27) and (my <= 27 + 23)) then
					ui.primary_clicked = i
					hit_button = i
					
					if ui.primary_panel[i].id == "art.position" then
						ui.tooltip_active = -1
						if ui.primary_panel[i].icon == icon_art_above then
							artboard.draw_top = false
							ui.primary_panel[i].icon = icon_art_below
						else
							artboard.draw_top = true
							ui.primary_panel[i].icon = icon_art_above
						end
					end
					
					if ui.primary_panel[i].id == "polyline.convert" then
						
						if polygon.data[tm.polygon_loc] ~= nil and polygon.data[tm.polygon_loc].raw ~= nil then
						
							local old_layer = tm.polygon_loc

							local clone_index = ui.layer[#ui.layer].count
							local tbl_clone = {}
							local old_copy = polygon.data[old_layer]

							tbl_clone.raw = {}

							local clc = 1
							while clc <= #old_copy.raw do
								local old_raw = old_copy.raw[clc]
								local raw_tbl = {}
								
								if old_raw.l ~= nil then
									raw_tbl.l = old_raw.l
									raw_tbl.index = clc
									table.insert(tbl_clone.raw, raw_tbl)
								end
								
								clc = clc + 1
							end
							
							local edited = false
							-- Convert all active lines into polygons
							local clone = polygon.data[tm.polygon_loc].raw
							local i = 1
							for i = 1, #clone do
								if clone[i].l ~= nil then
									clone[i].l = nil
									edited = true
								end
							end
							
							if edited then
								tm.store(TM_LINE_CONVERT, tbl_clone)
								tm.step()
							end
							
						end
						
					end
					
					if ui.primary_panel[i].id == "polyline.ruler" then
						ui.tooltip_active = -1
						if ui.primary_panel[i].icon == icon_ruler then
							polygon.ruler = false
							ui.primary_panel[i].icon = icon_paint
						else
							polygon.ruler = true
							ui.primary_panel[i].icon = icon_ruler
						end
					end
				end
				
				if ui.primary_panel[i].id == "art.position" or ui.primary_panel[i].id == "polyline.ruler" then
					panel_x = panel_x + 8
				end
				panel_x = panel_x + 24 + 4
			
			end
		
		end
		
		if (mouse_switch == _PRESS) then
			if ui.primary_textbox ~= -1 and hit_tbox == -1 then
				ui.textbox_selection_origin = "toolbar"
				ui.popupLoseFocus("toolbar")
				ui_active = true
			end
		end
		
		if (mouse_switch == _RELEASE) then
			if ui.primary_clicked ~= -1 and hit_button == -1 then
				ui.primary_clicked = -1
			end
		end
		
	end
	
	if ui.secondary_panel[1] ~= nil then
		
		-- Add line divider
		if ui.primary_panel[1] ~= nil then
			panel_x = panel_x + 12
		end
		
		panel_x = panel_x + font:getWidth(ui.secondary_panel.name) + 12
		
		local hit_tbox = -1
		local hit_button = -1
		
		local i = 1
		for i = 1, #ui.secondary_panel do
		
			local this_item = ui.secondary_panel[i]
			if this_item.is_textbox then
			
				-- Check collision on px for zoom
				if this_item.id == "zoom.type" then
					if mouse_switch == _PRESS and ui_active == false and (mx >= panel_x - 5) and (mx <= panel_x - 5 + 24) and (my >= 29) and (my <= 29 + 21) then
						if ui.zoom_textbox_mode == "px" then
							ui.zoom_textbox_mode = "%"
						else
							ui.zoom_textbox_mode = "px"
						end
					end
				end
			
				-- Title of element
				panel_x = panel_x + font:getWidth(this_item.name) + 12
				
				-- Textbox of element

				local ix, iy = panel_x, 3
				
				if (mouse_switch == _PRESS) then
					if (mx >= ix - 5) and (mx <= ix + 41) and (my >= iy + 25) and (my <= iy + 45) then
						
						if ui.primary_textbox ~= -1 then
							ui.textbox_selection_origin = "toolbar"
							ui.popupLoseFocus("toolbar")
						end
						
						if ui.secondary_textbox ~= -1 then
							ui.textbox_selection_origin = "toolbar2"
							ui.popupLoseFocus("toolbar2")
						end
						
						if ui_active == false then
							ui.secondary_textbox = i
							ui.secondary_text_orig = ui.secondary_panel[i].value
							
							ui.active_textbox = "toolbar2"
							ui.textbox_selection_origin = "toolbar2"
							
							hit_tbox = i
						end
					end
				end
				
				panel_x = panel_x + 46 + 6
			
			else
			
				if (mx >= panel_x) and (mx <= panel_x + 23) and (my >= 27) and (my <= 27 + 23) then
				
					if ui.secondary_panel[i].id == "grid.snap" then
						ui.setTooltip(TIP_GRID_SNAP)
					end
					
					if ui.secondary_panel[i].id == "grid.pp" then
						ui.setTooltip(TIP_GRID_PP)
					end
					
					if ui.secondary_panel[i].id == "zoom.in" then
						ui.setTooltip(TIP_ZOOM_IN)
					end
					
					if ui.secondary_panel[i].id == "zoom.out" then
						ui.setTooltip(TIP_ZOOM_OUT)
					end
					
					if ui.secondary_panel[i].id == "zoom.reset" then
						ui.setTooltip(TIP_ZOOM_RESET)
					end
					
					if ui.secondary_panel[i].id == "zoom.fit" then
						ui.setTooltip(TIP_ZOOM_FIT)
					end
				
				end
			
				if (mouse_switch == _PRESS and ui_active == false and (mx >= panel_x) and (mx <= panel_x + 23) and (my >= 27) and (my <= 27 + 23)) then
					ui.secondary_clicked = i
					hit_button = i
					
					if ui.secondary_panel[i].id == "grid.snap" then
						grid_snap = not grid_snap
						ui.secondary_panel[i].active = not grid_snap
					end
					
					if ui.secondary_panel[i].id == "grid.pp" then
						pixel_perfect = not pixel_perfect
						ui.secondary_panel[i].active = not pixel_perfect
					end
					
					if ui.secondary_panel[i].id == "zoom.in" then
						local larger_window_bound = math.max(document_w, document_h)
						local round_zoom = math.floor(camera_zoom * 100)/100
						local temp_zoom = math.min(round_zoom * 1.25, math.min(99999/larger_window_bound, 999.99))
						updateCamera(screen_width, screen_height, camera_zoom, temp_zoom)
					end
					
					if ui.secondary_panel[i].id == "zoom.out" then
						local round_zoom = math.floor(camera_zoom * 100)/100
						local temp_zoom = math.max(round_zoom * 0.85, 0.05)
						updateCamera(screen_width, screen_height, camera_zoom, temp_zoom)
					end
					
					if ui.secondary_panel[i].id == "zoom.reset" then
						updateCamera(screen_width, screen_height, camera_zoom, 1)
						resetCamera()
					end
					
					if ui.secondary_panel[i].id == "zoom.fit" then
						local smaller_preview_bound = math.min(screen_width - 208 - 64, screen_height - 54)
						local larger_window_bound = math.max(document_w, document_h)
						local temp_zoom = smaller_preview_bound / larger_window_bound
						updateCamera(screen_width, screen_height, camera_zoom, temp_zoom)
						resetCamera()
					end
				end
				
				panel_x = panel_x + 24 + 4
			
			end
		
		end
		
		if (mouse_switch == _PRESS) then
			if ui.secondary_textbox ~= -1 and hit_tbox == -1 then
				ui.textbox_selection_origin = "toolbar2"
				ui.popupLoseFocus("toolbar2")
				ui_active = true
			end
		end
		
		if (mouse_switch == _RELEASE) then
			if ui.secondary_clicked ~= -1 and hit_button == -1 then
				ui.secondary_clicked = -1
			end
		end
		
	end
	
	-- Interaction for preview window
	if ui.preview_textbox_locked then
		if ui.preview_textbox_mode == "px" then
			local larger_window_bound = math.max(document_w, document_h)
			local txt_num = larger_window_bound * ui.preview_zoom
			local txt_num_string = "" .. txt_num
			if string.len(txt_num_string) > 5 then
				txt_num = math.floor(txt_num)
			end
			ui.preview_textbox = txt_num
		elseif ui.preview_textbox_mode == "%" then
			ui.preview_textbox = math.floor(ui.preview_zoom * 100)
		end
	end
	
	if ui.preview_active and not ui_active and ui.popup[1] == nil then
		
		local rx, ry, rw, rh = ui.preview_x, ui.preview_y, ui.preview_w, ui.preview_h
		local pmx, pmy = mx - rx, my - ry
		
		local grab = 6
		
		local grab_left = (pmx <= 1 and pmx >= -grab)
		local grab_right = (pmx >= rw - 1 and pmx <= rw + grab)
		local grab_top = (pmy <= 1 and pmy >= -grab)
		local grab_bot = (pmy >= rh - 1 and pmy <= rh + grab)
		
		local bx, by, bw, bh = rx + 3, ry + 27, rw - 5, rh - 29 - 28
		if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
		
			if mouse_switch == _PRESS then
			
				ui.preview_palette_enabled = false
				ui.preview_action = "move"
			
			else
			
			-- Zoom in/out with the scroll wheel
			
				if mouse_wheel_y ~= 0 then
					local larger_window_bound = math.max(document_w, document_h)
					ui.preview_zoom = math.max(ui.preview_zoom + ((mouse_wheel_y / 100) * 60 * dt), 0.05)
					ui.preview_zoom = math.min(ui.preview_zoom, math.min(99999/larger_window_bound, 999.99))
				end
				
			end
		
		else
		
			if ui.preview_action ~= "textbox" and (ui.popup[1] == nil) and ui.active_textbox == "preview" then
				ui.textbox_selection_origin = "preview"
				ui.popupLoseFocus("preview")
			end
		
		end
		
		if tab_key == _PRESS then
			if (ui.popup[1] == nil) and ui.active_textbox == "preview" then
				ui.textbox_selection_origin = "preview"
				ui.popupLoseFocus("preview")
			end
		end
		
		-- Only show cursors when in bounds of the preview window
		if pmx >= -grab and pmx <= rw + grab and pmy >= -grab and pmy <= rh + grab and not ui.preview_dragging and not color_grabber and not zoom_grabber and not select_grabber then
		
			local drag_titlebar = false
		
			-- Set the correct cursor
			if (grab_top and grab_left) then
				love.mouse.setCursor(cursor_size_fall)
				ui.preview_drag_corner = 1
			elseif (grab_bot and grab_right) then
				love.mouse.setCursor(cursor_size_fall)
				ui.preview_drag_corner = 5
			elseif (grab_top and grab_right) then
				love.mouse.setCursor(cursor_size_rise)
				ui.preview_drag_corner = 3
			elseif (grab_bot and grab_left) then
				love.mouse.setCursor(cursor_size_rise)
				ui.preview_drag_corner = 7
			elseif grab_top then
				love.mouse.setCursor(cursor_size_v)
				ui.preview_drag_corner = 2
			elseif grab_bot then
				love.mouse.setCursor(cursor_size_v)
				ui.preview_drag_corner = 6
			elseif grab_left then
				love.mouse.setCursor(cursor_size_h)
				ui.preview_drag_corner = 8
			elseif grab_right then
				love.mouse.setCursor(cursor_size_h)
				ui.preview_drag_corner = 4
			else
				love.mouse.setCursor()
				ui.preview_drag_corner = -1
				drag_titlebar = (my <= ui.preview_y + 25)
			end
			
			-- Preview tooltips
			local ix, iy = rx + 36, ry + rh - 50

			-- Move vars to be near the button positions
			ix = ix + 49
			iy = iy + 24

			-- Zoom In
			if (mx >= ix) and (mx <= ix + 24) and (my >= iy) and (my <= iy + 24) then
				ui.setTooltip(TIP_PREV_ZOOM_IN)
			end

			-- Zoom Out
			if (mx >= ix + 28) and (mx <= ix + 24 + 28) and (my >= iy) and (my <= iy + 24) then
				ui.setTooltip(TIP_PREV_ZOOM_OUT)
			end

			-- Reset scale
			if (mx >= ix + 56) and (mx <= ix + 24 + 56) and (my >= iy) and (my <= iy + 24) then
				ui.setTooltip(TIP_PREV_ZOOM_RESET)
			end

			-- Fit to window
			if (mx >= ix + 84) and (mx <= ix + 24 + 84) and (my >= iy) and (my <= iy + 24) then
				ui.setTooltip(TIP_PREV_ZOOM_FIT)
			end

			-- Toggle artboard
			if (mx >= ix + 112) and (mx <= ix + 24 + 112) and (my >= iy) and (my <= iy + 24) then
				ui.setTooltip(TIP_PREV_FREEDRAW)
			end
			
			-- Toggle horizontal flip
			if (mx >= ix + 140) and (mx <= ix + 24 + 140) and (my >= iy) and (my <= iy + 24) then
				ui.setTooltip(TIP_PREV_HFLIP)
			end
			
			-- Toggle vertical flip
			if (mx >= ix + 168) and (mx <= ix + 24 + 168) and (my >= iy) and (my <= iy + 24) then
				ui.setTooltip(TIP_PREV_VFLIP)
			end

			-- Background color
			if (mx >= rx + rw - 26) and (mx <= rx + rw - 3) and (my >= iy) and (my <= iy + 23) then
				ui.setTooltip(TIP_PREV_BG)
			end
			
			if mouse_switch == _PRESS then

				ui_active = true
			
				-- Close window button (x)
				if (mx >= rx + rw - 22) and (mx <= rx + rw - 22 + 18) and (my >= ry + 5) and (my <= ry + 20) then
					ui.textbox_selection_origin = "preview"
					ui.popupLoseFocus("preview")
					ui.preview_active = false
				end
			
				if ui.preview_drag_corner ~= -1 or drag_titlebar then
					ui.preview_dragging = true
					ui.preview_w_init_pos = ui.preview_x + ui.preview_w
					ui.preview_h_init_pos = ui.preview_y + ui.preview_h
				else
				
					-- Button interactions
						
					-- Textbox for scale input
					local ix, iy = rx + 36, ry + rh - 50

					-- Toggle between pixels and percentage scaling
					if (mx >= ix - 32) and (mx <= ix - 32 + 24) and (my >= iy + 24) and (my <= iy + 47) then
						if ui.preview_textbox_mode == "px" then
							ui.preview_textbox_mode = "%"
						else
							ui.preview_textbox_mode = "px"
						end
						ui.preview_action = ""
					end
					
					-- Textbox for preview
					if (mx >= ix - 5) and (mx <= ix + 41) and (my >= iy + 25) and (my <= iy + 45) then
						ui.preview_textbox_orig = ui.preview_textbox
						ui.preview_textbox_locked = false
						ui.active_textbox = "preview"
						ui.textbox_selection_origin = "preview"
						ui.preview_action = "textbox"
					end

					-- Move vars to be near the button positions
					ix = ix + 49
					iy = iy + 24

					-- Zoom In
					if (mx >= ix) and (mx <= ix + 24) and (my >= iy) and (my <= iy + 24) then
						local larger_window_bound = math.max(document_w, document_h)
						local round_zoom = math.floor(ui.preview_zoom * 100)/100
						ui.preview_zoom = math.min(round_zoom * 1.25, math.min(99999/larger_window_bound, 999.99))
						ui.preview_action = ""
						ui.preview_button_active = 1
					end

					-- Zoom Out
					if (mx >= ix + 28) and (mx <= ix + 24 + 28) and (my >= iy) and (my <= iy + 24) then
						local round_zoom = math.floor(ui.preview_zoom * 100)/100
						ui.preview_zoom = math.max(round_zoom * 0.85, 0.05)
						ui.preview_action = ""
						ui.preview_button_active = 2
					end

					-- Reset scale
					if (mx >= ix + 56) and (mx <= ix + 24 + 56) and (my >= iy) and (my <= iy + 24) then
						ui.preview_window_x = 0
						ui.preview_window_y = 0
						ui.preview_zoom = 1
						ui.preview_action = ""
						ui.preview_button_active = 3
					end

					-- Fit to window
					if (mx >= ix + 84) and (mx <= ix + 24 + 84) and (my >= iy) and (my <= iy + 24) then
						ui.preview_window_x = 0
						ui.preview_window_y = 0
						local smaller_preview_bound = math.min(ui.preview_w, ui.preview_h - 55)
						local larger_window_bound = math.max(document_w, document_h)
						ui.preview_zoom = smaller_preview_bound / larger_window_bound
						ui.preview_action = ""
						ui.preview_button_active = 4
					end

					-- Toggle artboard
					if (mx >= ix + 112) and (mx <= ix + 24 + 112) and (my >= iy) and (my <= iy + 24) then
						ui.preview_artboard_enabled = not ui.preview_artboard_enabled
						ui.preview_action = ""
						ui.preview_button_active = 5
					end
					
					-- Toggle horizontal flip
					if (mx >= ix + 140) and (mx <= ix + 24 + 140) and (my >= iy) and (my <= iy + 24) then
						ui.preview_flip_h = not ui.preview_flip_h
						ui.preview_action = ""
						ui.preview_button_active = 6
					end
					
					-- Toggle vertical flip
					if (mx >= ix + 168) and (mx <= ix + 24 + 168) and (my >= iy) and (my <= iy + 24) then
						ui.preview_flip_v = not ui.preview_flip_v
						ui.preview_action = ""
						ui.preview_button_active = 7
					end

					-- Background color
					if (mx >= rx + rw - 26) and (mx <= rx + rw - 3) and (my >= iy) and (my <= iy + 23) then
						ui.preview_palette_enabled = false
						ui.preview_action = "background"
					end
				
				end
			end
			
		else
			if not ui.preview_dragging then
				love.mouse.setCursor()
			end
		end
	
	else
		if mouse_switch == _PRESS then
			ui.preview_action = ""
			if ui.preview_action ~= "textbox" and (ui.popup[1] == nil) and ui.active_textbox == "preview" then
				ui.textbox_selection_origin = "preview"
				ui.popupLoseFocus("preview")
			end
		end
	end
	
	if mouse_switch == _RELEASE and ui.preview_button_active ~= -1 then
		ui.preview_button_active = -1
	end
		
	if ui.preview_dragging and not color_grabber and not zoom_grabber and not select_grabber then
	
		if mouse_switch == _RELEASE then
			ui.preview_dragging = false
			ui_active = true
			ui.mouse_lock_x = -1
			ui.mouse_lock_y = -1
		else
		
			ui.preview_palette_enabled = false
			local lock_w = false
			local lock_h = false
		
			if ui.mouse_lock_x ~= -1 or ui.mouse_lock_y ~= -1 then
				local check_x_drag = (ui.preview_x + ui.mouse_lock_x - mx)
				local check_x_drag_prev = (ui.preview_x + ui.mouse_lock_x - ui.mouse_x_previous)
				local check_y_drag = (ui.preview_y + ui.mouse_lock_y - my)
				local check_y_drag_prev = (ui.preview_y + ui.mouse_lock_y - ui.mouse_y_previous)
				
				lock_w = true
				if (check_x_drag * check_x_drag_prev <= 0) then
					ui.mouse_lock_x = -1
					lock_w = false
				end
			
				lock_h = true
				if (check_y_drag * check_y_drag_prev <= 0) then
					ui.mouse_lock_y = -1
					lock_h = false
				end
				
			end
			
			local original_x = ui.preview_x
			local original_y = ui.preview_y
			
			if ui.preview_drag_corner ~= -1 then --If we're resizing the preview window
			
				local x_movement = ui.preview_x
				local y_movement = ui.preview_y
				local w_movement = ui.preview_w
				local h_movement = ui.preview_h
			
				local drag = ui.preview_drag_corner
				--print(drag)
				if drag == 1 then --NW
					y_movement = ui.preview_y + (my - ui.mouse_y_previous)
					h_movement = ui.preview_h - (my - ui.mouse_y_previous)
					x_movement = ui.preview_x + (mx - ui.mouse_x_previous)
					w_movement = ui.preview_w - (mx - ui.mouse_x_previous)
					love.mouse.setCursor(cursor_size_fall)
				elseif drag == 2 then --N
					y_movement = ui.preview_y + (my - ui.mouse_y_previous)
					h_movement = ui.preview_h - (my - ui.mouse_y_previous)
					love.mouse.setCursor(cursor_size_v)
				elseif drag == 3 then --NE
					y_movement = ui.preview_y + (my - ui.mouse_y_previous)
					h_movement = ui.preview_h - (my - ui.mouse_y_previous)
					w_movement = ui.preview_w + (mx - ui.mouse_x_previous)
					love.mouse.setCursor(cursor_size_rise)
				elseif drag == 4 then --E
					w_movement = ui.preview_w + (mx - ui.mouse_x_previous)
					love.mouse.setCursor(cursor_size_h)
				elseif drag == 5 then --SE
					w_movement = ui.preview_w + (mx - ui.mouse_x_previous)
					h_movement = ui.preview_h + (my - ui.mouse_y_previous)
					love.mouse.setCursor(cursor_size_fall)
				elseif drag == 6 then --S
					h_movement = ui.preview_h + (my - ui.mouse_y_previous)
					love.mouse.setCursor(cursor_size_v)
				elseif drag == 7 then --SW
					x_movement = ui.preview_x + (mx - ui.mouse_x_previous)
					w_movement = ui.preview_w - (mx - ui.mouse_x_previous)
					h_movement = ui.preview_h + (my - ui.mouse_y_previous)
					love.mouse.setCursor(cursor_size_rise)
				elseif drag == 8 then --W
					x_movement = ui.preview_x + (mx - ui.mouse_x_previous)
					w_movement = ui.preview_w - (mx - ui.mouse_x_previous)
					love.mouse.setCursor(cursor_size_h)
				end
				
				if not lock_w then
					ui.preview_x = x_movement
					ui.preview_w = w_movement
					ui.preview_action = ""
				end
				
				if not lock_h then
					ui.preview_y = y_movement
					ui.preview_h = h_movement
					ui.preview_action = ""
				end
			
			else --We're moving the preview from the titlebar
				if ui.mouse_lock_x == -1 then ui.preview_x = ui.preview_x + (mx - ui.mouse_x_previous) end
				if ui.mouse_lock_y == -1 then ui.preview_y = ui.preview_y + (my - ui.mouse_y_previous) end
				ui.preview_action = ""
			end
			
			-- Keep the preview window in bounds of the screen window
			ui.resizeWindow()
			
			ui_active = true
		end
		
	end
	
	if ui.preview_action == "move" then
	
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
		if mouse_switch == _RELEASE then
			ui.preview_action = ""
		else
			love.mouse.setCursor()
			ui.preview_window_x = ui.preview_window_x + (mx - ui.mouse_x_previous)
			ui.preview_window_y = ui.preview_window_y + (my - ui.mouse_y_previous)
		end
	
	end
	
	if ui.preview_action == "background" then
	
		-- Copy and paste for palette
		if input.ctrlCombo(c_key) then
			local new_col = {ui.preview_bg_color[1], ui.preview_bg_color[2], ui.preview_bg_color[3], ui.preview_bg_color[4]}
			palette.copy = new_col
		end
		
		if input.ctrlCombo(v_key) and palette.canPaste and palette.copy ~= nil then
			local new_col = {palette.copy[1], palette.copy[2], palette.copy[3], palette.copy[4]}
			ui.preview_bg_color = new_col
		end
	
	end
	
	if ui.active_textbox == "preview" and mouse_switch == _PRESS and (mx <= 64 or my <= 54) then
		ui.textbox_selection_origin = "preview"
		ui.popupLoseFocus("preview")
		ui.preview_action = ""
	end
	
	-- Check collision on popup box
	if ui.popup[1] ~= nil then
		
		local exit_pop = false
		
		-- Scroll inputs with tab
		if tab_key == _PRESS and ui.popup_sel_a ~= 0 and ui.popup_sel_b ~= 0 then
			
			if ui.popup[1][1].kind == "f.new" or ui.popup[1][1].kind == "i.setup" or ui.popup[1][1].kind == "f.as" then
			
				local oa = ui.popup_sel_a
				ui.popupLoseFocus(ui.popup[1][1].kind)
				
				ui.popup_sel_a, ui.popup_sel_b = oa + 1, 2
				
				if ui.popup_sel_a > #ui.popup - 1 then
					ui.popup_sel_a = 2
				end
				
				ui.active_textbox = ui.popup[ui.popup_sel_a][ui.popup_sel_b].name
				ui.textbox_selection_origin = "popup"
			
			end
			
		end
		
		-- Accept input with enter
		if enter_key == _PRESS then
		
			local pop_kind = ui.popup[1][1].kind
			
			if (pop_kind == "f.new" or pop_kind == "i.setup" or pop_kind == "f.as") and ui.popup_enter == false then
				-- OK button
				ui.popupLoseFocus(ui.popup[1][1].kind)
				document_name = ui.popup[2][2].name
				can_overwrite = false
				document_w = tonumber(ui.popup[3][2].name)
				document_h = tonumber(ui.popup[4][2].name)
				polygon.max_thickness = math.max(document_w, document_h)
				
				if pop_kind == "i.setup" or pop_kind == "f.as" then
					-- Exit popup
					ui.popup = {}
					ui_active = true
					ui.context_menu = {}
					ui.title_active = false
				else
					resetEditor(true, true, true)
				end
				
				if pop_kind == "f.as" then
					local test_save = export.test(overwrite_type)
					if test_save then
						ui.popup = {}
						ui_active = true
						ui.context_menu = {}
						ui.title_active = false
						
						ui.loadPopup("f.overwrite")
					else
					
						if overwrite_type == OVERWRITE_LOL then
							export.saveLOL()
							export.saveArtboard()
							can_overwrite = true
						elseif overwrite_type == OVERWRITE_SVG then
							export.saveSVG()
							can_overwrite = true
						elseif overwrite_type == OVERWRITE_PNG then
							export.savePNG()
							can_overwrite = true
						end
						
						if is_trying_to_quit then
							safe_to_quit = true
							love.event.quit()
						end
						
					end
				end
				
				updateTitle()
			end
			
			if pop_kind == "save.disabled" then
			
				safe_to_quit = true
				love.event.quit()
				
				-- Exit popup
				ui.popup = {}
				ui_active = true
				ui.context_menu = {}
				ui.title_active = false
			
			end
			
			if pop_kind == "h.about" then
				ui.popupLoseFocus(ui.popup[1][1].kind)
				
				-- Exit popup
				ui.popup = {}
				ui_active = true
				ui.context_menu = {}
				ui.title_active = false
			end
			
			if pop_kind == "f.exit" then
			
				local test_save = export.test(OVERWRITE_LOL)

				if test_save and can_overwrite == false then
				
					is_trying_to_quit = true
					
					ui.popup = {}
					ui_active = true
					ui.context_menu = {}
					ui.title_active = false
					
					ui.loadPopup("f.overwrite")
					
				else
				
					export.saveLOL()
					export.saveArtboard()
					can_overwrite = true
					
					-- Exit popup
					ui.popup = {}
					ui_active = true
					ui.context_menu = {}
					ui.title_active = false
					
					safe_to_quit = true
					love.event.quit()
					
				end
			
			end
			
			if pop_kind == "f.overwrite" then
				if overwrite_type == OVERWRITE_LOL then
					export.saveLOL()
					export.saveArtboard()
					can_overwrite = true
				elseif overwrite_type == OVERWRITE_SVG then
					export.saveSVG()
					can_overwrite = true
				elseif overwrite_type == OVERWRITE_PNG then
					export.savePNG()
					can_overwrite = true
				end
				
				if is_trying_to_quit then
					safe_to_quit = true
					love.event.quit()
				end
				
				-- Exit popup
				ui.popup = {}
				ui_active = true
				ui.context_menu = {}
				ui.title_active = false
					
			end
		
		end
		
		local mx_on_menu, my_on_menu
		mx_on_menu = (mx >= ui.popup_x) and (mx <= ui.popup_x + ui.popup_w)
		my_on_menu = (my >= ui.popup_y) and (my <= ui.popup_y + ui.popup_h)
		
		-- If the popup box was clicked on
		if mx_on_menu and my_on_menu then
			
			if mouse_switch == _PRESS then
			
				ui.preview_palette_enabled = false
				local px, py, pw, ph, pxo = ui.popup_x, ui.popup_y, ui.popup_w, ui.popup_h, ui.popup_x_offset
				local popup_clicked = false
				local load_next_popup = ""
			
				local i
				local h = 12
				for i = 2, #ui.popup do
			
					local j
					for j = 1, #ui.popup[i] do
					
						local name = ui.popup[i][j].name
						local kind = ui.popup[i][j].kind
						local bx, by, bw, bh = -9999, 0, 0, 0
						
						-- Get bounding box of element clicked
						if kind == "textbox" then
							bx = px + (pw / 2) - 5 + pxo
							by = py + 25 + h - 1
							bw = 251
							bh = 20
						elseif kind == "number" then
							bx = px + (pw / 2) - 5 + pxo
							by = py + 25 + h - 1
							bw = 46
							bh = 20
						elseif kind == "ok" then
							if ui.popup[1][1].kind == "h.about" then
								bx = math.floor(px + (pw / 2) - 9) - 8
								by = math.floor(py + 25 + h + 6) - 3
							else
								bx = px + (pw / 2) - 32 - 19 - 8
								by = py + 25 + h + 6 - 3
							end
							bw = 35
							bh = 25
						elseif kind == "save" then
							bx = math.floor(px + (pw / 2) - 20 - 22 - (pw / 6) - 4) - 8
							by = math.floor(py + 25 + h + 6) - 3
							bw = 44
							bh = 25
						elseif kind == "discard" then
							bx = math.floor(px + (pw / 2) - 21 - 4 - 2) - 7
							by = math.floor(py + 25 + h + 6) - 3
							bw = 58
							bh = 25
						elseif kind == "overwrite" then
							bx = math.floor(px + (pw / 2) - 62 - (pw / 6)) - 8
							by = math.floor(py + 25 + h + 6) - 3
							bw = 75
							bh = 25
						elseif kind == "rename" then
							bx = math.floor(px + (pw / 2) - 25) - 7
							by = math.floor(py + 25 + h + 6) - 3
							bw = 64
							bh = 25
						elseif kind == "continue" then
							bx = math.floor(px + (pw / 2) - 107) - 8
							by = math.floor(py + h + 6 - 10) - 3
							bw = 163
							bh = 25
						elseif kind == "exit" then
							bx = math.floor(px + (pw / 2) + 84) - 7
							by = math.floor(py + h + 6 - 10) - 3
							bw = 38
							bh = 25
						elseif kind == "cancel" then
							if ui.popup[1][1].kind == "f.exit" then
								bx = math.floor(px + (pw / 2) - 21 + 32 + (pw / 6) - 4) - 8
								by = math.floor(py + 25 + h + 6) - 3
							elseif ui.popup[1][1].kind == "f.overwrite" then
								bx = math.floor(px + (pw / 2) + 4 + (pw / 6)) - 8
								by = math.floor(py + 25 + h + 6) - 3
							else
								bx = px + (pw / 2) + 32 - 19 - 8
								by = py + 25 + h + 6 - 3
							end
							bw = 55
							bh = 25
						end
						
						-- If bounding box is valid
						if bx ~= -9999 then
							local mx_box, my_box
							mx_box = (mx >= bx) and (mx <= bx + bw)
							my_box = (my >= by) and (my <= by + bh)
							
							-- If bounding box was clicked on
							if mx_box and my_box then
								
								popup_clicked = true
								local pop_kind = ui.popup[1][1].kind
								
								if kind == "textbox" or kind == "number" then
									ui.popupLoseFocus(pop_kind)
									ui.active_textbox = ui.popup[i][j].name
									ui.textbox_selection_origin = "popup"
									ui.popup_sel_a, ui.popup_sel_b = i, j
								elseif kind == "ok" and (pop_kind == "f.new" or pop_kind == "i.setup" or pop_kind == "f.as") then -- OK button for f.new (new document)
									ui.popupLoseFocus(pop_kind)
									document_name = ui.popup[2][2].name
									can_overwrite = false
									document_w = tonumber(ui.popup[3][2].name)
									document_h = tonumber(ui.popup[4][2].name)
									polygon.max_thickness = math.max(document_w, document_h)
									
									if pop_kind == "i.setup" or pop_kind == "f.as" then
										-- removed clearing artboard
									else
										resetEditor(false, true, true)
									end
									
									if pop_kind == "f.as" then
										local test_save = export.test(overwrite_type)
										if test_save then
											load_next_popup = "f.overwrite"
										else
										
											if overwrite_type == OVERWRITE_LOL then
												export.saveLOL()
												export.saveArtboard()
												can_overwrite = true
											elseif overwrite_type == OVERWRITE_SVG then
												export.saveSVG()
												can_overwrite = true
											elseif overwrite_type == OVERWRITE_PNG then
												export.savePNG()
												can_overwrite = true
											end
											
											if is_trying_to_quit then
												safe_to_quit = true
												love.event.quit()
											end
											
										end
									end
									
									updateTitle()
									
									exit_pop = true
								elseif kind == "save" then
									local test_save = export.test(OVERWRITE_LOL)
									if test_save then
										load_next_popup = "f.overwrite"
										is_trying_to_quit = true
									else
									
										export.saveLOL()
										export.saveArtboard()
										can_overwrite = true
										
										if is_trying_to_quit then
											safe_to_quit = true
											love.event.quit()
										end
										
									end
									exit_pop = true
								elseif kind == "discard" then
									safe_to_quit = true
									love.event.quit()
									exit_pop = true
								elseif kind == "overwrite" then
									
									if overwrite_type == OVERWRITE_LOL then
										export.saveLOL()
										export.saveArtboard()
										can_overwrite = true
									elseif overwrite_type == OVERWRITE_SVG then
										export.saveSVG()
										can_overwrite = true
									elseif overwrite_type == OVERWRITE_PNG then
										export.savePNG()
										can_overwrite = true
									end
									
									if is_trying_to_quit then
										safe_to_quit = true
										love.event.quit()
									end
									
									exit_pop = true
									
								elseif kind == "continue" then
									splash_active = true
									exit_pop = true
								elseif kind == "exit" then
									is_trying_to_quit = false
									safe_to_quit = true
									love.event.quit()
									exit_pop = true
								elseif kind == "rename" then
									load_next_popup = "f.as"
									exit_pop = true
								elseif kind == "ok" and pop_kind == "h.about" then
									ui.popupLoseFocus(pop_kind)
									exit_pop = true
								elseif kind == "cancel" then
									is_trying_to_quit = false
									if pop_kind == "f.exit" or pop_kind == "f.overwrite" or pop_kind == "f.as" then
										safe_to_quit = false
									end
									exit_pop = true
								end
								
							end
						end
						
					end
					
					h = h + 28
				end
				
				if not popup_clicked then
					ui.popupLoseFocus(ui.popup[1][1].kind)
				end
				
				if exit_pop then
					ui.popupLoseFocus(ui.popup[1][1].kind)
					ui.popup = {}
					ui_active = true
					ui.context_menu = {}
					ui.title_active = false
					
					if load_next_popup ~= "" then
						ui.loadPopup(load_next_popup)
					end
				end
				
			end
			
			ui_active = true
			
		elseif mouse_switch == _PRESS then
			ui.popupLoseFocus(ui.popup[1][1].kind)
			ui_active = true
		end
		
	end
	
	if mouse_switch == _PRESS and my <= 58 then
		ui_active = true
	end
	
	if zoom_grabber and ui_active == false then
	
		local within_ui_bounds = mx > 64 and my > 54 and mx < screen_width - 208
		local preview_bounds = not (mx > ui.preview_x and mx < ui.preview_x + ui.preview_w and my > ui.preview_y and my < ui.preview_y + ui.preview_h and ui.preview_active)
		local popup_bounds = ui.popup[1] == nil
	
		if within_ui_bounds and preview_bounds and popup_bounds then
			love.mouse.setCursor(cursor_zoom)
		
			if mouse_switch == _PRESS then
				local larger_window_bound = math.max(document_w, document_h)
				local round_zoom = math.floor(camera_zoom * 100)/100
				local temp_zoom = math.min(round_zoom * 1.25, math.min(99999/larger_window_bound, 999.99))
				updateCamera(screen_width, screen_height, camera_zoom, temp_zoom)
				ui_active = true
			end
			
			if rmb_switch == _PRESS then
				local round_zoom = math.floor(camera_zoom * 100)/100
				local temp_zoom = math.max(round_zoom * 0.85, 0.05)
				updateCamera(screen_width, screen_height, camera_zoom, temp_zoom)
				ui_active = true
			end
		else
			love.mouse.setCursor()
		end
	
	end
	
	if ui_active == false and mx > 64 and my > 54 and mx < screen_width - 208 then
		if double_click_timer_deselect ~= 0 then
		
			double_click_timer_deselect = double_click_timer_deselect + (60 * dt)
		
			if double_click_timer_deselect > 30 then
				double_click_timer_deselect = 0
			end
		
		end
		
		if rmb_switch == _PRESS then
		
			if double_click_timer_deselect > 0 and double_click_timer_deselect < 14 then
			
				vertex_selection_mode = false
				vertex_selection = {}
				
				shape_selection_mode = false
				shape_selection = {}
				multi_shape_selection = false
				
				double_click_timer_deselect = 0
			else
				double_click_timer_deselect = 0
			end
		
			double_click_timer_deselect = double_click_timer_deselect + (60 * dt)
		
		end
	end
	
	if artboard.active == false then
	
		local mouse_var = mouse_switch
		if selection_rmb then mouse_var = rmb_switch end
		
		if mx > 64 and my > 54 and mx < screen_width - 208 then
	
			if not zoom_grabber and rmb_switch == _PRESS then
				
				if not ui.toolbar[ui.toolbar_select].active then
					selection_previously_active = true
				else
					selection_previously_active = false
				end
				
				ui.selectionButton(false, true)
				selection_rmb = true
				
			end
			
			if selection_rmb then mouse_var = rmb_switch end
	
			if mouse_var == _PRESS and ui_active == false and select_grabber then
				box_selection_x = mx / camera_zoom
				box_selection_y = my / camera_zoom
				box_selection_active = true
				ui_active = true
			end
		
		end
		
		if select_grabber then
		
			if mouse_var == _ON then
				ui_active = true
			end
			
			local use_rmb = false
			use_rmb = selection_rmb and rmb_switch == _RELEASE
			
			if mouse_var == _RELEASE or use_rmb then
			
				if shape_grabber then
				
					if box_selection_active then
					
						local sx, sy, sx2, sy2 = (box_selection_x - camera_x), (box_selection_y - camera_y), (mx / camera_zoom) - camera_x, (my / camera_zoom) - camera_y
						if sx2 < sx then sx, sx2 = sx2, sx end
						if sy2 < sy then sy, sy2 = sy2, sy end
						local sw, sh = math.floor(sx2 - sx), math.floor(sy2 - sy)
						sx, sy = math.floor(sx), math.floor(sy)
						local shape_selection_starting = #shape_selection
						local select_success = false
					
						local n = 1
						
						while n <= #ui.layer do
						
							local contains_all_points = true
							
							if polygon.data[ui.layer[n].count] ~= nil then
							
								local clone = polygon.data[ui.layer[n].count]
								local j = 1
								while j <= #clone.raw do
									
									local tx, ty = clone.raw[j].x, clone.raw[j].y
									
									if not (tx >= sx and tx <= sx + sw and ty >= sy and ty <= sy + sh) then
										contains_all_points = false
										j = #clone.raw + 1
									end
									
									j = j + 1
								
								end
							
							else
								contains_all_points = false
							end
							
							if contains_all_points then
							
								local shape_exists = false
								local k = 1
								while k <= shape_selection_starting do
									if shape_selection[k].index == j then
										shape_exists = true
										k = #shape_selection + 1
									end
									k = k + 1
								end

								if not shape_exists then

									local copy_shape = {}
									copy_shape.index = n
									copy_shape.x = 0
									copy_shape.y = 0
									table.insert(shape_selection, copy_shape)
									select_success = true
									shape_selection_mode = true
									multi_shape_selection = true

								end
							
							end
							
							n = n + 1
							
						end
						
						if select_success then
						
							ui.selectionButton(true, true)
						
						end
						
						if use_rmb then
							if not selection_previously_active then
								ui.selectionButton(false, false)
							end
							
							box_selection_x, box_selection_y = 0, 0
							ui_active = true
							box_selection_active = false
							selection_rmb = false
						end
					
					end
				
					box_selection_x, box_selection_y = 0, 0
					ui_active = true
					box_selection_active = false
				
				else
					
					if box_selection_active then
					
						local sx, sy, sx2, sy2 = (box_selection_x - camera_x), (box_selection_y - camera_y), (mx / camera_zoom) - camera_x, (my / camera_zoom) - camera_y
						if sx2 < sx then sx, sx2 = sx2, sx end
						if sy2 < sy then sy, sy2 = sy2, sy end
						local sw, sh = math.floor(sx2 - sx), math.floor(sy2 - sy)
						sx, sy = math.floor(sx), math.floor(sy)
						local vertex_selection_starting = #vertex_selection
						local select_success = false
					
						if polygon.data[tm.polygon_loc] ~= nil then
			
							local clone = polygon.data[tm.polygon_loc]
							
							local j = 1
							while j <= #clone.raw do
								
								local tx, ty = clone.raw[j].x, clone.raw[j].y
								
								if_line_is_valid = true
								if clone.raw[j].l ~= nil and clone.raw[j].l == "-" then
									if_line_is_valid = false
								end
								
								if if_line_is_valid and tx >= sx and tx <= sx + sw and ty >= sy and ty <= sy + sh then
									
									local vert_exists = false
									local k = 1
									while k <= vertex_selection_starting do
										if vertex_selection[k].index == j then
											vert_exists = true
											k = #vertex_selection + 1
										end
										k = k + 1
									end
									
									if not vert_exists then
									
										local moved_point = {}
										moved_point.index = j
										moved_point.x = tx
										moved_point.y = ty
										table.insert(vertex_selection, moved_point)
										select_success = true
										vertex_selection_mode = true
										
										-- Add vertex sibling if it's a line
										if clone.raw[j].l ~= nil and clone.raw[j].l == "+" then
											
											local sib_1 = clone.raw[j]
											local sib_2 = clone.raw[j - 1]
											
											local moved_point_sister = {}
											moved_point_sister.index = j - 1
											moved_point_sister.t = math.ceil(lume.distance(sib_1.x, sib_1.y, sib_2.x, sib_2.y))
											moved_point_sister.a = -lume.angle(sib_1.x, sib_1.y, sib_2.x, sib_2.y)
											moved_point_sister.x = math.floor(tx + polygon.lengthdir_x(moved_point_sister.t, moved_point_sister.a))
											moved_point_sister.y = math.floor(ty + polygon.lengthdir_y(moved_point_sister.t, moved_point_sister.a))
											
											table.insert(vertex_selection, moved_point_sister)
											
										end
									
									end
									
								end
								
								j = j + 1
							
							end
							
						end
						
						if select_success then
						
							ui.selectionButton(true, true)
						
						end
						
						if use_rmb then
							if not selection_previously_active then
								ui.selectionButton(false, false)
							end
							
							box_selection_x, box_selection_y = 0, 0
							ui_active = true
							box_selection_active = false
							selection_rmb = false
						end
					
					end
				
					box_selection_x, box_selection_y = 0, 0
					ui_active = true
					box_selection_active = false
					
				end
			
			end
		
		end
	
	end
	
	ui.popup_enter = false
	
	-- Make ui active if interacting with palette/layer window
	ui_active = ui_active or (mx >= screen_width - 208)
	
	if mouse_var == _PRESS and ui_active == false then
		ui.preview_action = ""
		ui.preview_palette_enabled = false
	end
	
	if ui.tooltip_disable then
		ui.tooltip_active = -1
		ui.tooltip_timer = 0
	end
	
	return ui_active

end

function ui.scrollButton()

	local layh = screen_height - 403 - 48
	local layer_amt = #ui.layer
	local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
	local calc_pos

	if ui.lyr_dir == "up" then
		calc_pos = (math.floor((ui.lyr_scroll_percent * layer_element_size)/25) * 25) / layer_element_size
			
		if ui.lyr_scroll_percent == calc_pos then
			local new_calc = (math.floor((ui.lyr_scroll_percent * (layer_element_size - 25))/25) * 25) / layer_element_size
			ui.lyr_scroll_percent = lume.clamp(new_calc, 0, 1)
		else
			ui.lyr_scroll_percent = calc_pos
		end
	elseif ui.lyr_dir == "down" then
		calc_pos = (math.ceil((ui.lyr_scroll_percent * (layer_element_size + 25))/25) * 25) / layer_element_size
			
		if calc_pos == 0 then
			local new_calc = 25 / layer_element_size
			ui.lyr_scroll_percent = lume.clamp(new_calc, 0, 1)
		else
			ui.lyr_scroll_percent = lume.clamp(calc_pos, 0, 1)
		end
	end
	
	if ( tostring(ui.lyr_scroll_percent) == "nan" ) then
		ui.lyr_scroll_percent = 0
	end

end

function ui.drawButtonOutline(state, x, y, w, h)
	
	local c_top, c_mid, c_bot = nil, nil, nil
	if (state == BTN_DEFAULT) then
		c_top = c_outline_light
		c_bot = c_outline_dark
	elseif (state == BTN_GRAY) then
		c_top = c_btn_gray_top
		c_mid = c_btn_gray_mid
		c_bot = c_btn_gray
	elseif (state == BTN_PINK) then
		c_top = c_btn_pink_top
		c_mid = c_btn_pink_mid
		c_bot = c_btn_gray
	elseif (state == BTN_HIGHLIGHT_ON) then
		c_top = c_btn_high_top
		c_mid = c_highlight_active
		c_bot = c_btn_high_bot
	elseif (state == BTN_HIGHLIGHT_OFF) then
		c_top = c_btn_high_bot
		c_mid = c_highlight_active
		c_bot = c_btn_high_top
	end
	
	if c_mid ~= nil then
		lg.setColor(c_mid)
		lg.rectangle("fill", x, y, w, h)
	end
	lg.setColor(c_top)
	lg.rectangle("fill", x, y, w - 1, 1)
	lg.rectangle("fill", x, y, 1, h)
	lg.setColor(c_bot)
	lg.rectangle("fill", x + w - 1, y, 1, h)
	lg.rectangle("fill", x + 1, y + h - 1, w - 1, 1)
	
end

function ui.drawOutline(x, y, w, h, invert)
	local ca, cb = c_outline_dark, c_outline_light
	if invert then ca, cb = cb, ca end

	lg.setColor(ca)
	lg.rectangle("fill", x, y, w - 1, 1)
	lg.rectangle("fill", x, y, 1, h)
	lg.setColor(cb)
	lg.rectangle("fill", x + w - 1, y, 1, h)
	lg.rectangle("fill", x + 1, y + h - 1, w - 1, 1)
end

function ui.drawOutlinePal(x, y, w, h, invert)

	lg.setColor(c_outline_dark)
	
	local gap = 35
	if invert then
		gap = 74
		lg.rectangle("fill", x, y, gap - 34, 1)
		lg.rectangle("fill", x + gap - 34, y - 29, 1, 30)
		lg.rectangle("fill", x + gap - 34, y - 29, 33, 1)
	else
		lg.rectangle("fill", x, y - 29, 1, 29)
		lg.rectangle("fill", x, y - 29, gap - 1, 1)
	end
	
	lg.rectangle("fill", x + gap, y, w - 1 - gap, 1)
	lg.rectangle("fill", x, y, 1, h)
	lg.setColor(c_outline_light)
	lg.rectangle("fill", x + w - 1, y, 1, h)
	lg.rectangle("fill", x + 1, y + h - 1, w - 1, 1)
	lg.rectangle("fill", x + gap - 1, y - 29, 1, 30)
end

function ui.draw()

	-- Local vars for palette swapping the editor
	local col_box, col_inactive, col_line_dark, col_line_light = c_box, c_highlight_inactive, c_line_dark, c_line_light
	local tex_btn, tex_slide_1, tex_slide_2, tex_slide_3, tex_gradient = spr_slider_button, spr_slider_1, spr_slider_2, spr_slider_3, grad_slider
	
	if artboard.active then
	
	col_box, col_inactive, col_line_dark, col_line_light = c_art_box, c_art_inactive, c_art_line_dark, c_art_line_light
	tex_btn, tex_slide_1, tex_slide_2, tex_slide_3, tex_gradient = art_slider_button, art_slider_1, art_slider_2, art_slider_3, art_grad_slider
	
	end
	-- End palette swap

	local mx, my = love.mouse.getX(), love.mouse.getY()
	lg.setColor(col_box)
	lg.rectangle("fill", 0, 0, screen_width, 54)
	lg.setColor(c_white)
	lg.draw(grad_large, 0, 1, 0, screen_width/256, 23)
	
	-- Draw vertex and shape selection positions when selecting
	if vertex_selection[1] ~= nil then
		local tx, ty = 94 + 5, screen_height - 50 + 1
		local select_text = ""
		
		local i = 1
		while i <= #vertex_selection do
		
			local this_vert = polygon.data[tm.polygon_loc].raw[vertex_selection[i].index]
			
			if vertex_selection[i].t ~= nil then
				local t_ang = (vertex_selection[i].a * 180 / math.pi) - 90
				if t_ang < 0 then t_ang = t_ang + 360 end
				t_ang = math.floor(t_ang)
				select_text = select_text .. "[" .. vertex_selection[i].index .. "]: {size: " .. vertex_selection[i].t .. ", ang: " .. t_ang .. "°} (" .. this_vert.x .. ", " .. this_vert.y .. ")"
			else
				select_text = select_text .. "[" .. vertex_selection[i].index .. "]: (" .. this_vert.x .. ", " .. this_vert.y .. ")"
			end
			
			if i + 1 <= #vertex_selection then
				select_text = select_text .. ", "
			end
			i = i + 1
		
		end
		
		local tool_width = font:getWidth(select_text) + 12
		lg.setColor(c_background[1], c_background[2], c_background[3], 0.6)
		lg.rectangle("fill", tx - 5, ty - 1, tool_width, 21)
		lg.setColor(c_white)
		lg.print(select_text, tx + 1, ty - 1)
		lg.setColor(c_white)
	end
	
	-- Draw title bar
	
	-- Draw background color of menu item
	if ui.context_menu[1] ~= nil and ui.title_active then
		lg.setColor(c_header_active)
		lg.rectangle("fill", ui.title_x, ui.title_y, ui.title_w, ui.title_h)
	end
	
	-- Draw text of menu item
	lg.setColor(c_white)
	local i
	local title_len = 0
	for i = 1, #ui.title do
		lg.print(ui.title[i].name, 12 + title_len, 3)
		title_len = title_len + font:getWidth(ui.title[i].name) + 15
	end
	
	-- Draw outline around menu item
	if ui.title_active then
		ui.drawOutline(ui.title_x, ui.title_y, ui.title_w, ui.title_h, ui.context_menu[1] == nil)
	end
	
	-- Draw palette
	local psize = 16
	local palw = (13 * psize)
	local palx, paly = screen_width - palw + 8, 192
	
	lg.setColor(col_box)
	lg.rectangle("fill", palx - 8, 52, palw, 300)
	ui.drawOutline(palx - 7, 52, palw - 2, 299, false)
	
	-- Color picker
	ui.drawOutlinePal(palx - 4, 92, palw - 9, 99, ui.palette_mode == "HSL")
	
	lg.setColor(c_black)
	lg.print("RGB", palx + 1, 69)
	lg.print("HSL", palx + 1 + 40, 69)
	
	if my >= 69 and my <= 69 + 18 then
		if ui.palette_mode == "RGB" and mx >= palx + 36 and mx <= palx + 36 + 24 + 10 then
			ui.drawOutline(palx + 41 - 5, 69, 24 + 10, 18,true)
		elseif ui.palette_mode == "HSL" and mx >= palx - 4 and mx <= palx - 4 + 25 + 10 then
			ui.drawOutline(palx + 1 - 5,  69, 25 + 10, 18,true)
		end
	end
	
	local ix, iy = screen_width - 50, 79
	local i
	h = 0
	local ioff = 0
	
	-- Shift index over to HSL values
	if ui.palette_mode == "HSL" then ioff = 3 end
	
	for i = 1 + ioff, 3 + ioff do
		
		-- Textbox of element
		local col = col_inactive
		local this_selected = ui.palette_textbox == i
		if this_selected then
			col = c_highlight_active
			lg.setLineWidth(2)
		end
		
		lg.setColor(c_off_white)
		lg.rectangle("fill", ix - 5, iy + 25 + h - 1, 46, 20)
		lg.setColor(col)
		lg.rectangle("line", ix - 5, iy + 25 + h - 1, 46, 20)
		lg.setColor(c_black)
		lg.print(ui.palette[i].name, ix - font:getWidth(ui.palette[i].name) - 12, iy + 25 + h)

		lg.setLineWidth(1)
		
		local col_val = ui.palette[i].value
		
		if ui.palette_textbox == i and string.len(tostring(ui.palette_text_entry)) == 0 then
			col_val = ""
		end
		lg.print(col_val, ix, iy + 25 + h)
		
		if ui.input_cursor_visible and ui.palette_textbox == i then
			local lxx, lyy = ix + font:getWidth(col_val) + 3, iy + 25 + 3 + h - 1
			lg.line(lxx, lyy, lxx, lyy + 14)
		end
		
		local slide_pos = (tonumber(ui.palette[i].value) / 255) * 111
		
		local slx, sly, slw = ix - 147, iy + 25 + h - 1, 122
		
		lg.setColor(c_white)
		lg.draw(tex_slide_1, slx, sly + 9)
		lg.draw(tex_slide_2, slx + 1, sly + 9, 0, (slw - 3)/1, 1)
		lg.draw(tex_slide_3, slx + slw - 2, sly + 9)
		lg.draw(tex_btn, slx + slide_pos, sly)
		
		h = h + 28
	
	end
	
	-- Palette
	ui.drawOutline(palx - 4, paly - 7 + 16, palw - 9, (16 * 7) - 3, false)
	local i
	local sel_i, sel_j = -1, -1
	for i = 1, palette.h do
	
		local j
		for j = 1, palette.w do
		
			local index = (j - 1) + ((i - 1) * palette.w)
			if index < #palette.colors then
			lg.setColor(palette.colors[index + 1])
			else
			lg.setColor(c_black)
			end
			
			lg.rectangle("fill", palx + (j - 1) * psize, paly + i * psize, psize - 1, psize - 1)
			
			if index == palette.slot then
				sel_i, sel_j = i, j
			end
		
		end
	
	end
	
	-- Selected color
	if sel_i ~= -1 then
		lg.setColor(c_outline_light)
		lg.rectangle("line", palx + (sel_j - 1) * psize, paly + sel_i * psize, psize - 1, psize - 1)
		lg.setColor(c_outline_dark)
		lg.rectangle("line", palx - 1 + (sel_j - 1) * psize, paly - 1 + sel_i * psize, psize + 1, psize + 1)
	end
	
	-- Current color
	lg.setColor(palette.active)
	lg.rectangle("fill", palx - 4, paly + (16 * 8) - 5, palw - 9, 30)
	ui.drawOutline(palx - 4, paly + (16 * 8) - 5, palw - 9, 30)
	
	-- Draw layer menu
	local layx, layy = screen_width - 208, 352
	local layw = 208 - 2 - 16
	local layh = screen_height - 403 - 48
	
	-- Fill area
	lg.setColor(col_box)
	lg.rectangle("fill", layx, layy, 208, screen_height - layy)
	
	ui.drawOutline(layx + 1, layy + 10, layw + 16, 30)
	
	-- Draw add + trash icons
	local btn_state = BTN_DEFAULT

	local mouse_hover_tool = false
	mouse_hover_tool = ((mx >= layx + 4) and (mx <= layx + 4 + 23) and (my >= layy + 13) and (my <= layy + 13 + 23))
	
	if mouse_hover_tool and (ui.lyr_button_active == -1) then
		btn_state = BTN_HIGHLIGHT_ON
	end
	
	if (mouse_switch ~= _OFF) and (ui.lyr_button_active == 1) then
		btn_state = BTN_HIGHLIGHT_OFF
	end
	
	if document_w == 0 then
		btn_state = BTN_GRAY
	end
	
	ui.drawButtonOutline(btn_state, layx + 4, layy + 13, 24, 24)
	lg.setColor(c_white)
	lg.draw(icon_add,   layx + 4, layy + 13)
	
	local btn_state = BTN_DEFAULT

	local mouse_hover_tool = false
	mouse_hover_tool = ((mx >= layx + 4 + 24 + 4 + 24) and (mx <= layx + 4 + 23 + 24 + 4 + 24) and (my >= layy + 13) and (my <= layy + 13 + 23))
	
	if mouse_hover_tool and (ui.lyr_button_active == -1) then
		btn_state = BTN_HIGHLIGHT_ON
	end
	
	if (mouse_switch ~= _OFF) and (ui.lyr_button_active == 2) then
		btn_state = BTN_HIGHLIGHT_OFF
	end
	
	if document_w == 0 then
		btn_state = BTN_GRAY
	end
	
	ui.drawButtonOutline(btn_state, layx + 4 + 24 + 4 + 24 + 4, layy + 13, 24, 24)
	lg.setColor(c_white)
	lg.draw(icon_trash, layx + 4 + 24 + 4 + 24 + 4, layy + 13)
	
	local btn_state = BTN_DEFAULT

	local mouse_hover_tool = false
	mouse_hover_tool = ((mx >= layx + 4 + 24 + 4) and (mx <= layx + 4 + 23 + 24 + 4) and (my >= layy + 13) and (my <= layy + 13 + 23))
	
	if mouse_hover_tool and (ui.lyr_button_active == -1) then
		btn_state = BTN_HIGHLIGHT_ON
	end
	
	if (mouse_switch ~= _OFF) and (ui.lyr_button_active == 3) then
		btn_state = BTN_HIGHLIGHT_OFF
	end
	
	if document_w == 0 then
		btn_state = BTN_GRAY
	end
	
	ui.drawButtonOutline(btn_state, layx + 4 + 24 + 4, layy + 13, 24, 24)
	lg.setColor(c_white)
	lg.draw(icon_clone, layx + 4 + 24 + 4, layy + 13)
	
	-- Draw layers in window
	local layer_amt = #ui.layer
	
	local layer_element_size = math.max((25 * layer_amt) - layh - 1, 0)
	
	if (layer_element_size == 0 and not ui.lyr_scroll) then
		ui.lyr_scroll_percent = 0
	end
	
	local scroll_offset = math.floor(ui.lyr_scroll_percent * layer_element_size)
	
	-- use scissor to cull other layers
	lg.setScissor(layx + 1, layy + 40, layw, layh)
	lg.translate(0, -scroll_offset)
	
	if ui.layer[1] ~= nil then
		local i
		for i = layer_amt, 1, -1 do
			local yy = 40 + ((layer_amt - i) * 25)
			
			local box_color = col_inactive
			
			if ui.layer[i].count == tm.polygon_loc then
				lg.setColor(c_highlight_active)
				lg.rectangle("fill", layx + 32, layy + yy, layw, 25)
				box_color = c_layer_box
			end
			
			lg.setColor(c_outline_dark)
			lg.print(ui.layer[i].name, layx + 77, layy + yy + 3)
			lg.rectangle("fill", layx + 1, layy + yy + 24, layw, 1)
			lg.rectangle("fill", layx + 32, layy + yy, 1, 24)
			
			if ui.textbox_rename_layer == i then

				local col = box_color
				
				local this_item = ui.layer[ui.textbox_rename_layer]
				
				local ix, iy = layx + 77, layy + yy - 24
				lg.setColor(c_off_white)
				lg.rectangle("fill", ix - 5, iy + 25, 116, 21)
				lg.setColor(col)
				lg.rectangle("line", ix - 5, iy + 25, 116, 21)
				lg.setColor(c_black)
				lg.print(this_item.name, ix, iy + 26 + 1)

				if ui.input_cursor_visible then
					local lxx, lyy = ix + font:getWidth(this_item.name) + 3, iy + 25 + 3
					lg.line(lxx, lyy, lxx, lyy + 16)
				end
				
			end
			
			lg.setColor(c_white)
			
			if ui.layer[i].visible then
			lg.draw(icon_eye, layx + 5, layy + yy)
			else
			lg.draw(icon_blink, layx + 5, layy + yy)
			end
			
			local body_color = palette.active
			if polygon.data[ui.layer[i].count] ~= nil then
				body_color = polygon.data[ui.layer[i].count].color
			end
			
			lg.setColor(body_color)
			lg.rectangle("fill", layx + 37, layy + yy + 3, 31, 17)
			lg.setColor(box_color)
			lg.rectangle("line", layx + 37, layy + yy + 3, 31, 17)
			
		end
	end
	
	lg.translate(0, scroll_offset)
	lg.setScissor(0, 0, screen_width, screen_height)
	
	local draw_l = false
	local lx, ly, lw, lh
	
	if ui.lyr_clicked ~= 0 and (math.abs(my - ui.lyr_click_y) > 4) then
	
		ui.lyr_click_y = 9999
		
		local l_alpha = 0.1
		local yy = 40 + ((layer_amt - ui.lyr_clicked) * 25)
		local box_color = {col_inactive[1], col_inactive[2], col_inactive[3], l_alpha}
		
		local sel_x, sel_y = 0, my - layy - yy
		lg.translate(sel_x, sel_y)
		
		lg.setColor({c_highlight_active[1], c_highlight_active[2], c_highlight_active[3], l_alpha})
		lg.rectangle("fill", layx + 32, layy + yy, layw - 32, 25)
		box_color = {c_layer_box[1], c_layer_box[2], c_layer_box[3], l_alpha}
		
		lg.setColor({0,0,0,l_alpha})
		lg.print(ui.layer[ui.lyr_clicked].name, layx + 77, layy + yy + 3)
		lg.rectangle("fill", layx + 1, layy + yy + 24, layw - 1, 1)
		lg.rectangle("fill", layx + 1, layy + yy, layw - 1, 1)
		lg.rectangle("fill", layx + 32, layy + yy, 1, 24)
		
		lg.setColor({c_outline_dark[1],c_outline_dark[2],c_outline_dark[3],l_alpha})
		
		if ui.layer[ui.lyr_clicked].visible then
		lg.draw(icon_eye, layx + 5, layy + yy)
		else
		lg.draw(icon_blink, layx + 5, layy + yy)
		end
		
		local body_color = {palette.active[1], palette.active[2], palette.active[3], l_alpha}
		if polygon.data[ui.layer[ui.lyr_clicked].count] ~= nil then
			local old_cc = polygon.data[ui.layer[ui.lyr_clicked].count].color
			body_color = {old_cc[1], old_cc[2], old_cc[3], l_alpha}
		end
		
		lg.setColor(body_color)
		lg.rectangle("fill", layx + 37, layy + yy + 3, 31, 17)
		lg.setColor(box_color)
		lg.rectangle("line", layx + 37, layy + yy + 3, 31, 17)
		
		lg.translate(-sel_x, -sel_y)
		
		-- Highlight bars when rearranging layers
		local moffset = my - 392
		local y_test = (moffset + scroll_offset)
		local layer_top = math.floor((moffset + scroll_offset) / 25) * 25
		local layer_num = layer_amt - math.floor((moffset + scroll_offset) / 25)
		
		if (my >= 392 - 6) and (my <= screen_height - 52) then -- Keep within bounds of layer selector
		
			if layer_num >= 0 and layer_num <= layer_amt then
			
				if math.abs(y_test - layer_top) < 8 then
					lx = layx + 32
					ly = 392 + layer_top - 3 - scroll_offset
					lw = layw - 32
					lh = 5
					draw_l = true
				end
				
				if math.abs(y_test - layer_top + 24) < 8 then
					lx = layx + 32
					ly = 392 + layer_top + 21 - scroll_offset
					lw = layw - 32
					lh = 5
					draw_l = true
				end
				
			elseif (layer_num >= 0) and (my >= 392 - 6) then
			
				lx = layx + 32
				ly = 392 - 3 - scroll_offset
				lw = layw - 32
				lh = 5
				draw_l = true
			
			end
			
		end
	
	end
	
	-- Draw layer slider
	ui.drawOutline(screen_width - 16, layy + 41, 15, 14, true)
	ui.drawOutline(screen_width - 16, screen_height - 24 - 48, 15, 14, true)
	
	lg.setColor(c_white)
	lg.draw(tex_gradient,   screen_width - 16, layy + 41 + 14, 0, 1, layh - 28)
	lg.draw(spr_arrow_up,   screen_width - 12, layy + 41 + 4)
	lg.draw(spr_arrow_down, screen_width - 12, screen_height - 24 + 4 - 48)
	
	-- Scroll button
	lg.setColor(col_box)
	local scroll_len = screen_height - 38 - (layy + 41 + 14) - 48
	lg.rectangle("fill", screen_width - 16, layy + 41 + 14 + math.floor(scroll_len * ui.lyr_scroll_percent), 15, 14)
	ui.drawOutline(screen_width - 16, layy + 41 + 14 + math.floor(scroll_len * ui.lyr_scroll_percent), 15, 14, true)
	
	ui.drawOutline(layx + 1, layy + 10 + 29, layw, screen_height - layy - 20 - 29 - 48)
	
	if draw_l then
		
		-- Keep ly within bounds of layer menu
		ly = lume.clamp(ly, 392-6+3, screen_height-6-7)
		
		lg.setColor(c_off_white)
		lg.rectangle("fill", lx, ly, lw, lh)
		lg.setColor(c_outline_dark)
		lg.rectangle("fill", lx, ly + 2, lw, lh - 4)
			
	end
	
	-- Draw toolbar
	lg.setColor(col_box)
	lg.rectangle("fill", 0, 54, 64, screen_height - 54)
	
	lg.setColor(col_inactive)
	lg.rectangle("fill", 1, 26, screen_width - 2, 1)
	lg.rectangle("fill", 1, 53, 61, 1)
	lg.rectangle("fill", 2, 26, 1, screen_height - 27)
	lg.rectangle("fill", 63, 26, 1, 26)
	
	lg.setColor(c_outline_dark)
	lg.rectangle("fill", 1, 25, screen_width - 2, 1)
	lg.rectangle("fill", 1, 52, screen_width - 2, 1)
	lg.rectangle("fill", screen_width - 2, 25, 1, 27)
	lg.rectangle("fill", 1, 26, 1, screen_height - 27)
	lg.rectangle("fill", 62, 26, 1, screen_height - 27)
	lg.rectangle("fill", 1, screen_height - 2, 61, 1)
	
	-- Draw toolbar items
	local i
	local h, xx = 0, 0
	local even_count = 0
	for i = 1, #ui.toolbar do
		if ui.toolbar[i]._break == nil then
		
			local ix, iy = 8 + (xx * 24), 61 + h
			
			local btn_state = BTN_DEFAULT
			if ui.toolbar[i].active == false then
				btn_state = BTN_GRAY
				
				if artboard.active then
					btn_state = BTN_PINK
				end
				
			else
			
				local mouse_hover_tool = false
				mouse_hover_tool = ((mx >= ix) and (mx <= ix + 23) and (my >= iy) and (my <= iy + 23))
				
				if mouse_hover_tool and (ui.toolbar_clicked == -1) then
					btn_state = BTN_HIGHLIGHT_ON
				end
				
				if (mouse_switch ~= _OFF) and (ui.toolbar_clicked == i) then
					btn_state = BTN_HIGHLIGHT_OFF
				end
			
			end
			
			ui.drawButtonOutline(btn_state, ix, iy, 24, 24)
			
			lg.setColor(c_white)
			lg.draw(ui.toolbar[i].icon, ix, iy)
			
			xx = xx + 1
			if xx == 2 then xx = 0 h = h + 24 end
			even_count = even_count + 1
			
		else
		
			if (even_count % 2 == 0) then
				h = h - 24
			end
			h = h + 36
		
			lg.setColor(col_line_dark)
			lg.rectangle("fill", 8, 54 + h, 48, 1)
			
			lg.setColor(col_line_light)
			lg.rectangle("fill", 8, 55 + h, 48, 1)
			
			xx = 0
			
		end
	end
	
	-- Draw info section
	local info_x, info_y = screen_width - 199, screen_height - 54
	local infomx, infomy = math.floor((love.mouse.getX() / camera_zoom) - camera_x), math.floor((love.mouse.getY() / camera_zoom) - camera_y)
	
	lg.setColor(c_black)
	lg.print("Size: " .. document_w .. ", " .. document_h, info_x, info_y)
	lg.print("Mouse: " .. infomx .. ", " .. infomy, info_x, info_y + 15)
	lg.print("Zoom: " .. math.floor(camera_zoom * 100) .. "%", info_x, info_y + 30)
	lg.printf("Tris: " .. total_triangles, info_x, info_y + 30, 190, "right")
	
	-- Draw active toolbar shortcuts
	local ix, iy
	ix = 8
	iy = 27
	
	lg.setColor(c_outline_dark)
	lg.rectangle("fill", ix + 24, iy - 1, 1, 26)
	lg.setColor(col_inactive)
	lg.rectangle("fill", ix + 25, iy - 1, 1, 26)
	lg.setColor(c_white)
	
	if artboard.active then
		lg.draw(ui.toolbar[ui.toolbar_artboard].icon, ix - 2, iy)
	elseif polygon.kind == "polygon" and polygon.line == false then
		lg.draw(ui.toolbar[ui.toolbar_polygon].icon, ix - 2, iy + 1)
	elseif polygon.kind == "ellipse" then
		lg.draw(ui.toolbar[ui.toolbar_ellipse].icon, ix - 3, iy)
	else
		lg.draw(ui.toolbar[ui.toolbar_polyline].icon, ix - 2, iy)
	end
	
	if document_w ~= 0 then
		if ui.toolbar[ui.toolbar_select].active == false then
			lg.draw(ui.toolbar[ui.toolbar_select].icon, ix + 28, iy)
		elseif ui.toolbar[ui.toolbar_shape].active == false then
			lg.draw(ui.toolbar[ui.toolbar_shape].icon, ix + 28, iy + 1)
		elseif ui.toolbar[ui.toolbar_pick].active == false then
			lg.draw(ui.toolbar[ui.toolbar_pick].icon, ix + 27, iy)
		elseif ui.toolbar[ui.toolbar_zoom].active == false then
			lg.draw(ui.toolbar[ui.toolbar_zoom].icon, ix + 28, iy)
		elseif ui.toolbar[ui.toolbar_grid].active == false then
			lg.draw(ui.toolbar[ui.toolbar_grid].icon, ix + 28, iy + 1)
		end
	end
	
	-- Draw toolbar panels
	
	local panel_x = 70 + 4
	
	if ui.primary_panel[1] ~= nil then
		
		lg.setColor(c_black)
		lg.print(ui.primary_panel.name, panel_x, 29)
		panel_x = panel_x + font:getWidth(ui.primary_panel.name) + 12
		
		local i = 1
		for i = 1, #ui.primary_panel do
		
			local this_item = ui.primary_panel[i]
			if this_item.is_textbox then
			
				-- Title of element
				lg.setColor(c_black)
				lg.print(this_item.name, panel_x, 29)
				panel_x = panel_x + font:getWidth(this_item.name) + 12
				
				-- Textbox of element
				local col = col_inactive
				local this_selected = ui.primary_textbox == i
				if this_selected then
					col = c_highlight_active
					lg.setLineWidth(2)
				end

				local text_ending = ""
				if this_item.id == "art.opacity" then
					text_ending = "%"
				end
				
				local ix, iy = panel_x, 3
				lg.setColor(c_off_white)
				lg.rectangle("fill", ix - 5, iy + 25, 46, 20)
				lg.setColor(col)
				lg.rectangle("line", ix - 5, iy + 25, 46, 20)
				lg.setColor(c_black)
				lg.print(this_item.value .. text_ending, ix, iy + 26)
				panel_x = panel_x + 46 + 6

				lg.setLineWidth(1)

				if ui.input_cursor_visible and this_selected then
					local lxx, lyy = ix + font:getWidth(ui.primary_panel[i].value .. text_ending) + 3, iy + 25 + 3
					lg.line(lxx, lyy, lxx, lyy + 14)
				end
			
			else
			
				local this_item = ui.primary_panel[i]
				local btn_state = BTN_DEFAULT
				if this_item.active == false then
					btn_state = BTN_GRAY
					
					if artboard.active then
						btn_state = BTN_PINK
					end
					
				else
				
					local mouse_hover_tool = false
					mouse_hover_tool = ((mx >= panel_x) and (mx <= panel_x + 23) and (my >= 27) and (my <= 27 + 23))
					
					if mouse_hover_tool and (ui.primary_clicked == -1) then
						btn_state = BTN_HIGHLIGHT_ON
					end
					
					if (mouse_switch ~= _OFF) and (ui.primary_clicked == i) then
						btn_state = BTN_HIGHLIGHT_OFF
					end
				
				end
				
				ui.drawButtonOutline(btn_state, panel_x, 27, 24, 24)
				
				lg.setColor(c_white)
				lg.draw(this_item.icon, panel_x, 27)
				
				if ui.primary_panel[i].id == "art.position" or ui.primary_panel[i].id == "polyline.ruler" then
					panel_x = panel_x + 8
				end
				panel_x = panel_x + 24 + 4
			
			end
		
		end
		
	end
	
	if ui.secondary_panel[1] ~= nil then
		
		-- Add line divider
		if ui.primary_panel[1] ~= nil then
			lg.setColor(c_outline_dark)
			lg.rectangle("fill", panel_x, 26, 1, 26)
			lg.setColor(col_inactive)
			lg.rectangle("fill", panel_x + 1, 26, 1, 26)
			lg.setColor(c_white)
			panel_x = panel_x + 12
		end
		
		lg.setColor(c_black)
		lg.print(ui.secondary_panel.name, panel_x, 29)
		panel_x = panel_x + font:getWidth(ui.secondary_panel.name) + 12
		
		local i = 1
		for i = 1, #ui.secondary_panel do
		
			local this_item = ui.secondary_panel[i]
			if this_item.is_textbox then
			
				local temp_name = this_item.name
				if this_item.id == "zoom.type" then
					if ui.zoom_textbox_mode ~= "px" then
						temp_name = " %"
					end
				end
			
				-- Title of element
				lg.setColor(c_black)
				lg.print(temp_name, panel_x, 29)
				panel_x = panel_x + font:getWidth(this_item.name) + 12
				
				-- Textbox of element
				local col = col_inactive
				local this_selected = ui.secondary_textbox == i
				if this_selected then
					col = c_highlight_active
					lg.setLineWidth(2)
				end

				local text_ending = ""
				if this_item.id == "art.opacity" then
					text_ending = "%"
				end
				
				local ix, iy = panel_x, 3
				lg.setColor(c_off_white)
				lg.rectangle("fill", ix - 5, iy + 25, 46, 20)
				lg.setColor(col)
				lg.rectangle("line", ix - 5, iy + 25, 46, 20)
				lg.setColor(c_black)
				lg.print(this_item.value .. text_ending, ix, iy + 26)
				panel_x = panel_x + 46 + 6

				lg.setLineWidth(1)

				if ui.input_cursor_visible and this_selected then
					local lxx, lyy = ix + font:getWidth(ui.secondary_panel[i].value .. text_ending) + 3, iy + 25 + 3
					lg.line(lxx, lyy, lxx, lyy + 14)
				end
			
			else
			
				local this_item = ui.secondary_panel[i]
				local btn_state = BTN_DEFAULT
				if this_item.active == false then
					btn_state = BTN_GRAY
					
					if artboard.active then
						btn_state = BTN_PINK
					end
					
				else
				
					local mouse_hover_tool = false
					mouse_hover_tool = ((mx >= panel_x) and (mx <= panel_x + 23) and (my >= 27) and (my <= 27 + 23))
					
					if mouse_hover_tool and (ui.secondary_clicked == -1) then
						btn_state = BTN_HIGHLIGHT_ON
					end
					
					if (mouse_switch ~= _OFF) and (ui.secondary_clicked == i) then
						btn_state = BTN_HIGHLIGHT_OFF
					end
				
				end
				
				ui.drawButtonOutline(btn_state, panel_x, 27, 24, 24)
				
				lg.setColor(c_white)
				lg.draw(this_item.icon, panel_x, 27)
				
				panel_x = panel_x + 24 + 4
			
			end
		
		end
		
	end
	
	-- Draw preview window
	if ui.preview_active then
	
		local rx, ry, rw, rh = ui.preview_x, ui.preview_y, ui.preview_w, ui.preview_h
		
		lg.setColor(col_box)
		lg.rectangle("fill", rx, ry, rw, rh)
		lg.setColor(c_white)
		local toolbar_color = grad_active
		local prev_buttons_enabled = true
		if ui.popup[1] ~= nil then
			toolbar_color = grad_inactive
			prev_buttons_enabled = false
		end
		lg.draw(toolbar_color, rx, ry + 1, 0, rw/256, 23)
		
		lg.print("Preview", rx + 10, ry + 3)
		lg.setColor(ui.preview_bg_color)
		lg.rectangle("fill", rx + 1, ry + 25, rw - 2, rh - 26 - 28)
		ui.drawOutline(rx + 1, ry + 25, rw - 2, rh - 26 - 28)
		
		local old_zoom = camera_zoom
		local bx, by, bw, bh = rx + 3, ry + 27, rw - 5, rh - 29 - 28
		
		lg.push()
		lg.setScissor(bx, by, bw, bh)
		lg.translate(bx, by)
		lg.translate(math.floor(ui.preview_window_x * ui.preview_zoom), math.floor(ui.preview_window_y * ui.preview_zoom))
		
		if ui.preview_flip_h then
			lg.translate(document_w * ui.preview_zoom, 0)
			lg.scale(-1, 1)
		end
		
		if ui.preview_flip_v then
			lg.translate(0, document_h * ui.preview_zoom)
			lg.scale(1, -1)
		end
		
		camera_zoom = ui.preview_zoom
		
		if artboard.draw_top and artboard.canvas ~= nil and ui.preview_artboard_enabled then
			local artcol = {1, 1, 1, artboard.opacity}
			
			lg.setColor(artcol)
			lg.draw(artboard.canvas, 0, 0, 0, ui.preview_zoom)
		end
		
		polygon.draw(false)
		
		if not artboard.draw_top and artboard.canvas ~= nil and ui.preview_artboard_enabled then
			local artcol = {1, 1, 1, artboard.opacity}
			
			lg.setColor(artcol)
			lg.draw(artboard.canvas, 0, 0, 0, ui.preview_zoom)
		end
		
		camera_zoom = old_zoom
		lg.setScissor()
		lg.pop()
		
		-- Draw preview buttons
		
		-- Textbox for scale input
		local col = col_inactive
		local this_selected = (not ui.preview_textbox_locked)
		if this_selected then
			col = c_highlight_active
			lg.setLineWidth(2)
		end
		
		local ix, iy = rx + 36, ry + rh - 50
		lg.setColor(c_off_white)
		lg.rectangle("fill", ix - 5, iy + 25, 46, 20)
		lg.setColor(col)
		lg.rectangle("line", ix - 5, iy + 25, 46, 20)
		lg.setColor(c_black)
		lg.print(ui.preview_textbox_mode, ix - font:getWidth(ui.preview_textbox_mode) - 12, iy + 26)
		lg.print(ui.preview_textbox, ix, iy + 26)
		
		lg.setLineWidth(1)
		
		if ui.input_cursor_visible and this_selected then
			local lxx, lyy = ix + font:getWidth(ui.preview_textbox) + 3, iy + 25 + 3
			lg.line(lxx, lyy, lxx, lyy + 14)
		end
		
		-- Move vars to be near the button positions
		ix = ix + 49
		iy = iy + 24
		
		-- Other buttons
		
		-- Close window button (x)
		lg.setColor(col_box)
		lg.rectangle("fill", rx + rw - 22, ry + 5, 18, 15)
		ui.drawOutline(rx + rw - 22, ry + 5, 18, 15, true)
		lg.setColor(c_white)
		lg.draw(icon_close, rx + rw - 22 + 5, ry + 9)
		
		-- Zoom In
		local btn_state = BTN_DEFAULT

		local mouse_hover_tool = false
		mouse_hover_tool = ((mx >= ix) and (mx <= ix + 23) and (my >= iy) and (my <= iy + 23))
		
		if mouse_hover_tool and (ui.preview_button_active == -1) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_ON
		end
		
		if (mouse_switch ~= _OFF) and (ui.preview_button_active == 1) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_OFF
		end
		ui.drawButtonOutline(btn_state, ix, iy, 24, 24)
		lg.setColor(c_white)
		lg.draw(icon_zoom_in, ix, iy)
		
		-- Zoom Out
		local btn_state = BTN_DEFAULT

		local mouse_hover_tool = false
		mouse_hover_tool = ((mx >= ix + 28) and (mx <= ix + 23 + 28) and (my >= iy) and (my <= iy + 23))
		
		if mouse_hover_tool and (ui.preview_button_active == -1) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_ON
		end
		
		if (mouse_switch ~= _OFF) and (ui.preview_button_active == 2) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_OFF
		end
		ui.drawButtonOutline(btn_state, ix + 28, iy, 24, 24)
		lg.setColor(c_white)
		lg.draw(icon_zoom_out, ix + 28, iy)
		
		-- Reset scale
		local btn_state = BTN_DEFAULT

		local mouse_hover_tool = false
		mouse_hover_tool = ((mx >= ix + 56) and (mx <= ix + 23 + 56) and (my >= iy) and (my <= iy + 23))
		
		if mouse_hover_tool and (ui.preview_button_active == -1) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_ON
		end
		
		if (mouse_switch ~= _OFF) and (ui.preview_button_active == 3) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_OFF
		end
		ui.drawButtonOutline(btn_state, ix + 56, iy, 24, 24)
		lg.setColor(c_white)
		lg.draw(icon_reset, ix + 56, iy)
		
		-- Fit to window
		local btn_state = BTN_DEFAULT

		local mouse_hover_tool = false
		mouse_hover_tool = ((mx >= ix + 84) and (mx <= ix + 23 + 84) and (my >= iy) and (my <= iy + 23))
		
		if mouse_hover_tool and (ui.preview_button_active == -1) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_ON
		end
		
		if (mouse_switch ~= _OFF) and (ui.preview_button_active == 4) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_OFF
		end
		ui.drawButtonOutline(btn_state, ix + 84, iy, 24, 24)
		lg.setColor(c_white)
		lg.draw(icon_fit, ix + 84, iy)
		
		-- Toggle artboard
		local btn_state = BTN_DEFAULT

		local mouse_hover_tool = false
		mouse_hover_tool = ((mx >= ix + 112) and (mx <= ix + 23 + 112) and (my >= iy) and (my <= iy + 23))
		
		if mouse_hover_tool and (ui.preview_button_active == -1) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_ON
		end
		
		if (mouse_switch ~= _OFF) and (ui.preview_button_active == 5) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_OFF
		end
		
		if ui.preview_artboard_enabled then
			btn_state = BTN_GRAY
		end
		ui.drawButtonOutline(btn_state, ix + 112, iy, 24, 24)
		lg.setColor(c_white)
		lg.draw(icon_draw, ix + 112, iy)
		
		-- Toggle horizontal flip
		local btn_state = BTN_DEFAULT

		local mouse_hover_tool = false
		mouse_hover_tool = ((mx >= ix + 140) and (mx <= ix + 23 + 140) and (my >= iy) and (my <= iy + 23))
		
		if mouse_hover_tool and (ui.preview_button_active == -1) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_ON
		end
		
		if (mouse_switch ~= _OFF) and (ui.preview_button_active == 6) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_OFF
		end
		
		if ui.preview_flip_h then
			btn_state = BTN_GRAY
		end
		ui.drawButtonOutline(btn_state, ix + 140, iy, 24, 24)
		lg.setColor(c_white)
		lg.draw(icon_flip_h, ix + 140, iy)
		
		-- Toggle vertical flip
		local btn_state = BTN_DEFAULT

		local mouse_hover_tool = false
		mouse_hover_tool = ((mx >= ix + 168) and (mx <= ix + 23 + 168) and (my >= iy) and (my <= iy + 23))
		
		if mouse_hover_tool and (ui.preview_button_active == -1) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_ON
		end
		
		if (mouse_switch ~= _OFF) and (ui.preview_button_active == 7) and prev_buttons_enabled then
			btn_state = BTN_HIGHLIGHT_OFF
		end
		
		if ui.preview_flip_v then
			btn_state = BTN_GRAY
		end
		ui.drawButtonOutline(btn_state, ix + 168, iy, 24, 24)
		lg.setColor(c_white)
		lg.draw(icon_flip_v, ix + 168, iy)
		
		-- Background color
		lg.setColor(ui.preview_bg_color)
		lg.rectangle("fill", rx + rw - 26, iy, 23, 23)
		lg.setColor(c_outline_dark)
		lg.rectangle("line", rx + rw - 26, iy, 23, 23)
		lg.setColor(c_outline_light)
		lg.rectangle("line", rx + rw - 26 + 1, iy + 1, 21, 21)
	
	end
	
	-- Draw popup box
	if ui.popup[1] ~= nil then
	
		local px, py, pw, ph, pxo = ui.popup_x, ui.popup_y, ui.popup_w, ui.popup_h, ui.popup_x_offset
	
		lg.setColor(col_box)
		lg.rectangle("fill", px, py, pw, ph)
		lg.setColor(c_white)
		lg.draw(grad_active, px, py + 1, 0, pw/256, 23)
		
		lg.print(ui.popup[1][1].name, px + 10, py + 3)
		ui.drawOutline(px + 1, py + 25, pw - 2, ph - 26)
		
		if ui.popup[1][1].kind == "h.about" then
			lg.setColor(c_white)
			lg.draw(icon_sodalite, px + 22, py + 78 - 5)
		end

		if ui.popup[1][1].kind == "f.convert" then
			lg.setColor(c_white)
			local count_box = (100/7) * save_svg_progress
			lg.draw(grad_inactive, px + 14, py + 42, 0, 100/256, 23)
			lg.draw(grad_active, px + 14, py + 42, 0, count_box/256, 23)
		end
		
		local i
		local h = 12
		for i = 2, #ui.popup do
			
			local j
			for j = 1, #ui.popup[i] do
			
				lg.setColor(c_black)
				
				local name = ui.popup[i][j].name
				local kind = ui.popup[i][j].kind
				
				local col = col_inactive
				local this_selected = (i == ui.popup_sel_a and j == ui.popup_sel_b)
				if this_selected then
					col = c_highlight_active
					lg.setLineWidth(2)
				end
			
				if kind == "text" then
					if ui.popup[1][1].kind == "h.about" then
						lg.print(name, math.floor(px + pw - font:getWidth(name) - 24), math.floor(py + 25 + h))
					elseif ui.popup[1][1].kind == "save.disabled" then
						lg.print(name, px + 22, math.floor(py + 25 + 3 + h*1.5/2))
					elseif ui.popup[1][1].kind == "f.exit" or ui.popup[1][1].kind == "f.overwrite" then
						lg.print(name, math.floor(px + 24), math.floor(py + 25 + h))
					else
						lg.print(name, math.floor(px + (pw / 2) - font:getWidth(name) - 12 + pxo), math.floor(py + 25 + h))
					end
				elseif kind == "textbox" then
					lg.setColor(c_off_white)
					lg.rectangle("fill", px + (pw / 2) - 5 + pxo, py + 25 + h - 1, 251, 20)
					lg.setColor(col)
					lg.rectangle("line", px + (pw / 2) - 5 + pxo, py + 25 + h - 1, 251, 20)
					lg.setColor(c_black)
					lg.print(name, px + (pw / 2) + pxo, py + 25 + h)
				elseif kind == "number" then
					lg.setColor(c_off_white)
					lg.rectangle("fill", px + (pw / 2) - 5 + pxo, py + 25 + h - 1, 46, 20)
					lg.setColor(col)
					lg.rectangle("line", px + (pw / 2) - 5 + pxo, py + 25 + h - 1, 46, 20)
					lg.setColor(c_black)
					lg.print(name, px + (pw / 2) + pxo, py + 25 + h)
				elseif kind == "ok" then
					local bx, by
					if ui.popup[1][1].kind == "h.about" then
						bx = math.floor(px + (pw / 2) - 9)
						by = math.floor(py + 25 + h + 6)
					else
						bx = math.floor(px + (pw / 2) - 32 - 19)
						by = math.floor(py + 25 + h + 6)
					end
					
					ui.drawOutline(bx - 8, by - 3, 35, 25, true)
					lg.print(name, bx, by)
				elseif kind == "overwrite" then
					local bx, by
					bx = math.floor(px + (pw / 2) - 62 - (pw / 6))
					by = math.floor(py + 25 + h + 6)
					ui.drawOutline(bx - 8, by - 3, 75, 25, true)
					lg.print(name, bx, by)
				elseif kind == "rename" then
					local bx, by
					bx = math.floor(px + (pw / 2) - 25)
					by = math.floor(py + 25 + h + 6)
					ui.drawOutline(bx - 7, by - 3, 64, 25, true)
					lg.print(name, bx, by)
				elseif kind == "continue" then
					local bx, by
					bx = math.floor(px + (pw / 2) - 107)
					by = math.floor(py + h + 6 - 10)
					ui.drawOutline(bx - 8, by - 3, 163, 25, true)
					lg.print(name, bx, by)
				elseif kind == "exit" then
					local bx, by
					bx = math.floor(px + (pw / 2) + 61 + 17 + 6)
					by = math.floor(py + h + 6 - 10)
					ui.drawOutline(bx - 7, by - 3, 38, 25, true)
					lg.print(name, bx + 1, by)
				elseif kind == "save" then
					local bx, by
					bx = math.floor(px + (pw / 2) - 20 - 22 - (pw / 6) - 4)
					by = math.floor(py + 25 + h + 6)
					ui.drawOutline(bx - 8, by - 3, 44, 25, true)
					lg.print(name, bx, by)
				elseif kind == "discard" then
					local bx, by
					bx = math.floor(px + (pw / 2) - 21 - 4 - 2)
					by = math.floor(py + 25 + h + 6)
					ui.drawOutline(bx - 7, by - 3, 58, 25, true)
					lg.print(name, bx, by)
				elseif kind == "cancel" then
					local bx, by
					if ui.popup[1][1].kind == "f.exit" then
						bx = math.floor(px + (pw / 2) - 21 + 32 + (pw / 6) - 4)
						by = math.floor(py + 25 + h + 6)
					elseif ui.popup[1][1].kind == "f.overwrite" then
						bx = math.floor(px + (pw / 2) + 4 + (pw / 6))
						by = math.floor(py + 25 + h + 6)
					else
						bx = math.floor(px + (pw / 2) + 32 - 19)
						by = math.floor(py + 25 + h + 6)
					end
					ui.drawOutline(bx - 8, by - 3, 55, 25, true)
					lg.print(name, bx, by)
				end
				
				lg.setLineWidth(1)
				
				if ui.input_cursor_visible and this_selected then
					local lxx, lyy = px + (pw / 2) + pxo + font:getWidth(name) + 3, py + 25 + h + 2
					lg.line(lxx, lyy, lxx, lyy + 14)
				end
			
			end
			
			h = h + 28
		
		end
	
	end
	
	-- Draw context menu
	if ui.context_menu[1] ~= nil then
	
		lg.setColor(col_box)
		lg.rectangle("fill", ui.context_x, ui.context_y, ui.context_w, ui.context_h)
		
		ui.drawOutline(ui.context_x + 1, ui.context_y + 1, ui.context_w - 2, ui.context_h - 2, false)
		
		-- Draw highlight
		local i
		local h = 0
		for i = 1, #ui.context_menu do
		
			-- Set colors for the menu text and background color when highlighted
			local tc, bc
			
			if ui.context_menu[i].active then
				tc = c_black
				bc = c_highlight_active
			else
				tc = c_gray
				bc = col_inactive
			end
			
			-- If entry in the menu
			if ui.context_menu[i]._break == nil then
				
				local low = ui.context_y + h + 8
				local upp = low + 20
				
				if mx >= ui.context_x and mx <= ui.context_x + ui.context_w then
					lg.setColor(bc)
					if my >= low and my <= upp then
						lg.rectangle("fill", ui.context_x + 4, ui.context_y + h + 8, ui.context_w - 8, 20)
					end
				end
				
				lg.setColor(tc)
				lg.print(ui.context_menu[i].name, ui.context_x + 12, ui.context_y + h + 9)
				lg.printf(ui.context_menu[i].key_combo, ui.context_x, ui.context_y + h + 9, ui.context_w - 12, "right")
				
				h = h + 22
			else -- If entry is a break
				lg.setColor(col_line_dark)
				lg.rectangle("fill", ui.context_x + 4, ui.context_y + h + 14, ui.context_w - 8, 1)
				lg.setColor(col_line_light)
				lg.rectangle("fill", ui.context_x + 4, ui.context_y + h + 15, ui.context_w - 8, 1)
			
				h = h + 11
			end
		
		end
	
	end
	
	-- Draw global message
	if global_message_timer > 0 then
	
		local gmo = 1
		if global_message_timer <= 60 then
			gmo = (global_message_timer / 60)
		end
	
		local gmx, gmy = 64+16, screen_height - ((font_big:getWidth(global_message)/(screen_width-64-208-32)) * 48) - 24
		gmy = math.floor(gmy)
		lg.setFont(font_big)
		lg.setColor({0,0,0,gmo})
		lg.printf(global_message, gmx + 2, gmy + 2, screen_width-64-208-32, "center")
		lg.setColor({1,1,1,gmo})
		lg.printf(global_message, gmx, gmy, screen_width-64-208-32, "center")
		lg.setFont(font)
		lg.setColor(c_white)
	
	end
	
	-- Draw tooltip
	if ui.tooltip_timer >= 51 and not splash_active then
		local tx, ty = ui.tooltip_x + 12, ui.tooltip_y + 18
		local tool_width = font:getWidth(ui.tooltip_text) + 12
		
		if tx + tool_width >= screen_width then
			tx = screen_width - tool_width - 8
		end
		
		lg.setColor(c_white)
		lg.rectangle("fill", tx, ty, tool_width, 21)
		lg.setColor(c_black)
		lg.setLineWidth(1)
		lg.rectangle("line", tx, ty, tool_width, 21)
		lg.print(ui.tooltip_text, tx + 5, ty + 1)
		lg.setColor(c_white)
	end
	
end

return ui