StepView = require '../step'
passwordHelper = require '../../lib/password_helper'
_ = require 'underscore'


module.exports = class PasswordView extends StepView

    template: require '../templates/view_steps_password'

    events:
        'click .next': 'onSubmit'
        'click [action=password-visibility]': 'onToggleVisibility'

        'change input': 'checkPasswordStrength'
        'input input': 'checkPasswordStrength'
        'keyup input': 'checkPasswordStrength'
        'mouseup input': 'checkPasswordStrength'
        'paste input': 'checkPasswordStrength'

    isVisible: false


    onRender: (args...) ->
        super args...
        @$inputPassword = @$('input[name=password]')
        @$visibilityButton = @$('[action=password-visibility]')
        @$strengthBar = @$('progress')
        @$errorContainer=@$('.errors')
        if @error
            @renderError(@error, false)
        else
            @$errorContainer.hide()


    renderInput: =>
        data = @serializeInputData()

        # Show/hide password value
        @$inputPassword.attr 'type', data.inputType

        # Update Button title
        @$visibilityButton.html(t(data.visibilityTxt))


    initialize: (args...) ->
        super args...
        # lowest level is 1 to display a red little part
        @passwordStrength = passwordHelper.getStrength ''
        @updatePasswordStrength = updatePasswordStrength.bind(@)


    updatePasswordStrength= _.throttle( ->
        @passwordStrength = passwordHelper.getStrength @$inputPassword.val()

        if @passwordStrength.percentage is 0
            @passwordStrength.percentage = 1
        @$strengthBar.attr 'value', @passwordStrength.percentage
        @$strengthBar.attr 'class', 'pw-' + @passwordStrength.label
        @$inputPassword.removeClass('error')
    , 500)


    checkPasswordStrength: ->
        @updatePasswordStrength()


    # Get 1rst error only
    # err is an object such as:
    # { type: 'password', text:'step password empty'}
    serializeData: () ->
        return Object.assign {}, @serializeInputData(), {
            id:         "#{@model.get 'name'}-figure"
            figureid:   require '../../assets/sprites/icon-lock.svg'
            passwordStrength: @passwordStrength
        }


    serializeInputData: =>
        visibilityAction = if @isVisible then 'hide' else 'show'
        type = if @isVisible then 'text' else 'password'
        {
            visibilityTxt:  "step password #{visibilityAction}"
            inputType:      type
        }


    onToggleVisibility: (event) ->
        event?.preventDefault()

        # Update Visibility
        @isVisible = not @isVisible

        # Update Component
        @renderInput()


    getDataForSubmit: ->
        return {
            password: @$inputPassword.val()
        }

    renderError: (error) ->
        @$errorContainer.html(t(error))
        @$errorContainer.show()


    onSubmit: (event)->
        event?.preventDefault()
        data = @getDataForSubmit()
        validation = @model.validate data
        if not validation.success
            errors = validation.errors
            if errors?.password
                @$inputPassword.addClass('error')
                @renderError(errors.password)
        else
            @model
                .submit data
                .then null, (error) =>
                    @renderError error.message
