extends Control

@onready var prestige_button: Button = %PrestigeButton

func _ready() -> void:
	prestige_button.pressed.connect(_on_prestige_button_pressed)

func _on_prestige_button_pressed() -> void:
	GameManager.do_prestige()