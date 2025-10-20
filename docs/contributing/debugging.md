# Debugging Tests (Using VSCode)

To debug individual RSpec test files in VS Code:

1. Copy the VS Code configuration files manually, or you can run:
   ```bash
   cp .vscode/launch.example.json .vscode/launch.json
   cp .vscode/settings.example.json .vscode/settings.json
   ```
   - If you already have a `launch.json` and/or `settings.json` file, copy the contents of the `launch.example.json` and `settings.example.json` files to your current files instead.
2. Open the VS Code "Run and Debug" sidebar
3. Open the spec file you want to debug and have it as the active file in your editor
4. Select "Run RSpec - Current File" from the debug configuration dropdown
5. Press F5 or click the green play button to start debugging

The debugger will stop at any `binding.break` statements in your code or at any breakpoints you set by clicking in the left margin of the editor.
