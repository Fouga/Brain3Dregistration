function [point_coor,Options] = transformSegmentedCoordinates(Options)

segmentation_dir = './Segmentation_results/';

% read parameters
OBJECT=returnSystemSpecificClass;
param = OBJECT.readMosaicMetaData(getTiledAcquisitionParamFile);

% collect txts to one file
[coordinate_name, B] = resampleRotateCoodinates(segmentation_dir,param.sections,param.layers,Options);

% transform the coordinates
point_coor = applyElastixSparceCoordinates(coordinate_name,B);

% plot the results
Options = plotTransformationResults(point_coor,B,Options);

