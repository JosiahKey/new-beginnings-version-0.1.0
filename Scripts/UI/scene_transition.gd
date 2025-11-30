extends CanvasLayer

func _ready() -> void:
	SignalBus.connect('combat_entered', Callable(self, "enter_combat"))
	SignalBus.connect('combat_exited', Callable(self, "exit_combat"))

func enter_combat():
	#$SFX.playing = true
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

func exit_combat():
	self.visible = true
	get_tree().paused = true
	$TextureRect.visible = false
	$AnimationPlayer.play('fadeout')
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards('fadeout')
	await $AnimationPlayer.animation_finished
	self.visible = false
	get_tree().paused = false
	$TextureRect.visible = true
	SignalBus.scene_transition_finished.emit()
