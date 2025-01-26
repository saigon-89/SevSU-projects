from functools import partial
from point import move

actions = [
    partial(move, dx=1, dy=0),
    partial(move, dx=-1, dy=0),
    partial(move, dx=0, dy=1),
    partial(move, dx=0, dy=-1),
    partial(move, dx=1, dy=1),
    partial(move, dx=-1, dy=-1),
    partial(move, dx=1, dy=-1),
    partial(move, dx=-1, dy=1),
]