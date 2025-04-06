function y = fcnvectorizer(pop,fun,numObj,SerialUserFcn,funOnWorkers)
%FCNVECTORIZER is a utility function used for scalar fitness functions.

%   Copyright 2003-2021 The MathWorks, Inc.

if nargin < 5
    % By default, we need to retrieve the function handle on the worker
    % before evaluating in parallel
    funOnWorkers = true;
end

try
    popSize = size(pop,1);
    y = zeros(popSize,numObj);
    % Use for if SerialUserFcn is 'true'; the if-and-else part should
    % be exactly same other than parfor-for syntax difference.
    if SerialUserFcn
        for i = 1:popSize
            y(i,:) = feval(fun,(pop(i,:)));
        end
    elseif funOnWorkers
        parfor (i = 1:popSize)
            % Get function handles for objective stored on the
            % worker (sent one time before the solver's iterations).
            objfun_local = getSetOptimFcns();
            y(i,:) = feval(objfun_local,(pop(i,:)));
        end
    else
        parfor (i = 1:popSize)
            % The function fun takes care of retrieving the handle stored
            % on the worker
            y(i,:) = feval(fun,(pop(i,:)));
        end
    end
catch userFcn_ME
    if iscell(pop) % if it is a custom PopulationType
        y = fun(pop);
    else
         gads_ME = MException('globaloptim:fcnvectorizer:fitnessEvaluation', ...
             'Failure in user-supplied fitness function evaluation. GA cannot continue.');
         userFcn_ME = addCause(userFcn_ME,gads_ME);
        rethrow(userFcn_ME)
    end
end
