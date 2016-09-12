CodePressAtom = require './codepress-atom'
request = require 'request'
# {BrowserWindow} = require('electron')
{BrowserWindow} = require('electron').remote

module.exports =
  class CodePressRequest
    constructor: (options, url, db, panel, webView) ->
      @db = db
      @codepressPanel = panel
      @codepressWebView = webView
      @URL = url

      console.log @URL
      #Event listener, needed to get the message from the iframe
      eventMethod = if window.addEventListener then "addEventListener" else "attachEvent"
      eventer = window[eventMethod]
      messageEvent = if eventMethod == "attachEvent" then "onmessage" else "message"

      #Listen to message from child window
      temp = this
      eventer messageEvent, (e) ->
        #Ignore other events, if any
        if e.data && e.data.sendto
          code = e.data.sendto
          temp.getCode code

      ,false

    ###
    Load the iframe (content)
    ###
    loadContent: (url) ->
      @codepressWebView.setUrl url

    ###
    Retrieve the code through the API and insert the response
    into the editor
    ###
    getCode: (token) ->
      url = "#{@URL}/sendto/?token=" + token
      webView = @codepressWebView
      console.log 'Token', token, url

      request.get(
        url,
        (error, response, body) ->
          webView.hide()
          console.log 'response', error, response, body

          if response.statusCode == 200 && body
            json = JSON.parse(response.body)

            editor = atom.workspace.getActiveTextEditor()
            editor.insertText json.data
      )

    ###
    Retrieve the list of all boilerplates
    ###
    refresh: (slug, fn) ->
      panel = @codepressPanel
      db = @db
      callback = fn
      url = "#{@URL}/#{slug}"
      @codepressPanel.setCaption 'Refreshing list'

      console.log 'Request', slug, url
      request.get(
        url,
        (error, response, body) ->
          if response.statusCode == 200
            json = JSON.parse(response.body)

            db.add slug, json
            panel.setCaption 'List updated'

            callback.readItems slug
            callback.toggle()
          else
            console.log 'Error', error, response, body
            panel.setCaption 'Something went wrong'

          panel.hidePanel true
      )
