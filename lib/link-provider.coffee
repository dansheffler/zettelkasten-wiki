fs = require 'fs-plus'

module.exports =
class LinkProvider
  selector: '.source.gfm'
  inclusionPriority: 2
  # suggestionPriority: 2

  filterSuggestions: true

  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return unless prefix[1] is '['
    new Promise (resolve) ->
      noteDirectory = fs.normalize(atom.config.get('zettelkasten-wiki.directory'))
      noteExtension = if atom.config.get('zettelkasten-wiki.extensions') then atom.config.get('zettelkasten-wiki.extensions')[0] else '.md'
      notes = fs.readdirSync(noteDirectory)

      suggestions = []
      for note in notes
        continue unless note.endsWith(noteExtension)
        note = note.substr(0, note.lastIndexOf('.'))
        console.log(note)
        # var input = 'myfile.png';
        # var output = input.substr(0, input.lastIndexOf('.')) || input;

        suggestions.push
          selector: '.source.gfm'
          text: note

      resolve(suggestions)

  getPrefix: (editor, bufferPosition) ->
      # Whatever your prefix regex might be
      regex = /\[\[[\w 0-9_-]+$/

      # Get the text for the line up to the triggered buffer position
      line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

      # Match the regex to the line, and return the match
      line.match(regex)?[0] or ''
