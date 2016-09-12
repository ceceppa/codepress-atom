CodePressAtomView = require './codepress-atom-view'
CodePressWebView = require './codepress-webview'
CodePressPanel = require './codepress-panel'
CodePressRequest = require './codepress-request'
CodePressDB = require './db'

{CompositeDisposable} = require 'atom'

module.exports = CodePressAtom =
  # BG_URL: 'http://staging1.codepress.io/api/v1'
  BG_URL: 'http://codepress.io/api/v1'
  codepressAtomView : null

  activate: (state) ->
    @codepressDB = new CodePressDB(state.codepressDB)
    @codepressPanel = new CodePressPanel(state.codepressPanelState)
    @codepressWebView = new CodePressWebView()
    @codepressRequest = new CodePressRequest(state.codepressRequest, @BG_URL, @codepressDB, @codepressPanel, @codepressWebView)
    @codepressAtomView = new CodePressAtomView(state.codepressAtomViewState, @codepressRequest, @BG_URL)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'codepress-atom:toggle': => @toggle()

    @codepressAtomView.toggle()

  deactivate: ->
    @subscriptions.dispose()
    @codepressAtomView.destroy()

  serialize: ->
    codepressAtomViewState: @codepressAtomView.serialize()

  toggle: ->
    @codepressAtomView.toggle()
