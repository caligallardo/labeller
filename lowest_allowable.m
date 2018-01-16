function x_low = lowest_allowable(events, n, active)
% given previous marked data, returns lowest x index that may be
% selected

    if active == 1 && n == 1 % no training data entered yet
        x_low = 5;
        return
    elseif active == 1 % pull from previous thruple
        x_low = events(n-1, 3);
        return
    else
        x_low = events(n, active-1)
    end
end