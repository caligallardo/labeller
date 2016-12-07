function b = isActive()

% return 1 is dataset has been loaded (as indicated by presence of active
% variable
% return 0 otherwise

try
    evalin('base', 'active');
catch e
    if isequal(e.identifier, 'MATLAB:UndefinedFunction');
        b = 0;
        return
    end
end
b = 1;