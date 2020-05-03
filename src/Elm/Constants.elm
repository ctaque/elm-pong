module Elm.Constants exposing (..)

import Array exposing (Array)


pxByMove : Int
pxByMove =
    2


barMoveIncrement : Int
barMoveIncrement =
    5


barMoveIncrementMobile : Int
barMoveIncrementMobile =
    80


barYOffset : Int
barYOffset =
    10


barHeight : Int
barHeight =
    20


circleRadius : Int
circleRadius =
    25


colors : Array String
colors =
    Array.fromList
        [ "66, 62, 55"
        , "89, 104, 105"
        , "46, 31, 39"
        , "129, 82, 63"
        , "110, 103, 95"
        ]


ballColors : Array String
ballColors =
    Array.fromList
        [ "217, 216, 209"
        , "196, 210, 210"
        , "192, 184, 190"
        , "217, 194, 172"
        , "212, 209, 200"
        ]
