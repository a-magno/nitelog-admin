extends Control

var test_data
var gmt_offset = 3 * 3600
@onready var tree = $PanelContainer/Tree

# Called when the node enters the scene tree for the first time.
func _ready():
	test_data = await _get_test_data()
	var root = tree.create_item()
	for data : Dictionary in test_data["attendees"]:
		#print(data, "\n")
		var child = tree.create_item(root)
		for field in data.keys():
			#print(data[field])
			var value
			if data[field] is Dictionary and data[field].has("hour"):
				var datetime_unix = Time.get_unix_time_from_datetime_dict(data[field]) - gmt_offset
				var datetime = Time.get_time_string_from_unix_time(datetime_unix)
				value = "" if data[field] == null else datetime
			elif field == "userId":
				value = await _lookup_username(data[field])
			else:
				value = "" if data[field] == null else data[field]
			child.set_text(data.keys().find(field), str(value))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _get_test_data():
	#var auth = Firebase.Auth.auth
	var current_date = "2024-05-31"
	#if auth.localid:
	var data = await Global.query_database(Global.ATTENDANCE_COLLECTION_ID, {"listDate":current_date})
	return data[0]["doc_fields"]

func _lookup_username(uid: String)->String:
	var result = await Global.query_database(Global.USER_COLLECTION_ID, {"userId":uid}, 1)
	return result[0]["doc_fields"]["displayName"]
