filenames = {
    '101combined.txt', ...
    '102combined.txt', ...
    '104combined.txt', ...
    '105combined.txt', ...
    '106combined.txt'
    };

    a = zeros(5, 2);
    T = array2table(a, 'RowNames', filenames, 'VariableNames', {'Duration_In_Days', 'Number_Of_Uses'});

for file = filenames
    filepath = strcat('India data/', file{1});
    dataWithEpoch = load_SUM_labeller_from_txt(filepath);

    durationInSeconds = dataWithEpoch(length(dataWithEpoch)) - dataWithEpoch(1);
    durationInDays = durationInSeconds / (60*60*24);
    
    data = dataWithEpoch(:, 2);
        
    [pks, locs] = findpeaks(data, ...
    'MinPeakProminence', 8, ...
    'MinPeakHeight', 35, ...
    'MinPeakDistance', 360, ...
    'MinPeakWidth', 40, ...
    'Annotate', 'extents');
    
    figure()
    findpeaks(data, ...
    'MinPeakProminence', 8, ...
    'MinPeakHeight', 35, ...
    'MinPeakDistance', 360, ...
    'MinPeakWidth', 6, ...
    'Annotate', 'extents')
    title(file{1})

    T{file, 'Duration_In_Days'} = durationInDays;
    T{file, 'Number_Of_Uses'} = length(locs);
end