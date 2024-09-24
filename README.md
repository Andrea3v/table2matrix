# table2matrix
converts a MATLAB table to an array for dataviz or anova analysis etc.

only 2 groups are specified by 'VariableColNum' as table column numbers
%% example 
% myNewArray = table2matrix(table,'VariableColNum',[1,3,12])
% 
% where the first number of the vector (1) is the response variable, the
% second is group1 (categorical condition), and the third is group2
% (categorical condition, e.g. genotype)
