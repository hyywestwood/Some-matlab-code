%% 生成Tecplot格式的文件
clc;clear;
file_path = '.';
data_node = data_from_nodal_type(file_path, 5); % 5为输出文件的编号

%% 生成nodal格式的文件
% 需先准备数据，需要的信息至少有x,y,其他变量...，和网格拓扑关系
% 这里以浓度c1为例
variables_name = ["x", "y", "c1"];
variables_data = [data_node.xKm, data_node.yKm, data_node.c1];
output_filename = 'test_nodal.dat';
generate_nodal_type_file(variables_name, variables_data,data_node.solutiontime, data_node.topr, output_filename);
%{
本函数的适用场景为：需要对程序原输出结果进行分析，分析后生成新的变量，利用Tecplot对新变量进行绘图
如，利用水沙模型计算出潮位信息，在MATLAB中对结果进行处理，得到潮位的潮差迟角等信息
再将新信息写成tecplot文件，利用tecplot作图
%}

%% 生成cell格式的文件
clc;clear;
cell = data_from_cell_type('Result00001.DAT');
cell_data = cell.c1;
nodal_data = [cell.xKm, cell.yKm];
cell_data = cell.c1*10;
variables_name = ["x", "y", "Chla"];
output_filename = ['cell_type_tec_file.dat'];
generate_cell_type_file(variables_name, nodal_data, cell_data, cell.solutiontime, cell.topr, output_filename);



%% 函数
function generate_nodal_type_file(variables_name, variables_data, solutiontime, topr, output_filename)
%{
本函数用于生成经典的角点格式的Tecplot输出文件
本函数运行所需参数为：
variables_name：长度至少为3的数组，记录输出变量的名称
variables_data：长度为nn*length(variables_name),nn为角点总数，该数组记录各变量的取值信息
solutiontime：程序模拟时长，可随意给定
topr：数组长度为nc*3，nc为计算单元总数，该数组记录计算单元与角点间的拓扑关系
output_filename：输出文件的名字，可包含路径
%}
fid=fopen(output_filename,'w','n','utf-8');
first_line = 'Variables= \t ';
for i = 1:length(variables_name)
    first_line = [first_line, '\"', char(variables_name(i)), '\" \t'];
end
first_line = [first_line, '\r\n'];
fprintf(fid, first_line);

second_line = ['Zone N= ' num2str(length(variables_data)) '  E= ' num2str(length(topr)) ...
    '  F=FEPOINT           ET=TRIANGLE         SOLUTIONTIME=  ' num2str(solutiontime) '  \r\n'];
fprintf(fid, second_line);

for i = 1:length(variables_data)
   fprintf(fid, [repmat('%f \t\t ',1,length(variables_name)) '\r\n'], variables_data(i,:)); 
end
for i = 1:length(topr)
   fprintf(fid, [repmat('%d \t\t ',1,3) '\r\n'], topr(i,:)); 
end
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

function cell = data_from_cell_type(file_path)
% 尝试以结构体形式，读取以网格单元形式输出的Tecplot文件
% 返回名字为cell的结构体数组，其中cell.nn，cell.nc分别记录了该文件中角点及网格数目
% cell.variables_name则对应了输出变量的变量名称，这里为了便于程序处理去除了原本变量名中存在的空格及括号
% cell.solutiontime对应模拟的时长
% 也可以直接通过cell.变量名来直接调用对应变量的数据，如cell.xKm对应输出文件中所有角点的x坐标（文件中变量表示为x (Km)，这里做了处理）
% cell.topr记录网格与角点间的拓扑关系
fid=fopen(file_path,'r','n','utf-8');
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

for i = 1:cell.nc
    topr = cell.topr(i,:);
    cell.x(i) = (cell.xKm(topr(1)) + cell.xKm(topr(2)) + cell.xKm(topr(3)) )/3.0;
    cell.y(i) = (cell.yKm(topr(1)) + cell.yKm(topr(2)) + cell.yKm(topr(3)) )/3.0;
end
end

function generate_cell_type_file(variables_name, nodal_data, cell_data, solutiontime, topr, output_filename)
    %{
    本函数用于生成经典的角点格式的Tecplot输出文件
    本函数运行所需参数为：
    variables_name：长度至少为3的数组，记录输出变量的名称
    variables_data：长度为nn*length(variables_name),nn为角点总数，该数组记录各变量的取值信息
    solutiontime：程序模拟时长，可随意给定
    topr：数组长度为nc*3，nc为计算单元总数，该数组记录计算单元与角点间的拓扑关系
    output_filename：输出文件的名字，可包含路径
    %}
    fid=fopen(output_filename,'w','n','utf-8');
    first_line = 'Variables= \t ';
    for i = 1:length(variables_name)
        first_line = [first_line, '\"', char(variables_name(i)), '\" \t'];
    end
    first_line = [first_line, '\r\n'];
    fprintf(fid, first_line);
    
    second_line = ['Zone N= ' num2str(length(nodal_data)) '  E= ' num2str(length(topr)) ...
        '  ZONETYPE=FETRIANGLE           DATAPACKING=BLOCK          SOLUTIONTIME=  ' num2str(solutiontime) '  \r\n'];
    fprintf(fid, second_line);
    
    third_line = ['VARLOCATION=([1-2]=NODAL, [3]=CELLCENTERED)' '  \r\n'];
    fprintf(fid, third_line);
    
    for i = 1:min(size(nodal_data))
        for j = 1:length(nodal_data)
            fprintf(fid, '%f    \r\n', nodal_data(j,i)); 
        end
    end
    for i = 1:min(size(cell_data))
        for j = 1:length(cell_data)
            fprintf(fid, '%f    \r\n', cell_data(j,i)); 
        end
    end
    for i = 1:length(topr)
       fprintf(fid, [repmat('%d \t\t ',1,3) '\r\n'], topr(i,:)); 
    end
    fclose(fid);
    end