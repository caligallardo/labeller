function s = getEvents(filename, nameForTextFile)

    function dayNum = isDay(timeFromStart) % time in seconds
        dayNum = floor(timeFromStart / (60 * 60 * 24);
    end

shiftEnd = 180;
thetaX = 60;
secondsPerDay = 60 * 60 * 24;
period = 30;
f_day = secondsPerDay / period;

% get data from .txt file, as arrays
rawDataWithEpoch = load_SUM_labeller_from_txt(filename);
epochTimestamps = rawDataWithEpoch(:, 1);
timeSinceActivation = epochTimestamps - epochTimestamps(1);
tempReadings = rawDataWithEpoch(:, 2);
assignin('base', 'tempReadings', tempReadings);

%epochActivationDayIST = floor(epochTimeStamps(1) / (60 * 60 * 24) + 5.5 * 60 * 60);

% unless specified as epoch, time is measured in seconds since activation.
% 'real time' is based on actual timestamp values

% interpolate temperature "data" every 30 sec
interpTime = (30 * ceil(timeSinceActivation(1)/period)) : period : (period * floor(timeSinceActivation(end)/30));
interpData = interp1q(timeSinceActivation, tempReadings, interpTime);

% % desired time vector: 
% % (midnight on first whole day):(30 seconds):(end of last whole day)
interpTimeSinceMidnight = mod(interpTime + 60 * 60 * 5.5, secondsPerDay);
firstMidnightInterpIndex = find(interpTimeSinceMidnight == 0, 1);
lastMidnightInterpIndex = find(interTimesSinceMidnight == 0, 1, 'last');
time = interpTime(firstMidnightInterpIndex : (lastMidnightInterpIndex-1));
data = interpData(firstMidnightInterpIndex : (lastMidnightInterpIndex-1));
numDays = (lastMidnightInterpIndex - firstMidnightInterpIndex) / f_day;

% timeSinceMidnight = mod(timeSinceActivation + 60 * 60 * 5.5, 60 * 60 * 24); % epoch time begins at 5:30am IST
% 
% firstInRangeRealTimeIndex = find(timeSinceMidnight(2:end) <= timeSinceMidnight(1)) + 1;
% firstInRangeRealTime = timeSinceActivation(firstInRangeRealTimeIndex);
% lastInRangeRealTimeIndex = find(timeSinceMidnight(1:end-1) <= timeSinceMidnight(end), 'last');
% lastInRangeRealTime = timeSinceActivation(lastInRangeRealTimeIndex);
% 
% rangeStart = firstInRangeRealTime - timeSinceMidnight(firstInRangeRealTimeIndex);
% rangeEnd = (lastInRangeRealTime - timeSinceMidnight(lastInRangeRealTimeIndex)) + 60 * 60 * 24;

assignin('base', 'data', data);
assignin('base', 'time', time);

% from here, time is now in seconds since the start of the
% first day. indices also measured by start of first day

% get peaks
[pks, locs] = findpeaks(data(1:length(dataUncut)-shiftEnd), ...
    'MinPeakProminence', 7, ...
    'MinPeakHeight', 35, ...
    'MinPeakDistance', 360, ...
    'MinPeakWidth', 10)
assignin('base', 'pks', pks);
assignin('base', 'locs', locs);

firstEventInRange_LocIndex = find(locs >= firstDayStartIndex, 1);
lastEventInRange_LocIndex = find(locs <= lastDayEndIndex, 1. 'last');

% only events in complete days
eventLocations = locs(firstEventInRange_LocIndex : lastEventInRange_LocIndex);
peakValues = pks(firstEventInRange_LocIndex : lastEventInRange_LocIndex);

numEvents = length(eventLocations);
A = horzcat(locs, zeros(numEvents, 2));
s.eventTable = array2table(A, 'VariableNames', {'Peak_Location', 'Start_Time', 'End_Time'});

thetas1 = atan(-difference(dataUncut, -thetaX)/.1); % divide by .1 for horizontal compression
thetas2 = atan(difference(dataUncut, thetaX)/.1);
% theta1 - theta2: sharpness (angle) of increase
% divide by pi/2 - theta1 to favor changes that begin reltively flat
lightValues = (thetas1+thetas2).*(pi/2-thetas1);

figure()
plot(dataUncut)
hold on
scatter(dayBreaks, neg_pks)
hold on;
scatter(locs, pks)

dailyEventCounts = zeros(numDays, 1);

for eventNum = 1:numEvents
    peakLoc = eventLocations(eventNum);
    dayNum = isDay(peakLoc * period);
    if eventNum == 1
        searchStartIndex = 1;
    else
        searchStartIndex = endOfLastEvent;
    end
    
    minDayTemp = min(data(start_i:end_i));
    maxDayTemp = max(dataUncut(start_i:end_i));
    relDistFromPeakTemp = ((maxDayTemp - dataUncut(searchStart:peakLoc))/(maxDayTemp - minDayTemp)).^2;

end
for dayNum = 1:length(dayBreaks)
    start_i = dayBreaks(dayNum)
    if dayNum == length(dayBreaks), end_i = length(dataUncut);    else end_i = dayBreaks(dayNum+1); end
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


        % get lighting point and ending range
        % get start and end pts for this event
        
        % lighting
        if i > 1
            prevEnd = eventEnd; % careful here. eventEnd cannot be changed in prev. iteration
            % proportional distance from daily max rel to daily min,
            % squared.
            % higher weight is placed on changes that occur at temps
            % low in relation to daily hi and lo
            relDistFromPeakTemp = ((maxDayTemp - dataUncut(prevEnd:peakLoc))/(maxDayTemp - minDayTemp)).^2;
            lighting_i = prevEnd + index_of_max(lightValues(prevEnd:peakLoc) .* relDistFromPeakTemp);
        else
            relDistFromPeakTemp = ((maxDayTemp - dataUncut(start_i-30:peakLoc))/(maxDayTemp - minDayTemp)).^2;
            lighting_i = start_i-30 + index_of_max(lightValues(start_i-30:peakLoc) .* relDistFromPeakTemp);
        end
        
        % cooling. finding longest region of continuous temp decline before
        % next event
        %isIncreasing = shiftAhead2smooth(peakLoc:end_i) >= 0;
        
        if i < numEventsToday % limit search upper bound by next event pk
            [mPks, mLocs] = findpeaks(dataUncut(peakLoc:listOfPeakLocationsThisDay(i+1)), 'MinPeakProminence', .5)
        elseif end_i == length(dataUncut) % limit by end of data set
            [mPks, mLocs] = findpeaks(dataUncut(peakLoc:end_i-shiftEnd), 'MinPeakProminence', .5);
        else % limit upper bound by next day start
            %[b, e] = getLongestZeroRegion(isIncreasing)
            [mPks, mLocs] = findpeaks(dataUncut(peakLoc:end_i), 'MinPeakProminence', .5);
        end
        
        lookAhead = dataUncut(peakLoc + mLocs) - dataUncut(peakLoc + mLocs + shiftEnd)
        iOM = index_of_max(lookAhead);
        mainPeakDiff = dataUncut(peakLoc)-dataUncut(peakLoc+shiftEnd)
        if iOM > 0
            if mainPeakDiff > lookAhead(iOM)
                mostProbablePeakInd = 0;
            else
                mostProbablePeakInd = mLocs(iOM);
            end
        else
            mostProbablePeakInd = 0;
        end
        
        eventEnd = peakLoc + mostProbablePeakInd;
        
        % add to table
        s.eventTable{eventNum, 'Peak_Location'} = peakLoc;
        s.eventTable{eventNum, 'Start_Time'} = lighting_i ;
        s.eventTable{eventNum, 'End_Time'} =  eventEnd;
        eventNum = eventNum + 1
        assignin('base', 'eventNum', eventNum);
    end
end

a = table2array(s.eventTable)
aHeightRaw = size(a, 1);
for row = 1:aHeightRaw
    if a(row, 3) == 0
        a = a(1:row-1, :)
        break
    end
end

n = size(a, 1);

for i = 1:n
    hold on
    plot(a(i,2):a(i,3), dataUncut(a(i,2):a(i,3)), 'Color', [.5, 0, .5])
    hold on
    scatter(a(i,2), dataUncut(a(i,2)), 'green', 'Marker', 'x')
    hold on
    scatter(a(i,3), dataUncut(a(i,3)), 'red', 'Marker', 'x')
end
%plot(lightValues + 30)
%title(strcat(filename, '1:', num2str(shift1), ', 2:', num2str(shift2), ', smooth:', num2str(smooth)))

[numEvents, c] = size(a)
durations = a(:, 3) - a(:, 2);
sumArray = [numEvents, mean(durations)/2, durationInDays];

s.summaryTable = array2table(sumArray, 'VariableNames', {'Number_Of_Events', 'Average_Duration_in_Min', 'Number_Of_Days'});


if nargin == 2,
    precision = ceil(log(epochTimestamps(1)));
    binArray = horzcat(timeSinceActivation + epochTimestamps(1), zeros(length(dataUncut), 1));
    n = size(a, 1);
    for i = 1 : n
        if a(i, 1) == 0
            break
        end
        binArray(a(i, 2):a(i, 3), 2) = 1;
    end
    dlmwrite(nameForTextFile, binArray, 'precision', precision);
end

end