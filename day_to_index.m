function index = day_to_index(time_point, handles)

dayRange = evalin('base', 'dayRange');
data = evalin('base', 'data');

if length(time_point) ~= 1
    throw (MException(timeDimensionNotOne, 'time_point should be a scalar quantity'));
end
start_day = dayRange(1);
end_day = dayRange(2);
% xlim = get(handles.axes1, 'Xlim');
% xmin = xlim(1);
% xmax = xlim(2);
% if (time_point > xmin && time_point < xmax)
    index = round((time_point - start_day) * (length(data)/(end_day - start_day)));
% else
%     index = [];
% end
