%% ПАРАМЕТРЫ МОДЕЛИРОВАНИЯ
t = 0:0.01:120;
lat_usbl = linspace(30,30,numel(t)) + 0.5e-6 .* sin(t/2.5);
lon_usbl = linspace(40,40,numel(t)) + 1.0e-6 .* sin(t/2.5);
phi_usbl = 0.15 * sin(t/2.5);
theta_usbl = 0.15 * cos(t/2.5);
psi_usbl = t .* 0.001;
origin = [lat_usbl(1), lon_usbl(1), 0];
d_usbl = 0;
d_obj = 4;
r_s = exp(t/35) + 7.5;
alpha = deg2rad(t);

%% ПРОЦЕДУРА РАСЧЕТА
Rx = @(phi)[1 0 0; 0 cos(phi) -sin(phi); 0 sin(phi) cos(phi)];
Ry = @(theta)[cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
Rz = @(psi)[cos(psi) -sin(psi) 0; sin(psi) cos(psi) 0; 0 0 1];
r_v = t;
r_h = t;
x_obj = t;
y_obj = t;
x_obj_corr = t;
y_obj_corr = t;
x_usbl = t;
y_usbl = t;
for i=1:numel(t)
    r_v(i) = [0 0 1] * Ry(theta_usbl(i)) * Rx(phi_usbl(i)) * [0; 0; d_obj - d_usbl];
    r_h(i) = sqrt(r_s(i)^2 - r_v(i)^2);
    dx = r_h(i) * sin(alpha(i));
    dy = r_h(i) * cos(alpha(i));
    [x_usbl(i), y_usbl(i)] = geo2ned(lat_usbl(i), lon_usbl(i), 0, origin);
    x_obj(i) = x_usbl(i) + dx;
    y_obj(i) = y_usbl(i) + dy;
    tmp = (Rz(psi_usbl(i)) * Ry(theta_usbl(i)) * Rx(phi_usbl(i)))' * [x_obj(i); y_obj(i); 0];
    x_obj_corr(i) = tmp(1);
    y_obj_corr(i) = tmp(2);
end

%% ПОСТРОЕНИЕ ГРАФИКОВ
figure
subplot(1,2,1)
plot(x_usbl, y_usbl)
title('USBL Position')
xlabel('East, m')
ylabel('North, m')
axis('equal');
grid on
subplot(1,2,2)
plot(x_obj, y_obj)
hold on
plot(x_obj_corr, y_obj_corr)
title('Object Position')
xlabel('East, m')
ylabel('North, m')
axis('equal');
legend('false position', 'true position')
grid on

function [X, Y, Z] = geo2ecef(lat, lon, alt)
    a = 6378137.0;
    b = 6356752.3142;
    B = deg2rad(lat);
    L = deg2rad(lon);
    H = alt;
    e2 = (a^2 - b^2) / a^2;
    NB = a / sqrt(1 - e2*sin(B)^2);
    X = (NB + H) * cos(B) * cos(L);
    Y = (NB + H) * cos(B) * sin(L);
    Z = ((b/a)^2 * NB + H) * sin(B);
end

% Converts the Earth-Centered Earth-Fixed (ECEF) coordinates (x, y, z) to 
% East-North-Up coordinates in a Local Tangent Plane that is centered at the 
% (WGS-84) Geodetic point (lat0, lon0, h0).
function [X, Y, Z] = ecef2ned(x, y, z, lat0, lon0, alt0)
    B = deg2rad(lat0);
    L = deg2rad(lon0);
    [x0, y0, z0] = geo2ecef(lat0, lon0, alt0);
    xd = x - x0;
    yd = y - y0;
    zd = z - z0;
    X = -sin(L) * xd + cos(L) * yd;
    Y = -cos(L) * sin(B) * xd - sin(B) * sin(L) * yd + cos(B) * zd;
    Z = cos(B) * cos(L) * xd + cos(B) * sin(L) * yd + sin(B) * zd;
end

function [X, Y, Z] = geo2ned(lat, lon, alt, origin)
    [x, y, z] = geo2ecef(lat, lon, alt);
    [X, Y, Z] = ecef2ned(x, y, z, origin(1), origin(2), origin(3));
end