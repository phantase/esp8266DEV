-- ****************************************************************************
-- Temperature & Humidity display for OLED screen on EPS8266 (nodemcu)
-- Written by: Phantase (https://github.com/phantase)
--
-- Call it with a dofile('u8g_graphics_test.lua') to test it.
--
-- MIT license, http://opensource.org/licenses/MIT
-- ****************************************************************************

-- Connect to the screen using i2c (spi doesn't work)
function init_i2c_display()
     local sda = 5 -- GPIO14
     local scl = 6 -- GPIO12
     local sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
end

-- Draw the thermometer
function draw_temp()
    -- Draw the thermometer filled
    disp:setColorIndex(1)
    disp:drawDisc(10,6,4)
    disp:drawBox(6,6,9,46)
    disp:drawDisc(10,56,6)
    -- Remove the contents
    disp:setColorIndex(0)
    disp:drawDisc(10,6,3)
    disp:drawBox(7,6,7,46)
    disp:drawDisc(10,56,5)
    -- Draw the graduation
    disp:setColorIndex(1)
    disp:drawHLine(17,10,4)
    disp:drawHLine(17,20,4)
    disp:drawHLine(17,30,4)
    disp:drawHLine(17,40,6)
    disp:drawHLine(17,50,4)
    -- Draw the contents 
    disp:drawDisc(10,56,2)
    -- Draw the temperature dependant part
    y = 40 - temp
    h = 15 + temp
    disp:drawVLine(10,y,h)
    -- Write the temperature
    disp:setFont(u8g.font_6x10)
    disp:setScale2x2()
    disp:drawStr(15, 12, 
    string.format(
      "%d.%d°C",
      math.floor(temp),
      temp_decimial/100
    ))
    disp:undoScale()
end

-- Draw the droplet
function draw_humi()

    -- Draw the content of the droplet
    disp:setColorIndex(1)
    disp:drawDisc(114,51,10,u8g.DRAW_LOWER_LEFT+u8g.DRAW_LOWER_RIGHT)
    disp:drawTriangle(103,51,114,18,125,51)

    -- Remove the humidity dependant part
    if humi < 100 then
        h = 46 - ( math.pow(humi,2) * 46 / math.pow(100,2) )
        disp:setColorIndex(0)
        disp:drawBox(103,16,22,h)
    end

    -- Draw the droplet edge
    disp:setColorIndex(1)
    disp:drawCircle(114,51,12,u8g.DRAW_LOWER_LEFT+u8g.DRAW_LOWER_RIGHT)
    disp:drawLine(101,51,114,16)
    disp:drawLine(114,16,127,51)

    -- the following part was for the mini droplet growing inside the edge of the big one
    -- Fill with something dependant of humidity
    --r = humi / 10
    --disp:drawDisc(114,51,r,u8g.DRAW_LOWER_LEFT+u8g.DRAW_LOWER_RIGHT)
    --disp:drawTriangle(114-r,51,114,51-r*3,114+r,51)

    -- Write the humidity
    disp:setFont(u8g.font_6x10)
    disp:setScale2x2()
    disp:drawStr(25, 32, humi.."%")
    disp:undoScale()
end

-- Draw (write) the hour
function draw_hour()
    -- Write the hour
    disp:setFont(u8g.font_6x10)
    disp:drawStr(40, 42, hour)
end

-- Draw everything (just one function call instead of 3, it's more readable)
function draw()
    draw_temp()
    draw_humi()
    draw_hour()
end

-- Start the test
function graphics_test()
    print("--- Starting Graphics Test ---")

-- Do a loop to view the animation
for cpt = 0, 50, 1 do
    
    temp = cpt-10
    temp_decimial = 900
    humi = cpt * 2

    hour = "08:"..cpt..":43"

    disp:firstPage()
    repeat
        draw()
    until disp:nextPage() == false
    
    tmr.delay(1000)

    tmr.wdclr()

end

    print("--- Graphics Test done ---")
end

-- initialize the display and launch the test
init_i2c_display()
graphics_test()