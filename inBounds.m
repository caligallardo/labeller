function b = inBounds(handles)
% in graph and within day range
C = get (gca, 'CurrentPoint');
current_point = C(1, 1:2);
x = current_point(1);
y = current_point(2);

xlim = get(handles.axes1, 'Xlim');
xmin = xlim(1);
xmax = xlim(2);
ylim = get(handles.axes1, 'Ylim');
ymin = ylim(1);
ymax = ylim(2);

b = (x > xmin && x < xmax && y > ymin && y < ymax);