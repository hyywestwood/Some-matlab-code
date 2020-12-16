%% SMS
%{ 
��ʵ�ʵ��β�ֵ�����У����ǿ�����Ҫ�Ե������ݽ����ٴ�����ɾ��������������ݵ�
����SMS����ֱ�Ӷ����ݵ���в������޸����֮�����ֱ�ӱ���Ϊh5��ʽ�������ļ�
ͨ������h5�ļ������Խ��޸ĺ�ĵ���������������ȡ����������ʹ��
��temp.h5��ΪSMS�����������ֵ�h5�ļ�
%}
clc;clear;
file_name = './mesh/cell - ��ֵ����09142.h5';
% h5disp(file_name)
info = h5info(file_name);
% һ����ԣ���������λ��һ�������ط����粻�ԣ���ͨ��h5disp����鿴�ļ����ݽṹ���ҳ�����λ��
data_loc = info.Groups(1).Groups.Groups;
elevation = h5read(file_name, [data_loc(1).Name '/elevation/Values']);
nodes = h5read(file_name, [data_loc(4).Name '/NodeLocs']);
data = [nodes', elevation]; % data����ĵ�1,2,4�зֱ��Ӧ�����ݵ��x,y,z

% ���õ�������д���ļ�����
fid=fopen('data_processed.dat','w','n','utf-8');
for i = 1:length(data)
    fprintf(fid, '%.4f \t %.4f \t %.4f \r\n',data(i,1),data(i,2),data(i,4));
end
fclose(fid);
