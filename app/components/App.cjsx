uuid = require 'node-uuid'
React = require 'react'

module.exports = class App extends React.Component
  constructor: (props) ->
    super(props)
    @state = {
      notes: [
        {id: uuid.v4(), task: 'Learn Webpack'}
        {id: uuid.v4(), task: 'Learn React'}
        {id: uuid.v4(), task: 'Do laundry'}
      ]
    }

  render: ->
    <div>
      <ul>
        {@state?.notes?.map (note) =>
          <li key={note.id}>{note.task}</li>
        }
      </ul>
    </div>
