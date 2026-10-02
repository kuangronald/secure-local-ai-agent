function pdone --description 'Check off one project task deterministically and log it'
    # Usage: pdone 'exact task text'
    # Changes ONLY a line that exactly matches "- [ ] <text>", and only if it
    # matches exactly once. Written because two LLMs failed this edit.
    set proj ~/ObsidianVault/Knowledge/Projects/Local-AI-Lab
    set f $proj/local-ai-lab-tasks.md
    set task "$argv"
    set n (grep -c -x -F -- "- [ ] $task" $f)
    if test "$n" != 1
        echo "Found $n open tasks matching exactly. Nothing changed."
        return 1
    end
    awk -v t="- [ ] $task" -v r="- [x] $task" '{ if ($0 == t) print r; else print }' $f > $f.tmp; and mv $f.tmp $f
    printf '%s\n' "- "(date +%F)" - Done: $task" >> $proj/local-ai-lab-changelog.md
    git -C $proj diff --stat
end
