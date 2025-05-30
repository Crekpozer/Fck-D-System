extends Node3D

@onready var HUD : CanvasLayer = %HUD
@onready var playerCharacter : Player = %CharacterBody3D
@onready var lifeProgressbar : TextureProgressBar = %TextureProgressBar

var isGameOver : bool

func _ready() -> void:
	AudioManager.PlayBackgroundMusic()

func _process(_delta: float) -> void:
	if lifeProgressbar.value == 0:
		%HUD.visible = false
		%GameOver.visible = true
		isGameOver = true
