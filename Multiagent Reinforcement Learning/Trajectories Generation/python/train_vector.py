from __future__ import annotations
import random

import numpy as np
from point import Point, calc_distance, calc_angle
from actions import actions
import json
import math
from value_to_state import distance_to_state, angle_to_state, calc_obstacles_state, calc_close_obstacles_state

MAX_ITERATIONS = 25
MAX_EPOCHS = 10000000
LEARNING_RATE = 0.8
DISCOUNT_FACTOR = 0.95

MAP_SIZE = 25
ANGLE_STATE_SIZE = 16
DISTANCE_STATE_SIZE = 1
OBSTACLE_STATE_SIZE = 2
max_possible_distance = math.ceil(math.sqrt(2) * MAP_SIZE)
OBSTACLE_DISTANCE_STATE_SIZE = max_possible_distance
CLOSE_OBSTACLES_STATE_SIZE = 32

Q_table = np.zeros((DISTANCE_STATE_SIZE, ANGLE_STATE_SIZE, OBSTACLE_STATE_SIZE, OBSTACLE_DISTANCE_STATE_SIZE, CLOSE_OBSTACLES_STATE_SIZE, len(actions)), float)

try:
    for epoch in range(MAX_EPOCHS):
        iteration = 0
        agent = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
        goal = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
        if agent == goal:
            continue
        
        obstacles = []
        for i in range(15):
            obs = Point(random.randint(0, MAP_SIZE-1), random.randint(0, MAP_SIZE-1))
            if obs != goal and obs != agent:
                obstacles.append(obs)

        print("epoch", epoch)
        while (iteration < MAX_ITERATIONS):
            old_distance = calc_distance(agent, goal)
            old_angle = calc_angle(agent, goal)
            distance_state = distance_to_state(old_distance, max_possible_distance, DISTANCE_STATE_SIZE)
            angle_state = angle_to_state(old_angle, ANGLE_STATE_SIZE)

            obstacles_state, dto_state = calc_obstacles_state(agent, goal, obstacles, max_possible_distance, OBSTACLE_DISTANCE_STATE_SIZE)
            close_obstacles_state = calc_close_obstacles_state(agent, goal, obstacles)

            old_state = Q_table[distance_state, angle_state, obstacles_state, dto_state, close_obstacles_state]

            # Choose action with epsilon-greedy strategy
            exploration_prob = 1 - epoch / MAX_EPOCHS
            if np.random.rand() < exploration_prob:
                action_index = random.randint(0, len(actions) - 1) # Explore
            else:
                action_index = np.argmax(old_state) # Exploit
            action = actions[action_index]
            action(point=agent)
            new_distance = calc_distance(agent, goal)
            new_angle = calc_angle(agent, goal)
            distance_state = distance_to_state(new_distance, max_possible_distance, DISTANCE_STATE_SIZE)
            angle_state = angle_to_state(new_angle, ANGLE_STATE_SIZE)

            obstacles_state, dto_state = calc_obstacles_state(agent, goal, obstacles, max_possible_distance, OBSTACLE_DISTANCE_STATE_SIZE)
            close_obstacles_state = calc_close_obstacles_state(agent, goal, obstacles)

            new_state = Q_table[distance_state, angle_state, obstacles_state, dto_state, close_obstacles_state]

            distance_diff = old_distance - new_distance
            reward = distance_diff / 100
            if agent in obstacles:
                reward = -1
            elif not (0 <= agent.x < MAP_SIZE) or not (0 <= agent.y < MAP_SIZE):
                reward = -1
            elif calc_distance(agent, goal) == 0:
                reward = 1


            # Update Q-value using the Q-learning update rule
            old_state[action_index] += LEARNING_RATE * \
            (reward + DISCOUNT_FACTOR *
            np.max(new_state) - old_state[action_index])
            if reward in [1, -1]:
                break
            iteration += 1
except KeyboardInterrupt:
    print("Force stop")

np.save("model.npy", Q_table)

with open("config.json", "w") as config_file:
    config = {
        "MAP_SIZE": MAP_SIZE,
        "ANGLE_STATE_SIZE": ANGLE_STATE_SIZE,
        "DISTANCE_STATE_SIZE": DISTANCE_STATE_SIZE,
        "OBSTACLE_DISTANCE_STATE_SIZE": OBSTACLE_DISTANCE_STATE_SIZE,
        "CLOSE_OBSTACLES_STATE_SIZE": CLOSE_OBSTACLES_STATE_SIZE
    }
    json.dump(config, config_file)

