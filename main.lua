---@diagnostic disable: lowercase-global
love = require("love")
enemy = require("Enemy") -- 返回该模块的返回值，是一个函数
button = require("Button")

-- 定义游戏状态的修改
local function changeGameState(state)
    game.state["menu"] = (state == "menu")
    game.state["stop"] = (state == "stop")
    game.state["running"] = (state == "running")
    game.state["ended"] = (state == "ended")
    game.state["setting"] = (state == "setting")
    game.state["win"] = (state == "win")
end

-- 定义标志游戏开始的函数，并传给对应按钮
local function startNewGame()
    changeGameState("running")
    game.points = 0

    -- 创建第一个敌人
    enemies = {}
    table.insert(enemies,1,enemy(game.difficulty * 1))
end

-- 定义游戏的难度
local function changeDifficulty(diff)
    game.difficulty = diff
    changeGameState("menu")
end

function love.load()
    love.window.setTitle("Save the Wooloo")
    love.mouse.setVisible(false) -- 隐藏鼠标光标
    math.randomseed(os.time()) -- 设置随机数种子
    wintime = 120 -- 设置胜利时间
    love.graphics.setBackgroundColor(235/255, 253/255,201/255) -- 设置背景颜色

    --设置游戏系统对象
    game = {
        difficulty = 1, -- 游戏难度
        state = {
            menu = true,
            stop = false,
            running = false,
            ended = false,
            setting = false,
            win = false
        },
        points = 0,
        levels = {10,20,30,40,50,60,70,80,90,100},
        menu_image = {
            src = love.graphics.newImage("icon/mainpage.jpg")
        }
    }

    -- 设置按钮对象
    buttons = {
         menu_state = {
            play_game = button("Play Game", startNewGame, nil, 120,40),
            settings = button("Settings", changeGameState, "setting", 120,40),
            exit_game = button("Exit Game", love.event.quit, nil,120,40)
         },
        ended_state = {
            replay_game = button("Replay Game", startNewGame, nil, 200,50),
            to_menu = button("Back to Menu", changeGameState, "menu", 200,50),
            exit_game = button("Exit Game", love.event.quit, nil,200,50)            
        },
        settings_state = {
            diff1 = button("difficulty 1", changeDifficulty, 1, 120,40),
            diff2 = button("difficulty 2", changeDifficulty, 2, 120,40),
            diff3 = button("difficulty 3", changeDifficulty, 3, 120,40),
            diff4 = button("difficulty 4", changeDifficulty, 4, 120,40),
            diff5 = button("difficulty 5", changeDifficulty, 5, 120,40)
        },
    }

    -- 设置游戏字体
    fonts = {
        medium = {
            font = love.graphics.newFont(16),
            size = 16
        },
        large = {
            font = love.graphics.newFont(24),
            size = 24
        },
        massive = {
            font = love.graphics.newFont(60),
            size = 60
        }
    }

    -- 设置鼠标光标对象
    player = {
        radius = 30,
        x = 0,
        y = 0,
        image = {
            src = love.graphics.newImage("icon/wooloo_trans.png"),
            -- 535 * 300 
            center_x = 535 / 2,
            center_y = 300 / 2
        } 
    }

    -- 设置敌人对象，我们写在Enemy.lua中
    enemies = {}
end

function love.update(dt)
    -- 获取鼠标坐标
    player.x, player.y = love.mouse.getPosition()

    -- 设置敌人的移动
    if game.state["running"] then
        for i = 1, #enemies do
            if not enemies[i]:checkTouched(player.x,player.y,player.radius) then
                enemies[i]:move(player.x, player.y)

                for j = 1,#game.levels do
                    if math.floor(game.points) == game.levels[j] then
                        table.insert(enemies,1, enemy(game.difficulty * (j + 1)))
                        game.points = game.points + 1
                    end
                end
            else
                changeGameState("ended")
            end
        end
        
        -- 增加point
        game.points = game.points + dt

        -- 按P暂停
        if love.keyboard.isDown("p")then
            changeGameState("stop")
        end

        -- 获得胜利
        if math.floor(game.points) >= wintime then
            changeGameState("win")
        end
    elseif game.state["stop"] then
        if love.keyboard.isDown("c")then
            changeGameState("running")
        end
    end
end

-- 定义鼠标点击时候的回调函数，具体参数定义见官方文档
function love.mousepressed(x, y, button, istouch,presses)
    if not game.state["running"] then
        if button == 1 then
            if game.state["menu"] then
                for index in pairs(buttons.menu_state) do
                    buttons.menu_state[index]:checkPressed(x,y,player.radius)
                end
            elseif game.state["ended"] or game.state["win"] then
                for index in pairs(buttons.ended_state) do
                    buttons.ended_state[index]:checkPressed(x,y,player.radius)
                end
            elseif game.state["setting"] then
                for index in pairs(buttons.settings_state) do
                    buttons.settings_state[index]:checkPressed(x,y,player.radius)
                end
            end
        end
    end
end

function love.draw()
    --设置字体
    love.graphics.setFont(fonts.medium.font)
    -- 设置颜色
    love.graphics.setColor(0, 0, 0)

    -- 显示fps,具体参数含义详见官方文档
    love.graphics.printf(
        "FPS: " .. love.timer.getFPS(),
        fonts.medium.font,
        10,
        love.graphics.getHeight() - 30,
        love.graphics.getWidth()
    )

    -- 显示游戏当前难度
    love.graphics.printf(
        "difficulty: " .. game.difficulty,
        fonts.medium.font,
        love.graphics.getWidth() - 100,
        10,
        love.graphics.getWidth()
    )

    -- love.graphics.circle("fill", 0, 0, 40,40) 坐标是circle中心的坐标

    -- 绘制鼠标光标
    -- love.graphics.circle("fill", player.x, player.y, player.radius)

    if game.state["running"] or game.state["stop"] then
        -- 绘制分数
        love.graphics.printf(
            math.floor(game.points),
            fonts.massive.font,
            0,
            10,
            love.graphics.getWidth(),
            "center"
        )

        -- 绘制敌人
        for i = 1, #enemies do
            enemies[i]:draw()
        end

        -- 绘制鼠标光标
        love.graphics.setColor(1,1,1);
        love.graphics.draw(player.image.src,player.x,player.y,0, 0.3,0.3, player.image.center_x, player.image.center_y)
        love.graphics.setColor(0,0,0);
        -- love.graphics.circle("fill", player.x, player.y, player.radius)    
    elseif game.state["menu"] then
        buttons.menu_state.play_game:draw(20,20,15,10)
        buttons.menu_state.settings:draw(20,80,20,10)
        buttons.menu_state.exit_game:draw(20,140,15,10)

        -- 显示游戏标题
        love.graphics.printf(
            "Save the Wooloo!",
            fonts.massive.font,
            0,
            love.graphics.getHeight() / 3 ,
            love.graphics.getWidth(),
            "center"
        )  
        -- 显示游戏说明
        love.graphics.printf(
            "help the Wooloo save " .. wintime.. "s and keep away from Yamper!",
            fonts.large.font,
            0,
            love.graphics.getHeight() / 2 ,
            love.graphics.getWidth(),
            "center"
        )  

        -- 绘制毛辫羊
        love.graphics.setColor(1,1,1);
        love.graphics.draw(game.menu_image.src,love.graphics.getWidth() - 250 ,love.graphics.getHeight() - 250,0, 0.4,0.4)
        love.graphics.setColor(0,0,0);

    elseif game.state["ended"] or game.state["win"] then
        love.graphics.setFont(fonts.large.font)

        -- 调整比例让按钮显示在中间
        buttons.ended_state.replay_game:draw(love.graphics.getWidth()/2.6 ,love.graphics.getHeight() /1.8 ,15,10)
        buttons.ended_state.to_menu:draw(love.graphics.getWidth()/2.6,love.graphics.getHeight() /1.53,15,10)
        buttons.ended_state.exit_game:draw(love.graphics.getWidth()/2.6,love.graphics.getHeight() /1.33,15,10)

        -- 显示玩家得分
        love.graphics.printf(
            math.floor(game.points),
            fonts.massive.font,
            0,
            love.graphics.getHeight() / 2 - fonts.massive.size ,
            love.graphics.getWidth(),
            "center"
        )

        -- 显示失败信息
        if game.state["ended"] then
            love.graphics.printf(
                "You Lose!",
                fonts.massive.font,
                0,
                love.graphics.getHeight() / 4 ,
                love.graphics.getWidth(),
                "center"
            )     
        elseif game.state["win"] then       
            love.graphics.printf(
                "You Win!",
                fonts.massive.font,
                0,
                love.graphics.getHeight() / 4 ,
                love.graphics.getWidth(),
                "center"
            )     
        end

    elseif game.state["setting"] then
        buttons.settings_state.diff1:draw(20,20,15,10)
        buttons.settings_state.diff2:draw(20,80,15,10)
        buttons.settings_state.diff3:draw(20,140,15,10)
        buttons.settings_state.diff4:draw(20,200,15,10)
        buttons.settings_state.diff5:draw(20,260,15,10)
    end

    if not (game.state["running"] or game.state["stop"]) then
        -- 绘制鼠标光标
        love.graphics.circle("fill", player.x, player.y, player.radius / 2)        
    end
end