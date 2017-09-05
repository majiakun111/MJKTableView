实现的步骤
1.为了能滚动需先计算出contentSize

2.计算出每个cell的位置，包括frame和indexPath

3.cell的布局
   3.1 通过cell的y和scrollView的contentOffset.y比较拿到当前屏幕需要的展示的开始indexPath
   3.2 通过cell的y和scrollView的contentOffset.y + scrollView.frame.size.height比较拿到当前屏幕需要的展示的最后一个indexPath

4.实现重用
   4.1 通过visiableCellSet和cacheCellSet实现， 去取重用的cell时需要需要注意：先从可见的visiableCellSet取，再从缓存的cacheCellSet取
   
5.监听contentOffset的变化，当新旧的y不一致时 执行第三步
