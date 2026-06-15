---
title: "What is Q-Learning?"
date: 2026-06-16 00:00:00 +0900
categories: [Reinforcement Learning, Concepts]
tags: [q-learning, bellman, mdp, beginner]
---

## One-line Summary
Q-Learning is a model-free reinforcement learning algorithm that learns the value of taking a given action in a given state, without needing a model of the environment.

## Intuition
Imagine an agent wandering through a grid world, trying to find the shortest path to a goal. At first it has no idea which moves are good. Every time it takes an action, it gets a reward (or penalty) and ends up in a new state.

Q-Learning keeps a table of "how good is it to take action `a` in state `s`?" — called the **Q-value**, `Q(s, a)`. Over many episodes, the agent updates this table based on the rewards it actually receives, gradually learning which actions lead to the best long-term outcome, even if the immediate reward is small or negative.

## Math
The core of Q-Learning is the **Bellman update**:

$$
Q(s_t, a_t) \leftarrow Q(s_t, a_t) + \alpha \left[ r_t + \gamma \max_{a} Q(s_{t+1}, a) - Q(s_t, a_t) \right]
$$

Where each term means:

- $Q(s_t, a_t)$ — current estimate of the value of action $a_t$ in state $s_t$
- $\alpha$ — learning rate, controls how much new information overrides old estimates
- $r_t$ — reward received after taking action $a_t$
- $\gamma$ — discount factor, how much future rewards matter relative to immediate ones
- $\max_{a} Q(s_{t+1}, a)$ — the best possible value achievable from the next state

The agent repeatedly applies this update as it explores, and `Q` slowly converges toward the true optimal action-value function $Q^*$.

## Code (optional)
```python
import numpy as np

n_states, n_actions = 6, 2
Q = np.zeros((n_states, n_actions))

alpha, gamma, epsilon = 0.1, 0.99, 0.1

def choose_action(state):
    if np.random.rand() < epsilon:
        return np.random.randint(n_actions)
    return np.argmax(Q[state])

def update(state, action, reward, next_state):
    best_next = np.max(Q[next_state])
    Q[state, action] += alpha * (reward + gamma * best_next - Q[state, action])
```

## Key Takeaway
Q-Learning lets an agent learn an optimal policy purely from trial-and-error experience, by iteratively bringing its value estimates closer to the Bellman optimality equation.

## References
- [Sutton & Barto, Reinforcement Learning: An Introduction](http://incompleteideas.net/book/the-book.html)
