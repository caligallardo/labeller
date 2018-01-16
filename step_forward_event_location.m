function [n_new, active_new] = step_forward_event_location(n, active)

if active == 1 || active == 2
    active = active + 1
elseif active == 3
    active = 1;
    n = n + 1;
else
    error('active should be 1, 2, or 3')
end

n_new = n;
active_new = active;
end
