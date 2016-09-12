CodePressAtom = require './codepress-atom'
{SelectListView, $$} = require 'atom-space-pen-views'

module.exports =
  class CodePressAtomView extends SelectListView
    #Current slug
    _slug = ''

    #Slugs history (used to go "back")
    _slugs = []

    # The refresh item text
    _refreshItem = '- Refresh List -'

    #The back item text
    _backItem = '- Back -'

    #Database data
    _data = {}

    constructor: (options, args...) ->
      super(args)
      @codepressRequest = args[0]
      @API_URL = args[1]

      @readItems _slug
      @panel ?= atom.workspace.addModalPanel(item: this)
      @panel.show()
      @focusFilterEditor()

    initialize: ->
      super

    readItems: (slug, load = true) ->
      # The "root" slug is generators
      slug = slug || 'generators'
      if _slugs[_slugs.length - 1] != slug
        _slugs.push slug
      _slug = slug

      # Get the items from the database
      if load || ! _data[slug]
        _data[slug] = @codepressRequest.db.get slug

      data = _data[slug]
      items = []
      console.log _data, slug, data

      if _slugs.length > 1
        items.push _backItem

      for key of data
        item = data[key]
        items.push item.title

      items.push _refreshItem
      @setItems items

    ###
    Toggle the view
    ###
    toggle: ->
      if @panel.isVisible()
        @panel.hide()
      else
        # FIXME: When toggle the list is empty, need to type something to show the items...
        @readItems _slug, true

        @panel.show()
        @focusFilterEditor()

    viewForItem: (item) ->
      "<li>#{item}</li>"

    confirmed: (item) ->
      @panel.hide()

      #
      # Refresh the list
      #
      if( _refreshItem == item )
        @codepressRequest.refresh _slug, @
      else if _backItem == item
        _slugs.pop()

        @readItems _slugs[_slugs.length - 1]
        @toggle()
      else
        items = _data[_slug]
        for key of items
          i = items[key]
          if i.title == item
            # Contains subitems or is a template?
            console.log 'Item', i
            if i.endpoint.indexOf('template') >= 0
              console.info 'Loading iframe', i.link
              @codepressRequest.loadContent i.link
            else
              url = @API_URL

              @readItems i.endpoint
              @toggle()

            break

    cancelled: ->
      @panel.hide()
