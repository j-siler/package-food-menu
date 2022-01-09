gl.setup(1920, 1080)

local menu, font, font_size, color
local dots = resource.load_image "dots.png"
local separator = resource.load_image "rainbowchalkline.png"
local range_x1, range_x2

local function Resource()
   local res, nxt
   local function set(asset)
      nxt = resource.load_image(asset.asset_name)
   end
   local function draw(...)
      if nxt and nxt:state() == "loaded" then
	 if res then res:dispose() end
	 res, nxt = nxt, nil
      end
      if res then
	 return res:draw(...)
      end
   end
   return {
      set = set;
      draw = draw;
   }
end

local background = Resource()

util.json_watch("config.json", function(config)
		   background.set(config.background)
		   color = config.text_color
		   font = resource.load_font(config.font.asset_name)
		   font_size = config.font_size
		   items = config.items
		   range_x1 = config.text_range[1]
		   range_x2 = config.text_range[2]
end)

function node.render()
   -- io.output("/tmp/package.out")
   io.write("Testing")
   background.draw(0, 0, WIDTH, HEIGHT, 1.0)
   local statusformat  = "HDMI-0: x1=%d x2=%d y1=%d y2=%d"
   local statusline = string.format(
      sys.displays[1].x1,
      sys.displays[1].x2,
      sys.displays[1].y1,
      sys.displays[1].y2)
   font:write(0, 0, statusline, font_size*1.0, 0, 255, 255, 1.0)

   if sys.displays[2] ~= nil then
      statusformat  = "HDMI-1: x1=%d x2=%d y1=%d y2=%d"
      statusline = string.format(statusformat,
				 sys.displays[2].x1,
				 sys.displays[2].x2,
				 sys.displays[2].y1,
				 sys.displays[2].y2)
--   font:write(0, 20, statusline, font_size*1.0, 0, 255, 255, 1.0)
      -- if sys.displays[1].x1 == sys.displays[2].x1
      -- 	 and
      -- 	 sys.displays[1].x2 == sys.displays[2].x2
      -- 	 and
      -- 	 sys.displays[1].y1 == sys.displays[2].y1
      -- 	 and
      -- 	 sys.displays[1].y2 == sys.displays[2].y2
      -- then
      -- 	 statusline = statusline .. "  Mirrored."
      -- -- elseif sys.displays[1].x1==0 and sys.displays[2].x1==0 and sys.displays[1].y2 == sys.displays[2].y1 then
      -- -- 	 statusline = statusline .. "  Stacked (T->B)"
      -- -- elseif sys.displays[1].y1==0 and sys.displays[2].y1==0 and sys.displays[1].x2 == sys.displays[2].x1 then
      -- -- 	 statusline = statusline .. "  SideBySide (L->R)"
      -- end
   end

   local y = 50
   for idx, item in ipairs(items) do
      if item.text == "" then
	 local len = range_x2-range_x1
	 local center = len/2
	 local lpos = center-(len/4)
	 local rpos = center+(len/4)
	 y = y + font_size*0.5
	 separator:draw(lpos, y, rpos,  y+10, .5)
	 y = y + font_size*0.5
      elseif item.price == "" then
	 font:write(range_x1, y, item.text, font_size*1.2, color.r, color.g, color.b)
	 y = y + font_size*1.3
      else
	 local w = font:width(item.text, font_size)
	 font:write(range_x1, y, item.text, font_size, color.r, color.g, color.b, 0.8)
	 local x_start = range_x1+w+10

	 local w = font:width(item.price, font_size)
	 font:write(range_x2-w, y, item.price, font_size, color.r, color.g, color.b, 0.8)

	 local x_end = range_x2-w-10

	 local w = x_end - x_start
	 w = w - (w % 20)
	 dots:draw(x_start, y+font_size-25, x_end, y+font_size-10, 0.8, 0, 0, 1/1920*w, 1)
	 y = y + font_size*1.05
      end
   end
end
