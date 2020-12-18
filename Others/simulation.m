clc;clear;

% 生成文件夹和删除文件夹
if exist('.\simulation_results','dir') == 0
    mkdir('.\simulation_results');
else
    rmdir('.\simulation_results', 's')
    mkdir('.\simulation_results');
end

% 调用exe程序，status不为0时表示exe文件运行错误
% status = 1;
% while status ~= 0
%     [status,cmdout] = system('without.exe');
% end

% 时间处理
time_origin = datetime('2013-05-18','InputFormat','yyyy-MM-dd');
time_duration = days(1);
time_end = time_origin + time_duration;
dt = datenum(time_end - time_origin)*86400;
