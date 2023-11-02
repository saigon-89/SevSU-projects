function dx = odefcn(t,x,UV,tau)
    n = 6;
    eta = x(1:n); 
    v = x(7:end);

    M = UV.M;
    C = UV.C(UV,v);
    g = UV.g(UV,eta);
    J = UV.J(eta);

    A = [zeros(n), J^-1;
         zeros(n), -M^-1 * ( C )];
    B = [zeros(n); M^-1];


    u = -g + tau; % без управления
    dx = A*x + B*u;
end