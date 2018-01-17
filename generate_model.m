function model = generate_model(training_sets)
% training_set: cell of saved .mat files generated from labeller

master_X = [];
master_Y = [];

for i = 1:length(training_sets)
    load(training_sets{i});
    s = evalin('base', 'training_set');
    [X, Y] = generate_training_input(s(:, 1), s(:, 2:3));
    master_X = vertcat(master_X, X);
    master_Y = vertcat(master_Y, Y);
end
model = fitcsvm(master_X, master_Y); 

end