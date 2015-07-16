%% plot_circle.m
% draw a filled circle
function plot_circle(center,radius,facecolor,edgcolor)
script_mycolorplate
if (nargin < 3), facecolor =  mycolor(2,:); end;
if (nargin < 4), edgcolor = facecolor; end;
 
starts = center-radius;
sizes = repmat(radius,1,2)*2;
rectangle('position', [starts, sizes],'Curvatur',[1,1],'Facecolor',facecolor,'Edgecolor',edgcolor);