fs = require 'fs-plus'
escapeStringRegexp = require 'escape-string-regexp'

module.exports =
class LinkProvider
  selector: '.source.gfm'
  inclusionPriority: 2
  # suggestionPriority: 2

  filterSuggestions: true

  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return unless prefix[0] is atom.config.get('notelink.linkbegin')[0]
    new Promise (resolve) ->
      noteDirectory = fs.normalize(atom.config.get('notelink.directory'))
      noteExtension = if atom.config.get('notelink.extensions') then atom.config.get('notelink.extensions')[0] else '.md'
      notes = fs.readdirSync(noteDirectory)

      suggestions = []
      for note in notes
        continue unless note.endsWith(noteExtension)
        note = note.substr(0, note.lastIndexOf('.'))

        suggestions.push
          selector: '.source.gfm'
          text: note

      resolve(suggestions)

  getPrefix: (editor, bufferPosition) ->
      # Whatever your prefix regex might be
      buildRegex = escapeStringRegexp(atom.config.get('notelink.linkbegin'))
      buildRegex += '[\\w 0-9_-]+$'
      regex = new RegExp(buildRegex)

      # Get the text for the line up to the triggered buffer position
      line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

      # Match the regex to the line, and return the match
      line.match(regex)?[0] or ''
