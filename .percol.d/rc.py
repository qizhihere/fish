# Run command file for percol
percol.view.PROMPT = ur"<cyan>Input:</cyan> %q"
percol.view.RPROMPT = ur"(%F) [%i/%I]"

percol.view.CANDIDATES_LINE_BASIC    = ("on_default", "default")
percol.view.CANDIDATES_LINE_SELECTED = ("on_black", "white")
percol.view.CANDIDATES_LINE_MARKED   = ("bold", "reverse", "on_default", "white")
percol.view.CANDIDATES_LINE_QUERY    = ("on_black", "bold", "red")

# Display finder name in RPROMPT
percol.view.prompt_replacees["F"] = lambda self, **args: self.model.finder.get_name()

# Change prompt in response to the status of case sensitivity
percol.view.__class__.PROMPT = property(
    lambda self:
    ur"<bold><blue>QUERY </blue><black>[a]:</black></bold> %q" if percol.model.finder.case_insensitive
    else ur"<bold><red>QUERY </red>[A]:</bold> %q"
)

# Switching matching method dynamically
from percol.finder import FinderMultiQueryMigemo, FinderMultiQueryRegex
percol.import_keymap({
    "M-c" : lambda percol: percol.command.toggle_case_sensitive(),
    "M-m" : lambda percol: percol.command.toggle_finder(FinderMultiQueryMigemo),
    "M-r" : lambda percol: percol.command.toggle_finder(FinderMultiQueryRegex)
})

# Emacs like
percol.import_keymap({
    "C-h" : lambda percol: percol.command.delete_backward_char(),
    "C-d" : lambda percol: percol.command.delete_forward_char(),
    "C-k" : lambda percol: percol.command.kill_end_of_line(),
    "C-y" : lambda percol: percol.command.yank(),
    "C-t" : lambda percol: percol.command.transpose_chars(),
    "C-a" : lambda percol: percol.command.beginning_of_line(),
    "C-e" : lambda percol: percol.command.end_of_line(),
    "C-b" : lambda percol: percol.command.backward_char(),
    "C-f" : lambda percol: percol.command.forward_char(),
    "M-f" : lambda percol: percol.command.forward_word(),
    "M-b" : lambda percol: percol.command.backward_word(),
    "M-d" : lambda percol: percol.command.delete_forward_word(),
    "M-<backspace>" : lambda percol: percol.command.delete_backward_word(),
    "C-n" : lambda percol: percol.command.select_next(),
    "C-p" : lambda percol: percol.command.select_previous(),
    "C-v" : lambda percol: percol.command.select_next_page(),
    "M-v" : lambda percol: percol.command.select_previous_page(),
    "M-<" : lambda percol: percol.command.select_top(),
    "M->" : lambda percol: percol.command.select_bottom(),
    "C-m" : lambda percol: percol.finish(),
    "C-j" : lambda percol: percol.finish(),
    "C-g" : lambda percol: percol.cancel(),
})
