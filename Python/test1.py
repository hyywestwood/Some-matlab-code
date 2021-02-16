""""
使用Pytecplot库调用tecplot进行绘图
"""

'''
1. 确保自己的tecplot为2017及以上，2018最好，并按Scripting--Pytecplot connections--勾选Accept connections
2. 确保自己使用64位的python3，并安装Pytecplot库和numpy库
3. 编写绘图代码，如下，并运行
注：详细操作参见pytecplot的文档，一般tecplot安装目录中就有
'''
import tecplot as tp
from tecplot.constant import PlotType, AxisMode, AxisTitleMode, TextBox
import numpy as np

tp.session.connect(port=7600)   # 与tecplot程序连接

# 读取数据并创建一个新frame
# file_data = tp.data.load_tecplot(r'D:\辽河\支流对比\1110\与实测对比验证\第六次模拟\算例\渤海1229-50N-长周期\REsults\RESULTS01050.DAT')
file_data = tp.data.load_tecplot(r'RESULTS01050.DAT')
frame = tp.active_frame()
frame.position = (0.2, 0.5) # frame的位置
frame.width = 8     # frame的长
frame.height = 6    # frame的高
frame.show_border = False   # 不显示frame的最外边框

# 绘图的一些基础设置
plot = frame.plot(PlotType.Cartesian2D)
plot.activate()
plot.axes.viewport.left = 12    # 确定坐标区的大小，即Axis details中的Area
plot.axes.viewport.right = 95
plot.axes.viewport.top = 95
plot.axes.viewport.bottom = 10
plot.axes.grid_area.show_border = True      # 坐标区四周边框显示，即Axis details中的Line--show grid border

# 选择展示数据，这里设为水位z，并设置了color map
plot.contour(0).variable = file_data.variable('z')
plot.contour(0).colormap_name = 'Modified Rainbow - Dark ends'
plot.show_contour = True

# 对x轴的设置，字体、字号等
xaxis = plot.axes.x_axis
xaxis.title.text = 'Longitudinal (m)'
xaxis.title.title_mode = AxisTitleMode.UseText
xaxis.min = 520
xaxis.max = 1080
xaxis.title.font.typeface = 'Times New Roman'   #同理可设置bold, italic, size等
xaxis.title.font.size = 4
xaxis.title.offset = 6
xaxis.tick_labels.font.typeface = 'Times'
xaxis.tick_labels.font.size = 3.5

# 对y轴的设置
yaxis = plot.axes.y_axis
yaxis.title.text = 'Latitudinal (m)'
yaxis.title.title_mode = AxisTitleMode.UseText
yaxis.min = 4100
yaxis.max = 4560
yaxis.title.font.typeface = 'Times New Roman'   #同理可设置bold, italic, size等
yaxis.title.font.size = 4
yaxis.title.offset = 8
yaxis.tick_labels.font.typeface = 'Times'
yaxis.tick_labels.font.size = 3.5

# 图片legend显层数
levels = frame.plot().contour(0).levels
levels.reset_levels(np.linspace(0,3,11))

# 对legend的详细设置
legend = plot.contour(0).legend
legend.show = True
legend.overlay_bar_grid = False
legend.position = (93, 74)  # Frame percentages
legend.box.box_type = TextBox.None_ # Remove Text box
legend.header_font.typeface = 'Times'
legend.header_font.size = 4.5
legend.header_font.bold = True
legend.number_font.typeface = 'Times'
legend.number_font.size = 3.5
legend.number_font.bold = False

# 保存图片
tp.export.save_png('test.png', 600, supersample=3)
