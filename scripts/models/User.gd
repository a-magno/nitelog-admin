class_name User
extends Resource

var displayName : String
var schedule : Array[Dictionary]
var email : String
var userId : String

func _init(_name, _email):
	displayName = _name
	email = _email

func get_data() -> Dictionary:
	return {
		"id":userId,
		"displayName":displayName,
		"email":email,
		"schedule":schedule,
		"admin":false
	}

func add_scheduled_day(day : String, clock_in : String, clock_out : String):
	schedule.push_back(
		{
			"dayOfWeek": day,
			"fromTime":clock_in,
			"toTime":clock_in
		}
	)
