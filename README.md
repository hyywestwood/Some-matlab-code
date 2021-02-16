# Some Code
记录一些平常用到的代码

# CFD

该文件夹用于记录一些有限差分格式求解的浅水方程等

[求解一维Sanders 2008文章中的溃坝](/CFD/Dam_break_2008.m)

[求解一维圆柱溃坝的数值解](/CFD/FDM_cycle_dam_break.m)



## SMS

该文件夹中包含对SMS程序生成网格后的源文件进行读取的代码

[读取网格文件中的h5文件](/SMS/SMS_h5.m)

[读取网格文件中的map文件](/SMS/SMS_map.m)

[读取网格文件中的geo, bc文件](/File_read_and_generate/topr.m)



## PIC_plot

主要记录一些画图用到的代码，还没仔细整理



## File_read_and_generate

主要记录对程序计算结果进行读取的MATLAB代码，以及重新生成tecplot文件的代码等

[topr文件的MATLAB重写](/File_read_and_generate/topr.m)

[程序输出文件的读取](/File_read_and_generate/result_process.m)

[生成Tecplot格式的文件](/File_read_and_generate/result_generate.m)



# Others

该部分记录一些平常使用的一些小技巧，以及杂七杂八的代码文件

~~~matlab

%% 生成文件夹和删除文件夹
if exist('.\simulation_results','dir') == 0
    mkdir('.\simulation_results');
else
    rmdir('.\simulation_results', 's')
    mkdir('.\simulation_results');
end

%% 调用exe程序，status不为0时表示exe文件运行错误，cmout为原exe文件运行时的输出
status = 1;
while status ~= 0
    [status,cmdout] = system('without.exe');
end

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

x1 = 1400; y1 = 1400; %解析解中的参数
x2 = 2400; y2 = 2400;
c1 = 10; c2 = 6.5;
u = 0.5; v = 0.5;
t=9600; theta=264; internal=10;

c = c1 * exp(-((x - u * t - x1) / theta)^2.0 - ((y - v * t - y1) / theta)^2.0) + c2 * exp(-((x - u * t - x2) / theta)^2.0 - ((y - v * t - y2) / theta)^2.0);  % 解析解的表达式
c = c/internal;

[X,Y] = meshgrid(linspace(0, 9000, 500),linspace(0, 9000, 500));
c_exact = double(subs(c,{x,y},{X,Y}));  % 将XY对应代入xy，求得对应点位上的解析解


~~~

# Python

该部分记录用Python写的一些代码片段

[使用Pytecplot调用tecplot进行绘图](/Python/test1.py)