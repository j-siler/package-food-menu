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
    font:write(0, 0, "Testing", font_size*1.2, 255, 255, 0, 1.0)
    background.draw(0, 0, WIDTH, HEIGHT, .8)
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
