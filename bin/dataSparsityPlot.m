function dataSparsityPlot(tbl)
%DATASPARSITYPLOT   Plot location inside a table where data is missing
% This function is used to create a plot showing the sparsity of missing
% data values (assumed to be NaN) in the input table.
%
% Inputs:
%   tbl     Table data type with the following requirements:
%               - First column must be datetime
%               - All other columns must be double
% Copyright 2014-2018 The MathWorks, Inc.
% find the missing values
idxmissing = ismissing(tbl(:,2:end));
[r,c] = find(idxmissing);
% what percentage are missing by station
percmissing = sum(idxmissing)/height(tbl)*100;
% plot the missing data
figure
plot(c,tbl.Time(r),'.')
% hack to avoid error if no missing values exist
if isempty(c)
    plot(-1,datetime(tbl.Time(1)-days(1)))
end
% plot customizations
xlim([0,width(tbl)])
ylim([tbl.Time(1),tbl.Time(end)])
ax = gca;
ax.YDir = 'reverse';
ax.XTick = 1:(width(tbl)-1);
labels = cellfun(@(x,y)[x '  ' sprintf('%.2f',y) '%'],...
    tbl.Properties.VariableNames(2:end),num2cell(percmissing),...
    'UniformOutput',false);
ax.XTickLabel = labels;
ax.XTickLabelRotation = -90;
xlabel('Region (% Missing Data)')
ylabel('Time')
title(sprintf('Sparsity of missing data\n%.2f%% of data points missing overall',...
    nnz(idxmissing)/numel(idxmissing)*100))
legend('Missing Data','Location','northwest','Orientation','vertical')
grid('on')
end
