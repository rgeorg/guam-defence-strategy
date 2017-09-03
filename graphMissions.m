clear all;
hold off

%Aircraft Specifications
Vto = 200; %ft/s
loiterPeriod = 30; %minutes
loiterLD = 8;
loiterC = 0.8; %lbs/lbs/hr

%                       %
%  %%% MISSION ONE %%%  %
%                       %
%Mission Specifications
MissionStage1 = {'climb','cruise','release','climb','cruise','descent','reserves'};
cruiseAlt = [45000,50000]; %feet
cruiseMach = [1.2,1.2];
cruiseRange = [9849600,9849600]; %feet
cruiseLD = [8,6];
cruiseC = [1,0.8]; %lbs/lbs/hr
climbRates = [500,700]; %ft per second

k=1;
for i=30000:1000:200000
    takeoffWeight1(k) = i;
    missionOne = MissionProf(i,MissionStage1,Vto,cruiseAlt,cruiseMach,cruiseRange,cruiseLD,cruiseC,climbRates,loiterPeriod,loiterLD,loiterC);
    missionOne.mffCalc;
    emptyWeight1(k) = missionOne.we;
    k=k+1;
end
loglog(takeoffWeight1, emptyWeight1);
hold all



%                       %
%  %%% MISSION TWO %%%  %
%                       %
%Mission Specifications
MissionStage2 = {'climb','cruise','descent','cruise','release','cruise','climb','cruise','descent','reserves'};
cruiseAlt = [45000,20000,20000,50000]; %feet
cruiseMach = [1.2,0.85,0.85,1.2];
cruiseRange = [9059200,790400,790400,9059200]; %feet
cruiseLD = [9,8,7,6];
cruiseC = [1,0.6,0.6,0.8]; %lbs/lbs/hr
climbRates = [500,500,500,700]; %ft per second

k=1;
for i=30000:1000:200000
    takeoffWeight2(k) = i;
    missionTwo = MissionProf(i,MissionStage2,Vto,cruiseAlt,cruiseMach,cruiseRange,cruiseLD,cruiseC,climbRates,loiterPeriod,loiterLD,loiterC);
    missionTwo.mffCalc;
    emptyWeight2(k) = missionTwo.we;
    k=k+1;
end
loglog(takeoffWeight2, emptyWeight2);


%                         %
%  %%% MISSION THREE %%%  %
%                         %
%Mission Specifications
MissionStage3 = {'climb','cruise','descent','cruise','release','cruise','climb','cruise','descent','reserves'};
cruiseAlt = [45000,2000,2000,50000]; %feet
cruiseMach = [1.2,0.85,0.85,1.2];
cruiseRange = [6809600,3040000,3040000,6809600]; %feet
cruiseLD = [9,8,7,6];
cruiseC = [1,0.6,0.6,0.8]; %lbs/lbs/hr
climbRates = [500,500,500,700]; %ft per second


k=1;
for i=30000:1000:200000
    takeoffWeight3(k) = i;
    missionThree = MissionProf(i,MissionStage3,Vto,cruiseAlt,cruiseMach,cruiseRange,cruiseLD,cruiseC,climbRates,loiterPeriod,loiterLD,loiterC);
    missionThree.mffCalc;
    emptyWeight3(k) = missionThree.we;
    k=k+1;
end
loglog(takeoffWeight3, emptyWeight3);

%                        %
%  %%% MISSION FOUR %%%  %
%                        %
%Mission Specifications
MissionStage4 = {'climb','cruise','climb','cruise','release','cruise','descent','cruise','descent','reserves'};
cruiseAlt = [45000,60000,60000,50000]; %feet
cruiseMach = [1.2,1.8,1.8,1.2];
cruiseRange = [8268800,1580800,1580800,8268800]; %feet
cruiseLD = [9,5,5,8];
cruiseC = [0.8,0.6,0.6,1]; %lbs/lbs/hr
climbRates = [500,500,0,0]; %ft per second

k=1;
for i=30000:1000:200000
    takeoffWeight4(k) = i;
    missionFour = MissionProf(i,MissionStage4,Vto,cruiseAlt,cruiseMach,cruiseRange,cruiseLD,cruiseC,climbRates,loiterPeriod,loiterLD,loiterC);
    missionFour.mffCalc;
    emptyWeight4(k) = missionFour.we;
    k=k+1;
end
loglog(takeoffWeight4, emptyWeight4);

%                        %
%  %%% MISSION FIVE %%%  %
%                        %
%Mission Specifications
MissionStage5 = {'climb','cruise','refuel','cruise','descent','cruise','release','cruise','climb','cruise','descent','reserves'};
cruiseAlt = [45000,45000,200,200,50000]; %feet
cruiseMach = [1.2,1.2,0.85,0.85,1.8];
cruiseRange = [6080000,6809600,6080000,3040000,3040000]; %feet
cruiseLD = [9,9,9,8,8];
cruiseC = [1,1,0.8,1,1.2]; %lbs/lbs/hr
climbRates = [500,0,0,0,700]; %ft per second

k=1;
for i=30000:1000:200000
    takeoffWeight5(k) = i;
    missionFive = MissionProf(i,MissionStage5,Vto,cruiseAlt,cruiseMach,cruiseRange,cruiseLD,cruiseC,climbRates,loiterPeriod,loiterLD,loiterC);
    missionFive.mffCalc;
    emptyWeight5(k) = missionFive.we;
    k=k+1;
end
loglog(takeoffWeight5, emptyWeight5);

%                       %
%  %%% MISSION SIX %%%  %
%                       %
%Mission Specifications
MissionStage6 = {'climb','cruise','descent','reserves'};
cruiseAlt = [45000]; %feet
cruiseMach = [0.8];
cruiseRange = [3040000]; %feet
cruiseLD = [9];
cruiseC = [1]; %lbs/lbs/hr
climbRates = [700]; %ft per second

k=1;
for i=30000:1000:200000
    takeoffWeight6(k) = i;
    missionSix = MissionProf(i,MissionStage6,Vto,cruiseAlt,cruiseMach,cruiseRange,cruiseLD,cruiseC,climbRates,loiterPeriod,loiterLD,loiterC);
    missionSix.mffCalc;
    emptyWeight6(k) = missionSix.we;
    k=k+1;
end
loglog(takeoffWeight6, emptyWeight6);

% Format plot
title('Technology diagram','interpreter','latex');
xlabel('Gross take-off weight $W_{TO}$, kg','interpreter','latex');
ylabel('Empty weight $W_{E}$, kg','interpreter','latex');
B = 1.0495;
A = 0.1111;
xlim([1e4 4e5]);
ylim([8e3 2e5]);

%                          %
%  %%% PLOT TECH LINE %%%  %
%                          %
% Plot the line
yline = ylim;
xline = 10.^(A+B.*log10(yline));
loglog(xline, yline);
legend('High Level','Medium Level Penetration','Low Level Penetration','High Level Penetration','Single Integrated Operational Plan','Ferry','Technology Line','Location','NorthWest');