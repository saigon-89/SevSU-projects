%% MMT parameters
L = 3081; % Длина ROV [mm]
H = 295; % Высота ROV [mm]
rho = 1000; % Плотность жидкости [kg/m^3]
m = 150; % Масса ROV [kg]

r_b_b = [0; 0; -0.15];
r_g_b = [0; 0; 0.15];
r_b_b = r_b_b / 10^3; % переводим [mm] в [m]
r_g_b = r_g_b / 10^3; % переводим [mm] в [m]
B = m * 9.81;

l = L * 10^-3;
r = 0.5*H * 10^-3;
I0  = (m/12).*diag([ 6*r^2 (3*r^2 + l^2) (3*r^2 + l^2) ]);

M_A = cylindrical_added_mass(m, (H/2)*10^-3, L*10^-3, rho); 

MMT300 = UnderwaterVehicle(m,r_g_b,B,r_b_b,I0,M_A);

%% THRUSTER ALLOCATION
load('thrusters-load.mat')
x = Code;
y = F;
p = polyfit(x,y,6);
% f = polyval(p,x);
% plot(x,y,x,f,'--')
% legend('Data','Polynomial fit')
% xlabel("Code"), ylabel("Newtons, N(Code)")
% grid on

F = @(code)polyval(p,code);

f1 = @(code)[ F(code)*cos(deg2rad(22)); 
              0; 
              F(code)*sin(deg2rad(22)) ];
f2 = @(code)[ F(code)*cos(deg2rad(22)); 
              F(code)*sin(deg2rad(22));
              0 ];
f3 = @(code)[ F(code)*cos(deg2rad(22)); 
              0; 
              -F(code)*sin(deg2rad(22)) ];
f4 = @(code)[ F(code)*cos(deg2rad(22));  
              -F(code)*sin(deg2rad(22));
              0 ];
f5 = @(code)[ 0; 
              F(code); 
              0 ];
f6 = @(code)[ 0; 
              0; 
              -F(code) ];

T = [ -1330,  0,    189; 
      -1330,  159,  30;
      -1330,  0,   -129;
      -1330, -159,  30;
       1330,  0,    30;
       882,   0,    30 ] .* 10^-3;

r1 = T(1,:)'; 
r2 = T(2,:)'; 
r3 = T(3,:)';
r4 = T(4,:)';
r5 = T(5,:)';
r6 = T(6,:)';
tau1 = @(code)[ f1(code); cross(r1, f1(code)) ];
tau2 = @(code)[ f2(code); cross(r2, f2(code)) ];
tau3 = @(code)[ f3(code); cross(r3, f3(code)) ];
tau4 = @(code)[ f4(code); cross(r4, f4(code)) ];
tau5 = @(code)[ f5(code); cross(r5, f5(code)) ];
tau6 = @(code)[ f6(code); cross(r6, f6(code)) ];

tau_c = @(code)[ tau1(code(1)), tau2(code(2)), tau3(code(3)), ...
                 tau4(code(4)), tau5(code(5)), tau6(code(6)) ];
