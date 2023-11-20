function dx = odefcn(t,x,UV,TAU,HE)
    n = 6;
    dx = zeros(2*n*numel(UV),1);
    for i = 1:numel(UV)
        offset = 12 * (i - 1);
        eta = x((1 + offset):(n + offset));
        v = x((7 + offset):(2*n + offset));
    
        M = UV{i}.M;
        %C = UV{i}.C(UV{i},v);
        C = zeros(6,6);
        g = UV{i}.g(UV{i},eta);
        J = UV{i}.J(eta);
    
        A = [zeros(n), J^-1;
             zeros(n), -M^-1 * ( C )];
        B = [zeros(n); M^-1];
    
        if nargin < 5
            he = zeros(n,1);
        else
            he = HE{i};
        end
        
        Q = 1.*eye(2*n); R = 0.01.*eye(n); % матрицы штрафов
        [K,~,~] = lqr(A,B,Q,R);
            
        %tau = TAU{i};
        tau = -K*x((1 + offset):(2*n + offset));
        u = -g + tau + J*he; % без управления
        offset = 12 * (i - 1);
        dx((1 + offset):(2*n + offset)) = A*x((1 + offset):(2*n + offset)) + B*u;
    end
end