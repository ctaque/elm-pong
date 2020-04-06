module Functions exposing (..)

import Complex exposing (exp, fromReal, real)
import Constants exposing (barHeight, barMoveIncrement, barYOffset, circleRadius, pxByMove)
import Types exposing (Coordinates, Direction(..), Flags, Model, Msg, SetYPositionReturnType, WindowSize)


getBarMoveIncrement : Int -> Int
getBarMoveIncrement level =
    barMoveIncrement + level


getBarWidth : WindowSize -> Int
getBarWidth windowSize =
    Basics.floor (Basics.min (Basics.toFloat windowSize.width / 2) 300)


getInitialBarXOffset : WindowSize -> Int
getInitialBarXOffset windowSize =
    Basics.floor ((toFloat windowSize.width / 2) - (Basics.toFloat (getBarWidth windowSize) / 2))


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        windowSize =
            { width = flags.windowWidth
            , height = flags.windowHeight
            }
    in
    ( { coordinates = ( Basics.floor (toFloat flags.windowWidth / 2), Basics.floor (toFloat flags.windowHeight / 2) )
      , xDirection = 1
      , yDirection = -1
      , barXOffset = getInitialBarXOffset windowSize
      , gameLost = False
      , gameStarted = False
      , level = 1
      , barWidth = getBarWidth windowSize
      , direction = None
      , windowSize = windowSize
      }
    , Cmd.none
    )



-- get the step to move by level
-- it's the exponential of the level divided by a number


getStep : Int -> Int
getStep level =
    pxByMove + Basics.floor (real (exp (fromReal (Basics.toFloat level / 10))))


getXPosition : Int -> WindowSize -> Int -> Int -> ( Int, Int )
getXPosition x windowSize direction level =
    let
        step =
            getStep level
    in
    if x < circleRadius then
        ( x + step, 1 )

    else if x >= windowSize.width - circleRadius then
        ( x - step, -1 )

    else if direction == 1 then
        ( x + step, 1 )

    else
        ( x - step, -1 )


getYPosition : Coordinates -> Int -> Int -> WindowSize -> Int -> Int -> SetYPositionReturnType
getYPosition coordinates barXOffset barWidth windowSize direction level =
    let
        step =
            getStep level
    in
    if Tuple.second coordinates <= circleRadius then
        { y = Tuple.second coordinates + step, direction = 1, gameLost = False }

    else if Tuple.second coordinates >= windowSize.height - circleRadius then
        { y = Tuple.second coordinates - step, direction = -1, gameLost = True }

    else if direction == 1 && Tuple.second coordinates >= (windowSize.height - barHeight - barYOffset - circleRadius) then
        if Tuple.first coordinates >= barXOffset && Tuple.first coordinates <= barXOffset + barWidth then
            { y = Tuple.second coordinates - step, direction = -1, gameLost = False }

        else
            { y = Tuple.second coordinates + step, direction = 1, gameLost = False }

    else if direction == 1 then
        { y = Tuple.second coordinates + step, direction = 1, gameLost = False }

    else
        { y = Tuple.second coordinates - step, direction = -1, gameLost = False }


barOffsetFromLeft : Int -> Int
barOffsetFromLeft currentPosition =
    Basics.max currentPosition 0


barOffsetFromRight : Int -> WindowSize -> Int -> Int
barOffsetFromRight nextPosition windowSize barWidth =
    Basics.min nextPosition (windowSize.width - barWidth)
