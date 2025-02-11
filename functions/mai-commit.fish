
function mai-commit --description "Generate a git commit message based on staged changes"

    argparse h/help e/edit -- $argv

    # Display help and exit
    if set --query _flag_help
        echo "" >&2
        echo "Usage: mai commit -- [options...]" >&2
        echo "" >&2
        echo "Options:" >&2
        echo "       -h, --help     Print this help message" >&2
        echo "       -e, --edit     Edit the message before commiting" >&2
        echo "" >&2
        echo ""
        return 0
    end

    if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
        echo "You are not inside a git repository."
        return 1
    end

    set --local GIT_DIFF (git diff --staged)
    if test "$GIT_DIFF" = ""
        echo "No staged changes found. Please stage your changes first."
        return 1
    end

    set -l PROMPT "
You are an expert software engineer.
Review the provided context and diffs which are about to be committed to a git repo.
Review the diffs carefully.
Generate a commit message for those changes.
The commit message MUST use the imperative tense and active voice
The commit message should be structured as follows: <type>[(scope)]: <title>
The commit message can come with an optional description after the title with a blank line.
Try making the title shorter than 72 characters
Reply with JUST the commit message, without quotes, comments, questions, etc!
Do not use any code snippets, imports, file routes or bulleting points.
Do not mention the route of the file that has been changed.
Write clear, concise, and descriptive title that explains the MAIN GOAL of the changes made.
The scope is optional and provides additional contextual information.
Optional Breaking changes should be indicated by an ! before the : in the subject line.

Types:
- feat: Commits, that add or remove a new feature to the API or UI
- fix: Commits, that fix a API or UI bug of a preceded feat commit
- refactor Commits, that rewrite/restructure your code, however do not change any API or UI behaviour
- perf: Commits are special refactor commits, that improve performance
- style: Commits, that do not affect the meaning (white-space, formatting, missing semi-colons, etc)
- test: Commits, that add missing tests or correcting existing tests
- docs: Commits, that affect documentation only
- build: Commits, that affect build components like build tool, ci pipeline, dependencies, project version, ...
- ops: Commits, that affect operational components like infrastructure, deployment, backup, recovery, ...
- chore: Miscellaneous commits e.g. modifying .gitignore

After the initial line, add a description of why the change is needed.
- Use the imperative mood in the body
- Include motivation for the change, and contrast this with previous behavior
- Separate the description using two new lines
"

    set --local MESSAGE (ollama run $OLLAMA_MODEL "$PROMPT\n\n$GIT_DIFF" | string collect)
    set --local TMP_MESSAGE_FILE (mktemp)
    echo "$MESSAGE" > $TMP_MESSAGE_FILE

    if set --query _flag_edit
        editor $TMP_MESSAGE_FILE
    end

    git commit --file $TMP_MESSAGE_FILE && rm -f $TMP_MESSAGE_FILE && return 0 || rm -f $TMP_MESSAGE_FILE && return 1
end
