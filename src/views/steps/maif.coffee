StepView = require '../step'
_ = require 'underscore'

module.exports = class MaifView extends StepView
    template: require '../templates/view_steps_maif'

    ui:
        next: '.controls .next'
        pass: '.controls .pass'

    events:
        'click @ui.next': 'onSubmit'
        'click @ui.pass': 'onSubmit'


    onRender: (args...) ->
        super args...
        @$errorContainer=@$('.errors')

        if @error
            @renderError(@error)
        else
            @$errorContainer.hide()


    onSubmit: (event) ->
        event.preventDefault()
        @model
            .submit()
            .then null, (error) =>
                @renderError error.message


    serializeData: ->
        _.extend super,
            id: "#{@model.get 'name'}-figure"
            service: "service-logo--#{@model.get 'name'}"
            figureid: require '../../assets/sprites/maif.svg'


    renderError: (error) ->
        @$errorContainer.html(t(error))
        @$errorContainer.show()
