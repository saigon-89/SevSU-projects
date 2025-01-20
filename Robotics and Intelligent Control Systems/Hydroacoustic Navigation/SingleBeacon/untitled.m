P1 = @(xm, ym, xs, ys, rh) [ xm + (rh*(xs-xm)) / sqrt((xs-xm)^2 + (ys-ym)^2); ...
                             ym + (rh*(ys-ym)) / sqrt((xs-xm)^2 + (ys-ym)^2) ];
P2 = @(xm, ym, xs, ys, rh) [ xm - (rh*(xs-xm)) / sqrt((xs-xm)^2 + (ys-ym)^2); ...
                             ym - (rh*(ys-ym)) / sqrt((xs-xm)^2 + (ys-ym)^2) ];

% Входные данные
xm = 4; ym = 4; % положение маяка приемника
xs_prev = 5; ys_prev = 7; % предыдущее положение ответчика
rh = 2; % горизонтальная дальность (радиус)
vs_prev = [1; 0]; % скорость 1 м/с прямо по курсу
alpha = -pi/2; % угол курса
dt = 1; % время между посылками

% Тут корректируем положение по скорости
vs_prev_ned = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)] * vs_prev;
offset = vs_prev_ned / dt;
xs_pred = xs_prev + offset(1);
ys_pred = ys_prev + offset(2);

% Две возможные точки
p1 = P1(xm, ym, xs_pred, ys_pred, rh);
p2 = P2(xm, ym, xs_pred, ys_pred, rh);

% Две нормы
n = [ norm(p1 - [xs_pred; ys_pred]); ... 
      norm(p2 - [xs_pred; ys_pred]) ];

% Ищем минимальную
[~, idx] = min(n);
if (idx == 1)
    xs_new = p1(1); ys_new = p1(2);
else
    xs_new = p2(1); ys_new = p2(1);
end

center = [xm ym];
radii = rh;
viscircles(center, radii, 'LineWidth', 1);
axis equal
hold on
plot(xs_prev, ys_prev, 'O', 'LineWidth', 2)
plot(xs_pred, ys_pred, 'O', 'LineWidth', 2)
plot(xs_new, ys_new, 'X', 'LineWidth', 2)
legend('previous', 'predicted', 'new')
grid on