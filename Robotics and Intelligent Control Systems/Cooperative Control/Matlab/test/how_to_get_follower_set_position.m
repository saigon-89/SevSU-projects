clc
close all
clear all
pos_l = [1; 0; 0]; % Leader Position
pos_f = [5; 1; 5]; % Follower Position
r = 2; % Range

%% GROUP 1: IF LEADER AND FOLLOWER POSITIONS ARE KNOWN
%% VIA NUMERICAL OPTIMIZATION (2D)
tic
f = @(x)Criterion2D(x, pos_l, r);
constr = @(x)Constrains2D(x, pos_l, r);
[x, ~] = fmincon(f, pos_f, [], [], [], [], [], [], constr);
toc
disp('Numerical optimization (2D)');

figure
plot(pos_l(1), pos_l(2), 'rO', 'LineWidth', 3);
viscircles(pos_l(1:2)', r);
hold on
plot(pos_f(1), pos_f(2), 'bO', 'LineWidth', 2);
plot(x(1), x(2), 'gO', 'LineWidth', 2);
legend('Leader Position', 'Follower Position', 'Follower Set Position')
grid on
axis equal
xlabel('X, m')
ylabel('Y, m')

%% ANALITICALLY
tic
P1 = @(pos_l, pos_f, r) [ pos_l(1) + (r*(pos_f(1)-pos_l(1))) / sqrt((pos_f(1)-pos_l(1))^2 + (pos_f(2)-pos_l(2))^2); ...
                          pos_l(2) + (r*(pos_f(2)-pos_l(2))) / sqrt((pos_f(1)-pos_l(1))^2 + (pos_f(2)-pos_l(2))^2) ];
P2 = @(pos_l, pos_f, r) [ pos_l(1) - (r*(pos_f(1)-pos_l(1))) / sqrt((pos_f(1)-pos_l(1))^2 + (pos_f(2)-pos_l(2))^2); ...
                          pos_l(2) - (r*(pos_f(2)-pos_l(2))) / sqrt((pos_f(1)-pos_l(1))^2 + (pos_f(2)-pos_l(2))^2) ];
% Две возможные точки
p1 = P1(pos_l, pos_f, r);
p2 = P2(pos_l, pos_f, r);
% Две нормы
n = [ norm(p1 - pos_f(1:2)); ... 
      norm(p2 - pos_f(1:2)) ];
% Ищем минимальную
[~, idx] = min(n);
if (idx == 1)
    x(1) = p1(1); x(2) = p1(2);
else
    x(1) = p2(1); x(2) = p2(1);
end
toc
disp('Analitically');

figure
plot(pos_l(1), pos_l(2), 'rO', 'LineWidth', 3);
viscircles(pos_l(1:2)', r);
hold on
plot(pos_f(1), pos_f(2), 'bO', 'LineWidth', 2);
plot(x(1), x(2), 'gO', 'LineWidth', 2);
legend('Leader Position', 'Follower Position', 'Follower Set Position')
grid on
axis equal
xlabel('X, m')
ylabel('Y, m')

%% VIA NUMERICAL OPTIMIZATION (3D)
tic
f = @(x)Criterion3D(x, pos_l, r);
constr = @(x)Constrains3D(x, pos_l, r);
[x, ~] = fmincon(f, pos_f, [], [], [], [], [], [], constr);
toc
disp('Numerical optimization (3D)');
[X,Y,Z] = sphere;
X2 = X * r;
Y2 = Y * r;
Z2 = Z * r;
figure
surf(X2 + pos_l(1), Y2 + pos_l(2), Z2 + pos_l(3), 'FaceAlpha', 0.5, 'EdgeColor', 'none')
hold on
plot3(pos_l(1), pos_l(2), pos_l(3), 'rO', 'LineWidth', 3);
plot3(pos_f(1), pos_f(2), pos_f(3), 'bO', 'LineWidth', 2);
plot3(x(1), x(2), 0, 'gO', 'LineWidth', 2);
legend('', 'Leader Position', 'Follower Position', 'Follower Set Position')
axis equal


function f = Criterion2D(pos_f, pos_l, r)
    f = sqrt( (pos_f(1) - pos_l(1))^2 + (pos_f(2) - pos_l(2))^2 ) - r;
end

function [c, ceq] = Constrains2D(pos_f, pos_l, r)
    c = -( (pos_f(1) - pos_l(1))^2 + (pos_f(2) - pos_l(2))^2 - r^2);
    ceq = [];
end

function f = Criterion3D(pos_f, pos_l, r)
    f = sqrt( (pos_f(1) - pos_l(1))^2 + (pos_f(2) - pos_l(2))^2 + (pos_f(3) - pos_l(3))^2 ) - r;
end

function [c, ceq] = Constrains3D(pos_f, pos_l, r)
    c = -( (pos_f(1) - pos_l(1))^2 + (pos_f(2) - pos_l(2))^2 + (pos_f(3) - pos_l(3))^2 - r^2);
    ceq = [];
end