
%% parameters
phase_Matrix = ones(20,20)*45;
[m,n] = size(phase_Matrix);
unit = 300;
h1 = 1000; %substrate, SiO2
h2_1 = 130; %Gold Layer
h2_2 = 90; %Glass Layer
h2 = h2_1+h2_2;
h3 = 30; %rob layer
rob_long = 200;
rob_short = 80;

%% Generating phase distribution
f = 5000;
wavelength = 1000;
x = -m/2*unit:unit:(m/2-1)*unit;
y = -m/2*unit:unit:(m/2-1)*unit;
[X , Y] = meshgrid( x, y );
phase_Matrix = rem(((X.^2 + Y.^2 + f^2).^0.5 - f)/wavelength,1)*180;
imagesc(x,y,phase_Matrix); colorbar;


%% create
a = Cre_BAS;
% add material
a.defMaterial('Silicon (loss free)');
a.defMaterial('MgF2');
a.defMaterial('Gold (Johnson) (optical)');
% Airbox
airbox_sizeX = m*unit;
airbox_sizeY = n*unit;
airbox_sizeZ = 10000;
a.square('airbox','component1','Vacuum',[-airbox_sizeX/2,airbox_sizeX/2],...
    [-airbox_sizeY/2,airbox_sizeY/2],[-airbox_sizeZ,airbox_sizeZ]);
% substrate
a.square('substrate','component1','Vacuum',[-airbox_sizeX/2,airbox_sizeX/2],...
    [-airbox_sizeY/2,airbox_sizeY/2],[0,h1]);
a.subtract('component1:airbox','component1:substrate');
a.square('substrate','component2','Silicon (loss free)',[-airbox_sizeX/2,airbox_sizeX/2],...
    [-airbox_sizeY/2,airbox_sizeY/2],[0,h1]);

% Gold Layer
a.square('goldlayer','component1','Vacuum',[-airbox_sizeX/2,airbox_sizeX/2],...
    [-airbox_sizeY/2,airbox_sizeY/2],[h1,h1+h2_1]);
a.subtract('component1:airbox','component1:goldlayer');
a.square('goldlayer','component3','Gold (Johnson) (optical)',[-airbox_sizeX/2,airbox_sizeX/2],...
    [-airbox_sizeY/2,airbox_sizeY/2],[h1,h1+h2_1]);
%MgF2 Layer
a.square('MgF2layer','component1','Vacuum',[-airbox_sizeX/2,airbox_sizeX/2],...
    [-airbox_sizeY/2,airbox_sizeY/2],[h1+h2_1,h1+h2]);
a.subtract('component1:airbox','component1:MgF2layer');
a.square('MgF2layer','component3','MgF2',[-airbox_sizeX/2,airbox_sizeX/2],...
    [-airbox_sizeY/2,airbox_sizeY/2],[h1+h2_1,h1+h2]);

% Robs
for i = 1:m
    for j = 1:n
        a.square(['rob_',num2str(i),'_',num2str(j)], 'component1',...
            'Vacuum',[-rob_long/2,rob_long/2],[-rob_short/2,rob_short/2],[h1+h2,h1+h2+h3]);
        a.rotate(['component1:rob_',num2str(i),'_',num2str(j)],...
            [0,0,0],[0,0,phase_Matrix(i,j)]);
        a.translate(['component1:rob_',num2str(i),'_',num2str(j)],...
            [-airbox_sizeX/2 - unit/2 + i*unit,-airbox_sizeY/2 - unit/2 + j*unit,0]);
        a.subtract('component1:airbox',['component1:','rob_',num2str(i),'_',num2str(j)]);
        
        a.square(['rob_',num2str(i),'_',num2str(j)], 'component4',...
            'Gold (Johnson) (optical)',[-rob_long/2,rob_long/2],[-rob_short/2,rob_short/2],[h1+h2,h1+h2+h3]);
        a.rotate(['component4:rob_',num2str(i),'_',num2str(j)],...
            [0,0,0],[0,0,phase_Matrix(i,j)]);
        a.translate(['component4:rob_',num2str(i),'_',num2str(j)],...
            [-airbox_sizeX/2 - unit/2 + i*unit,-airbox_sizeY/2 - unit/2 + j*unit,0]);
        
    end
end