using System;
using DotNetHeap;

namespace MedianSlidingWindow
{
    public class Program
    {
        public double[] MedianSlidingWindow(int[] nums, int k)
        {
            if (nums == null || nums.Length <= 0 || k <= 0)
                return new double[0];

            DotNetHeap<int> leftMax = new DotNetHeap<int>();
            DotNetHeap<int> rightMin = new DotNetHeap<int>(DotNetHeap<int>.HEAP_TYPE.MIN);

            k = k > nums.Length ? nums.Length : k;
            double[] results = new double[nums.Length - k + 1];
            int resultIndex = 0;

            for (int i = k - 1; i < nums.Length; i++)
            {

                int j = i - (k - 1);
                int startIndex = j;

                if (j == 0)
                {
                    for (; j <= i; j++)
                    {
                        this.AddToHeaps(nums[j], leftMax, rightMin);
                    }
                }
                else
                {
                    this.AddToHeaps(nums[i], leftMax, rightMin);
                }

                results[resultIndex++] = this.GetMedian(leftMax, rightMin);
                this.RemoveFromHeaps(nums[startIndex], leftMax, rightMin);
            }


            return results;
        }

        public void PrintPreview(DotNetHeap<int> left, DotNetHeap<int> right)
        {
            for (int i = 2; i >= 0; i--)
                Console.Write("{0} ", left[i]);
            Console.Write("- ");
            for (int i = 0; i < 3; i++)
                Console.Write("{0} ", right[i]);
            Console.WriteLine(); Console.WriteLine();
        }

        public void AddToHeaps(int next, DotNetHeap<int> leftMax, DotNetHeap<int> rightMin)
        {
            if (leftMax.NumElements == 0 || next <= leftMax.Peek())
                leftMax.Enqueue(next);
            else
                rightMin.Enqueue(next);

            if (leftMax.NumElements > rightMin.NumElements + 1)
                rightMin.Enqueue(leftMax.Dequeue());
            else if (leftMax.NumElements < rightMin.NumElements)
                leftMax.Enqueue(rightMin.Dequeue());

            // if (leftMax.NumElements == rightMin.NumElements)
            // {
            //     if (next >= rightMin.Peek())
            //         rightMin.Enqueue(next);
            //     else
            //         leftMax.Enqueue(next);
            // }
            // else if (leftMax.NumElements < rightMin.NumElements)
            // {
            //     if (next >= rightMin.Peek())
            //     {
            //         leftMax.Enqueue(rightMin.Dequeue());
            //         rightMin.Enqueue(next);
            //     }
            //     else
            //     {
            //         leftMax.Enqueue(next);
            //     }
            // }
            // else
            // {
            //     if (next <= leftMax.Peek())
            //     {
            //         rightMin.Enqueue(leftMax.Dequeue());
            //         leftMax.Enqueue(next);
            //     }
            //     else
            //     {
            //         rightMin.Enqueue(next);
            //     }
            // }
        }

        public void RemoveFromHeaps(int toRemove, DotNetHeap<int> leftMax, DotNetHeap<int> rightMin)
        {
            if (toRemove <= leftMax.Peek())
            {
                leftMax.Remove(toRemove);
            }
            else
            {
                rightMin.Remove(toRemove);
            }

            if (leftMax.NumElements > rightMin.NumElements + 1)
                rightMin.Enqueue(leftMax.Dequeue());
            else if (leftMax.NumElements < rightMin.NumElements)
                leftMax.Enqueue(rightMin.Dequeue());
            // if (leftMax.NumElements > 0 && toRemove <= leftMax.Peek())
            // {
            //     leftMax.Remove(toRemove);
            //     if (leftMax.NumElements <= (rightMin.NumElements - 2))
            //         leftMax.Enqueue(rightMin.Dequeue());
            // }
            // else if (rightMin.NumElements > 0 && toRemove >= rightMin.Peek())
            // {
            //     rightMin.Remove(toRemove);
            //     if (rightMin.NumElements <= (leftMax.NumElements - 2))
            //         rightMin.Enqueue(leftMax.Dequeue());
            // }
        }

        public double GetMedian(DotNetHeap<int> leftMax, DotNetHeap<int> rightMin)
        {
            if (rightMin.NumElements == leftMax.NumElements)
            {
                return ((double)leftMax.Peek() / 2.0) + ((double)rightMin.Peek() / 2.0);
            }
            else
            {
                return (double)leftMax.Peek();
            }
            //     if (leftMax.NumElements == rightMin.NumElements)
            //     {
            //         return ((double)leftMax.Peek() / 2.0) + ((double)rightMin.Peek() / 2.0);
            //     }
            //     else
            //     {
            //         return leftMax.NumElements > rightMin.NumElements ? (double)leftMax.Peek() : (double)rightMin.Peek();
            //     }
        }
        static void Main(string[] args)
        {
            int[] nums = new int[] {2147483647, 1, 2, 3, 4, 5, 6, 7, 2147483647 };
            int k = 2;
            Program p = new Program();

            double[] sln = p.MedianSlidingWindow(nums, k);


            //             [2147483647,1,2,3,4,5,6,7,2147483647]
            // 2
            // Output
            // [1073741824.00000, 1.50000, 2.50000, 3.00000, 4.00000, 5.00000, 6.00000, 7.00000]
            // Expected
            // [1073741824.00000, 1.50000, 2.50000, 3.50000, 4.50000, 5.50000, 6.50000, 1073741827.00000]
        }
    }
}
