function [n_new, active_new] = step_forward_event_location(n, active, handles)

if active == 1 || active == 2
    active = active + 1
    set(handles.pushbutton5, 'enable', 'off');
elseif active == 3
    active = 1;
    n = n + 1;
    set(handles.pushbutton5, 'enable', 'on');
else
    error('active should be 1, 2, or 3')
end

n_new = n;
active_new = active;
end
