fs = require 'fs-plus'
path = require 'path'
{CompositeDisposable} = require 'atom'

module.exports = ZettelkastenWiki =
  config:
    directory:
      title: 'Note Directory'
      description: 'The directory where you plan to store your notes'
      type: 'string'
      default: path.join(process.env.ATOM_HOME, 'zettelkasten-wiki')
    extensions:
      title: 'Extensions'
      description: 'The first extension will be used for newly created notes.'
      type: 'array'
      default: ['.md', '.mmd', 'markdown']
      items:
        type: 'string'
  zettelkastenWikiView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that follows the link
    @subscriptions.add atom.commands.add 'atom-workspace', 'zettelkasten-wiki:follow': => @follow()

  deactivate: ->
    @subscriptions.dispose()

  follow: ->
    noteDirectory = fs.normalize(atom.config.get('zettelkasten-wiki.directory'))
    noteExtension = if atom.config.get('zettelkasten-wiki.extensions') then atom.config.get('zettelkasten-wiki.extensions')[0] else '.md'
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



  provide: ->
    unless @provider?
      LinkProvider = require('./link-provider')
      @provider = new LinkProvider()

    @provider

# linkProvider =
#   selector: '.source.gfm'
#
#   # This will take priority over the default provider, which has a priority of 0.
#   # `excludeLowerPriority` will suppress any providers with a lower priority
#   # i.e. The default provider will be suppressed
#   inclusionPriority: 1
#   excludeLowerPriority: true
#
#   # Required: Return a promise, an array of suggestions, or null.
#   getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
#     new Promise (resolve) ->
#       resolve([text: 'something'])
#
# provide: ->
#   @linkProvider
