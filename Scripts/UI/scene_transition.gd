extends CanvasLayer

func _ready() -> void:
	SignalBus.connect('scene_transition_started', Callable(self, "fade_out"))

func fade_out():
	#$SFX.playing = true
	AudioManager.change_song_to_combat("pokemon")
	self.visible = true
	get_tree().paused = true
	$AnimationPlayer.play('fadeout')
	await $AnimationPlayer.animation_finished
	$ColorRect.visible = false
	$AnimationPlayer.play('fadein')
	await $AnimationPlayer.animation_finished
	self.visible = false
	get_tree().paused = false
	$ColorRect.visible = true
	SignalBus.scene_transition_finished.emit()
