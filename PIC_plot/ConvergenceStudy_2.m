%% Convergence study
clc;clear;
file_path = 'E:\算例1\Pollutant transport in a squared cavity\算例\RK';
mesh_size = ["dx20","dx40","dx80","dx160"];
rec_scheme = ["First", "MUSCL-Hou", "MUSCL-Song", "WENO-Wolf", "WENO-Ye2", "WENO-Ye3", "Hybrid"];

for m = 1:length(mesh_size)
    
    % 对应网格大小下的解析解
    path = fullfile(file_path, char(mesh_size(m)));
    cell = read_cell(path);
    eval(['exact.mesh' num2str(m) '.data = get_exact(1921.2641928394, 264, 10, cell.x, cell.y);' ]);
    eval(['exact.mesh' num2str(m) '.area = cell.area;' ]);
    
    % 读取模拟值，并求对应的范数
    for n = 1:length(rec_scheme)
        path = fullfile(file_path, char(mesh_size(m)), char(rec_scheme(n)));
        cell = data_from_cell_type(path, 1);
        
        total_1 = 0; total_2 = 0; total_3 = 0; total_area = 0;
        for i = 1:cell.nc
            eval(['total_1 = total_1 + ' 'abs(cell.c1(i)/10.0 - exact.mesh' num2str(m)  '.data(i)) * exact.mesh' num2str(m) '.area(i);' ]);
            eval(['total_2 = total_2 + ' '(cell.c1(i)/10.0 - exact.mesh' num2str(m)  '.data(i))^2.0 * exact.mesh' num2str(m) '.area(i);' ]);
            eval(['total_3 = max(total_3, abs(cell.c1(i)/10.0 - exact.mesh' num2str(m)  '.data(i)));' ]);
            eval(['total_area = total_area + exact.mesh' num2str(m) '.area(i);']);
        end
        
        % 存入结构数组
        eval(['modeled.L1_' num2str(n) '(' num2str(m) ') = total_1/total_area;' ]);
        eval(['modeled.L2_' num2str(n) '(' num2str(m) ') = sqrt(total_2/total_area);' ]);
        eval(['modeled.Lw_' num2str(n) '(' num2str(m) ') = (total_3);' ]);
        
    end
end

%% 一些函数
function cell = read_cell(file_path)
fid=fopen([file_path '\cell.geo'],'r','n','utf-8');
while ~feof(fid)
    tline=fgetl(fid);
    if contains(tline, 'GE')
        S = regexp(tline, '\s+', 'split');
        NC = str2num(S{2});
        topr(NC, 1) = str2num(S{3});
        topr(NC, 2) = str2num(S{5});
        topr(NC, 3) = str2num(S{7});
    elseif contains(tline, 'GNN')
        S = regexp(tline, '\s+', 'split');
        NN = str2num(S{2});
        Node(NN, 1) = str2num(S{3});
        Node(NN, 2) = str2num(S{4});
        Node(NN, 3) = str2num(S{5});       
    end
end
cell.topr = topr;
for i = 1:length(topr)
    cell.x(i,1) = (Node(topr(i, 1), 1) + Node(topr(i, 2), 1) + Node(topr(i, 3), 1))/3.0;
    cell.y(i,1) = (Node(topr(i, 1), 2) + Node(topr(i, 2), 2) + Node(topr(i, 3), 2))/3.0;
    cell.z(i,1) = (Node(topr(i, 1), 3) + Node(topr(i, 2), 3) + Node(topr(i, 3), 3))/3.0;
end

for i = 1:NC
    face_1 = sqrt((Node(topr(i,1), 1) - Node(topr(i,2), 1))^2.0 + (Node(topr(i,1), 2) - Node(topr(i,2), 2))^2.0);
    face_2 = sqrt((Node(topr(i,2), 1) - Node(topr(i,3), 1))^2.0 + (Node(topr(i,2), 2) - Node(topr(i,3), 2))^2.0);
    face_3 = sqrt((Node(topr(i,3), 1) - Node(topr(i,1), 1))^2.0 + (Node(topr(i,3), 2) - Node(topr(i,1), 2))^2.0);
    cell.area(i) = 0.5*(face_1 + face_2 + face_3);
    cell.area(i) = cell.area(i)*( cell.area(i) - face_1 )*( cell.area(i) - face_2 )*( cell.area(i) - face_3 );
    cell.area(i) = sqrt(cell.area(i));
end

end


function c_exact = get_exact(t, theta, internal, x_loc, y_loc)
%{
t:模拟时长；theta:分布分散程度;internal:最大浓度，用于归一化浓度场
%}
% 计算解析解
syms x y
x1 = 1400; y1 = 1400;
x2 = 2400; y2 = 2400;
c1 = 10; c2 = 6.5;
u = 0.5; v = 0.5;
c = c1 * exp(-((x - u * t - x1) / theta)^2.0 - ((y - v * t - y1) / theta)^2.0) + c2 * exp(-((x - u * t - x2) / theta)^2.0 - ((y - v * t - y2) / theta)^2.0);
c = c/internal;
c_exact = double(subs(c,{x,y},{x_loc, y_loc}));
end

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