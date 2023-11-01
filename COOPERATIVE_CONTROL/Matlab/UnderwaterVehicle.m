classdef UnderwaterVehicle
    %UNDERWATERVEHICLE Класс для работы с моделями подводных аппаратов
    %   Класс содержит методы для работы с кинематикой и пересчетом
    %   параметров динамики

    properties
        m     (1,1) double {mustBeReal} % масса аппарата [кг]
        B     (1,1) double {mustBeReal} % плавучесть аппарата [Н]
        r_b_b (3,1) double {mustBeReal} % вектор центра плавучести [м]
        r_g_b (3,1) double {mustBeReal} % вектор центра масс [м]
        I0    (3,3) double {mustBeReal} % тензор инерции [кг * м^2]
        ThrusterAllocationMatrix
        ThrusterStaticCharacteristic
        M_RB
        M_A
        M
    end

    methods (Static)
        function obj = UnderwaterVehicle(m,r_b_b,r_g_b,I0)
            %UNDERWATERVEHICLE Конструктор класса
            %   Detailed explanation goes here
            obj.m = m;
            obj.r_b_b = r_b_b;
            obj.r_g_b = r_g_b;
            obj.I0 = I0;
            S = @(x)([ 0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0 ]);
            obj.M = [ obj.m*eye(3) -obj.m*S(obj.r_g_b); obj.m*S(obj.r_g_b) obj.I0 ]; 
        end

        function J = J_k_o(eta)
            arguments
                eta (6,1) {mustBeReal}
            end
            %J_k_o Якобиан для вращательных степеней свободы
            %   Detailed explanation goes here
            J = [ 1  0           -sin(eta(5)); ...
                  0  cos(eta(4))  cos(eta(5))*sin(eta(4)); ...
                  0 -sin(eta(4))  cos(eta(5))*cos(eta(4)) ];
        end

        function R = R_I_B(eta)
            arguments
                eta (6,1) {mustBeReal}
            end
            %R_I_B Матрица поворота из инерциальной системы в систему тела
            %   Detailed explanation goes here
            R = [ cos(eta(6))*cos(eta(5))                                        sin(eta(6))*cos(eta(5))                                       -sin(eta(5)); ...
                 -sin(eta(6))*cos(eta(4)) + cos(eta(6))*sin(eta(5))*sin(eta(4))  cos(eta(6))*cos(eta(4)) + sin(eta(6))*sin(eta(5))*sin(eta(4))  sin(eta(4))*cos(eta(5)); ...
                  sin(eta(6))*sin(eta(4)) + cos(eta(6))*sin(eta(5))*cos(eta(4)) -cos(eta(6))*sin(eta(4)) + sin(eta(6))*sin(eta(5))*cos(eta(4))  cos(eta(4))*cos(eta(5)) ];
        end

        function J = J(eta)
            arguments
                eta (6,1) {mustBeReal}
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
            m = obj.m;
            I0 = obj.I0;
            r_g_b = obj.r_g_b;   
            S = @(x)([ 0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0 ]);
            C = [ zeros(3)                           -m*S(v(1:3))-m*S(S(v(4:end))*r_g_b); ...
                 -m*S(v(1:3))-m*S(S(v(4:end))*r_g_b)  m*S(S(v(1:3))*r_g_b)-S(I0*v(4:end)) ];
        end
    end

    methods

    end
end