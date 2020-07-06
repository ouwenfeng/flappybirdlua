require "config"
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- 初始化游戏参数
    local pipes = {}
    local gameStatus = GAME_INIT
    local downSpeed = 0
    local upSpeed = 0
    local score = 0
    local visiblieSize = cc.Director:getInstance():getVisibleSize()
    -- print(CC_DESIGN_RESOLUTION.width)
    -- print(CC_DESIGN_RESOLUTION.height)
    -- print(display.cx)
    -- print(display.cy)
    -- print(visiblieSize.width)
    -- print(visiblieSize.height)
    -- print(display.sizeInPixels.width)
    -- print(display.sizeInPixels.height)
    -- 背景
    local bgSprite = display.newSprite("bg_day.png"):move(display.center):addTo(self)
    bgSprite:setContentSize(cc.rect(0, 0, visiblieSize.width, visiblieSize.height))
    -- 地板
    local land1 = display.newSprite("land.png"):move(display.cx, 0):setName("land1"):addTo(self)
    local land2 = display.newSprite("land.png"):move(display.cx, 0):setName("land2"):addTo(self)
    land1:setContentSize(cc.rect(0, 0, visiblieSize.width, land1:getContentSize().height))
    land2:setContentSize(cc.rect(0, 0, visiblieSize.width, land2:getContentSize().height))

    -- 标题
    local title = display.newSprite("title.png"):move(display.cx, display.cy + 100):setName("title"):addTo(self)

    -- 小鸟
    local birdSprite = display.newSprite("bird1.png"):move(display.center):setName("birdSprite"):addTo(self, 10):hide()

    -- 小鸟飞帧动画
    local animFrames = {}
    table.insert(animFrames, cc.SpriteFrame:create("bird1.png", cc.rect(0, 0, 38, 27)))
    table.insert(animFrames, cc.SpriteFrame:create("bird2.png", cc.rect(0, 0, 38, 27)))
    table.insert(animFrames, cc.SpriteFrame:create("bird3.png", cc.rect(0, 0, 38, 27)))
    local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.1)
    local animate = cc.Animate:create(animation)
    local swingAnimate = cc.RepeatForever:create(animate):setTag(1)
    birdSprite:runAction(swingAnimate)

    -- 分数面板
    local scoreSprite =
        display.newSprite("score.png"):move(display.center):setName("scoreSprite"):hide():addTo(self, 10)
    local textGameOver =
        display.newSprite("text_game_over.png"):move(display.cx, display.cy + 100):setName("textGameOver"):hide():addTo(
        self,
        10
    )
    local scoreLabel =
        cc.Label:createWithSystemFont("0", "黑体", 20):move(display.cx, display.cy + 10):setName("scoreLabel"):hide():addTo(
        self,
        10
    )
    local maxScoreLabel =
        cc.Label:createWithSystemFont("0", "黑体", 20):move(display.cx, display.cy - 30):setName("maxScoreLabel"):hide():addTo(
        self,
        10
    )
    local nowScoreLabel =
        cc.Label:createWithSystemFont("0", "黑体", 50):move(display.cx, display.cy + 150):setName("nowScoreLabel"):hide():addTo(
        self,
        9
    )
    -- 奖牌
    local medal =
        display.newSprite("medals.png"):setName("newMedal"):move(
        PIPE_START_WIDTH + 90,
        display.cy + math.random(-120, 120)
    ):addTo(self, 8)

    -- 开始按钮
    local beginSprite =
        display.newSprite("button_play.png"):move(display.cx, display.cy):setName("beginSprite"):addTo(self, 9)

    -- 游戏开始
    local function gameStart()
        print("gameStart")
        medal:show()
        nowScoreLabel:show()
        beginSprite:hide()
        cc.Director:getInstance():getEventDispatcher():pauseEventListenersForTarget(beginSprite)
        gameStatus = GAME_START
        pipes = {}
        for i = 0, 1, 1 do
            local r = math.random(PIPE_VARIATION_RANGE)
            local pipeUp =
                display.newSprite("pipe_up.png"):move(
                PIPE_START_WIDTH + i * PIPE_BETWEEN_WIDTH,
                visiblieSize.height - PIPE_SPACE + r
            ):setName("newPipe"):addTo(self)
            local pipeDown =
                display.newSprite("pipe_down.png"):move(PIPE_START_WIDTH + i * PIPE_BETWEEN_WIDTH, r):setName("newPipe"):addTo(
                self
            )

            table.insert(pipes, pipeUp)
            table.insert(pipes, pipeDown)
        end
    end

    -- 游戏重新开始
    local function gameRestart()
        local animFrames = {}
        table.insert(animFrames, cc.SpriteFrame:create("bird1.png", cc.rect(0, 0, 38, 27)))
        table.insert(animFrames, cc.SpriteFrame:create("bird2.png", cc.rect(0, 0, 38, 27)))
        table.insert(animFrames, cc.SpriteFrame:create("bird3.png", cc.rect(0, 0, 38, 27)))
        local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.1)
        local animate = cc.Animate:create(animation)
        local swingAnimate = cc.RepeatForever:create(animate):setTag(1)
        birdSprite:runAction(swingAnimate)
        birdSprite:move(display.center)
        beginSprite:hide()
        for k, v in pairs(pipes) do
            self:removeChild(v)
        end
        scoreLabel:hide()
        maxScoreLabel:hide()
        scoreSprite:hide()
        textGameOver:hide()
        score = 0
        nowScoreLabel:setString(score)
        medal:move(PIPE_START_WIDTH + 90, display.cy + math.random(-120, 120)):setName("newMedal")
        gameStart()
    end

    -- 游戏结束
    local function gameOver()
        print("gameOver")
        gameStatus = GAME_OVER
        birdSprite:stopAction(birdSprite:getActionByTag(1))
        beginSprite:show():move(display.cx, display.cy - 100)
        cc.Director:getInstance():getEventDispatcher():resumeEventListenersForTarget(beginSprite)
        scoreLabel:show()
        maxScoreLabel:show()
        scoreSprite:show()
        textGameOver:show()
        nowScoreLabel:hide()
        scoreLabel:setString(tostring(score))
        if cc.UserDefault:getInstance():getIntegerForKey("maxScore") < score then
            maxScoreLabel:setString(tostring(score))
            cc.UserDefault:getInstance():setIntegerForKey("maxScore", score)
        else
            maxScoreLabel:setString(cc.UserDefault:getInstance():getIntegerForKey("maxScore"))
        end
    end

    -- 点击开始按钮事件
    local function onTouchBeganButton(touch, event)
        local target = event:getCurrentTarget()
        local size = target:getContentSize()
        local rect = cc.rect(0, 0, size.width, size.height)
        local locationInNode = target:convertTouchToNodeSpace(touch)
        -- 判断是否点中按钮
        if cc.rectContainsPoint(rect, locationInNode) then
            print("onTouchBeganButton")
            if gameStatus == GAME_INIT then
                self:removeChildByName("title")
                birdSprite:show()
                gameStart()
            end
            if gameStatus == GAME_OVER then
                gameRestart()
            end
            return true
        end
        return false
    end

    -- 点击场景事件
    local function onTouchScene(touch, event)
        print("onTouchScene")
        if gameStatus == GAME_START then
            -- 每次点击都初始化速度
            downSpeed = 0
            upSpeed = 10

            -- 小鸟抬头动画
            local rotateUp = cc.RotateTo:create(0.1, -40)
            local stop = cc.RotateTo:create(0.4, -40)
            local rotateDown = cc.RotateTo:create(0.1, 40.)
            local touchActionSeq = cc.Sequence:create(rotateUp, stop, rotateDown)
            birdSprite:runAction(touchActionSeq)

            -- 向上加速度的定时器
            local scheduler = cc.Director:getInstance():getScheduler()
            local schedulerID = nil
            schedulerID =
                scheduler:scheduleScriptFunc(
                function()
                    upSpeed = upSpeed - 1
                    if upSpeed <= 0 then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
                    end
                    birdSprite:setPositionY(birdSprite:getPositionY() + upSpeed)
                end,
                0,
                false
            )
        end
    end

    -- 绑定事件到按钮
    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:registerScriptHandler(onTouchBeganButton, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, beginSprite)

    -- 绑定事件到场景
    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:registerScriptHandler(onTouchScene, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, self)

    --  更新定时器
    local function update()
        if gameStatus == GAME_START then
            -- 奖牌的生成与移动
            medal:setPositionX(medal:getPositionX() - 1)
            if medal:getPositionX() <= -PIPE_WIDTH / 2 then
                medal:show()
                medal:setName("newMedal")
                medal:setPosition(visiblieSize.width + PIPE_WIDTH / 2, display.cy + math.random(-120, 120))
            end
            if
                cc.rectIntersectsRect(birdSprite:getBoundingBox(), medal:getBoundingBox()) and
                    medal:getName() == "newMedal"
             then
                medal:setName("passed")
                medal:hide()
                score = score + 5
                nowScoreLabel:setString(tostring(score))
            end

            -- 小鸟的重力
            downSpeed = downSpeed + 1
            birdSprite:setPositionY(birdSprite:getPositionY() - downSpeed / 10)
            -- 地板的移动
            land1:setPositionX(land1:getPositionX() - 1)
            land2:setPositionX(land1:getPositionX() + land1:getContentSize().width - 2)
            if land2:getPositionX() <= land2:getContentSize().width / 2 then
                land1:setPosition(0, 0)
            end

            local r = 100
            for k, v in pairs(pipes) do
                v:setPositionX(v:getPositionX() - 1)
                -- 得分判断
                if v:getName() == "newPipe" then
                    if birdSprite:getPositionX() > v:getPositionX() then
                        score = score + 1
                        nowScoreLabel:setString(tostring(score))
                        v:setName("passed")
                    end
                end
                -- 管道的移动
                if v:getPositionX() < -PIPE_WIDTH / 2 then
                    v:setPositionX(visiblieSize.width + PIPE_WIDTH / 2)
                    v:setName("newPipe")
                    if k % 2 == 1 then
                        r = math.random(PIPE_VARIATION_RANGE)
                        v:setPositionY(visiblieSize.height - PIPE_SPACE + r)
                    else
                        v:setPositionY(r)
                    end
                end
            end

            -- 碰撞检测
            -- 地板
            if
                cc.rectIntersectsRect(birdSprite:getBoundingBox(), land1:getBoundingBox()) or
                    cc.rectIntersectsRect(birdSprite:getBoundingBox(), land2:getBoundingBox())
             then
                print("boundingBox")
                gameOver()
            end
            -- 管道
            for k, v in pairs(pipes) do
                if cc.rectIntersectsRect(birdSprite:getBoundingBox(), v:getBoundingBox()) then
                    print("boundingBox")
                    gameOver()
                end
            end
            -- 天
            if birdSprite:getPositionY() > visiblieSize.height then
                gameOver()
            end
        end
        -- 游戏结束后掉落到地板
        if gameStatus == GAME_OVER then
            if
                not (cc.rectIntersectsRect(birdSprite:getBoundingBox(), land1:getBoundingBox()) or
                    cc.rectIntersectsRect(birdSprite:getBoundingBox(), land2:getBoundingBox()))
             then
                downSpeed = downSpeed + 1
                birdSprite:setPositionY(birdSprite:getPositionY() - downSpeed)
            end
        end
    end
    self:onUpdate(update) -- 启动定时器
end

return MainScene
