extends Node

# Codigo imcompleto

# Onready references to AudioStreamPlayers
@onready var gameplayMusicPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var SFXPlayer: AudioStreamPlayer = AudioStreamPlayer.new()

# Load the audio files
var gameplayMusicAudio = preload("res://Assets/Sounds/Track2_Gameplay.wav")
var SFXAudio = preload("res://Assets/Sounds/SFX1_BallHit.wav")

# Function to initialize the AudioManager
func _ready() -> void:
	# Add AudioStreamPlayers to the tree
	add_child(gameplayMusicPlayer)
	add_child(SFXPlayer)
	# Initialize the audio streams
	gameplayMusicPlayer.stream = gameplayMusicAudio
	SFXPlayer.stream = SFXAudio
	
	# Configure where each player goes in audio bus
	SetBus(gameplayMusicPlayer, "Music")
	SetBus(SFXPlayer, "SFX")

# Function to play the intro
func PlayBackgroundMusic() -> void:
	gameplayMusicPlayer.play()

func PlaySFX() -> void:
	SFXPlayer.play()

func StopAll() -> void:
	gameplayMusicPlayer.stop()

# Function to set the volume of all
# WIP: This function will split to cover the volume of each one.
func SetVolume(volume: float):
	gameplayMusicPlayer.volume_db = volume
	SFXPlayer.volume_db = volume

# Function to configure the bus of an AudioStreamPlayer
func SetBus(player: AudioStreamPlayer, busName: String):
	player.bus = busName

# Function to enable or disable an audio effect on a bus
func SetAudioEffect(busName: String, effectIDX: int, enable: bool):
	var busIDX = AudioServer.get_bus_index(busName)
	
	if busIDX != -1:
		AudioServer.set_bus_effect_enabled(busIDX, effectIDX, enable)
	else:
		print("Bus not found: " + busName)
