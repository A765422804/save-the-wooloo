---@diagnostic disable: lowercase-global
love = require("love")

-- 文本，函数，函数参数，宽度，高度
function Button(text, func, func_param, width, height)
    return {
        width = width or 100,
        height = height or 100,
        func = func or function () print("Nothing") end,
        func_param = func_param or nil,
        text = text or "No Text",
        button_x = 0, -- button的坐标
        button_y = 0,
        text_x = 0, -- 文本的相对坐标
        text_y = 0,

        -- 判断点击，如果在按钮内点击，则执行按钮对应函数
        checkPressed = function (self, mouse_x, mouse_y,cursor_radius)
            if (mouse_x + cursor_radius >= self.button_x) and 
            (mouse_x - cursor_radius <= self.button_x + self.width) then
                if (mouse_y + cursor_radius >= self.button_y) and 
                (mouse_y - cursor_radius <= self.button_y + self.height) then
                    if self.func_param then
                        self.func(self.func_param)
                    else
                        self.func()
                    end
                end               
            end
        end,

        draw = function (self, button_x, button_y, text_x, text_y)
            self.button_x = button_x or self.button_x
            self.button_y = button_y or self.button_y

            -- 设置文本的相对坐标
            if text_x then
                self.text_x = self.button_x + text_x
            else
                self.text_x = self.button_x
            end

            if text_y then
                self.text_y = self.button_y + text_y
            else
                self.text_y = self.button_y
            end

            love.graphics.setColor(0.6,0.6,0.6)
            love.graphics.rectangle("fill",self.button_x,self.button_y,self.width, self.height)
            love.graphics.setColor(0,0,0)
            love.graphics.print(self.text, self.text_x, self.text_y)
        end
    }
end

return Button