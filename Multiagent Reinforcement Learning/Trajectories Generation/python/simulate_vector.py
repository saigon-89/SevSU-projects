import numpy as np
from point import Point, calc_distance, calc_angle
from actions import actions
import matplotlib.pyplot as plt
import json

Q_table = np.load("model.npy")

with open("config.json", "r", encoding="utf-8") as config_file:
    config = json.load(config_file)

agent_pos = [2, 5]
goal_pos = [23, 22]

agent = Point(*agent_pos)
goal = Point(*goal_pos)
map_size = int(config.get("map_size"))
map = np.zeros((map_size, map_size))
map[agent.x, agent.y] = 3


for i in range(50):
    distance = calc_distance(agent, goal)
    angle = calc_angle(agent, goal) + 180 - 1
    state = Q_table[int(distance), int(angle)]
    action_index = np.argmax(state)
    action = actions[action_index]
    action(point=agent)
    map[agent.x, agent.y] = 1

    if calc_distance(agent, goal) == 0:
        break


map[goal.x, goal.y] = 2
plt.imshow(map, cmap='flag_r')
plt.show()