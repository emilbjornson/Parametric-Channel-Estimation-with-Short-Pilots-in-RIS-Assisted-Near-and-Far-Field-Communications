% This code is intended to demonstrate the beam shape over different azimuth 
% angle and distances
clear;clc;close all;
freq = 28e9; % Central frequency
lambda = physconst('LightSpeed') / freq; % Wavelength
M_H = 32; M_V = 32; M = M_H * M_V; % Size  of the arrat
d_H = 1/2;d_V = 1/2; % inter-element spacing
Ant_Center = [0,0,0]; 
Hsize = M_H*d_H*lambda;
Vsize = M_V*d_V*lambda;
D = sqrt(Hsize^2+Vsize^2);
d_fraun = 2*(D^2)/lambda; %2*diagonal^2/lambda/10
d_NF = d_fraun/10;
d_bjo = 2*D;
disp(['Far-Field upperbound distance is ' num2str(d_NF) ' (m)']);
disp(['Bjornson distance is ' num2str(d_bjo) ' (m)']);
i = @(m) mod(m-1,M_H); % Horizontal index
j = @(m) floor((m-1)/M_H); % Vertical index
U = zeros(3,M); % Matrix containing the position of the RIS antennas
% The relative position with respect to [0;0;0]
for m = 1:M  
    ym = (-(M_H-1)/2 + i(m))*d_H*lambda; % dislocation with respect to center in y direction
    zm = (-(M_V-1)/2 + j(m))*d_V*lambda; % dislocation with respect to center in z direction
    U(:,m) = [0; ym; zm]; % Relative position of the m-th element with respect to the center
end
% define the plane 
x_t = linspace(0,d_fraun,2000); % cover different distances
z_t = repelem(0,1,length(x_t)); % Elevation angle of zero
y_t = linspace(-d_fraun/2,d_fraun/2,length(x_t)); % cover different azimuth
az = [0,pi/6,-pi/6]; % Which azimuth to consider for beamforming
pow = zeros(length(y_t),length(x_t),length(az));

for j = 1:length(az)
    % Near-field array response
    nearChan1 = nearFieldChan(d_NF/2,az(j),0,U,lambda); 
    % Vector response on the plane parallel to X-Y plane 
    parfor i = 1:length(x_t)
        [azimuth,elevation,Cph,d_t] = ChanParGen(repelem(x_t(i),1,length(y_t)),y_t,z_t,Ant_Center,lambda);
        nearChan2 = nearFieldChan(d_t,azimuth,elevation,U,lambda); 
        pow(:,i,j) = abs(1/sqrt(M)*nearChan2'*nearChan1).^2;
    end

end
% Process the data
pow = pow2db(pow);
pow(pow<0) = 0;
pow = max(pow,[],3);
% Plot the combined figure
figure("defaultAxesFontSize",20,"DefaultLineLineWidth", 2,...
    "defaultAxesTickLabelInterpreter","latex");
imagesc([x_t(1) x_t(end)],[y_t(1) y_t(end)],pow);
xlabel('X (m)','FontSize',20,'Interpreter','latex');
ylabel('Y (m)','FontSize',20,'Interpreter','latex');
hold on
plot([0,0],[-Hsize/2,Hsize/2],'LineWidth',10,'Color','r');
% Figure size
ax = gca; % to get the axis handle
ax.XLabel.Units = 'normalized'; % Normalized unit instead of 'Data' unit 
ax.Position = [0.15 0.15 0.8 0.8]; % Set the position of inner axis with respect to
                           % the figure border
ax.XLabel.Position = [0.5 -0.07]; % position of the label with respect to 
                                  % axis
fig = gcf;
set(fig,'position',[60 50 900 600]);
