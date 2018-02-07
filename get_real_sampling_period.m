function period = get_real_sampling_period(data, varargin) 
% inputs:
% - signal
% - expected period (default = 5)
% - proportional margin (default = .2 --> within 20% of estimate)

% set defaults
exp_period = 5;
margin = .2; % default margin
assignin('base', 'varargin', varargin)

if nargin >= 2
    exp_period = varargin{1}
    if nargin == 3
        margin = varargin{2};
    end
end

num_samples = length(data);
y = fft(data);
z = abs(y);
z = z(1: round(num_samples/2) - 1);

expected = round(num_samples * exp_period / 60 /24); % expected number of days in the dataset (based on 5 min estimation)
range = round(expected * margin); % consider possible day lengths within 25% of the estimated
% get main signal (max on the fft) whose frequency is nearish to an
% estimated day
real_days_in_dataset = index_of_max(z(expected - range : expected + range)) + (expected - range);
samples_per_day = num_samples / real_days_in_dataset;
samples_per_min = samples_per_day / (60 * 24);

period = 1 / samples_per_min;

f_exp = (1:(round(num_samples/2) - 1))/num_samples * (24*60/exp_period);
f_calc = (1:(round(num_samples/2) - 1))/num_samples * (24*60/period);
figure()
plot(f_exp, z)
title('estimated')
figure()
plot(f_calc, z)
title('calculated')

end