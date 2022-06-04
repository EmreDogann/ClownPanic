using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using Godot;

// Reference: https://stackoverflow.com/a/10442244
public class TreeNode<T> {
	private readonly T _value;
	private readonly List<TreeNode<T>> _children = new List<TreeNode<T>>();


	public TreeNode(T value) {
		_value = value;
	}

	public TreeNode<T> this[int i] {
		get { return _children[i]; }
	}

	public TreeNode<T> Parent { get; private set; }

	public T Value {
		get { return _value; }
	}


	public ReadOnlyCollection<TreeNode<T>> Children {
		get { return _children.AsReadOnly(); }
	}

	public TreeNode<T> AddChild(T value) {
		var node = new TreeNode<T>(value) { Parent = this };
		_children.Add(node);
		return node;
	}

	public void AddChildNode(TreeNode<T> child) {
		child.Parent = this; // change the parent to this, usefull when coming from another tree
		_children.Add(child);
	}

	public TreeNode<T>[] AddChildren(params T[] values) {
		return values.Select(AddChild).ToArray();
	}

	public bool RemoveChild(TreeNode<T> node) {
		return _children.Remove(node);
	}

	public void Traverse(Action<TreeNode<T>> action) {
		action(this);
		foreach (var child in _children)
			child.Traverse(action);
	}

	public int ChildrenCount() {
		return _children.Count;
	}

	public int Depth() {
		int depthCount = 0;
		var parent = Parent;

		while (parent != null) {
			depthCount += 1;
			parent = parent.Parent;
		}

		return depthCount;
	}

	public int Size() {
		return Flatten().Count<T>();
	}

	public IEnumerable<T> Flatten() {
		return new[] { Value }.Concat(_children.SelectMany(x => x.Flatten()));
	}

	// IDEK did this while half asleep, I think it works.
	// returns -1 if fails
	public static int DistanceBetweenTwoNodes(TreeNode<FileItem> currentNode, TreeNode<FileItem> targetNode) {
		int distance = -1;

		if (!currentNode.Value.IsDirectory()) {
			currentNode = currentNode.Parent;
		}

		if (!targetNode.Value.IsDirectory()) {
			targetNode = targetNode.Parent;
		}

		if (targetNode == null || currentNode == null) {
			GD.PrintErr("Cannot Find Distances, the passed values are not directories, neither are there parents.");
			return -1;
		}


		// Root would be "" First Items would be Main Directories (ie. "Documents" or "Downloads")
		string currentNodePath = GetPathByNode(currentNode);
		string targetNodePath = GetPathByNode(targetNode);

		// Removing the last '/'
		// if (currentNodePath.Length > 0)
		//     currentNodePath = currentNodePath.Remove(currentNodePath.Length - 1);
		if (targetNodePath.Length > 0)
			targetNodePath = targetNodePath.Remove(targetNodePath.Length - 1);



		var splitCurrentNodePath = currentNodePath.Split("/");
		var splitTargetNodePath = targetNodePath.Split("/");

		int lcaIndex = -1;
		string lcaPath = "";


		int minNumberOfDir = Math.Min(splitCurrentNodePath.Length, splitTargetNodePath.Length);

		for (int i = 0; i < minNumberOfDir; i++) {
			if (splitCurrentNodePath[i] == "" || splitTargetNodePath[i] == "") {
				lcaPath += "";
			}

			if (splitCurrentNodePath[i] == splitTargetNodePath[i]) {
				lcaPath += splitCurrentNodePath[i] + "/";
			}
		}

		// GD.Print("_________________________________");
		// GD.Print("Current Path: " + currentNodePath);
		// GD.Print("Target Path:  " + targetNodePath);
		// GD.Print("Lca Path:  " + lcaPath);


		// if (lcaPath == "") {
		// 	distance = Math.Max(splitCurrentNodePath.Length, splitTargetNodePath.Length);
		// } else {

		// remove '/' from lca path
		if (lcaPath.Length > 0) {
			if (lcaPath[lcaPath.Length - 1] == '/') {
				lcaPath = lcaPath.Remove(lcaPath.Length - 1);
			}
		}

		// Remove the LCA, giving the remainging paths
		if (lcaPath.Length > 0) {
			currentNodePath = currentNodePath.Replace(lcaPath, "");
			targetNodePath = targetNodePath.Replace(lcaPath, "");
		}

		int targetDistance = 0;
		if (targetNodePath == "") {
			targetDistance = 0;
		} else {
			var temp = targetNodePath.Split("/");
			foreach (string s in temp) {
				if (s != "") {
					targetDistance += 1;
				}
			}
		}

		int currentDistance = 0;
		if (currentNodePath == "") {
			currentDistance = 0;
		} else {
			var temp = currentNodePath.Split("/");
			foreach (string s in temp) {
				if (s != "") {
					currentDistance += 1;
				}
			}
		}

		distance = targetDistance + currentDistance;

		// }

		// GD.Print("Distance:  " + distance);
		// GD.Print("_________________________________");

		return distance;
	}

	public static TreeNode<FileItem> GetChildNodeByName(string filename, TreeNode<FileItem> parent) {
		foreach (TreeNode<FileItem> item in parent.Children) {
			if (item.Value.GetFileName().Equals(filename)) {
				return item;
			}
		}

		return null;
	}

	// Pass in path after root (IE. Start with Document/ or Downloads/)
	public static TreeNode<FileItem> GetChildNodeByPath(string path, TreeNode<FileItem> parent) {
		string[] splitPath = path.Split("/");

		var childNode = parent;
		foreach (string dir in splitPath) {
			var tempNode = GetChildNodeByName(dir, childNode);
			if (tempNode == null) {
				break;
			} else {
				childNode = tempNode;
			}
		}

		return childNode;
	}

	// Get path in string, starts after root (IE. Start with Document/ or Downloads/)
	public static string GetPathByNode(TreeNode<FileItem> node) {
		string path = "";

		while (node.Parent != null) {
			path = node.Value.GetFileName() + "/" + path;
			node = node.Parent;
		}

		return path;
		// return node.Value.getFilePath().Replace(rootPath,"");
	}

	public static List<TreeNode<FileItem>> GetDirectoryChildren(TreeNode<FileItem> tree) {
		List<TreeNode<FileItem>> children = new List<TreeNode<FileItem>>();
		foreach (var treeChild in tree._children) {
			if (treeChild.Value.IsDirectory()) {
				children.Add(treeChild);
			}
		}

		return children;
	}

	// Gets File (ie. Non-Directory) children
	public static List<TreeNode<FileItem>> GetFileChildren(TreeNode<FileItem> tree) {
		List<TreeNode<FileItem>> children = new List<TreeNode<FileItem>>();
		foreach (var treeChild in tree._children) {
			if (!treeChild.Value.IsDirectory()) {
				children.Add(treeChild);
			}
		}

		return children;
	}

	// get random directory
	public static TreeNode<FileItem> GetRandomDirectory(TreeNode<FileItem> tree, int depthPercentage = 80) {
		Random rnd = new Random();


		TreeNode<FileItem> randomDirectory = tree;

		// keep going if the 
		bool goSubDir = tree.Value.IsDirectory();

		while (goSubDir) {
			List<TreeNode<FileItem>> dirChildren = GetDirectoryChildren(randomDirectory);

			if (dirChildren.Count > 0) {
				int randomChildIndex = rnd.Next(dirChildren.Count);
				randomDirectory = dirChildren[randomChildIndex];

				goSubDir = rnd.Next(100) < depthPercentage;
			} else {
				goSubDir = false;
			}
		}

		return randomDirectory;
	}

	// Get Random File (Non Directory)
	public static TreeNode<FileItem> GetRandomFile(TreeNode<FileItem> tree) {
		Random rnd = new Random();

		List<TreeNode<FileItem>> fileChildren = GetDirectoryChildren(tree);

		int randomChildIndex = rnd.Next(fileChildren.Count);

		return fileChildren[randomChildIndex];
	}


	// by path and root
	public static void AddToTree(FileItem itemToAdd, string path, TreeNode<FileItem> treeRoot) {
		var treeNode = GetChildNodeByPath(path, treeRoot);
		treeNode.AddChild(itemToAdd);
	}


	public static void DeleteNode(TreeNode<FileItem> tree) {
		// Delete all the file Children
		foreach (var child in GetFileChildren(tree)) {
			DeleteNode(child);
		}

		// delete the directories
		foreach (var child in GetDirectoryChildren(tree)) {
			DeleteNode(child);
		}

		// Dont remove if there is no parent
		if (tree.Parent != null)
			tree.Parent.RemoveChild(tree);
	}

	// Reference: https://stackoverflow.com/a/8567550
	public static void PrintTree(TreeNode<FileItem> tree, String indent = "", bool last = true) {
		// Console.Write(indent + "+- " + tree.Value.getFileName());
		GD.Print(indent + "+- " + tree.Value.GetFileName());
		indent += last ? "   " : "|  ";

		for (int i = 0; i < tree.Children.Count; i++) {
			PrintTree(tree.Children[i], indent, i == tree.Children.Count - 1);
		}
	}
}
