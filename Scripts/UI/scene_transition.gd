extends CanvasLayer

func _ready() -> void:
	SignalBus.connect('scene_transition_started', Callable(self, "fade_out"))

func fade_out():
	self.visible = true
	get_tree().paused = true
	$AnimationPlayer.play('fadeout')
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards('fadeout')
	await $AnimationPlayer.animation_finished
	self.visible = false
	get_tree().paused = false
	GlobalAudioStream.fanfare_audio()
	SignalBus.scene_transition_finished.emit()
