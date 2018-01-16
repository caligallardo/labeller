function day = index_to_day(index)

timeRange = evalin('base', 'timeRange');
data = evalin('base', 'data');

start_day = timeRange(1);
end_day = timeRange(2);

day = index * (end_day - start_day)/length(data) + (start_day);