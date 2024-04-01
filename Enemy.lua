---@diagnostic disable: lowercase-global
-- 创建enemy对象
love = require("love")

function Enemy(level)
    -- 设置敌人生成的随机数，不在表格中，不会被返回
    local dice = math.random(1,4) -- 分别从上左下右生成敌人
    local _x, _y
    local _radius = 20

    if dice == 1 then
        _x = math.random(_radius, love.graphics.getWidth())
        _y = - _radius * 4
    elseif dice == 2 then
        _x = - _radius * 4
        _y = math.random(_radius, love.graphics.getHeight())
    elseif dice == 3 then
        _x = math.random(_radius, love.graphics.getWidth())
        _y = love.graphics.getHeight() + _radius * 4
    else
        _x = love.graphics.getWidth() + _radius * 4
        _y = math.random(_radius, love.graphics.getHeight())
    end

    -- 返回一个table
    return {
        level = level or 1,
        radius = _radius,
        -- 初始化位置，希望不可见，所以设为负值
        x = _x,
        y = _y,

        image = {
            direction = "right",
            src = love.graphics.newImage("icon/laidianwang.jpg"),
            -- 150*150
            center_x = 150 / 2,
            center_y = 150 / 2
        },

        -- 碰撞检测函数
        checkTouched = function (self, player_x,player_y,cursor_radius)
            return math.sqrt((self.x - player_x) ^ 2 + (self.y - player_y) ^ 2) <= self.radius + cursor_radius   
            
        end,

        --设置移动的函数
        move = function (self, player_x,player_y)
            if self.x - player_x < 0 then
                self.image.direction = "right"
                self.x = self.x + self.level
            elseif self.x - player_x > 0 then
                self.image.direction = "left"
                self.x = self.x - self.level
            end

            if self.y - player_y < 0 then
                self.y = self.y + self.level
            elseif self.y - player_y > 0 then
                self.y = self.y - self.level
            end
        end,

        -- 绘制敌人
        draw = function (self)
            love.graphics.setColor(1,1,1);
            if self.image.direction == "right" then
                love.graphics.draw(self.image.src,self.x,self.y, 0, 0.4, 0.4,self.image.center_x,self.image.center_y)
            else
                love.graphics.draw(self.image.src,self.x,self.y, 0, -0.4, 0.4,self.image.center_x,self.image.center_y)                
            -- love.graphics.circle("fill", self.x, self.y, self.radius)
            end
            love.graphics.setColor(0,0,0);
        end
    }
end

return Enemy