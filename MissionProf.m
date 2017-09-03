classdef MissionProf < handle
    %Calcs mission fuel fraction
    
    properties
        %Setup the hash table for easier indexing and function calling
        stageKeys = {'climb', 'cruise', 'release', 'descent', 'reserves', 'refuel'}
        stageValues = [1,2,3,4,5,6]
        stage
        stageString
        %  stageObj = containers.Map(obj.stageKeys,obj.stageValues,'UniformValues',false);
        %  stageArr = values(stageObj,stage);
        
        %setup the variables for the function
        WtoGuess
        vTo
        vPriorClimb
        mff
        initMff
        overallMff
        storeWeight = 10000
        cruiseIndex
        cruiseAlt
        cruiseVelo
        cruiseRange
        LonD
        C
        roc
        
        reservePeriod
        loiterLonD
        loiterC
        
        %hardcode any unique stages here
        warmup = 0.990
        taxi = 0.9925
        takeoff = 0.995
        landing = 0.992
    end
    
    methods
        function obj = MissionProf(guessWeight,stage,vto,cruiseAlt,cruiseVelocities,cruiseLength,LD,C,roc,resMin,loitLD,loitC)
            %stage -> array of each mission section in order after takeoff
            % ProfileOne =
            % MissionProf({'climb','cruise','release','climb','cruise','descent','landing','reserves'},[45000,50000],[1.2,1.2],[9843307],[10,9],[1,1.2],[20,40],30,8,0.8);
            
            %OR
            
            % MissionStages =
            % {'climb','cruise','release','climb','cruise','descent','reserves'};
            % ProfileOne = MissionProf(MissionStages,[45000,50000],[1.2,1.2],[9843307],roc,[10,9],[1,1.2],30,8,0.8);
            
            % Assign the variables to the object
            obj.vTo = vto;
            obj.WtoGuess = guessWeight;
            obj.cruiseAlt = cruiseAlt;
            obj.cruiseVelo = cruiseVelocities;
            obj.cruiseRange = cruiseLength;
            obj.LonD = LD;
            obj.C = C;
            obj.roc = roc;

            obj.reservePeriod = resMin;
            obj.loiterLonD = loitLD;
            obj.loiterC = loitC;
            obj.cruiseIndex = 1;
            
            obj.stage = stage;
        end
        function overallMff = mffCalc(obj)
             %When releaseNext is set to 1 the _next_ mff will adjust for the reduction in
             %weight from the store release
             releaseNext = 0;
             %These track the cruise session and velocities 
             %in order to correct adjust the range credit
             obj.cruiseIndex = 1;
             obj.vPriorClimb = obj.vTo;
             bombRatio = 1;
            %calculate MFF for each stage
            obj.initMff = obj.warmup * obj.taxi * obj.takeoff;
            for i=1:length(obj.stage)
                obj.stageString = obj.stage{i};
                %Checks if stage is for a store release, if it is calculate
                %the weight up to that point and trigger the releaseNext
                %flag to ensure the next stage is correctly modified as per
                %Roskam V1 Pg 64
                if strcmp(obj.stageString,'release') 
                    %just sets it to 1 as we're assuming no fuel loss from release
                    %Can change so it considers combat time via the loiter equation.
                    obj.mff(i) = mffStageCalc(obj);
                                                    
                    %Setup for the weight correction in the next stage
                    wAtRelease = (1-prod([obj.initMff, obj.mff])) * obj.WtoGuess;
                    bombRatio = (wAtRelease - obj.storeWeight) / wAtRelease;
                    releaseNext = 1;
                elseif releaseNext == 1
                    obj.mff(i) = 1-(1-mffStageCalc(obj))*bombRatio;
                    releaseNext = 0;
                else
                    obj.mff(i) = mffStageCalc(obj);
                end
                %increment the cruise index if it was a cruise period
                if strcmp(obj.stageString,'cruise')
                    obj.cruiseIndex = obj.cruiseIndex+1;
                end
            end
            if bombRatio == 1
                %Bombs were not released and we assume they weren't carried
                obj.storeWeight = 0;
            end
            obj.overallMff = prod([obj.initMff, obj.mff, obj.landing]);
        end
        function MFF = mffStageCalc(obj)
            switch (obj.stageString)
                case 'climb'
                    % TODO: use loiter eqn?
                    %calc range credit
                    a = speedOfSound(obj);
                    nextCruiseVelo = obj.cruiseVelo(obj.cruiseIndex)*a;
                    nextCruiseAlt = obj.cruiseAlt(obj.cruiseIndex);
                    aveVelo = (obj.vPriorClimb + nextCruiseVelo)/2;
                    
                    timeToComplete = nextCruiseAlt/obj.roc(obj.cruiseIndex);
                    climbRange = aveVelo * timeToComplete;
                    obj.cruiseRange(obj.cruiseIndex) = obj.cruiseRange(obj.cruiseIndex) - climbRange;
                    
                    MFF = 0.92; % 0.92-0.87 (supercruise) / 0.980 (bombers)
                case 'cruise'
                    %CRUISE
                    MFF = cruiseCalc(obj);
                case 'release'
                    %RELEASE
                    MFF = 1; %Placeholder in case it is required in the future
                case 'descent'
                    % TODO: use loiter eqn and rate of descent?
                    %DESCENT
                    MFF = 0.9875;
                case 'reserves'
                    %RESERVES
                    MFF = loiterCalc(obj);%loiter period of 30 minutes and 5% on top
                case 'refuel'
                    %REFUEL
                    MFF = 1/prod(obj.mff); %Should set mff back to 1 up to this point
                otherwise
                    MFF = 0;
                    warning('Unknown Stage Type')
            end
        end
        function CruiseFrac = cruiseCalc(obj)
            m = obj.cruiseVelo(obj.cruiseIndex);
            range = obj.cruiseRange(obj.cruiseIndex);
            lOnD = obj.LonD(obj.cruiseIndex);
            c = obj.C(obj.cruiseIndex) / 3600; %converts into seconds
            a = speedOfSound(obj);
            velo = m*a;
            obj.vPriorClimb = velo;
            CruiseFrac = 1/exp(range/((velo/c)*(lOnD)));
        end
        function speedSound = speedOfSound(obj)
            h = obj.cruiseAlt(obj.cruiseIndex);
            %matrix of values for different altitudes in ft
            if (h<36000)
                T = 518.69 - 0.00359*h; %Rankine
                speedSound = sqrt(1.4*1716.49*T); %ft/s
            elseif (h>=36000 && h < 82347)
                speedSound = 968.1;  %constant between 36000 and 82346
            else
                warning('Altitude out of range');
            end
        end
        function LoiterFrac = loiterCalc(obj)
            t = obj.reservePeriod;
            lOnD = obj.loiterLonD;
            c = obj.loiterC / 3600; %converts into seconds
            t = t * 60;             %converts into seconds
            LoiterFrac = 1/exp(t/((1/c)*(lOnD)));
        end
        function wF = wf(obj)
           % 5% reserve fuel
           wF = 1.05*(1-obj.overallMff)*obj.WtoGuess;
        end
        function wE = we(obj)
           fuelWeight = wf(obj);
           wE = fuelWeight - 0.005*obj.WtoGuess - obj.storeWeight;
        end
    end
end

