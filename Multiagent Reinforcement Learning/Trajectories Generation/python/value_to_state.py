import math
from point import Point, calc_distance, calc_angle

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

def calc_obstacles_state(agent: Point, goal: Point, obstacles: list[Point], max_distance: float, state_size) -> tuple[int, int]:
    def goal_visible(agent: Point, target: Point, obstacle: Point):
        obstacle_bounding_box = [
            (obstacle.x - 0.5, obstacle.y - 0.5, obstacle.x - 0.5, obstacle.y + 0.5),
            (obstacle.x - 0.5, obstacle.y + 0.5, obstacle.x + 0.5, obstacle.y + 0.5),
            (obstacle.x + 0.5, obstacle.y + 0.5, obstacle.x + 0.5, obstacle.y - 0.5),
        ]
        for line in obstacle_bounding_box:
            sign_1_x = agent.x - line[0]
            sign_1_y = agent.y - line[1]
            sign_2_x = target.x - line[2]
            sign_2_y = target.y - line[3]
            return not (((sign_1_x > 0) != (sign_2_x > 0)) and ((sign_1_y > 0) != (sign_2_y > 0)))
    closest_obstacle = max_distance-1
    state = 0
    for index, obstacle in enumerate(obstacles):
        visibility = goal_visible(agent, goal, obstacle)
        if not visibility:
            closest_obstacle = min(closest_obstacle, distance_to_state(calc_distance(agent, obstacle), max_distance, state_size))
            state = 1
            # return 1, distance_to_state(calc_distance(agent, obstacle), max_distance, state_size)
    return state, closest_obstacle


def calc_close_obstacles_state(agent: Point, target: Point, obstacles: list[Point]) -> int:
    close_points = [
        Point(agent.x,agent.y+1),
        Point(agent.x-1,agent.y+1),
        Point(agent.x-1,agent.y),
        Point(agent.x-1,agent.y-1),
        Point(agent.x,agent.y-1),
        Point(agent.x+1,agent.y-1),
        Point(agent.x+1,agent.y),
        Point(agent.x+1,agent.y+1),
    ]
    shift = round((calc_angle(agent, target)) / 360 * 8) - 4
    close_points = [close_points[i] for i in range(shift, 5 + shift)]
    state = 0
    for index, p in enumerate(close_points):
        if p in obstacles:
            state += pow(2,index)
    return state

