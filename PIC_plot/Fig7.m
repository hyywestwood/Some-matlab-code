%% begin����������⼰���ε���
clc;clear;
[X,Y] = meshgrid(linspace(0, 9000, 500),linspace(0, 9000, 500));
[exact.data, exact.dx, exact.dxx] = get_exact(9600, 264, 10);

%% 
[exact_n.data, exact_n.dx, exact_n.dxx] = get_exact(9600, 264*4, 10);

%% ģ��ֵ��ȡ
file_path = 'H:\����\����1\Pollutant transport in a squared cavity\����\̽��Ũ�ȷֲ��仯\dx50 - theta264 1';
rec_scheme = ["��ά����-�������-���Ծ�����-һ������", "��ά���� - MUSCL-dx100", "MUACL-Song2011", "��ά����- ������� -���Ծ�����-ƽ��ֲ�", ...
    "WENO-Ye Fei2019-2ord-wolf", "WENO-Ye Fei2019-3ord-wolf", "�����ع�����-first+YE3-5e-7"];

for m = 1:length(rec_scheme)
    path = fullfile(file_path, char(rec_scheme(m)));
    cell = data_from_nodal_type(path, 5);
    
    % ����ṹ����
    eval(['modeled.rec' num2str(m) '.data= griddata(cell.xKm*1000, cell.yKm*1000, cell.c1, X,Y)/10.0;' ]);
    eval(['modeled.rec' num2str(m) '.error = ' 'modeled.rec' num2str(m) '.data - exact.data;']);
end

%%
file_path = 'H:\����\����1\Pollutant transport in a squared cavity\����\̽��Ũ�ȷֲ��仯\dx50 - theta264 4';
for m = 1:length(rec_scheme)
    path = fullfile(file_path, char(rec_scheme(m)));
    cell = data_from_nodal_type(path, 5);
    
    % ����ṹ����
    eval(['modeled_n.rec' num2str(m) '.data= griddata(cell.xKm*1000, cell.yKm*1000, cell.c1, X,Y)/10.0;' ]);
    eval(['modeled_n.rec' num2str(m) '.error = ' 'modeled_n.rec' num2str(m) '.data - exact_n.data;']);
end


%% ��ͼ
figure('position',[100,100,1200,800]);

% 1
subplot('position',[0.06,0.6,0.35,0.36])
plot(get_duijiao(exact.dxx), get_duijiao(abs(modeled.rec1.error)), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dxx), get_duijiao(abs(modeled.rec2.error)), 'o', 'Color', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256, 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dxx), get_duijiao(abs(modeled.rec3.error)), 's', 'Color', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256, 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dxx), get_duijiao(abs(modeled.rec4.error)), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dxx), get_duijiao(abs(modeled.rec5.error)), 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dxx), get_duijiao(abs(modeled.rec6.error)), 'r^', 'MarkerFaceColor', 'r', 'MarkerSize', 8)
xlim([0, 4.5e-5])
ylim([-0.1, 0.8])
grid on
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('NI^0 (m^{-2})', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Error^{9600 s}', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(a) \sigma = 264', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

% 2
subplot('position',[0.47,0.6,0.35,0.36])
plot(get_duijiao(exact.dx), get_duijiao(abs(modeled.rec1.error)), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dx), get_duijiao(abs(modeled.rec2.error)), 'o', 'Color', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256, 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dx), get_duijiao(abs(modeled.rec3.error)), 's', 'Color', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256, 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dx), get_duijiao(abs(modeled.rec4.error)), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dx), get_duijiao(abs(modeled.rec5.error)), 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 8)
hold on
plot(get_duijiao(exact.dx), get_duijiao(abs(modeled.rec6.error)), 'r^', 'MarkerFaceColor', 'r', 'MarkerSize', 8)
xlim([0, 3.5e-3])
ylim([-0.1, 0.8])
grid on
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('gradient^0 (m^{-1})', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Error^{9600 s}', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(b) \sigma = 264', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

% 3
subplot('position',[0.06,0.11,0.35,0.36])
plot(get_duijiao(exact_n.dxx), get_duijiao(abs(modeled_n.rec1.error)), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8, 'MarkerIndices', 1:5:500)
hold on
plot(get_duijiao(exact_n.dxx), get_duijiao(abs(modeled_n.rec2.error)), 'o', 'Color', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256, 'MarkerSize', 8, 'MarkerIndices', 2:5:500)
hold on
plot(get_duijiao(exact_n.dxx), get_duijiao(abs(modeled_n.rec3.error)), 's', 'Color', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256, 'MarkerSize', 8, 'MarkerIndices', 3:5:500)
hold on
plot(get_duijiao(exact_n.dxx), get_duijiao(abs(modeled_n.rec4.error)), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'MarkerIndices', 4:6:500)
hold on
plot(get_duijiao(exact_n.dxx), get_duijiao(abs(modeled_n.rec5.error)), 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'MarkerIndices', 5:6:500)
hold on
plot(get_duijiao(exact_n.dxx), get_duijiao(abs(modeled_n.rec6.error)), 'r^', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'MarkerIndices', 6:5:500)
xlim([0, 3e-6])
ylim([-0.1, 0.8])
grid on
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('NI^0 (m^{-2})', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Error^{9600 s}', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(c) \sigma = 1056', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

% 4
subplot('position',[0.47,0.11,0.35,0.36])
plot(get_duijiao(exact_n.dx), get_duijiao(abs(modeled_n.rec1.error)), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8, 'MarkerIndices', 1:5:500)
hold on
plot(get_duijiao(exact_n.dx), get_duijiao(abs(modeled_n.rec2.error)), 'o', 'Color', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256, 'MarkerSize', 8, 'MarkerIndices', 2:5:500)
hold on
plot(get_duijiao(exact_n.dx), get_duijiao(abs(modeled_n.rec3.error)), 's', 'Color', [192, 57, 43]/256, 'MarkerFaceColor', [192, 57, 43]/256, 'MarkerSize', 8, 'MarkerIndices', 3:5:500)
hold on
plot(get_duijiao(exact_n.dx), get_duijiao(abs(modeled_n.rec4.error)), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'MarkerIndices', 4:6:500)
hold on
plot(get_duijiao(exact_n.dx), get_duijiao(abs(modeled_n.rec5.error)), 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'MarkerIndices', 5:6:500)
hold on
plot(get_duijiao(exact_n.dx), get_duijiao(abs(modeled_n.rec6.error)), 'r^', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'MarkerIndices', 6:5:500)
xlim([0, 9e-4])
ylim([-0.1, 0.8])
grid on
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('gradient^0 (m^{-1})', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Error^{9600 s}', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(d) \sigma = 1056', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

hh = legend('First order', 'MUSCL-Hou', 'MUSCL-Song', 'WENO-Wolf', 'WENO-Ye2', 'WENO-Ye3');
set(hh, 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'position', [0.83,0.44,0.15,0.2]);
print('E:\�㷨����\������\���ݴ���\PICS\Fig7 NI gradient','-djpeg','-r400')

%% һЩ����
function duijiao = get_duijiao(matrix)
    duijiao = zeros(length(matrix), 1);
    for i = 1:length(matrix)
        duijiao(i) = matrix(i,i);
    end
end

function [c_exact, c_1, c_2] = get_exact(t, theta, internal)
%{
t:ģ��ʱ����theta:�ֲ���ɢ�̶�;internal:���Ũ�ȣ����ڹ�һ��Ũ�ȳ�
%}
[X,Y] = meshgrid(linspace(0, 9000, 500),linspace(0, 9000, 500));
% ���������
syms x y
x1 = 1400; y1 = 1400;
x2 = 2400; y2 = 2400;
c1 = 10; c2 = 6.5;
u = 0.5; v = 0.5;
c = c1 * exp(-((x - u * t - x1) / theta)^2.0 - ((y - v * t - y1) / theta)^2.0) + c2 * exp(-((x - u * t - x2) / theta)^2.0 - ((y - v * t - y2) / theta)^2.0);
c = c/internal;
c_dx = diff(c, x, 1);
c_dy = diff(c, y, 1);
c_dxx = diff(c, x, 2);
c_dyy = diff(c, y, 2);
temp_x = double(subs(c_dx,{x,y},{X,Y}));temp_y = double(subs(c_dy,{x,y},{X,Y}));
c_1 = (temp_x.^2.0 + temp_y.^2.0).^0.5;
temp_x = double(subs(c_dxx,{x,y},{X,Y}));temp_y = double(subs(c_dyy,{x,y},{X,Y}));
c_2 = (temp_x.^2.0 + temp_y.^2.0).^0.5;
c_exact = double(subs(c,{x,y},{X,Y}));
end

function cell = data_from_cell_type(str,i)
% �����Խṹ����ʽ����ȡ������Ԫ��ʽ�����Tecplot�ļ�
% ��������Ϊcell�Ľṹ�����飬����cell.nn��cell.nc�ֱ��¼�˸��ļ��нǵ㼰������Ŀ
% cell.variables_name���Ӧ����������ı������ƣ�����Ϊ�˱��ڳ�����ȥ����ԭ���������д��ڵĿո�����
% cell.solutiontime��Ӧģ���ʱ��
% Ҳ����ֱ��ͨ��cell.��������ֱ�ӵ��ö�Ӧ���������ݣ���cell.xKm��Ӧ����ļ������нǵ��x���꣨�ļ��б�����ʾΪx (Km)���������˴���
% cell.topr��¼������ǵ������˹�ϵ
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
% �����Խṹ����ʽ���洢�������ݣ��ú�����Ӧ����Ľǵ��ʽ������ļ�
% ��������Ϊcell�Ľṹ�����飬����cell.nn��cell.nc�ֱ��¼�˸��ļ��нǵ㼰������Ŀ
% cell.variables_name���Ӧ����������ı������ƣ�����Ϊ�˱��ڳ�����ȥ����ԭ���������д��ڵĿո�����
% cell.solutiontime��Ӧģ���ʱ��
% cell.data�򷵻�[cell.nc�� ��������]�Ķ�ά����
% Ҳ����ֱ��ͨ��cell.��������ֱ�ӵ��ö�Ӧ���������ݣ���cell.xKm��Ӧ����ļ������нǵ��x���꣨�ļ��б�����ʾΪx (Km)���������˴���
% cell.topr��¼������ǵ������˹�ϵ
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