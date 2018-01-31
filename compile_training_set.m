function training_set = compile_training_set(data, events)
events
target = zeros(length(data), 2);
[n, m] = size(events);
for i = 1 : n
    if events(i, 1) == 0
        break
    end
    % event(i, 1): lighting start index of event i
    target(events(i, 1):(events(i, 2) - 1), 1) = 1;
    target(events(i, 1):(events(i, 2) - 1), 2) = 0;
    % event(i, 2): lighting end index of event i
    target(events(i, 2):(events(i, 3) - 1), 1) = 1;
    target(events(i, 2):(events(i, 3) - 1), 2) = 1;
end
training_set = horzcat(data, target);