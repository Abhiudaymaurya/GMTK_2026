extends Node

@warning_ignore_start("unused_signal")

# lodge
signal lodge_upgraded(new_tier: int)
signal upgrade_failed(reason: String)

# context btn
signal context_update(interactable, hint_text: String, entered: bool)
signal update_hint(hint_text: String)

# day count
signal day_changed(day: int)
signal day_started()

@warning_ignore_restore("unused_signal")