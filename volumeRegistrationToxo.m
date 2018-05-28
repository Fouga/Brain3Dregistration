function volumeRegistrationToxo(data_dir,angle,overwrite)
% volume registration
% need to have Mosaic file, Segmentation_resutls with *.txt position files
cd (data_dir);

% options and parameters
S=settings_handler('settingsFiles_ARAtools.yml');

Options.downSampDir = [pwd, '/' S.downSampledDir '/'];
Options.angle = angle;
Options.volFname = 'dstest_25_25_02'; % sample name
Options.originalVolumeDir = [Options.downSampDir 'originalVolume/'];
Options.sample2AraDir =[Options.downSampDir S.sample2araDir];
Options.registResult = '/result.1.mhd';
% downsample in xy and oversample in z, 25 - isitropic resolution


% maKE INI FILE
if ~exist('stitchitConf.ini')
	makeLocalStitchItConf
end

% downsample to fit the brain template
if ~exist('./downsampled/') || overwrite
    downsampleVolumeAndData(2,25,[],[],overwrite);
else 
    disp('Downsampled data already exist. Skip this step.\n')
end


% rotate sample data and move initial data to a new folder
if ~isempty(angle) && (~exist([Options.originalVolumeDir Options.volFname '.raw']) && ...
        exist([Options.downSampDir Options.volFname '.raw'])) || ~isempty(angle) && overwrite
 
        Options = rotateSampleVolume(Options);
    
else
    disp('Roatated data already exist. Skip this step.\n');
    % downsampled
    downSampledVol = fullfile(Options.originalVolumeDir,[Options.volFname,'.mhd']);
    headerInfo=mhd_read_header(downSampledVol); 
    Options.InitialVolumeSize = [headerInfo.Dimensions(2) headerInfo.Dimensions(1) headerInfo.Dimensions(3)];
    % rotated
    volNameRot = fullfile(Options.downSampDir,[Options.volFname,'.mhd']);
    headerInfo=mhd_read_header(volNameRot); 
    Options.RotatedVolumeSize = [headerInfo.Dimensions(2) headerInfo.Dimensions(1) headerInfo.Dimensions(3)];
end




% register data
if overwrite || ~exist([Options.sample2AraDir Options.registResult])
    ARAregister;
else 
    disp('Registered data already exist. Skip this step.\n');
end
% transform segmented coordinates
[point_coor,Options] = transformSegmentedCoordinates(Options);%[cols rows z]

% remove outliers from points' coordinates
point_coor = removeOutliers(point_coor,Options);


%% data analysis

% load anotated brain data to find part names
templateFile = getARAfnames;
templateFile_annotated = [templateFile(1:end-12) 'atlas_smooth1_corrected.mhd'];
headerInfo=mhd_read_header(templateFile_annotated); 
vol_atlas_annotated = mhd_read(headerInfo);

% find ID of a brain structure
% (col, row)
ID = [];

for i = 1:length(point_coor(:,1))
    ID = [ID,vol_atlas_annotated(point_coor(i,2),point_coor(i,1),point_coor(i,3))];% vol(rows,cols,z)
end
if ~exist('./data_analysis')
    mkdir('./data_analysis')
end

% get the name
for level = 3:10
    [T,IDlevel] = sortNamesByMode(ID,level);

    [Tvol,Vol] = CalculateVolumeLevel(IDlevel,vol_atlas_annotated,level);

    Tlev = table(repmat(level,length(Vol),1),'VariableNames',{'Level'});
    T = [T Tvol Tlev];
    writetable(T,['data_analysis/' sprintf('ToxoBrainDistributionLevel_%i.xls',level)]);
    % plots
    [TidSort indSort] = sort(T.ID);
    Ratio = T.number_of_toxo./T.Volume*1000;
    figure, plot(1:length(TidSort),Ratio(indSort)), 
    ylabel ('#toxo/Vol')
    xlabel ('Braind ID')
    xticks(1:length(TidSort))
    h = num2cell(TidSort);
    xticklabels(h)
    savefig(['data_analysis/' sprintf('ToxoBrainDistributionLevel_%i.fig',level)])
    close all
end


