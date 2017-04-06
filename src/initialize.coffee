###
Application bootstrap

Sets the browser environment to prepare it to launch the app, and then require
the application.
###

require('babel-polyfill')

Polyglot = require 'node-polyglot'

app = require './application'


###
Polyglot initialization

Locales need to be loaded in Polyglot before using it. We need to declares a
global translator `t` method to use it in Marionette templates.

We use the `html[lang]` attribute to get the correct locale.
###
initLocale = ->
    locale = document.documentElement.getAttribute 'lang'
    try phrases = require "./locales/#{locale}"
    catch e
        phrases = require './locales/en'
    polyglot = new Polyglot phrases: phrases, locale: locale
    # Temporary use a global variable to store the `t` helpers, waiting for
    # Marionette allow to register global helpers.
    # see https://github.com/marionettejs/backbone.marionette/issues/2164
    window.t = polyglot.t.bind polyglot


###
Retrieve the given query string parameter from url
###
getQueryStringParam = (key) ->
    queryString = window.location.search.substring(1)
    return queryString?.split('&').reduce (accumulator, param) ->
        keyValue = param.split('=')
        return if keyValue.length and keyValue[0] is key \
            then keyValue[1] else accumulator
    , null


###
Starts

Trigger locale initilization and starts application singleton.
###
document.addEventListener 'DOMContentLoaded', ->
    initLocale()
    registerToken = getQueryStringParam('registerToken')
    window.history.pushState({}, '', new URL(window.location.href).origin);
    app.start registerToken: registerToken
