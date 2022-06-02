extends TreeItem

enum FILE_TYPES{DIRECTORY, IMAGE, DOCUMENT}

var filepath
var filetype

var filesize # may be unused
	

func set_filepath(path : String):
    filepath = path

func set_filetype(type: int):
    if type <= FILE_TYPES.size():
        filetype =  type
    else:
        print("INVALID FILE TYPE: SETTING TYPE TO DOCUMENT - Thrown by FileItem.gd")
        filetype = FILE_TYPES.DOCUMENT