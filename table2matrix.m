function [arrayOut,group1out,group2out] = table2matrix(table,varargin)
%% example 
% myNewArray = table2matrix(table,'VariableColNum',[1,3,12])
% 
% where the first number of the vector (1) is the response variable, the
% second is group1 (categorical condition), and the third is group2
% (categorical condition, e.g. genotype)

%%
p = inputParser;
% check inputs
validationFcn1 = @(x) isvector(x);  % validation function

% add param
addParameter(p, 'VariableColNum', [], validationFcn1);

% Parse the input arguments
parse(p, varargin{:});
vColNum     = p.Results.VariableColNum;

if numel(vColNum) ~= 3
    error('The number of variables is %d, but must be 3',numel(p.Results.VariableColNum));
end

varNames = table.Properties.VariableNames;
respVar = table.(varNames{vColNum(1)});
groupA = table.(varNames{vColNum(2)});
groupB = table.(varNames{vColNum(3)});

if ~isnumeric(respVar)
    error('group1 (%s) is not numeric',varNames{vColNum(2)})
end

group1 = unique(groupA);
group2 = unique(groupB);

tmpTab = table(:,varNames(vColNum));                    % keep only relevant stuff: resp var, group1 (p2a), group2 (gt)
varNames = tmpTab.Properties.VariableNames;
celTb = cell(numel(group2),4);

for n = 1:numel(group2)
    index0      = tmpTab.(varNames{3}) == group2(n);
    tmpvar1 = NaN(sum(index0),1);

    if iscategorical(group1)
        tmpgrp1     = categorical(zeros(sum(index0),1));
    else
        tmpgrp1     = NaN(sum(index0),1);
    end
    if iscategorical(group2)
        tmpgrp2     = categorical(zeros(sum(index0),1));
    else
        tmpgrp2     = NaN(sum(index0),1);
    end

    q1 = 1;
    for m = 1:numel(group1)                               % re-organize by replicates first, then p2a along rows
        index1      = tmpTab.(varNames{2}) == group1(m);
        index2      = index0&index1;
        q2          = q1 +sum(index2)-1;
        tmpvar1(q1:q2,1) = tmpTab.(varNames{1})(index2);
        tmpgrp1(q1:q2,1) = tmpTab.(varNames{2})(index2);
        tmpgrp2(q1:q2,1) = tmpTab.(varNames{3})(index2);
        q1 = q2+1;
    end
    celTb(n,1) = {tmpvar1};     % response var
    celTb(n,2) = {tmpgrp1};     % group 2
    celTb(n,3) = {tmpgrp2};     % group 1 (repeated to match length)
    celTb(n,4) = {group2(n)};   % group 1
end

% pad missing vals (to handle diff num of replicates?)

[maxLen,Mpos] = max(cellfun(@numel,celTb(:,1)),[],1);                       % max length in the array

% handle the case of different numbers of elements in group1:group2
% combinations
tmpVal = zeros(numel(group1),numel(group2));
indxGrN = cell(numel(group1),numel(group2));
for is = 1:numel(group2)
    for ig = 1:numel(group1)
        indxGrN{ig,is} = celTb{is,2} == group1(ig);
        tmpVal(ig,is) = sum(indxGrN{ig,is});
    end
end

[maxElem1,pos] = max(tmpVal,[],2); % max num of element for each group combination
arrayOut    = NaN(sum(maxElem1),numel(group2));
group1out = [];
for nx = 1:numel(group1)
    group1out = [group1out; repmat(group1(nx),maxElem1(nx),1)];
end
group2out   = [celTb{:,4}]';

for ih = 1:size(celTb,1)
    for ij = 1:numel(group1)
        tmpindx     = celTb{ih,2} == group1(ij);
        tmpindM     = indxGrN{ij,pos(ij)};
        padd1       = NaN(sum(tmpindM)-sum(tmpindx),1);
        tmpArr4y    = [celTb{ih,1}(tmpindx); padd1];
        arrayOut(tmpindM,ih) = tmpArr4y;                        % Fill the matrix with the elements from the cell array
    end
end
end