# mAI - AI Assistant

_for Software Engineers living in the `fish` shell_

mAI is an AI assistant designed to help software engineers with various tasks within their development workflow. Initially, it focuses on generating commit messages based on staged changes in a Git repository.

## Features

- **Generate Commit Messages**: Automatically generate descriptive and structured commit messages using AI.
- **Customizable Model**: Use the `MAI_OLLAMA_MODEL` environment variable to specify the model used for generating messages.

## Usage

### `mai <command>`

The main entry point for mAI. Currently supports a single subcommand: `commit`.

```
Usage: mai <command...> [options...]

Options:
       -v, --version  Print version
       -h, --help     Print this help message

Commands:
  commit: Generate a git commit message based on staged changes
```

### `mai commit`

Generate a commit message for the current Git repository.

```
Usage: mai commit -- [options...]

Options:
       -h, --help     Print this help message
       -e, --edit     Edit the message before committing
       -a, --amend    Amend the last commit with the new message
```

### Settings

You can set the desired commit type by setting the `MAI_COMMIT_TYPE` environment variable. Valid values include: `PLAIN` (default), and `CONVENTIONAL` (for conventional commits).

```fish
set -Ux MAI_COMMIT_TYPE <desired_commit_type>
```

## Requirements

- [`fish shell`](https://fishshell.com/): A command line shell for the 90s
- [`fisher`](https://github.com/jorgebucaran/fisher): A plugin manager for Fish
- [`git`](https://git-scm.com/): Git SCM
- [`ollama`](https://ollama.com/): Ollama CLI for running models locally

## Installation

### Using Fisher (Recommended)

```sh
fisher install markomarkovic/mai.fish
```

## Contribution

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

This project is licensed under the MIT License.
