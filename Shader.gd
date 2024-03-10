extends ColorRect

var adjustmentConstant = 1.3

func _ready():
	get_tree().get_root().size_changed.connect(onResize)
	onResize()

func onResize():
	material.set_shader_parameter("scanline_count",get_tree().get_root().size.y*adjustmentConstant)
