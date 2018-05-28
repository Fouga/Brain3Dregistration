function [Tvol, Vol] = CalculateVolumeLevel(IDlevel,vol_atlas_annotated,level)


% load the data base
ARA_LIST = getAllenStructureList;

% build tree structure
Lev = 0;
id = ARA_LIST.id(ARA_LIST.depth==Lev);
t = tree(id);
Lev = 1;
id = ARA_LIST.id(ARA_LIST.depth==Lev);
NODE1 = zeros(1,length(id));
for i =1:length(id)
    [t node] = t.addnode(1,id(i));
    NODE1(i) = node;
end
nodesall = cell(1,max(ARA_LIST.depth));
nodesall{1} = NODE1;
for Lev = 2:max(ARA_LIST.depth)
% Lev = 2;
    id = ARA_LIST.id(ARA_LIST.depth==Lev);
    Parent = ARA_LIST.parent_structure_id(ARA_LIST.depth==Lev);
    NODE = zeros(1,length(id));
    T = t.Node;
    node_tmp = nodesall{Lev-1};
    ParentsOld = cell2mat(T(node_tmp));
    for i =1:length(id)
        ind = find(ParentsOld==Parent(i));

        [t node] = t.addnode(node_tmp(ind),id(i));
        NODE(i) = node;
    end
    nodesall{Lev} = NODE;
end

disp(t.tostring)



%%
if level~=max(ARA_LIST.depth)
    T = cell2mat(t.Node);    
    % find all the id down the current ID level
    Vol = zeros(1,length(IDlevel));
    for i=1:length(IDlevel)
        a = IDlevel(i);
        fprintf('Calculating volume for %s\n',cell2mat(ARA_LIST.name(ARA_LIST.id==a)));
        ind = find(T==a);
        t1 = t.subtree(ind);
        nodest1 = cell2mat(t1.Node);
        Volt1 = zeros(1,length(nodest1));
        for j=1:length(nodest1)
            x = nodest1(j);
            Volt1(j) =length(find(vol_atlas_annotated(:)==x));
        end
        Vol(i) = sum(Volt1);

    end
else
    Vol = zeros(1,length(IDlevel));
    for i=1:length(IDlevel)
        x = IDlevel(i);
        Vol(i) =length(find(vol_atlas_annotated(:)==x));
    end
end

Tvol = table(Vol','VariableNames',{'Volume'});

% 
% 
% for i = 1:size(vol_atlas_annotated,3)
%     slice = vol_atlas_annotated(:,:,i);
%     slice_new = zeros(size(slice));
%     ind = find(slice~=0);
%     for p = 1:length(ind)
%         a = slice(ind(p)); % ID
%         f=find(ARA_LIST.id == a); 
%         while ARA_LIST.depth(f)> level
% 
%             a = ARA_LIST.parent_structure_id(f);
%             f=find(ARA_LIST.id == a);
% %             ARA_LIST.depth(f)
% %             structureID2name(a)
%         end
%         slice_new(ind(p)) = a;
%     end
%     vol_atlas_annotated_new(:,:,i) = slice_new;
% %     figure, subplot(1,2,1), imagesc(slice)
% %      subplot(1,2,2), imagesc(slice_new)
% i
% end