% Change_Map_Properties.m
% 
% This function modifies properties and saves the current figure. It is
% useful for creating pretty figures from OpenXY results. The valuse can be
% modified as desired and the lines can be commented and uncommented as
% needed.

% dir = uigetdir; % Asks where you would like to save your map image
colormap(gca,jet); % Change colormap style (parula is default)
caxis([12 14]); % Set limits for colorbar
c = colorbar; % Change colorbar title
c.Label.String = 'GND (10^x^x^.^x m^-^2)'; % Change colorbar title
title_name = 'Ta7 - Step 6 - 5um Step'; % Change plot title
title(title_name) % Change plot title
% axis off % Turn on and of x and y axis
% set(gca,'position',[0 0 1 1],'units','normalized') % Gets rid of border around the axis
x = get(gca,'xlim'); % Calculates the size of the data in x direction
x = (x(2)-x(1))*5; % Determines the map size by multiplying the data size by a scaler
y = get(gca,'ylim'); % Calculates the size of the data in y direction
y = (y(2)-y(1))*5; % Determines the map size by multiplying the data size by a scaler
set(gcf,'Position',[-1000 0 x y]) % Repositions and resizes the figure window
% colorbar off % Removes color scale
% save_file = [dir '\' title_name]; % Sets a location and file name for where to save the figure
% saveas(gcf,save_file,'tif') % Saves the map in the predetermined location
