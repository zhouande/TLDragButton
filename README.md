+# TLDragButton
+TLDragButton *btn = [TLDragButton buttonWithType:UIButtonTypeCustom];
+btn.dragColor = [UIColor blueColor]; // 设置拖拽的时候按钮的颜色
+[array addObject:btn];  //所有的按钮添加进数组
+ btn.btnArray = array;  // 把按钮数组传给btn.btnArray 
+ 使用非常简单，左右的操作都在TLDragButton中进行的
+ 当按钮发生拖拽的时候，通过此代理即可获知
+ /**
+ *  @brief  通知父视图button的排列顺序发生了改变
+ *
+ *  @param dragButton  被拖拽的button
+ *  @param dragButtons 新排列的button数组
+ */
+- (void)dragButton:(TLDragButton *)dragButton dragButtons:(NSArray *)dragButtons;
