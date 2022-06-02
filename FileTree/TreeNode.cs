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

	//     public void Traverse(Action<T> action) {
	//     action(Value);
	//     foreach (var child in _children)
	//         child.Traverse(action);
	// }


	public int Size() {
		return Flatten().Count<T>();
	}

	public IEnumerable<T> Flatten() {
		return new[] { Value }.Concat(_children.SelectMany(x => x.Flatten()));
	}

	public static TreeNode<FileItem> GetChildNodeByName(string filename, TreeNode<FileItem> parent) {
		foreach (TreeNode<FileItem> item in parent.Children) {
			if (item.Value.getFileName().Equals(filename)) {
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
			path = node.Value.getFileName() + "/" + path;
			node = node.Parent;
		}

		return path;
		// return node.Value.getFilePath().Replace(rootPath,"");
	}
	public static void AddToTree(FileItem itemToAdd, string path, TreeNode<FileItem> treeRoot) {
		var treeNode = GetChildNodeByPath(path, treeRoot);
		treeNode.AddChild(itemToAdd);
	}

	public static void DeleteNode(TreeNode<T> tree) {
		// tree.Traverse((TreeNode<T> node)=>{
		// 	node.Parent = null;
		// 	node = null;
		// });
		// tree = null;
	}

	// Reference: https://stackoverflow.com/a/8567550
	public static void PrintTree(TreeNode<FileItem> tree, String indent, bool last) {
		// Console.Write(indent + "+- " + tree.Value.getFileName());
		GD.Print(indent + "+- " + tree.Value.getFileName());
		indent += last ? "   " : "|  ";

		for (int i = 0; i < tree.Children.Count; i++) {
			PrintTree(tree.Children[i], indent, i == tree.Children.Count - 1);
		}
	}
}
