function mouseMove (object, eventdata, handles)

global data;
global dayRange; % [start_day, end_day]
global index; % cursor's current location in data
global lighting_index;
global active;
global current_event;

start_day = dayRange(1);
end_day = dayRange(2);

if ~isempty(data) && inBounds(handles); % if dataset chosen and cursor in axes
    C = get(gca, 'CurrentPoint');
    Xloc = C(1, 1);
    index = day_to_index(Xloc, handles);
    if ~isempty(current_event)
        active;
        disp(current_event);
    end
    disp(data(index));
    if (isequal(active, 1) && (current_event(1) > -1 && current_event(2) == -1) && index > current_event(1))
        area((lighting_index:index), data(lighting_index, index));
    end 
end