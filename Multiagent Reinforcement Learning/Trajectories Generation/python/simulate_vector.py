import numpy as np
from point import Point, calc_distance, calc_angle
from actions import actions
import matplotlib.pyplot as plt
import json
from value_to_state import distance_to_state, angle_to_state, calc_obstacles_state, calc_close_obstacles_state
import math
from matplotlib.colors import ListedColormap
import random
from datetime import datetime

cmap = ListedColormap(
    colors=[
        "black",
        "green",
        "orange",
        "white",
        "grey",
        "red"
    ],
    name="qcolormap"
)

MAP_EMPTY = 0
MAP_START_POS = 1
MAP_PATH = 2
MAP_GOAL = 3
MAP_OBSTACLE = 4
MAP_COLLISION = 5

Q_table = np.load("model.npy")

with open("config.json", "r", encoding="utf-8") as config_file:
    config = json.load(config_file)

MAP_SIZE = int(config.get("MAP_SIZE"))
ANGLE_STATE_SIZE = int(config.get("ANGLE_STATE_SIZE"))
DISTANCE_STATE_SIZE = int(config.get("DISTANCE_STATE_SIZE"))
OBSTACLE_DISTANCE_STATE_SIZE = int(config.get("OBSTACLE_DISTANCE_STATE_SIZE"))
CLOSE_OBSTACLES_STATE_SIZE = int(config.get("CLOSE_OBSTACLES_STATE_SIZE"))

for iteration in range(100):
    # agent_pos = [2, 10]
    # goal_pos = [23, 15]
    agent_pos = [random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1)]
    goal_pos = [random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1)]
    obstacles = []

    agent = Point(*agent_pos)
    goal = Point(*goal_pos)

    max_possible_distance = math.ceil(math.sqrt(2) * MAP_SIZE)

    map = np.zeros((MAP_SIZE, MAP_SIZE))
    map[agent.x, agent.y] = MAP_START_POS

    for i in range(15):
        obs = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
        if obs != goal and obs != agent:
            obstacles.append(obs)

    for o in obstacles:
        map[o.x, o.y] = MAP_OBSTACLE

    try:
        for i in range(50):
            distance = calc_distance(agent, goal)
            angle = calc_angle(agent, goal)
            distance_state = distance_to_state(distance, max_possible_distance, DISTANCE_STATE_SIZE)
            angle_state = angle_to_state(angle, ANGLE_STATE_SIZE)
            obstacles_state, dto_state = calc_obstacles_state(agent, goal, obstacles, max_possible_distance, OBSTACLE_DISTANCE_STATE_SIZE)
            close_obstacles_state = calc_close_obstacles_state(agent, goal, obstacles)
            state = Q_table[distance_state, angle_state, obstacles_state, dto_state, close_obstacles_state]
            action_index = np.argmax(state)
            action = actions[action_index]
            action(point=agent)
            if agent in obstacles:
                map[agent.x, agent.y] = MAP_COLLISION
            else:
                map[agent.x, agent.y] = MAP_PATH
            if calc_distance(agent, goal) == 0:
                break
    except Exception as e:
        print(e)

    map[goal.x, goal.y] = MAP_GOAL
    plt.imshow(map, cmap=cmap)
    # plt.show()
    plt.savefig(f"results/{datetime.now().timestamp()}.png")


