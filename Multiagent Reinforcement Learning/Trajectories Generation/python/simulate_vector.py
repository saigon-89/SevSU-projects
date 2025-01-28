import numpy as np
from point import Point, calc_distance, calc_angle
from actions import actions
import matplotlib.pyplot as plt
import json
from value_to_state import distance_to_state, angle_to_state
import math

Q_table = np.load("model.npy")

with open("config.json", "r", encoding="utf-8") as config_file:
    config = json.load(config_file)

agent_pos = [2, 5]
goal_pos = [23, 22]

agent = Point(*agent_pos)
goal = Point(*goal_pos)
MAP_SIZE = int(config.get("MAP_SIZE"))
ANGLE_STATE_SIZE = int(config.get("ANGLE_STATE_SIZE"))
DISTANCE_STATE_SIZE = int(config.get("DISTANCE_STATE_SIZE"))
max_possible_distance = math.ceil(math.sqrt(2) * MAP_SIZE)


map = np.zeros((MAP_SIZE, MAP_SIZE))
map[agent.x, agent.y] = 3


for i in range(50):
    distance = calc_distance(agent, goal)
    angle = calc_angle(agent, goal)
    distance_state = distance_to_state(distance, max_possible_distance, DISTANCE_STATE_SIZE)
    angle_state = angle_to_state(angle, ANGLE_STATE_SIZE)
    state = Q_table[distance_state, angle_state]
    action_index = np.argmax(state)
    action = actions[action_index]
    action(point=agent)
    map[agent.x, agent.y] = 1

    if calc_distance(agent, goal) == 0:
        break


map[goal.x, goal.y] = 2
plt.imshow(map, cmap='flag_r')
plt.show()