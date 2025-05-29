extends Node

# Codigo imcompleto

# Onready references to AudioStreamPlayers
@onready var gameplayMusicPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var SFXBoxCrashPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
@onready var SFXJumpPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
@onready var SFXStickPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
@onready var SFXCharWalkingPlayer : AudioStreamPlayer = AudioStreamPlayer.new()

# Load the audio files
var SFXBoxCrashAudio = preload("res://Assets/Sounds/sfx_box_crash_v1.wav")
var SFXJumpAudio = preload("res://Assets/Sounds/Char/char_cyber_pulo_v1.wav")
var SFXStickAudio = preload("res://Assets/Sounds/Char/char_cyber_grudar_v1.wav")
var SFXCharWalkingAudio = preload("res://Assets/Sounds/Char/char_cyber_andar_v1.wav")
var gameplayMusicAudio = preload("res://Assets/Sounds/Music/mus_main_theme_v2.wav")

# Function to initialize the AudioManager
func _ready() -> void:
	# Add AudioStreamPlayers to the tree
	add_child(gameplayMusicPlayer)
	add_child(SFXBoxCrashPlayer)
	add_child(SFXJumpPlayer)
	add_child(SFXStickPlayer)
	add_child(SFXCharWalkingPlayer)
	
	# Initialize the audio streams
	SFXJumpPlayer.stream = SFXJumpAudio
	SFXBoxCrashPlayer.stream = SFXBoxCrashAudio
	SFXStickPlayer.stream = SFXStickAudio
	SFXCharWalkingPlayer.stream = SFXCharWalkingAudio
	gameplayMusicPlayer.stream = gameplayMusicAudio
	
	# Configure where each player goes in audio bus
	SetBus(gameplayMusicPlayer, "Music")
	SetBus(SFXBoxCrashPlayer, "SFX")
	SetBus(SFXJumpPlayer, "SFX")
	SetBus(SFXStickPlayer, "SFX")
	SetBus(SFXCharWalkingPlayer, "SFX")

# Function to play the intro
func PlayBackgroundMusic() -> void:
	gameplayMusicPlayer.play()

func PlaySFX(sfxName) -> void:
	match sfxName:
		"pulo":
			SFXJumpPlayer.play()
		"caixa quebrando":
			SFXBoxCrashPlayer.play()
		"grudar":
			SFXStickPlayer.play()

func StartWalk() -> void:
	if not SFXCharWalkingPlayer.is_playing():
		SFXCharWalkingPlayer.play()

func StopWalk() -> void:
	if SFXCharWalkingPlayer.is_playing():
		SFXCharWalkingPlayer.stop()

func StopAll() -> void:
	gameplayMusicPlayer.stop()

# Function to set the volume of all
# WIP: This function will split to cover the volume of each one.
func SetVolumeMusic(volume: float):
	gameplayMusicPlayer.volume_db = volume

func SetVolumeSFX(volume : float):
	SFXBoxCrashPlayer.volume_db = volume

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
