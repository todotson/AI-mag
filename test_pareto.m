function test_pareto()

close all;

plot_data.x_label = 'x';
plot_data.y_label = 'y';
plot_data.c_label = 'c';

plot_data.x_lim = [0 1];
plot_data.y_lim = [0.1 1];
plot_data.c_lim = [0.01 1];

plot_data.x_scale = 'lin';
plot_data.y_scale = 'log';
plot_data.c_scale = 'log';

plot_data.x_data = rand(1, 100);
plot_data.y_data = rand(1, 100);
plot_data.c_data = rand(1, 100);

plot_data.marker_pts_size = 20;
plot_data.marker_select_size = 10;
plot_data.marker_select_color = 'r';

figure()

ax = subplot(2,1,1);
callback = @(idx) fprintf('callback 1: %d\n', idx);
obj = design.GuiPareto(ax, plot_data, callback);
obj.set_select(4);

ax = subplot(2,1,2);
callback = @(idx) fprintf('callback 2: %d\n', idx);
design.GuiPareto(ax, plot_data, callback);

keyboard

end