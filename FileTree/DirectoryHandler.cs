using Godot;
using System;
using System.Collections.Generic;

public class DirectoryHandler : Node {
    [Signal]
    delegate void virus_deleted();


    string[] folderRoots = { "Documents", "Downloads", "Desktop", "Videos", "Music", "Pictures" };

    const int fileLimitPerMainDirectory = 5000;

    private Tree sceneTree;

    private TreeItem sceneTreeRoot;

    TreeNode<FileItem> userFileTree; // base logical file tree
                                     // string rootPath = "C:/Users/aum/Documents/Documents";

    TreeNode<FileItem> gameFileTree;

    TreeNode<FileItem> selectedTreeNode;
    TreeNode<FileItem> selectedItem;

    TreeNode<FileItem> virusNode;

    Stack<TreeNode<FileItem>> nodeHistory;

    // string rootPath = "C:/Users/aum/Documents/Documents/IDEAS";
    string userRoot = ""; // C:/Users/<USERNAME>

    const string windowsRootDirectory = "C:/Users";
    const string gameDirectoryRoot = "res://FileTree/GameDirectories";

    int fileCount = 0;


    string currentDirectory = ""; // Can be used as the breadcrumb

    ItemList sceneItemList;

    Label sceneBreadCrumb;

    int debugTreeDepthCounter = 0;

    Texture treeItemIcon;

    Texture[] itemListIcons = new Texture[7];

    private Node gameManagerRef;

    private string mainDirBeingRead = "";

    public override void _Ready() {
        treeItemIcon = (Texture)GD.Load("res://Images/Icons/Folder.png");

        itemListIcons[0] = (Texture)GD.Load("res://Images/Icons/Folder.png");
        itemListIcons[1] = (Texture)GD.Load("res://Images/Icons/Image.png");
        itemListIcons[2] = (Texture)GD.Load("res://Images/Icons/Video.png");
        itemListIcons[3] = (Texture)GD.Load("res://Images/Icons/Audio.png");
        itemListIcons[4] = (Texture)GD.Load("res://Images/Icons/Executable.png");
        itemListIcons[5] = (Texture)GD.Load("res://Images/Icons/File.png");
        itemListIcons[6] = (Texture)GD.Load("res://Images/Icons/File.png");

        // create root path
        if (OS.GetName() == "Windows") {
            userRoot = windowsRootDirectory + "/" + OS.GetEnvironment("USERNAME");
        }

        loadTrees();

        // TreeNode<FileItem>.PrintTree(userFileTree);

        GD.Print("User File Tree Size: ", userFileTree.Size());
        GD.Print("Game File Tree Size: ", gameFileTree.Size());

        // merged File Tree
        // mergeFileTrees(gameFileTree, userFileTree, 0.002f);


        // Scene Tree
        sceneTree = (Tree)GetNode("HBoxContainer/VBoxContainer/CSTree");
        updateSceneTree(ref sceneTree, gameFileTree);
        // sceneTreeRoot = sceneTree.CreateItem();
        // sceneTreeRoot.SetText(0, "Directories");

        // createSceneTree(gameFileTree, sceneTreeRoot);


        sceneTree.HideRoot = true;
        GD.Print(OS.GetEnvironment("USERNAME"));

        // Scene Tree
        sceneItemList = (ItemList)GetNode("HBoxContainer/VBoxContainer2/ItemList");

        nodeHistory = new Stack<TreeNode<FileItem>>();

        selectedTreeNode = gameFileTree;

        sceneBreadCrumb = (Label)GetNode("../Controls/HBoxContainer/MarginContainer5/Breadcrumb");

        gameManagerRef = GetTree().Root.GetNode("Node2D/GameManager");
        Connect("virus_deleted", gameManagerRef, "virus_deleted");
    }

    // Frame by frame method
    public override void _Process(float delta) {
        if (Input.IsActionJustPressed("merge_tree")) {
            // GD.Print("8");
            mergeFileTrees(gameFileTree, userFileTree, 1.0f);
            updateSceneTree(ref sceneTree, gameFileTree);

            //			addVirus();
        }

        if (Input.IsActionJustPressed("ui_up")) {
            addVirusRandomly("VIRUS.mp4", false);
        }

        // TODO
        // Custom Action, needs to be added in project settings: Assigned to BackSpace, MouseBackButton (4/5)
        if (Input.IsActionJustPressed("ui_back")) {
            onBackButtonPressed();
        } else if (Input.IsActionJustPressed("ui_forward")) {
            onForwardButtonPressed();
        }

        if (sceneBreadCrumb.Text != currentDirectory)
            sceneBreadCrumb.Text = currentDirectory;
    }

    void loadTrees() {
        // create the root node and start the tree
        // User File Tree
        userFileTree = new TreeNode<FileItem>(new FileItem(userRoot, "", FileItem.FILE_TYPE.DIRECTORY));
        getDirContents(userRoot, userFileTree);

        // Default game file tree
        gameFileTree = new TreeNode<FileItem>(new FileItem(gameDirectoryRoot, "", FileItem.FILE_TYPE.DIRECTORY));
        getDirContents(gameDirectoryRoot, gameFileTree);
    }

    // Adds Virus randomly to the Game File Tree
    // if Directory blank, it will add it in randomly.
    void addVirusRandomly(string nameOfVirus, bool hidden, string directory = "",
        FileItem.FILE_TYPE fileType = FileItem.FILE_TYPE.FILE) {
        TreeNode<FileItem> dirToAddToo;
        if (directory == "") {
            dirToAddToo = TreeNode<FileItem>.GetRandomDirectory(gameFileTree);
        } else {
            dirToAddToo = TreeNode<FileItem>.GetChildNodeByPath(directory, gameFileTree);
        }

        FileItem virusItem;
        if (hidden) {
            FileItem fileToCopy = TreeNode<FileItem>.GetRandomFile(dirToAddToo).Value;
            virusItem = new FileItem(TreeNode<FileItem>.GetPathByNode(dirToAddToo) + "/" + fileToCopy.getFileName(),
                filename: fileToCopy.getFileName(), filetype: fileToCopy.getFileType());
        } else {
            virusItem = new FileItem(TreeNode<FileItem>.GetPathByNode(dirToAddToo) + "/" + nameOfVirus,
                filetype: fileType);
        }

        virusItem.setIsVirus(true);
        dirToAddToo.AddChild(virusItem);
        updateSelectedTreeNode(selectedTreeNode);
    }


    // create mergedTree by Blend B into A. Blend amount is blendValue (range 0-1)
    void mergeFileTrees(TreeNode<FileItem> treeA, TreeNode<FileItem> treeB, float blendValue) {
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
        foreach (TreeNode<FileItem> mainDir in treeB.Children) {
            int numFilesToAdd = (int)Math.Ceiling(((float)mainDir.Size() * blendValue));
            int numFilesAdded = 0;
            int numOfChildren = mainDir.Children.Count;
            List<int> childUsed = new List<int>();

            // Get the matching Main Directory from the other tree
            // GD.Print(mainDir.Value.getFileName());

            var mergedMainDir = TreeNode<FileItem>.GetChildNodeByName(mainDir.Value.getFileName(), treeA);

            // GD.Print(mergedMainDir.Value.getFileName());

            while (numFilesAdded < numFilesToAdd) {
                int randomChild = rnd.Next(numOfChildren);

                mergedMainDir.AddChildNode(mainDir[randomChild]);
                numFilesAdded += mainDir[randomChild].Size();
                childUsed.Add(randomChild);
            }
        }

        // TreeNode<FileItem>.PrintTree(treeA, "", true);
    }

    void populateSceneItemList(TreeNode<FileItem> directory) {
        sceneItemList.Clear();

        int i = 0;
        foreach (TreeNode<FileItem> item in directory.Children) {
            sceneItemList.AddItem(item.Value.getFileName(), itemListIcons[(int)item.Value.getFileType()]);
            sceneItemList.SetItemTooltipEnabled(i, false);
            i++;
        }

        sceneItemList.SortItemsByText();
    }

    void createSceneTree(TreeNode<FileItem> tree, TreeItem sceneTreeParent) {
        for (int i = 0; i < tree.Children.Count; i++) {
            if (tree[i].Value.isDirectory()) {
                TreeItem sceneTreeChild = sceneTree.CreateItem(sceneTreeParent);
                sceneTreeChild.SetText(0, tree[i].Value.getFileName());
                sceneTreeChild.Collapsed = true;
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
            mainDirBeingRead = "";
            fileCount = 0;
            addDirContents(dir, parent, rootPath);
            mainDirBeingRead = "";
                
        } else {
            GD.PushError("An error occurred when trying to access the path.");
        }
    }




    // Reference: https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
    void addDirContents(Directory dir, TreeNode<FileItem> parent, string rootPath) {
        string filename = dir.GetNext();


        while (filename != "" && fileCount < fileLimitPerMainDirectory) {
            var path = dir.GetCurrentDir() + "/" + filename;

            bool isValidDir = false;
            int i = 0;
            // Is Valid only in the main directories.
            foreach (string mainFolder in folderRoots) {
                isValidDir = path.Contains(rootPath + "/" + mainFolder);
                if (isValidDir) break;
                i++;
            }


            if (isValidDir) {
                if (mainDirBeingRead == "") mainDirBeingRead = folderRoots[i];

                if (mainDirBeingRead != folderRoots[i]) {
                    GD.Print(rootPath + ": " + mainDirBeingRead + "   File Count : " + fileCount);
					
                    mainDirBeingRead = folderRoots[i];

                    fileCount = 0;

                }

                if (dir.CurrentIsDir()) {
                    if (isValidDir) {
                        if (filename[0] != '.') {
                            Directory subDir = new Directory();
                            subDir.Open(path);
                            subDir.ListDirBegin(true, false);

                            // for logical tree
                            TreeNode<FileItem> child =
                                parent.AddChild(new FileItem(path, "", FileItem.FILE_TYPE.DIRECTORY));
                            addDirContents(subDir, child, rootPath);
                        }
                    }
                } else {
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
        sceneTree.Clear();

        sceneTreeRoot = sceneTree.CreateItem();
        sceneTreeRoot.SetText(0, "Directories");

        createSceneTree(tree, sceneTreeRoot);
    }


    public TreeNode<FileItem> getVirusNode() {
        return virusNode;
    }

    public FileItem getVirusFileItem() {
        return virusNode.Value;
    }

    /* SIGNALS */

    #region SIGNALS

    void onTreeItemSelected() {
        // need to set the current directory string
        TreeItem checkingDir = sceneTree.GetSelected();
        string tempCurrentDir = "";
        while (checkingDir.GetParent() != null) {
            tempCurrentDir = checkingDir.GetText(0) + "/" + tempCurrentDir;
            checkingDir = checkingDir.GetParent();
        }

        TreeNode<FileItem> tempNode = TreeNode<FileItem>.GetChildNodeByPath(currentDirectory, gameFileTree);
        if (tempNode.Value.isDirectory()) {
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
        if (tempNode.Value.isDirectory()) {
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
        if (selectedItem.Value.IsVirus()) {
            deleteVirus();
        }
    }

    /* Emmiting Signals */
    private void deleteVirus() {
        EmitSignal(nameof(virus_deleted));
    }

    private void deletedWrongItem() {
        EmitSignal("friendly_deleted");
    }

    #endregion
}
