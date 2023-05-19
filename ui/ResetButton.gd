extends Node2D

signal reset

func _on_TextureButton_pressed():
	emit_signal("reset")

func tick(_beat):
	$PulseTween.pulse(U.v(1.1, 1.1))

func _ready():
	$PulseTween.target = $Grid