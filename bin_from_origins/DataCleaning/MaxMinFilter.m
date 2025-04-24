function [data] = MaxMinFilter(data, VarName, min_val, max_val)
% Replace out of boundary values with NaN
    if ismember(VarName,data.Properties.VariableNames)
        data.(VarName)(data.(VarName)<min_val) = NaN;
        data.(VarName)(data.(VarName)>max_val) = NaN;
    end
end