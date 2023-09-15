%% OBJECT PARAMETERS (AUV)
obj = load('geoRoute.mat');
alt = 0;
origin = [obj.latitude(1), obj.longitude(1), alt];
[xEast, yNorth] = latlon2local(obj.latitude, obj.longitude, alt, origin);

figure;
plot(xEast, yNorth)
axis('equal'); % set 1:1 aspect ratio to see real-world shapes

%% ROTATION MATRICES
Rx = @(phi)[1 0 0; 0 cos(phi) -sin(phi); 0 sin(phi) cos(phi)];
Ry = @(theta)[cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
Rz = @(psi)[cos(psi) -sin(psi) 0; sin(psi) cos(psi) 0; 0 0 1];
R = @(phi,theta,psi)[Rz(phi)*Ry(theta)*Rx(psi)]; % TODO

%% SERIAL PORT
serial_list = serialportlist("available");
serial = serialport(serial_list(1), 115200, "Timeout", 5);

while (true)
    line = serial.readline();
    euler = sscanf(line, "phi:%f,theta:%f,psi:%f");
    if (length(euler) == 3)
        euler(3) = 0; % TODO
        display(euler)
        euler = deg2rad(euler);
        rotation = R(euler(3),euler(2),euler(1));

        p1 = rotation*[-2 -2 0]';
        p2 = rotation*[2 -2 0]';
        p3 = rotation*[2 2 0]';
        p4 = rotation*[-2 2 0]'; 
        
        x = [p1(1) p2(1) p3(1) p4(1)];
        y = [p1(2) p2(2) p3(2) p4(2)];
        z = [p1(3) p2(3) p3(3) p4(3)];
        
        refresh
        fill3(x, y, z, 1);

% hold on
% p1 = rotation'*p1;
% p2 = rotation'*p2;
% p3 = rotation'*p3;
% p4 = rotation'*p4;       
% x = [p1(1) p2(1) p3(1) p4(1)];
% y = [p1(2) p2(2) p3(2) p4(2)];
% z = [p1(3) p2(3) p3(3) p4(3)];
% fill3(x, y, z, 2);
% hold off
        xlabel('x'); ylabel('y'); zlabel('z'); 
        axis([-5 5 -5 5 -4 4])
        grid on
        drawnow
    end
    serial.flush();
end

function position = positionCorrection(usbl_depth, usbl_euler, usbl_latitude, usbl_longitude, usbl_range, usbl_bearing, auv_depth)
    persistent origin;
    position = zeros(3,1);
    
    r_V = R(usbl_euler(3),usbl_euler(2),usbl_euler(1)) * [0; 0; auv_depth - usbl_depth];
    r_V = [0 0 1] * r_V;
    r_H = sqrt(usbl_range^2 - r_V^2);
    if isempty(origin)
        origin = [usbl_latitude, usbl_longitude, 0];
    end
    [usbl_y, usbl_x] = latlon2local(usbl_latitude, usbl_longitude, 0, origin);
    dy = r_H*sin(usbl_bearing);
    dx = r_H*cos(usbl_bearing);
    position(1) = usbl_x + dx;
    position(2) = usbl_y + dy;
    position = R(usbl_euler(3),usbl_euler(2),usbl_euler(1))' * position;
    position(3) = auv_depth;
end