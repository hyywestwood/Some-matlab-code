%% 程序计算结果的读取
clc;clear;

% 以普通角点形式输出的结果文件
file_path = '.';
data_node = data_from_nodal_type(file_path, 5); % 5为输出文件的编号

% 以网格单元形式输出的结果文件
file_path = '.';
data_cell = data_from_cell_type(file_path, 5);

%% 一些函数
function cell = data_from_cell_type(str,i)
% 尝试以结构体形式，读取以网格单元形式输出的Tecplot文件
% 返回名字为cell的结构体数组，其中cell.nn，cell.nc分别记录了该文件中角点及网格数目
% cell.variables_name则对应了输出变量的变量名称，这里为了便于程序处理去除了原本变量名中存在的空格及括号
% cell.solutiontime对应模拟的时长
% 也可以直接通过cell.变量名来直接调用对应变量的数据，如cell.xKm对应输出文件中所有角点的x坐标（文件中变量表示为x (Km)，这里做了处理）
% cell.topr记录网格与角点间的拓扑关系
fid=fopen([str '\csSULTS' num2str(i,'%05d') '.DAT'],'r','n','utf-8');
flag = 1;
while ~feof(fid)
    tline=fgetl(fid);
    if contains(tline, 'VarIables=')
        c = regexp(tline,'".*"','match');
        c = strrep(c{1,1},' ','');
        c = strrep(c,'(','');
        c = strrep(c,')','');
        c = strrep(c,'""','"');
        cell.varibles_name = split(strtrim(c(2:end-1)),'"');
    elseif contains(tline, 'Zone')
        b = regexp(tline,'N=\s*\d*','match');
        cell.nn = str2num(cell2mat(regexp(b{1,1},'\d*','match')));
        b = regexp(tline,'E=\s*\d*','match');
        cell.nc = str2num(cell2mat(regexp(b{1,1},'\d*','match')));
        b = regexp(tline,'SOLUTIONTIME=\s*\d*.\d*','match');
        cell.solutiontime = str2num(cell2mat(regexp(b{1,1},'\d*\.\d*','match')));
    elseif contains(tline, 'VARLOCATION')
        b = regexp(tline,'1-\d','match');
        b = split(b,'-');
        cell.nodal_type_number = str2num(b{2,1});
        cell.cell_type_number = length(cell.varibles_name) - cell.nodal_type_number;
        break
    end
end
for i = 1:cell.nodal_type_number
    eval(['cell.' cell.varibles_name{i,1} '= cell2mat(textscan(fid,''%f'',cell.nn));'])
end
for i = 1:cell.cell_type_number
    eval(['cell.' cell.varibles_name{i+cell.nodal_type_number,1} '= cell2mat(textscan(fid,''%f'',cell.nc));'])
end
cell.topr = cell2mat(textscan(fid,'%f %f %f',cell.nc));
fclose(fid);

end

function cell = data_from_nodal_type(str,i)
% 尝试以结构体形式，存储计算数据，该函数对应经典的角点格式的输出文件
% 返回名字为cell的结构体数组，其中cell.nn，cell.nc分别记录了该文件中角点及网格数目
% cell.variables_name则对应了输出变量的变量名称，这里为了便于程序处理去除了原本变量名中存在的空格及括号
% cell.solutiontime对应模拟的时长
% cell.data则返回[cell.nc， 变量个数]的二维数组
% 也可以直接通过cell.变量名来直接调用对应变量的数据，如cell.xKm对应输出文件中所有角点的x坐标（文件中变量表示为x (Km)，这里做了处理）
% cell.topr记录网格与角点间的拓扑关系
fid=fopen([str '\RESULTS' num2str(i,'%05d') '.DAT'],'r','n','utf-8');
flag = 1;
while ~feof(fid)
    tline=fgetl(fid);
    if contains(tline, 'VarIables=','IgnoreCase',true)
        c = regexp(tline,'".*"','match');
        c = strrep(c{1,1},' ','');
        c = strrep(c,'(','');
        c = strrep(c,'/','');
        c = strrep(c,')','');
        c = strrep(c,'""','"');
        cell.varibles_name = split(strtrim(c(2:end-1)),'"');
    elseif contains(tline, 'Zone')
        b = regexp(tline,'N=\s*\d*','match');
        cell.nn = str2num(cell2mat(regexp(b{1,1},'\d*','match')));
        b = regexp(tline,'E=\s*\d*','match');
        cell.nc = str2num(cell2mat(regexp(b{1,1},'\d*','match')));
        b = regexp(tline,'SOLUTIONTIME=\s*\d*.\d*','match');
        cell.solutiontime = str2num(cell2mat(regexp(b{1,1},'\d*\.\d*','match')));
        break
    end
end
cell.data = cell2mat(textscan(fid, repmat('%f ',1, length(cell.varibles_name)),cell.nn));
for i = 1:length(cell.varibles_name)
    eval(['cell.' cell.varibles_name{i,1} '= cell.data(:,i);'])
end
cell.topr = cell2mat(textscan(fid, repmat('%f ',1,3),cell.nc));

for i = 1:cell.nc
    face_1 = 1000*sqrt((cell.xKm(cell.topr(i,1)) - cell.xKm(cell.topr(i,2)))^2.0 + (cell.yKm(cell.topr(i,1)) - cell.yKm(cell.topr(i,2)))^2.0);
    face_2 = 1000*sqrt((cell.xKm(cell.topr(i,2)) - cell.xKm(cell.topr(i,3)))^2.0 + (cell.yKm(cell.topr(i,2)) - cell.yKm(cell.topr(i,3)))^2.0);
    face_3 = 1000*sqrt((cell.xKm(cell.topr(i,3)) - cell.xKm(cell.topr(i,1)))^2.0 + (cell.yKm(cell.topr(i,3)) - cell.yKm(cell.topr(i,1)))^2.0);
    cell.area(i) = 0.5*(face_1 + face_2 + face_3);
    cell.area(i) = cell.area(i)*( cell.area(i) - face_1 )*( cell.area(i) - face_2 )*( cell.area(i) - face_3 );
    cell.area(i) = sqrt(cell.area(i));
end
fclose(fid);
end