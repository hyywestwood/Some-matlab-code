%% �����������йص�MATLAB����
clc;clear;
file_path = '.';
% ��ȡcell.geo�ļ�
% bc = read_bc(file_path);

% ��ȡcell.bc�ļ�
% cell = read_cell(file_path);

% ��ĳЩ����£����ǻ������Ҫ����������Χ�߽�һȦ�Ľǵ�����
% ����1����SMS�н�����һȦ��ñ߽絼��Ϊcell.bc,���cell.geo��������������
% boundry = get_boundry1(file_path);

% ����2������cell.geo�ļ�������������˹�ϵ����߽�
% ����������

% ������Topr��MATLABʵ��
[Cell, Face, Node] = run_topr(file_path);


%% һЩ����
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
���������ڶ�ȡcell.geo�ļ�������ֵΪ�����ļ������ļ���·��
����ֵΪcell�ṹ���飬cell.topr��¼��������ǵ��������Ϣ
cell.node��¼�ǵ��Ӧ��x,y,zֵ;
cell,nc��cell.nn�ֱ�Ϊ���������ͽǵ�����
cell.x��cell.y, cell.z�ֱ�������Ԫ���ĵ�xyz
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
���������ڶ�ȡcell.bc�ļ�������ֵΪ�߽��ļ������ļ���·�������Լ��޸����ڶ�ȡcspoint.bc�ļ�
����ֵΪBC�ṹ�壬BC.bc1��¼��һ���߽�Ľǵ��ţ�BC.bc2��¼�ڶ����߽�...�Դ�����
BC.bc_numΪ�߽�����
���ļ���û�б߽���Ϣ�����᷵�ؿվ���[],����isempty(BC)���ж�
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
    fprintf('�ļ���û�б߽���Ϣ������ \n')
end
fclose(fid);
end

function [Cell, Face, Node] = run_topr(file_path)
%{
������ο�Fortran�汾��topr�ļ���������Cell,Face,Node�����ṹ��
Cell�ṹ���а���idn,nc,idf,rfn,x,y,zb0,area
Face�ṹ���а���idc,idn,xm,ym,length,rfn,nf,bcstl,nff
Node�ṹ���а���x,y,zbo,nn,idcn,idc,idlh
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

% ��ʼ���壬�ߵ�����
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

bar = waitbar(0,'1', 'Name','�ߵ�����...');
II = 3;
for i = 2:Cell.nc
    str = ['Ѱ��idc1,idn...',num2str(100*i/Cell.nc, '%.1f'),'%'];
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

bar = waitbar(0,'1', 'Name','�ߵ�����...');
for i = 1:Face.nf
    str = ['Ѱ��idc2...',num2str(100*i/Face.nf, '%.1f'),'%'];
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

bar = waitbar(0,'1', 'Name','���������...');
for i = 1:Cell.nc
    str = ['ȷ��Cell.idf...',num2str(100*i/Cell.nc, '%.1f'),'%'];
    waitbar(i/Cell.nc,bar,str)
    for j = 1:Face.nf
        % ��Ԫ��Ӧ��һ����
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
        
        % ��Ԫ��Ӧ�ڶ�����
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
        
        % ��Ԫ��Ӧ��san����
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

bar = waitbar(0,'1', 'Name','���������...');
for i = 1:Cell.nc
    str = ['ȷ������Ԫ��x,y,zb0,area...',num2str(100*i/Cell.nc, '%.1f'),'%'];
    waitbar(i/Cell.nc,bar,str)
    Cell.x(i) = ( Node.x(Cell.idn(i,1)) + Node.x(Cell.idn(i,2)) + Node.x(Cell.idn(i,3)))/3.0d0;
    Cell.y(i) = ( Node.y(Cell.idn(i,1)) + Node.y(Cell.idn(i,2)) + Node.y(Cell.idn(i,3)))/3.0d0;
    Cell.zb0(i) = ( Node.zb0(Cell.idn(i,1)) + Node.zb0(Cell.idn(i,2)) + Node.zb0(Cell.idn(i,3)))/3.0d0;
    Cell.area(i) = 1.0/2.0*( Face.length(Cell.idf(i,1)) + Face.length(Cell.idf(i,2)) + Face.length(Cell.idf(i,3)) );
    Cell.area(i) = Cell.area(i)*( Cell.area(i) - Face.length(Cell.idf(i,1)) )*( Cell.area(i) - Face.length(Cell.idf(i,2)) )*( Cell.area(i) - Face.length(Cell.idf(i,3)) );
    Cell.area(i) = sqrt(Cell.area(i));
end
close(bar);

% �����ڵ�����˹�ϵ
bar = waitbar(0,'1', 'Name','�ǵ������...');
for i = 1:Node.nn
    str = ['ȷ��Node��Χ������...',num2str(100*i/Node.nn, '%.1f'),'%'];
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

% �ڵ㷴������Ȩ��Ȩ��
for i = 1:Node.nn
    Node.sidlh(i) = 0;
    for j = 1:Node.idcn(i)
        Node.idlh(i,j) = 1.0/sqrt( (Node.x(i) - Cell.x(Node.idc(i,j)) )^2.0 + (Node.y(i) - Cell.y(Node.idc(i,j)) )^2.0  );
    end
end

% ���face��Χ��ı�ţ���Ҫ����MUSCL-Hou�ع�
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