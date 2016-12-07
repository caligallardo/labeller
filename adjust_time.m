function [time_new, data_new] = adjust_time(num_days, data)
% trims data vector to begin at first morning
% calculates true average log rate and adjust time vector

num_samples = length(data);
y = fft(data);
z = abs(y);
z = z(1: round(num_samples/2) - 1);

expected = round(num_days); % expected number of days in the dataset (based on 5 min estimation)
range = round(expected * .25); % consider possible day lengths within 25% of the estimated

% get main signal (max on the fft) whose frequency is nearish to an
% estimated day
real_days_in_dataset = max_index(z(expected - range : expected + range)) + (expected - range);
samples_per_day = num_samples / real_days_in_dataset;
samples_per_min = samples_per_day / (60 * 24)

start_index = index_min(data(0:samples_per_day));
end_index = index_min(data(len(data)-samples_per_day : len(data)));

time_new = (1 : (end_index-start_index)) / samples_per_day;
data_new = data(start_index : end_index);
end