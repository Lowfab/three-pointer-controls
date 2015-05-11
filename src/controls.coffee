clone = require 'clone'

{BUTTON, KEY, STATE} = require './enums'
defaults = require './defaults'

PanHelper = require './PanHelper'

module.exports = (THREE) ->
	class PointerControls
		constructor: ->
			@conf = clone defaults

			@cameras = []
			@state = STATE.NONE

			@start = new THREE.Vector2()
			@end = new THREE.Vector2()
			@delta = new THREE.Vector2()
			@offset = new THREE.Vector3()

			@target = new THREE.Vector3()
			@pan = new THREE.Vector3()

			@element = undefined

		control: (camera) =>
			@cameras.push camera
			return

		listenTo: (domElement) =>
			registerEventListeners @, domElement
			return

		onPointerDown: (event) =>
			preventDefault event

			switch event.buttons
				when @conf.pan.button
					return unless @conf.pan.enabled
					@state = STATE.PAN
					@start.set event.clientX, event.clientY
				else
					return

			@element = event.target
			document.addEventListener 'pointermove', @onPointerMove
			document.addEventListener 'pointerup', @onPointerUp
			return

		onPointerMove: (event) =>
			preventDefault event

			switch @state
				when STATE.PAN
					@end.set event.clientX, event.clientY
					@delta.subVectors @end, @start
					PanHelper.pan(this).by @delta
					@start.copy @end
				else
					return

			@update()
			return

		onPointerUp: (event) =>
			preventDefault event
			document.removeEventListener 'pointermove', @onPointerMove
			document.removeEventListener 'pointerup', @onPointerUp
			@element = undefined
			@state = STATE.NONE
			return

		update: =>
			@offset.copy(@cameras[0].position).sub @target

			@target.add @pan
			@pan.set 0, 0, 0

			for camera in @cameras
				camera.position.copy(@target).add @offset
				camera.lookAt @target
			return

preventDefault = (event) ->
	event.preventDefault()
	event.stopPropagation()
	event.stopImmediatePropagation()
	return

registerEventListeners = (controls, domElement) ->
	domElement.addEventListener 'contextmenu', preventDefault
	domElement.addEventListener 'pointerdown', controls.onPointerDown
	return
