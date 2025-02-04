from __future__ import annotations
import random

import numpy as np
from point import Point, calc_distance, calc_angle
from actions import actions
import json
import math
from value_to_state import distance_to_state, angle_to_state, calc_obstacles_state

MAX_ITERATIONS = 25
MAX_EPOCHS = 20000000
LEARNING_RATE = 0.8
DISCOUNT_FACTOR = 0.95

MAP_SIZE = 25
ANGLE_STATE_SIZE = 16
DISTANCE_STATE_SIZE = 1
OBSTACLE_STATE_SIZE = 256

max_possible_distance = math.ceil(math.sqrt(2) * MAP_SIZE)

Q_table = np.zeros((DISTANCE_STATE_SIZE, ANGLE_STATE_SIZE, OBSTACLE_STATE_SIZE, len(actions)), float)

LR_QUEUE_SIZE = 100
latest_results = [0] * LR_QUEUE_SIZE

# obstacles = [Point(10,i) for i in range(3,20)]
# obstacles += [Point(15,i) for i in range(3,20)]

for epoch in range(MAX_EPOCHS):
    iteration = 0
    agent = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
    goal = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
    if agent == goal:
        continue
    
    # obstacles = []
    # for i in range(30):
    #     obs = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
    #     if obs != goal and obs != agent:
    #         obstacles.append(obs)

    print("epoch", epoch, "success_rate", sum(latest_results)/LR_QUEUE_SIZE)
    while (iteration < MAX_ITERATIONS):
        obstacles = []
        if np.random.rand() < 0.4:
            for i in [-1,0,1]:
                for j in [-1,0,1]:
                    if i != 0 or j != 0:
                        if np.random.rand() < 0.5:
                            obs = Point(agent.x+i, agent.y+j)
                            if obs != goal:
                                obstacles.append(obs)

        old_distance = calc_distance(agent, goal)
        old_angle = calc_angle(agent, goal)
        distance_state = distance_to_state(old_distance, max_possible_distance, DISTANCE_STATE_SIZE)
        angle_state = angle_to_state(old_angle, ANGLE_STATE_SIZE)
        obstacles_state = calc_obstacles_state(agent, obstacles)
        old_state = Q_table[distance_state, angle_state, obstacles_state]

        # Choose action with epsilon-greedy strategy
        exploration_prob = 1 - epoch / MAX_EPOCHS
        if np.random.rand() < exploration_prob:
            action_index = random.randint(0, len(actions) - 1) # Explore
        else:
            action_index = np.argmax(old_state) # Exploit
        action = actions[action_index]
        action(point=agent)
        if not (0 <= agent.x < MAP_SIZE) or not (0 <= agent.y < MAP_SIZE):
            old_state[action_index] = -10
            break
        new_distance = calc_distance(agent, goal)
        new_angle = calc_angle(agent, goal)
        distance_state = distance_to_state(new_distance, max_possible_distance, DISTANCE_STATE_SIZE)
        angle_state = angle_to_state(new_angle, ANGLE_STATE_SIZE)
        obstacles_state = calc_obstacles_state(agent, obstacles)
        new_state = Q_table[distance_state, angle_state, obstacles_state]
        distance_diff = old_distance - new_distance
        reward = distance_diff / 10
        if agent in obstacles:
            old_state[action_index] = -10
            break
        if calc_distance(agent, goal) == 0:
            old_state[action_index] = 1
            latest_results.append(1)
            latest_results.pop(0)
            break

        # Update Q-value using the Q-learning update rule
        old_state[action_index] += LEARNING_RATE * \
        (reward + DISCOUNT_FACTOR *
        np.max(new_state) - old_state[action_index])
        iteration += 1
        if iteration == MAX_ITERATIONS:
            latest_results.append(0)
            latest_results.pop(0)

np.save("model.npy", Q_table)

with open("config.json", "w") as config_file:
    config = {
        "MAP_SIZE": MAP_SIZE,
        "ANGLE_STATE_SIZE": ANGLE_STATE_SIZE,
        "DISTANCE_STATE_SIZE": DISTANCE_STATE_SIZE
    }
    json.dump(config, config_file)

