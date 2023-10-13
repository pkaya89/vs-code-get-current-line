// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';
import * as path from 'path';

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {
    let disposable = vscode.commands.registerCommand('extension.getCurrentLineNumber', () => {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
            const lineNumber = editor.selection.active.line + 1;
            
            // Get the current file's full path
            const fullPath = editor.document.fileName;
            
            // Extract the filename from the full path
            const fileName = path.basename(fullPath);

            // Construct a string containing both the file name and the line number separated by |
            const output = `${fileName}|L:${lineNumber}`;

            // Write the string to the clipboard
            vscode.env.clipboard.writeText(output);
            vscode.window.showInformationMessage(`Copied to clipboard: ${output}`);
        }
    });

    context.subscriptions.push(disposable);
}
export function deactivate() {}