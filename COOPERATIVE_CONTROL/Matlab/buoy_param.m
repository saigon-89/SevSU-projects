m_buoy = 10;
l_buoy = 0.5;
r_buoy = 0.15;

r_g_b_buoy = [0; 0; 0];
r_b_b_buoy = [0; 0; -0.2];

B_buoy = m_buoy*9.81;

I0_buoy = (m_buoy/12).*diag([ (3*r_buoy^2 + l_buoy^2) (3*r_buoy^2 + l_buoy^2) 6*r_buoy^2 ]);

S = @(x)([ 0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0 ]); 

M_A_buoy = cylindrical_added_mass(m_buoy, r_buoy, l_buoy, rho); 