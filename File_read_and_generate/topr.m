%% 与网格拓扑有关的MATLAB代码
clc;clear;
file_path = '.';
% 读取cell.geo文件
% bc = read_bc(file_path);

% 读取cell.bc文件
% cell = read_cell(file_path);

% 在某些情况下，我们或许会需要计算区域外围边界一圈的角点坐标
% 方法1：在SMS中将网格一圈打好边界导出为cell.bc,结合cell.geo便可完成需求，如下
% boundry = get_boundry1(file_path);

% 方法2：仅用cell.geo文件，利用相关拓扑关系求出边界
% 待续。。。

% 程序中Topr的MATLAB实现
[Cell, Face, Node] = run_topr(file_path);


%% 一些函数
function boundry = get_boundry1(file_path)
cell = read_cell(file_path);
bc = read_bc(file_path);
for i = 1:length(bc.bc1)
    boundry.x(i) = cell.node(bc.bc1(i), 1);
    boundry.y(i) = cell.node(bc.bc1(i), 2);
end
end

function cell = read_cell(file_path)
%{ 
本函数用于读取cell.geo文件，输入值为网格文件所在文件夹路径
返回值为cell结构数组，cell.topr记录网格编号与角点的拓扑信息
cell.node记录角点对应的x,y,z值;
cell,nc和cell.nn分别为网格总数和角点总数
cell.x，cell.y, cell.z分别是网格单元中心的xyz
%}
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
cell.nc = NC;
cell.nn = NN;
cell.topr = topr;
cell.node = Node;
for i = 1:length(topr)
    cell.x(i,1) = (Node(topr(i, 1), 1) + Node(topr(i, 2), 1) + Node(topr(i, 3), 1))/3.0;
    cell.y(i,1) = (Node(topr(i, 1), 2) + Node(topr(i, 2), 2) + Node(topr(i, 3), 2))/3.0;
    cell.z(i,1) = (Node(topr(i, 1), 3) + Node(topr(i, 2), 3) + Node(topr(i, 3), 3))/3.0;
end
fclose(fid);
end

function BC = read_bc(file_path)
%{ 
本函数用于读取cell.bc文件，输入值为边界文件所在文件夹路径，可自己修改用于读取cspoint.bc文件
返回值为BC结构体，BC.bc1记录第一条边界的角点编号，BC.bc2记录第二条边界...以此类推
BC.bc_num为边界条数
若文件中没有边界信息，将会返回空矩阵[],可用isempty(BC)来判断
%}
fid=fopen([file_path '\cell.bc'],'r','n','utf-8');
% fid=fopen([file_path '\cspoint.bc'],'r','n','utf-8');
bc_num = 0;
while ~feof(fid)
    tline=fgetl(fid);
    if contains(tline, 'GCL')
        if contains(tline(8:13), '      ')
            S = regexp(tline, '\s+', 'split');
            for i = 2:length(S)
                eval(['BC.bc' num2str(bc_num) '= [BC.bc' num2str(bc_num) ', str2double(S{i})];']);
            end
        else
            bc_num = bc_num + 1;
            S = regexp(tline, '\s+', 'split');
            eval(['BC.bc' num2str(bc_num) '= [];']);
            for i = 3:length(S)
                eval(['BC.bc' num2str(bc_num) '= [BC.bc' num2str(bc_num) ', str2double(S{i})];']);
            end
        end 
    end
end
if bc_num >0
    for i = 1:bc_num
        eval(['BC.bc' num2str(i) '= BC.bc' num2str(i) '(1:end-1);']);
    end
    BC.bc_num = bc_num;
else
    BC = [];
    fprintf('文件中没有边界信息。。。 \n')
end
fclose(fid);
end

function [Cell, Face, Node] = run_topr(file_path)
%{
本程序参考Fortran版本的topr文件，将返回Cell,Face,Node三个结构体
Cell结构体中包含idn,nc,idf,rfn,x,y,zb0,area
Face结构体中包含idc,idn,xm,ym,length,rfn,nf,bcstl,nff
Node结构体中包含x,y,zbo,nn,idcn,idc,idlh
%}
fid=fopen([file_path '\cell.geo'],'r','n','utf-8');
while ~feof(fid)
    tline=fgetl(fid);
    if contains(tline, 'GE')
        S = regexp(tline, '\s+', 'split');
        NC = str2num(S{2});
        Cell.idn(NC, 1) = str2num(S{3});
        Cell.idn(NC, 2) = str2num(S{5});
        Cell.idn(NC, 3) = str2num(S{7});
    elseif contains(tline, 'GNN')
        S = regexp(tline, '\s+', 'split');
        NN = str2num(S{2});
        Node.x(NN) = str2num(S{3});
        Node.y(NN) = str2num(S{4});
        Node.zb0(NN) = str2num(S{5});       
    end
end
Cell.nc = NC;
Node.nn = NN;

% 初始定义，边的拓扑
Face.idc(1,1)=1;
Face.idc(2,1)=1;
Face.idc(3,1)=1;

Face.idn(1,1) = Cell.idn(1,1);
Face.idn(1,2) = Cell.idn(1,2); 
Face.idn(2,1) = Cell.idn(1,2);
Face.idn(2,2) = Cell.idn(1,3); 
Face.idn(3,1) = Cell.idn(1,3);
Face.idn(3,2) = Cell.idn(1,1); 

Face.xm(1) = ( Node.x(Face.idn(1,1)) + Node.x(Face.idn(1,2)) )/2.0;
Face.ym(1) = ( Node.y(Face.idn(1,1)) + Node.y(Face.idn(1,2)) )/2.0;
Face.xm(2) = ( Node.x(Face.idn(2,1)) + Node.x(Face.idn(2,2)) )/2.0;
Face.ym(2) = ( Node.y(Face.idn(2,1)) + Node.y(Face.idn(2,2)) )/2.0;
Face.xm(3) = ( Node.x(Face.idn(3,1)) + Node.x(Face.idn(3,2)) )/2.0;
Face.ym(3) = ( Node.y(Face.idn(3,1)) + Node.y(Face.idn(3,2)) )/2.0;

Face.length(1) = sqrt( ( Node.x(Face.idn(1,2)) - Node.x(Face.idn(1,1)) )^2.0 + (Node.y(Face.idn(1,2)) - Node.y(Face.idn(1,1)))^2.0 );
Face.length(2) = sqrt( ( Node.x(Face.idn(2,2)) - Node.x(Face.idn(2,1)) )^2.0 + (Node.y(Face.idn(2,2)) - Node.y(Face.idn(2,1)))^2.0 );
Face.length(3) = sqrt( ( Node.x(Face.idn(3,2)) - Node.x(Face.idn(3,1)) )^2.0 + (Node.y(Face.idn(3,2)) - Node.y(Face.idn(3,1)))^2.0 );

Face.rfn(1,1) = ( Node.y(Face.idn(1, 2)) - Node.y(Face.idn(1, 1)) )/Face.length(1);
Face.rfn(1,2) = -( Node.x(Face.idn(1, 2)) - Node.x(Face.idn(1, 1)) )/Face.length(1);
Face.rfn(2,1) = ( Node.y(Face.idn(2, 2)) - Node.y(Face.idn(2, 1)) )/Face.length(2);
Face.rfn(2,2) = -( Node.x(Face.idn(2, 2)) - Node.x(Face.idn(2, 1)) )/Face.length(2);
Face.rfn(3,1) = ( Node.y(Face.idn(3, 2)) - Node.y(Face.idn(3, 1)) )/Face.length(3);
Face.rfn(3,2) = -( Node.x(Face.idn(3, 2)) - Node.x(Face.idn(3, 1)) )/Face.length(3);

bar = waitbar(0,'1', 'Name','边的拓扑...');
II = 3;
for i = 2:Cell.nc
    str = ['寻找idc1,idn...',num2str(100*i/Cell.nc, '%.1f'),'%'];
    waitbar(i/Cell.nc,bar,str)
    for k = 1:3
        IP = 1;
        if k <= 2
            for j = 1:i-1
                if Cell.idn(i, k) == Cell.idn(j,2) && Cell.idn(i, k+1) == Cell.idn(j,1)
                    IP = 0;
                    break
                end
                if Cell.idn(i, k) == Cell.idn(j,3) && Cell.idn(i, k+1) == Cell.idn(j,2)
                    IP = 0;
                    break
                end
                if Cell.idn(i, k) == Cell.idn(j,1) && Cell.idn(i, k+1) == Cell.idn(j,3)
                    IP = 0;
                    break
                end
            end
        else
            for j = 1:i-1
                if Cell.idn(i, k) == Cell.idn(j,2) && Cell.idn(i, 1) == Cell.idn(j,1)
                    IP = 0;
                    break
                end
                if Cell.idn(i, k) == Cell.idn(j,3) && Cell.idn(i, 1) == Cell.idn(j,2)
                    IP = 0;
                    break
                end
                if Cell.idn(i, k) == Cell.idn(j,1) && Cell.idn(i, 1) == Cell.idn(j,3)
                    IP = 0;
                    break
                end
            end
        end
        if IP == 1
            II = II + 1;
            Face.idc(II, 1) = i;
            if k<=2
                Face.idn(II, 1) = Cell.idn(i,k);
                Face.idn(II, 2) = Cell.idn(i,k+1);
            else
                Face.idn(II, 1) = Cell.idn(i,k);
                Face.idn(II, 2) = Cell.idn(i,1);
            end
            Face.xm(II) = ( Node.x(Face.idn(II,1)) + Node.x(Face.idn(II,2)) )/2.0;
            Face.ym(II) = ( Node.y(Face.idn(II,1)) + Node.y(Face.idn(II,2)) )/2.0;
            Face.length(II) = sqrt( ( Node.x(Face.idn(II,2)) - Node.x(Face.idn(II,1)) )^2.0 + (Node.y(Face.idn(II,2)) - Node.y(Face.idn(II,1)))^2.0 );
            Face.rfn(II,1) = ( Node.y(Face.idn(II, 2)) - Node.y(Face.idn(II, 1)) )/Face.length(II);
            Face.rfn(II,2) = -( Node.x(Face.idn(II, 2)) - Node.x(Face.idn(II, 1)) )/Face.length(II);
        end
    end
end
Face.nf = II;
close(bar);

for i = 1:Face.nf
    Face.idc(i, 2)=0;
    Face.bcstl(i)=0;
end

bar = waitbar(0,'1', 'Name','边的拓扑...');
for i = 1:Face.nf
    str = ['寻找idc2...',num2str(100*i/Face.nf, '%.1f'),'%'];
    waitbar(i/Face.nf,bar,str)
    for j = 1:Cell.nc
        if Face.idn(i,1) == Cell.idn(j,2) && Face.idn(i,2) == Cell.idn(j,1)
            Face.idc(i, 2) = j;
            break
        end
        if Face.idn(i,1) == Cell.idn(j,3) && Face.idn(i,2) == Cell.idn(j,2)
            Face.idc(i, 2) = j;
            break
        end
        if Face.idn(i,1) == Cell.idn(j,1) && Face.idn(i,2) == Cell.idn(j,3)
            Face.idc(i, 2) = j;
            break
        end
    end
    if Face.idc(i,2) == 0
        Face.bcstl(i)=1;
    end
end
close(bar);

bar = waitbar(0,'1', 'Name','网格的拓扑...');
for i = 1:Cell.nc
    str = ['确定Cell.idf...',num2str(100*i/Cell.nc, '%.1f'),'%'];
    waitbar(i/Cell.nc,bar,str)
    for j = 1:Face.nf
        % 单元对应第一条边
        if Cell.idn(i,1) == Face.idn(j,1) && Cell.idn(i,2) == Face.idn(j,2)
            Cell.idf(i,1)=j;
            Cell.rfn(i,1,:)=Face.rfn(j,:);
            continue
        end
        if Cell.idn(i,1) == Face.idn(j,2) && Cell.idn(i,2) == Face.idn(j,1)
            Cell.idf(i,1)=j;
            Cell.rfn(i,1,:)=-Face.rfn(j,:);
            continue
        end
        
        % 单元对应第二条边
        if Cell.idn(i,2) == Face.idn(j,1) && Cell.idn(i,3) == Face.idn(j,2)
            Cell.idf(i,2)=j;
            Cell.rfn(i, 2,:)=Face.rfn(j,:);
            continue
        end
        if Cell.idn(i,2) == Face.idn(j,2) && Cell.idn(i,3) == Face.idn(j,1)
            Cell.idf(i,2)=j;
            Cell.rfn(i,2 ,:)=-Face.rfn(j,:);
            continue
        end
        
        % 单元对应第san条边
        if Cell.idn(i,3) == Face.idn(j,1) && Cell.idn(i,1) == Face.idn(j,2)
            Cell.idf(i,3)=j;
            Cell.rfn(i, 3,:)=Face.rfn(j,:);
            continue
        end
        if Cell.idn(i,3) == Face.idn(j,2) && Cell.idn(i,1) == Face.idn(j,1)
            Cell.idf(i,3)=j;
            Cell.rfn(i,3 ,:)=-Face.rfn(j,:);
            continue
        end
    end    
end
close(bar);

bar = waitbar(0,'1', 'Name','网格的拓扑...');
for i = 1:Cell.nc
    str = ['确定网格单元的x,y,zb0,area...',num2str(100*i/Cell.nc, '%.1f'),'%'];
    waitbar(i/Cell.nc,bar,str)
    Cell.x(i) = ( Node.x(Cell.idn(i,1)) + Node.x(Cell.idn(i,2)) + Node.x(Cell.idn(i,3)))/3.0d0;
    Cell.y(i) = ( Node.y(Cell.idn(i,1)) + Node.y(Cell.idn(i,2)) + Node.y(Cell.idn(i,3)))/3.0d0;
    Cell.zb0(i) = ( Node.zb0(Cell.idn(i,1)) + Node.zb0(Cell.idn(i,2)) + Node.zb0(Cell.idn(i,3)))/3.0d0;
    Cell.area(i) = 1.0/2.0*( Face.length(Cell.idf(i,1)) + Face.length(Cell.idf(i,2)) + Face.length(Cell.idf(i,3)) );
    Cell.area(i) = Cell.area(i)*( Cell.area(i) - Face.length(Cell.idf(i,1)) )*( Cell.area(i) - Face.length(Cell.idf(i,2)) )*( Cell.area(i) - Face.length(Cell.idf(i,3)) );
    Cell.area(i) = sqrt(Cell.area(i));
end
close(bar);

% 建立节点的拓扑关系
bar = waitbar(0,'1', 'Name','角点的拓扑...');
for i = 1:Node.nn
    str = ['确定Node周围网格编号...',num2str(100*i/Node.nn, '%.1f'),'%'];
    waitbar(i/Node.nn,bar,str)
    Node.idcn(i) = 0;
    for j = 1:Cell.nc
       for k = 1:3
          if Cell.idn(j,k) == i
              Node.idcn(i) = Node.idcn(i) + 1;
              Node.idc(i, Node.idcn(i)) = j;
              break
          end
       end
    end
end
close(bar);

% 节点反向距离加权的权重
for i = 1:Node.nn
    Node.sidlh(i) = 0;
    for j = 1:Node.idcn(i)
        Node.idlh(i,j) = 1.0/sqrt( (Node.x(i) - Cell.x(Node.idc(i,j)) )^2.0 + (Node.y(i) - Cell.y(Node.idc(i,j)) )^2.0  );
    end
end

% 求出face周围点的编号，主要用于MUSCL-Hou重构
for i = 1:Face.nf
    if Face.idn(i,1) == Cell.idn(Face.idc(i,1),1) && Face.idn(i,2) == Cell.idn(Face.idc(i,1),2)
        Face.nff(i,2) = Cell.idn(Face.idc(i,1),1);
        Face.nff(i,3) = Cell.idn(Face.idc(i,1),2);
        Face.nff(i,1) = Cell.idn(Face.idc(i,1),3);
    end
    if Face.idn(i,1) == Cell.idn(Face.idc(i,1),2) && Face.idn(i,2) == Cell.idn(Face.idc(i,1),3)
        Face.nff(i,2) = Cell.idn(Face.idc(i,1),2);
        Face.nff(i,3) = Cell.idn(Face.idc(i,1),3);
        Face.nff(i,1) = Cell.idn(Face.idc(i,1),1);
    end
    if Face.idn(i,1) == Cell.idn(Face.idc(i,1),3) && Face.idn(i,2) == Cell.idn(Face.idc(i,1),1)
        Face.nff(i,2) = Cell.idn(Face.idc(i,1),3);
        Face.nff(i,3) = Cell.idn(Face.idc(i,1),1);
        Face.nff(i,1) = Cell.idn(Face.idc(i,1),2);
    end
    
    if Face.idc(i,2) == 0
        Face.nff(i,4) = Face.nff(i,3);
    else
       if Cell.idn(Face.idc(i,2), 1) == Face.nff(i,3) &&  Cell.idn(Face.idc(i,2), 2) == Face.nff(i,2)
           Face.nff(i,4) = Cell.idn(Face.idc(i,2), 3);
       end
       if Cell.idn(Face.idc(i,2), 2) == Face.nff(i,3) &&  Cell.idn(Face.idc(i,2), 3) == Face.nff(i,2)
           Face.nff(i,4) = Cell.idn(Face.idc(i,2), 1);
       end
       if Cell.idn(Face.idc(i,2), 3) == Face.nff(i,3) &&  Cell.idn(Face.idc(i,2), 1) == Face.nff(i,2)
           Face.nff(i,4) = Cell.idn(Face.idc(i,2), 2);
       end
    end
end

end