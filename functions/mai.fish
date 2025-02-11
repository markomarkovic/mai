function mai --description "My AI assistant"
    set --local mai_version "1.0.0"

    # Model can be overridden by setting OLLAMA_MODEL env var. If not set, use the default.
    if not set --query OLLAMA_MODEL
        set --export OLLAMA_MODEL "qwen2.5-coder:32b"
    end
    echo "Using OLLAMA_MODEL: $OLLAMA_MODEL" >&2

    argparse h/help v/version -- $argv

    # Display version and exit
    if set --query _flag_version
        echo "mai, version $mai_version" >&2
        return 0
    end

    # Display help and exit
    if set --query _flag_help
        echo "" >&2
        echo "Usage: mai <command...> [options...]" >&2
        echo "" >&2
        echo "Options:" >&2
        echo "       -v, --version  Print version" >&2
        echo "       -h, --help     Print this help message" >&2
        echo "" >&2
        echo "Commands:" >&2
        printf '  %s\n' (subcommand --list mai) >&2
        echo ""
        return 0
    end

    if not command -q ollama
        echo "ollama not found. Make sure it's installed and available."
        return 1
    end

    # Run subcommand
    subcommand (status function) $argv
end

# https://www.reddit.com/r/fishshell/comments/1933xml/nice_little_subcommands_for_fish/kh88wco/
function subcommand -d "Easy function subcommands"
    argparse --name=subcommand --stop-nonopt --ignore-unknown 'l/list' -- $argv
    or return 1

    set --local cmd $argv[1]
    set --local subcmd $argv[2]

    # Try to run 'cmd subcommand args'
    if not functions -q $cmd
        echo "No command function found: '$cmd'." >&2
        return 1
    else if test -n "$_flag_list"
        for func in (functions -n | string split ',' | string match "$cmd-*" | string replace "$cmd-" "")
            printf '%s: %s\n' $func (functions -vD "$cmd-$func" | string split '\n' | tail -n1 | string trim)
        end
        return 1
    else if not functions -q $cmd"-"$subcmd
        echo "Subcommand not found for $cmd: '$subcmd'." >&2
        echo "Available subcommands:"
        printf '  %s\n' (subcommand --list $cmd)
        return 1
    else
        $cmd"-"$subcmd $argv[3..]
    end
end
