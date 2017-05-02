StepView = require '../step'
_ = require 'underscore'


module.exports = class ConfirmationView extends StepView
    template: require '../templates/view_steps_firstsConnectors'

    ui:
        next: '.controls .next'
        errors: '.errors'

    events:
        'click @ui.next': 'onSubmit'


    onRender: (args...) ->
        super args...

        if @error
            @show(@error)
        else
            @hideError()


    onSubmit: (event) ->
        event.preventDefault()
        @model
            .submit()
            .then null, (error) =>
                @showError error.message


    serializeData: ->
        _.extend super,
            id: "#{@model.get 'name'}-figure"
            figureid: require '../../assets/sprites/icon-thumbup.svg'
