function [p, w] = CalculateMission( p, w )

%% Convert units
for i=1:length(p)
    % Convert Mach, Mach No -> ft/s
    if isfield(p{i}, 'mach')
        p{i}.speed = p{i}.mach * SpeedOfSound(p{i}.alt);
    end
    % Convert C, 1/hr -> 1/sec
    if isfield(p{i}, 'C')
        p{i}.C = p{i}.C / 3600;
    end
    % Convert duration, min -> sec
    if isfield(p{i}, 'duration')
        p{i}.duration = p{i}.duration * 60;
    end
end

%% Calculate mff for each segment
w.takeoff = sym('W_TO');
MFF = 1;
for i=1:length(p)
    if ~isfield(p{i}, 'mff')    % if mff specified, just use that
        switch p{i}.seg
            case 'STARTUP'
                p{i}.mff = 0.990;
            case 'TAXI'
                p{i}.mff = 0.9925;
            case 'TAKEOFF'
                p{i}.mff = 0.995;
            case 'CLIMB'
                alt_change = p{i+1}.alt - p{i-1}.alt;
                p{i}.duration = alt_change / p{i}.RoC;
                p{i}.speed = (p{i-1}.speed + p{i+1}.speed) / 2;
                p{i+1}.range = p{i+1}.range - p{i}.speed * p{i}.duration;
                p{i}.mff = BreguetLoiter( p{i}.duration, p{i}.C, p{i}.LD );
            case 'CRUISE'
                p{i}.mff = BreguetRange( p{i}.range, p{i}.speed, p{i}.C, p{i}.LD );
            case 'DESCENT'
                % Put something here if feeling fancy
            case 'RELEASE'
                p{i}.mff = 1;
                W_at_release = (1 - MFF) * w.takeoff;
                w.payload = w.payload + p{i}.dropped_weight;
                p{i+1}.bomb_ratio = (W_at_release - p{i}.dropped_weight) ...
                    / W_at_release;
                p{i}.alt = p{i-1}.alt;
                p{i}.speed = p{i-1}.speed;
            case 'RESERVES'
                p{i}.mff = BreguetLoiter( p{i}.duration, p{i}.C, p{i}.LD );
            case 'REFUEL'
                p{i}.mff = 1 / MFF; % Not convinced this works
            case 'LANDING'
                p{i}.mff = 0.992;
            otherwise
                MFF = 0;
                warning('Unknown Stage Type')
        end
    end
    if isfield(p{i}, 'bomb_ratio')
        p{i}.mff = 1 - (1 - p{i}.mff) * p{i}.bomb_ratio;
    end
    MFF = MFF * p{i}.mff;
end

%% Get the equation
w.fuel = 1.05 * w.takeoff * (1 - MFF);
w.empty = w.takeoff - w.fuel - w.payload - w.crew;

end

%% Helper functions
function a = SpeedOfSound(h)
    if (h<36000)
        T = 518.69 - 0.00359*h; %Rankine
        a = sqrt(1.4*1716.49*T); %ft/s
    elseif (h>=36000 && h < 82347)
        a = 968.1;  %constant between 36000 and 82346
    else
        warning('Altitude out of range');
    end
end

function mff = BreguetRange( R, V, C, LD )
    mff = ( exp(R / ( LD * V / C )) )^-1;
end

function mff = BreguetLoiter( E, C, LD )
    mff = ( exp(E / ( LD / C )) )^-1;
end
