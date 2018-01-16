function myButtonDownFcn(object, eventdata, handles)
% active
% 1: this event is lighting
% 2: this event is cooking start
% 3: this event is cooking end
% [] if nothing loaded

% only execute if a dataset is loaded
if ~isActive()
    return
end

active = evalin('base', 'active');

    data = evalin('base', 'data');
    n = evalin('base', 'number_of_events');
    events = evalin('base', 'cooking_events');
    markers = evalin('base', 'markers');
    timeRange = evalin('base', 'timeRange');
    
    C = get(gca, 'CurrentPoint')
    x = C(1, 1)

    if inBounds(handles) && x >= timeRange(1) && x <= timeRange(2)
        YLims = get(gca, 'ylim');
        index = day_to_index(x) % index of nearest point in x-direction
        adj_x = index_to_day(day_to_index(x)) % time value of nearest data point
        x_low_index = lowest_allowable(events, n, active)
        
        % first line
        if active == 1 && index > x_low_index
            % mark on graph & update events
            red_marker = line;
            set(red_marker, 'XData', [adj_x, adj_x], 'YData', [YLims(1), YLims(2)], 'Color', 'red');
            markers{n, 1} = red_marker;
            events(n, 1) = index;
            
            % update status
            [n, active] = step_forward_event_location(n, active);
            
            set(handles.pushbutton2, 'Enable', 'on'); % enable undo % MOVE THIS

        % second line
        elseif active == 2 && index > events(n, 1)
            % mark on graph & update events
            events(n, 2) = index;
            
            light_index = events(n,1)
            lighting_time = index_to_day(light_index)
            
            orange_marker = line;
            yellow_marker = line;
            set(orange_marker, 'XData', linspace(lighting_time, adj_x, index - light_index + 1), 'YData', data(light_index:index), 'Color', [1, .5, 0], 'LineWidth', 2);
            set(yellow_marker, 'XData', [adj_x, adj_x], 'YData', [YLims(1), YLims(2)], 'Color', 'yellow');
            markers{n, 2} = orange_marker;
            markers{n, 3} = yellow_marker;
            
            % update status
            [n, active] = step_forward_event_location(n, active);

        % third line
        elseif active == 3 && index > events(n, 2)
            % update events & mark on graph
            events(n, 3) = index;
            
            cook_start_index = events(n,2);
            cook_start_time = index_to_day(cook_start_index);
            
            green_marker = line;
            blue_marker = line;
            set(green_marker, 'XData', linspace(cook_start_time, adj_x, index - cook_start_index + 1), 'YData', data(cook_start_index:index), 'Color', [0, .8, .6], 'LineWidth', 2);
            set(blue_marker, 'XData', [adj_x, adj_x], 'YData', [YLims(1), YLims(2)], 'Color', 'blue');
            markers{n, 4} = green_marker;
            markers{n, 5} = blue_marker;
            % update status
            [n, active] = step_forward_event_location(n, active);

        end
        
        assignin('base', 'active', active);
        assignin('base', 'number_of_events', n);
        assignin('base', 'cooking_events', events);
        assignin('base', 'markers', markers);
        assignin('base', 'number_of_events', n);

    end
end