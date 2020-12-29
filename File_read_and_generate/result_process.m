%% ����������Ķ�ȡ
clc;clear;

% ����ͨ�ǵ���ʽ����Ľ���ļ�
file_path = '.';
data_node = data_from_nodal_type(file_path, 5); % 5Ϊ����ļ��ı��

% ������Ԫ��ʽ����Ľ���ļ�
file_path = '.';
data_cell = data_from_cell_type(file_path, 5);

%% һЩ����
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