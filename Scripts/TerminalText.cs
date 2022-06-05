using System;
using Godot;
using System.Collections.Generic;
using System.Linq;

public class TerminalText : RichTextLabel {
	[Signal]
	delegate void terminal_game_over();
	
	private Node gameManagerRef;

	private DirectoryHandler filesDirectoryReference;
	private LinkedList<string> fileDirectoryList;
	private String rootDirectory;

	private bool is_terminal_active = false;

	private const int MAX_CHARACTER_LIMIT = 5000;
	private const float gameOverTimeLimit = 60.0f; // Game Over Time Limit in seconds
	private float timer;
	private float timerIncrement;

	private bool is_blink_on = true;
	private float blinkingCooldown = 0.75f;
	
	private float gameOverCooldown = 6.0f;
	private float gameOverTimer;

	private bool is_game_over = false;
	private bool ambiguous_text_active = false;

	private int numberOfFilesDeleted = 1;

	public override void _Ready() {
		filesDirectoryReference = (DirectoryHandler)GetTree().Root
			.GetNode("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files");

		var fileExplorerWindowIndex = GetTree().Root.GetNode("Node2D/CanvasLayer/FileExplorer").GetIndex();
		GetTree().Root.GetNode("Node2D/CanvasLayer").CallDeferred("move_child", GetTree().Root.GetNode("Node2D/CanvasLayer/Terminal"), fileExplorerWindowIndex);

		fileDirectoryList = new LinkedList<string>(filesDirectoryReference.GetListOfFiles());

		rootDirectory = fileDirectoryList.ElementAt(0);

		timerIncrement = gameOverTimeLimit / filesDirectoryReference.GetUserTotalFileCount();
		
		gameOverTimer = gameOverCooldown;

		gameManagerRef = GetTree().Root.GetNode("Node2D/GameManager");

		Connect("terminal_game_over", gameManagerRef, "terminal_game_over");
	}

	public override void _Process(float delta) {
		if (is_terminal_active) {
			timer += delta;
			
			if (is_game_over) {
				gameOverTimer -= delta;
			}

			if (timer > timerIncrement && !is_game_over) {
				addDebugStatementToTerminal();
				timer = 0;
			} else if (timer > blinkingCooldown) {
				blinkLastText();
				timer = 0;
				
				if (gameOverTimer > 0.0 && is_blink_on) {
					gameManagerRef.Call("play_terminal_beep");
				}
			}
			
			if (gameOverTimer <= 0.0) {
				SetProcess(false);
				EmitSignal(nameof(terminal_game_over));
			}
		}
	}

	public bool IsGameOver() {
		return numberOfFilesDeleted >= filesDirectoryReference.GetUserTotalFileCount();
	}

	public void begin_countdown() {
		is_terminal_active = true;
	}
	
	public void ambiguous_text() {
		ambiguous_text_active = true;
	}

	public void addDebugStatementToTerminal() {
		if (fileDirectoryList.Count > 1) {
			var finalFileLocation = fileDirectoryList.First.Next.Value.Replace(rootDirectory, "");
			
			String textToAdd = "";
			if (ambiguous_text_active) {
				textToAdd += rootDirectory + "> [color=yellow](???/???)[/color]";
			} else {
				textToAdd += rootDirectory + "> [color=yellow](" + numberOfFilesDeleted + "/" + (filesDirectoryReference.GetUserTotalFileCount() - 1) + ")[/color]";
			}
			
			textToAdd += " [color=red]DELETING[/color] [color=green]" + finalFileLocation + "[/color]\n";
			
			BbcodeText += textToAdd;
			fileDirectoryList.Remove(fileDirectoryList.First.Next);

			numberOfFilesDeleted += 1;
		}

		if (IsGameOver()) {
			BbcodeText += "[color=yellow]GAME OVER - go home now![/color]";
			gameManagerRef.Call("play_terminal_beep");
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
