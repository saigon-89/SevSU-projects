function A = cylindrical_added_mass(m, r, l, rho)

    if nargin < 4
       rho = 1000; 
    end
    
    A = zeros(6,6);

    A(1,1) = 0.1*m;
    A(2,2) = pi*rho*r^2*l;
    A(3,3) = A(2,2);
    A(4,4) = 0;
    A(5,5) = (1/12)*pi*rho*r^2*l^3;
    A(6,6) = A(5,5);
    
end
