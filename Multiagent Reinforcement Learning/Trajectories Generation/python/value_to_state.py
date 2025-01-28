import math

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