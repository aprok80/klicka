class MouseClickGame
    width: 600
    height: 500
    speed: 0.5
    targetList: null
    stateTime: 0
    score: 0
    gametimeleft: 0
    addNextLegendTargetTime: 1000
    legendSpeed: 1000
    shapes: []
    maxtargetsize: 40
    clickAnimations: []


    constructor: ( targetnum, speed = 0.1, hardmod = false, gametimeleft = 60000 ) ->
        @shapes = [@drawRhombus,@drawHourglass1,@drawStar1,@drawStar2,@drawCircle,@drawHourglass2,@drawRect,@drawTriangle1,@drawTriangle2,@drawTriangle3,@drawTriangle4,@drawTriangle5,@drawTriangle6,@drawTriangle7,@drawTriangle8] 
        @speed = speed
        @score = 0
        @hardmod = hardmod
        @clickAnimations = []
        @legendSpeed = 983
        @addNextLegendTargetTime = @legendSpeed
        @maxtargetsize = 40
        @gametimeleft = gametimeleft
        @canvas = $('canvas')
        @width = @canvas.width()
        @height = @canvas.height()
        @dc = @canvas[0].getContext '2d'
        @createTargets( targetnum )
        @legend = new Legend( @dc, @width, @height, @maxtargetsize, @targetList )
        @stateTime = Date.now()

    createTargets: (targetnum) ->
        @targetList = []
        for i in [0...targetnum]
            @targetList[i] = @createTarget(i % @shapes.length) #Math.floor(Math.random()*@shapes.length))

    createClickAnimation: (x,y, time) ->
        posx: x
        posy: y
        time2life: time
        size: 0

    createTarget: (shapenum) ->
        posx: Math.random() * (@width - 10)
        posy: Math.random() * (@height - 10)
        shapefunc: @shapes[shapenum]
        addx: 0
        addy: 0
        timeleft: 0
        sizex: @maxtargetsize * 0.5 + Math.random() * @maxtargetsize * 0.5;
        sizey: @maxtargetsize * 0.5 + Math.random() * @maxtargetsize * 0.5;
        color: "rgb(#{Math.floor(127+128*Math.random())},#{Math.floor(127+128*Math.random())},#{Math.floor(127+128*Math.random())})"

    
    drawTarget: (target) ->
        @dc.fillStyle = 'rgba(128,128,128,0.3)'
        @dc.fillRect( target.posx, target.posy, target.sizex, target.sizey );
        @dc.fillStyle = target.color
        target.shapefunc(@dc, target)

    moveTarget: (target, time) ->
        if target.timeleft <= 0 
            target.addx = (Math.random() - 0.5)*@speed
            target.addy = (Math.random() - 0.5)*@speed
            target.timeleft = Math.floor( Math.random() * 10000 + 1000 )
        target.posx += target.addx * time 
        target.posy += target.addy * time 
        target.timeleft -= time;
        @reflectOnEdge( target )

    reflectOnEdge: (target) ->
        target.addx = -target.addx if target.posx < 0 and target.addx < 0
        target.addy = -target.addy if target.posy < 0 and target.addy < 0
        target.addx = -target.addx if target.posx >= (@width-target.sizex) and target.addx > 0
        target.addy = -target.addy if target.posy >= (@height-target.sizey) and target.addy > 0

    click: (x,y) ->
        if @gametimeleft > 0
            hit = false
            ani = @createClickAnimation( x, y, 200 )
            @clickAnimations.push ani
            next = @legend.getNextTarget()
            if next?
                if @isHit( x,y,@targetList[next] )
                    @score++ 
                    @legend.removeTarget()
                    sound.hit()
                    hit = true
            if not hit
                sound.click()
                if @hardmod
                    @score-- if @score > 0

    isHit: (x,y,t) ->
        x >= t.posx and x <= t.posx+t.sizex and y >= t.posy and y <= t.posy+t.sizey 

    tick: ->
        if @gametimeleft > 0
            now = Date.now()
            timePassed = now - @stateTime
            @dc.clearRect( 0, 0, @width, @height )
            @dc.font = "bold 12px sans-serif"
            @dc.fillStyle = 'rgb(255,255,255)'
            @drawScore()
            @drawGameTime()
            @dc.globalAlpha = 0.5
            for target in @targetList
                @moveTarget target, timePassed
                @drawTarget target
            if( @addNextLegendTargetTime <= 0 )
                @addNextLegendTargetTime = @legendSpeed
                @legend.addRandomTarget()
            @legend.draw()
            @handleClickAnimations(timePassed)
            @addNextLegendTargetTime -= timePassed
            @gametimeleft -= timePassed
            @stateTime = now
        else
            @drawFinalScore()

    handleClickAnimations: (timePassed) ->
        while @clickAnimations.length > 0 and @clickAnimations[0].time2life <= 0 
            @clickAnimations.shift()
        if @clickAnimations.length > 0
            for ani in @clickAnimations 
                @dc.strokeStyle = "rgba(255,255,255,#{ani.time2life*0.005})"
                @dc.beginPath()
                ani.time2life -= timePassed
                ani.size += timePassed*0.1
                @dc.arc( ani.posx, ani.posy, ani.size, 0 , 2 * Math.PI, false)
                @dc.stroke()




    drawScore: ->
        @dc.textBaseline = "top"
        @dc.textAlign = "right"
        @dc.fillText( @score, @width - 10, 10 )

    drawFinalScore: ->
        @dc.font = "bold 30px sans-serif"
        @dc.fillStyle = 'rgb(255,255,255)'
        @dc.textBaseline = "middle"
        @dc.textAlign = "center"
        @dc.fillText( "Final Score: #{@score}", @width * 0.5, @height * 0.5 )

    drawGameTime: ->
        minuten = Math.floor( @gametimeleft * 0.001 )
        sekunden = minuten % 60;
        minuten -= sekunden
        minuten /= 60;
        @dc.textBaseline = "top"
        @dc.textAlign = "left"
        if sekunden < 10 
            insertnull = "0"
        else
            insertnull = ""
        @dc.fillText( "#{minuten}:#{insertnull}#{sekunden}", 10, 10 )

    drawTriangle1: (dc,t) ->
        drawPolygon dc, t.posx, t.posy, t.posx+t.sizex, t.posy, t.posx, t.posy+t.sizey 
    drawTriangle2: (dc,t) ->
        drawPolygon dc, t.posx, t.posy, t.posx+t.sizex, t.posy, t.posx+t.sizex, t.posy+t.sizey 
    drawTriangle3: (dc,t) ->
        drawPolygon dc, t.posx+t.sizex, t.posy, t.posx+t.sizex, t.posy+t.sizey, t.posx, t.posy+t.sizey 
    drawTriangle4: (dc,t) ->
        drawPolygon dc, t.posx, t.posy, t.posx+t.sizex, t.posy+t.sizey, t.posx, t.posy+t.sizey 
    drawTriangle5: (dc,t) ->
        drawPolygon dc, t.posx+t.sizex*0.5, t.posy, t.posx+t.sizex, t.posy+t.sizey, t.posx, t.posy+t.sizey 
    drawTriangle6: (dc,t) ->
        drawPolygon dc, t.posx, t.posy, t.posx+t.sizex, t.posy+t.sizey*0.5, t.posx, t.posy+t.sizey 
    drawTriangle7: (dc,t) ->
        drawPolygon dc, t.posx, t.posy, t.posx+t.sizex, t.posy, t.posx+t.sizex*0.5, t.posy+t.sizey 
    drawTriangle8: (dc,t) ->
        drawPolygon dc, t.posx, t.posy+t.sizey*0.5, t.posx+t.sizex, t.posy, t.posx+t.sizex, t.posy+t.sizey 
    drawHourglass1: (dc,t) ->
        drawPolygon dc, t.posx, t.posy, t.posx+t.sizex, t.posy, t.posx, t.posy+t.sizey, t.posx+t.sizex, t.posy+t.sizey
    drawHourglass2: (dc,t) ->
        drawPolygon dc, t.posx, t.posy, t.posx, t.posy+t.sizey, t.posx+t.sizex, t.posy, t.posx+t.sizex, t.posy+t.sizey
    drawRhombus: (dc,t) ->
        drawPolygon dc, t.posx+t.sizex*0.5, t.posy, t.posx+t.sizex, t.posy+t.sizey*0.5, t.posx+t.sizex*0.5, t.posy+t.sizey, t.posx, t.posy+t.sizey*0.5 
    drawStar1: (dc,t) ->
        px = t.posx
        py = t.posy
        sx = t.sizex
        sy = t.sizey
        sx2 = sx*0.5
        sy2 = sy*0.5
        ix = sx*0.2
        iy = sy*0.2
        drawPolygon dc, px, py, px+sx2, py+iy, px+sx, py, px+sx-ix, py+sy2, px+sx, py+sy, px+sx2, py+sy-iy, px, py+sy, px+ix, py+sy2
    drawStar2: (dc,t) ->
        px = t.posx
        py = t.posy
        sx = t.sizex
        sy = t.sizey
        sx2 = sx*0.5
        sy2 = sy*0.5
        ix = sx*0.35
        iy = sy*0.35
        drawPolygon dc, px+ix, py+iy, px+sx2, py, px+sx-ix, py+iy, px+sx, py+sy2, px+sx-ix, py+sy-iy, px+sx2, py+sy, px+ix, py+sy-iy, px, py+sy2
    drawCircle: (dc,t) ->
        px = t.posx
        py = t.posy
        sx = t.sizex
        sy = t.sizey
        sx2 = sx*0.5
        sy2 = sy*0.5
        ix = sx*0.15
        iy = sy*0.15
        drawPolygon dc, px+ix, py+iy, px+sx2, py, px+sx-ix, py+iy, px+sx, py+sy2, px+sx-ix, py+sy-iy, px+sx2, py+sy, px+ix, py+sy-iy, px, py+sy2
    drawRect: (dc, t ) ->
        dc.fillRect t.posx, t.posy, t.sizex, t.sizey


class Legend
    constructor: ( dc, width, height, maxtargetsize, targetList ) ->
        @targetList = targetList
        @legendList = []
        @dc = dc
        @maxlegenditems = 5
        @spacing = maxtargetsize*1.5
        @offsetx = maxtargetsize*0.25
        @offsety = maxtargetsize*0.25
        @maxtargetsize = maxtargetsize
        @sizex = @maxlegenditems * @spacing + @offsetx
        @sizey = maxtargetsize*1.5
        @posx = (width-@sizex)*0.5
        @posy = height - 2*maxtargetsize 

    addRandomTarget: ->
        if @legendList.length < @maxlegenditems
            sound.newTarget()
            @legendList.push( @createItem( random(@targetList.length) ) )

    createItem: ( targetNum ) ->
        num: targetNum
        posx: @posx+@sizex*2
        posy: @posy+@offsety

    removeTarget: ->
        @legendList.shift()

    getNextTarget: ->
        if @legendList[0]?
            return @legendList[0].num
        return null

    draw: ->
        @dc.fillStyle = 'rgba(255,255,255,0.1)'
        @dc.fillRect( @posx, @posy, @sizex, @sizey )
        pos = 0
        for item in @legendList
            target = @targetList[item.num]
            px = target.posx
            py = target.posy
            zielx = @posx + @offsetx + pos*@spacing + (@maxtargetsize - target.sizex)*0.5
            ziely = @posy + @offsety + (@maxtargetsize - target.sizey)*0.5
            dx = zielx - item.posx
            dy = ziely - item.posy
            dx *= 0.8
            dy *= 0.8
            item.posx = target.posx = zielx - dx
            item.posy = target.posy = ziely - dy
            game.drawTarget( target )
            target.posx = px
            target.posy = py
            pos++


window.drawPolygon  = (dc,x...) ->
    dc.beginPath()
    size = x.length >> 1
    for i in [0..size] 
        dc.lineTo( x[i << 1], x[(i<<1)+1] )
    dc.fill()

class Sound
    constructor: ->
        @mute = false

    click: ->
        @playSound('id-click-sound1');
        # console.log 'emptyclick'

    hit: ->
        @playSound('id-hit-sound1');
        # console.log 'hit'

    newTarget: ->
        @playSound('id-newtarget-sound1');
        # console.log 'new Target'

    playSound: (id) ->
        if @mute 
            return
        element = document.getElementById(id)
        if window.chrome 
            element.load()
        element.play()

$ ->
    $('#id-input-auto-size').click (event) ->
        $('#id-input-width').prop('disabled',this.checked)
        $('#id-input-height').prop('disabled',this.checked)

    $('#id-input-preset').click (event) ->
        custom = document.getElementById('id-input-preset').value == 'none'
        if custom
            $('#id-custom').show();
        else
            $('#id-custom').hide();

    window.myCanvas = $('canvas')[0]
    $('canvas').click (event) =>
        if window.game?
            rect = myCanvas.getBoundingClientRect();
            window.game.click( event.clientX - rect.left, event.clientY - rect.top )

    $('#id-button-create').click (event) =>
        if window.game?
            clearInterval window.gameId
            window.game = null
            $('#id-button-create').text('Start Game');
        else 
            canvas = $('canvas');
            width = 800
            height = 600
            preset = document.getElementById('id-input-preset').value
            if preset == 'Easy'
                speed = 0.1
                num = 3
            else if preset == 'Medium'
                speed = 0.2
                num = 5
            else if preset == 'Hard'
                speed = 0.3
                num = 7
            else if preset == 'Insane'
                speed = 0.4
                num = 10
            else
                if document.getElementById('id-input-auto-size').checked 
                    width = 0.98 * canvas.parent().width()
                    height = 0.9*$(window).height()
                else
                    width = checkValueInt(document.getElementById('id-input-width').value,200)
                    height = checkValueInt(document.getElementById('id-input-height').value,200)
                speed = checkValueFloat( document.getElementById('id-input-speed').value, 0 )
                num =  checkValueInt(document.getElementById('id-input-targetnum').value,1)
            

            canvas[0].width = width
            canvas[0].height = height

            hardmod = document.getElementById('id-input-hardmod').checked
            window.game = new MouseClickGame( num, speed, hardmod );
            window.gameId = setInterval ->
                window.game.tick()
            , 1
            $('#id-button-create').text('Stop Game');



window.sound = new Sound()

window.checkValueInt = (value, min) ->
    result = parseInt value
    result = min if isNaN(result) 
    result = min if result < min
    result
window.checkValueFloat = (value, min) ->
    result = parseFloat value
    result = min if isNaN(result) 
    result = min if result < min
    result

window.random = ( max ) ->
    Math.floor( Math.random() * max )