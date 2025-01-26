import math
import numpy as np

class Point:
    x: int
    y: int

    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

def move(point: Point, dx: int, dy: int):
    point.x += dx
    point.y += dy

def calc_distance(point1: Point, point2: Point) -> float:
    return math.sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))

def calc_angle(point1: Point, point2: Point) -> float:
    return np.rad2deg(math.atan2(point2.y-point1.y, point2.x-point1.x))