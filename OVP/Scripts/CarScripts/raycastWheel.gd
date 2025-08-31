extends RayCast3D
class_name raycastWheel

@export var spring_strength := 100.0; #Portuguese note: força da mola
@export var spring_damping := 2.0;  #Portuguese note:  amortecimento
@export var rest_dist := 0.5;  #Portuguese note: retorno da mola
@export var over_extend := 0.0;
@export var wheel_radius := 0.4;
@export var is_motor := false;

@onready var wheel: Node3D = get_child(0);
