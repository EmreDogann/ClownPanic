﻿using System;
using Godot;
using System.Collections.Generic;
using System.Linq;

public class Credits : Label {
    private ScrollContainer scrollContainer;
    private DirectoryHandler filesDirectoryReference;
    private LinkedList<string> fileDirectoryList;
    private String rootDirectory;


    private const float gameOverTimeLimit = 120.0f; // Game Over Time Limit in seconds
    private float timer;
    private float timerIncrement;

    private int numberOfFilesDeleted = 1;


    public override void _Ready() {
        filesDirectoryReference = (DirectoryHandler) GetTree().Root
            .GetNode("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files");

        fileDirectoryList = new LinkedList<string>(filesDirectoryReference.GetListOfFiles());

        rootDirectory = fileDirectoryList.ElementAt(0);

        timerIncrement = gameOverTimeLimit / filesDirectoryReference.GetUserTotalFileCount();

        scrollContainer = GetParent<ScrollContainer>();
        // Text += rootDirectory + "> GAME OVER.\n";
    }

    public override void _Process(float delta) {
        timer += delta;

        if (timer > timerIncrement) {
            addDebugStatementToTerminal();
            timer = 0;
        }
    }

    public bool IsGameOver() {
        return numberOfFilesDeleted >= filesDirectoryReference.GetUserTotalFileCount();
    }

    public void addDebugStatementToTerminal() {
        var finalFileLocation = fileDirectoryList.First.Next.Value.Replace(rootDirectory, "");
        Text += rootDirectory + "> (" + numberOfFilesDeleted + "/" + (filesDirectoryReference.GetUserTotalFileCount() - 1) + ") DELETING " + finalFileLocation + "\n";
        fileDirectoryList.Remove(fileDirectoryList.First.Next);

        numberOfFilesDeleted += 1;

        if (IsGameOver()) {
            Text += "GAME OVER - go home now!";
        }

        scrollContainer.ScrollVertical = (int)scrollContainer.GetVScrollbar().MaxValue;
    }
}