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



## PIC_plot

主要记录一些画图用到的代码，还没仔细整理



## File read and generate

主要记录对程序计算结果进行读取的MATLAB代码，以及重新生成tecplot文件的代码等

[topr文件的MATLAB重写](/File read and generate /topr.m)

[程序输出文件的读取](/File read and generate/result_process.m)

[生成Tecplot格式的文件](/File read and generate/result_generate.m)