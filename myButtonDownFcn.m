function myButtonDownFcn(object, eventdata, handles)

% only execute if a dataset is loaded
if ~isActive()
    return
end

active = evalin('base', 'active');

if active

    data = evalin('base', 'data');
    cel = evalin('base', 'cel');
    current_event = evalin('base', 'current_event');
    events = evalin('base', 'events');

    %global current_event; % indices of selected times
    %global data;
    %global cel;

    if inBounds(handles)
        C = get(gca, 'CurrentPoint');
        x = C(1, 1);
        index = day_to_index(x);
        adj_x = index_to_day(day_to_index(x)); % time value of nearest data point
        
        % last is index of last line of last event
        [n, m] = size(events);
        if isequal(events, [])
            last = -1;
        else
            last = events(n, 3);
        end
        
        % first line
        if current_event(1) == -1 && index > last
            current_event(1) = index;
            cel(1) = line([adj_x, adj_x], [0, 1], 'Color', 'red');
            set(handles.pushbutton2, 'Enable', 'on'); % enable undo
            set(handles.pushbutton1, 'Enable', 'off'); % disable create new

        % second line
        elseif current_event(2) == -1 && index > current_event(1) && current_event(1) ~= -1
            lighting_start = index_to_day(current_event(1));
            cel(2) = line(linspace(lighting_start, adj_x, index - current_event(1) + 1), data(current_event(1):index), 'Color', [1, .5, 0], 'LineWidth', 2);
            cel(3) = line([adj_x, adj_x], [0, 1], 'Color', 'yellow');
            current_event(2) = index;

        % third line
        elseif current_event(3) == -1 && index > current_event(2) && current_event(2) ~= -1
            lighting_end = index_to_day(current_event(2));
            current_event(3) = index;
            cel(4) = line(linspace(lighting_end, adj_x, index - current_event(2) + 1), data(current_event(2):index), 'Color', [0, .8, .6], 'LineWidth', 2);
            cel(5) = line([x, x], [0, 1], 'Color', 'blue');
            set(handles.pushbutton4,'Enable', 'on');
        end

        % update cel and current_event
        assignin('base', 'cel', cel);
        assignin('base', 'current_event', current_event);
    end
end