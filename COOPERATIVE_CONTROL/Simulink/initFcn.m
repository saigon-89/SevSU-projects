close all

cd '..'\Matlab\
run('auv_param.m')
cd '..'\Simulink\

S = @(x)([ 0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0 ]);

M_RB = [ m*eye(3)    m*S(r_g_b); ...
         m*S(r_g_b)  I0 ]; 
M = M_RB + M_A;

D_LIN = 1;
D_QUAD = 1;

range = 2;