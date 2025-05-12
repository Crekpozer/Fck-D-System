extends StaticBody3D

# Referencia ao material
@onready var meshInstance = %MeshInstance3D
# Cor
var newColor: Color = Color(0,0,0)
# Rotação
var rotationSpeed = Vector3(0, 30, 0)

func _process(delta: float) -> void:
	if meshInstance:
		meshInstance.rotation_degrees += rotationSpeed * delta


# Evento disparado quando o jogador clica no cubo
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	
	if meshInstance:
		var materialInstace = meshInstance.get_surface_override_material(0)
		
		if materialInstace:
			# Se o botão usado for o botão esquerdo do mouse...
			if event.button_mask == 1:
				newColor.r = randf_range(0.0, 1.0)
				newColor.g = randf_range(0.0, 1.0)
				newColor.b = randf_range(0.0, 1.0)
				materialInstace.albedo_color = newColor
		else:
			var newMaterial = StandardMaterial3D.new()
			newMaterial.albedo_color = newColor
			meshInstance.set_surface_override_material(0, newMaterial)
