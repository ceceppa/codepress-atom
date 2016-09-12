{View} = require 'atom-space-pen-views'

module.exports =
  class CodePressWebView extends View

    initialize: ->
      @addClass('modal overlay from-top')
      @appendTo atom.views.getView atom.workspace
      @hide()

    @content: ->
      @div class: 'codepress', =>
        @iframe class: 'codepress__iframe', src: ''
        @div class: 'codepress__actions', =>
          @a href: '#', class: 'codepress__actions__button button-close', 'Close'
          # @a href: '#', class: 'codepress__actions__button button-insert codepress__actions__button--right', 'Insert code'

    setUrl: (url)->
      @iframe = @find('iframe')[0] if typeof(@iframe) == 'undefined'
      @iframe.src = url + '?embed=1'

      if typeof(@close) == 'undefined'
        @close = @find('.button-close')

        webView = @
        @close.on 'click', ->
          webView.hide()
      #
      # if typeof(@insert) == 'undefined'
      #   @close = @find('.button-insert')
      #
      #   webView = @
      #   @close.on 'click', ->
      #     webView.hide()

      @show()
