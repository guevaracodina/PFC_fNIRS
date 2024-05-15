function plotHbO_resting_State(t, HbO)
% load('C:\Edgar\Dropbox\CIACYT\Students\Michelle\fNIRS Yoga\Training31\resting\derivatives\homer\Resting_State.mat')
% dc = output.dc.GetDataTimeSeries('reshape');
% t = output.dc.GetTime();
% HbO = squeeze(dc(:,1,:));
    HbO = 1e6*HbO;  % MicroMolar * cm
    % Determine the offset by finding the maximum range of HbO
    maxVal = max(HbO, [], 'all'); % Maximum value across all columns
    minVal = min(HbO, [], 'all'); % Minimum value across all columns
    range = maxVal - minVal;      % Range of the data
    offset = range * 0.25;        % Set offset as 5% of the range for spacing
    
    close all
    % Initialize the figure
    h = figure;
    set(h, 'color', 'w')
    hold on; % Keep the plot active to overlay multiple lines
    
    % Loop through each column of HbO to plot with an offset
    for i = 1:size(HbO, 2) % Iterate through columns
        plot(t, HbO(:,i) + (i-1) * offset, 'k-', 'LineWidth', 1); % Add offset to each column's data
    end
    
    % Aesthetics
    % title('HbO Time Courses with Offsets');
    xlabel('Time (s)');
    ylabel('\DeltaHbO (\muM\cdotcm with offsets)');
    % legend(arrayfun(@(x) ['HbO Column ' num2str(x)], 1:size(HbO, 2), 'UniformOutput', false));
    hold off; % Release the plot
    axis tight; %axis off
    set(gca, 'FontSize', 11)
    % Specify window units
    set(h, 'units', 'inches')
    % Change figure and paper size
    set(h, 'Position', [0.1 0.1 4 1.8])
    set(h, 'PaperPosition', [0.1 0.1 4 1.8])
    print(h, '-dpng', '..\figures\Figure1e_resting_state.png', '-r300');
end
