%% SMS
%{ 
网格文件中的map文件记录了画网格时制作的控制边，以及控制点的信息
程序输出结果中，Node记录了控制点的坐标
Arc1,Arc2...等记录第i条控制边上Feature点的位置信息
Arcs将各Arc边信息汇总至同一个数组中
%}
clc;clear;
file_name = './mesh/cell.map';

fid=fopen(file_name,'r','n','utf-8');
Node = []; Arcs = []; Arc_num=0;
while ~feof(fid)
    tline=fgetl(fid);
    if startsWith(tline, 'NODE') && length(tline) == 4
        tline=fgetl(fid);
        S = regexp(tline, '\s+', 'split');
        Node = [Node; str2double(S{2}),str2double(S{3}),str2double(S{4})];
    elseif startsWith(tline, 'ARCVERTICES')
        S = regexp(tline, '\s+', 'split');
        ARCVERTICES = str2double(S{2}); %控制边对应的各分节点(Feature Vertex)总数
        Arc_num = Arc_num + 1;
        eval(['Arc' num2str(Arc_num) '= cell2mat(textscan(fid,''%f %f %f'',ARCVERTICES));']);
        eval(['Arcs = [Arcs; Arc' num2str(Arc_num) '];']);
%         Arcs = [Arcs; cell2mat(textscan(fid,'%f %f %f',ARCVERTICES))];
    end
end