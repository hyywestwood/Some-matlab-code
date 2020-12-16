%% begin
clc;clear;
[X,Y] = meshgrid(linspace(0, 9000, 500),linspace(0, 9000, 500));

% ��������� sigma=264
exact.theta1 = get_exact(9600, 264, 10);

%% ģ��ֵ��ȡ
file_path = 'H:\����\����1\Pollutant transport in a squared cavity\����\̽���������С�仯';
mesh_size = ["dx20 - RK","dx50 - RK","dx70 - RK","dx100 - RK"];
rec_scheme = ["��ά����-�������-���Ծ�����-һ������", "��ά���� - MUSCL-dx100", "MUACL-Song2011", "��ά����- ������� -���Ծ�����-ƽ��ֲ�", ...
    "WENO-Ye Fei2019-2ord-wolf", "WENO-Ye Fei2019-3ord-wolf", "�����ع�����-first+YE3-5e-7"];

for m = 1:length(rec_scheme)
    for n = 1:length(mesh_size)
        path = fullfile(file_path, char(mesh_size(n)), char(rec_scheme(m)));
        cell = data_from_nodal_type(path, 5);   
        % ����ṹ����
        eval(['modeled.theta' num2str(n) '.rec' num2str(m) '= griddata(cell.xKm*1000, cell.yKm*1000, cell.c1, X,Y)/10.0;' ]);
    end
end


%% ��ͼ
x = linspace(0, 9000, 500);
figure('position',[100,100,1200,800]);

subplot('position',[0.05,0.6,0.35,0.36])
plot(x, get_duijiao(exact.theta1), 'k-', 'linewidth', 2.5)
hold on
plot(x, get_duijiao(modeled.theta1.rec1), 'k--', 'linewidth', 2.5)
hold on
plot(x, get_duijiao(modeled.theta1.rec2), 'o-', 'linewidth', 1.5, 'MarkerIndices', 12:6:500, 'Color', [192, 57, 43]/256)
hold on
plot(x, get_duijiao(modeled.theta1.rec3), 's-', 'linewidth', 1.5, 'MarkerIndices', 14:6:500, 'Color', [192, 57, 43]/256)
hold on
plot(x, get_duijiao(modeled.theta1.rec4), 'bo-', 'linewidth', 1.5, 'MarkerIndices', 12:6:500)
hold on
plot(x, get_duijiao(modeled.theta1.rec5), 'bs-', 'linewidth', 1.5, 'MarkerIndices', 14:6:500)
hold on
plot(x, get_duijiao(modeled.theta1.rec6), 'r^-', 'linewidth', 1.5, 'MarkerIndices', 16:6:500)
% hold on
% plot(x, get_duijiao(modeled.theta1.rec7), 'ro-', 'linewidth', 1.5, 'MarkerIndices', 10:4:500)
xlim([5500, 7800])
ylim([-0.1, 1.2])
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('Location (m)', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Concentration', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(a) dx = 20 m', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

subplot('position',[0.45,0.6,0.35,0.36])
plot(x, get_duijiao(exact.theta1), 'k-', 'linewidth', 2.5)
hold on
plot(x, get_duijiao(modeled.theta2.rec1), 'k--', 'linewidth', 2.5)
hold on
plot(x, get_duijiao(modeled.theta2.rec2), 'o-', 'linewidth', 1.5, 'MarkerIndices', 12:6:500, 'Color', [192, 57, 43]/256)
hold on
plot(x, get_duijiao(modeled.theta2.rec3), 's-', 'linewidth', 1.5, 'MarkerIndices', 14:6:500, 'Color', [192, 57, 43]/256)
hold on
plot(x, get_duijiao(modeled.theta2.rec4), 'bo-', 'linewidth', 1.5, 'MarkerIndices', 12:6:500)
hold on
plot(x, get_duijiao(modeled.theta2.rec5), 'bs-', 'linewidth', 1.5, 'MarkerIndices', 14:6:500)
hold on
plot(x, get_duijiao(modeled.theta2.rec6), 'r^-', 'linewidth', 1.5, 'MarkerIndices', 16:6:500)
% hold on
% plot(x, get_duijiao(modeled.theta2.rec7), 'ro-', 'linewidth', 1.5, 'MarkerIndices', 10:5:500)
xlim([5500, 7800])
ylim([-0.1, 1.2])
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('Location (m)', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Concentration', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(b) dx = 50 m', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

subplot('position',[0.05,0.13,0.35,0.36])
plot(x, get_duijiao(exact.theta1), 'k-', 'linewidth', 2.5)
hold on
plot(x, get_duijiao(modeled.theta3.rec1), 'k--', 'linewidth', 2.5)
hold on
plot(x, get_duijiao(modeled.theta3.rec2), 'o-', 'linewidth', 1.5, 'MarkerIndices', 12:8:500, 'Color', [192, 57, 43]/256)
hold on
plot(x, get_duijiao(modeled.theta3.rec3), 's-', 'linewidth', 1.5, 'MarkerIndices', 14:8:500, 'Color', [192, 57, 43]/256)
hold on
plot(x, get_duijiao(modeled.theta3.rec4), 'bo-', 'linewidth', 1.5, 'MarkerIndices', 12:10:500)
hold on
plot(x, get_duijiao(modeled.theta3.rec5), 'bs-', 'linewidth', 1.5, 'MarkerIndices', 14:10:500)
hold on
plot(x, get_duijiao(modeled.theta3.rec6), 'r^-', 'linewidth', 1.5, 'MarkerIndices', 16:10:500)
% hold on
% plot(x, get_duijiao(modeled.theta3.rec7), 'ro-', 'linewidth', 1.5, 'MarkerIndices', 10:5:500)
xlim([5500, 7800])
ylim([-0.1, 1.2])
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('Location (m)', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Concentration', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(c) dx = 70 m', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

subplot('position',[0.45,0.13,0.35,0.36])
plot(x, get_duijiao(exact.theta1), 'k-', 'linewidth', 2.5)
hold on
plot(x, get_duijiao(modeled.theta4.rec1), 'k--', 'linewidth', 2.5)
hold on
plot(x, get_duijiao(modeled.theta4.rec2), 'o-', 'linewidth', 1.5, 'MarkerIndices', 12:8:500, 'Color', [192, 57, 43]/256)
hold on
plot(x, get_duijiao(modeled.theta4.rec3), 's-', 'linewidth', 1.5, 'MarkerIndices', 14:8:500, 'Color', [192, 57, 43]/256)
hold on
plot(x, get_duijiao(modeled.theta4.rec4), 'bo-', 'linewidth', 1.5, 'MarkerIndices', 10:12:500)
hold on
plot(x, get_duijiao(modeled.theta4.rec5), 'bs-', 'linewidth', 1.5, 'MarkerIndices', 14:12:500)
hold on
plot(x, get_duijiao(modeled.theta4.rec6), 'r^-', 'linewidth', 1.5, 'MarkerIndices', 18:12:500)
% hold on
% plot(x, get_duijiao(modeled.theta4.rec7), 'ro-', 'linewidth', 1.5, 'MarkerIndices', 10:5:500)
xlim([5500, 7800])
ylim([-0.1, 1.2])
set(gca,'FontSize',12,'FontWeight','bold', 'FontName', 'Times New Roman');
xlabel('Location (m)', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
ylabel('Concentration', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')
title('(d) dx = 100 m', 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold')

hh = legend('Exact', 'First order', 'MUSCL-Hou', 'MUSCL-Song', 'WENO-Wolf', 'WENO-Ye2', 'WENO-Ye3');
set(hh, 'FontSize', 16, 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'position', [0.82,0.44,0.15,0.2]);
print('E:\�㷨����\������\���ݴ���\PICS\Fig5','-djpeg','-r400')

%% һЩ����
function duijiao = get_duijiao(matrix)
    duijiao = zeros(length(matrix), 1);
    for i = 1:length(matrix)
        duijiao(i) = matrix(i,i);
    end
end

function c_exact = get_exact(t, theta, internal)
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