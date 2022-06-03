using Godot;
using System;

public class FileItem {

	// TYPES
	public enum FILE_TYPE {
		DIRECTORY, // 0
		IMAGE, // 1
		VIDEO, // 2
		AUDIO, // 3
		EXECUTABLE, // 4
		FILE, // 5
		NULL // 6
	}

	const string EXTENSIONS_IMAGE = ".jpeg.jpg.png.gif.tiff.psd.pdf.eps.ai.indd.raw.bmp.ico.apng.avif.jfif.pjepg.pjp.png.svg.webp.tif.";
	const string EXTENSIONS_VIDEO = ".3g2.3gp.amv.asf.avi.flv.f4v.f4p.f4a.4fb.gifv.m4v.mkv.mng.mov.qt.mp4.mp2.mpeg.mpe.mpv.m2v.mts.m2ts.ts.mxf.nsv.ogv.ogg.rm.rmvb.roq.svi.viv.vob.webm.wmv.yuv"; // TODO Write these out again
	const string EXTENSIONS_AUDIO = ".3gp.aa.aac.aax.act.aiff.alac.amr.ape.au.awb.dss.dvf.flac.gsm.iklax.ivs.m4a.m4b.mmf.mp3.mpc.msv.nmf.ogg.oga.mogg.opus.ra.rm.raw.rf64.tta.voc.vox.wav.wma.wv.webm.8svx.cda";

	const string EXTENSIONS_EXECUTABLE = ".exe.bat.cgi.msi.cmd.bin.appimage.app.command.sh";

	// MEMBERS
	// private string filename;
	private string filepath;
	private FILE_TYPE filetype;

	private string filename;

	private bool isVirus = false;

	private bool isCollapsed = true;

	// METHODS

	// PUBLIC

	public FileItem(string filepath, string filename = "", FILE_TYPE filetype = FILE_TYPE.NULL) {
		this.filepath = filepath;

		if (filename == "") {
			determineFileName();
		} else {
			this.filename = filename;
		}

		if (filetype == FILE_TYPE.NULL) {
			determineFileType();
		} else {
			this.filetype = filetype;
		}
	}

	public string GetFilePath() {
		return filepath;
	}

	public string GetFileName() {
		if (filename == "") {
		}
		return filename;
	}

	public FILE_TYPE GetFileType() {
		return filetype;
	}

	public bool IsDirectory() {
		return filetype == FILE_TYPE.DIRECTORY;
	}
	public bool IsExecutable() {
		return filetype == FILE_TYPE.EXECUTABLE;
	}
	public bool IsVirus() {
		return isVirus;
	}

	public bool IsCollapsed() {
		return isCollapsed;
	}

	public void SetIsCollapsed() {
		
	}

	public void SetIsVirus(bool isVirus) {
		this.isVirus = isVirus;
	}


	// PRIVATE
	private void determineFileName() {
		string[] splitPath = filepath.Split("/");
		filename = splitPath[splitPath.Length - 1];
	}

	private void determineFileType() {
		string[] splitName = filename.Split(".");

		// no extension, therefore directory. Little iffy on this.
		if (splitName.Length == 1)
			filetype = FILE_TYPE.DIRECTORY;
		else if (EXTENSIONS_IMAGE.Contains(splitName[1]))
			filetype = FILE_TYPE.IMAGE;
		else if (EXTENSIONS_AUDIO.Contains(splitName[1]))
			filetype = FILE_TYPE.AUDIO;
		else if (EXTENSIONS_VIDEO.Contains(splitName[1]))
			filetype = FILE_TYPE.VIDEO;
		else if (EXTENSIONS_EXECUTABLE.Contains(splitName[1]))
			filetype = FILE_TYPE.EXECUTABLE;
		else
			filetype = FILE_TYPE.FILE;
	}


}
