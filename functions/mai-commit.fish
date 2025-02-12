
function mai-commit --description "Generate a git commit message based on staged changes"

    # Types of commits supported:
    # - PLAIN: Just the subject and body, no special formatting
    # - CONVENTIONAL: https://www.conventionalcommits.org/en/v1.0.0/
    if not set --query MAI_COMMIT_TYPE
        set --function MAI_COMMIT_TYPE "PLAIN"
    else if not string match -r '^(PLAIN|CONVENTIONAL)$' $MAI_COMMIT_TYPE
        echo "Invalid MAI_COMMIT_TYPE: $MAI_COMMIT_TYPE. Using PLAIN instead." >&2
        set --function MAI_COMMIT_TYPE "PLAIN"
    end
    echo "Generating a $MAI_COMMIT_TYPE type commit message" >&2
    switch $MAI_COMMIT_TYPE
        case "PLAIN"
            set MAI_COMMIT_TYPE 1
        case "CONVENTIONAL"
            set MAI_COMMIT_TYPE 2
    end

    argparse h/help e/edit a/amend -- $argv

    # Display help and exit
    if set --query _flag_help
        echo "" >&2
        echo "Usage: mai commit -- [options...]" >&2
        echo "" >&2
        echo "Options:" >&2
        echo "       -h, --help     Print this help message" >&2
        echo "       -e, --edit     Edit the message before commiting" >&2
        echo "       -a, --amend    Amend the last commit with the new message" >&2
        echo "" >&2
        echo ""
        return 0
    end

    if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
        echo "You are not inside a git repository."
        return 1
    end

    if set --query _flag_amend
        set --function GIT_DIFF (git diff HEAD^ HEAD)
    else
        set --function GIT_DIFF (git diff --staged)
    end
    if test "$GIT_DIFF" = ""
        echo "No staged changes found. Please stage your changes first."
        return 1
    end

    # PLAIN
    set --local PROMPT[1] "
You are an expert software engineer.
Review the provided context and diffs which are about to be committed to a git repo.
Reply with JUST the commit message, without quotes, comments, questions, etc!
Do not use any code snippets, imports, file routes or bulleting points.
Do not mention the route of the file that has been changed.
Write clear, concise, and descriptive TITLE that explains the MAIN GOAL of the changes made.

Generate a commit message for those changes following these rules:
- Use imperative tense and active voice.
- TITLE should be clear, concise, shorter than 72 characters if possible.
- Explain breaking changes in the DESCRIPTION section.

After SUBJECT line, add a DESCRIPTION if necessary.
- Optional and can provide more context about the change.
- Write in present tense, active voice, imperative mood.
- Explain what was changed, why it was necessary with motivation, contrasting previous behavior.
- Do NOT describe how the change was made.
- Separate description using two new lines.
"

    # CONVENTIONAL
    set --local PROMPT[2] "
$PROMPT[1]

Follow Conventional Commits guidelines:
- Structure SUBJECT as follows: <TYPE>(optional SCOPE): <TITLE>
- SCOPE is optional and provides context, not a file name.
- Indicate breaking changes with an exclamation mark ! before the colon : in the SUBJECT line.

TYPEs:
feat: Add or remove a new feature
fix: Fix an API or UI bug of a preceded feat commit
refactor: Rewrite/restructure code without changing behavior
perf: Improve performance (special refactor)
style: Formatting, white-space, missing semi-colons, etc.
test: Add or correct tests
docs: Affect documentation only
build: Affect build tools, ci pipeline, dependencies, version, ...
ops: Affect infrastructure, deployment, backup, recovery, ...
chore: Miscellaneous changes e.g. modifying .gitignore
"

    set --local PROMPT $PROMPT[$MAI_COMMIT_TYPE]
    set --local MESSAGE (ollama run $MAI_OLLAMA_MODEL "$PROMPT\n\n$GIT_DIFF" | string collect)
    set --local TMP_MESSAGE_FILE (mktemp)
    echo "$MESSAGE" > $TMP_MESSAGE_FILE

    if set --query _flag_edit
        editor $TMP_MESSAGE_FILE
    end

    if set --query _flag_amend
        git commit --amend --file $TMP_MESSAGE_FILE && rm -f $TMP_MESSAGE_FILE && return 0 || rm -f $TMP_MESSAGE_FILE && return 1
    end

    git commit --file $TMP_MESSAGE_FILE && rm -f $TMP_MESSAGE_FILE && return 0 || rm -f $TMP_MESSAGE_FILE && return 1
end
