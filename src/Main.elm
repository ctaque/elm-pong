module Main exposing (main)

import Browser
import Functions exposing (init)
import Update exposing (update)
import View exposing (app)
import Subscriptions exposing (subscriptions)



main =
    Browser.element { init = init, update = update, view = app, subscriptions = subscriptions }