fs = require 'fs-plus'
glob = require 'glob'
escapeStringRegexp = require 'escape-string-regexp'

module.exports =
class LinkProvider
  selector: '.source.gfm'
  filterSuggestions: true

  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return unless prefix[0] is atom.config.get('notelink.linkbegin')[0]
    new Promise (resolve) ->
      [projPath, relPath] = atom.project.relativizePath(editor?.buffer?.file?.path)
      noteDirectory = fs.normalize(projPath)
      noteExtension = atom.config.get('notelink.extension')
      noteGlob = "**/*" + noteExtension
      notes = glob.sync(noteGlob, {cwd: noteDirectory})

      suggestions = []
      for note in notes
        note = note.replace noteExtension, ""
        suggestions.push
          selector: '.source.gfm'
          text: note

      resolve(suggestions)

  getPrefix: (editor, bufferPosition) ->
      # The prefix regex
      buildRegex = escapeStringRegexp(atom.config.get('notelink.linkbegin'))
      buildRegex += '[\\w\\s0-9_-]+$'
      regex = new RegExp(buildRegex)

      # Get the text for the line up to the triggered buffer position
      line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

      # Match the regex to the line, and return the match
      line.match(regex)?[0] or ''
