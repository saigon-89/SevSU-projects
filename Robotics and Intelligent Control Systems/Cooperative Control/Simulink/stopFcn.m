X_L = squeeze(out.ETA.signals(1).values(:,1,:));
Y_L = squeeze(out.ETA.signals(1).values(:,2,:));
X_F1 = squeeze(out.ETA_F1.signals(1).values(:,1,:));
Y_F1 = squeeze(out.ETA_F1.signals(1).values(:,2,:));

figure
plot(X_L, Y_L, 'LineWidth', 2)
hold on
plot(X_F1, Y_F1, 'LineWidth', 2)
viscircles([X_L(end), Y_L(end)], range);
legend('Leader', 'Follower', 'Location', 'Best')
grid on
xlabel('x, m')
ylabel('y, m')
axis equal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
subplot(2,1,1)
plot(out.ETA.time, squeeze(out.ETA.signals(1).values(:,1,:)))
hold on
plot(out.ETA.time, squeeze(out.ETA.signals(1).values(:,2,:)))
plot(out.ETA.time, squeeze(out.ETA.signals(1).values(:,3,:)))
ylabel('Position, m')
legend('${x_L}$', '${y_L}$', '${z_L}$','Interpreter','latex','Location', 'Best')
grid on

subplot(2,1,2)
plot(out.ETA.time, squeeze(out.ETA.signals(2).values(:,1,:)))
hold on
plot(out.ETA.time, squeeze(out.ETA.signals(2).values(:,2,:)))
plot(out.ETA.time, squeeze(out.ETA.signals(2).values(:,3,:)))
ylabel('Orientation, rad')
legend('${\phi}_L$', '${\theta}_L$', '${\psi}_L$','Interpreter','latex','Location', 'Best')
grid on
xlabel('Time, sec')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
subplot(2,1,1)
plot(out.ETA_F1.time, squeeze(out.ETA_F1.signals(1).values(:,1,:)))
hold on
plot(out.ETA_F1.time, squeeze(out.ETA_F1.signals(1).values(:,2,:)))
plot(out.ETA_F1.time, squeeze(out.ETA_F1.signals(1).values(:,3,:)))
ylabel('Position, m')
legend('${x}_F$', '${y}_F$', '${z}_F$','Interpreter','latex','Location', 'Best')
grid on

subplot(2,1,2)
plot(out.ETA_F1.time, squeeze(out.ETA_F1.signals(2).values(:,1,:)))
hold on
plot(out.ETA_F1.time, squeeze(out.ETA_F1.signals(2).values(:,2,:)))
plot(out.ETA_F1.time, squeeze(out.ETA_F1.signals(2).values(:,3,:)))
ylabel('Orientation, rad')
legend('${\phi}_F$', '${\theta}_F$', '${\psi}_F$','Interpreter','latex','Location', 'Best')
grid on
xlabel('Time, sec')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
subplot(2,1,1)
plot(out.SET_F1.time, squeeze(out.SET_F1.signals(1).values(:,1,:)))
hold on
plot(out.SET_F1.time, squeeze(out.SET_F1.signals(1).values(:,2,:)))
plot(out.SET_F1.time, squeeze(out.SET_F1.signals(1).values(:,3,:)))
ylabel('Position, m')
legend('${x}_{SET}$', '${y}_{SET}$', '${z}_{SET}$','Interpreter','latex','Location', 'Best')
grid on

subplot(2,1,2)
plot(out.SET_F1.time, squeeze(out.SET_F1.signals(2).values(:,1,:)))
hold on
plot(out.SET_F1.time, squeeze(out.SET_F1.signals(2).values(:,2,:)))
plot(out.SET_F1.time, squeeze(out.SET_F1.signals(2).values(:,3,:)))
ylabel('Orientation, rad')
legend('${\phi}_{SET}$', '${\theta}_{SET}$', '${\psi}_{SET}$','Interpreter','latex','Location', 'Best')
grid on
xlabel('Time, sec')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
plot(out.RANGE.time, squeeze(out.RANGE.signals(1).values))
hold on
plot(out.RANGE.time, range + 0.*squeeze(out.RANGE.signals(1).values), '--r')
ylabel('Range, m')
grid on
xlabel('Time, sec')