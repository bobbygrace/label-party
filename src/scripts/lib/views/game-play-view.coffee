$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $
{ renderable, div, form, input, text, ul, li, p, strong, span, a, raw, h2, h4 } = require 'teacup'
AppView = require './app-view.coffee'
NewGameView = require './new-game-view.coffee'

template = renderable (data) ->
  p "GAME TIME"
  a '.js-new-game', href: "#", "Start a New Game"
  h2 '.js-fill-word'
  div '.js-fill-label-select'
  div '.js-pair-list'

labelsTemplate = renderable (labels) ->
  h4 "This is…"
  ul ->
    for label in labels
      li ->
        a '.js-select-label', href: '#', 'data-labelname': label.name, label.name

pairsTemplate = renderable (pairs) ->
  for pair in pairs
    p ->
      strong pair.word
      text " is "
      strong pair.label
      text "."

class GamePlayView extends Backbone.View
  events:
    'click .js-new-game': 'newGame'
    'click .js-select-label': 'selectLabel'

  initialize: ->
    pairs = @getPairCollection()
    @listenTo pairs, 'add', @fillWord
    @listenTo pairs, 'add', @fillPairs

  render: ->
    @$el.append template()
    @fillLabels()
    @getNewWord()
    @

  fillLabels: ->
    labels = @getLabelCollection().toJSON()
    @$('.js-fill-label-select').append labelsTemplate(labels)
    return

  fillWord: ->
    word = @getLatestWord()
    @$('.js-fill-word').text word
    return

  fillPairs: ->
    pairs = @getPairCollection().toJSON().reverse()

    data = []
    for pair in pairs
      if pair.label
        data.push pair

    @$('.js-pair-list').html pairsTemplate(data)
    return

  getLabelCollection: ->
    @model.get('labelCollection')

  getPairCollection: ->
    @model.get('pairCollection')

  getLatestPair: ->
    @getPairCollection().last()

  getLatestWord: ->
    @getLatestPair()?.get('word')

  addWord: (word) ->
    @model.get('pairCollection').add
      word: word

  getNewWord: ->
    url = "http://api.wordnik.com:80/v4/words.json/randomWord?hasDictionaryDef=true&minCorpusCount=0&maxCorpusCount=-1&minDictionaryCount=1&maxDictionaryCount=-1&minLength=4&maxLength=-1&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"

    $.get url, (data) =>
      @addWord data.word

  selectLabel: (e) ->
    label = $(e.target).closest('a').attr('data-labelname')
    @getLatestPair().set 'label': label
    @getNewWord()
    return

  newGame: (e) ->
    e.preventDefault()
    game = AppView.startNewGame()

    view = new NewGameView({ model: game })
    AppView.showView view

    false

module.exports = GamePlayView
