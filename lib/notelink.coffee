fs = require 'fs-plus'
path = require 'path'
{CompositeDisposable, Disposable} = require 'atom'
escapeStringRegexp = require 'escape-string-regexp'

module.exports = atomNoteLink =
  config:
    directory:
      title: 'Note Directory'
      description: 'The directory where you plan to store your notes'
      type: 'string'
      default: path.join(process.env.ATOM_HOME, 'notelink')
    extensions:
      title: 'Extensions'
      description: 'The first extension will be used for newly created notes.'
      type: 'array'
      default: ['.md', '.mmd', 'markdown']
      items:
        type: 'string'
    linkbegin:
      title: 'Link Begin Symbol'
      description: 'The symbol used to mark the beginning of a link'
      type: 'string'
      default: '[['
    linkend:
      title: 'Link End Symbol'
      description: 'The symbol used to mark the ending of a link'
      type: 'string'
      default: ']]'
    linkregex:
      title: 'Link Regex'
      description: 'The regex used to identify the contents of a link'
      type: 'string'
      default: '(.+)'
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'notelink:follow': => @follow()
    @subscriptions.add atom.commands.add 'atom-workspace', 'notelink:copylink': => @copyLink()

    addEventListener = (editor, eventName, handler) ->
      editorView = atom.views.getView(editor)
      editorView.addEventListener eventName, handler
      new Disposable ->
        editorView.removeEventListener eventName, handler

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      disposables = new CompositeDisposable
      disposables.add addEventListener editor, 'click', (event) =>
        if event.altKey
          @follow()
      disposables.add editor.onDidDestroy =>
        disposables.dispose()
        @subscriptions.remove(disposables)
      @subscriptions.add(disposables)

  deactivate: ->
    @subscriptions.dispose()

  follow: ->
    noteDirectory = fs.normalize(atom.config.get('notelink.directory'))
    noteExtension = if atom.config.get('notelink.extensions') then atom.config.get('notelink.extensions')[0] else '.md'
    editor = atom.workspace.getActiveTextEditor()
    cursorPosition = editor.getCursorBufferPosition()
    buffer = editor.getBuffer()
    currentRow = buffer.lineForRow(cursorPosition.row)
    linkRegex = escapeStringRegexp(atom.config.get('notelink.linkbegin'))
    linkRegex += atom.config.get('notelink.linkregex')
    linkRegex += escapeStringRegexp(atom.config.get('notelink.linkend'))
    pattern = new RegExp(linkRegex, 'g')
    match = pattern.exec currentRow
    return unless match
    matches = true
    while match
      return if cursorPosition.column < match.index
      if cursorPosition.column < (match.index + match[0].length)
        noteName = match[1]
        notePath = path.join(noteDirectory, noteName + noteExtension)
        unless fs.existsSync(notePath)
          fs.writeFileSync(notePath, '')
        atom.workspace.open(notePath)
        return
      else
        match = pattern.exec currentRow

  copyLink: ->
    noteDirectory = fs.normalize(atom.config.get('notelink.directory'))
    noteExtension = if atom.config.get('notelink.extensions') then atom.config.get('notelink.extensions')[0] else '.md'
    editor = atom.workspace.getActiveTextEditor()
    notePath = editor.getPath()
    return unless notePath.startsWith(noteDirectory) and notePath.endsWith(noteExtension)
    text = notePath.replace noteDirectory, ""
    text = text.replace noteExtension, ""
    text = text.replace /^\/+|^\\+/g, ""
    text = atom.config.get('notelink.linkbegin') + text + atom.config.get('notelink.linkend')
    atom.clipboard.write(text)

  provide: ->
    unless @provider?
      LinkProvider = require('./provider')
      @provider = new LinkProvider()

    @provider
