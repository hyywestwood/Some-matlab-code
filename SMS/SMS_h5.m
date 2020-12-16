%% SMS
%{ 
在实际地形插值过程中，我们可能需要对地形数据进行再处理，如删除部分区域的数据点
利用SMS可以直接对数据点进行操作，修改完毕之后可以直接保存为h5格式的数据文件
通过处理h5文件，可以将修改后的地形数据再重新提取出来，方便使用
如temp.h5就为SMS生成网格后出现的h5文件
%}
clc;clear;
file_name = './mesh/cell - 插值数据09142.h5';
% h5disp(file_name)
info = h5info(file_name);
% 一般而言，地形数据位于一下两个地方，如不对，可通过h5disp命令查看文件数据结构，找出数据位置
data_loc = info.Groups(1).Groups.Groups;
elevation = h5read(file_name, [data_loc(1).Name '/elevation/Values']);
nodes = h5read(file_name, [data_loc(4).Name '/NodeLocs']);
data = [nodes', elevation]; % data数组的第1,2,4列分别对应了数据点的x,y,z

% 将得到的数据写入文件保存
fid=fopen('data_processed.dat','w','n','utf-8');
for i = 1:length(data)
    fprintf(fid, '%.4f \t %.4f \t %.4f \r\n',data(i,1),data(i,2),data(i,4));
end
fclose(fid);
