close all
clear all

%% ЗАГРУЗИТЬ ПАРАМЕТРЫ ИЗ ФАЙЛА
param

%% ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
% преобразование в кососимметричную матрицу
S = @(x)([ 0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0 ]); 

%% РАСЧЕТ ЯКОБИАНА
J_k_o = @(eta)[ 1  0           -sin(eta(5)); ...
                0  cos(eta(4))  cos(eta(5))*sin(eta(4)); ...
                0 -sin(eta(4))  cos(eta(5))*cos(eta(4)) ];
R_I_B = @(eta)[ cos(eta(6))*cos(eta(5))                                        sin(eta(6))*cos(eta(5))                                       -sin(eta(5)); ...
               -sin(eta(6))*cos(eta(4)) + cos(eta(6))*sin(eta(5))*sin(eta(4))  cos(eta(6))*cos(eta(4)) + sin(eta(6))*sin(eta(5))*sin(eta(4))  sin(eta(4))*cos(eta(5)); ...
                sin(eta(6))*sin(eta(4)) + cos(eta(6))*sin(eta(5))*cos(eta(4)) -cos(eta(6))*sin(eta(4)) + sin(eta(6))*sin(eta(5))*cos(eta(4))  cos(eta(4))*cos(eta(5)) ];
J = @(eta)[ R_I_B(eta) zeros(3); ...
            zeros(3)   J_k_o(eta) ];

%% РАСЧЕТ МАТРИЦЫ M
% расчет M_RB
M_RB = [ m*eye(3) -m*S(r_g_b); m*S(r_g_b) I0 ];
% расчет M
M = M_RB + M_A; 

%% РАСЧЕТ C(v)
% расчет C_RB(v)
%C_RB = @(v)([ zeros(3) -m*S(v(1:3)); -m*S(v(1:3)) -S(diag(I0).*v(4:end)) ]); 
C_RB = @(v)[ zeros(3)                           -m*S(v(1:3))-m*S(S(v(4:end))*r_g_b); ...
            -m*S(v(1:3))-m*S(S(v(4:end))*r_g_b)  m*S(S(v(1:3))*r_g_b)-S(I0*v(4:end)) ];
% расчет C_A(v)
diag_M_A = diag(M_A);
C_A = @(v)([ zeros(3) -S(diag_M_A(1:3).*v(1:3)); 
    -S(diag_M_A(1:3).*v(1:3)) -S(diag_M_A(4:end).*v(4:end))]);
% расчет C(v)
C = @(v)(C_RB(v) + C_A(v)); 
% M11 = M(1:3,1:3); M12 = M(1:3,4:6); M21 = M(4:6,1:3); M22 = M(4:6,4:6);
% C = @(v)[ zeros(3) -S(M11*v(1:3)+M12*v(4:6)); -S(M11*v(1:3)+M12*v(4:6)) -S(M21*v(1:3)+M22*v(4:6)) ];

%% РАСЧЕТ g(n)
x_g = r_g_b(1); y_g = r_g_b(2); z_g = r_g_b(3);
x_b = r_b_b(1); y_b = r_b_b(2); z_b = r_b_b(3);
g = @(eta)[ (W-B)*sin(eta(5)); 
           -(W-B)*cos(eta(5))*sin(eta(4)); 
           -(W-B)*cos(eta(5))*cos(eta(4));
           -(y_g*W-y_b*B)*cos(eta(5))*cos(eta(4)) + ...
              (z_g*W-z_b*B)*cos(eta(5))*sin(eta(4));
            (z_g*W-z_b*B)*sin(eta(5)) + ...
              (x_g*W-x_b*B)*cos(eta(5))*cos(eta(4));
           -(x_g*W-x_b*B)*cos(eta(5))*sin(eta(4)) - ...
              (y_g*W-y_b*B)*sin(eta(5)) ];

%% РАСЧЕТ D(v)
D = @(v)(D_LIN + D_QUAD .* diag(abs(v)));

%% МОДЕЛИРОВАНИЕ ДВИЖЕНИЯ ПРИ ПРЕДОПРЕДЕЛЕННОМ СИЛОВОМ ВОЗДЕЙСТВИИ
eta0 = [0; 0; 0; 0; 0; 0]; 
v0 = [0; 0; 0; 0; 0; 0];
tau = [2; 0; 0; 0; 0; 0];
fe = [0; 0; 2; 0; 0; 0];
t_end = 60; dt = 0.01;
[t,Y] = ode45(@(t,y)odefcn(t,y,M,C,D,g,J,tau,fe), 0:dt:t_end, [eta0; v0]);

%% ПОСТРОЕНИЯ ГРАФИКОВ
figure
v = Y(:,7:end);
subplot(2,2,1), title('Скорости (линейные)'), hold on, grid on
plot(t, v(:,1:3)), xlabel('t, сек'), ylabel('Скорость, м/c'), xlim([0 t_end])
legend('u(t)', 'v(t)', 'w(t)', 'Location', 'Best')
subplot(2,2,2), title('Скорости (угловые)'), hold on, grid on
plot(t, v(:,4:end)), xlabel('t, сек'), ylabel('Скорость, рад/c'), xlim([0 t_end])
legend('p(t)', 'q(t)', 'r(t)', 'Location', 'Best')
eta = Y(:,1:6);
subplot(2,2,3), title('Положения (по осям)'), hold on, grid on
plot(t, eta(:,1:3)), xlabel('t, сек'), ylabel('Положения, м'), xlim([0 t_end])
legend('x(t)', 'y(t)', 'z(t)', 'Location', 'Best')
subplot(2,2,4), title('Ориентация (углы Эйлера)'), hold on, grid on
plot(t, eta(:,4:end)), xlabel('t, сек'), ylabel('Положения, рад'), xlim([0 t_end])
legend('\phi(t)', '\theta(t)', '\psi(t)', 'Location', 'Best')

figure, plot3(eta(:,1), eta(:,2), eta(:,3)), title('Позиционирование ПА')
hold on
plot3(eta(end,1), eta(end,2), eta(end,3), 'rO') 
legend('траектория ПА', 'желаемое положение', 'Location', 'Best')
xlabel('x(t)'), ylabel('y(t)'), zlabel('z(t)'), grid on
set(gca, 'ZDir', 'reverse');
set(gca, 'YDir', 'reverse');
axis equal
legend('off')
