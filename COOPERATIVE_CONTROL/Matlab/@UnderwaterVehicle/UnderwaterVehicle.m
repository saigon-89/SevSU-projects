classdef UnderwaterVehicle
    %UNDERWATERVEHICLE Класс для работы с моделями подводных аппаратов
    %   Класс содержит методы для работы с кинематикой и пересчетом
    %   параметров динамики

    properties
        m     (1,1) double {mustBeReal} % Масса аппарата [кг]
        B     (1,1) double {mustBeReal} % Плавучесть аппарата [Н]
        r_b_b (3,1) double {mustBeReal} % Вектор центра плавучести [м]
        r_g_b (3,1) double {mustBeReal} % Вектор центра масс [м]
        I0    (3,3) double {mustBeReal} % Тензор инерции [кг * м^2]
        M_RB = zeros(6,6) % Матрица инерции твердого тела
        M_A = zeros(6,6)  % Матрица присоединенных масс
        M = zeros(6,6)    % Матрица инерции подводного аппарата
        ThrusterAllocationMatrix
        ThrusterStaticCharacteristic
    end

    methods (Static)
        function obj = UnderwaterVehicle(m,r_g_b,B,r_b_b,I0,M_A,ThrusterAllocationMatrix,ThrusterStaticCharacteristic)
            %UNDERWATERVEHICLE Конструктор класса
            %   Detailed explanation goes here
            obj.m = m;
            obj.r_g_b = r_g_b;
            obj.B = B;
            obj.r_b_b = r_b_b;
            obj.I0 = I0;
            if nargin > 5
                obj.M_A = M_A;
            end
            if nargin > 6
                obj.ThrusterAllocationMatrix = ThrusterAllocationMatrix;
                obj.ThrusterStaticCharacteristic = ThrusterStaticCharacteristic;
            end
            S = @(x)([ 0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0 ]);
            obj.M_RB = [ obj.m*eye(3)       -obj.m*S(obj.r_g_b); ...
                         obj.m*S(obj.r_g_b)  obj.I0 ]; 
        end

        function J = J_k_o(eta)
            arguments
                eta (6,1) {mustBeReal} % Вектор положения и ориентации
            end
            %J_k_o Якобиан для вращательных степеней свободы
            %   Detailed explanation goes here
            J = [ 1  0           -sin(eta(5)); ...
                  0  cos(eta(4))  cos(eta(5))*sin(eta(4)); ...
                  0 -sin(eta(4))  cos(eta(5))*cos(eta(4)) ];
        end

        function R = R_I_B(eta)
            arguments
                eta (6,1) {mustBeReal} % Вектор положения и ориентации
            end
            %R_I_B Матрица поворота из инерциальной системы в систему тела
            %   Detailed explanation goes here
            R = [ cos(eta(6))*cos(eta(5))                                        sin(eta(6))*cos(eta(5))                                       -sin(eta(5)); ...
                 -sin(eta(6))*cos(eta(4)) + cos(eta(6))*sin(eta(5))*sin(eta(4))  cos(eta(6))*cos(eta(4)) + sin(eta(6))*sin(eta(5))*sin(eta(4))  sin(eta(4))*cos(eta(5)); ...
                  sin(eta(6))*sin(eta(4)) + cos(eta(6))*sin(eta(5))*cos(eta(4)) -cos(eta(6))*sin(eta(4)) + sin(eta(6))*sin(eta(5))*cos(eta(4))  cos(eta(4))*cos(eta(5)) ];
        end

        function J = J(eta)
            arguments
                eta (6,1) {mustBeReal} % Вектор положения и ориентации
            end
            %J Якобиан перехода из инерциальной системы в систему тела
            %   Detailed explanation goes here
            J_k_o = [ 1  0           -sin(eta(5)); ...
                      0  cos(eta(4))  cos(eta(5))*sin(eta(4)); ...
                      0 -sin(eta(4))  cos(eta(5))*cos(eta(4)) ];
            R = [ cos(eta(6))*cos(eta(5))                                        sin(eta(6))*cos(eta(5))                                       -sin(eta(5)); ...
                 -sin(eta(6))*cos(eta(4)) + cos(eta(6))*sin(eta(5))*sin(eta(4))  cos(eta(6))*cos(eta(4)) + sin(eta(6))*sin(eta(5))*sin(eta(4))  sin(eta(4))*cos(eta(5)); ...
                  sin(eta(6))*sin(eta(4)) + cos(eta(6))*sin(eta(5))*cos(eta(4)) -cos(eta(6))*sin(eta(4)) + sin(eta(6))*sin(eta(5))*cos(eta(4))  cos(eta(4))*cos(eta(5)) ];
            J = [ R          zeros(3,3); ...
                  zeros(3,3) J_k_o ];
        end

        function g = g(obj,eta)
            %g Вектор гравитационных сил и плавучести
            %   Detailed explanation goes here
            m = obj.m;
            B = obj.B;
            x_g = obj.r_g_b(1); y_g = obj.r_g_b(2); z_g = obj.r_g_b(3);
            x_b = obj.r_b_b(1); y_b = obj.r_b_b(2); z_b = obj.r_b_b(3);
            g = [ (m*9.81-B)*sin(eta(5)); 
                 -(m*9.81-B)*cos(eta(5))*sin(eta(4)); 
                 -(m*9.81-B)*cos(eta(5))*cos(eta(4));
                 -(y_g*m*9.81-y_b*B)*cos(eta(5))*cos(eta(4)) + ...
                    (z_g*m*9.81-z_b*B)*cos(eta(5))*sin(eta(4));
                  (z_g*m*9.81-z_b*B)*sin(eta(5)) + ...
                    (x_g*m*9.81-x_b*B)*cos(eta(5))*cos(eta(4));
                 -(x_g*m*9.81-x_b*B)*cos(eta(5))*sin(eta(4)) - ...
                    (y_g*m*9.81-y_b*B)*sin(eta(5)) ];
        end

        function C = C_RB(obj,v)
            %C_RB Матрица Кориолиса твердого тела
            %   Detailed explanation goes here
            m = obj.m;
            I0 = obj.I0;
            r_g_b = obj.r_g_b;   
            S = @(x)([ 0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0 ]);
            C = [ zeros(3)                           -m*S(v(1:3))-m*S(S(v(4:end))*r_g_b); ...
                 -m*S(v(1:3))-m*S(S(v(4:end))*r_g_b)  m*S(S(v(1:3))*r_g_b)-S(I0*v(4:end)) ];
        end

        function C = C_A(obj,v)
            %C_A Матрица Кориолиса для присоединенных масс
            %   Detailed explanation goes here
            diag_M_A = diag(obj.M_A);
            S = @(x)([ 0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0 ]);
            C = [ zeros(3)                 -S(diag_M_A(1:3).*v(1:3)); ...
                 -S(diag_M_A(1:3).*v(1:3)) -S(diag_M_A(4:end).*v(4:end)) ];
        end
        
        function C = C(obj,v)
            %C Матрица Кориолиса подводного аппарата
            %   Detailed explanation goes here
            C = obj.C_RB(obj,v) + obj.C_A(obj,v);
        end

        function dv = DirectDynamics(obj,v,eta,tau,he)
            %DIRECTDYNAMICS Пересчет ускорений подводного аппарата
            %   Detailed explanation goes here
            if isempty(obj.ThrusterAllocationMatrix)
                if nargin < 5
                    he = zeros(6,1);
                end
                dv = obj.M\(tau+obj.J(obj,eta)*he-obj.C(obj,v)*v-obj.g(obj,eta));
            end
        end
        function deta = DirectKinematics(obj,v,eta)
            %DIRECTKINEMATICS Кинематика подводного аппарата
            %   Detailed explanation goes here
            deta = obj.J(obj,eta)^-1*v;
        end
    end

    methods
        function obj = set.M_A(obj,val)
            obj.M_A = val;
        end

        function obj = set.B(obj,val)
            obj.B = val;
        end

        function M = get.M(obj)
            M = obj.M_RB + obj.M_A;
        end
    end
end