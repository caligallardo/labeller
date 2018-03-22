function s = getEvents(filename)

% get data from .txt file, as arrays
dataWithEpoch = load_SUM_labeller_from_txt(filename);
epochTimestamps = dataWithEpoch(:, 1);
timeFromStart = epochTimestamps - epochTimestamps(1);
tempReadings = dataWithEpoch(:, 2);
assignin('base', 'tempReadings', tempReadings);

% interpolate temperature "data" every 30 sec
time = transpose(0:30:timeFromStart(length(timeFromStart)));
data = interp1q(timeFromStart, tempReadings, time);
assignin('base', 'data', data);

durationInSeconds = dataWithEpoch(length(dataWithEpoch)) - dataWithEpoch(1);
durationInDays = durationInSeconds / (60*60*24)
assignin('base', 'durationInDays', durationInDays);

% get peaks
[pks, locs] = findpeaks(data, ...
    'MinPeakProminence', 8, ...
    'MinPeakHeight', 35, ...
    'MinPeakDistance', 360, ...
    'MinPeakWidth', 10)
assignin('base', 'pks', pks);
assignin('base', 'locs', locs);

numPeaks = length(pks);
A = horzcat(locs, zeros(numPeaks, 2));
s.eventTable = array2table(A, 'VariableNames', {'Peak_Location', 'Start_Time', 'End_Time'});

% day daily lows by index
[neg_neg_pks, dayBreaks] = findpeaks(data * -1, 'MinPeakDistance', .85 * 2 * 60 * 24, 'MinPeakProminence', 1.2, 'MinPeakHeight', -35);
neg_pks = neg_neg_pks * -1;
assignin('base', 'dayBreaks', dayBreaks);

% check that this was at least kind of accurate
daysByPks = length(neg_pks)
if daysByPks > durationInDays * 1.2 || daysByPks < .8 * durationInDays
    msgId = 'getEvents: size discrepancy';
    msg = 'days calculated by peak find varies significantly from actual duration in days';
    throw(MException(msgId, msg))
end

% shift1 to find lighting start
% shift1 * 2 = shift in minutes
shift1 = 20;
shift2 = 120;
thetaX = 40;

thetas1 = atan(-difference(data, -thetaX));
thetas2 = atan(difference(data, thetaX));
% theta1 - theta2: sharpness (angle) of increase
% divide by pi/2 - theta1 to favor changes that begin reltively flat
lightValues = (thetas1+thetas2).*(pi/2-thetas1);
%lightValues = diff(fastsmooth(diff(fastsmooth(data, 20)), 10));

smooth = 60;
shiftAhead2smooth = difference(fastsmooth(data, smooth), shift2);

figure()
plot(data)
hold on
scatter(dayBreaks, neg_pks)
hold on;
scatter(locs, pks)

eventNum = 1;

for dayNum = 1:length(dayBreaks)-1
    start_i = dayBreaks(dayNum)
    end_i = dayBreaks(dayNum+1)
    % get events that occur on or after beginning of the day. ith value is
    % index wrt locs
    isToday_locs = (locs > start_i & locs < end_i);
    locsIndicesForThisDay = find(isToday_locs)
    listOfPeakLocationsThisDay = zeros(1, length(locsIndicesForThisDay))
    for i = 1:length(locsIndicesForThisDay)
        j = locsIndicesForThisDay(i);
        listOfPeakLocationsThisDay(i) = locs(j)
    end
    
    numEventsToday = length(listOfPeakLocationsThisDay);
    for i = 1: numEventsToday
        peakLoc = listOfPeakLocationsThisDay(i)
        assignin('base', 'dayStart_i', start_i);
        assignin('base', 'dayEnd_i', end_i);
        minDayTemp = min(data(start_i:end_i));
        maxDayTemp = max(data(start_i:end_i));

        % get lighting point and ending range
        % get start and end pts for this event
        
        % lighting
        if i > 1
            prevEnd = eventEnd; % careful here. eventEnd cannot be changed in prev. iteration
            % proportional distance from daily max rel to daily min,
            % squared.
            % higher weight is placed on changes that occur at temps
            % low in relation to daily hi and lo
            relDistFromPeakTemp = ((maxDayTemp - data(prevEnd:peakLoc))/(maxDayTemp - minDayTemp)).^2;
            lighting_i = prevEnd + index_of_max(lightValues(prevEnd:peakLoc) .* relDistFromPeakTemp);
        else
            relDistFromPeakTemp = ((maxDayTemp - data(start_i-30:peakLoc))/(maxDayTemp - minDayTemp)).^2;
            lighting_i = start_i-30 + index_of_max(lightValues(start_i-30:peakLoc) .* relDistFromPeakTemp);
        end
        
        % cooling. finding longest region of continuous temp decline before
        % next event
        isIncreasing = shiftAhead2smooth(peakLoc:end_i) >= 0;
        
        if i < numEventsToday
            [b, e] = getLongestZeroRegion(isIncreasing(1:listOfPeakLocationsThisDay(i+1)-peakLoc))
        else
            [b, e] = getLongestZeroRegion(isIncreasing)
        end
        eventEnd = peakLoc + b
        
        % add to table
        s.eventTable{eventNum, 'Peak_Location'} = peakLoc;
        s.eventTable{eventNum, 'Start_Time'} = lighting_i ;
        s.eventTable{eventNum, 'End_Time'} =  eventEnd;
        eventNum = eventNum + 1
        assignin('base', 'eventNum', eventNum);
    end
end

    a = table2array(s.eventTable)
    n = length(pks);
    if locs(length(locs)) > dayBreaks(length(dayBreaks))
        n = length(pks)-1
        a = a(1:n, :)
    end
    
    for i = 1:n
        hold on
        plot(a(i,2):a(i,3), data(a(i,2):a(i,3)), 'Color', [.5, 0, .5])
        hold on
        scatter(a(i,2), data(a(i,2)), 'green', 'Marker', 'x')
        hold on
        scatter(a(i,3), data(a(i,3)), 'red', 'Marker', 'x')
    end
title(strcat(filename, '1:', num2str(shift1), ', 2:', num2str(shift2), ', smooth:', num2str(smooth)))
end