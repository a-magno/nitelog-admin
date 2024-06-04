extends Control

signal code_generated(code)

## Refresh time in seconds
var qr_refresh_time
@onready var time_left = %TimeLeft
@onready var qr_refresh = %"QR Refresh"
@onready var qr_code_rect = %QRCodeRect

var daily_list : AttendanceList

#region Virtual Functions
func _ready():
	qr_refresh_time = Global.QR_LIFETIME
	qr_refresh.wait_time = qr_refresh_time
	qr_refresh.start(qr_refresh_time)
	time_left.max_value = qr_refresh_time
	check_attendance_list()
	#generate_qr_code()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_left.value = qr_refresh.time_left
#endregion
#region Functions
func generate_qr_code():
	var datetime = Time.get_datetime_string_from_system()
	var code = rand_from_seed(datetime.to_int())
	_set_qr_data(_build_url( {"activeCode" : str(code[0]) } ))
	code_generated.emit(code[0])
	return code[0]

func _set_qr_data( string : String ):
	qr_code_rect.data = str(string).to_utf8_buffer().get_string_from_utf8()

func _build_url( params : Dictionary ) -> String:
	var keys = params.keys()
	var param_string = ""
	for key in keys:
		param_string += "{key}={value}".format( {"key": key, "value": params[key]} )
	return "{url}?{params}".format( {"url": Global.DOMAIN_URI, "params": param_string} )

func check_attendance_list():
	var current_date = Time.get_date_string_from_system()
	var has_list = await Global.query_database(Global.ATTENDANCE_COLLECTION_ID, {"listDate" : current_date}, 1)
	if has_list.is_empty():
		create_atendance_list(str(current_date))
	else:
		Global.active_list_data = has_list[0]["doc_fields"]
		print(Global.active_list_data)
		var new_url = Global.DOMAIN_URI+"?activeCode="+str(Global.active_list_data["activeCode"])
		_set_qr_data(new_url)

	Firebase.Auth.logout()

func create_atendance_list(date_string : String):
	var list = AttendanceList.new(date_string, str(generate_qr_code()) )
	var r = await Global.save_to_database(Global.ATTENDANCE_COLLECTION_ID, list.date, list.get_data())
	
#endregion
#region Signal Functions
func _on_qr_refresh_timeout():
	qr_refresh.stop()
	if not %QRCodeRect.visible:
		return
	update_qr_code()
	set_qr_time(Global.QR_LIFETIME)
	qr_refresh.start(Global.QR_LIFETIME)

func _on_close_pressed():
	get_tree().quit()

func update_qr_code():
	var current_date = Time.get_date_string_from_system()
	var new_code = generate_qr_code()
	var collection: FirestoreCollection = await Firebase.Firestore.collection(Global.ATTENDANCE_COLLECTION_ID)
	var task : FirestoreTask = await collection.update(current_date, {"activeCode":new_code})

func _on_logout_pressed():
	Firebase.Auth.logout()
#endregion

func _on_options_toggled(toggled_on):
	if toggled_on:
		%AdminPanel.show()
	else:
		%AdminPanel.hide()

func _on_open_qr_toggled(toggled_on):
	%"QR Code".visible = toggled_on

func set_qr_time(time):
	qr_refresh.wait_time = time
	time_left.max_value = time
