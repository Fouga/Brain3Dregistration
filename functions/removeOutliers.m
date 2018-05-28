function P = removeOutliers(point_coor,Options)

size = Options.registeredVolumeSize;
point_coor = round(point_coor);
ind_x_out = find(point_coor(:,1)>size(2) | point_coor(:,1)<=0);
point_coor(ind_x_out,:) = [];

ind_y_out = find(point_coor(:,2)>size(1) | point_coor(:,2)<=0);
point_coor(ind_y_out,:) = [];

ind_z_out = find(point_coor(:,3)>size(3) | point_coor(:,3)<=0);
point_coor(ind_z_out,:) = [];

P = point_coor;

