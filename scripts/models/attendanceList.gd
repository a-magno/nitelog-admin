class_name AttendanceList
extends Resource

var date : String
var activeCode : String
var attendees : Array[attendanceEntry]

class attendanceEntry:
	var uid : String
	var date_entry : String
	var date_exit : String

func _init(_id, _code):
	activeCode = _code
	#attendees = parse_users(_users)
	date = Time.get_date_string_from_system()
	attendees = []

func get_data() -> Dictionary:
	return {
		"listDate":date,
		"activeCode":activeCode,
		"attendees":attendees,
	}

func _ready():
	print(_get_property_list())

#func parse_users(user_list : Array[User]) -> Array[Dictionary]:
	#var users : Array[Dictionary] = []
	#for u in user_list:
		#users.push_back(
			#u.get_data()
		#)
	#return users

func add_user( user : User ):
	attendees.push_back(
		user.get_data()
	)
