from __future__ import annotations
import random

import numpy as np
from point import Point, calc_distance
from actions import actions
import json

map_size = 25
max_iterations = 25
max_epochs = 200000
learning_rate = 0.8
discount_factor = 0.95
# exploration_prob = 0.2
Q_table = np.zeros((map_size, map_size, map_size, map_size, len(actions)))

for epoch in range(max_epochs):
    print("epoch", epoch)
    iteration = 0
    agent = Point(random.randint(0, map_size-1), random.randint(0, map_size-1))
    goal = Point(random.randint(0, map_size-1), random.randint(0, map_size-1))
    if agent == goal:
        continue
    while (iteration < max_iterations):
        old_distance = calc_distance(agent, goal)
        old_state = Q_table[agent.x, agent.y, goal.x, goal.y]

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
        new_state = Q_table[agent.x, agent.y, goal.x, goal.y]
        distance_diff = old_distance - calc_distance(agent, goal)
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