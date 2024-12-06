close all
radii = 5;

figure
plot(out.eta_L(:,1), out.eta_L(:,2), 'LineWidth', 1.5)
hold on
plot(out.eta_F(:,1), out.eta_F(:,2), 'LineWidth', 1.5)
viscircles([out.eta_L(end,1), out.eta_L(end,2)], radii, 'LineWidth', 1.5);
axis equal
grid on
xlabel('x, m')
ylabel('y, m')
legend('Leader', 'Follower', '')

figure
plot(out.tout, out.range, 'LineWidth', 1.5)
grid on
hold on
plot(out.tout, out.range .*0 + radii, '--r', 'LineWidth', 1.5)
legend('Distance', 'Desired distance')
xlabel('Time, sec')
ylabel('Range, m')

figure
plot(out.tout, out.eta_L(:,3), 'LineWidth', 1.5)
grid on
hold on
plot(out.tout, out.eta_F(:,3), 'LineWidth', 1.5)
legend('Leader', 'Follower')
xlabel('Time, sec')
ylabel('Depth, m')

figure
subplot(2,1,1)
plot(out.tout, out.eta_L(:,1), 'LineWidth', 1.5)
grid on
hold on
plot(out.tout, out.eta_F(:,1), 'LineWidth', 1.5)
legend('Leader', 'Follower')
ylabel('x, m')
subplot(2,1,2)
plot(out.tout, out.eta_L(:,2), 'LineWidth', 1.5)
grid on
hold on
plot(out.tout, out.eta_F(:,2), 'LineWidth', 1.5)
legend('Leader', 'Follower')
xlabel('Time, sec')
ylabel('y, m')

figure
subplot(2,1,1)
plot(out.tout, radii - out.range, 'LineWidth', 1.5)
grid on
ylabel('Distance error, m')
subplot(2,1,2)
plot(out.tout, out.eta_L(:,3) - out.eta_F(:,3), 'LineWidth', 1.5)
grid on
xlabel('Time, sec')
ylabel('Depth error, m')