def _iframe(args):
    google-chrome --app=@(args[0])
aliases['iframe'] = _iframe
