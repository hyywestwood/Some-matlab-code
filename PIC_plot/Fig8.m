%% Fig.8 Hybrid VS Others schemes
% 解析解
clc;clear;
[X,Y] = meshgrid(linspace(0, 9000, 500),linspace(0, 9000, 500));
exact.theta1 = get_exact(9600, 264, 10);
exact.theta4 = get_exact(9600, 264*4, 10);

%% 模拟值读取
file_path = 'H:\数据\算例1\Pollutant transport in a squared cavity\算例\探究浓度分布变化';
theta_style = ["dx50 - theta264 1", "dx50 - theta264 4"];
rec_scheme = ["二维网格-变量耦合-绝对均匀流-一阶中心", "二维网格 - MUSCL-dx100", "MUACL-Song2011", "二维网格- 变量耦合 -绝对均匀流-平面分布", ...
    "WENO-Ye Fei2019-2ord-wolf", "WENO-Ye Fei2019-3ord-wolf", "多重重构技术-first+YE3-5e-7"];

for m = 1:length(rec_scheme)
    for n = 1:length(theta_style)
        path = fullfile(file_path, char(theta_style(n)), char(rec_scheme(m)));
        cell = data_from_nodal_type(path, 5);
        
        % 存入结构数组
        eval(['modeled.theta' num2str(n) '.rec' num2str(m) '= griddata(cell.xKm*1000, cell.yKm*1000, cell.c1, X,Y)/10.0;' ]);
    end
end

%% 绘图
figure('position',[100,100,800,700]);

subplot('position',[0.065,0.58,0.7,0.38])
plot(linspace(0, 9000, 500), get_duijiao(modeled.theta1.rec1), 'k--', 'linewidth', 2)
hold on
plot(linspace(0, 9000, 500), get_duijiao(modeled.theta1.rec4), 'bo-', 'linewidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 6, 'MarkerIndices', 1:3:500)
hold on
plot(linspace(0, 9000, 500), get_duijiao(modeled.theta1.rec6), 'bs-', 'linewidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 6, 'MarkerIndices', 2:3:500)
hold on
plot(linspace(0, 9000, 500), get_duijiao(modeled.theta1.rec7), 'ro-', 'linewidth', 1.5, 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'MarkerIndices', 3:3:500)
hold on
plot(linspace(0, 9000, 500), get_duijiao(exact.theta1), 'k-', 'linewidth', 3)
xlim([5500, 7800])
ylim([-0.1, 1.2])
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('Location (m)', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Concentration', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(a) \sigma = 264', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

subplot('position',[0.065,0.08,0.7,0.38])
plot(linspace(0, 9000, 500), get_duijiao(modeled.theta2.rec1), 'k--', 'linewidth', 2)
hold on
plot(linspace(0, 9000, 500), get_duijiao(modeled.theta2.rec4), 'bo-', 'linewidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 6, 'MarkerIndices', 1:5:500)
hold on
plot(linspace(0, 9000, 500), get_duijiao(modeled.theta2.rec6), 'bs-', 'linewidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 6, 'MarkerIndices', 3:5:500)
hold on
plot(linspace(0, 9000, 500), get_duijiao(modeled.theta2.rec7), 'ro-', 'linewidth', 1.5, 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'MarkerIndices', 5:5:500)
hold on
plot(linspace(0, 9000, 500), get_duijiao(exact.theta4), 'k-', 'linewidth', 3)
xlim([5000, 8500])
ylim([-0.1, 1.2])
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('Location (m)', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Concentration', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(b) \sigma = 1056', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

hh = legend('First order', 'WENO-Wolf', 'WENO-Ye3', 'Hybrid', 'Exact');
set(hh, 'FontSize', 14, 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'position', [0.86,0.48,0.05,0.15]);
print('E:\算法文章\审稿意见\数据处理\PICS\Fig8 Hybrid VS others','-djpeg','-r400')


%% 一些函数
function duijiao = get_duijiao(matrix)
    duijiao = zeros(length(matrix), 1);
    for i = 1:length(matrix)
        duijiao(i) = matrix(i,i);
    end
end

function c_exact = get_exact(t, theta, internal)
%{
t:模拟时长；theta:分布分散程度;internal:最大浓度，用于归一化浓度场
%}
[X,Y] = meshgrid(linspace(0, 9000, 500),linspace(0, 9000, 500));
% 计算解析解
syms x y
x1 = 1400; y1 = 1400;
x2 = 2400; y2 = 2400;
c1 = 10; c2 = 6.5;
u = 0.5; v = 0.5;
c = c1 * exp(-((x - u * t - x1) / theta)^2.0 - ((y - v * t - y1) / theta)^2.0) + c2 * exp(-((x - u * t - x2) / theta)^2.0 - ((y - v * t - y2) / theta)^2.0);
c = c/internal;
c_exact = double(subs(c,{x,y},{X,Y}));
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
fclose(fid);
end