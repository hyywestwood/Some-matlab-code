%% 计算解析解
clc;clear;
file_path = 'E:\算例1\Pollutant transport in a squared cavity\算例\RK';
mesh_size = ["dx30","dx40","dx50","dx60","dx70","dx80","dx90","dx100"];
for i = 1:length(mesh_size)
    path = fullfile(file_path, char(mesh_size(i)));
    cell = read_cell(path);
    eval(['exact.' char(mesh_size(i)) '=get_exact(9600, 264, 10, cell.x, cell.y);']);  
end

%% 模拟值，计算eg，cpu_time
rec_scheme = ["First", "MUSCL-Hou", "MUSCL-Song", "WENO-Wolf", "WENO-Ye2", "WENO-Ye3", "Hybrid"];

for m = 1:length(rec_scheme)
    for n = 1:length(mesh_size)
        path = fullfile(file_path, char(mesh_size(n)), char(rec_scheme(m)));
        cell = data_from_cell_type(path, 5);
        cell.c1 = cell.c1/10;
        total_1 = 0; total_2 = 0;
        for i = 1:cell.nc
            eval(['total_1 = total_1 + ( cell.c1(i) -  exact.' char(mesh_size(n)) '(i) )^2.0;' ]);
            eval(['total_2 = total_2 + exact.' char(mesh_size(n)) '(i)^2.0;' ]);
        end
        eg = sqrt(total_1/total_2);  %eg
        
        file_info_1 = dir([path '\RESULTS' num2str(1,'%05d') '.DAT']);
        file_info_2 = dir([path '\RESULTS' num2str(5,'%05d') '.DAT']);
        t_1 = datetime(datevec(file_info_1.date));t_2 = datetime(datevec(file_info_2.date));
        cpuTime = seconds(t_2-t_1);  %cputime 秒
        
        % 存入结构数组
        eval(['data.rec' num2str(m) '.eg(n) = eg;' ]);
        eval(['data.rec' num2str(m) '.cputime(n) = cpuTime;' ]);
    end
end

%% 绘图
figure('position',[100,100,800,600]);

loglog(data.rec1.cputime, data.rec1.eg, '^', 'Markersize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k')
hold on
loglog(data.rec2.cputime, data.rec2.eg, 'o', 'Markersize', 8, 'MarkerEdgeColor', [192, 57, 43]/256, 'MarkerFaceColor',[192, 57, 43]/256)
hold on
loglog(data.rec3.cputime, data.rec3.eg, 's', 'Markersize', 8, 'MarkerEdgeColor', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256)
hold on
loglog(data.rec4.cputime, data.rec4.eg, '^', 'Markersize', 8, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b')
hold on
loglog(data.rec5.cputime, data.rec5.eg, 'o', 'Markersize', 8, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b')
hold on
loglog(data.rec6.cputime, data.rec6.eg, 's', 'Markersize', 8, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r')
hold on
loglog(data.rec7.cputime, data.rec7.eg, 'o', 'Markersize', 8, 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g')
hold on

% 1
x = data.rec1.cputime; y = data.rec1.eg;
ft_ = fittype('10^(b+a*log(x))' ,...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a', 'b'});
cf_ = fit(x',y',ft_);
coef = coeffvalues(cf_);
syms fit_x
fit_y = 10^(coef(2)+coef(1)*log(fit_x));
inter_x = linspace(min(x)*0.8, max(x)*2, 200);
final_y = double(subs(fit_y,fit_x,inter_x));
loglog(inter_x,final_y, 'Color', 'k', 'linewidth', 2)
hold on
% 2
x = data.rec2.cputime; y = data.rec2.eg;
ft_ = fittype('10^(b+a*log(x))' ,...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a', 'b'});
cf_ = fit(x',y',ft_);
coef = coeffvalues(cf_);
syms fit_x
fit_y = 10^(coef(2)+coef(1)*log(fit_x));
inter_x = linspace(min(x)*0.8, max(x)*2, 200);
final_y = double(subs(fit_y,fit_x,inter_x));
loglog(inter_x,final_y, 'Color', [192, 57, 43]/256, 'linewidth', 2)
hold on
% 3
x = data.rec3.cputime; y = data.rec3.eg;
ft_ = fittype('10^(b+a*log(x))' ,...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a', 'b'});
cf_ = fit(x',y',ft_);
coef = coeffvalues(cf_);
syms fit_x
fit_y = 10^(coef(2)+coef(1)*log(fit_x));
inter_x = linspace(min(x)*0.8, max(x)*2, 200);
final_y = double(subs(fit_y,fit_x,inter_x));
loglog(inter_x,final_y, 'Color', [192, 57, 43]/256, 'linewidth', 2)
hold on

% 4
x = data.rec4.cputime; y = data.rec4.eg;
ft_ = fittype('10^(b+a*log(x))' ,...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a', 'b'});
cf_ = fit(x',y',ft_);
coef = coeffvalues(cf_);
syms fit_x
fit_y = 10^(coef(2)+coef(1)*log(fit_x));
inter_x = linspace(min(x)*0.8, max(x)*2, 200);
final_y = double(subs(fit_y,fit_x,inter_x));
loglog(inter_x,final_y, 'Color', 'b', 'linewidth', 2)
hold on

% 5
x = data.rec5.cputime; y = data.rec5.eg;
ft_ = fittype('10^(b+a*log(x))' ,...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a', 'b'});
cf_ = fit(x',y',ft_);
coef = coeffvalues(cf_);
syms fit_x
fit_y = 10^(coef(2)+coef(1)*log(fit_x));
inter_x = linspace(min(x)*0.8, max(x)*2, 200);
final_y = double(subs(fit_y,fit_x,inter_x));
loglog(inter_x,final_y, 'Color', 'b', 'linewidth', 2)
hold on

% 6
x = data.rec6.cputime; y = data.rec6.eg;
ft_ = fittype('10^(b+a*log(x))' ,...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a', 'b'});
cf_ = fit(x',y',ft_);
coef = coeffvalues(cf_);
syms fit_x
fit_y = 10^(coef(2)+coef(1)*log(fit_x));
inter_x = linspace(min(x)*0.8, max(x)*1.5, 200);
final_y = double(subs(fit_y,fit_x,inter_x));
loglog(inter_x,final_y, 'Color', 'r', 'linewidth', 2)
hold on

% 7
x = data.rec7.cputime; y = data.rec7.eg;
ft_ = fittype('10^(b+a*log(x))' ,...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a', 'b'});
cf_ = fit(x',y',ft_);
coef = coeffvalues(cf_);
syms fit_x
fit_y = 10^(coef(2)+coef(1)*log(fit_x));
inter_x = linspace(min(x)*0.8, max(x)*1.5, 200);
final_y = double(subs(fit_y,fit_x,inter_x));
loglog(inter_x,final_y, 'Color', 'g', 'linewidth', 2)
hold on

grid on
set(gca,'FontSize',14,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('CPU time (s)', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Eg', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
hh = legend('First order', 'MUSCL-Hou', 'MUSCL-Song', 'WENO-Wolf', 'WENO-Ye2', 'WENO-Ye3', 'Hybrid');
set(hh, 'FontSize', 15, 'FontName', 'Times New Roman', 'FontWeight', 'bold');

print('E:\算法文章\审稿意见\数据处理\PICS\Eg VS CPU_1','-djpeg','-r400')


%% 一些函数
function plot_fit(x, y, color)
ft_ = fittype('10^(b+a*log(x))' ,...
'dependent',{'y'},'independent',{'x'},...
'coefficients',{'a', 'b'});
cf_ = fit(x,y,ft_);
coef = coeffvalues(cf_);
coef = coeffvalues(cf_);
syms fit_x
fit_y = 10^(coef(2)+coef(1)*log(fit_x));
inter_x = linspace(min(x)*0.5, max(x)*1.5, 200);
final_y = double(subs(fit_y,fit_x,inter_x));
loglog(x, y, 'o','Color',color)
hold on
loglog(inter_x,final_y,'Color',color)
hold on
end

function c_exact = get_exact(t, theta, internal, X, Y)
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
c_exact = double(subs(c,{x,y},{X,Y}));
end

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