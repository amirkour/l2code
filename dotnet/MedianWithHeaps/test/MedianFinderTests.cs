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
    }
}