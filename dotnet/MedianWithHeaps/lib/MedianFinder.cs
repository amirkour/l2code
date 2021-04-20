using System;
using DotNetHeap;

namespace MedianWithHeaps
{
    public class MedianFinder
    {
        protected DotNetHeap<int> _leftMaxHeap;
        protected DotNetHeap<int> _rightMinHeap;

        public int Size { get { return _leftMaxHeap.NumElements + _rightMinHeap.NumElements; } }
        public bool LeftSideOfListIsLarger { get { return _leftMaxHeap.NumElements > _rightMinHeap.NumElements; } }
        public bool RightSideOfListIsLarger { get { return _rightMinHeap.NumElements > _leftMaxHeap.NumElements; } }

        public MedianFinder()
        {
            _leftMaxHeap = new DotNetHeap<int>((a, b) => { return a - b; });
            _rightMinHeap = new DotNetHeap<int>((a, b) => { return a - b; }, DotNetHeap<int>.HEAP_TYPE.MIN);
        }

        public MedianFinder AddNum(int num)
        {
            if (this.LeftSideOfListIsLarger)
            {
                if (num >= _rightMinHeap.Peek())
                {
                    _rightMinHeap.Enqueue(num);
                }
                else if (num > _leftMaxHeap.Peek() && num < _rightMinHeap.Peek())
                {
                    _rightMinHeap.Enqueue(num);
                }
                else
                { // num is <= _rightMinHeap.Peek()
                    _rightMinHeap.Enqueue(_leftMaxHeap.Dequeue());
                    _leftMaxHeap.Enqueue(num);
                }
            }
            else if (this.RightSideOfListIsLarger)
            {
                if (num >= _rightMinHeap.Peek())
                {
                    _leftMaxHeap.Enqueue(_rightMinHeap.Dequeue());
                    _rightMinHeap.Enqueue(num);
                }
                else if (num > _leftMaxHeap.Peek() && num < _rightMinHeap.Peek())
                {
                    _leftMaxHeap.Enqueue(num);
                }
                else
                { // num is <= _leftMaxHeap.Peek()
                    _leftMaxHeap.Enqueue(num);
                }
            }

            // both lists have equal size ...
            else
            {
                if (num >= _rightMinHeap.Peek())
                {
                    _rightMinHeap.Enqueue(num);
                }
                else if (num > _leftMaxHeap.Peek() && num < _rightMinHeap.Peek())
                {
                    _leftMaxHeap.Enqueue(num);
                }
                else
                { // num is <= _leftMaxHeap.Peek()
                    _leftMaxHeap.Enqueue(num);
                }
            }

            return this;
        }
    }
}
