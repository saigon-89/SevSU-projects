from __future__ import annotations
import random

import numpy as np
from point import Point, calc_distance, calc_angle
from actions import actions
import json
import math
from value_to_state import distance_to_state, angle_to_state

MAX_ITERATIONS = 25
MAX_EPOCHS = 100000
LEARNING_RATE = 0.8
DISCOUNT_FACTOR = 0.95

MAP_SIZE = 25
ANGLE_STATE_SIZE = 30
DISTANCE_STATE_SIZE = 25

max_possible_distance = math.ceil(math.sqrt(2) * MAP_SIZE)

Q_table = np.zeros((DISTANCE_STATE_SIZE, ANGLE_STATE_SIZE, len(actions)), float)



for epoch in range(MAX_EPOCHS):
    print("epoch", epoch)
    iteration = 0
    agent = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
    goal = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
    if agent == goal:
        continue
    while (iteration < MAX_ITERATIONS):
        old_distance = calc_distance(agent, goal)
        old_angle = calc_angle(agent, goal)
        distance_state = distance_to_state(old_distance, max_possible_distance, DISTANCE_STATE_SIZE)
        angle_state = angle_to_state(old_angle, ANGLE_STATE_SIZE)
        old_state = Q_table[distance_state, angle_state]

        # Choose action with epsilon-greedy strategy
        exploration_prob = 1 - epoch / MAX_EPOCHS
        if np.random.rand() < exploration_prob:
            action_index = random.randint(0, len(actions) - 1) # Explore
        else:
            action_index = np.argmax(old_state) # Exploit
        action = actions[action_index]
        action(point=agent)
        if not (0 <= agent.x < MAP_SIZE) or not (0 <= agent.y < MAP_SIZE):
            old_state[action_index] = -1
            break
        new_distance = calc_distance(agent, goal)
        new_angle = calc_angle(agent, goal)
        distance_state = distance_to_state(new_distance, max_possible_distance, DISTANCE_STATE_SIZE)
        angle_state = angle_to_state(new_angle, ANGLE_STATE_SIZE)
        new_state = Q_table[distance_state, angle_state]
        distance_diff = old_distance - new_distance
        reward = distance_diff
        if calc_distance(agent, goal) == 0:
            old_state[action_index] = 1
            break

        # Update Q-value using the Q-learning update rule
        old_state[action_index] += LEARNING_RATE * \
        (reward + DISCOUNT_FACTOR *
        np.max(new_state) - old_state[action_index])
        iteration += 1

np.save("model.npy", Q_table)

with open("config.json", "w") as config_file:
    config = {
        "MAP_SIZE": MAP_SIZE,
        "ANGLE_STATE_SIZE": ANGLE_STATE_SIZE,
        "DISTANCE_STATE_SIZE": DISTANCE_STATE_SIZE
    }
    json.dump(config, config_file)

