extends Node

var canvas
var tween : Tween
var travel_dist := Vector2(0, 128)
# Called when the node enters the scene tree for the first time.
func _ready():
	canvas = CanvasLayer.new()
	add_child(canvas)
	

func add_notify_label(msg, duration):
	var lbl = RichTextLabel.new()
	canvas.add_child(lbl)
	lbl.bbcode_enabled = true
	lbl.fit_content = true
	lbl.size_flags_vertical = Control.SIZE_SHRINK_END
	lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	lbl.text = msg
	await get_tree().create_timer(duration).timeout
	tween = get_tree().create_tween()
	if tween and tween.is_running():
		tween.kill()

	
	tween.tween_property(lbl,"position", travel_dist, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel()
	tween.tween_property(lbl, "modulate", Color(0,0,0,0), 1)
	await tween.finished
	tween.kill()
	return
