extends Control

@onready var title_label: Label = $%Label
@onready var host_input: LineEdit = $%HostInput
@onready var start_server_button: Button = $%StartServerButton
@onready var start_client_button: Button = $%StartClientButton

var window_width: int = 1200

func _ready() -> void:
	start_server_button.pressed.connect(_on_server_button_pressed)
	start_client_button.pressed.connect(_on_client_button_pressed)

	var args = Array(OS.get_cmdline_args())
	if args.has("-s"):
		title_label.text = "Server"
		DisplayServer.window_set_position(Vector2i(50, 100))
		_on_server_button_pressed()
	elif args.has("-c"):
		var c_index = args.find("-c")
		var client_number = 0
		if c_index + 1 < args.size():
			client_number = int(args[c_index + 1])
		title_label.text = "Client " + str(client_number)
		DisplayServer.window_set_position(Vector2i(100 + client_number * window_width, 100))
		# Wait briefly for server to be ready
		await get_tree().create_timer(1.0).timeout
		_on_client_button_pressed()

func get_server_and_port(host_text: String) -> Array[String]:
	if host_text.find(":") != -1:
		var array: Array[String]
		array.assign(host_text.split(":"))
		return array
	return [host_text, "42069"]

func _on_server_button_pressed() -> void:
	var server_and_port = get_server_and_port(host_input.text)
	NetworkHandler.start_server("0.0.0.0", int(server_and_port[1]))
	start_server_button.release_focus()


func _on_client_button_pressed() -> void:
	var server_and_port = get_server_and_port(host_input.text)
	NetworkHandler.start_client(server_and_port[0], int(server_and_port[1]))
	start_client_button.release_focus()
