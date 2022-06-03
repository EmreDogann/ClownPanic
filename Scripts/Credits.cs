using System;
using Godot;
using System.Collections.Generic;
using System.Linq;

public class Credits : RichTextLabel {
	[Signal]
	delegate void terminal_game_over();

	private DirectoryHandler filesDirectoryReference;
	private LinkedList<string> fileDirectoryList;
	private String rootDirectory;

	private const int MAX_CHARACTER_LIMIT = 5000;
	private const float gameOverTimeLimit = 1.0f; // Game Over Time Limit in seconds
	private float timer;
	private float timerIncrement;

	private bool is_blink_on = true;
	private float blinkingCooldown = 0.75f;

	private bool is_game_over = false;

	private int numberOfFilesDeleted = 1;

	private DynamicFont bigFont = GD.Load<DynamicFont>("res://Fonts/DefaultDynamicFont-Big.tres");

	public override void _Ready() {
		filesDirectoryReference = (DirectoryHandler)GetTree().Root
			.GetNode("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files");

		var fileExplorerWindowIndex = GetTree().Root.GetNode("Node2D/CanvasLayer/FileExplorer").GetIndex();
		GetTree().Root.GetNode("Node2D/CanvasLayer").CallDeferred("move_child", GetTree().Root.GetNode("Node2D/CanvasLayer/Terminal"), fileExplorerWindowIndex);

		fileDirectoryList = new LinkedList<string>(filesDirectoryReference.GetListOfFiles());

		rootDirectory = fileDirectoryList.ElementAt(0);

		timerIncrement = gameOverTimeLimit / filesDirectoryReference.GetUserTotalFileCount();

		Node gameManagerRef = GetTree().Root.GetNode("Node2D/GameManager");

		Connect("terminal_game_over", gameManagerRef, "terminal_game_over");
	}

	public override void _Process(float delta) {
		timer += delta;

		if (timer > timerIncrement && !is_game_over) {
			addDebugStatementToTerminal();
			timer = 0;
		} else if (timer > blinkingCooldown) {
			blinkLastText();
			timer = 0;
		}
	}

	public bool IsGameOver() {
		return numberOfFilesDeleted >= filesDirectoryReference.GetUserTotalFileCount();
	}

	public void addDebugStatementToTerminal() {
		if (fileDirectoryList.Count > 1) {
			var finalFileLocation = fileDirectoryList.First.Next.Value.Replace(rootDirectory, "");

			String textToAdd = rootDirectory + "> [color=yellow](" + numberOfFilesDeleted + "/" + (filesDirectoryReference.GetUserTotalFileCount() - 1) + ")[/color] [color=red]DELETING[/color] [color=green]" + finalFileLocation + "[/color]\n";

			BbcodeText += textToAdd;
			fileDirectoryList.Remove(fileDirectoryList.First.Next);

			numberOfFilesDeleted += 1;
		}

		if (IsGameOver()) {
			BbcodeText += "[color=yellow]GAME OVER - go home now![/color]";
			EmitSignal(nameof(terminal_game_over));
			is_game_over = true;
		}

		if (BbcodeText.Count() > MAX_CHARACTER_LIMIT) {
			BbcodeText = BbcodeText.Remove(0, BbcodeText.Count() - MAX_CHARACTER_LIMIT);
		}
	}

	public void blinkLastText() {
		if (is_blink_on) {
			BbcodeText = BbcodeText.Remove(BbcodeText.LastIndexOf('\n') + 1);
			is_blink_on = false;
		} else {
			BbcodeText += "[color=yellow]GAME OVER - go home now![/color]";
			is_blink_on = true;
		}
	}
}
