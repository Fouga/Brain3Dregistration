function [Options,vol_rotate] = rotateSampleVolume(Options)

angle=Options.angle;

S=settings_handler('settingsFiles_ARAtools.yml');
% load initial downsampled volume of the sample data
% volFname = 'dstest_25_25_02'; % sample name

downSampledVol = fullfile(Options.downSampDir,[Options.volFname,'.mhd']);
headerInfo=mhd_read_header(downSampledVol); 
vol_data = mhd_read(headerInfo);
Options.InitialVolumeSize = [headerInfo.Dimensions(2) headerInfo.Dimensions(1) headerInfo.Dimensions(3)];

% rotate the sample
vol_rotate = imrotate(vol_data,angle);
Options.RotatedVolumeSize = size(vol_rotate);


if ~exist([Options.downSampDir 'originalVolume/'])
    mkdir ([Options.downSampDir 'originalVolume/']);
end
system(['mv ' Options.downSampDir Options.volFname '.* ' Options.downSampDir 'originalVolume/'] )

volNameRot = fullfile(Options.downSampDir, [Options.volFname '.raw']);
mhd_write(vol_rotate,volNameRot,[1,1,1]); % permut() 2,1,3

