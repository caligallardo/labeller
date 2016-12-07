function day = index_to_day(index, handles)

dayRange = evalin('base', 'dayRange');
data = evalin('base', 'data');

start_day = dayRange(1);
end_day = dayRange(2);

day = index * (end_day - start_day)/length(data) + start_day;