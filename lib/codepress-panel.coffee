{$, $$, View} = require('atom-space-pen-views')

module.exports =
class CodePressPanel extends View

    @captionPrefix = 'Minify: '
    @clickableLinksCounter = 0

    @content: ->
        @div class: 'atom-minify atom-panel panel-bottom codepress-panel', =>
            @div class: 'inset-panel', =>
                @div outlet: 'panelHeading', class: 'panel-heading no-border', =>
                    @span
                        outlet: 'panelHeaderCaption'
                        class: 'header-caption'
                    @span
                        outlet: 'panelLoading'
                        class: 'inline-block loading loading-spinner-tiny hide'
                    @div outlet: 'panelRightTopOptions', class: 'inline-block pull-right right-top-options', =>
                        @button
                            outlet: 'panelClose'
                            class: 'btn btn-close'
                            click: 'hidePanel'
                            'Close'
                @div
                    outlet: 'panelBody'
                    class: 'panel-body padded hide'

    constructor: (options, args...) ->
      super(args)
      @options = options || {}
      @panel = atom.workspace.addBottomPanel
          item: this
          visible: false


    initialize: (serializeState) ->


    destroy: ->
        clearTimeout(@automaticHidePanelTimeout)
        @panel.destroy()
        @detach()


    updateOptions: (options) ->
        @options = options

    showPanel: (reset = false) ->
        clearTimeout(@automaticHidePanelTimeout)

        if reset
            @resetPanel()

        @panel.show()

    hidePanel: (withDelay = false)->
        clearTimeout(@automaticHidePanelTimeout)

        # We have to compare it to true because if close button is clicked, the withDelay
        # parameter is a reference to the button
        if withDelay == true
            @automaticHidePanelTimeout = setTimeout =>
                @panel.hide()
            , @options.autoHidePanelDelay || 3000
        else
            @panel.hide()

    setCaption: (text) ->
        @panelHeaderCaption.html(text)
        @showPanel()
