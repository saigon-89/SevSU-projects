import math
from point import Point

def angle_to_state(angle: float, state_size):
    """
    Angle can be in range [-180; 180], therefore angle+180 gives positive angle values
    """
    return math.floor((angle + 180) / 360 * state_size) - 1

def distance_to_state(distance: float, max_distance: float, state_size):
    """
    Angle can be in range [-180; 180], therefore angle+180 gives positive angle values
    """
    return math.floor(distance / max_distance * state_size) - 1

def calc_obstacles_state(target: Point, obstacles: list[Point]) -> int:
    obstacles = [(o.x, o.y) for o in obstacles]
    power = 0
    state = 0
    for i in [-1, 0, 1]:
        for j in [-1, 0, 1]:
            if i != 0 or j != 0:
                if (target.x + i, target.y + j) in obstacles:
                    state += pow(2,power)
                power += 1
    return state