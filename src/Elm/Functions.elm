module Elm.Functions exposing (..)

import Complex exposing (exp, fromReal, real)
import Elm.Constants exposing (barHeight, barMoveIncrement, barMoveIncrementMobile, barYOffset, circleRadius, pxByMove)
import Elm.Types exposing (Coordinates, Direction(..), Flags, Model, Msg(..), Score, SetYPositionReturnType, WindowSize)
import Http
import Json.Decode exposing (Decoder, float, int, list, nullable, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode
import RemoteData
import Table


getBarMoveIncrement : Int -> Int
getBarMoveIncrement level =
    barMoveIncrement + level


getBarMoveIncrementMobile : Int -> Int
getBarMoveIncrementMobile level =
    barMoveIncrementMobile + level


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
      , pseudo = ""
      , pseudoErrors = Maybe.Just ""
      , apiUrl = flags.apiUrl
      , jwtToken = flags.jwtToken
      , score = 100
      , savedScore = Maybe.Nothing
      , topScores = RemoteData.NotAsked
      , tableState = Table.sortBy "score" False
      , filterScoreUsername = ""
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


decodeScore : Decoder Score
decodeScore =
    Json.Decode.succeed Score
        |> required "id" int
        |> required "pseudo" string
        |> required "level" int
        |> required "score" int
        |> optional "rank" int 0


sendScore : String -> String -> String -> Int -> Int -> Cmd Msg
sendScore token url pseudo level score =
    Http.request
        { method = "post"
        , url = url ++ "/scores"
        , headers =
            [ Http.header "Authorization" ("Bearer " ++ token)
            , Http.header "Prefer" "return=representation"
            ]
        , body =
            Http.jsonBody
                (Json.Encode.object
                    [ ( "pseudo", Json.Encode.string pseudo )
                    , ( "level", Json.Encode.int level )
                    , ( "score", Json.Encode.int score )
                    ]
                )
        , expect = Http.expectJson (RemoteData.fromResult >> GotScore) (list decodeScore)
        , tracker = Nothing
        , timeout = Nothing
        }


getTopScores : String -> String -> String -> Cmd Msg
getTopScores token url username =
    Http.request
        { method = "GET"
        , body = Http.emptyBody
        , url = url ++ "/scores_with_rank?limit=10&offset=0&order=score.desc&pseudo=like.%25" ++ username ++ "%25"
        , headers =
            [ Http.header "Authorization" ("Bearer" ++ token)
            ]
        , expect = Http.expectJson (RemoteData.fromResult >> GotTopScores) (list decodeScore)
        , tracker = Nothing
        , timeout = Nothing
        }


getColorIndex : Int -> Int
getColorIndex level =
    let
        firstNumber =
            String.slice 0 1 (String.fromInt level)

        firstNumberInt =
            String.toInt firstNumber
    in
    case firstNumberInt of
        Just value ->
            if value > 5 then
                10 - value - 1

            else
                value - 1

        Nothing ->
            0
