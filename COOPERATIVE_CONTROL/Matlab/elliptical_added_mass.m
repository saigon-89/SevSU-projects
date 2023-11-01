function A = elliptical_added_mass(l, W)
% l - длина боевой части
% W - объем боевой части

    if nargin < 4
       rho = 1000; 
    end

    A = zeros(6,6);
    
    a = l/2;
    b = sqrt((3*W)/(4*pi*a));
    m = (4/3)*pi*a*b^2;
    J = (4/15)*pi*rho*a*b^2*(a^2+b^2);

    EMP_LAMBDA11 = [0, 0; 0.2, 0.05; 0.3, 0.1; 0.4, 0.17; 0.6, 0.27; 0.8, 0.4; 1, 0.5];
    LAMBDA11 = spline(EMP_LAMBDA11(:,1), EMP_LAMBDA11(:,2));

    EMP_LAMBDA22 = [0, 1; 0.2, 0.9; 0.4, 0.78; 0.6, 0.63; 0.8, 0.57; 1, 0.5];
    LAMBDA22 = spline(EMP_LAMBDA22(:,1), EMP_LAMBDA22(:,2));

    EMP_LAMBDA66 = [0, 1; 0.2, 0.68; 0.4, 0.39; 0.6, 0.18; 0.8, 0.05; 1, 0];
    LAMBDA66 = spline(EMP_LAMBDA66(:,1), EMP_LAMBDA66(:,2));

    A(1,1) = ppval(LAMBDA11, b/a) * m;
    A(2,2) = ppval(LAMBDA22, b/a) * m;
    A(3,3) = A(2,2);
    A(4,4) = 0;
    A(5,5) = ppval(LAMBDA66, b/a) * J;
    A(6,6) = A(5,5);
  
end