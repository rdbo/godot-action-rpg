extends Control

const HEART_WIDTH = 15
onready var empty_hearts = $EmptyHearts
onready var full_hearts = $FullHearts

func _ready():
	var _ret = PlayerStats.connect("health_changed", self, "update_health")
	_ret = PlayerStats.connect("max_health_changed", self, "update_max_health")

func update_health(value):
	full_hearts.rect_size.x = value * HEART_WIDTH

func update_max_health(value):
	empty_hearts.rect_size.x = value * HEART_WIDTH
