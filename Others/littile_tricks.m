clc;clear;

%% 生成文件夹和删除文件夹
if exist('.\simulation_results','dir') == 0
    mkdir('.\simulation_results');
else
    rmdir('.\simulation_results', 's')
    mkdir('.\simulation_results');
end

%% 调用exe程序，status不为0时表示exe文件运行错误
% status = 1;
% while status ~= 0
%     [status,cmdout] = system('without.exe');
% end

%% 时间处理
time_origin = datetime('2013-05-18','InputFormat','yyyy-MM-dd');
time_duration = days(1);
time_end = time_origin + time_duration;
dt = datenum(time_end - time_origin)*86400;

%% 文件剪切和复制
movefile('origin_file_name', 'new_file_name');
copyfile('origin_file_name', 'new_file_name');

%% 求解析解
syms x y

x1 = 1400; y1 =  1400; %解析解中的参数
x2 = 2400; y2 = 2400;
c1 = 10; c2 = 6.5;
u = 0.5; v = 0.5;
t=9600; theta=264; internal=10;

c = c1 * exp(-((x - u * t - x1) / theta)^2.0 - ((y - v * t - y1) / theta)^2.0) + c2 * exp(-((x - u * t - x2) / theta)^2.0 - ((y - v * t - y2) / theta)^2.0);  % 解析解的表达式
c = c/internal;

[X,Y] = meshgrid(linspace(0, 9000, 500),linspace(0, 9000, 500));
c_exact = double(subs(c,{x,y},{X,Y}));  % 将XY对应代入xy，求得对应点位上的解析解