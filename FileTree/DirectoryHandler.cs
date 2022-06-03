using Godot;
using System;
using System.Collections.Generic;

public class DirectoryHandler : Node {
	#region delegates

	[Signal]
	delegate void virus_deleted();

	[Signal]
	delegate void wrong_file_deleted();

	#endregion


	private string[] folderRoots = {"Documents", "Downloads", "Desktop", "Videos", "Music", "Pictures"};

	private const int fileLimitPerMainDirectory = 50;

	private Tree sceneTree;

	private TreeItem sceneTreeRoot;

	private TreeNode<FileItem> userFileTree; // base logical file tree
	// string rootPath = "C:/Users/aum/Documents/Documents";

	private TreeNode<FileItem> gameFileTree;

	private TreeNode<FileItem> selectedTreeNode;
	private TreeNode<FileItem> selectedItem;

	private TreeNode<FileItem> virusNode;

	private Stack<TreeNode<FileItem>> nodeHistory;

	// string rootPath = "C:/Users/aum/Documents/Documents/IDEAS";
	private string userRoot = ""; // C:/Users/<USERNAME>

	private const string windowsRootDirectory = "C:/Users";
	private const string gameDirectoryRoot = "res://FileTree/GameDirectories";

	private int fileCount = 0;


	private string currentDirectory = ""; // Can be used as the breadcrumb

	private ItemList sceneItemList;

	private Label sceneBreadCrumb;

	private Texture treeItemIcon;

	private Texture[] itemListIcons = new Texture[7];

	private int userTotalFileCount;

	#region PublicMethods

	/* PUBLIC METHODS */
	public override void _Ready() {
		treeItemIcon = (Texture) GD.Load("res://Images/Icons/Folder.png");

		itemListIcons[0] = (Texture) GD.Load("res://Images/Icons/Folder.png");
		itemListIcons[1] = (Texture) GD.Load("res://Images/Icons/Image.png");
		itemListIcons[2] = (Texture) GD.Load("res://Images/Icons/Video.png");
		itemListIcons[3] = (Texture) GD.Load("res://Images/Icons/Audio.png");
		itemListIcons[4] = (Texture) GD.Load("res://Images/Icons/Executable.png");
		itemListIcons[5] = (Texture) GD.Load("res://Images/Icons/File.png");
		itemListIcons[6] = (Texture) GD.Load("res://Images/Icons/File.png");

		// create root path
		if (OS.GetName() == "Windows") {
			userRoot = windowsRootDirectory + "/" + OS.GetEnvironment("USERNAME");
		}

		loadTrees();

		// TreeNode<FileItem>.PrintTree(userFileTree);

		userTotalFileCount = userFileTree.Size();
		GD.Print("User File Tree Size: ", userFileTree.Size());
		GD.Print("Game File Tree Size: ", gameFileTree.Size());

		// merged File Tree
		// mergeFileTrees(gameFileTree, userFileTree, 0.002f);


		// Scene Tree
		sceneTree = (Tree) GetNode("HBoxContainer/VBoxContainer/CSTree");
		updateSceneTree(ref sceneTree, gameFileTree);
		// sceneTreeRoot = sceneTree.CreateItem();
		// sceneTreeRoot.SetText(0, "Directories");

		// createSceneTree(gameFileTree, sceneTreeRoot);


		sceneTree.HideRoot = true;
		GD.Print(OS.GetEnvironment("USERNAME"));

		// Scene Tree
		sceneItemList = (ItemList) GetNode("HBoxContainer/VBoxContainer2/ItemList");

		nodeHistory = new Stack<TreeNode<FileItem>>();

		selectedTreeNode = gameFileTree;

		sceneBreadCrumb = (Label) GetNode("../Controls/HBoxContainer/MarginContainer5/ScrollContainer/Breadcrumb");

		// ---------------------------
		// ----- Signal Connects -----
		Node gameManagerRef = GetTree().Root.GetNode("Node2D/GameManager");
		Node audioManagerRef = GetTree().Root.GetNode("Node2D/AudioManager");

		Connect("virus_deleted", gameManagerRef, "virus_deleted");
		Connect("virus_deleted", audioManagerRef, "virus_deleted");
		Connect("wrong_file_deleted", audioManagerRef, "wrong_file_deleted");

		// ---------------------------
	}

	// Frame by frame method
	public override void _Process(float delta) {
		if (Input.IsActionJustPressed("merge_tree")) {
			mergeFileTrees(gameFileTree, userFileTree, 1.0f);
			updateSceneTree(ref sceneTree, gameFileTree);
			
			// addVirusRandomly("Virus.dtf", false);
			// int distance = TreeNode<FileItem>.DistanceBetweenTwoNodes(selectedTreeNode,virusNode);

			//			addVirus();
		}

		if (Input.IsActionJustPressed("ui_up")) {
			addVirusRandomly("VIRUS.mp4", false);
		}

		// TODO
		// Custom Action, needs to be added in project settings: Assigned to BackSpace, MouseBackButton (4/5)
		if (Input.IsActionJustPressed("ui_back")) {
			onBackButtonPressed();
		}
		else if (Input.IsActionJustPressed("ui_forward")) {
			onForwardButtonPressed();
		}

		if (sceneBreadCrumb.Text != currentDirectory)
			sceneBreadCrumb.Text = currentDirectory;
	}

	public List<string> GetListOfFiles() {
		var listOfFiles = new List<string>();
		userFileTree.Traverse((TreeNode<FileItem> fileNode) => { listOfFiles.Add(fileNode.Value.GetFilePath()); });
		return listOfFiles;
	}

	public TreeNode<FileItem> GetVirusNode() {
		return virusNode;
	}

	public FileItem GetVirusFileItem() {
		return virusNode.Value;
	}

	public int GetUserTotalFileCount() {
		return userTotalFileCount;
	}

	public void Shuffle(IList<int> list) {
		Random rng = new Random();
		int n = list.Count;
		while (n > 1) {
			n--;
			int k = rng.Next(n + 1);
			int value = list[k];
			list[k] = list[n];
			list[n] = value;
		}
	}
	
	// Adds Virus randomly to the Game File Tree
	// if Directory blank, it will add it in randomly.
	public void addVirusRandomly(string nameOfVirus, bool hidden, string directory = "",
		FileItem.FILE_TYPE fileType = FileItem.FILE_TYPE.FILE) {
		// Delete the old virus node.
		if (virusNode != null) {
			TreeNode<FileItem>.DeleteNode(virusNode);
		}
		
		TreeNode<FileItem> dirToAddToo;
		if (directory == "") {
			dirToAddToo = TreeNode<FileItem>.GetRandomDirectory(gameFileTree);
		}
		else {
			dirToAddToo = TreeNode<FileItem>.GetChildNodeByPath(directory, gameFileTree);
		}

		FileItem virusItem;
		if (hidden) {
			FileItem fileToCopy = TreeNode<FileItem>.GetRandomFile(dirToAddToo).Value;
			virusItem = new FileItem(TreeNode<FileItem>.GetPathByNode(dirToAddToo) + "/" + fileToCopy.GetFileName(),
				filename: fileToCopy.GetFileName(), filetype: fileToCopy.GetFileType());
		}
		else {
			virusItem = new FileItem(TreeNode<FileItem>.GetPathByNode(dirToAddToo) + "/" + nameOfVirus,
				filetype: fileType);
		}

		virusItem.SetIsVirus(true);
		virusNode = dirToAddToo.AddChild(virusItem);
		updateSelectedTreeNode(selectedTreeNode);
	}

	#endregion

	#region PrivateMethods

	/* PRIVATE METHODS */

	void loadTrees() {
		// create the root node and start the tree
		// User File Tree
		userFileTree = new TreeNode<FileItem>(new FileItem(userRoot, "", FileItem.FILE_TYPE.DIRECTORY));
		getDirContents(userRoot, userFileTree);

		// Default game file tree
		gameFileTree = new TreeNode<FileItem>(new FileItem(gameDirectoryRoot, "", FileItem.FILE_TYPE.DIRECTORY));
		getDirContents(gameDirectoryRoot, gameFileTree);
	}

	// create mergedTree by Blend B into A. Blend amount is blendValue (range 0-1)
	void mergeFileTrees(TreeNode<FileItem> treeReciever, TreeNode<FileItem> treeGiver, float blendValue) {
		// Clamp value between 0,1 Reference: https://stackoverflow.com/a/20443081
		blendValue = Math.Min(Math.Max(blendValue, 0), 1);

		// get size and find out how many files to bleed into treeA

		// GD.Print("Game Default Tree Size: " + gameDefaultFileTree.Size());
		// GD.Print("User File Tree Size: " + userFileTree.Size());	

		// get number of files to blend.
		// Maybe blend files based on the Main directories?
		// int amountOfFiles = (int) ((float)treeB.Size()*blendValue);

		// mergedFileTree = treeA;

		Random rnd = new Random();
		// Should be main directories (Documents, Downloads, Desktop, etc...)
		foreach (TreeNode<FileItem> mainDir in treeGiver.Children) {
			int numFilesToAdd = (int) Math.Floor(((float) mainDir.Size() * blendValue));
			int numFilesAdded = 0;
			int numOfChildren = mainDir.Children.Count;
			List<TreeNode<FileItem>> childrenUsed = new List<TreeNode<FileItem>>();

			// Get the matching Main Directory from the other tree
			// GD.Print(mainDir.Value.getFileName());

			TreeNode<FileItem> mergedMainDir = TreeNode<FileItem>.GetChildNodeByName(mainDir.Value.GetFileName(), treeReciever);

			// GD.Print(mergedMainDir.Value.getFileName());

			List<int> randomChildren = new List<int>();

			for (int i = 0; i < numOfChildren; i++) {
				randomChildren.Add(i);
			}

			Shuffle(randomChildren);

			
			for (int i = 0; i < numOfChildren; i++) {
			
				mergedMainDir.AddChildNode(mainDir[randomChildren[i]]);
				numFilesAdded += mainDir[randomChildren[i]].Size();

				childrenUsed.Add(mainDir[randomChildren[i]]);

				// numOfChildren = mainDir.Children.Count;
				if (numFilesAdded >= numFilesToAdd) break;
			}

			foreach (var child in childrenUsed) {
				mainDir.RemoveChild(child);
			}
		}

		// TreeNode<FileItem>.PrintTree(treeA, "", true);
	}


	void populateSceneItemList(TreeNode<FileItem> directory) {
		sceneItemList.Clear();

		int i = 0;
		foreach (TreeNode<FileItem> item in directory.Children) {
			sceneItemList.AddItem(item.Value.GetFileName(), itemListIcons[(int) item.Value.GetFileType()]);
			sceneItemList.SetItemTooltipEnabled(i, false);
			i++;
		}

		sceneItemList.SortItemsByText();
	}

	void createSceneTree(TreeNode<FileItem> tree, TreeItem sceneTreeParent, bool retainCollapsed = true) {
		for (int i = 0; i < tree.Children.Count; i++) {
			if (tree[i].Value.IsDirectory()) {
				TreeItem sceneTreeChild = sceneTree.CreateItem(sceneTreeParent);
				sceneTreeChild.SetText(0, tree[i].Value.GetFileName());
				if (retainCollapsed) {
					sceneTreeChild.Collapsed = tree[i].Value.IsCollapsed();
				}
				else {
					sceneTreeChild.Collapsed = true;
				}

				sceneTreeChild.SetTooltip(0, " ");
				sceneTreeChild.SetIcon(0, treeItemIcon);
				sceneTreeChild.SetIconMaxWidth(0, 12);
				// recursive call with child
				createSceneTree(tree[i], sceneTreeChild);
			}
		}
	}


	// Reference: https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
	void getDirContents(String rootPath, TreeNode<FileItem> parent) {
		Directory dir = new Directory();

		if (dir.Open(rootPath) == Error.Ok) {
			dir.ListDirBegin(true, false);
			fileCount = 0;
			addDirContents(dir, parent, rootPath, 0);
		}
		else {
			GD.PushError("An error occurred when trying to access the path.");
		}
	}


	// Reference: https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
	void addDirContents(Directory dir, TreeNode<FileItem> parent, string rootPath, int depth) {
		string filename = dir.GetNext();


		while (filename != "" && fileCount < fileLimitPerMainDirectory) {
			var path = dir.GetCurrentDir() + "/" + filename;

			bool isValidDir = false;

			// int i = 0;
			// Is Valid only in the main directories.
			foreach (string mainFolder in folderRoots) {
				isValidDir = path.Contains(rootPath + "/" + mainFolder);
				if (isValidDir) break;
				// i++;
			}


			if (isValidDir) {
				if (dir.CurrentIsDir()) {
					if (isValidDir) {
						if (filename[0] != '.') {
							Directory subDir = new Directory();
							subDir.Open(path);
							subDir.ListDirBegin(true, false);

							// for logical tree
							TreeNode<FileItem> child = parent.AddChild(new FileItem(path, "", FileItem.FILE_TYPE.DIRECTORY));
							addDirContents(subDir, child, rootPath, depth + 1);
							// if coming out of the recursion, and it is back at the root, set file count to 0, as it is done checking main
							if (depth == 0) fileCount = 0;
						}
					}
				}
				else {
					if (filename[0] != '.') {
						TreeNode<FileItem> child = parent.AddChild(new FileItem(path));
						fileCount += 1;
					}
				}
			}

			filename = dir.GetNext();
		}

		dir.ListDirEnd();
	}

	void updateSelectedTreeNode(TreeNode<FileItem> node) {
		selectedTreeNode = node;
		populateSceneItemList(selectedTreeNode);
		currentDirectory = TreeNode<FileItem>.GetPathByNode(selectedTreeNode);
		// GD.Print(currentDirectory);
		// updateItemList = true;
	}

	void updateSceneTree(ref Tree sceneTree, TreeNode<FileItem> tree) {
		// before clearing, store the collapsed state

		// if tree.get_root() != null:
		// var child = tree.get_root().get_children()
		// while child != null:
		//     # put code here
		//     print(child.get_text(0))
		//     child = child.get_next() 

		// Reference: https://www.reddit.com/r/godot/comments/3eaq8n/comment/ctd8yyo/?utm_source=share&utm_medium=web2x&context=3
		if (sceneTree.GetRoot() != null) {
			var child = sceneTree.GetRoot().GetChildren();
			while (child != null) {
				GD.Print(child.GetText(0));
				child = child.GetNext();
			}
		}

		sceneTree.Clear();

		sceneTreeRoot = sceneTree.CreateItem();
		sceneTreeRoot.SetText(0, "Directories");

		createSceneTree(tree, sceneTreeRoot);
	}

	#endregion

	#region SIGNALS

	/* SIGNALS */
	void onTreeItemSelected() {
		// need to set the current directory string
		TreeItem checkingDir = sceneTree.GetSelected();
		string tempCurrentDir = "";
		while (checkingDir.GetParent() != null) {
			tempCurrentDir = checkingDir.GetText(0) + "/" + tempCurrentDir;
			checkingDir = checkingDir.GetParent();
		}

		TreeNode<FileItem> tempNode = TreeNode<FileItem>.GetChildNodeByPath(currentDirectory, gameFileTree);
		if (tempNode.Value.IsDirectory()) {
			currentDirectory = tempCurrentDir;
			currentDirectory.Remove(currentDirectory.Length - 1, 1); // remove the last '/'


			updateSelectedTreeNode(TreeNode<FileItem>.GetChildNodeByPath(currentDirectory, gameFileTree));
		}

		nodeHistory.Clear();
	}


	// Back Button
	private void onBackButtonPressed() {
		// Replace with function body.

		// var temp = nodeHistory.Pop();
		// nodeHistory.Push(selectedTreeNode);
		// selectedTreeNode = temp;

		// TODO UPDATE CURRENT DIRECTORY STRING		


		if (selectedTreeNode.Parent != null) {
			nodeHistory.Push(selectedTreeNode);
			updateSelectedTreeNode(selectedTreeNode.Parent);
		}
	}


	// Forward Button
	private void onForwardButtonPressed() {
		// Replace with function body.
		if (nodeHistory.Count > 0) {
			updateSelectedTreeNode(nodeHistory.Pop());
		}
	}

	// Item List
	// Double Click or Enter
	private void onItemActivated(int index) {
		string path = currentDirectory + sceneItemList.GetItemText(index);
		// GD.Print(currentDirectory);
		// GD.Print(path);

		var tempNode = TreeNode<FileItem>.GetChildNodeByPath(path, gameFileTree);
		if (tempNode.Value.IsDirectory()) {
			updateSelectedTreeNode(tempNode);
			currentDirectory = path + "/";
		}

		nodeHistory.Clear();
	}


	private void onItemListItemSelected(int index) {
		string path = currentDirectory + sceneItemList.GetItemText(index);
		selectedItem = TreeNode<FileItem>.GetChildNodeByPath(path, gameFileTree);
		// GD.Print(selectedItem.Value.getFileName() + " is " + (selectedItem.Value.IsVirus() ? "" : "not ") + "A Virus");
	}

	private void onDeletePressed() {
		// GD.Print("item to delete: " + selectedItem.Value.getFileName());
		// TreeNode<FileItem>.DeleteNode(selectedItem);
		// updateSceneTree(ref sceneTree, gameFileTree);
		// populateSceneItemList(selectedTreeNode);

		// if nothing selected then dont do anything
		if (selectedItem == null) return;

		if (selectedItem.Value.IsVirus()) {
			virusDeleted();
		}
		else {
			wrongItemDeleted();
		}


		TreeNode<FileItem> nodeToDelete = selectedItem;
		if (selectedItem.Value.IsDirectory()) {
			if (selectedItem == selectedTreeNode) {
				selectedTreeNode = selectedTreeNode.Parent;
			}

			selectedItem = selectedItem.Parent;
		}

		TreeNode<FileItem>.DeleteNode(nodeToDelete);
		updateSceneTree(ref sceneTree, gameFileTree);
		populateSceneItemList(selectedTreeNode);
	}

	private void onTreeItemCollapsed(object item) {
		// Replace with function body.
		// GD.Print("Collapsed: ", ((TreeItem) item).GetText(0));
		TreeItem checkingDir = (TreeItem) item;
		string itemDir = "";
		while (checkingDir.GetParent() != null) {
			itemDir = checkingDir.GetText(0) + "/" + itemDir;
			checkingDir = checkingDir.GetParent();
		}

		TreeNode<FileItem> treeNode = TreeNode<FileItem>.GetChildNodeByPath(currentDirectory, gameFileTree);

		treeNode.Value.SetIsCollapsed(checkingDir.Collapsed);
	}


	private void onItemListNothingSelected() {
		selectedItem = null;
	}

	/* Emmiting Signals */
	private void virusDeleted() {
		EmitSignal(nameof(virus_deleted));
	}

	private void wrongItemDeleted() {
//		EmitSignal("friendly_deleted");
		EmitSignal(nameof(wrong_file_deleted));
	}

	#endregion
}
