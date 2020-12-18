# Some MATLAB Code
记录一些平常用到的MATLAB代码

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

该文件夹中存放一些其他杂七杂八的代码文件

~~~matlab
```matlab 
% 生成文件夹和删除文件夹
if exist('.\simulation_results','dir') == 0
    mkdir('.\simulation_results');
else
    rmdir('.\simulation_results', 's')
    mkdir('.\simulation_results');
end

% 调用exe程序，status不为0时表示exe文件运行错误，cmout为原exe文件运行时的输出
status = 1;
while status ~= 0
    [status,cmdout] = system('without.exe');
end

% 时间处理
time_origin = datetime('2013-05-18','InputFormat','yyyy-MM-dd');
time_duration = days(1);
time_end = time_origin + time_duration;
dt = datenum(time_end - time_origin)*86400;

% 文件剪切和复制
movefile('origin_file_name', 'new_file_name');
copyfile('origin_file_name', 'new_file_name');

```
~~~