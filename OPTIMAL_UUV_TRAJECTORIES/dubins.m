%% SNAME-NOTATION
syms x y z phi theta psi
syms u v w p q r

nu = [u; v; w; p; q; r];
eta = [x; y; z; phi; theta; psi];

%% QUINTIC POLYNOMIAL TRAJECTORY
syms x0 y0 z0 phi0 theta0 psi0
syms x_end y_end z_end phi_end theta_end psi_end
syms u0 v0 w0 p0 q0 r0
syms u_end v_end w_end p_end q_end r_end
syms M N P
syms t0 t_end

T = [ 1     t0     t0^2       t0^3        t0^4; ...
      0      1     2*t0     3*t0^2      4*t0^3; ...
      1  t_end  t_end^2    t_end^3     t_end^4; ...
      0      1  2*t_end  3*t_end^2   4*t_end^3; ...
      0      0        2    6*t_end  12*t_end^2 ];

%% JACOBIAN MATRIX
J_k_o = @(eta)[ 1            0             -sin(eta(5)); ...
                0  cos(eta(4))  cos(eta(5))*sin(eta(4)); ...
                0 -sin(eta(4))  cos(eta(5))*cos(eta(4)) ];

R_I_B = @(eta)[                                        cos(eta(6))*cos(eta(5))                                         sin(eta(6))*cos(eta(5))             -sin(eta(5)); ...
                -sin(eta(6))*cos(eta(4)) + cos(eta(6))*sin(eta(5))*sin(eta(4))   cos(eta(6))*cos(eta(4)) + sin(eta(6))*sin(eta(5))*sin(eta(4))  sin(eta(4))*cos(eta(5)); ...
                 sin(eta(6))*sin(eta(4)) + cos(eta(6))*sin(eta(5))*cos(eta(4))  -cos(eta(6))*sin(eta(4)) + sin(eta(6))*sin(eta(5))*cos(eta(4))  cos(eta(4))*cos(eta(5)) ];

J = @(eta)[ R_I_B(eta)    zeros(3); ...
              zeros(3)  J_k_o(eta) ];

eta0 = [x0; y0; z0; phi0; theta0; psi0];
eta_end = [x_end; y_end; z_end; phi_end; theta_end; psi_end];

nu0 = [u0; v0; w0; p0; q0; r0];
nu_end = [u_end; v_end; w_end; p_end; q_end; r_end];

deta0 = simplify( J(eta0) \ nu0 );
deta_end = simplify( J(eta_end) \ nu_end );

TRACKS.px = simplify( T \ [eta0(1); deta0(1); eta_end(1); deta_end(1); M] );
TRACKS.py = simplify( T \ [eta0(2); deta0(2); eta_end(2); deta_end(2); N] );
TRACKS.pz = simplify( T \ [eta0(3); deta0(3); eta_end(3); deta_end(3); P] );
%TRACKS.pz = 0; %% TODO

TRACKS.pxf = matlabFunction(TRACKS.px, 'vars', {eta0, nu0, eta_end, nu_end, M, t0, t_end});
TRACKS.pyf = matlabFunction(TRACKS.py, 'vars', {eta0, nu0, eta_end, nu_end, N, t0, t_end});
TRACKS.pzf = matlabFunction(TRACKS.pz, 'vars', {eta0, nu0, eta_end, nu_end, P, t0, t_end});

UUV1.eta0 = [0; 0; 0; 0; 0; 0];
UUV1.nu0 = [0; 0; 0; 0; 0; 0];
UUV1.eta_end = [10; 0; 5; 0; 0; 0];
UUV1.nu_end = [0; 0; 0; 0; 0; 0];

UUV2.eta0 = [-2; -1; 0; 0; 0; 0];
UUV2.nu0 = [0; 0; 0; 0; 0; 0];
UUV2.eta_end = [10; 2; 5; 0; 0; 0];
UUV2.nu_end = [0; 0; 0; 0; 0; 0];

UUV3.eta0 = [-2; 1; 0; 0; 0; 0];
UUV3.nu0 = [0; 0; 0; 0; 0; 0];
UUV3.eta_end = [12; 1; 5; 0; 0; 0];
UUV3.nu_end = [0; 0; 0; 0; 0; 0];

UUV4.eta0 = [-4; -1; 0; 0; 0; 0];
UUV4.nu0 = [0; 0; 0; 0; 0; 0];
UUV4.eta_end = [12; 5; 5; 0; 0; 0];
UUV4.nu_end = [0; 0; 0; 0; 0; 0];

FORMATION = [UUV1; UUV2; UUV3; UUV4];

t = 0:0.01:10;

[ENV.X, ENV.Y] = meshgrid(-4:0.2:12.09, -1:0.2:5.608);
ENV.Z = exp(ENV.X ./ 30) .* (sin(ENV.X) + cos(ENV.Y) + 6);

% Pass fixed parameters to objfun
objfun = @(x)objectiveFcn(x, FORMATION, TRACKS, ENV, t);

% Set nondefault solver options
options = optimoptions("particleswarm", "PlotFcn", "pswplotbestf", 'MaxIterations', 50);

n = numel(FORMATION);
m = 3; % parameters to optimize

% Solve
[solution, objectiveValue] = particleswarm(objfun, m * n, repmat(0.01, m * n, 1), ones(m * n, 1), options);

M_set = solution(1:n);
N_set = solution(n+1:2*n);
P_set = solution(2*n+1:3*n);

FORMATION = update_iteration(FORMATION, TRACKS, ENV, M_set, N_set, P_set, t);

figure
legend
set(gca, 'YDir', 'reverse');
set(gca, 'ZDir', 'reverse');
view([-1, 1, 1])
axis equal
xlabel('x, m')
ylabel('y, m')
zlabel('z, m')
grid on
hold on
for i = 1:numel(FORMATION)
    name = sprintf('UUV%d', i);
    plot3(FORMATION(i).x, FORMATION(i).y, FORMATION(i).z, 'DisplayName', name)
    plot3(FORMATION(i).eta_end(1), FORMATION(i).eta_end(2), FORMATION(i).eta_end(3), ...
        'rO', 'HandleVisibility', 'off')
end

x_gen = [];
y_gen = [];
z_gen = [];
for i = 1:numel(FORMATION)
    x_gen = [x_gen, FORMATION(i).x];
    y_gen = [y_gen, FORMATION(i).y];
    z_gen = [z_gen, FORMATION(i).z];
end

min_x = min(x_gen);
min_y = min(y_gen);
min_z = min(z_gen);
max_x = max(x_gen);
max_y = max(y_gen);
max_z = max(z_gen);

colormap copper
mesh(ENV.X, ENV.Y, ENV.Z, 'HandleVisibility', 'off')
zlim([0; max(ENV.Z(:)) + 1])

X = [min_x max_x max_x min_x min_x max_x max_x min_x];
Y = [min_y min_y max_y max_y min_y min_y max_y max_y];
Z = [max(ENV.Z(:)) max(ENV.Z(:)) max(ENV.Z(:)) max(ENV.Z(:)) 0 0 0 0];

faces = [ 1 2 3 4; ...
          5 6 7 8; ...
          1 2 6 5; ...
          2 3 7 6; ...
          3 4 8 7; ...
          4 1 5 8; ];

for i = 1:size(faces, 1)
    patch('Vertices', [X' Y' Z'], 'Faces', faces(i,:), ...
        'FaceColor', [0 0 1], 'FaceAlpha', 0.025, ...
        'HandleVisibility', 'off', 'EdgeColor', 'None');
end

xlim([min_x - 1; max_x + 1])
ylim([min_y - 1; max_y + 1])

function f = objectiveFcn(x, FORMATION, TRACKS, ENV, t)
    n = numel(FORMATION);
    M_set = x(1:n);
    N_set = x(n+1:2*n);
    P_set = x(2*n+1:3*n);
    FORMATION = update_iteration(FORMATION, TRACKS, ENV, M_set, N_set, P_set, t);
    L = 0;
    C = 0;
    D_min = 0;
    D_max = 0;
    V_min = 0;
    V_max = 0;
    for i = 1:numel(FORMATION)
        L = L + FORMATION(i).l;
        D_min = D_min + FORMATION(i).d_min;
        D_max = D_max + FORMATION(i).d_max;
        V_min = V_min + FORMATION(i).V_min;
        V_max = V_max + FORMATION(i).V_max;
        if FORMATION(i).collision
            C = C + 10000;
        end
    end
    f = L - 1500 * D_min + 100 * D_max - 1000 * V_min + 1000 * V_max + C;
end

function FORMATION = update_iteration(FORMATION, TRACKS, ENV, M_set, N_set, P_set, t)
    for i = 1:numel(FORMATION)
        FORMATION(i).px = TRACKS.pxf(FORMATION(i).eta0, FORMATION(i).nu0, FORMATION(i).eta_end, FORMATION(i).nu_end, M_set(i), t(1), t(end));
        FORMATION(i).py = TRACKS.pyf(FORMATION(i).eta0, FORMATION(i).nu0, FORMATION(i).eta_end, FORMATION(i).nu_end, N_set(i), t(1), t(end));
        FORMATION(i).pz = TRACKS.pzf(FORMATION(i).eta0, FORMATION(i).nu0, FORMATION(i).eta_end, FORMATION(i).nu_end, P_set(i), t(1), t(end));

        FORMATION(i).px = flip(FORMATION(i).px);
        FORMATION(i).py = flip(FORMATION(i).py);
        FORMATION(i).pz = flip(FORMATION(i).pz);
    
        FORMATION(i).pdx = polyder(FORMATION(i).px);
        FORMATION(i).pdy = polyder(FORMATION(i).py);
        FORMATION(i).pdz = polyder(FORMATION(i).pz);
    end
    
    for i = 1:numel(FORMATION)
        FORMATION(i).x = polyval(FORMATION(i).px, t);
        FORMATION(i).y = polyval(FORMATION(i).py, t);
        FORMATION(i).z = polyval(FORMATION(i).pz, t);
    
        FORMATION(i).u = polyval(FORMATION(i).pdx, t);
        FORMATION(i).v = polyval(FORMATION(i).pdy, t);
        FORMATION(i).w = polyval(FORMATION(i).pdz, t);
    
        V = zeros(1, numel(t));
        for j = 1:numel(t)
           V(j) = norm([FORMATION(i).u(j), FORMATION(i).v(j), FORMATION(i).w(j)]);
        end
        FORMATION(i).V_max = max(V);
        FORMATION(i).V_min = min(V);
    end
    
    for i = 1:numel(FORMATION)
        D = zeros(numel(FORMATION), numel(t));
        for j = 1:numel(t)
            for k = 1:numel(FORMATION)
                if k == i
                    D(k, j) = NaN;
                else
                    D(k, j) = norm([FORMATION(i).x(j) - FORMATION(k).x(j), ...
                        FORMATION(i).y(j) - FORMATION(k).y(j), ...
                        FORMATION(i).z(j) - FORMATION(k).z(j)]);
                end
            end
        end
        FORMATION(i).d_max = max(D(:));
        FORMATION(i).d_min = min(D(:));
    end
    
    for i = 1:numel(FORMATION)
        L = 0;
        for j = 2:numel(t)
            L = L + norm([FORMATION(i).x(j) - FORMATION(i).x(j - 1), ...
                FORMATION(i).y(j) - FORMATION(i).y(j - 1), ...
                FORMATION(i).z(j) - FORMATION(i).z(j - 1)]);
        end
        FORMATION(i).l = L;
    end

    for i = 1:numel(FORMATION)
        FORMATION(i).collision = false;
        z_env = interp2(ENV.X, ENV.Y, ENV.Z, FORMATION(i).x, FORMATION(i).y);
        if any(FORMATION(i).z > z_env) || any(FORMATION(i).z < 0)
            FORMATION(i).collision = true;
        end
    end
end
