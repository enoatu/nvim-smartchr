# nvim-smartchr

nvim-smartchr is a Neovim plugin heavily inspired by [kana/vim-smartchr](https://github.com/kana/vim-smartchr). It aims to bring the same smart and efficient key mapping functionality to the Lua-based Neovim environment. This plugin allows users to define custom key mappings that dynamically expand or replace characters based on the context and file type, greatly enhancing the typing experience in various programming languages. The design closely mirrors the intuitive and powerful features of vim-smartchr, making it an ideal tool for those looking to streamline their coding workflow in Neovim.

## Features

- Define custom key mappings for different file types.
- Smart character replacements based on the cursor's preceding text.
- Support for looping through multiple replacements.
- Lightweight and configurable with a simple Lua interface.

## Installation

You can install `nvim-smartchr` using your preferred Neovim plugin manager.

## Configuration

### Setup

The plugin is configured through the `setup` function. You can define mappings globally or for specific file types. Each mapping consists of the key to be replaced, a list of replacements, and optional settings like looping.

### Example Configuration

Here’s an example configuration to get you started:

```lua
require('nvim-smartchr').setup({
    mappings = {
        default = {
            { "<", { "<", ">" } },
        },
        ["perl|php|python|golong|rust"] = {
            { ".", { ".", " . " }, { loop = true } },
            { ",", { ", ", "," }, { loop = true } },
            { "-", { "->", " - ", "--", "-" }, { loop = true } },
            { "=", { "=", " = ", " => ", " == ", " === ", " eq " }, { loop = true } },
            { "&", { " & ", " && ", "&" }, { loop = true } },
            { "?", { "? ", "?" }, { loop = true } },
            { ":", { "::", ": ", ":" }, { loop = true } },
            { "[", { "[" } },
            { "]", { "]" } },
        },
        ["tt2html"] = {
            { ".", { "." } },
            { ",", { ", ", "," }, { loop = true } },
            { "-", { "-" } },
            { "=", { "=" } },
            { "&", { "&" } },
            { "?", { "?" } },
            { ":", { ":" } },
            { "[", { "[%", "[%-", "[" } },
            { "]", { "%]", "-%]", "]" } },
        },
    },
})
```

### Key Mapping Format

Each key mapping entry follows this structure:

```lua
{
    "<key>",    -- The key to be replaced.
    { "replacement1", "replacement2", ... },   -- List of replacement strings.
    { loop = true/false }  -- Optional settings (e.g., whether to loop through replacements).
}
```

### loop Option

The `loop` option in `nvim-smartchr` determines whether the replacements for a key should cycle through repeatedly or stop after the last replacement. This feature is essential for controlling how the key mappings behave when the same key is pressed multiple times.

### Usage

When defining a key mapping, you can specify the `loop` option as `true` or `false`:

- **`loop = false`**: The replacements will not cycle after reaching the last one. If you continue pressing the key, it will remain at the final replacement. This setting is useful when you want to ensure the final state is stable and ready for the next input. It’s recommended to include the original key as the last replacement value to revert to the initial state.
  
  **Example:**
  ```lua
  { "=", { " = ", " == ", "=" }, { loop = false } }
  ```
  **Behavior:** Pressing `=` will cycle through " = ", " == ", and finally "=". On the next key press, it remains as "=".

- **`loop = true`**: The replacements will cycle continuously. When you press the key multiple times, it will loop back to the first replacement after reaching the last one. This setting is helpful when you want to toggle between different states.

  **Example:**
  ```lua
  { "=", { " = ", " == ", "=" }, { loop = true } }
  ```
  **Behavior:** Pressing `=` will cycle through " = ", " == ", and back to "=" repeatedly.

### Examples

#### Example 1: `loop = false`

```lua
{ "=", { " = ", " == ", "=" }, { loop = false } }
```

- **First press**: `=` transforms to " = ".
- **Second press**: " = " transforms to " == ".
- **Third press**: " == " transforms back to "=".
- **Fourth press and beyond**: It stays as "=".

In this setup, the sequence stops at the last replacement, making the key stable and ready for the next input. It’s advisable to have the key itself as the last replacement value to ensure it returns to its original state.

#### Example 2: `loop = true`

```lua
{ "=", { " = ", " == ", "=" }, { loop = true } }
```

- **First press**: `=` transforms to " = ".
- **Second press**: " = " transforms to " == ".
- **Third press**: " == " transforms back to "=".
- **Fourth press**: "=" transforms to " = " again.
- **Subsequent presses**: The cycle repeats.

With `loop = true`, the replacements keep cycling, allowing continuous toggling between different states. This is useful when you need to switch back and forth among various forms of the replacement.

By configuring the `loop` option according to your needs, you can tailor the behavior of your key mappings in `nvim-smartchr` to match your workflow preferences.

## Contributions

Contributions are welcome! Please submit issues or pull requests via the [GitHub repository](https://github.com/enoatu/nvim-smartchr).

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/enoatu/nvim-smartchr/blob/main/LICENSE) file for details.

---

By following the instructions above, you can easily set up and customize `nvim-smartchr` to fit your needs. This plugin provides a flexible way to handle repetitive typing tasks across different programming languages in Neovim.
