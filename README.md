# ZYNQ7010_CNN_Implementation

在ZYNQ-7010上部署卷积神经网络。包括2X2卷积层、最大池化层、线性层、Relu层、线性层、Relu层、softmax层。所有的计算都是基于FP16半精度浮点数据。
由于7010资源很少，因此在编写代码时用了些小trick，比如把卷积矩阵、线性层中的bias偏置等设置成0，线性层中的filter设置成0.01等。
目前资源占用率比较少，只使用了44%的LUT，20%的FF，但相应的，处理速度就比较慢了，在50MHz工作频率下，对于输入尺寸为28*28的FP16精度数据/图片，可以实现19K帧/s

目前还存在一些问题，比如在综合的时候部分代码会被优化掉导致逻辑出错（应该是代码问题）；FP16数据的指数计算及求倒数方法，目前的算法比较实用，但不优雅简洁，有待改进。
目前暂挂着，后续实验上有实际需求了再来优化。
