%% Example of using function [mycorrplot_1]
% This is an example file demonstrating how to use * [mycorrplot_1] * to
% viisualize the result of correlation (i.e. the results from * corr(X) *). 
%
% Use my Iva insect data *[X_community]*. 
%
% by Wei-Ting Lin, _2014/10/15_
%% Setting up and load data
clear;clc
load X_community
%%
% *[X_community]* contains two matrices, and two "name" files:
%
% * insect_data : 44 x 13 matrix, data for 44 patches and 13 species 
% * patch_met : 44 x12 matrix, data for 44 patches and 12 patch attributes
% * insect_names : content of the insects (each column in [insect_data])
% * met_names : content of the patch attributes
% I like to keep data as a matrix and put their names in a seperate file.
% We are only using the *[insect_data]* here.

%%
% *Short names*
%
% The names in insect_names can be too long for some display, so I create a short version of names 
shortnames={'Spd','Ant','Ophr.','Paria','Aphid','H.GH','RSB','Crypt.','K.eye','LB.7','LB.0','LB.n','LB.sw'}

%%  Using [mycorrplot_1]
% *Syntax*
% 
% mycorrplot_1(X,xnames,type, colorbaron,textin)
%
% * X : data; we are interested in correlation between each pair of columns in X; as in corr(X)
% * xnames : name of each column in X, stored in cell array of strings; default is {'1','2','3',....}
% * type :  style of output, can be 'C','T','S','B'; default is 'B'
% * colorbaron : 0 or 1; whether to plot out the legend or not; default is 0
% * textin : 0 or 1; whether to put labels in the diagnal; default is 1 if
% xnames not specified, 0 otherwise
%% Examples of usage
% *'C'* means put all circles 
mycorrplot_1(insect_data, insect_names, 'C',1,0)
%%
% *'T'* means put text and circles 
%
% don't need legend everytime, set colorbaron (the 4th parameter) to 0
mycorrplot_1(insect_data, insect_names, 'T',0,0) 
%%
% *'S'* means put scatterplot and circles
%
% If the names are short enough, we can put them in the diagnal boxes
mycorrplot_1(insect_data, shortnames, 'S',0,1) 
%%
% *'B'* means put "Both" scatter plot and text
%
% In this case, text will be put on top of the circles. 
%  
% * The default *
% Equal to mycorrplot_1(insect_data,{'1','2','3',....,'13'},'B',0,1)
mycorrplot_1(insect_data)

