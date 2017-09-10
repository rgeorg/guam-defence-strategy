hold off
clearvars
close all
set(groot,'DefaultAxesColorOrder', [0 0 0], ...
    'DefaultAxesLineStyleOrder', '-|--|:|-.');

% Load the data
load('aircraft_data.mat');

% Plot data points
loglog([aircraft(~[aircraft.UnusualWing]).W_TO], ...
    [aircraft(~[aircraft.UnusualWing]).W_E], '.');
hold on
loglog([aircraft([aircraft.UnusualWing]).W_TO], ...
    [aircraft([aircraft.UnusualWing]).W_E], 'x');

% Format plot
title('Technology diagram---supersonic stealth bombers','interpreter','latex');
xlabel('Gross take-off weight $W_{TO}$, kg','interpreter','latex');
ylabel('Empty weight $W_{E}$, kg','interpreter','latex');
xlim([1e4 4e5]);
ylim([8e3 2e5]);
legend({'Conventional Wing', 'Non-Conventional Wing'}, ...
    'interpreter', 'latex', 'location', 'best');

% Fit line "log10(W_TO) = A + B*log10(W_E)"
coeffs = polyfit(log10([aircraft.W_E]), log10([aircraft.W_TO]), 1);
B = coeffs(1);
A = coeffs(2);

% Plot the line
yline = ylim;
xline = 10.^(A+B.*log10(yline));
loglog(xline, yline);

% Display equation of line
annotation('textbox', 'String', {'$log(W_{TO})=A+B log(W_{E})$', ...
    ['$A=' num2str(A, '%.4f') '$'], ...
    ['$B=' num2str(B, '%.4f') '$']}, ...
    'FitBoxToText', 'on', 'interpreter', 'latex');

% Label points
for i=1:length(aircraft)
    text(aircraft(i).W_TO*1.03, aircraft(i).W_E*1.03, num2str(i));
end
labels = {aircraft.Name};
for i=1:length(aircraft)
    labels{i} = [num2str(i) '. ' labels{i}];
end
annotation('textbox', 'String', labels, 'FitBoxToText', 'on', ...
    'interpreter', 'latex');








