%% ����Tecplot��ʽ���ļ�
clc;clear;
file_path = '.';
data_node = data_from_nodal_type(file_path, 5); % 5Ϊ����ļ��ı��

%% ����nodal��ʽ���ļ�
% ����׼�����ݣ���Ҫ����Ϣ������x,y,��������...�����������˹�ϵ
% ������Ũ��c1Ϊ��
variables_name = ["x", "y", "c1"];
variables_data = [data_node.xKm, data_node.yKm, data_node.c1];
output_filename = 'test_nodal.dat';
generate_nodal_type_file(variables_name, variables_data,data_node.solutiontime, data_node.topr, output_filename);
%{
�����������ó���Ϊ����Ҫ�Գ���ԭ���������з����������������µı���������Tecplot���±������л�ͼ
�磬����ˮɳģ�ͼ������λ��Ϣ����MATLAB�жԽ�����д����õ���λ�ĳ���ٽǵ���Ϣ
�ٽ�����Ϣд��tecplot�ļ�������tecplot��ͼ
%}

%% ����cell��ʽ���ļ�
clc;clear;
cell = data_from_cell_type('Result00001.DAT');
cell_data = cell.c1;
nodal_data = [cell.xKm, cell.yKm];
cell_data = cell.c1*10;
variables_name = ["x", "y", "Chla"];
output_filename = ['cell_type_tec_file.dat'];
generate_cell_type_file(variables_name, nodal_data, cell_data, cell.solutiontime, cell.topr, output_filename);



%% ����
function generate_nodal_type_file(variables_name, variables_data, solutiontime, topr, output_filename)
%{
�������������ɾ���Ľǵ��ʽ��Tecplot����ļ�
�����������������Ϊ��
variables_name����������Ϊ3�����飬��¼�������������
variables_data������Ϊnn*length(variables_name),nnΪ�ǵ��������������¼��������ȡֵ��Ϣ
solutiontime������ģ��ʱ�������������
topr�����鳤��Ϊnc*3��ncΪ���㵥Ԫ�������������¼���㵥Ԫ��ǵ������˹�ϵ
output_filename������ļ������֣��ɰ���·��
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
% �����Խṹ����ʽ����ȡ������Ԫ��ʽ�����Tecplot�ļ�
% ��������Ϊcell�Ľṹ�����飬����cell.nn��cell.nc�ֱ��¼�˸��ļ��нǵ㼰������Ŀ
% cell.variables_name���Ӧ����������ı������ƣ�����Ϊ�˱��ڳ�����ȥ����ԭ���������д��ڵĿո�����
% cell.solutiontime��Ӧģ���ʱ��
% Ҳ����ֱ��ͨ��cell.��������ֱ�ӵ��ö�Ӧ���������ݣ���cell.xKm��Ӧ����ļ������нǵ��x���꣨�ļ��б�����ʾΪx (Km)���������˴���
% cell.topr��¼������ǵ������˹�ϵ
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
    �������������ɾ���Ľǵ��ʽ��Tecplot����ļ�
    �����������������Ϊ��
    variables_name����������Ϊ3�����飬��¼�������������
    variables_data������Ϊnn*length(variables_name),nnΪ�ǵ��������������¼��������ȡֵ��Ϣ
    solutiontime������ģ��ʱ�������������
    topr�����鳤��Ϊnc*3��ncΪ���㵥Ԫ�������������¼���㵥Ԫ��ǵ������˹�ϵ
    output_filename������ļ������֣��ɰ���·��
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