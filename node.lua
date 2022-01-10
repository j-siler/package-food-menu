gl.setup(1920, 1080)

local menu, font, font_size, color
local dots = resource.load_image "dots.png"
local separator = resource.load_image "rainbowchalkline.png"
local range_x1, range_x2

local debugfont = resource.load_font("Lato-SemiboldItalic.ttf");

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
   d1 = sys.displays[1]
   d2 = sys.displays[2]
   background.draw(0, 0, WIDTH, HEIGHT, 1.0)

   -- Draw status line 1
   local statusformat  = "HDMI-0: x1=%d x2=%d y1=%d y2=%d"
   local statusline = string.format(
      statusformat,
      d1.x1,
      d1.x2,
      d1.y1,
      d1.y2)
   debugfont:write(75, 0, statusline, font_size*1.0, 0, 255, 255, 1.0)

   -- Draw status line 2, if dual display
   if d2 ~= nil then
      statusformat  = "HDMI-1: x1=%d x2=%d y1=%d y2=%d"
      statusline = string.format(
	 statusformat,
	 d2.x1,
	 d2.x2,
	 d2.y1,
	 d2.y2)
      font:write(75, 20, statusline, font_size*1.0, 0, 255, 255, 1.0)

      --   Mir    0 1920    0 1080
      --          0 1920    0 1080 
      --   L2R    0 1920    0 1080
      --          1920 3840    0 1080
      --   T2B    0 1920    0 1080
      --          0 1920 1080 2160
      --   R2L 1920 3840    0 1080
      --          0 1920    0 1080
      --   B2T    0 1920 1080 2160
      --          0 1920    0 1080
      -- Determine and display
      local mir = d1.x1==0 and d1.x2>d1.x1 and d2.x1==0     and d2.x2==d1.x2    and d1.y1==0     and d1.y2>d1.y1 and d2.y1==0     and d2.y2==d1.y2
      local l2r = d1.x1==0 and d1.x2>d1.x1 and d2.x1==d1.x2 and d2.x2==d2.x1*2  and d1.y1==0     and d1.y2>d1.y1 and d2.y1==0     and d2.y2==d1.y2
      local t2b = d1.x1==0 and d1.x2>d1.x1 and d2.x1==0     and d2.x2==d1.x2    and d1.y1==0     and d1.y2>d1.y1 and d2.y1==d1.y2 and d2.y2==d2.y1*2
      local r2l = d2.x1==0 and d2.x2>d2.x1 and d1.x1==d2.x2 and d1.x2==d1.x1*2  and d2.y1==0     and d2.y2>d2.y1 and d1.y1==0     and d1.y2==d2.y2
      local b2t = d2.x1==0 and d2.x2>d2.x1 and d1.x1==0     and d1.x2==d2.x2    and d2.y1==0     and d2.y2>d2.y1 and d1.y1==d2.y2 and d1.y2==d1.y1*2
      local right_left=4
      local bottom_top=5
      local other=6
      if mir then
	 font:write(0, 0, "[1/2]", font_size*1.0, 255, 255, 255, 1.0)
      elseif l2r then
	 font:write(0, 0, "[1][2]", font_size*1.0, 255, 255, 255, 1.0)
      elseif t2b then --d1.x1==0 and d1.x2>d1.x1  and d2.x1==0 and d2.x2==d1.x2 and d1.y1==0 and d1.y2>d1.y1 and d2.y1==d1.y2 and d2.y2>d2.y1 then
	 font:write(0, 0, "[1]", font_size*1.0, 255, 255, 255, 1.0)
	 font:write(0, 20, "[2]", font_size*1.0, 255, 255, 255, 1.0)
      elseif r2l then
	 font:write(0, 0, "[2][1]", font_size*1.0, 255, 255, 1.0)
      elseif b2t then --d1.x1==0 and d1.x2>d1.x1  and d2.x1==0 and d2.x2==d1.x2 and d1.y1==0 and d1.y2>d1.y1 and d2.y1==d1.y2 and d2.y2>d2.y1 then
	 font:write(0, 0, "[2]", font_size*1.0, 255, 255, 0, 1.0)
	 font:write(0, 20, "[1]", font_size*1.0, 255, 255, 0, 1.0)
      else
	 font:write(0, 0, "[?]   ", font_size*1.0, 255, 0, 0, 1.0)
	 font:write(0, 20, "   [?]", font_size*1.0, 255, 0, 0, 1.0)	 
      end
      
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
	 dots:draw(x_start, y+(font_size*.33333), x_end, y+(font_size*.66667), 0.8, 0, 0, 1/1920*w, 1)
	 y = y + font_size*1.05
      end
   end
end
