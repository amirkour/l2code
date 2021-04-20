using System;
using Xunit;


namespace MedianWithHeaps.Test
{
    public class MedianFinderTests
    {
        protected MedianFinder _finder;
        public MedianFinderTests()
        {
            _finder = new MedianFinder();
        }

        [Theory]
        [InlineData(new int[] { 1, 2, 3, 4, 5 }, 5)]
        [InlineData(new int[] { 11, -2, 301, 204, 15, 1, 12, -9 }, 8)]
        public void AddNumSmokeTest(int[] numbers, int size)
        {
            Array.ForEach<int>(numbers, i => _finder.AddNum(i));
            Assert.Equal(size, _finder.Size);
        }

        [Fact]
        public void AddNum_EvenSides_GTEMin()
        {
            // put something in both sides:
            _finder.AddNum(5);  // this'll go on the right
            _finder.AddNum(-1); // and this'll go on the left
            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);

            // now insert something >= min.peek
            _finder.AddNum(6);
            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.True(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_EvenSides_BetweenSides()
        {
            // put something in both sides:
            _finder.AddNum(5);  // this'll go on the right
            _finder.AddNum(-1); // and this'll go on the left
            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);

            // now insert something b/w min.peek and max.peek
            _finder.AddNum(1);
            Assert.True(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_EvenSides_LTEMax()
        {
            // put something in both sides:
            _finder.AddNum(5);  // this'll go on the right
            _finder.AddNum(-1); // and this'll go on the left
            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);

            // now insert something <= max.peek
            _finder.AddNum(-2);
            Assert.True(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_LeftBigger_GTEMin()
        {
            // put something in the left list ...
            _finder.AddNum(-5);

            // now left is bigger.
            // add something >= min.peek
            _finder.AddNum(2);

            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_LeftBigger_BetweenSides()
        {
            // put something in the left list ...
            _finder.AddNum(-5);

            // now left is bigger.
            // insert something b/w max.peek and min.peek
            _finder.AddNum(-2);

            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_LeftBigger_LTEMax()
        {
            // put something in the left list ...
            _finder.AddNum(-5);

            // now left is bigger.
            // insert something <= max.peek
            _finder.AddNum(-10);

            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_RightBigger_GTEMin()
        {
            // put something in the right list ...
            _finder.AddNum(5);

            // now right is bigger.
            // add something bigger than right.peek
            _finder.AddNum(10);

            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_RightBigger_BetweenSides()
        {
            // put something in the right list ...
            _finder.AddNum(5);

            // now right is bigger.
            // insert something between left.peek and right.peek
            _finder.AddNum(3);

            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_RightBigger_LTEMax()
        {
            // put something in the right-list ...
            _finder.AddNum(5);

            // now right is bigger.
            // insert something LTE leftMax.peek
            _finder.AddNum(-2);

            Assert.False(_finder.LeftSideOfListIsLarger);
            Assert.False(_finder.RightSideOfListIsLarger);
        }

        [Fact]
        public void AddNum_ABunchOfZeros()
        {
            _finder.AddNum(0);  // this should go min/right
            Assert.True(_finder.RightSideOfListIsLarger);

            _finder.AddNum(0);  // this should flip-flop 'em, so both lists are equal now
            Assert.False(_finder.LeftSideOfListIsLarger || _finder.RightSideOfListIsLarger);

            _finder.AddNum(0);  // again, min/right
            Assert.True(_finder.RightSideOfListIsLarger);
        }

        [Theory]
        [InlineData(new int[] { 2, 1, 5, 4, 3 }, 3.0)]
        [InlineData(new int[] { 1, 2, 3, 7, 5, 6, 4 }, 4.0)]
        [InlineData(new int[] { 1 }, 1.0)]
        public void FindMedian_OddSizeList_SmokeTest(int[] numbers, double medianExpected)
        {
            Array.ForEach<int>(numbers, i => _finder.AddNum(i));
            Assert.Equal(medianExpected, _finder.FindMedian());
        }

        [Theory]
        [InlineData(new int[] { 5, 4, 3, 2, 1, 6 }, 3.5)]
        [InlineData(new int[] { 7, 5, 3, 4, 2, 6, 1, 8 }, 4.5)]
        [InlineData(new int[] { 1, 2 }, 1.5)]
        public void FindMedian_EvenSizeList_SmokeTest(int[] numbers, double medianExpected)
        {
            Array.ForEach<int>(numbers, i => _finder.AddNum(i));
            Assert.Equal(medianExpected, _finder.FindMedian());
        }
    }
}