import * as vscode from "vscode";
import * as path from "path";

export function activate(context: vscode.ExtensionContext) {
  let disposable = vscode.commands.registerCommand(
    "extension.logCurrentLineNumber",
    () => {
      const editor = vscode.window.activeTextEditor;
      if (editor) {
        const lineNumber = editor.selection.active.line + 1;

        // Get the current file's full path
        const fullPath = editor.document.fileName;

        // Extract the filename from the full path
        const fileName = path.basename(fullPath);

        // Construct a string containing both the file name and the line number separated by |
        const output = `${fileName} | L:${lineNumber}`;
        const consoleLogStatement = `console.log('${output} ');`;

        editor
          .edit((editBuilder) => {
            // Replace the current selection with the log statement
            editBuilder.replace(editor.selection, consoleLogStatement);
            // Insert the log statement without replacing the current selection
            // editBuilder.insert(editor.selection.active, consoleLogStatement);
          })
          .then((success) => {
            if (success) {
              const newPosition = editor.selection.active.translate(0, -3); // Moves cursor 3 characters to the left.
              const newSelection = new vscode.Selection(
                newPosition,
                newPosition
              );
              editor.selection = newSelection;
            }
          });

        vscode.window.showInformationMessage(
          `Inserted: ${consoleLogStatement}`
        );
      }
    }
  );

  context.subscriptions.push(disposable);
}
export function deactivate() {}
