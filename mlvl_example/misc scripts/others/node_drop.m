function xy = node_drop (box, ninit, dotmax, radius,varargin)

% --- Input parameters ---
%   box         Size of box be filled by nodes; [xmin,xmax,ymin,ymax]
%   ninit       Upper limit on number of PDP entries
%   dotmax      Upper bound for number of dots to place
%   radius      The function radius(xy) provides grain radius to be used
%               at location (x,y).
%
% --- Output parameter ---
%   xy          Array xy(:,2) with the generated node locations

dotnr   = 0;                            % Counter for the placed dots
rng('default');                                 % Initialize random number generator
pdp     = [linspace(box(1),box(2),ninit)',box(3)+ 1e-4*rand(ninit,1)];% Array to hold PDPs
pdp_end = ninit;                        % Number of PDPs in use 
xy      = zeros(dotmax,2);              % Array to store produced dot locations
[ym,i]  = min(pdp(1:pdp_end,2));        % Locate PDP with lowest y-coordinate

while ym <= box(4) && dotnr < dotmax;   % Loop over all dots that are to be placed
    dotnr = dotnr + 1;                  % Keep count for next dot to be placed
    xy(dotnr,:) = pdp(i,:);             % Place the dot

    if isempty(varargin)
        r = radius(xy(dotnr,:));% Get grain radius to be used
    else
        r = radius(xy(dotnr,:),varargin);% Get grain radius to be used
    end
    
    % --- Calculate the distance from the placed dot to all present PDPs
    dist2   = (pdp(1:pdp_end,1)-pdp(i,1)).^2+(pdp(1:pdp_end,2)-pdp(i,2)).^2;
    
    % --- Find nearest old PDP to the left, outside the new circle
    ileft  = find(dist2(1:i)  > r^2,1, 'last' );      
    if isempty(ileft );                 
        ileft    = 0;                   % Special case if no such point
        ang_left = pi;
    else
        ang_left  = atan2(pdp(ileft,2)-pdp(i,2),pdp(ileft,1)-pdp(i,1));
    end
    
    % --- Find nearest old PDP to the right, outside the new circle
    iright = find(dist2(i:pdp_end) > r^2,1, 'first'); 
    if isempty(iright);                 
        iright = 0;                     % Special case if no such point
        ang_right = 0; 
    else
        ang_right = atan2(pdp(i+iright-1,2)-pdp(i,2),pdp(i+iright-1,1)-pdp(i,1));
    end
    
    % --- Introduce five new markers along the circle sector, equispaced in angle
    ang = ang_left-[0.1;0.3;0.5;0.7;0.9]*(ang_left-ang_right);
    pdp_new = [pdp(i,1)+r*cos(ang),pdp(i,2)+r*sin(ang)];
    ind = pdp_new(:,1) < box(1) | pdp_new(:,1) > box(2);
    pdp_new(ind,:) = [];                % Remove any new PDPs outside the domain 
    nw = length(pdp_new(:,1));          % Number of new markers to be inserted
    
    % --- Remove obsolete and insert new PDPs in the array pdp
    if iright == 0                      % Place rightmost block (of old markers)
        pdp_end = ileft+nw;             % to the right of the block of new markers
    else
        ind = i+iright-1:pdp_end;
        pdp_end = ileft+nw+pdp_end-i-iright+2;
        pdp(ileft+nw+1:pdp_end,:) = pdp(ind,:);
    end
    pdp(ileft+1:ileft+nw,:) = pdp_new;  % Insert the new markers into pdp    
   
    % --- Identify next dot location, then iterate until all dots are placed
    [ym,i] = min(pdp(1:pdp_end,2));      
end                                     

xy = xy(1:dotnr,:);                     % Remove unused entries in array xy