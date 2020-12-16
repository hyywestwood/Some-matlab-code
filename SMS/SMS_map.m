%% SMS
%{ 
�����ļ��е�map�ļ���¼�˻�����ʱ�����Ŀ��Ʊߣ��Լ����Ƶ����Ϣ
�����������У�Node��¼�˿��Ƶ������
Arc1,Arc2...�ȼ�¼��i�����Ʊ���Feature���λ����Ϣ
Arcs����Arc����Ϣ������ͬһ��������
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
        ARCVERTICES = str2double(S{2}); %���Ʊ߶�Ӧ�ĸ��ֽڵ�(Feature Vertex)����
        Arc_num = Arc_num + 1;
        eval(['Arc' num2str(Arc_num) '= cell2mat(textscan(fid,''%f %f %f'',ARCVERTICES));']);
        eval(['Arcs = [Arcs; Arc' num2str(Arc_num) '];']);
%         Arcs = [Arcs; cell2mat(textscan(fid,'%f %f %f',ARCVERTICES))];
    end
end