%% PRICE scheme
%{
基于PRICE有限差分格式，对一维浅水方程求解，见Eq5-8 in Canestrelli et al., 2009; doi:doi:10.1016/j.advwatres.2009.02.006
求解的方程为圆柱溃坝一维偏微分方程，表达式见Eq.59 in Canestrelli et al., 2010; doi:10.1016/j.advwatres.2009.12.006
未使用文章中改进的PRICE-C格式，因为没看懂，故现在只能通过加密网格来提升求解精度
不想运行程序，可直接使用结果文件，以dx**-time**.txt为文件名，文件格式为x-h-u
%}
clc;clear;

% 计算场设定
X = linspace(0,25,100000);
dx = 25/length(X);
h = zeros(1, length(X));
u = zeros(1, length(X));
dt = 0.00001;


% 初始条件
h(X < 10) = 10;
h(X >= 10) = 1;
hu = h.*u;
time=0;
k =1;

tic
figure('position',[100,100,800,450]);
while time <= 1

%     求解对流通量
    h_force = get_flux(h, u, X, dt, dx);
    hu_force = get_flux(hu, u, X, dt, dx);
    
    % 求解源项--静水压力项
    source = source_flux(h, u, X, dt, dx);
    
for i = 2:length(X)-1
%     h_new(i) = h(i) - dt*(h_force(i) - h_force(i-1))/dx;
%     hu_new(i) = hu(i) - dt*(hu_force(i) - hu_force(i-1))/dx + dt*source(i);
    h_new(i) = h(i) - dt*(h_force(i) - h_force(i-1))/dx - dt*h(i)*u(i)/X(i);
    hu_new(i) = hu(i) - dt*(hu_force(i) - hu_force(i-1))/dx + dt*source(i) - dt*hu(i)*u(i)/X(i);
end
    h_new(1) = h_new(2);
    hu_new(1) = hu_new(2);
    h_new(length(X)) = h_new(length(X)-1);
    hu_new(length(X)) = hu_new(length(X)-1);
    
    h = h_new;
    hu = hu_new;  
    u = hu./h;
    u(isnan(u)) = 0;
%     h(h<0)=0;u(u<0)=0;
%     u = zeros(1, length(X)) + 10;
    
%     plot(X, h, 'linewidth', 2)
%     xlim([4, 16])
%     ylim([0 12])
%     xlabel('X(m)')
%     ylabel('h(m)')
%     title(['time: ', num2str(time, '%.4f'),'s' ])
%     grid on
% %     pause(0.01)
%     frame=getframe(gcf);
%     clf; 
   
    time = time + dt;
    
    if abs(time - 0.1*k)<dt
        write_file(h, u, X, time, dx);
        k = k+1;
        fprintf(['time: ' num2str(time, '%.2f') 's finished... \r'])
    end
%     fprintf(['time: ' num2str(time, '%.4f') 's finished... \r'])
end
% write_file(h, u, X, time, dx)
mytime = toc;
disp(mytime)

%% 一些函数
function write_file(h, u, X, time, dx)
% 输出数据文件，格式为x-h-u
fid = fopen(['dx' num2str(dx, '%.5f') '-time' num2str(time, '%.2f') '.txt'], 'w');
for i = 1:length(X)
    fprintf(fid, '%.5f \t %.5f \t %.5f \r\n', X(i), h(i), u(i));
end
fclose(fid);

end

% 对流通量
function F_force = get_flux(h, u, X, dt, dx)
for i = 1:length(X)-1
    LF(i) = 0.5*(h(i)*u(i) + h(i+1)*u(i+1))-0.5*dx*(h(i+1) - h(i))/dt;
    Qi_half(i) = 0.5*(h(i) + h(i+1)) - 0.5*dt*(h(i+1)*u(i+1) - h(i)*u(i))/dx;
    Ui_half(i) = 0.5*(u(i) + u(i+1)) - 0.5*dt*(u(i+1)*u(i+1) - u(i)*u(i))/dx;
    LW(i) = Qi_half(i)*Ui_half(i);
    F_force(i) = 0.5*(LF(i) + LW(i));
%     F_force(i) = LF(i);
end
end

% 源项的计算--使用中心差分格式求解
function source = source_flux(h, u, X, dt, dx)

for i = 2:length(X)-1
    source(i) = -0.5*9.8*(h(i+1)^2.0 - h(i-1)^2.0 )/dx/2;
end
source(1) = source(2);
source(length(X)) = source(length(X)-1);

end
