function [T,id] = sortNamesByMode(ID,level)


% load the data base
ARA_LIST = getAllenStructureList;

if nargin<2
    level = max(ARA_LIST.depth);
elseif level>max(ARA_LIST.depth)
    error('Maximum level is %i', max(ARA_LIST.depth));
end

% change the name according to the level of depth
ID_new = zeros(size(ID));
f_delete = [];
for i = 1:length(ID)
    a = ID(i);
    f=find(ARA_LIST.id == a); % index in the structure
    if ~isempty(f)
        while ARA_LIST.depth(f)> level
            a = ARA_LIST.parent_structure_id(f);
            f=find(ARA_LIST.id == a);
        %     ARA_LIST.depth(f)
        %     structureID2name(a)
        end
    else
        f_delete = [f_delete;i];% indeces outside the brain
    end
    ID_new(i) =  a;
end
ID_new(f_delete) = [];
[a,b] = mode(ID_new);
fprintf('The largest amount of toxo is in the %s area.\n', structureID2name(a));
% make a table with names
IDnames = cell(1,1); k =1;
IDnum = []; id = [];
while ~isempty(ID_new)
    [a,b] = mode(ID_new);
    IDnames{k} = structureID2name(a);
    IDnum = [IDnum; b];
    id = [id;a];
    k = k+1;
    ID_new(ID_new==mode(ID_new)) = [];
end
T = table(IDnames', IDnum, id,'VariableNames', {'brain_part_name'; 'number_of_toxo';'ID'})