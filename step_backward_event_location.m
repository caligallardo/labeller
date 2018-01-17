function [n_new, active_new] = step_backward_event_location(n, active, handles)

if active == 1 && n == 1
    n_new = n;
    active_new = active;
    return
end

if active == 2 || active == 3
    active = active - 1;
elseif active == 1
    active = 3;
    n = n - 1;
else
    error('active should be 1, 2, or 3')
end

if active == 1
    set(handles.pushbutton5, 'enable', 'on');
else
    set(handles.pushbutton5, 'enable', 'off');
end

n_new = n;
active_new = active;

end