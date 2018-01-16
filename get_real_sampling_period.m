function period = get_real_sampling_period(data, varargin) 
% inputs:
% - signal
% - estimated period (default = 5)
% - proportional margin (default = .2 --> within 20% of estimate)

% set defaults
est_period = 5;
margin = .2; % default margin
assignin('base', 'varargin', varargin)

if nargin >= 2
    est_period = varargin{1}
    if nargin == 3
        margin = varargin{2};
    end
end

num_samples = length(data);
y = fft(data);
z = abs(y);
z = z(1: round(num_samples/2) - 1);
expected = round(num_samples * est_period / 60 /24); % expected number of days in the dataset (based on 5 min estimation)
range = round(expected * margin); % consider possible day lengths within 25% of the estimated
% get main signal (max on the fft) whose frequency is nearish to an
% estimated day
real_days_in_dataset = index_of_max(z(expected - range : expected + range)) + (expected - range);
samples_per_day = num_samples / real_days_in_dataset;
samples_per_min = samples_per_day / (60 * 24);

period = 1 / samples_per_min;

end