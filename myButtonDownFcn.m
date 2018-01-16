function myButtonDownFcn(object, eventdata, handles)

% only execute if a dataset is loaded
if ~isActive()
    return
end

active = evalin('base', 'active');


    data = evalin('base', 'data');
    n = evalin('base', 'number_of_events');
    events = evalin('base', 'cooking_events');

    if inBounds(handles)
        C = get(gca, 'CurrentPoint')
        YLims = get(gca, 'ylim');
        x = C(1, 1)
        index = day_to_index(x)
        adj_x = index_to_day(day_to_index(x)) % time value of nearest data point
        if n == 1
            last = 5;
        end
        
        % first line
        if active == 0 && index > last - 10
            events(n, active+1) = index;
            line([adj_x, adj_x], [YLims(1), YLims(2)], 'Color', 'red');
            active = 1
            set(handles.pushbutton2, 'Enable', 'on'); % enable undo % MOVE THIS

        % second line
        elseif active == 1 && index > events(n+1, 1)
            light_index = events(n,1)
            lighting_time = index_to_day(light_index)
            line(linspace(lighting_time, adj_x, index - light_index + 1), data(light_index:index), 'Color', [1, .5, 0], 'LineWidth', 2);
            line([adj_x, adj_x], [YLims(1), YLims(2)], 'Color', 'yellow');
            current_event(2) = index;

        % third line
        elseif current_event(3) == -1 && index > current_event(2) && current_event(2) ~= -1
            lighting_end = index_to_day(current_event(2));
            current_event(3) = index;
            cel(4) = line(linspace(lighting_end, adj_x, index - current_event(2) + 1), data(current_event(2):index), 'Color', [0, .8, .6], 'LineWidth', 2);
            cel(5) = line([x, x], [0, 1], 'Color', 'blue');
            set(handles.pushbutton4,'Enable', 'on');
        end
        
        assignin('base', 'active', active);
        assignin('base', 'number_of_events', n);
        assignin('base', 'cooking_events', events);

    end
end