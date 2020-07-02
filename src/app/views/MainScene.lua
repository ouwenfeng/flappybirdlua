require "config"
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- 初始化游戏参数
    local pipes = {}
    local gameStatus = GAME_INIT
    local downSpeed = 0
    local upSpeed = 0
    local score = 0
    local medals = {}
    -- 背景
    display.newSprite("bg_day.png"):move(display.center):addTo(self)

    -- 地板
    local land1 = display.newSprite("land.png"):move(display.cx, 0):setName("land1"):addTo(self)
    local land2 = display.newSprite("land.png"):move(display.cx, 0):setName("land2"):addTo(self)

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
        cc.Label:createWithSystemFont("0", "黑体", 50):move(display.cx, display.cy + 200):setName("nowScoreLabel"):hide():addTo(
        self,
        10
    )
    -- 奖牌
    local medal1 =
        display.newSprite("medals.png"):setName("newMedal"):move(
        display.cx + math.random(200) + 350,
        display.cy + math.random(200) - 100
    ):hide():addTo(self, 8)
    local medal2 =
        display.newSprite("medals.png"):setName("newMedal"):move(
        display.cx + math.random(200) + 350,
        display.cy + math.random(200) - 100
    ):hide():addTo(self, 8)

    -- 开始按钮
    local beginSprite =
        display.newSprite("button_play.png"):move(display.cx, display.cy):setName("beginSprite"):addTo(self, 9)

    -- 游戏开始
    local function gameStart()
        print("gameStart")
        medal1:show()
        medal2:show()
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
                CC_DESIGN_RESOLUTION.height - PIPE_SPACE + r
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

        medal1:move(display.cx + math.random(200) + 350, display.cy + math.random(200) - 100)
        medal2:move(display.cx + math.random(200) + 350, display.cy + math.random(200) - 100)
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
            -- 奖牌的移动
            medal1:setPositionX(medal1:getPositionX() - 1)
            medal2:setPositionX(medal2:getPositionX() - 1)
            if medal1:getPositionX() <= -medal1:getContentSize().width / 2 then
                medal1:setPosition(
                    CC_DESIGN_RESOLUTION.width + medal1:getContentSize().width + math.random(100),
                    display.cy - 100 + math.random(200)
                )
            end
            if medal2:getPositionX() <= -medal2:getContentSize().width / 2 then
                medal2:setPosition(
                    CC_DESIGN_RESOLUTION.width + medal2:getContentSize().width + math.random(100),
                    display.cy - 100 + math.random(200)
                )
            end

            if cc.rectIntersectsRect(birdSprite:getBoundingBox(), medal1:getBoundingBox()) then
                print("get medal")
                score = score + 1
                nowScoreLabel:setString(tostring(score))
                medal1:setPosition(
                    CC_DESIGN_RESOLUTION.width + medal1:getContentSize().width + math.random(100),
                    display.cy - 100 + math.random(200)
                )
            end
            if cc.rectIntersectsRect(birdSprite:getBoundingBox(), medal2:getBoundingBox()) then
                print("get medal")
                score = score + 1
                nowScoreLabel:setString(tostring(score))
                medal2:setPosition(
                    CC_DESIGN_RESOLUTION.width + medal2:getContentSize().width + math.random(100),
                    display.cy - 100 + math.random(200)
                )
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
            -- 管道的移动
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
                if v:getPositionX() < -PIPE_WIDTH / 2 then
                    v:setPositionX(CC_DESIGN_RESOLUTION.width + PIPE_WIDTH / 2)
                    v:setName("newPipe")
                    if k % 2 == 1 then
                        r = math.random(PIPE_VARIATION_RANGE)
                        v:setPositionY(CC_DESIGN_RESOLUTION.height - PIPE_SPACE + r)
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
            if birdSprite:getPositionY() > CC_DESIGN_RESOLUTION.height then
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
    self:onUpdate(update)
end

return MainScene
