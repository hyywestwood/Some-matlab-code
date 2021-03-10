%% 瞬时点源分子扩散
clc;clear;
mkdir ./pics
delete .\pics\*.jpg
D = 10e-9;  %分子扩散系数
x_1 = linspace(-0.5, 0.5, 1000);
% 解析解
syms x t
c = exp(-x^2/(4*D*t))/sqrt(4*pi*D*t)/10;

flag = 0;
for i = 1:0.1:11
    flag = flag + 1;
    c_point_initial = double(subs(c, {x, t}, {x_1, 86400*1})); 
    c_point = double(subs(c, {x, t}, {x_1, 86400*i}));  % 将XY对应代入xy，求得对应点位上的解析解
    figure('position',[100,100,800,500]);
    plot(x_1, c_point_initial, '--k', 'linewidth', 2)
    hold on
    plot(x_1, c_point, 'k', 'linewidth', 2)
    ylim([0 1.5])
    set(gca,'FontSize',20, 'FontName', 'Times New Roman');
    xlabel('X \fontname{仿宋}(米)', 'FontSize', 24, 'FontName', 'Times new roman', 'FontWeight', 'bold')
    ylabel('污染物浓度\fontname{Times new roman} c (mg/L)', 'FontSize', 24, 'FontName', '仿宋', 'FontWeight', 'bold')
    text(-0.28,1.3, {'\itD\rm = 10^{-5} cm^2/s'; ...
        ['\fontname{仿宋}模拟时长：\fontname{Times new roman}' num2str(i-1, '%.1f') '\fontname{仿宋}天']} ,...
        'FontSize',24,'Fontweight','bold', 'FontName', 'Times New Roman', 'HorizontalAlignment','center')
    hh = legend('初始条件','模拟结果');
    set(hh,'Location','northEast', 'FontSize', 20, 'FontName', '仿宋');
    print(['.\pics\' num2str(flag)],'-djpeg','-r400')
%     break
    close
end

namelist = dir(['.\pics' '\*.jpg']);
generate_video('.\pics', length(namelist), './瞬时点源.avi', 5); %生成视频
generate_GIF('.\pics', length(namelist), './瞬时点源.GIF', 5); %生成GIF


%% 函数
function generate_video(pic_path, pic_num, video_path, video_rate)
aviobj = VideoWriter(video_path);
%设置帧率
aviobj.FrameRate = video_rate;
open(aviobj)
%我制作了由180张图片构成的视频
for i = 1:pic_num
    frame = imread(fullfile(pic_path, [num2str(i) '.jpg']));
    writeVideo(aviobj,frame);
end
close(aviobj)
end

function generate_GIF(pic_path, pic_num, GIF_path, GIF_rate)
filename = GIF_path; % Specify the output file name
for idx = 1:pic_num
    [A,map] = rgb2ind(imread(fullfile(pic_path, [num2str(idx) '.jpg'])),256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1/GIF_rate);
    end
end
end



