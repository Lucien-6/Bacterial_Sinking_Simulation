function Fractal_Dimension = Calculate_Fractal_Dimension(Trajectory)
%Fractal_Dimension This function is used to calculate the complexity of the trajectory.
%   This function use Box-Counting Method to analyze the complexity of
%   bacterial trajectory, and Trajectory is an N*3 matrix, e.g. [x, y, z].
%   A higher fractal dimension indicates a more complex trajectory.

%Calculating the upper limit of the box size
Dis = pdist(Trajectory);
Min_Dis = min(Dis);
Max_Dis = max(Dis);
Factor = Max_Dis/(10*Min_Dis);

%Setting the box size sequence
box_sizes = logspace(log10(1/20),0,20).*(Factor*Min_Dis);

%Initialize arrays to store the results
N_boxes = zeros(size(box_sizes));
log_box_sizes = log10(box_sizes);
log_N_boxes = zeros(size(log_box_sizes));

% Perform box-counting for each box size
for i = 1:length(box_sizes)
    N_boxes(i) = box_counting(Trajectory, box_sizes(i));
    log_N_boxes(i) = log10(N_boxes(i));
end

% Calculate the slope of the log-log plot to estimate the fractal dimension
p = polyfit(log_box_sizes, log_N_boxes, 1);
Fractal_Dimension = -p(1);

% Display the fractal dimension
disp(['The estimated fractal dimension of the trajectory is: ', num2str(Fractal_Dimension),newline]);

% Visualization
figure;
set(gcf,'Position',[20 20 1200 1000])
plot(log_box_sizes, log_N_boxes, 'bo','MarkerSize',7.5,'LineWidth',1.0);
hold on;
plot(log_box_sizes, polyval(p, log_box_sizes), 'r-','LineWidth',1.5);
set(gca,'FontName','Times New Roman')
grid on;
ax = gca; ax.LineWidth = 1.5;
ax.FontSize = 12;
xlabel('log(BoxSize)','FontSize',18);
ylabel('log(NumBox)','FontSize',18);
title('Fractal Dimension Calculation','FontSize',24,'FontWeight','bold');
legend({'Original Data','Fitted Line'},'FontSize',16,'Location','northeast')
latexf = ['$$ \leftarrow {\bf FD} = ',num2str(Fractal_Dimension),'$$'];
text(log_box_sizes(floor(i/2)),polyval(p, log_box_sizes(floor(i/2))),latexf,'Interpreter','latex','FontSize',14, ...
    'Color','k','HorizontalAlignment','left')
hold off;

end

% Function to calculate the number of boxes needed to cover the trajectory
function N = box_counting(trajectory, box_size)

% Initialize the number of boxes
N = 0;

% Range of the trajectory
min_xyz = min(trajectory);
max_xyz = max(trajectory);

% Create a matrix to keep track of which boxes have been counted
box_counts = zeros(ceil((max_xyz - min_xyz) ./box_size)+1);

% Iterate over each point, counting boxes
for i = 1:size(trajectory, 1)
    idx = floor((trajectory(i, :) - min_xyz)./box_size)+1;
    if box_counts(idx(1), idx(2), idx(3)) == 0
        N = N + 1;
        box_counts(idx(1), idx(2), idx(3)) = 1;
    end
end
end