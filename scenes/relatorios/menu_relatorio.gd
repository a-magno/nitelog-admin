extends Control

var test_data
var gmt_offset = 3 * 3600
@onready var tree = $PanelContainer/Tree

func populate_with_data():
	tree.clear()
	test_data = await _get_test_data()
	var root = tree.create_item()
	
	for data : Dictionary in test_data["attendees"]:
		#print(data, "\n")
		var child = tree.create_item(root)
		for field in data.keys():
			
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

func _get_test_data():
	var current_date = Time.get_date_string_from_system()
	var data = await Global.query_database(Global.ATTENDANCE_COLLECTION_ID, {"listDate":current_date})
	return data[0]["doc_fields"]

func _lookup_username(uid: String)->String:
	var result = await Global.query_database(Global.USER_COLLECTION_ID, {"userId":uid}, 1)
	return result[0]["doc_fields"]["displayName"]

func _on_button_pressed():
	populate_with_data()
