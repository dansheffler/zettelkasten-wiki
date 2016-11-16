fs = require 'fs-plus'
path = require 'path'
{CompositeDisposable} = require 'atom'

module.exports = atomNoteLink =
  config:
    directory:
      title: 'Note Directory'
      description: 'The directory where you plan to store your notes'
      type: 'string'
      default: path.join(process.env.ATOM_HOME, 'atom-notelink')
    extensions:
      title: 'Extensions'
      description: 'The first extension will be used for newly created notes.'
      type: 'array'
      default: ['.md', '.mmd', 'markdown']
      items:
        type: 'string'
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-notelink:follow': => @follow()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-notelink:copyLink': => @copyLink()

  deactivate: ->
    @subscriptions.dispose()

  follow: ->
    noteDirectory = fs.normalize(atom.config.get('atom-notelink.directory'))
    noteExtension = if atom.config.get('atom-notelink.extensions') then atom.config.get('atom-notelink.extensions')[0] else '.md'
    editor = atom.workspace.getActiveTextEditor()
    cursorPosition = editor.getCursorBufferPosition()
    buffer = editor.getBuffer()
    currentRow = buffer.lineForRow(cursorPosition.row)
    pattern = /\[\[([^\]]+)\]\]/g
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
    noteDirectory = fs.normalize(atom.config.get('atom-notelink.directory'))
    noteExtension = if atom.config.get('atom-notelink.extensions') then atom.config.get('atom-notelink.extensions')[0] else '.md'
    editor = atom.workspace.getActiveTextEditor()
    notePath = editor.getPath()
    return unless notePath.startsWith(noteDirectory) and notePath.endsWith(noteExtension)
    text = notePath.replace noteDirectory, ""
    text = text.replace noteExtension, ""
    text = text.replace /^\/+|^\\+/g, ""
    text = "[[" + text + "]]"
    atom.clipboard.write(text)

  provide: ->
    unless @provider?
      LinkProvider = require('./link-provider')
      @provider = new LinkProvider()

    @provider
