extends Camera2D


# Got this from a dope YouTube tutorial
# https://www.youtube.com/watch?v=pG4KGyxQp40


var _shake_intensity: float = 0.0
var _active_shake_time: float = 0.0

var _shake_decay: float = 5.0

var _shake_time: float = 0.0
var _shake_time_speed: float = 20.0

var _noise = FastNoiseLite.new()


func _physics_process(delta: float) -> void:
	if _active_shake_time > 0:
		_shake_time += delta * _shake_time_speed
		_active_shake_time -= delta
		
		offset = Vector2(
			_noise.get_noise_2d(_shake_time, 0) * _shake_intensity,
			_noise.get_noise_2d(0, _shake_time) * _shake_intensity,
		)
		
		_shake_intensity = max(_shake_intensity, - _shake_decay * delta, 0)
	else:
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)


func screen_shake(intensity: int, time: float) -> void:
	randomize()
	_noise.seed = randi()
	_noise.frequency = 2.0
	
	_shake_intensity = intensity
	_active_shake_time = 1000.0 if time == 0.0 else time
	_shake_time = 0.0
