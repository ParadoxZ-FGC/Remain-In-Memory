class_name Pause #ALERT Not currently in use, but may be used in the future (who am I kidding, it will be, unfortunately)

const FLOATPATTERN = "\\d+\\.\\d+"
var pausePosition : int
var duration : float

func _init(position : int, string : String) -> void:
	var durationRegex = RegEx.new()
	durationRegex.compile(FLOATPATTERN)
	
	duration = float(durationRegex.search(string).get_string())
	pausePosition = int(clamp(position - 1, 0, abs(position)))
