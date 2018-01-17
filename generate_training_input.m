function [X, Y] = generate_training_input(temp_data, response)
    if length(temp_data) ~= length(response)
        error('data and response must be of same size');
    end
    
    n = length(temp_data);
    X = horzcat(temp_data(11:n-10), temp_data(21:n), temp_data(16:n-5), temp_data(6:n-15), temp_data(1:n-20));
    Y = (sum(response(11:n-10, :), 2) > 0);
end