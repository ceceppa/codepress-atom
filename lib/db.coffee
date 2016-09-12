fs = require 'fs'


module.exports =
  class CodePressDB
    ###
    Add / Update the list of items for the specified slug
    ###
    add: (slug, items) ->
      data = @get()

      data[slug] = items

      try
        fs.writeFileSync(
          @file()
          JSON.stringify data, null, 2
          'utf-8'
        )
      catch
        console.error err

    ###
    Get the data from the "database"

    @param slug -
    ###
    get: (slug) ->
      try
        stats = fs.statSync(@file())
      catch
        return {}

      data = fs.readFileSync(
        @file()
      )

      if data.length
        data = JSON.parse data.toString()

      if slug
        return data[slug] || {}
      else
        return data || {}

    file: ->
      filename = 'codepress.cson'
      filedir = atom.getConfigDirPath()

      return "#{filedir}/#{filename}"
