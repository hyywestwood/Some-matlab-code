clc;clear;

% �����ļ��к�ɾ���ļ���
if exist('.\simulation_results','dir') == 0
    mkdir('.\simulation_results');
else
    rmdir('.\simulation_results', 's')
    mkdir('.\simulation_results');
end

% ����exe����status��Ϊ0ʱ��ʾexe�ļ����д���
% status = 1;
% while status ~= 0
%     [status,cmdout] = system('without.exe');
% end

% ʱ�䴦��
time_origin = datetime('2013-05-18','InputFormat','yyyy-MM-dd');
time_duration = days(1);
time_end = time_origin + time_duration;
dt = datenum(time_end - time_origin)*86400;
