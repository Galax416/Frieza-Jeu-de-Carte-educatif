class_name Card
extends Control


@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label
@onready var state_machine: CardStateMachine = $CardStateMachine
@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_detector: Area2D = $CardsDetector
@onready var home_field: Field

var index: int = 0

func set_home_fied(field: Field):
	home_field = field

func _ready():
	pass

func _input(event):
	state_machine.on_input(event)


func _on_gui_input(event):
	state_machine.on_gui_input(event)


func _on_mouse_entered():
	state_machine.on_mouse_entered()


func _on_mouse_exited():
	state_machine.on_mouse_exited()
