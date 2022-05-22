#  Script created by Gamet (github.com/Gamestus), some code remixed from CSGExport plugin by Xtremezero (github.com/mohammedzero43).
#  This plugin adds an export button when selecting NavigationMeshInstance Node.
#  Exported object name ends with "-navmesh" so Godot will import it as navigation mesh automatically*.
# *You should import .obj file as Scene.
tool
extends EditorPlugin

var export_button = Button.new()
var navmesh_instance_node = null
var object_name = ""
var obj_content = ""
var fdialog: FileDialog


func _ready() -> void:
	export_button.connect("pressed",self,"_on_export_pressed")


func _enter_tree() -> void:
	get_editor_interface().get_selection().connect("selection_changed",self,"_on_selection_changed")
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU,export_button)
	export_button.text = "Export NavMesh as .obj"


func _exit_tree() -> void:
	export_button.queue_free()
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU,export_button)


func _on_selection_changed() -> void:
	var selected = get_editor_interface().get_selection().get_selected_nodes()
	
	if selected.size() == 1 and selected[0] is NavigationMeshInstance:
		object_name = selected[0].name
		navmesh_instance_node = selected[0]
		export_button.visible = true
	else:
		export_button.visible = false


func _on_export_pressed() -> void:
	export_mesh()


func export_mesh() -> void:
	obj_content = ""
	var nav_mesh = navmesh_instance_node.navmesh
	
	obj_content += "o " + object_name + "-navmesh\n";
	
	#add verticies
	for ver in nav_mesh.vertices:
		obj_content += "v %f %f %f\n" % [ver.x,ver.y,ver.z]
	
	for pol in nav_mesh.polygons:
		obj_content += "f %d %d %d\n" % [pol[0] + 1,pol[1] + 1,pol[2] + 1]
		
		
	#Select file destination
	fdialog = FileDialog.new()
	fdialog.mode = FileDialog.MODE_OPEN_DIR
	fdialog.access = FileDialog.ACCESS_RESOURCES
	fdialog.show_hidden_files = false
	fdialog.window_title = "Export mesh"
	fdialog.resizable = true
	
	get_editor_interface().get_editor_viewport().add_child(fdialog)
	fdialog.connect("dir_selected", self, "on_file_dialog_ok", [])
	fdialog.popup_centered(Vector2(700, 450))


func on_file_dialog_ok(path: String):
	var objfile = File.new()
	objfile.open(path+"/"+object_name+".obj", File.WRITE)
	objfile.store_string(obj_content)
	objfile.close()
	
	print("NavMesh Exported!")
	get_editor_interface().get_resource_filesystem().scan()
