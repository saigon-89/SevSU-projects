from __future__ import annotations
import random

import numpy as np
from point import Point, calc_distance, calc_angle
from actions import actions
import json
import math

map_size = 25
max_iterations = 25
max_epochs = 100000
learning_rate = 0.8
discount_factor = 0.95
# exploration_prob = 0.2
angle_states = 360
distance_states = math.ceil(math.sqrt(2) * map_size)
Q_table = np.zeros((distance_states, angle_states, len(actions)))


for epoch in range(max_epochs):
    print("epoch", epoch)
    iteration = 0
    agent = Point(random.randint(0, map_size-1), random.randint(0, map_size-1))
    goal = Point(random.randint(0, map_size-1), random.randint(0, map_size-1))
    if agent == goal:
        continue
    while (iteration < max_iterations):
        old_distance = calc_distance(agent, goal)
        old_angle = calc_angle(agent, goal) + 180 - 1
        old_state = Q_table[int(old_distance), int(old_angle)]

        # Choose action with epsilon-greedy strategy
        exploration_prob = 1 - epoch/max_epochs
        if np.random.rand() < exploration_prob:
            action_index = random.randint(0, len(actions) - 1) # Explore
        else:
            action_index = np.argmax(old_state) # Exploit
        action = actions[action_index]
        action(point=agent)
        if not (0 <= agent.x < map_size) or not (0 <= agent.y < map_size):
            old_state[action_index] = -1
            break
        new_distance = calc_distance(agent, goal)
        new_angle = calc_angle(agent, goal) + 180 - 1
        new_state = Q_table[int(new_distance), int(new_angle)]
        distance_diff = old_distance - new_distance
        reward = distance_diff
        if calc_distance(agent, goal) == 0:
            old_state[action_index] = 1
            break

        # Update Q-value using the Q-learning update rule
        old_state[action_index] += learning_rate * \
        (reward + discount_factor *
        np.max(new_state) - old_state[action_index])
        iteration += 1

np.save("model.npy", Q_table)

with open("config.json", "w") as config_file:
    config = {
        "map_size": map_size
    }
    json.dump(config, config_file)