---
title: RecyclerView嵌套使用
date: 2016-01-09 10:32:22
categories: Android
tags: RecyclerView
---
一般情况下RecyclerView是不推荐嵌套使用的，我们可以用使用不同的Type使RecyclerView达到嵌套的效果，
这里先不介绍这种方式。因为最近项目需要将RecyclerView嵌套在NestedScrollView中使用，下面记录一下
在NestedScrollView中如何使用RecyclerView。

<!--more-->

#### 如何使用
首先我们先看下布局文件
![Smithsonian Image](/images/recyclerview-060105.png)
在我们使用ListView的时候，如果需要嵌套，我们一般的做法是重写ListView的onMearsure方法，如下：
``` java
@Override protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) { 
              int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2, MeasureSpec.AT_MOST); 
              super.onMeasure(widthMeasureSpec, expandSpec); 
}
```
但是RecyclerView并不是这样做，而是通过修改RecyclerView.LayoutManager实现，比如重写LinearLayoutManager，GridLayoutManager
或StaggeredGridLayoutManager，下面我们以LinearLayoutManager为例，如下：
``` java
public class WrappingLinearLayoutManager extends LinearLayoutManager{

    public WrappingLinearLayoutManager(Context context) {
        super(context);
    }

    private int[] mMeasuredDimension = new int[2];

    @Override public boolean canScrollVertically() {
        return false;
    }

    @Override public void onMeasure(RecyclerView.Recycler recycler, RecyclerView.State state,
                          int widthSpec, int heightSpec) {
        final int widthMode = View.MeasureSpec.getMode(widthSpec);
        final int heightMode = View.MeasureSpec.getMode(heightSpec);

        final int widthSize = View.MeasureSpec.getSize(widthSpec);
        final int heightSize = View.MeasureSpec.getSize(heightSpec);

        int width = 0;
        int height = 0;
        //
        if (state.getItemCount() == 0 || state.didStructureChange() || !state.isMeasuring()){
            return;
        }
        for (int i = 0; i < getItemCount(); i++) {
            if (getOrientation() == HORIZONTAL) {
                measureScrapChild(recycler, i,
                        View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                        heightSpec,
                        mMeasuredDimension);

                width = width + mMeasuredDimension[0];
                if (i == 0) {
                    height = mMeasuredDimension[1];
                }
            } else {
                measureScrapChild(recycler, i,
                        widthSpec,
                        View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                        mMeasuredDimension);

                height = height + mMeasuredDimension[1];
                if (i == 0) {
                    width = mMeasuredDimension[0];
                }
            }
        }

        switch (widthMode) {
            case View.MeasureSpec.EXACTLY:
                width = widthSize;
            case View.MeasureSpec.AT_MOST:
            case View.MeasureSpec.UNSPECIFIED:
        }

        switch (heightMode) {
            case View.MeasureSpec.EXACTLY:
                height = heightSize;
            case View.MeasureSpec.AT_MOST:
            case View.MeasureSpec.UNSPECIFIED:
        }

        setMeasuredDimension(width, height);
    }

    private void measureScrapChild(RecyclerView.Recycler recycler, int position, int widthSpec,
                                   int heightSpec, int[] measuredDimension) {

        View view = recycler.getViewForPosition(position);
        if (view.getVisibility() == View.GONE) {
            measuredDimension[0] = 0;
            measuredDimension[1] = 0;
            return;
        }
        // For adding Item Decor Insets to view
        super.measureChildWithMargins(view, 0, 0);
        RecyclerView.LayoutParams p = (RecyclerView.LayoutParams) view.getLayoutParams();
        int childWidthSpec = ViewGroup.getChildMeasureSpec(
                widthSpec,
                getPaddingLeft() + getPaddingRight() + getDecoratedLeft(view) + getDecoratedRight(view),
                p.width);
        int childHeightSpec = ViewGroup.getChildMeasureSpec(
                heightSpec,
                getPaddingTop() + getPaddingBottom() + getDecoratedTop(view) + getDecoratedBottom(view),
                p.height);
        view.measure(childWidthSpec, childHeightSpec);

        // Get decorated measurements
        measuredDimension[0] = getDecoratedMeasuredWidth(view) + p.leftMargin + p.rightMargin;
        measuredDimension[1] = getDecoratedMeasuredHeight(view) + p.bottomMargin + p.topMargin;
        recycler.recycleView(view);
    }

}
```
然后我们给RecyclerView设置我们自定义的LayoutManager，然后禁止RecyclerView滑动和设置其可改变大小，如下：
``` java
    mRecyclerView.setLayoutManager(new WrappingLinearLayoutManager(getContext()));
    mRecyclerView.setNestedScrollingEnabled(false); 
    mRecyclerView.setHasFixedSize(false);
```
现在就可以实现RecyclerView嵌套使用了。


