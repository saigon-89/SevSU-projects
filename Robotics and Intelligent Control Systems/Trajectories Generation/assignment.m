clear;

combinations = [
    10, 20, 30;
    20, 20, 20;
    15, 4, 25;
    16, 8, 200;
    15, 16, 13;
];

[n_combinations, n_trajectories] = size(combinations);

results = zeros(n_combinations,1);
mu1 = 1;
mu2 = 1;
for i=1:n_combinations
    combination = combinations(i,:);
    f_sum = sum(combination);
    f_avg = f_sum / n_trajectories;
    f_var = (sum((combination - f_avg).^2)) / n_trajectories;
    f_eva = mu1 * f_sum + mu2 * f_var;
    results(i) = f_eva;
end

[best_eval_func, best_comb_idx] = min(results);
