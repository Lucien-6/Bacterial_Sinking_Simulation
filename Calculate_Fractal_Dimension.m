function Fractal_Dimension = Calculate_Fractal_Dimension(Trajectory, Size_Ratio, depth)
%Fractal_Dimension Estimate trajectory complexity by box-counting.
%   Trajectory is an N*3 matrix, e.g. [x, y, z].
%   Returns NaN if the estimate is unreliable (degenerate data / poor fit).
% Created by: Lucien
% Modified: 2026-07-31 (V1.1.0)

if nargin < 2 || isempty(Size_Ratio)
    Size_Ratio = 10;
end
if nargin < 3 || isempty(depth)
    depth = 0;
end
maxDepth = 5;

if size(Trajectory, 1) < 3
    warning('Too few points for fractal dimension estimation.');
    Fractal_Dimension = NaN;
    return
end

%Calculating the upper limit of the box size
Dis = pdist(Trajectory);
Min_Dis = min(Dis);
Max_Dis = max(Dis);
if ~(Min_Dis > 0) || ~isfinite(Min_Dis) || ~isfinite(Max_Dis) || Max_Dis <= Min_Dis
    warning('Invalid pairwise distances for fractal dimension (duplicate or degenerate points).');
    Fractal_Dimension = NaN;
    return
end

Factor = Max_Dis / (Size_Ratio * Min_Dis);

%Setting the box size sequence
box_sizes = logspace(log10(1/10), 0, 20) .* (Factor * Min_Dis);

%Initialize arrays to store the results
N_boxes = zeros(size(box_sizes));
log_box_sizes = log10(box_sizes);
log_N_boxes = zeros(size(log_box_sizes));

% Perform box-counting for each box size
for i = 1:length(box_sizes)
    N_boxes(i) = box_counting(Trajectory, box_sizes(i));
    if N_boxes(i) <= 0
        log_N_boxes(i) = NaN;
    else
        log_N_boxes(i) = log10(N_boxes(i));
    end
end

valid = isfinite(log_box_sizes) & isfinite(log_N_boxes);
if nnz(valid) < 3
    warning('Insufficient valid box-counting samples for fractal dimension.');
    Fractal_Dimension = NaN;
    return
end

% Calculate the slope of the log-log plot to estimate the fractal dimension
[p, gof] = fit(log_box_sizes(valid)', log_N_boxes(valid)', 'poly1');
Fractal_Dimension = -p.p1;

% Display the fractal dimension
if gof.adjrsquare >= 0.995
    disp(['The estimated fractal dimension of the trajectory is: ', num2str(Fractal_Dimension), newline]);
else
    warning('Poor linearity of results, please re-select box size range !')
    if depth >= maxDepth
        warning('Fractal dimension fit did not converge within %d retries. Returning NaN.', maxDepth);
        Fractal_Dimension = NaN;
        return
    end
    Fractal_Dimension = Calculate_Fractal_Dimension(Trajectory, Size_Ratio + 1, depth + 1);
    return
end

% Visualization
figure;
set(gcf, 'Position', [20 20 1200 1000])
plot(log_box_sizes(valid), log_N_boxes(valid), 'bo', 'MarkerSize', 7.5, 'LineWidth', 1.0);
hold on;
plot(log_box_sizes(valid), p(log_box_sizes(valid)), 'r-', 'LineWidth', 1.5);
set(gca, 'FontName', 'Times New Roman')
grid on;
ax = gca; ax.LineWidth = 1.5;
ax.FontSize = 12;
xlabel('log(BoxSize)', 'FontSize', 18);
ylabel('log(NumBox)', 'FontSize', 18);
title('Fractal Dimension Calculation', 'FontSize', 24, 'FontWeight', 'bold');
legend({'Original Data', 'Fitted Line'}, 'FontSize', 16, 'Location', 'northeast')
mid = max(1, floor(nnz(valid) / 2));
xv = log_box_sizes(valid);
latexf = ['$$ \leftarrow {\bf FD} = ', num2str(Fractal_Dimension), '$$'];
text(xv(mid), p(xv(mid)), latexf, 'Interpreter', 'latex', 'FontSize', 14, ...
    'Color', 'k', 'HorizontalAlignment', 'left')
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
box_counts = zeros(ceil((max_xyz - min_xyz) ./ box_size) + 1);

% Iterate over each point, counting boxes
for i = 1:size(trajectory, 1)
    idx = floor((trajectory(i, :) - min_xyz) ./ box_size) + 1;
    if box_counts(idx(1), idx(2), idx(3)) == 0
        N = N + 1;
        box_counts(idx(1), idx(2), idx(3)) = 1;
    end
end
end
