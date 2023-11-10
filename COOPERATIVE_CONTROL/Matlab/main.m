close all
clear all

set(0, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontName', 'Arial');

%% ��������� ��������� �� �����
auv_param

%% ������������� �������� ��� ���������������� ������� �����������
eta0 = [0; 0; 0; 0; 0; 0];
v0 = [0; 0; 0; 0; 0; 0];
tau = [0.45; 0; 0.15; 0; 0; 0.25];
he = [0; 0; 0; 0; 0; 0];
t_end = 60; dt = 0.01;

UV = { MMT300, MMT300 };
X0 = [ [eta0; v0]; [eta0; v0] ];
TAU = { tau, tau };
HE = { he, he };

[t,Y] = ode45(@(t,y)odefcn(t,y,UV,TAU,HE), 0:dt:t_end, X0);

%% ���������� ��������
for i = 1:numel(UV)
    n = 6;
    offset = 12 * (i - 1);
    figure
    v = Y(:,(7 + offset):(2*n + offset));
    subplot(2,2,1), title('�������� (��������)'), hold on, grid on
    plot(t, v(:,1:3)), xlabel('t, ���'), ylabel('��������, �/c'), xlim([0 t_end])
    legend('u(t)', 'v(t)', 'w(t)', 'Location', 'Best')
    subplot(2,2,2), title('�������� (�������)'), hold on, grid on
    plot(t, v(:,4:end)), xlabel('t, ���'), ylabel('��������, ���/c'), xlim([0 t_end])
    legend('p(t)', 'q(t)', 'r(t)', 'Location', 'Best')
    eta = Y(:,(1 + offset):(n + offset));
    subplot(2,2,3), title('��������� (�� ����)'), hold on, grid on
    plot(t, eta(:,1:3)), xlabel('t, ���'), ylabel('���������, �'), xlim([0 t_end])
    legend('x(t)', 'y(t)', 'z(t)', 'Location', 'Best')
    subplot(2,2,4), title('��������� (���� ������)'), hold on, grid on
    plot(t, eta(:,4:end)), xlabel('t, ���'), ylabel('���������, ���'), xlim([0 t_end])
    legend('\phi(t)', '\theta(t)', '\psi(t)', 'Location', 'Best')
    sgtitle(strcat('���������������� AUV', sprintf('#%d', i)))
    
    figure, plot3(eta(:,1), eta(:,2), eta(:,3)), title(strcat('���������������� AUV', sprintf('#%d', i)))
    hold on
    plot3(eta(end,1), eta(end,2), eta(end,3), 'rO') 
    legend('���������� AUV', '�������� ���������', 'Location', 'Best')
    xlabel('x(t)'), ylabel('y(t)'), zlabel('z(t)'), grid on
    set(gca, 'YDir', 'reverse');
    set(gca, 'ZDir', 'reverse');
    axis equal
    legend('off')
    %rectangular_plot(eta(1,:), L*10^-3, W*10^-3, H*10^-3, '--r')
    %rectangular_plot(eta(end,:), L*10^-3, W*10^-3, H*10^-3, 'r')
    
    %auv_animation(eta,L,W,H,dt/1000)
end