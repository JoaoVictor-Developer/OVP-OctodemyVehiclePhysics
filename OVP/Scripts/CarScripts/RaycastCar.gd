extends RigidBody3D

@export var wheels: Array[raycastWheel]; #Portuguese note: Para monitorar as rodas
@export var acceleration := 600.0;
@export var deceleration := 200.0;
@export var max_speed := 20.0;
@export var accel_curve : Curve;


var motor_input := 0;

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("accelerate"):
		motor_input = 1;
	elif event.is_action_released("accelerate"):
		motor_input = 0;
		
	if event.is_action_pressed("decelerate"):
		motor_input = -1;
	elif event.is_action_released("decelerate"):
		motor_input = 0;
		
func _physics_process(delta: float) -> void:
	var grounded := false;
	
	for wheels in wheels:
		if wheels.is_colliding():
			grounded = true
		wheels.force_raycast_update();
		_do_single_wheel_suspension(wheels);
		_do_single_wheel_acceleration(wheels);
		
	if grounded:
		center_of_mass = Vector3.ZERO
	else:
		center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM;
		center_of_mass = Vector3.DOWN * 0.5; 
func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position);
	
func _do_single_wheel_acceleration(ray: raycastWheel) -> void:
	var forward_dir := -ray.global_basis.z;
	var vel := forward_dir.dot(linear_velocity) #Portuguese note: velocidade de avanço
	ray.wheel.rotate_x(-vel * get_process_delta_time() * 2 * PI * ray.wheel_radius);
	
	if ray.is_colliding():
		var contact := ray.wheel.global_position;
		var force_pos := contact - global_position ;
	
		if ray.is_motor and motor_input:
			var speed_ratio := vel / max_speed;
			var ac := accel_curve.sample_baked(speed_ratio);
			var force_vector := forward_dir * acceleration * motor_input * ac;
			apply_force(force_vector,force_pos);
			
		elif abs(vel) > 0.015 and not motor_input:
			var drag_force_vector = global_basis.z * deceleration * signf(vel);
			apply_force(drag_force_vector,force_pos);
		
func _do_single_wheel_suspension(ray: raycastWheel) -> void:
	if ray .is_colliding():
		ray.target_position.y =-(ray.rest_dist + ray.wheel_radius + ray.over_extend); #Portuguese note: modifica o over_extend para 0.2		
		var contact := ray .get_collision_point();
		var spring_up_dir := ray .global_transform.basis.y;
		var spring_len := ray .global_position.distance_to(contact) - ray.wheel_radius;
		var offset := ray.rest_dist - spring_len;
		
		ray.wheel.position.y = -spring_len; #ATENÇÃO
		
		var word_vel := _get_point_velocity(contact);
		var relative_vel := spring_up_dir.dot(word_vel);
		var spring_damp_force := ray.spring_damping * relative_vel;
		
		var spring_force := ray.spring_strength * offset
		var force_vector := (spring_force - spring_damp_force) * ray.get_collision_normal();
		
		contact = ray.wheel.global_position;
		var force_pos_offset := contact - global_position
		apply_force(force_vector, force_pos_offset);
		
